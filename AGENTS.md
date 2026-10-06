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

1. **Strict Zero-Spam Policy**:
   - Absolutely NEVER create throwaway test scripts (`test_*.py`, `temp_*.ps1`, `deploy_*.py`, `check_*.py`, `temp_*.class`) directly in the workspace root (`d:\tinhlinh`) or on the Remote VPS desktop (`C:\Users\Administrator\Desktop`).
   - If a temporary script is strictly required, place it in the system scratch directory (`<appDataDir>/brain/<conversation-id>/scratch/` or `$env:TEMP` on VPS) and delete it immediately after execution.
   - Do NOT save duplicate binary dumps, zip files, or installers across sessions.

2. **VPS Capacity Retention & Auto-Hygiene (15GB Disk)**:
   - Always remember that the Remote VPS has a constrained 15GB disk.
   - Maintain minimum free disk space on VPS drive C: >= 1.0GB - 1.5GB.
   - If free space drops below 1.0GB, trigger automatic garbage collection:
     * Purge `%TEMP%` and `C:\Windows\Temp`
     * Purge `C:\Windows\SoftwareDistribution\Download`
     * Purge `C:\ProgramData\Microsoft\Windows\WER\ReportQueue`
     * Empty `C:\$Recycle.Bin`
     * Rotate bot logs: If `autofarm_log.txt` > 5MB, keep only the latest 2,000 lines.
   - Never allow Java socket/SSL allocation or Windows Task Scheduler to fail due to disk exhaustion.

3. **User Machine (Local PC) Disk Hygiene**:
   - Keep the workspace `d:\tinhlinh` and local drives clean and uncluttered.
   - Periodically remove abandoned temporary artifacts and logs.

4. **100% Autonomous Operation**:
   - Never ask the user to manually delete files, check free space via RDP, or run maintenance commands. Handle all storage management and recoveries automatically.

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

