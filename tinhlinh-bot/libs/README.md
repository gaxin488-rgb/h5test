# 📚 Standalone Libraries

> Thư viện đóng gói độc lập cho các thành phần core engine và navigation.

---

## 📦 Các Tệp Thư Viện

| Tên Tệp JAR | Kích Thước | Số Lớp | Mô Tả |
| :--- | :--- | :--- | :--- |
| `com-a-c-f-a-b-j.jar` | ~165 KB | 28 classes | Đóng gói toàn bộ package `com.a.c.f.a.b.j.*` (Bao gồm Navigator, Box2D raycasts, kinematic body controllers, contact listeners). |

---

## 💡 Hướng Dẫn Nhúng (Dependency Injection)

Trong dự án Java / Gradle / Maven hoặc script bot, bạn có thể tham chiếu trực tiếp tệp JAR này:

```groovy
dependencies {
    implementation files('libs/com-a-c-f-a-b-j.jar')
}
```
Hoặc khi biên dịch / decompile bằng CFR / Jadx:
```bash
java -jar cfr.jar libs/com-a-c-f-a-b-j.jar --outputdir decompiled_src/
```
