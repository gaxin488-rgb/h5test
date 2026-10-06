---
name: code-integrity-guard
description: >-
  Ngăn chặn triệt để code rỗng, code chết, scaffolding/stub placeholder, các hàm mồ côi
  không bao giờ được gọi, và bắt buộc trace luồng thực thi end-to-end (đặc biệt là luồng di chuyển,
  vật lý Box2D, network socket và callback) trước khi kết luận hoàn thành tác vụ.
---

# 🛡️ Code Integrity & Execution Guard Skill

Skill này thiết lập quy trình kiểm soát chất lượng mã nguồn nghiêm ngặt, ngăn chặn triệt để các lỗi cố hữu của AI: **viết code rỗng (scaffolding/stubs), sinh hàm mồ côi không bao giờ được gọi (dead code/uncalled functions), tài liệu ảo (ghost docs), và đứt gãy luồng thực thi (broken execution chain)**.

---

## 🎯 1. Bốn Nguyên Tắc Bất Di Bất Dịch (Core Invariants)

### 1.1. Zero-Scaffolding & No-Stub Invariant (Cấm Code Rỗng & Giả Lập)
1. **Cấm tuyệt đối dummy return**: Không được tạo method chỉ chứa `return true;`, `return null;`, `return 0;`, `pass`, hoặc comment `// TODO: implement later` để đối phó nếu không phải là `interface` hoặc `abstract class`.
2. **Triển khai hoàn chỉnh hoặc không viết**: Mọi hàm được tạo mới phải chứa logic xử lý thực tế, thao tác đúng cấu trúc dữ liệu và API thật của engine (LibGDX, Box2D, KryoNet, v.v.).
3. **Cấm Ghost Documentation**: Không được tạo tài liệu Markdown mô tả các class, file hoặc API chưa từng được hiện thực hóa trong mã nguồn.

### 1.2. Mandatory Call-Site Wiring (Chống Hàm Mồ Côi & Code Chết)
1. **Không tạo "ốc đảo cô lập" (No Island Code)**: Bất kỳ function/method mới nào được sinh ra **BẮT BUỘC phải được kết nối (hook/wire)** trực tiếp vào ít nhất một vị trí gọi hàm (Call-Site) đang hoạt động trong vòng đời ứng dụng.
2. **Xác định Call-Site trước khi viết hàm**:
   - Hàm này sẽ được gọi từ đâu?
   - Trong game loop tick (`act(float delta)` / `render()`)?
   - Trong KryoNet Packet Listener khi server gửi gói tin về?
   - Hay trong State Machine / Task Dispatcher của bot?
3. **Kiểm tra đồng thời**: Khi thêm hàm mới ở Module A, phải đồng thời chỉnh sửa Call-Site ở Module B để gọi hàm đó. Nếu không có Call-Site thực tế, hàm đó được coi là **Dead Code**.

### 1.3. End-to-End Execution Trace Protocol (Trace Luồng Khép Kín)
Đặc biệt đối với các luồng nghiệp vụ phức tạp như **Di chuyển (Movement), Chiến đấu (Combat), hoặc Kết nối mạng (Network Reconnect)**, AI bắt buộc phải trace và kiểm chứng đủ **4 chặng liên tục**:

```
[Chặng 1: Trigger / Decision] 
       │ (Ai ra lệnh? Điều kiện là gì?)
       ▼
[Chặng 2: Calculation & State Setup]
       │ (Tọa độ đích, raycast dò địa hình, thiết lập cờ isMoving)
       ▼
[Chặng 3: Actuator / Physical Execution]
       │ (Áp dụng Box2D Impulse/Velocity, gửi packet socket lên server)
       ▼
[Chặng 4: Callback & Completion Handshake]
         (Báo đến đích, giải phóng trạng thái, xử lý Timeout / Anti-Stuck)
```

- **Lưu ý chí mạng trong Game Engine (Box2D/LibGDX)**:
  - Nếu engine ghi đè vận tốc nhân vật mỗi frame trong `act(delta)`, thì việc gọi `applyLinearImpulse()` một lần ở ngoài luồng sẽ bị reset ngay lập tức ở frame kế tiếp. Luồng vật lý phải can thiệp đúng vòng lặp cập nhật vận tốc hoặc duy trì liên tục qua từng tick.

### 1.4. Pre-Done Reachability Verification (Tự Kiểm Chứng Trước Khi Báo Xong)
Trước khi kết luận một tác vụ là hoàn thành, AI bắt buộc phải:
1. Grep kiểm tra tên hàm mới tạo để chỉ ra chính xác File + Dòng của Call-Site đang gọi nó.
2. Kiểm tra xem luồng điều khiển có đi qua hàm đó trong điều kiện runtime thực tế hay không.

---

## 📋 2. Checklist Tự Kiểm Tra (Self-Audit Checklist)

Mỗi khi chỉnh sửa hoặc thêm mới tính năng, AI phải tự trả lời 5 câu hỏi sau:

- [ ] **1. Hàm này có thân hàm thực tế không?** (Có xử lý logic thật hay chỉ là scaffolding/stub return?)
- [ ] **2. Ai đang gọi hàm này?** (Chỉ rõ file và dòng chứa call-site).
- [ ] **3. Luồng dữ liệu đi đến đâu?** (Có thực sự thay đổi trạng thái game/tọa độ nhân vật/gói tin mạng không?)
- [ ] **4. Điểm kết thúc ở đâu?** (Có callback, timeout, hoặc cơ chế dừng khi xong việc/bị kẹt không?)
- [ ] **5. Có tạo file rác hay tài liệu ảo không?** (Mọi file được liệt kê trong docs đều phải tồn tại thật trên ổ đĩa).

---

## 🛠️ 3. Công Cụ Hỗ Trợ (Helper Scripts)

Skill này đi kèm công cụ audit tĩnh:
- `scripts/audit_call_sites.py`: Quét mã nguồn Java/Python để phát hiện các hàm không có call-site nào gọi tới (Dead Code Hunter).
