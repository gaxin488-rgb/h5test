# 🌐 Tài Liệu HTTP REST API Server (Cổng 7654)

> Máy chủ HTTP nhúng bên trong `AutoReconnect` phục vụ điều khiển bot từ xa và tích hợp hai chiều với Antigravity MCP Plugin (`tinh-linh-mcp`).

---

## 1. Cấu Hình Máy Chủ

* **Địa chỉ lắng nghe:** `http://localhost:7654`
* **Triển khai:** `com.sun.net.httpserver.HttpServer`
* **ThreadPool:** 4 luồng daemon worker (`HttpApi-Worker`)
* **Định dạng dữ liệu:** JSON (`application/json; charset=utf-8`)

---

## 2. Danh Sách Endpoint

### 1. `GET /status`
Lấy toàn bộ thông tin nhân vật và trạng thái hoạt động của bot theo thời gian thực.

* **Response Sample:**
```json
{
  "status": "online",
  "character": {
    "name": "PlayerOne",
    "level": 45,
    "hp": 2450,
    "maxHp": 2500,
    "mp": 890,
    "maxMp": 1000,
    "stamina": 85,
    "x": 142.5,
    "y": 12.0
  },
  "world": {
    "mapName": "Rừng cổ mộc",
    "mapId": 7,
    "zoneId": 3
  },
  "bot": {
    "isAutoAttack": true,
    "isReconnecting": false,
    "isHarvestingApple": false,
    "has_harvested_apple": 2,
    "apple_harvest_count_today": 2,
    "apple_harvest_cycle_handled": true,
    "auto_pickup_enabled": 5,
    "auto_pickup_count": 5,
    "total_picked_items": 5,
    "auto_pickup_active": true,
    "uptimeSeconds": 14200
  }
}
```

Trong `/status`, `apple_harvest_count_today` là số lượt thu táo thành công trong ngày, được giữ qua lần khởi động lại bot và tự reset sang ngày mới. `total_picked_items` là tổng số item đã xác nhận nhặt thành công trong phiên chạy; chỉ tăng sau khi số lượng trong túi tăng. `apple_harvest_cycle_handled` và `auto_pickup_active` mới là các cờ trạng thái boolean.

Để tương thích với bộ hiển thị cũ, `has_harvested_apple` trả số lượt thu táo hôm nay và `auto_pickup_enabled` trả tổng lượt nhặt; hai trường này không còn là boolean. Bộ hiển thị mới nên dùng `apple_harvest_count_today`, `total_picked_items` cùng hai cờ trạng thái có tên rõ nghĩa ở trên.

---

### 2. `GET /quests`
Lấy danh sách các nhiệm vụ hàng ngày và tiến độ hoàn thành.

---

### 3. `GET /bag`
Xem chi tiết các ô trong túi đồ (Hành trang), bao gồm ID vật phẩm, tên hiển thị và số lượng.

---

### 4. `GET /log?lines=N`
Đọc $N$ dòng log mới nhất được ghi từ file `autofarm_log.txt` (mặc định 50 dòng).

---

### 5. `POST /command`
Gửi lệnh trực tiếp vào hàng đợi thực thi của bot.

* **Danh sách lệnh hỗ trợ:**
  - `f6`: Kích hoạt ngay lập tức chu trình thu hoạch Cây Táo.
  - `f7`: Sử dụng ngay các vật phẩm dã ngoại và buff trong túi đồ.
  - `f8`: Nhận và đồng bộ Nhiệm Vụ Hàng Ngày.
  - `toggle_auto`: Bật/tắt nút Tự Động Đánh.
  - `return_village`: Ép buộc nhân vật gửi gói tin Về Làng ngay lập tức.
  - `change_zone <zoneId>`: Chuyển sang khu vực chỉ định (ví dụ: `change_zone 5`).
