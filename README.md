# 🌟 Tinh Linh Game Client (Bản Gốc - Baseline)

> **Dự án Game Tinh Linh Khởi Nguyên — Phiên bản cơ sở chuẩn (Baseline - Không chức năng auto)**

Dự án được khởi tạo lại từ đầu với nền tảng là client game nguyên bản được trích xuất từ bộ cài đặt gốc (`TLKN-setup.exe`), loại bỏ hoàn toàn các mã can thiệp/auto cũ để phục vụ việc kiểm thử nền tảng và từng bước xây dựng các mô-đun mới từ con số 0.

---

## 📁 Cấu Trúc Dự Án

```
d:\tinhlinh\
├── TinhLinh.jar         # Tệp JAR game gốc đầy đủ (LibGDX + LWJGL3 + KryoNet + Box2D)
├── run-game.cmd         # Script khởi chạy game gốc với Java 17+
├── vps_agent.ps1        # Agent điều khiển và giám sát VPS từ xa
├── vps_install.ps1      # Script cài đặt hệ điều hành và môi trường 24/7 trên VPS
├── vps_tunnel_url.txt   # Đường dẫn Cloudflare Tunnel đồng bộ thời gian thực
└── AGENTS.md            # Quy chuẩn vận hành và nguyên tắc an toàn cho Antigravity AI
```

---

## 🚀 Hướng Dẫn Khởi Chạy

### Yêu cầu môi trường:
- Java Runtime Environment (JRE) hoặc JDK 17 trở lên (64-bit).

### Khởi chạy:
- Nhấp đúp vào `run-game.cmd` hoặc chạy qua dòng lệnh:
```cmd
java -Xms32m -Xmx256m -Dfile.encoding=UTF-8 -jar TinhLinh.jar
```
