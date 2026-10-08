# Antigravity Rules & Tool Guide for LDPlayer 9 Automation

When the user asks to inspect, view, or interact with LDPlayer 9 / Android emulator (`emulator-5556`):
1. **Never ask the user to take a manual screenshot.**
   - Antigravity can directly view the screen using `ldplayer_see_screen` (or `adb exec-out screencap -p`).
2. **For Native Android UI / Apps:**
   - Use `ldplayer_get_ui_tree` or `ldplayer_tap_element_by_text` to find buttons and text with 100% precision.
3. **For Unity/Cocos/Unreal Games:**
   - Use `ldplayer_find_and_tap` / `ldplayer_find_template` with a cropped button template for pixel-perfect OpenCV matching.
   - Alternatively, tap using normalized percentage coordinates via `ldplayer_tap_percent(x_pct, y_pct)` or internal resolution (1280x720).

# Antigravity Rules for Storage & Capacity Guard (VPS & Local PC)

1. **Micro-VPS (15GB Disk) Hardware Reality & Invariants**:
   - Ổ cứng VPS chỉ có **15GB tổng dung lượng**. Bản cài Windows Server 2012 R2 nguyên bản đã chiếm 9GB - 11GB, biên độ an toàn thực tế chỉ có **~3GB - 4GB**.
   - Mọi megabyte trên ổ `C:` đều là tài nguyên sống còn. Tình trạng cạn kiệt đĩa (0 MB) sẽ lập tức bẻ gãy việc cấp phát Socket/SSL, làm sập Windows Task Scheduler, ngắt Cloudflare Tunnel và treo bot game.
   - Antigravity BẮT BUỘC phải chủ động phòng vệ từ cấp độ Hệ Điều Hành (OS) đến cấp độ Runtime ứng dụng.

2. **Mandatory Day-Zero OS Hardening (Thiết lập bất biến khi Reinstall VPS)**:
   - **Tắt Hibernation hoàn toàn (`powercfg /h off`)**: Thu hồi ngay lập tức 1GB - 2GB file ẩn `hiberfil.sys`.
   - **Cố định Pagefile (`pagefile.sys`)**: Cấm tuyệt đối để pagefile tự động co giãn lên 4GB - 8GB. Phải ghim cố định InitialSize = 512MB, MaximumSize = 1024MB trên ổ `C:`.
   - **Vô hiệu hóa Windows Update ngầm (`wuauserv` disabled)**: Ngăn chặn triệt để việc Windows âm thầm tải hàng GB bản vá vào `C:\Windows\SoftwareDistribution\Download`.
   - **Vô hiệu hóa Windows Error Reporting Crash Dumps**: Tắt crash dump trong Registry (`HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting\Disabled = 1`, `DumpCount = 0`). Chống hiện tượng tiến trình crash vòng lặp sinh hàng loạt file dump 100MB làm tràn đĩa chỉ trong 15-30 phút.
   - **Giới hạn & Xóa Volume Shadow Copies (VSS)**: Khống chế tối đa 400MB và xóa snapshot cũ (`vssadmin resize shadowstorage /for=c: /on=c: /maxsize=400mb` & `vssadmin delete shadows /all /quiet`).

3. **Strict Single-Runtime Policy (Chống phân mảnh & Zero-Spam trên VPS)**:
   - Toàn bộ runtime điều khiển VPS được chuẩn hóa duy nhất tại: `C:\TinhLinh`.
   - CẤM phân tán các script rải rác ngoài Desktop hoặc sinh nhiều file batch/powershell thừa thãi, chồng chéo (`auto_mcp.ps1`, `MCP_Daemon.ps1`, `Chay_Agent.bat`, `Khoi_Dong_*.bat`,...).
   - Chỉ duy nhất 1 Agent (`vps_agent.ps1`) quản lý HTTP server, Tunnel (`cloudflared.exe`) và bộ dọn dẹp Storage Guard.
   - CẤM tạo các file test tạm bợ trên VPS Desktop hoặc thư mục gốc `d:\tinhlinh`. Mọi thao tác tạm phải nằm trong `$env:TEMP` và xóa ngay sau khi chạy.

4. **3-Tier Dynamic Storage Defense (Cơ chế phòng vệ 3 cấp độ tự động 24/7)**:
   - **Tier 1 (Thường nhật - Mỗi 60 giây)**:
     * Không tạo file log runtime (`service.log`, `agent.log`, `cloudflared.log`); chỉ cắt tỉa log bot game nếu game sinh ra.
     * Cắt tỉa log bot game (`autofarm_log.txt`) nếu $> 3\text{MB}$, chỉ giữ lại tối đa 1.500 dòng mới nhất.
     * Quét và dọn sạch `%TEMP%`, `C:\Windows\Temp`, `%LOCALAPPDATA%\CrashDumps`, và WER report queue.
   - **Tier 2 (Cảnh báo - Dung lượng trống $< 1.5\text{GB}$)**:
     * Xóa sạch `C:\Windows\SoftwareDistribution\Download`.
     * Xóa toàn bộ nhật ký CBS/DISM: `C:\Windows\Logs\CBS\*.log`, `C:\Windows\Logs\DISM\*.log`.
     * Làm rỗng Thùng rác: `Clear-RecycleBin -Force`.
   - **Tier 3 (Nguy cấp - Dung lượng trống $< 800\text{MB}$)**:
     * Cưỡng chế xóa toàn bộ Volume Shadow snapshots (`vssadmin delete shadows /all /quiet`).
     * Gọi garbage collection thu hồi RAM & bộ nhớ đệm.

5. **Continuous Telemetry & 100% Autonomous Operation**:
   - Trạng thái dung lượng trống ổ đĩa (`disk_free_gb`) phải được đồng bộ liên tục trong heartbeat (`vps_mcp_status.json`) và API `/health`.
   - Tuyệt đối không bao giờ yêu cầu người dùng phải tự mở RDP kiểm tra ổ đĩa hay dọn dẹp thủ công. Mọi quy trình duy trì dung lượng phải tự vận hành 100%.

6. **User Machine (Local PC) Disk Hygiene**:
   - Giữ cây thư mục `d:\tinhlinh` tinh gọn, không để sót các file dump, zip thừa hay log tạm không cần thiết.

# Antigravity Rules for Code Integrity & Execution Guard (Zero-Scaffolding & Flow Tracing)

1. **Zero-Scaffolding & No-Stub Invariant**:
   - Cấm tuyệt đối sinh code rỗng, dummy return (`return true;`, `return null;`, `return 0;`), hoặc placeholder comment (`// TODO`, `// implement later`).
   - Cấm viết tài liệu ảo (ghost documentation) mô tả các class, file, hoặc API chưa từng được hiện thực hóa trong mã nguồn.

2. **Mandatory Call-Site Reachability (Chống Dead Code / Hàm Mồ Côi)**:
   - Bất kỳ hàm/method mới nào được tạo ra BẮT BUỘC phải được kết nối (hook/wire) trực tiếp vào ít nhất 1 Call-Site đang hoạt động (Game Loop tick `act(delta)`, Event Listener, Packet Handler, State Machine).
   - Cấm tạo các hàm "ốc đảo cô lập" (viết để đó nhưng không ai gọi).

3. **End-to-End Execution Trace Protocol (Trace Luồng Khép Kín)**:
   - Với mọi tính năng liên quan đến Di chuyển (Movement), Vật lý Box2D, hoặc Mạng Socket, phải trace đủ 4 chặng:
     * **Chặng 1 (Trigger)**: Điều kiện và tác nhân khởi xướng lệnh.
     * **Chặng 2 (Calculation)**: Tọa độ, raycast, target setting.
     * **Chặng 3 (Actuator / Physics)**: Áp dụng lực vật lý (`setLinearVelocity`, `applyLinearImpulse`) hoặc gửi packet socket thật sự. Lưu ý: Nếu game loop ghi đè vận tốc mỗi frame, xung lực một lần sẽ bị mất — phải can thiệp đúng nhịp tick!
     * **Chặng 4 (Callback & Completion)**: Kiểm tra đến đích (`arrivalCallback`), giải phóng cờ `isMoving`, và cơ chế Anti-Stuck khi kẹt.

4. **Kiểm Chứng Trước Khi Hoàn Thành (Pre-Done Reachability Audit)**:
   - Luôn chỉ ra chính xác File + Dòng của Call-Site đang gọi hàm mới trước khi thông báo hoàn thành nhiệm vụ.

# Antigravity Rules for Continuous GitHub Sync (Zero-Uncommitted Policy)

1. **Mandatory Continuous Sync (Cam kết & Đẩy lên GitHub tức thời)**:
   - Mọi thay đổi dù nhỏ nhặt nhất, từng task, từng câu hỏi có phát sinh chỉnh sửa code/tài liệu, thêm chức năng mới, xóa chức năng cũ, khảo sát/tìm kiếm, triển khai hay chạy test... **BẮT BUỘC phải được commit và push lên GitHub ngay lập tức** trước khi kết thúc lượt xử lý.
   - Tuyệt đối không để lại trạng thái uncommitted/dirty working tree sau mỗi yêu cầu của người dùng.

2. **Safe Pull-Rebase Workflow (Chống xung đột với VPS)**:
   - Do Remote VPS cũng tự động đồng bộ log/tunnel lên GitHub, quy trình chuẩn luôn là:
     * `git add -A`
     * `git commit -m "<semantic message>"`
     * `git pull --rebase origin main`
     * `git push origin main`
   - Hoặc chạy script một chạm: `pwsh -File d:\tinhlinh\.agents\skills\auto-git-sync\scripts\sync.ps1 -Message "..."`.

3. **Semantic Commit Messages (Chuẩn Conventional Commits)**:
   - Sử dụng tiền tố rõ ràng: `feat:` (tính năng mới), `fix:` (sửa lỗi), `docs:` (tài liệu), `refactor:` (tối ưu/dọn dead code), `test:` (kiểm thử), `chore:` (kỹ thuật/sync).

4. **Bảo Mật & Bộ Lọc File Lớn (Security & Large File Invariant)**:
   - Tuyệt đối tuân thủ `.gitignore`: Không bao giờ commit tài khoản/mật khẩu (`saved_account*.txt`), SSH config, token cá nhân hoặc các file nhị phân lớn $> 50\text{MB}$ (`TinhLinh_Lite.zip`, `TLKN-setup.exe`).

