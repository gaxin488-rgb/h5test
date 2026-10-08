[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [int]$TargetPid,
    [int]$Port = 7655
)

$ErrorActionPreference = 'Stop'

if ($Port -lt 1024 -or $Port -gt 65535) {
    throw 'Port must be between 1024 and 65535.'
}

if (-not ('TinhLinh.ReadOnlyCapture' -as [type])) {
    Add-Type -AssemblyName System.Drawing
    Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;

namespace TinhLinh {
    public static class ReadOnlyCapture {
        [StructLayout(LayoutKind.Sequential)]
        public struct Rect {
            public int Left;
            public int Top;
            public int Right;
            public int Bottom;
        }

        [DllImport("user32.dll")]
        public static extern bool GetWindowRect(IntPtr handle, out Rect rect);

        [DllImport("user32.dll")]
        public static extern bool PrintWindow(IntPtr handle, IntPtr deviceContext, uint flags);
    }
}
'@
}

function Capture-GameWindow {
    $process = Get-GameWindow
    $rect = New-Object TinhLinh.ReadOnlyCapture+Rect
    if (-not [TinhLinh.ReadOnlyCapture]::GetWindowRect($process.MainWindowHandle, [ref]$rect)) {
        throw 'GetWindowRect failed.'
    }
    $width = $rect.Right - $rect.Left
    $height = $rect.Bottom - $rect.Top
    if ($width -le 0 -or $height -le 0 -or $width -gt 8192 -or $height -gt 8192) {
        throw 'Invalid game window bounds.'
    }

    $bitmap = New-Object System.Drawing.Bitmap($width, $height)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $deviceContext = $graphics.GetHdc()
    try {
        if (-not [TinhLinh.ReadOnlyCapture]::PrintWindow($process.MainWindowHandle, $deviceContext, 2)) {
            throw 'PrintWindow failed.'
        }
    }
    finally {
        $graphics.ReleaseHdc($deviceContext)
        $graphics.Dispose()
    }

    $stream = New-Object System.IO.MemoryStream
    try {
        $bitmap.Save($stream, [System.Drawing.Imaging.ImageFormat]::Png)
        return @{
            Process = $process
            Rect = $rect
            Bytes = $stream.ToArray()
        }
    }
    finally {
        $stream.Dispose()
        $bitmap.Dispose()
    }
}

function Send-Bytes {
    param(
        [Parameter(Mandatory = $true)]$Context,
        [Parameter(Mandatory = $true)][byte[]]$Bytes,
        [Parameter(Mandatory = $true)][string]$ContentType
    )

    $Context.Response.StatusCode = 200
    $Context.Response.ContentType = $ContentType
    $Context.Response.ContentLength64 = $Bytes.Length
    $Context.Response.Headers['Cache-Control'] = 'no-store'
    $Context.Response.OutputStream.Write($Bytes, 0, $Bytes.Length)
    $Context.Response.Close()
}

function Send-Json {
    param(
        [Parameter(Mandatory = $true)]$Context,
        [Parameter(Mandatory = $true)]$Object,
        [int]$StatusCode = 200
    )

    $bytes = [Text.Encoding]::UTF8.GetBytes(($Object | ConvertTo-Json -Depth 5 -Compress))
    $Context.Response.StatusCode = $StatusCode
    $Context.Response.ContentType = 'application/json; charset=utf-8'
    $Context.Response.ContentLength64 = $bytes.Length
    $Context.Response.Headers['Cache-Control'] = 'no-store'
    $Context.Response.OutputStream.Write($bytes, 0, $bytes.Length)
    $Context.Response.Close()
}

function Get-GameWindow {
    $process = Get-Process -Id $TargetPid -ErrorAction Stop
    if ($process.MainWindowHandle -eq 0) {
        throw 'Game process has no visible window.'
    }
    return $process
}

$listener = [Net.HttpListener]::new()
$listener.Prefixes.Add("http://127.0.0.1:$Port/")
$listener.Start()
Write-Output ("Read-only MCP screen bridge online: http://127.0.0.1:{0}/mcp/" -f $Port)

try {
    while ($listener.IsListening) {
        $context = $listener.GetContext()
        try {
            if ($context.Request.HttpMethod -ne 'GET') {
                Send-Json -Context $context -Object @{ ok = $false; error = 'Read-only bridge accepts GET only.' } -StatusCode 405
                continue
            }

            switch ($context.Request.Url.AbsolutePath) {
                '/mcp/ping' {
                    Send-Json -Context $context -Object @{ ok = $true; read_only = $true; pid = $TargetPid; port = $Port }
                    continue
                }
                '/mcp/observe' {
                    $process = Get-GameWindow
                    $rect = New-Object TinhLinh.ReadOnlyCapture+Rect
                    [TinhLinh.ReadOnlyCapture]::GetWindowRect($process.MainWindowHandle, [ref]$rect) | Out-Null
                    Send-Json -Context $context -Object @{
                        ok = $true
                        read_only = $true
                        pid = $process.Id
                        title = $process.MainWindowTitle
                        window = @{
                            left = $rect.Left
                            top = $rect.Top
                            width = $rect.Right - $rect.Left
                            height = $rect.Bottom - $rect.Top
                        }
                        captured_at = [DateTime]::UtcNow.ToString('o')
                    }
                    continue
                }
                '/mcp/screenshot.png' {
                    $capture = Capture-GameWindow
                    Send-Bytes -Context $context -Bytes $capture.Bytes -ContentType 'image/png'
                    continue
                }
                default {
                    Send-Json -Context $context -Object @{ ok = $false; error = 'Not found' } -StatusCode 404
                }
            }
        }
        catch {
            try {
                Send-Json -Context $context -Object @{ ok = $false; read_only = $true; error = $_.Exception.Message } -StatusCode 503
            }
            catch {}
        }
    }
}
finally {
    $listener.Stop()
    $listener.Close()
}
