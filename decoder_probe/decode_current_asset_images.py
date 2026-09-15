from __future__ import annotations

import argparse
import json
import shutil
import struct
from pathlib import Path


SIGNATURE = b"^_3uz`TG,!"
KEY = b"^G2hbW;UWg)/\\2@q"
DELTA = 0x9E3779B9
MASK = 0xFFFFFFFF
IMAGE_EXTENSIONS = {".png", ".jpg", ".jpeg", ".webp", ".gif"}


def is_viewable_image(data: bytes) -> bool:
    return (
        data.startswith(b"\x89PNG\r\n\x1a\n")
        or data.startswith(b"\xff\xd8\xff")
        or data.startswith(b"GIF8")
        or (len(data) >= 12 and data[:4] == b"RIFF" and data[8:12] == b"WEBP")
    )


def decrypt_container(raw: bytes) -> bytes:
    if not raw.startswith(SIGNATURE):
        return raw

    payload = raw[len(SIGNATURE) :]
    if len(payload) % 4:
        raise ValueError("encrypted payload length is not divisible by 4")

    count = len(payload) // 4
    if count < 2:
        return payload

    words = list(struct.unpack(f"<{count}I", payload))
    key_words = list(struct.unpack("<4I", KEY))
    rounds = 6 + 52 // count
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

    return struct.pack(f"<{count}I", *words).rstrip(b"\x00")


def main() -> int:
    parser = argparse.ArgumentParser(description="Decode current com.langla.net image assets")
    parser.add_argument("source", type=Path)
    parser.add_argument("output", type=Path)
    parser.add_argument("--report", type=Path, default=None)
    args = parser.parse_args()

    source = args.source.resolve()
    output = args.output.resolve()
    report_path = (args.report or (output / "decode_report.json")).resolve()
    output.mkdir(parents=True, exist_ok=True)

    report = {
        "source": str(source),
        "output": str(output),
        "algorithm": {
            "signature": SIGNATURE.decode("ascii"),
            "key": KEY.decode("ascii"),
            "delta": hex(DELTA),
            "rounds": "6 + 52 // word_count",
        },
        "counts": {"scanned": 0, "encrypted": 0, "decoded": 0, "copied": 0, "failed": 0, "unknown": 0},
        "bytes": {"source": 0, "output": 0},
        "failures": [],
        "unknown": [],
    }

    for path in sorted(source.rglob("*")):
        if not path.is_file() or path.suffix.lower() not in IMAGE_EXTENSIONS:
            continue

        report["counts"]["scanned"] += 1
        raw = path.read_bytes()
        report["bytes"]["source"] += len(raw)
        relative = path.relative_to(source)
        destination = output / relative

        try:
            if raw.startswith(SIGNATURE):
                report["counts"]["encrypted"] += 1
                decoded = decrypt_container(raw)
                if not is_viewable_image(decoded):
                    raise ValueError(f"decoded header is not a supported image: {decoded[:16].hex()}")
                destination.parent.mkdir(parents=True, exist_ok=True)
                destination.write_bytes(decoded)
                report["counts"]["decoded"] += 1
                report["bytes"]["output"] += len(decoded)
            elif is_viewable_image(raw):
                destination.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(path, destination)
                report["counts"]["copied"] += 1
                report["bytes"]["output"] += len(raw)
            else:
                report["counts"]["unknown"] += 1
                if len(report["unknown"]) < 50:
                    report["unknown"].append(str(relative))
        except Exception as exc:
            report["counts"]["failed"] += 1
            if len(report["failures"]) < 50:
                report["failures"].append({"path": str(relative), "error": str(exc)})

    report_path.parent.mkdir(parents=True, exist_ok=True)
    report_path.write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding="utf-8")
    print(json.dumps(report["counts"], ensure_ascii=False))
    print(json.dumps(report["bytes"], ensure_ascii=False))
    print(f"report={report_path}")
    return 0 if report["counts"]["failed"] == 0 else 1


if __name__ == "__main__":
    raise SystemExit(main())
