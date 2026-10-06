---
name: storage-capacity-guard
description: >-
  Ghi nhớ và giám sát dung lượng ổ cứng VPS & máy Local, ngăn ngừa triệt để spam file,
  tự động xoay vòng log bot game và dọn dẹp bộ nhớ đệm định kỳ để đảm bảo VPS luôn đủ dung lượng
  (>= 1.0GB - 1.5GB) hoạt động ổn định 24/7 mà không cần người dùng thao tác thủ công.
---

# 🛡️ Storage & Capacity Guard Skill (VPS & Local)

Skill này thiết lập cơ chế giám sát dung lượng ổ cứng, chống phân mảnh, ngăn chặn triệt để hành vi sinh file rác (spam files), và tự động bảo trì tài nguyên trên cả **Remote VPS** lẫn **Máy người dùng (Local)**.

---

## 🎯 1. Nguyên Tắc Cốt Lõi (Zero-Spam & Auto-Hygiene)

1. **Tuyệt đối KHÔNG spam file rác**:
   - CẤM tạo các file kiểm tra rời rạc (`test_*.py`, `temp_*.ps1`, `deploy_*.py`, `check_*.py`, `temp_*.class`) trực tiếp tại thư mục gốc của dự án hoặc trên màn hình `Desktop` của VPS.
   - Mọi script kiểm tra tạm thời nếu cần thiết phải được đặt trong thư mục scratch (`<appDataDir>/brain/<conversation-id>/scratch/` trên máy local, hoặc `$env:TEMP` trên VPS) và **phải tự động xóa ngay sau khi thực thi**.
2. **Luôn ghi nhớ và kiểm soát dung lượng VPS**:
   - Ổ cứng VPS (thường là 15GB - 20GB) rất dễ bị đầy 100% nếu không quản lý cẩn thận, dẫn đến việc Java không mở được socket kết nối mạng, Task Scheduler báo lỗi `There is not enough space on the disk`, và hệ thống tê liệt.
   - Đảm bảo dung lượng trống trên ổ `C:` của VPS luôn duy trì $\ge 1.0\text{ GB} - 1.5\text{ GB}$.
3. **Tự động hóa 100% (Không yêu cầu người dùng thủ công)**:
   - Khi phát hiện ổ đĩa sắp đầy hoặc có file rác, AI phải tự động kích hoạt tiến trình dọn dẹp, không bao giờ yêu cầu người dùng phải tự kết nối Remote Desktop hay gõ lệnh tay.
4. **Bảo vệ máy người dùng (Local PC)**:
   - Giữ cho cây thư mục dự án (`d:\tinhlinh`) luôn gọn gàng, sạch sẽ, không tích tụ các file class/b64/dump trùng lặp qua các phiên làm việc.

---

## 📊 2. Các Ngưỡng Dung Lượng VPS & Hành Động Tự Động

| Mức độ | Dung lượng trống ổ `C:` | Tình trạng | Hành động của Hệ thống |
| :--- | :--- | :--- | :--- |
| 🟢 **An toàn (Safe)** | $\ge 1.5\text{ GB}$ | Tối ưu | Tiếp tục vận hành bình thường, ghi log nhẹ. |
| 🟡 **Cảnh báo (Warning)** | $500\text{ MB} - 1.5\text{ GB}$ | Có nguy cơ đầy | Kích hoạt dọn dẹp nhẹ: xóa `%TEMP%`, `C:\Windows\Temp`, cắt tỉa log game $> 5\text{MB}$. |
| 🔴 **Khẩn cấp (Critical)** | $< 500\text{ MB}$ | Đe dọa vận hành | **Dọn dẹp khẩn cấp ngay lập tức** trước khi chạy bất kỳ tiến trình nào: xóa Windows Update cache, WER crash dumps, Recycle Bin, cắt tỉa toàn bộ file log về 2,000 dòng mới nhất. |

---

## 🧹 3. Danh Mục Các Khu Vực Tự Động Dọn Dẹp

### Trên Remote VPS:
1. **File Log Game Treo 24/7**:
   - `C:\TinhLinh\TinhLinh_Lite\Acc1\autofarm_log.txt`
   - `C:\TinhLinh\TinhLinh_Lite\Acc2\autofarm_log.txt`
   - *Quy tắc cắt tỉa*: Nếu file vượt quá $5\text{ MB}$, chỉ giữ lại $2,000$ dòng gần nhất và ghi đè lại file.
2. **Bộ Nhớ Tạm & Cache Hệ Thống**:
   - `%TEMP%` (`C:\Users\Administrator\AppData\Local\Temp\*`)
   - `C:\Windows\Temp\*`
   - `C:\Windows\SoftwareDistribution\Download\*` (cache cập nhật Windows)
   - `C:\ProgramData\Microsoft\Windows\WER\ReportQueue\*` (báo cáo lỗi crash ứng dụng)
3. **Thùng Rác & File Rác Desktop**:
   - Xóa sạch `C:\$Recycle.Bin`
   - Dọn sạch các file test cũ trong `C:\Users\Administrator\Desktop\remote-vps-mcp\temp_*`

### Trên Máy Người Dùng (Local Workspace):
1. **Dự án `d:\tinhlinh`**:
   - Thu gom và xóa sạch các file tạm: `temp_*`, `test_*`, `deploy_*`, `check_*`, `orig_*`, `.b64` thừa.
   - Giữ lại duy nhất mã nguồn chính thống, file jar gốc và các công cụ quản lý chuẩn.

---

## ⚡ 4. Quy Trình Vận Hành Chuẩn

### Bước 1: Kiểm Tra Dung Lượng Trước Khi Thao Tác
Trước khi thực hiện tác vụ trên VPS, gọi hàm kiểm tra dung lượng:
```powershell
Get-PSDrive -PSProvider FileSystem | Where-Object {$_.Name -eq "C"} | Select-Object Name, @{N="FreeGB";E={[math]::Round($_.Free/1GB, 2)}}
```
Nếu `FreeGB < 1.0`, tự động chạy script dọn dẹp trước.

### Bước 2: Kích Hoạt Tự Động Dọn Dẹp Khẩn Cấp (Emergency Auto-Clean)
Chạy script dọn dẹp tích hợp sẵn trên VPS hoặc qua lệnh từ xa:
```powershell
# 1. Don dep Temp
Get-ChildItem -Path "$env:TEMP", "C:\Windows\Temp" -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue

# 2. Xoa cache WER va SoftwareDistribution
Get-ChildItem -Path "C:\ProgramData\Microsoft\Windows\WER\ReportQueue" -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
Get-ChildItem -Path "C:\Windows\SoftwareDistribution\Download" -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue

# 3. Zoa Thung Rac
Clear-RecycleBin -Force -ErrorAction SilentlyContinue

# 4. Cat tia log game bot neu > 5MB
$log1 = "C:\TinhLinh\TinhLinh_Lite\Acc1\autofarm_log.txt"
$log2 = "C:\TinhLinh\TinhLinh_Lite\Acc2\autofarm_log.txt"
foreach ($f in @($log1, $log2)) {
    if (Test-Path $f) {
        $sizeMB = (Get-Item $f).Length / 1MB
        if ($sizeMB -gt 5) {
            $tail = Get-Content $f -Tail 2000
            Set-Content -Path $f -Value $tail -Force
        }
    }
}
```

### Bước 3: Đảm Bảo MCP Daemon Giám Sát Dung Lượng Định Kỳ
Trên VPS, daemon nền `MCP_Daemon.ps1` có vòng lặp chạy mỗi 300 giây:
- Tự động đo dung lượng ổ C:.
- Nếu $< 500\text{MB}$, tự kích hoạt khối dọn rác và xoay vòng log.
- Gửi thông số dung lượng về hệ thống giám sát.
