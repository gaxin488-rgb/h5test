---
name: auto-git-sync
description: >-
  Tự động cam kết (commit) và đẩy (push) toàn bộ thay đổi lên GitHub sau mỗi tác vụ,
  mỗi câu hỏi có chỉnh sửa code/tài liệu, thêm/xóa/tìm kiếm/triển khai chức năng mới,
  hoặc sau khi chạy test để đảm bảo 100% tiến độ luôn được đồng bộ và lưu vết liên tục.
---

# 🚀 Continuous GitHub Sync Skill (Zero-Uncommitted Policy)

Skill này thiết lập quy trình tự động hóa cam kết (commit) và đồng bộ hóa (push) lên kho lưu trữ **GitHub (`gaxin488-rgb/h5test`)** cho mọi thay đổi trong dự án — từ những chỉnh sửa nhỏ nhất, từng câu hỏi, từng task, đến việc thêm/xóa/nghiên cứu/triển khai tính năng hay chạy test.

---

## 🎯 1. Nguyên Tắc Bắt Buộc (Core Invariants)

1. **Chính Sách Không Tồn Đọng (Zero-Uncommitted Work)**:
   - Kết thúc mỗi lượt xử lý (turn/task) có phát sinh thay đổi về mã nguồn, cấu hình, skill, hoặc tài liệu, AI **BẮT BUỘC** phải thực hiện commit và push lên GitHub ngay lập tức.
   - Tuyệt đối không để code dở dang ở trạng thái `untracked` hoặc `modified` mà không commit.

2. **Quy Chuẩn Thông Điệp Commit (Semantic / Conventional Commits)**:
   - Mỗi commit phải có thông điệp rõ ràng, đúng ngữ cảnh:
     * `feat(...)`: Thêm chức năng mới (bot, routing, packet, MCP).
     * `fix(...)`: Sửa lỗi (chống kẹt địa hình, null pointer, physics jump).
     * `refactor(...)`: Tối ưu hóa, dọn dẹp hàm mồ côi, tái cấu trúc mã nguồn.
     * `docs(...)`: Cập nhật tài liệu, mapping obfuscation, hướng dẫn.
     * `test(...)`: Bổ sung kịch bản test, kiểm chứng call-site.
     * `chore(...)`: Cập nhật skill, rules, bảo trì cấu hình hệ thống.

3. **Cơ Chế Kéo - Gộp - Đẩy An Toàn (Safe Pull-Rebase-Push)**:
   - Vì Remote VPS cũng chạy tự động và đẩy log định kỳ lên repo (`Auto-update VPS Daemon`), AI phải luôn thực hiện:
     $$\text{git add} \xrightarrow{} \text{git commit} \xrightarrow{} \text{git pull --rebase origin main} \xrightarrow{} \text{git push origin main}$$
   - Tránh xung đột (merge conflicts) và không làm gián đoạn lịch sử commit.

4. **Bảo Mật & Dung Lượng (Security & Storage Invariant)**:
   - Tuyệt đối tuân thủ `.gitignore`: Không bao giờ commit tài khoản/mật khẩu (`saved_account*.txt`), SSH config, token cá nhân hoặc các file nhị phân lớn $> 50\text{MB}$ (`TinhLinh_Lite.zip`, `TLKN-setup.exe`).

---

## 🛠️ 2. Công Cụ Hỗ Trợ (Helper Scripts)

Skill đi kèm script tự động hóa một chạm:
- `scripts/sync.ps1`: Tự động kiểm tra thay đổi, stage, commit với thông điệp tùy chọn, rebase và push lên GitHub.

### Cách sử dụng nhanh:
```powershell
# Chạy đồng bộ nhanh với thông điệp:
pwsh -File d:\tinhlinh\.agents\skills\auto-git-sync\scripts\sync.ps1 -Message "feat: cap nhat logic di chuyen"
```
