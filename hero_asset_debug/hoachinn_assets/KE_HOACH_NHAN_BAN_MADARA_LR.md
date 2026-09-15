# Kế hoạch nhân bản Madara LR

## Mục tiêu

Tạo thêm một Madara LR mới có:

- BID riêng.
- Hệ `camp_type` khác.
- Model, icon và ngoại hình riêng.
- Card triệu hồi và mảnh ghép riêng.
- Dùng chung toàn bộ skill family `727xxx` với Madara LR hiện tại.

Không nhân bản skill sang family mới nếu gameplay cần giống Madara LR 100%.

## Đường dẫn đang sử dụng

### Server

```text
D:\src game naruto Doc VIP\nonnon\180$ 7122025\AFK LEGENDS\AFK LEGENDS\erl to beam\server_core_data\data
```

### Client hiện tại

```text
D:\thantuongvosong\Onepice\OnePiece New 04 2026\Server op\pokemon\client sever khac ko tinh dungg xem\Client Server toi dang su dung\assets\res\config
```

Lưu ý: đây là client hiện tại, không phải thư mục `assets - Copy` đã dùng khi kiểm tra trước.

## Madara LR gốc

| Thành phần | Giá trị |
|---|---:|
| Hero BID | `60927` |
| Model | `H60927` |
| Hệ | `camp_type = 5` |
| Card | `528419` |
| Mảnh | `1528419` |
| Skill family | `727xxx` |
| Skill order | `[72710,72730,72710,72700]` |

Skill chính ở 5 sao:

```text
727001 - đánh thường
727101 - active skill 1
727201 - passive
727301 - active skill 3
727401... - passive và skill bổ sung
```

## Mẫu nhân bản đã có: Boruto

Server và client đang có cặp:

| Thành phần | Boruto 1 | Boruto 2 |
|---|---:|---:|
| BID | `60925` | `61925` |
| Hệ | `5` | `4` |
| Model | `H60925` | `H61925` |
| Card | `528417` | `528427` |
| Mảnh | `1528417` | `1528427` |
| Skill | `726xxx` | `726xxx` |

Hai BID có model, hệ và mảnh riêng nhưng dùng chung toàn bộ skill `726xxx`. Đây là mẫu cần áp dụng cho Madara LR.

## Đề xuất Madara LR mới

| Thành phần | Giá trị dự kiến |
|---|---:|
| Hero BID | `61927` |
| Model | `H61927` hoặc model khác được chọn |
| Hệ | `camp_type = 4` |
| Card | ID mới, chưa chốt |
| Mảnh | ID mới, chưa chốt |
| Skill family | giữ nguyên `727xxx` |
| Skill order | giữ nguyên `[72710,72730,72710,72700]` |

`61927` hiện chưa có hero base trong server/client hiện tại. Tuy nhiên client cũng chưa có resource/model `H61927`, nên phải chọn hoặc bổ sung model trước khi hoàn thiện.

## Phần server cần nhân bản

File chính:

```text
server_core_data\data\partner_data.erl
```

Nhân bản dữ liệu của `60927` sang BID mới:

1. Thêm BID vào danh sách hero.
2. `get_base`: đổi BID, tên, `camp_type`, `item_id`.
3. `get_attr` và `get_lev_attr`.
4. `get_stars_by_bid`.
5. `get_star_attr` cho sao `5..200`.
6. `get_skills` cho sao `5..200`, nhưng giữ nguyên ID `727xxx`.
7. `get_skill_order` cho sao `5..200`, giữ `[72710,72730,72710,72700]`.
8. `get_star_max_lev`.
9. `get_star_expend` và nguyên liệu nâng sao phải trỏ BID/mảnh mới khi cần.
10. `get_star_other_expend`.
11. `get_star_group_attr`.
12. Mapping item, vị trí, giới hạn crystal và các bảng tra cứu phụ.

File item server:

```text
server_core_data\data\item_data.erl
```

Tạo:

- Card triệu hồi riêng, effect trả về `{NewBid, 5, 1}`.
- Mảnh riêng, effect ghép/trả về `NewBid`.
- Mapping ghép mảnh và random list nếu cần mở từ rương/sự kiện.

## Phần client cần nhân bản

### `partner_data.luac`

Nhân bản toàn bộ dữ liệu `60927` sang BID mới:

- Base hero.
- Thuộc tính cơ bản.
- Toàn bộ 196 record sao `5..200`.
- Giữ danh sách skill `727xxx` ở từng mốc sao.
- Đổi model key từ `H60927` sang model mới.
- Đổi icon, head icon, draw resource và các lookup BID.

### `item_data6.luac`

Tạo card và mảnh riêng:

- Card trỏ tới BID mới.
- Mảnh trỏ tới BID mới.
- Tên, mô tả, icon và quality đúng với hệ mới.

### `skill_data1.luac`

Không cần copy skill nếu dùng chung gameplay `727xxx`.

Chỉ kiểm tra model mới có tương thích với animation/VFX của `727`.

## Yêu cầu asset/model

Skill `727xxx` gọi các animation:

```text
action1
action2
action3
action4
```

Model mới phải có đủ các action tương ứng. Nếu thiếu:

- Server vẫn có thể tung đúng skill.
- Client có thể đứng hình, phát sai animation hoặc không hiện chiêu.

Skill dùng chung cũng giữ VFX, âm thanh và buff của Madara LR. Nếu muốn ngoại hình skill khác hoàn toàn thì phải tạo family skill mới thay vì dùng chung `727xxx`.

## Quy tắc quan trọng

- Hero BID mới khác `60927`.
- Card và mảnh phải có ID mới, không dùng lại `528419/1528419`.
- `get_skills` của hero mới vẫn trỏ `727xxx`.
- `get_skill_order` phải dùng group `727xx`, không đổi theo BID hero mới.
- Không thay các record skill `727` nếu Madara LR cũ vẫn cần giữ nguyên.
- Kiểm tra khả năng cho hai Madara ra trận cùng lúc; nếu không muốn, cần thêm quy tắc cùng series/loại trừ.

## Checklist thực hiện

- [ ] Chốt BID mới.
- [ ] Chốt hệ mới.
- [ ] Chốt model và xác nhận đủ `action1..action4`.
- [ ] Chốt ID card và ID mảnh.
- [ ] Backup server/client trước khi sửa.
- [ ] Nhân bản server `partner_data`.
- [ ] Tạo card/mảnh trong server `item_data`.
- [ ] Nhân bản client `partner_data`.
- [ ] Tạo card/mảnh client `item_data6`.
- [ ] Compile `partner_data.beam` và `item_data.beam`.
- [ ] Kiểm tra client load config không lỗi.
- [ ] Test nhận tướng bằng card/mảnh.
- [ ] Test đội hình, nâng sao và skill order.
- [ ] Test animation skill ở 5 sao và sao cao.
- [ ] So sánh damage/buff với Madara LR gốc.

## Kết quả mong đợi

Hai Madara là hai hero độc lập về BID, hệ, model và vật phẩm, nhưng server chọn cùng bộ skill `727xxx` và sức mạnh/logic skill giống nhau, tương tự cặp Boruto `60925/61925`.
