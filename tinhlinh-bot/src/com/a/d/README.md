# 💻 Mã Nguồn Java: `com.a.d.AutoReconnect`

Thư mục này chứa file mã nguồn trung tâm của bot game Tinh Linh:

* **[AutoReconnect.java](AutoReconnect.java)**: Toàn bộ lớp điều khiển cốt lõi (~6.000 dòng code).

### Các module được hợp nhất bên trong `AutoReconnect.java`:
1. `AutoReconnect` Core & KryoNet Packet Listener.
2. `AutoFarm-Watcher` Daemon Loop (800ms).
3. Embedded `HttpServer` (Port 7654) cho Antigravity MCP.
4. Box2D Physical Jump Engine & Tri-Stage Anti-Stuck.
5. Rabbit Catcher & Wild Item Pickup Manager.
6. Apple Farm Automation System.
7. Hotkey Listener (F6, F7, F8).
8. Waypoint & Route Graph Pathfinding Engine.
