# Note check nền làm Hồn Thú và Tri Kỉ

Ngày check: 2026-07-06  
Yêu cầu gốc: chỉ check đủ nền để làm tính năng, không fix/sửa file.

## Đường dẫn đã check

- Client đúng:
  `D:\thantuongvosong\Onepice\OnePiece New 04 2026\Server op\pokemon\client sever khac ko tinh dungg xem\Client Server toi dang su dung\assets\res`
- Server data ban đầu:
  `D:\src game naruto Doc VIP\nonnon\180$ 7122025\AFK LEGENDS\AFK LEGENDS\erl to beam\server_core_data\data`
- Server đầy đủ hơn, có module cần dùng:
  `D:\src game naruto Doc VIP\nonnon\180$ 7122025\AFK LEGENDS\AFK LEGENDS\erl to beam\server_core_data\erl_update`

Lưu ý: user từng ghi `assets\res client`, nhưng folder đúng thực tế là `assets\res`.

## Kết luận nhanh

- Hồn thú: đủ nền để làm, nên dựa vào hệ `elfin/sprite`.
- Tri kỉ: đủ nền để làm, nhưng chưa có module riêng tên tri kỉ; nên clone/đổi từ `sprite` + tham khảo `partner_skill` hoặc `partner_artifact`.
- Skill tri kỉ ra trận và hồi mỗi 4 lượt: làm được vì battle/skill có field `cd`, `count`, `duration`, nhưng phải gắn logic vào combat, không chỉ thêm config.
- Chưa sửa gì ở lần check này.

## Hồn thú nên dựa vào đâu

Client có sẵn hệ elfin/sprite:

- `game\elfin\elfin_controller.luac`
  - Đăng ký packet `26500` đến `26564`.
  - Có hatch, summon, tree upgrade, tree step, đặt tinh linh, đội hình tinh linh.
- `game\elfin\elfin_model.luac`
  - Có dữ liệu cây tinh linh: `elfin_tree_data`.
  - Có danh sách thú đang đặt: `sprites`.
  - Có tính nguyên liệu nâng cấp/tiến cấp từ `Config.SpriteData`.
- `game\hero\view\form\form_go_fight_panel.luac`
  - Có 4 ô elfin trong giao diện đội hình.
  - Đọc `Config.SpriteData.data_elfin_data`.
  - Lấy skill từ `Config.SkillData.data_get_skill`.
- `csb\tips\elfin_tips.csb`
- `game\tips\view\elfin_tips*.luac`
- `game\tips\view\elfin_attach_skill_tips.luac`

Server có sẵn hệ sprite:

- `erl_update\sprite_rpc.erl`
- `erl_update\sprite_tree.erl`
- `erl_update\sprite_formation.erl`
- `erl_update\sprite_hatch.erl`
- `erl_update\sprite_lottery.erl`
- `erl_update\sprite_data.erl`

Các điểm quan trọng:

- `sprite_formation.erl` export:
  - `get_sprite_formation/2`
  - `save_plan/2`
  - `save_sprites/2`
  - `save_sprites_by_plan/2`
  - `sprite_tree_set_sprites/2`
  - `sprite_tree_set_sprites/3`
  - `add_pos/1`
- `sprite_tree.erl` có `set_sprite/3`, đặt thú vào ô và gọi `calc_attr`.
- Role record đã có:
  - `m_sprite_tree`
  - `m_sprite_hatch`

=> Hồn thú nếu chỉ là giao diện đẹp, 12 con spine, nút nâng cấp, thuộc tính, nguyên liệu: làm theo `elfin/sprite` là hợp nhất.

## Tri kỉ nên dựa vào đâu

Tri kỉ khác hồn thú vì có skill và phải ra trận mới có tác dụng. Nên không nên dùng y chang hồn thú nếu cần battle skill riêng.

Nền có thể dùng:

- Chọn ra trận 1-2 con:
  - Dựa theo `sprite_formation.erl`.
  - Có sẵn dạng plan/team/list để lưu thú theo đội.
- Skill học/gắn skill:
  - Dựa theo `partner_skill.erl`.
  - Partner có field `dower_skill`.
  - Packet partner đã push `dower_skill`.
- Thuộc tính/nguyên liệu/nâng cấp:
  - Dựa theo `partner_artifact.erl`.
  - Có mẫu `get_artifact_attr/1`, `get_artifact_skill/1`, nâng sao/refine và trừ nguyên liệu.
- Battle skill:
  - Dựa theo `combat_loop.erl`, `combat_lib.erl`, `combat_pk.erl`.
  - `skill_data` có field `cd`, `count`, `duration`.

## File server đáng đọc tiếp

- `erl_update\sprite_formation.erl`
  - Chọn/luu đội hình tinh linh.
  - Có `formation_sprite`, `team_sprite`, `sprite_plan`.
- `erl_update\sprite_tree.erl`
  - Nâng cấp cây, đặt tinh linh, tính thuộc tính.
- `erl_update\sprite_rpc.erl`
  - Packet tinh linh.
- `erl_update\sprite_data.erl`
  - Data tinh linh.
- `erl_update\partner_skill.erl`
  - Học skill, đổi skill, vị trí skill.
- `erl_update\partner_skill_data.erl`
  - Data skill học, giới hạn vị trí.
- `erl_update\partner_artifact.erl`
  - Mẫu item có attr + skill.
- `erl_update\combat_loop.erl`
  - Gen partner vào combat, đọc hook skills.
- `erl_update\combat_lib.erl`
  - Logic combat sâu hơn.
- `erl_update\combat_pk.erl`
  - Combat pk.
- `erl_update\skill_data.erl`
  - Data skill, effect, buff, cooldown/duration.

## File client đáng đọc tiếp

- `game\elfin\elfin_controller.luac`
- `game\elfin\elfin_model.luac`
- `game\elfin\elfin_const.luac`
- `game\elfin\elfin_event.luac`
- `game\hero\view\form\form_go_fight_panel.luac`
- `game\tips\view\elfin_attach_skill_tips.luac`
- `game\tips\view\elfin_tips.luac`
- `game\hero\view\bond_skil\bond_skill_panel.luac`
- `game\hero\view\bond_skil\bond_skill_up_window.luac`
- `game\gemstone\view\gemstone_strengthen_window.lua`
- `game\gemstone\view\gemstone_preview_skill_window.lua`
- `game\gemstone\view\gemstone_skill_tips_window.lua`
- `csb\hero\form_go_fight_panel.csb`
- `csb\tips\elfin_tips.csb`
- `csb\forgehouse\artifact_skill_window.csb`

## Gợi ý hướng làm sau này

### Hồn thú

1. Clone UI/model/controller từ `elfin`.
2. Tạo config hồn thú riêng hoặc dùng lại `SpriteData`.
3. Hiển thị 12 spine/con trong giao diện.
4. Dưới giao diện có nút nâng cấp/tiến cấp.
5. Hiển thị thuộc tính và nguyên liệu nâng cấp.
6. Nếu chỉ buff thuộc tính ngoài combat thì đi theo `sprite_tree:calc_attr`.

### Tri kỉ

1. Tạo module riêng, ví dụ `soulmate` hoặc `triki`.
2. Dữ liệu cần có:
   - id tri kỉ
   - level/star/step
   - attr
   - skill list
   - vị trí ra trận
   - cooldown skill
3. UI có danh sách tri kỉ, nâng cấp, học/gắn skill.
4. Đội hình chọn 1-2 tri kỉ ra trận, nên tham khảo `sprite_formation`.
5. Combat phải lấy tri kỉ đang ra trận rồi cộng skill vào actor/team.
6. Skill 4 lượt hồi 1 lần cần xử lý trong battle bằng `cd/count/round`, không chỉ set icon.

## Rủi ro cần nhớ

- Client hiện có `Config.SpriteData` nhưng trong `assets\res\config` không thấy file tên `sprite_data.luac`; có thể config bị gộp/ẩn ở bundle khác. Khi làm thật cần xác nhận loader config.
- Hồn thú dễ làm UI/attr, nhưng nếu muốn lưu server đầy đủ thì phải map packet/server module.
- Tri kỉ có skill battle nên bắt buộc sửa combat hoặc hook vào logic skill hiện có.
- Không nên sửa trực tiếp file `.luac` nếu không có quy trình build/decompile rõ; ưu tiên tìm source `.lua` hoặc hệ build asset.

## Chốt

Hiện tại đủ nền để làm.  
Hồn thú làm nhanh nhất bằng `elfin/sprite`.  
Tri kỉ làm được nhưng cần thêm module riêng và nối vào combat để skill chỉ có tác dụng khi ra trận, hồi theo 4 lượt.
