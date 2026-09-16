import struct
from pathlib import Path

KEY = b"^G2kbW;UWg)/\\2@q"
DELTA = 0x9E377989
MASK = 0xFFFFFFFF
SIGN = b"^_3uz`TG,!"

SRC = Path(r"D:\h5\codex_workspace\tools\ld9_runtime_dump_full\data_user_0\files\assets\src\config\dungeon_data.luac")
OUT_DIR = Path(r"D:\h5\codex_workspace\tools\ld9_runtime_dump_full\decrypted")
OUT_RAW = OUT_DIR / "dungeon_data.decrypted.bin"
OUT_LUAC = OUT_DIR / "dungeon_data.decrypted.luac"


def xxtea_decrypt_custom(data: bytes, key: bytes) -> bytes:
    if not data:
        return data
    if len(key) != 16:
        raise ValueError(f"KEY must be 16 bytes, got {len(key)}")
    if len(data) % 4 != 0:
        raise ValueError(f"cipher payload must be divisible by 4, got {len(data)}")

    v = list(struct.unpack(f"<{len(data) // 4}I", data))
    k = list(struct.unpack("<4I", key))
    n = len(v)
    if n < 2:
        return data

    q = 2 + 52 // n
    sum_val = (q * DELTA) & MASK
    y = v[0] & MASK

    while sum_val != 0:
        e = (sum_val >> 2) & 3
        for p in range(n - 1, 0, -1):
            z = v[p - 1] & MASK
            y_left  = (y << 2) & MASK
            z_right = (z >> 5) & MASK
            z_left  = (z << 4) & MASK
            y_right = (y >> 3) & MASK
            part1   = y_left ^ z_right
            part2   = z_left ^ y_right
            sum_y   = (sum_val ^ y) & MASK
            key_z   = (k[(p & 3) ^ e] ^ z) & MASK
            mx      = (((part1 + part2) & MASK) ^ ((sum_y + key_z) & MASK)) & MASK
            v[p]    = (v[p] - mx) & MASK
            y       = v[p]

        z       = v[n - 1] & MASK
        y_left  = (y << 2) & MASK
        z_right = (z >> 5) & MASK
        z_left  = (z << 4) & MASK
        y_right = (y >> 3) & MASK
        part1   = y_left ^ z_right
        part2   = z_left ^ y_right
        sum_y   = (sum_val ^ y) & MASK
        key_z   = (k[e] ^ z) & MASK
        mx      = (((part1 + part2) & MASK) ^ ((sum_y + key_z) & MASK)) & MASK
        v[0]    = (v[0] - mx) & MASK
        y       = v[0]
        sum_val = (sum_val - DELTA) & MASK

    return struct.pack(f"<{n}I", *v)


def classify(data: bytes) -> str:
    if data.startswith(b"\x1bLJ"):
        return "LuaJIT bytecode"
    if data.startswith(b"\x1bLua"):
        return "Lua bytecode"
    head = data[:128]
    printable = sum(32 <= b < 127 or b in (9, 10, 13) for b in head)
    if head and printable / len(head) > 0.8:
        return "mostly printable text/Lua source"
    return "unknown binary"


def main():
    raw = SRC.read_bytes()
    print(f"source      : {SRC}")
    print(f"source size : {len(raw)}")
    print(f"first 10    : {raw[:10]!r}")
    print(f"key length  : {len(KEY)}")

    if not raw.startswith(SIGN):
        raise SystemExit(f"Unexpected sign/header: {raw[:10]!r}")

    payload = raw[len(SIGN):]
    print(f"sign/header : {SIGN!r} ({len(SIGN)} bytes)")
    print(f"payload size: {len(payload)}; mod4={len(payload) % 4}")

    plain = xxtea_decrypt_custom(payload, KEY)
    kind = classify(plain)

    OUT_DIR.mkdir(parents=True, exist_ok=True)
    OUT_RAW.write_bytes(plain)
    OUT_LUAC.write_bytes(plain)

    print(f"type        : {kind}")
    print(f"plain head  : {plain[:32].hex()}")
    print(f"plain repr  : {plain[:64]!r}")
    print(f"wrote       : {OUT_RAW}")
    print(f"wrote       : {OUT_LUAC}")


if __name__ == "__main__":
    main()
