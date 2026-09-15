import struct
import sys
from pathlib import Path

SIGN = b"^_3uz`TG,!"
KEY = b"^G2kbW;UWg)/\\2@q"
DELTA = 0x9E377989
MASK = 0xFFFFFFFF


def decrypt_container(raw: bytes) -> bytes:
    if not raw.startswith(SIGN):
        return raw
    payload = raw[len(SIGN):]
    if len(payload) % 4:
        raise ValueError("encrypted payload is not 4-byte aligned")
    words = list(struct.unpack(f"<{len(payload) // 4}I", payload))
    key_words = list(struct.unpack("<4I", KEY))
    count = len(words)
    if count < 2:
        return payload
    rounds = 2 + 52 // count
    total = (rounds * DELTA) & MASK
    y = words[0]
    while total:
        e = (total >> 2) & 3
        for pos in range(count - 1, 0, -1):
            z = words[pos - 1]
            mix = ((((y << 2) & MASK) ^ (z >> 5)) + (((z << 4) & MASK) ^ (y >> 3))) & MASK
            mix ^= (((total ^ y) + (key_words[(pos & 3) ^ e] ^ z)) & MASK)
            words[pos] = (words[pos] - mix) & MASK
            y = words[pos]
        z = words[count - 1]
        mix = ((((y << 2) & MASK) ^ (z >> 5)) + (((z << 4) & MASK) ^ (y >> 3))) & MASK
        mix ^= (((total ^ y) + (key_words[e] ^ z)) & MASK)
        words[0] = (words[0] - mix) & MASK
        y = words[0]
        total = (total - DELTA) & MASK
    return struct.pack(f"<{count}I", *words)


def main() -> None:
    if len(sys.argv) != 3:
        raise SystemExit("usage: decode_asset_preview.py INPUT OUTPUT")
    source = Path(sys.argv[1])
    target = Path(sys.argv[2])
    target.write_bytes(decrypt_container(source.read_bytes()).rstrip(b"\x00"))
    print(f"WROTE={target}")


if __name__ == "__main__":
    main()
