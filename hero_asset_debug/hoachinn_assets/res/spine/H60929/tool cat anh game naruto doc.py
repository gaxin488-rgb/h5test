import os
from PIL import Image

# ---------------------- PARSER (đa trang) ----------------------
def parse_atlas_multi(path):
    """
    Đọc file .atlas (Spine/LibGDX) có thể gồm N trang.
    Trả về: list[ { 'page': 'xxx.png', 'frames': [ ... ] } ]
    """
    pages = []
    with open(path, "r", encoding="utf-8", errors="ignore") as f:
        lines = [ln.rstrip("\n") for ln in f if ln.strip()]

    cur_page = None
    cur_frame = None
    in_page_header = False

    def start_new_page(png_name: str):
        nonlocal cur_page, in_page_header
        cur_page = {"page": png_name.strip(), "frames": []}
        pages.append(cur_page)
        in_page_header = True

    for line in lines:
        s = line.strip()

        # 1) Gặp tên tấm PNG => trang mới
        if s.endswith(".png"):
            start_new_page(s)
            continue

        # 2) Header trang
        if in_page_header and s.split(":")[0] in ("size", "format", "filter", "repeat"):
            continue

        # 3) Kết thúc header khi gặp frame name
        if in_page_header and not line.startswith(" "):
            in_page_header = False

        # 4) Tên frame
        if not line.startswith(" ") and ":" not in s:
            cur_frame = {"name": s}
            if cur_page is not None:
                cur_page["frames"].append(cur_frame)
            continue

        # 5) Thuộc tính frame
        if ":" in s and line.startswith(" ") and cur_frame is not None:
            k, v = s.split(":", 1)
            v = v.strip()
            if k == "rotate":
                cur_frame["rotate"] = (v.lower() == "true")
            elif k == "xy":
                cur_frame["x"], cur_frame["y"] = map(int, v.split(","))
            elif k == "size":
                cur_frame["w"], cur_frame["h"] = map(int, v.split(","))
            elif k == "orig":
                cur_frame["ow"], cur_frame["oh"] = map(int, v.split(","))
            elif k == "offset":
                cur_frame["ox"], cur_frame["oy"] = map(int, v.split(","))
            elif k == "index":
                cur_frame["index"] = int(v)

    # Lọc frame thiếu dữ liệu
    for p in pages:
        p["frames"] = [
            f for f in p["frames"]
            if all(k in f for k in ("x", "y", "w", "h"))
        ]
    return pages


# ---------------------- UNPACK ----------------------
def extract_region(sheet_img: Image.Image, f: dict) -> Image.Image:
    """Crop 1 frame từ đúng trang, có xử lý rotate."""
    x, y, w, h = f["x"], f["y"], f["w"], f["h"]
    rot = f.get("rotate", False)

    # Khi rotate:true → thực tế crop vùng (h, w)
    crop_w, crop_h = (h, w) if rot else (w, h)
    region = sheet_img.crop((x, y, x + crop_w, y + crop_h))

    if rot:
        # Spine/LibGDX: rotate:true = xoay 90° CW -> cần xoay lại 90° CCW
        region = region.transpose(Image.Transpose.ROTATE_270)

    return region


def compose_with_orig(region: Image.Image, f: dict) -> Image.Image:
    """Phục hồi orig + offset CHUẨN (không bị lệch/giật)."""
    w, h = f["w"], f["h"]
    ow, oh = f.get("ow", w), f.get("oh", h)
    ox, oy = f.get("ox", 0), f.get("oy", 0)
    rw, rh = region.size

    canvas = Image.new("RGBA", (ow, oh), (0, 0, 0, 0))

    # Công thức Spine / LibGDX chuẩn – KHÔNG dùng oy trực tiếp
    canvas.paste(region, (ox, oh - rh - oy))

    return canvas


def unpack_atlas(atlas_path: str, out_root="output", restore_orig=False):
    """Giải nén 1 file .atlas (có thể nhiều trang)."""
    pages = parse_atlas_multi(atlas_path)
    if not pages:
        print(f"❌ {atlas_path}: không tìm thấy frame.")
        return

    atlas_base = os.path.splitext(os.path.basename(atlas_path))[0]
    atlas_out = os.path.join(out_root, atlas_base)
    os.makedirs(atlas_out, exist_ok=True)

    print(f"\n📦 Đang xử lý atlas: {atlas_base}")

    for p in pages:
        page_png = p["page"]
        page_dir = os.path.dirname(atlas_path)
        png_path = os.path.join(page_dir, page_png)

        if not os.path.exists(png_path):
            print(f"⚠️ Thiếu trang ảnh: {png_path}")
            continue

        sheet = Image.open(png_path).convert("RGBA")
        print(f"  • Trang: {os.path.basename(png_path)} → {len(p['frames'])} frames")

        for f in p["frames"]:
            region = extract_region(sheet, f)
            out_img = compose_with_orig(region, f) if restore_orig else region

            save_rel = f["name"] + ".png"
            save_path = os.path.join(atlas_out, *save_rel.split("/"))
            os.makedirs(os.path.dirname(save_path), exist_ok=True)
            out_img.save(save_path)

    print(f"✅ Hoàn tất → {atlas_out}")


def unpack_all(folder=".", restore_orig=True):
    """Quét và giải nén TẤT CẢ .atlas trong thư mục hiện tại."""
    atlas_files = [fn for fn in os.listdir(folder) if fn.endswith(".atlas")]
    if not atlas_files:
        print("❌ Không tìm thấy file .atlas nào.")
        return

    for atlas in atlas_files:
        unpack_atlas(os.path.join(folder, atlas), out_root="output", restore_orig=restore_orig)

    print("\n🎯 Hoàn tất toàn bộ atlas!")


# ---------------------- MAIN ----------------------
if __name__ == "__main__":
    # restore_orig=True = KHÔNG LỆCH/ KHÔNG GIẬT ẢNH
    unpack_all(".", restore_orig=True)
