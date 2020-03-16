
# Pseudocode

*Pseudocode for each of the proposals.*

---

## V1

```
saes.v1.enc(rs1):
    rd.8[i] =    AESSBox(rs1.8[i]) for i = 0..3

saes.v1.dec(rs1):
    rd.8[i] = InvAESSBox(rs1.8[i]) for i = 0..3
```

## V2

```
saes.v2.sub(rs1, rs2, mode):
    if(mode == enc)
        t0 =    AESSBox(rs1.8[0]), t1 =    AESSBox(rs2.8[1])
        t2 =    AESSBox(rs1.8[2]), t3 =    AESSBox(rs2.8[3])
    else
        t0 = InvAESSBox(rs1.8[0]), t1 = InvAESSBox(rs2.8[1])
        t2 = InvAESSBox(rs1.8[2]), t3 = InvAESSBox(rs2.8[3])
    rd.32 = {t3, t2, t1, t0} 

saes.v2.mix(rs1, rs2, mode):
    t0 = rs1.8[0], t1 = rs1.8[1]
    t2 = rs2.8[2], t3 = rs2.8[3]
    if(mode == enc)
        rd.32 =    AESMixColumns(t3,t2,t1,t0)
    else
        rd.32 = InvAESMixColumns(t3,t2,t1,t0)
```

## V3

```
saes.v3.encs(rs1, rs2, bs):                 // SubBytes Only
    t0.8  = rs1.8[bs]
    x.8   = AESSBox(t0)
    u.32  = {0, 0, 0, x}
    rd.32 = ROTL32(u, 8*bs) ^ rs2.32

saes.v3.encsm(rs1, rs2, bs):                // SubBytes & MixColumns
    t0.8  = rs1.8[bs]
    x.8   = AESSBox(t0)
    u.32  = {GFMUL(x,3) , x, x, GFMUL(x,2)}
    rd.32 = ROTL32(u, 8*bs) ^ rs2.32

saes.v3.decs(rs1, rs2, bs):                 // InvSubBytes Only
    t0.8  = rs1.8[bs]
    x.8   = InvAESSBox(t0)
    u.32  = {0, 0, 0, x}
    rd.32 = ROTL32(u, 8*bs) ^ rs2.32

saes.v3.decsm(rs1, rs2, bs):                // InvSubBytes & InvMixColumns
    t0.8  = rs1.8[bs]
    x.8   = InvAESSBox(t0)
    u.32  = {GFMUL(x,11),GFMUL(x,13),GFMUL(9),GFMUL(14)}
    rd.32 = ROTL32(u, 8*bs) ^ rs2.32
```

## V4

```
saes.v4.sub(rs1):               // SubBytes Only for Encrypt KeySchedule
    rd.8[i]  = AESSBox(rs1.8[i]) for i=0..3
    rd.8[j]  =         rs1.8[j]  for j=4..7

saes.v4.enc(rs1, rs2, mix, hi): // SubBytes, ShiftRows, MixColumns
    t1.128    = AESShiftRows(rs2 || rs1)
    t2.64     = t1.64[1] if hi else t1.64[0]
    t3.8[i]   = AESSBox(t2.8[i]) for i=0..7
    t4.32[0]  = AESMixColumn(t3.32[0]) if mix else t3.32[0]
    t4.32[1]  = AESMixColumn(t3.32[1]) if mix else t3.32[1]
    rd.64     = t4.64[1] if hi else t4.64[0]

saes.v4.dec(rs1, rs2, mix, hi): // InvSubBytes, InvShiftRows, InvMixColumns
    t1.128    = InvAESShiftRows(rs2 || rs1)
    t2.64     = t1.64[1] if hi else t1.64[0]
    t3.8[i]   = InvAESSBox(t2.8[i]) for i=0..7
    t4.32[0]  = InvAESMixColumn(t3.32[0]) if mix else t3.32[0]
    t4.32[1]  = InvAESMixColumn(t3.32[1]) if mix else t3.32[1]
    rd.64     = t4.64[1] if hi else = t4.64[0]

saes.v4.imix(rs1):              // Inverse MixColumns
    rd.32[0] = InvAESMixColumns(rs1.32[0])
    rd.32[1] = InvAESMixColumns(rs1.32[1])
```

## v5 / Tiled

TBD
