# 🌟 Tinh Linh Game Bot & AutoReconnect System

> **Hệ thống Tự Động Hoá Toàn Diện & Phục Hồi Kết Nối Cho Game Tinh Linh (LibGDX + KryoNet)**

Hệ thống bot được thiết kế dưới dạng **In-Memory Java Bytecode Patch**, can thiệp trực tiếp vào runtime engine của game Tinh Linh (nền tảng LibGDX & KryoNet socket). Bot cung cấp khả năng tự động chơi 24/7, tự kết nối lại khi mất mạng, giải kẹt địa hình thông minh qua Box2D physics, thu hoạch nông trại, bắt pet Thỏ Ngọc và tích hợp REST API server để kết nối với Antigravity MCP.

---

## 📑 Mục Lục Tài Liệu Chi Tiết

| Tài liệu | Mô tả nội dung |
| :--- | :--- |
| 🔄 **[Vòng Lặp Chính (Loop Lifecycle)](docs/LOOP_LIFECYCLE.md)** | **Phân tích chi tiết hàm loop `AutoFarm-Watcher`, chu kỳ 800ms, toàn bộ điều kiện rẽ nhánh và luồng thực thi.** |
| 🏛️ **[Kiến Trúc Kỹ Thuật (Architecture)](docs/ARCHITECTURE.md)** | Mô hình đa luồng, cơ chế can thiệp bytecode, hook LibGDX Scene2D và KryoNet. |
| 🔌 **[Auto Reconnect (Tự Động Kết Nối)](docs/AUTO_RECONNECT.md)** | Cơ chế bắt sự kiện đứt kết nối socket, lưu trữ thông tin đăng nhập, retry với backoff. |
| 🗺️ **[Định Tuyến & Chống Kẹt (Navigation & Anti-Stuck)](docs/NAVIGATION_AND_ANTI_STUCK.md)** | Đồ thị chuyển map tự động, thuật toán giải kẹt 3 cấp (Box2D Jump, Phase Step, Recall). |
| 🌐 **[Embedded REST API Server](docs/HTTP_API_SERVER.md)** | Tài liệu HTTP API port `7654` phục vụ Antigravity MCP (`/status`, `/quests`, `/bag`, `/command`). |
| ⚙️ **[Hướng Dẫn Tính Năng & Cấu Hình](docs/FEATURES_GUIDE.md)** | Cấu hình Auto Cây Táo, Thỏ Ngọc, Thể Lực, Potion máu/mana, Đổi khu vực và Hotkeys. |
| 💻 **[Mã Nguồn Java (Source Code)](src/com/a/d/AutoReconnect.java)** | Toàn bộ mã nguồn Java hoàn chỉnh (~6.000 dòng) nằm tại `src/com/a/d/AutoReconnect.java`. |

---

## 🎯 Tính Năng Nổi Bật

```mermaid
graph TD
    A["🎮 Game Client (LibGDX Runtime)"] --> B["🔌 AutoReconnect Core"]
    B --> C["⏱️ AutoFarm-Watcher (Chu kỳ 800ms)"]
    
    C --> D1["🔄 Auto Reconnect & Auto Login"]
    C --> D2["🍏 Thu Hoạch Cây Táo Nông Trại"]
    C --> D3["⚔️ Auto Farm & Tự Bật/Tắt Đánh"]
    C --> D4["🐇 Bắt Thỏ Ngọc & Nhặt Item Dã Ngoại"]
    C --> D5["🧗 Chống Kẹt 3 Cấp (Box2D Jump / Phase Step / Recall)"]
    C --> D6["🗺️ Định Tuyến Chuyển Map Tự Động"]
    C --> D7["🔄 Tự Đổi Khu Vực (Zone Rotation 40s)"]
    C --> D8["🧪 Tự Bơm HP / MP & Hồi Thể Lực (Đùi Gà)"]

    B --> E["🌐 Embedded HTTP Server (Port 7654)"]
    E --> F["🤖 Antigravity MCP Plugin (tinh-linh-mcp)"]
```

1. **Auto Reconnect & Auto Login Tuyệt Đối**:
   - Lắng nghe sự kiện đứt socket từ KryoNet.
   - Tự động kết nối lại TCP socket và gửi gói tin đăng nhập từ tài khoản lưu trong `saved_account.txt`.
   - Có cơ chế cờ điều khiển: `bat_auto_login.txt` (bật) và `tat_auto_login.txt` (tắt).

2. **Vòng Lặp Giám Sát Thông Minh (`AutoFarm-Watcher`)**:
   - Chạy trên một Daemon Thread độc lập với chu kỳ **800ms**, không làm gián đoạn luồng render đồ hoạ chính của LibGDX.
   - Xem chi tiết tại [docs/LOOP_LIFECYCLE.md](docs/LOOP_LIFECYCLE.md).

3. **Cơ Chế Giải Kẹt Địa Hình 3 Cấp Độ (Tri-Stage Anti-Stuck)**:
   - **Cấp 1 - Box2D Jump**: Tự động tính toán hướng và áp dụng xung lực vật lý (`applyLinearImpulse`) để nhân vật nhảy qua bậc đá hoặc chướng ngại vật (thử tối đa 3 lần).
   - **Cấp 2 - Phase Step**: Nếu vẫn kẹt tại cùng toạ độ sau 3 lần nhảy, kích hoạt xung lực gia tốc cực mạnh ($15	ext{ m/s}$) hướng về phía mục tiêu.
   - **Cấp 3 - Emergency Recall**: Nếu kẹt quá số chu kỳ cho phép hoặc timeout 6 phút, tự động gửi gói tin Về Làng an toàn để reset hoàn toàn lộ trình.

4. **Thu Hoạch Nông Trại & Bắt Thỏ Ngọc**:
   - Chu kỳ 6 phút tự về làng, bước vào cổng Nông Trại, mở giao diện Cây Táo và thu hoạch trái chín.
   - Tự động phát hiện NPC Thỏ Ngọc trên bản đồ, kiểm tra củ Cà Rốt trong túi và tiếp cận ném bắt.
   - Tự động nhặt các vật phẩm dã ngoại rơi trên đất.

5. **REST API Server Nhúng (Port 7654)**:
   - Cho phép điều khiển bot từ xa qua HTTP mà không cần giao diện đồ hoạ.
   - Hỗ trợ đầy đủ các endpoint: `/status`, `/quests`, `/bag`, `/log`, `/command`.

---

## 📂 Cấu Trúc Thư Mục

```text
tinhlinh-bot/
├── README.md                          # Trang chủ tổng quan dự án
├── docs/                              # Toàn bộ tài liệu kỹ thuật chuyên sâu
│   ├── ARCHITECTURE.md                # Kiến trúc hệ thống, threading & bytecode hook
│   ├── LOOP_LIFECYCLE.md              # Phân tích chi tiết vòng lặp chính (Hàm Loop)
│   ├── AUTO_RECONNECT.md              # Cơ chế tự động kết nối lại và đăng nhập
│   ├── NAVIGATION_AND_ANTI_STUCK.md   # Định tuyến Waypoint & Giải kẹt 3 cấp
│   ├── HTTP_API_SERVER.md             # Tài liệu REST API cổng 7654 (MCP integration)
│   └── FEATURES_GUIDE.md              # Hướng dẫn cấu hình toàn bộ tính năng bot
└── src/                               # Mã nguồn Java
    └── com/
        └── a/
            └── d/
                ├── AutoReconnect.java # Toàn bộ mã nguồn Java hoàn chỉnh (~6.000 dòng)
                └── README.md          # Hướng dẫn biên dịch và đóng gói
```
