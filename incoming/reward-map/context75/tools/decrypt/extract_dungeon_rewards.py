import json, re
from pathlib import Path

SRC = Path(r"D:\h5\codex_workspace\tools\ld9_runtime_dump_full\decrypted\dungeon_data.decrypted.luac")
OUT_JSON = Path(r"D:\h5\codex_workspace\tools\ld9_runtime_dump_full\decrypted\dungeon_rewards.json")
OUT_CSV = Path(r"D:\h5\codex_workspace\tools\ld9_runtime_dump_full\decrypted\dungeon_rewards.csv")


def split_top_level(s: str):
    parts = []
    buf = []
    brace = bracket = paren = 0
    quote = None
    esc = False
    i = 0
    while i < len(s):
        ch = s[i]
        if quote:
            buf.append(ch)
            if esc:
                esc = False
            elif ch == '\\':
                esc = True
            elif ch == quote:
                quote = None
            i += 1
            continue
        if ch in ('"', "'"):
            quote = ch
            buf.append(ch)
        elif ch == '{':
            brace += 1; buf.append(ch)
        elif ch == '}':
            brace -= 1; buf.append(ch)
        elif ch == '[':
            bracket += 1; buf.append(ch)
        elif ch == ']':
            bracket -= 1; buf.append(ch)
        elif ch == '(':
            paren += 1; buf.append(ch)
        elif ch == ')':
            paren -= 1; buf.append(ch)
        elif ch == ',' and brace == 0 and bracket == 0 and paren == 0:
            parts.append(''.join(buf).strip()); buf = []
        else:
            buf.append(ch)
        i += 1
    if buf:
        parts.append(''.join(buf).strip())
    return parts


def parse_pairs(s: str):
    return [[int(a), int(b)] for a, b in re.findall(r'\{\s*(\d+)\s*,\s*(-?\d+)\s*\}', s)]


def as_int(s):
    try:
        return int(s)
    except Exception:
        return None


def main():
    text = SRC.read_text(encoding='utf-8')
    lines = text.splitlines()
    start = None
    for i, line in enumerate(lines):
        if 'Config.DungeonData.data_drama_dungeon_info_table = {' in line:
            start = i + 1
            break
    if start is None:
        raise SystemExit('table start not found')

    rows = []
    rx = re.compile(r'^\s*\[(\d+)\]\s*=\s*\[\[\{(.*)\}\]\],?\s*$')
    for line in lines[start:]:
        m = rx.match(line)
        if not m:
            if rows and line.strip() == '}':
                break
            continue
        key = int(m.group(1))
        fields = split_top_level(m.group(2))
        if len(fields) < 18:
            raise SystemExit(f'{key}: only {len(fields)} fields')
        row = {
            'key': key,
            'name_expr': fields[0],
            'mode': as_int(fields[1]),
            'chapter_id': as_int(fields[2]),
            'land_id': as_int(fields[3]),
            'id': as_int(fields[4]),
            'next_id': as_int(fields[5]),
            'show_items': parse_pairs(fields[6]),
            'is_big': as_int(fields[7]),
            'hook_items': parse_pairs(fields[8]),
            'hook_show_items': parse_pairs(fields[9]),
            'hook_lev_add_expr': fields[10],
            'pos_expr': fields[11],
            'unit_id': as_int(fields[12]),
            'power': as_int(fields[13]),
            'per_hook_items': parse_pairs(fields[14]),
            'talk_ids': parse_pairs(fields[15]),
            'energy_max': as_int(fields[16]),
            'quick_show_items': parse_pairs(fields[17]),
            'extra_fields': fields[18:],
        }
        rows.append(row)

    OUT_JSON.write_text(json.dumps(rows, ensure_ascii=False, indent=2), encoding='utf-8')
    with OUT_CSV.open('w', encoding='utf-8-sig', newline='') as f:
        f.write('key,id,chapter_id,land_id,is_big,power,show_items,hook_items,hook_show_items,per_hook_items,quick_show_items\n')
        for r in rows:
            def j(v): return json.dumps(v, ensure_ascii=False, separators=(',', ':')).replace('"', '""')
            f.write(f"{r['key']},{r['id']},{r['chapter_id']},{r['land_id']},{r['is_big']},{r['power']},\"{j(r['show_items'])}\",\"{j(r['hook_items'])}\",\"{j(r['hook_show_items'])}\",\"{j(r['per_hook_items'])}\",\"{j(r['quick_show_items'])}\"\n")

    print(f'rows={len(rows)}')
    if rows:
        print('first=', json.dumps(rows[-1 if rows[0]["key"] > rows[-1]["key"] else 0], ensure_ascii=False))
        print('last =', json.dumps(rows[0 if rows[0]["key"] > rows[-1]["key"] else -1], ensure_ascii=False))
    print('json =', OUT_JSON)
    print('csv  =', OUT_CSV)


if __name__ == '__main__':
    main()
