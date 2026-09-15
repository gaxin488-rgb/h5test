import struct

# --- Cấu hình giải mã ---
KEY = b"^G2kbW;UWg)/\\2@q"
DELTA = 0x9E377989
MASK = 0xFFFFFFFF

# --- Thuật toán XXTEA Custom ---
def xxtea_decrypt_custom(data: bytes, key: bytes) -> bytes:
    if not data:
        return data
        
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
            part1   = y_left  ^ z_right
            part2   = z_left  ^ y_right
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
        part1   = y_left  ^ z_right
        part2   = z_left  ^ y_right
        sum_y   = (sum_val ^ y) & MASK
        key_z   = (k[(0 & 3) ^ e] ^ z) & MASK
        mx      = (((part1 + part2) & MASK) ^ ((sum_y + key_z) & MASK)) & MASK
        v[0]    = (v[0] - mx) & MASK
        y       = v[0]
        
        sum_val = (sum_val - DELTA) & MASK
        
    return struct.pack(f"<{n}I", *v)