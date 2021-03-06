
#include "aes_common.S"

.data

.text

.macro AES_KEY_ROUND RK_LO, RK_HI, RK, TMP1, TMP2, OFFSET, RCON
    saes.v4.ks1      \TMP1 , \RK_HI, \RCON
    saes.v4.ks2      \RK_LO, \TMP1 , \RK_LO
    saes.v4.ks2      \RK_HI, \RK_LO, \RK_HI
    AES_DUMP_STATE  \RK_LO, \RK_HI, \RK   , \TMP1, \TMP2, \OFFSET
.endm

.macro AES_KEY_DBL_ROUND RK_LO, RK_HI, RK_LO2, RK_HI2, RK, TMP1, TMP2, OFFSET, RCON
    saes.v4.ks1      \TMP1 , \RK_HI, \RCON
    saes.v4.ks2      \RK_LO2, \TMP1 , \RK_LO
    saes.v4.ks2      \RK_HI2, \RK_LO2, \RK_HI
    saes.v4.ks1      \TMP1 , \RK_HI2, \RCON+1
    saes.v4.ks2      \RK_LO, \TMP1 , \RK_LO2
    saes.v4.ks2      \RK_HI, \RK_LO, \RK_HI2
    AES_DUMP_STATE  \RK_LO2, \RK_HI2, \RK   , \TMP1, \TMP2, \OFFSET
    AES_DUMP_STATE  \RK_LO, \RK_HI, \RK   , \TMP1, \TMP2, \OFFSET + 1*16
.endm

.func   aes_128_enc_key_schedule
.global aes_128_enc_key_schedule
aes_128_enc_key_schedule:       // a0 - uint32_t rk [AES_128_RK_WORDS]
                                // a1 - uint8_t  ck [AES_128_CK_BYTE ]

    #define RK     a0
    #define CK     a1
    #define TMP1   t0
    #define TMP2   t1
    #define TMP3   t2
    #define RK_LO  a2
    #define RK_HI  a3
    #define RK_LO2 a4
    #define RK_HI2 a5

    AES_LOAD_STATE  RK_LO, RK_HI, CK, TMP1, TMP2

    AES_DUMP_STATE  RK_LO, RK_HI, RK, TMP1, TMP2, 0*16

    AES_KEY_DBL_ROUND   RK_LO, RK_HI,RK_LO2,RK_HI2, RK, TMP1, TMP2, 1*16, 0
    AES_KEY_DBL_ROUND   RK_LO, RK_HI,RK_LO2,RK_HI2, RK, TMP1, TMP2, 3*16, 2
    AES_KEY_DBL_ROUND   RK_LO, RK_HI,RK_LO2,RK_HI2, RK, TMP1, TMP2, 5*16, 4
    AES_KEY_DBL_ROUND   RK_LO, RK_HI,RK_LO2,RK_HI2, RK, TMP1, TMP2, 7*16, 6
    AES_KEY_DBL_ROUND   RK_LO, RK_HI,RK_LO2,RK_HI2, RK, TMP1, TMP2, 9*16, 8

    ret

    #undef RK
    #undef CK
    #undef TMP1
    #undef TMP2
    #undef TMP3
    #undef RK_LO
    #undef RK_HI

.endfunc

.func   aes_128_dec_key_schedule
.global aes_128_dec_key_schedule
aes_128_dec_key_schedule:       // a0 - uint32_t rk [AES_128_RK_WORDS]
                                // a1 - uint8_t  ck [AES_128_CK_BYTE ]

    #define RKP t0
    #define RKE t1

    addi sp, sp, -16
    sd   ra, 0(sp)

    call aes_128_enc_key_schedule

    addi   RKP, a0, 16
    addi   RKE, a0, 160 - 16
    
    .loop:

        ld  a2, 0(RKP)          // Load 2 16-byte round keys at once.
        ld  a3, 8(RKP)          //
        ld  a4,16(RKP)          //
        ld  a5,24(RKP)          //

        saes.v4.imix a2, a2      // Perform inverse mix-columns
        saes.v4.imix a3, a3      //
        saes.v4.imix a4, a4      //
        saes.v4.imix a5, a5      //
        
        sd  a2, 0(RKP)          // Store back
        sd  a3, 8(RKP)          //
        sd  a4,16(RKP)          //
        sd  a5,24(RKP)          //

        addi    RKP, RKP, 32
        bne RKP, RKE, .loop
        
    ld  a2, 0(RKP)          // Load 2 16-byte round keys at once.
    ld  a3, 8(RKP)          //
    ld  ra, 0(sp)
    addi sp, sp, 16

    saes.v4.imix a2, a2      // Perform inverse mix-columns
    saes.v4.imix a3, a3      //
    sd  a2, 0(RKP)          // Store back
    sd  a3, 8(RKP)          // Store back
    
    ret

