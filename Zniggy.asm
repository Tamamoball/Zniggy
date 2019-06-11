;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Zniggy the Znig
; Copyright 2019 anonymous
; 4chan /vr/ board
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 
; ZX Spectrum Memory Map
; 0x0000 - 0x3FFF RESERVED: basic ROM
; 0x4000 - 0x57FF RAM: Screen 256x192 1bpp
; 0x5800 - 0x5AFF RAM: 8x8 color cells 32x24
; 0x5B00 - 0x5BFF RESERVED: Printer Buffer (?)
; 0x5C00 - 0x5CBF RESERVED: System variables (?)
; 0x5CC0 - 0x5CCA RESERVED: ???
; 0x5CCB - 0xFF57 FREE RAM OUR GAME
; 0xFF58 - 0xFFFF RESERVED: ???
 
org $8200
 
;==============================================================
; Defines
;==============================================================
 
SCREEN_PIXEL_START          equ $4000
SCREEN_PIXEL_SIZE           equ $1800
 
SCREEN_ATTRIBUTE_START      equ $5800
SCREEN_ATTRIBUTE_SIZE       equ $0300
 
SCREEN_BORDER_COLOR         equ $FE ; Last 3 bits defines color
 
BLACK_INK                   equ $00
BLUE_INK                    equ $01
RED_INK                     equ $02
PURPLE_INK                  equ $03
GREEN_INK                   equ $04
CYAN_INK                    equ $05
YELLOW_INK                  equ $06
WHITE_INK                   equ $07
 
BLACK_PAPER                 equ BLACK_INK << 3
BLUE_PAPER                  equ BLUE_INK << 3
RED_PAPER                   equ RED_INK << 3
PURPLE_PAPER                equ PURPLE_INK << 3
GREEN_PAPER                 equ GREEN_INK << 3
CYAN_PAPER                  equ CYAN_INK << 3
YELLOW_PAPER                equ YELLOW_INK << 3
WHITE_PAPER                 equ WHITE_INK << 3
 
FLASH                       equ $80
BRIGHT                      equ $40
 
BLOCK_COLLISION             equ $01
BLOCK_COLLISION_BIT         equ 0
BLOCK_LADDER                equ $02
BLOCK_LADDER_BIT            equ 1

 
SCRATCH_ADDRESS1            equ $5CCB
SCRATCH_ADDRESS2            equ $5CCD
SCRATCH_ADDRESS3            equ $5CD3
CURRENT_ROOM_ADDRESS        equ $5CCE
CURRENT_ROOM_NUMBER         equ $5CD0
CURRENT_ROOM_GEMS           equ $5CF0
CURRENT_SPRITE              equ $5CD4
SPRITE_LENGTH               equ $5CD2
BUG_COUNT                   equ $5FFF
WALKER_COUNT                equ $5FFE

COLLECTED_GEMS              equ $60A0
GEM_COLOR                   equ $5EFF

PLAYER_POS                  equ $5D00
PLAYER_X                    equ $5D00
PLAYER_Y                    equ $5D01
PLAYER_VEL                  equ $5D02
PLAYER_ANIM                 equ $5D03
PLAYER_SPRITE               equ $5D04
PLAYER_GEMS                 equ $5D06
PLAYER_ENTRY_X              equ $5D07
PLAYER_ENTRY_Y              equ $5D08


MONSTER_START               equ $6000
MONSTER_POS                 equ $6000
MONSTER_X                   equ $6000
MONSTER_Y                   equ $6001
MONSTER_SPRITE              equ $6002
MONSTER_DIR                 equ $6004
MONSTER_SIZE                equ 5

ROOM_WIDTH                  equ 32
ROOM_HEIGHT                 equ 18
ROOM_SIZE                   equ 32*18
SCREEN_HEIGHT               equ 24
MAP_WIDTH                   equ 4

ROOM_START                  equ $6B00
ROOM_END                    equ $6D41

ROOM_BITS                   equ %00000111

CHAR_A equ 33
CHAR_B equ 34
CHAR_C equ 35
CHAR_D equ 36
CHAR_E equ 37
CHAR_F equ 38
CHAR_G equ 39
CHAR_H equ 40
CHAR_I equ 41
CHAR_J equ 42
CHAR_K equ 43
CHAR_L equ 44
CHAR_M equ 45
CHAR_N equ 46
CHAR_O equ 47
CHAR_P equ 48
CHAR_Q equ 49
CHAR_R equ 50
CHAR_S equ 51
CHAR_T equ 52
CHAR_U equ 53
CHAR_V equ 54
CHAR_W equ 55
CHAR_X equ 56
CHAR_Y equ 57
CHAR_Z equ 58
CHAR_COLON equ 26
CHAR_SQ equ 7
CHAR_SPACE equ 97
CHAR_ZERO equ 16
LC equ 32


;==============================================================
; Data
;==============================================================
SWAP_BIT:
db 0

soundstart:
db 0, 0, 0, 0, 0, 0, 231, 0, 231, 0, 207, 0, 207, 16, 207, 0, 239
db 16, 231, 0, 255, 0, 247, 0, 247, 8, 243, 8, 247, 8, 243, 8, 243, 12
db 241, 12, 243, 14, 241, 12, 241, 14, 241, 8, 241, 15, 241, 0, 243, 143, 241
db 0, 241, 143, 241, 8, 240, 143, 240, 12, 240, 143, 240, 14, 112, 207, 112, 15
db 48, 239, 240, 143, 16, 255, 240, 199, 0, 255, 240, 227, 0, 225, 240, 195, 192
db 225, 241, 225, 224, 225, 241, 44, 48, 15, 135, 0, 240, 14, 31, 240, 110, 16
db 232, 255, 1, 112, 135, 110, 240, 135, 8, 179, 239, 8, 243, 14, 126, 241, 15
db 112, 78, 239, 240, 142, 16, 137, 159, 48, 7, 48, 143, 255, 112, 15, 48, 15
db 223, 241, 12, 224, 14, 191, 247, 0, 99, 16, 159, 255, 240, 0, 242, 0, 127
db 255, 16, 13, 241, 0, 239, 255, 16, 8, 240, 0, 8, 255, 112, 0, 6, 96
db 0, 143, 255, 247, 0, 14, 112, 0, 12, 255, 241, 0, 13, 48, 0, 14, 255
db 241, 0, 14, 113, 0, 15, 255, 112, 0, 15, 208, 0, 15, 255, 112, 0, 143
db 0, 0, 15, 255, 112, 0, 231, 0, 0, 207, 255, 16, 0, 229, 0, 0, 255
db 247, 0, 0, 0, 0, 143, 255, 48, 0, 0, 0, 143, 255, 16, 0, 0, 8
db 247, 0, 143, 48, 8, 255, 48, 143, 80, 4, 239, 240, 14, 112, 4, 207, 240
db 15, 48, 2, 255, 176, 143, 32, 78, 247, 16, 245, 0, 239, 49, 175, 112, 14
db 241, 12, 225, 8, 239, 32, 175, 48, 143, 112, 15, 112, 15, 242, 8, 113, 15
db 243, 8, 73, 15, 123, 32, 41, 175, 97, 36, 165, 135, 148, 80, 80, 239, 74
db 40, 0, 247, 36, 12, 25, 242, 146, 10, 9, 231, 82, 72, 41, 228, 178, 18
db 82, 219, 89, 73, 73, 10, 107, 74, 66, 0, 135, 20, 0, 1, 1, 128, 0
db 152, 0, 0, 0, 0, 16, 10, 0, 12, 180, 17, 64, 0, 1, 0, 8, 0
db 0, 0, 0, 0, 0, 162, 128, 160, 0, 16, 2, 0, 0, 0, 0, 0, 0
db 0, 0, 0, 0, 0, 0, 16, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 0, 0, 0, 0, 1, 0
db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
db 0, 0, 0, 0, 0, 0, 0, 32, 0, 0, 0, 0, 0, 0, 16, 0, 0
db 0, 0, 0, 0, 0, 32, 64, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0
db 16, 1, 0, 65, 0, 4, 128, 128, 10, 2, 0, 0, 0, 1, 0, 0, 0
db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 144, 0
db 0, 67, 0, 0, 0, 8, 72, 0, 0, 0, 0, 0, 164, 132, 239, 48, 0
db 0, 0, 8, 255, 255, 0, 0, 0, 0, 231, 191, 255, 0, 0, 0, 12, 191
db 255, 240, 0, 0, 0, 15, 255, 247, 0, 0, 0, 14, 255, 255, 80, 0, 0
db 0, 255, 255, 112, 0, 0, 0, 143, 255, 210, 0, 64, 0, 15, 255, 64, 0
db 96, 0, 207, 255, 0, 15, 96, 14, 255, 16, 12, 240, 0, 255, 112, 8, 243
db 0, 239, 112, 0, 243, 0, 255, 48, 8, 241, 8, 255, 0, 15, 112, 15, 243
db 0, 255, 0, 239, 112, 14, 241, 12, 247, 0, 207, 16, 143, 112, 12, 241, 14
db 247, 0, 239, 16, 239, 48, 14, 240, 15, 243, 12, 243, 0, 255, 48, 239, 16
db 111, 241, 14, 241, 6, 255, 16, 239, 16, 255, 241, 15, 240, 15, 255, 0, 255
db 8, 223, 240, 143, 112, 204, 247, 0, 135, 12, 252, 241, 6, 96, 6, 64, 0
db 114, 0, 0, 0, 0, 96, 0, 38, 201, 19, 207, 243, 127, 251, 22, 47, 1
db 0, 177, 0, 0, 0, 1, 8, 128, 0, 209, 10, 241, 48, 3, 64, 0, 0
db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 108, 132, 128, 20, 1, 10, 93
db 202, 19, 145, 225, 170, 240, 94, 68, 221, 144, 137, 255, 48, 0, 4, 239, 48
db 206, 12, 62, 241, 7, 96, 217, 243, 14, 17, 228, 231, 12, 112, 193, 207, 30
db 240, 7, 143, 60, 243, 12, 30, 240, 255, 6, 192, 243, 143, 120, 54, 207, 28
db 243, 129, 62, 112, 255, 4, 192, 243, 139, 112, 7, 143, 6, 195, 0, 12, 120
db 62, 16, 6, 241, 224, 32, 0, 143, 247, 0, 0, 14, 255, 16, 0, 8, 255
db 112, 0, 0, 239, 241, 0, 0, 143, 255, 0, 0, 14, 255, 48, 0, 0, 255
db 241, 0, 0, 207, 247, 0, 0, 15, 255, 16, 0, 12, 255, 240, 0, 0, 239
db 243, 0, 0, 143, 255, 16, 0, 12, 255, 240, 0, 0, 239, 247, 0, 0, 143
db 255, 112, 0, 8, 255, 247, 0, 0, 143, 255, 112, 0, 12, 255, 247, 0, 0
db 127, 241, 135, 0, 0, 243, 60, 7, 0, 0, 96, 143, 4, 0, 76, 15, 243
db 0, 208, 20, 8, 4, 180, 36, 12, 228, 3, 183, 231, 9, 242, 58, 244, 241
db 151, 149, 203, 150, 47, 49, 12, 51, 98, 153, 141, 105, 144, 51, 185, 221, 173
db 207, 55, 137, 99, 222, 102, 92, 96, 11, 132, 180, 44, 64, 201, 210, 156, 204
db 224, 6, 33, 243, 29, 157, 64, 200, 183, 1, 25, 159, 241, 225, 70, 137, 24
db 252, 118, 12, 241, 227, 78, 16, 15, 255, 56, 185, 184, 141, 200, 48, 230, 102
db 71, 96, 7, 192, 129, 19, 39, 14, 27, 6, 16, 0, 0, 15, 241, 96, 24
db 0, 0, 207, 112, 97, 0, 0, 8, 241, 0, 0, 0, 0, 255, 24, 251, 0
db 32, 111, 80, 199, 0, 0, 143, 113, 14, 120, 0, 143, 112, 4, 56, 16, 207
db 48, 0, 189, 64, 239, 0, 0, 143, 190, 243, 0, 0, 255, 255, 240, 0, 110
db 255, 247, 0, 0, 239, 255, 16, 0, 15, 255, 112, 0, 14, 255, 112, 0, 14
db 255, 240, 0, 14, 255, 240, 0, 15, 255, 48, 0, 207, 247, 0, 8, 255, 50
db 34, 12, 255, 0, 177, 15, 240, 14, 48, 239, 16, 247, 12, 243, 14, 240, 143
db 16, 203, 8, 243, 12, 241, 15, 240, 143, 16, 247, 8, 243, 15, 177, 15, 56
db 255, 16, 179, 13, 241, 11, 48, 223, 48, 181, 13, 243, 14, 240, 143, 48, 239
db 8, 247, 4, 241, 15, 240, 134, 48, 255, 64, 194, 10, 249, 64, 96, 143, 57
db 68, 8, 247, 41, 0, 15, 244, 41, 0, 239, 189, 33, 12, 239, 107, 16, 2
db 246, 181, 0, 141, 99, 215, 16, 140, 98, 191, 0, 8, 64, 127, 16, 0, 191
db 189, 48, 4, 47, 211, 241, 0, 15, 122, 94, 0, 10, 255, 111, 0, 0, 231
db 189, 176, 0, 143, 212, 240, 0, 14, 123, 117, 0, 12, 255, 177, 16, 2, 255
db 218, 0, 4, 207, 189, 128, 0, 143, 246, 80, 0, 46, 253, 100, 0, 12, 247
db 178, 0, 1, 255, 83, 32, 128, 207, 189, 16, 8, 143, 246, 81, 0, 43, 255
db 100, 0, 4, 247, 177, 0, 1, 207, 246, 0, 4, 143, 251, 32, 0, 30, 255
db 96, 0, 72, 255, 177, 16, 1, 207, 189, 16, 8, 15, 247, 18, 0, 41, 247
db 178, 0, 1, 199, 181, 16, 8, 14, 253, 32, 0, 0, 251, 210, 0, 2, 143
db 255, 64, 0, 136, 223, 123, 0, 0, 175, 255, 244, 0, 72, 251, 255, 49, 0
db 14, 255, 223, 112, 0, 14, 41, 140, 48, 0, 0, 0, 13, 96, 0, 0, 0


soundend:
db 0

DATA_LIVES_STRING:
db CHAR_Z, CHAR_N, CHAR_I, CHAR_G, CHAR_S, CHAR_COLON
PLAYER_LIVES:
db CHAR_ZERO + 9, 0
DATA_GEMS_STRING:
db CHAR_G, CHAR_E, CHAR_M, CHAR_S, CHAR_COLON
PLAYER_GEM_TEXT:
db CHAR_ZERO + 0, CHAR_ZERO + 9, 0

DATA_TILE_PIXELS:

DATA_SPRITES:
DATA_ZIGGY_RIGHT:
db BLACK_PAPER | PURPLE_INK | BRIGHT
; zniggy_0
db %00011000>>0, %00011000<<8
db %00111100>>0, %00111100<<8
db %01111010>>0, %01111010<<8
db %11111111>>0, %11111111<<8
db %01110000>>0, %01110000<<8
db %00111100>>0, %00111100<<8
db %00011000>>0, %00011000<<8
db %00111100>>0, %00111100<<8

db %01111110>>0, %01111110<<8
db %11111111>>0, %11111111<<8
db %01111110>>0, %01111110<<8
db %00111100>>0, %00111100<<8
db %00011000>>0, %00011000<<8
db %00011000>>0, %00011000<<8
db %00011000>>0, %00011000<<8
db %00011110>>0, %00011110<<8
; zniggy_1
db %00011000>>1, %00011000<<7
db %00111100>>1, %00111100<<7
db %01111010>>1, %01111010<<7
db %11111111>>1, %11111111<<7
db %01110000>>1, %01110000<<7
db %00111100>>1, %00111100<<7
db %00011000>>1, %00011000<<7
db %00111100>>1, %00111100<<7

db %01111110>>1, %01111110<<7
db %11111111>>1, %11111111<<7
db %01111110>>1, %01111110<<7
db %00111100>>1, %00111100<<7
db %00011000>>1, %00011000<<7
db %01101100>>1, %01101100<<7
db %10000111>>1, %10000111<<7
db %01000000>>1, %01000000<<7
; zniggy_2
db %00011000>>2, %00011000<<6
db %00111100>>2, %00111100<<6
db %01111010>>2, %01111010<<6
db %11111111>>2, %11111111<<6
db %01110000>>2, %01110000<<6
db %00111100>>2, %00111100<<6
db %00011000>>2, %00011000<<6
db %00111100>>2, %00111100<<6

db %01111110>>2, %01111110<<6
db %11111111>>2, %11111111<<6
db %01111110>>2, %01111110<<6
db %00111100>>2, %00111100<<6
db %00011000>>2, %00011000<<6
db %00101001>>2, %00101001<<6
db %01000110>>2, %01000110<<6
db %10000100>>2, %10000100<<6
; zniggy_3
db %00011000>>3, %00011000<<5
db %00111100>>3, %00111100<<5
db %01111010>>3, %01111010<<5
db %11111111>>3, %11111111<<5
db %01110000>>3, %01110000<<5
db %00111100>>3, %00111100<<5
db %00011000>>3, %00011000<<5
db %00111100>>3, %00111100<<5

db %01111110>>3, %01111110<<5
db %11111111>>3, %11111111<<5
db %01111110>>3, %01111110<<5
db %00111100>>3, %00111100<<5
db %00011000>>3, %00011000<<5
db %00101000>>3, %00101000<<5
db %01010000>>3, %01010000<<5
db %01011110>>3, %01011110<<5

; zniggy_4
db %00011000>>4, %00011000<<4
db %00111100>>4, %00111100<<4
db %01111010>>4, %01111010<<4
db %11111111>>4, %11111111<<4
db %01110000>>4, %01110000<<4
db %00111100>>4, %00111100<<4
db %00011000>>4, %00011000<<4
db %00111100>>4, %00111100<<4

db %01111110>>4, %01111110<<4
db %11111111>>4, %11111111<<4
db %01111110>>4, %01111110<<4
db %00111100>>4, %00111100<<4
db %00011000>>4, %00011000<<4
db %00011000>>4, %00011000<<4
db %00011000>>4, %00011000<<4
db %00011110>>4, %00011110<<4
; zniggy_5
db %00011000>>5, %00011000<<3
db %00111100>>5, %00111100<<3
db %01111010>>5, %01111010<<3
db %11111111>>5, %11111111<<3
db %01110000>>5, %01110000<<3
db %00111100>>5, %00111100<<3
db %00011000>>5, %00011000<<3
db %00111100>>5, %00111100<<3

db %01111110>>5, %01111110<<3
db %11111111>>5, %11111111<<3
db %01111110>>5, %01111110<<3
db %00111100>>5, %00111100<<3
db %00011000>>5, %00011000<<3
db %01101100>>5, %01101100<<3
db %10000111>>5, %10000111<<3
db %01000000>>5, %01000000<<3
; zniggy_6
db %00011000>>6, %00011000<<2
db %00111100>>6, %00111100<<2
db %01111010>>6, %01111010<<2
db %11111111>>6, %11111111<<2
db %01110000>>6, %01110000<<2
db %00111100>>6, %00111100<<2
db %00011000>>6, %00011000<<2
db %00111100>>6, %00111100<<2

db %01111110>>6, %01111110<<2
db %11111111>>6, %11111111<<2
db %01111110>>6, %01111110<<2
db %00111100>>6, %00111100<<2
db %00011000>>6, %00011000<<2
db %00101001>>6, %00101001<<2
db %01000110>>6, %01000110<<2
db %10000100>>6, %10000100<<2
; zniggy_7
db %00011000>>7, %00011000<<1
db %00111100>>7, %00111100<<1
db %01111010>>7, %01111010<<1
db %11111111>>7, %11111111<<1
db %01110000>>7, %01110000<<1
db %00111100>>7, %00111100<<1
db %00011000>>7, %00011000<<1
db %00111100>>7, %00111100<<1

db %01111110>>7, %01111110<<1
db %11111111>>7, %11111111<<1
db %01111110>>7, %01111110<<1
db %00111100>>7, %00111100<<1
db %00011000>>7, %00011000<<1
db %00101000>>7, %00101000<<1
db %01010000>>7, %01010000<<1
db %01011110>>7, %01011110<<1



DATA_ZIGGY_LEFT:
db BLACK_PAPER | PURPLE_INK | BRIGHT
; zniggy_0
db %00011000>>0, %00011000<<8
db %00111100>>0, %00111100<<8
db %01011110>>0, %01011110<<8
db %11111111>>0, %11111111<<8
db %00001110>>0, %00001110<<8
db %00111100>>0, %00111100<<8
db %00011000>>0, %00011000<<8
db %00111100>>0, %00111100<<8

db %01111110>>0, %01111110<<8
db %11111111>>0, %11111111<<8
db %01111110>>0, %01111110<<8
db %00111100>>0, %00111100<<8
db %00011000>>0, %00011000<<8
db %00011000>>0, %00011000<<8
db %00011000>>0, %00011000<<8
db %01111000>>0, %01111000<<8
; zniggy_1
db %00011000>>1, %00011000<<7
db %00111100>>1, %00111100<<7
db %01011110>>1, %01011110<<7
db %11111111>>1, %11111111<<7
db %00001110>>1, %00001110<<7
db %00111100>>1, %00111100<<7
db %00011000>>1, %00011000<<7
db %00111100>>1, %00111100<<7

db %01111110>>1, %01111110<<7
db %11111111>>1, %11111111<<7
db %01111110>>1, %01111110<<7
db %00111100>>1, %00111100<<7
db %00011000>>1, %00011000<<7
db %00110110>>1, %00110110<<7
db %11100001>>1, %11100001<<7
db %00000010>>1, %00000010<<7
; zniggy_2
db %00011000>>2, %00011000<<6
db %00111100>>2, %00111100<<6
db %01011110>>2, %01011110<<6
db %11111111>>2, %11111111<<6
db %00001110>>2, %00001110<<6
db %00111100>>2, %00111100<<6
db %00011000>>2, %00011000<<6
db %00111100>>2, %00111100<<6

db %01111110>>2, %01111110<<6
db %11111111>>2, %11111111<<6
db %01111110>>2, %01111110<<6
db %00111100>>2, %00111100<<6
db %00011000>>2, %00011000<<6
db %10010100>>2, %10010100<<6
db %01100010>>2, %01100010<<6
db %00100001>>2, %00100001<<6
; zniggy_3
db %00011000>>3, %00011000<<5
db %00111100>>3, %00111100<<5
db %01011110>>3, %01011110<<5
db %11111111>>3, %11111111<<5
db %00001110>>3, %00001110<<5
db %00111100>>3, %00111100<<5
db %00011000>>3, %00011000<<5
db %00111100>>3, %00111100<<5

db %01111110>>3, %01111110<<5
db %11111111>>3, %11111111<<5
db %01111110>>3, %01111110<<5
db %00111100>>3, %00111100<<5
db %00011000>>3, %00011000<<5
db %00010100>>3, %00010100<<5
db %00001010>>3, %00001010<<5
db %01111010>>3, %01111010<<5

; zniggy_4
db %00011000>>4, %00011000<<4
db %00111100>>4, %00111100<<4
db %01011110>>4, %01011110<<4
db %11111111>>4, %11111111<<4
db %00001110>>4, %00001110<<4
db %00111100>>4, %00111100<<4
db %00011000>>4, %00011000<<4
db %00111100>>4, %00111100<<4

db %01111110>>4, %01111110<<4
db %11111111>>4, %11111111<<4
db %01111110>>4, %01111110<<4
db %00111100>>4, %00111100<<4
db %00011000>>4, %00011000<<4
db %00011000>>4, %00011000<<4
db %00011000>>4, %00011000<<4
db %01111000>>4, %01111000<<4
; zniggy_5
db %00011000>>5, %00011000<<3
db %00111100>>5, %00111100<<3
db %01011110>>5, %01011110<<3
db %11111111>>5, %11111111<<3
db %00001110>>5, %00001110<<3
db %00111100>>5, %00111100<<3
db %00011000>>5, %00011000<<3
db %00111100>>5, %00111100<<3

db %01111110>>5, %01111110<<3
db %11111111>>5, %11111111<<3
db %01111110>>5, %01111110<<3
db %00111100>>5, %00111100<<3
db %00011000>>5, %00011000<<3
db %00110110>>5, %00110110<<3
db %11100001>>5, %11100001<<3
db %00000010>>5, %00000010<<3
; zniggy_6
db %00011000>>6, %00011000<<2
db %00111100>>6, %00111100<<2
db %01011110>>6, %01011110<<2
db %11111111>>6, %11111111<<2
db %00001110>>6, %00001110<<2
db %00111100>>6, %00111100<<2
db %00011000>>6, %00011000<<2
db %00111100>>6, %00111100<<2

db %01111110>>6, %01111110<<2
db %11111111>>6, %11111111<<2
db %01111110>>6, %01111110<<2
db %00111100>>6, %00111100<<2
db %00011000>>6, %00011000<<2
db %10010100>>6, %10010100<<2
db %01100010>>6, %01100010<<2
db %00100001>>6, %00100001<<2
; zniggy_7
db %00011000>>7, %00011000<<1
db %00111100>>7, %00111100<<1
db %01011110>>7, %01011110<<1
db %11111111>>7, %11111111<<1
db %00001110>>7, %00001110<<1
db %00111100>>7, %00111100<<1
db %00011000>>7, %00011000<<1
db %00111100>>7, %00111100<<1

db %01111110>>7, %01111110<<1
db %11111111>>7, %11111111<<1
db %01111110>>7, %01111110<<1
db %00111100>>7, %00111100<<1
db %00011000>>7, %00011000<<1
db %00010100>>7, %00010100<<1
db %00001010>>7, %00001010<<1
db %01111010>>7, %01111010<<1


DATA_BUG:
db %00001100, %00110000
db %00010011, %11001000
db %00000011, %11000000
db %00001111, %11110000
db %00000101, %10100000
db %10011110, %01111001
db %01111000, %00011110
db %00010110, %01101000

db %00010010, %01001000
db %00010010, %01001000
db %11110010, %01001111
db %00110000, %00001100
db %00111111, %11111100
db %01001011, %11010010
db %00000111, %11100000
db %00000001, %10000000 
 
DATA_BOTTLE:
db 68
db 48,0,48,0,48,0,48,0,120,0,120,0,252,0,252,0
db 4,0,244,0,244,0,4,0,252,0,252,0,252,0,252,0
db 3,0,3,0,3,0,6,0,30,0,30,0,63,0,63,0
db 1,0,61,0,61,0,1,0,127,0,127,0,126,0,62,0
db 0,0,0,0,0,2,0,7,0,14,0,252,1,56,3,216
db 4,88,15,184,31,240,3,224,57,192,124,128,126,0,63,0
db 0,0,0,28,0,28,0,24,0,248,1,248,3,240,0,112
db 3,144,3,208,0,208,7,16,7,240,7,240,0,16,7,224
db 0,12,0,12,0,12,0,12,0,30,0,30,0,63,0,63
db 0,32,0,47,0,47,0,32,0,63,0,63,0,63,0,63
db 0,96,0,96,0,96,0,48,0,60,0,60,0,126,0,126
db 0,64,0,94,0,94,0,64,0,127,0,127,0,63,0,62
db 0,0,0,0,32,0,112,0,56,0,31,128,14,64,13,224
db 13,16,14,248,7,252,3,224,1,206,0,159,0,63,0,126
db 0,96,0,96,0,96,0,48,0,60,0,60,0,126,0,126
db 0,64,0,94,0,94,0,64,0,127,0,127,0,63,0,62
 
DATA_SNAKE:
db 68
db 7,192,15,32,31,56,31,248,16,0,16,0,15,240,0,8
db 0,8,15,240,16,0,16,0,15,240,0,8,0,8,15,240
 
DATA_GHOST:
db 69
db 0,0,96,6,56,12,28,216,15,240,15,224,11,160,25,48
db 31,240,62,248,61,120,63,248,63,248,63,120,51,104,0,0
 
DATA_GEM:
db %00111100
db %01011010
db %11111111
db %01011010
db %00111100
db %00111100
db %00011000
db %00011000

DATA_BLOCK_SPRITES:
; TODO: FIX ADDRESSING BUG WRITING TO THIS MEMORY
db 0,0,0,0
BLOCK_0:
db 0,0,0,0,0,0,0,0
db 255,254,180,164,32,0,0,0
db 255,129,189,165,165,189,129,255
db 8,16,126,16,8,126,8,16
db 82,98,82,98,82,98,82,98
db 0,0,0,0,0,0,0,0
db 127,63,119,251,219,73,62,127
db 255,0,255,85,85,81,17,17
db 1,3,7,14,30,63,117,247
db 255,255,240,248,5,142,212,96
db 127,127,127,0,247,247,247,0
db 16,231,102,24,40,100,100,72
db 0,255,255,0,0,255,255,0
db 0,3,15,30,56,48,115,98
db 0,255,240,123,28,12,206,70
db 102,102,102,102,102,102,102,102
db 98,115,48,56,30,63,75,120
db 70,206,12,28,120,252,243,30
db 16,231,102,24,40,100,100,72
db 127,127,127,0,247,247,247,0
db 32,207,204,48,80,200,200,144
db 255,129,255,129,255,129,255,129
db 1,15,255,127,63,31,7,1
db 207,207,231,231,207,207,231,231
db 248,254,255,255,255,255,255,255
db 248,254,206,255,255,0,254,252
db 255,255,255,51,0,204,255,255
db 31,127,115,255,255,0,127,63
db 255,255,255,255,255,255,254,248
db 255,136,136,255,255,17,17,255
db 0,224,32,108,106,202,202,234
db 0,128,0,155,173,191,137,187
db 0,0,4,84,84,116,16,100
db 126,66,255,66,126,90,90,102
db 102,102,126,90,90,90,90,90
db 0,0,3,4,4,12,8,24
db 0,0,254,34,33,33,33,33
db 31,63,97,222,99,73,34,28
db 126,126,126,126,254,127,0,0
db 254,255,131,185,69,146,68,56
db 255,85,170,0,85,0,170,0
db 0,60,90,102,102,90,60,0
db 255,129,255,129,255,129,255,129
db 211,82,222,128,243,18,243,94
db 24,24,52,52,122,122,253,253
db 211,82,223,129,243,18,243,94
db 166,164,188,0,230,36,230,188
DATA_BLOCK_ATTRIBS:
db 0
db 7
db 69
db 71
db 69
db 0
db 7
db 69
db 7
db 7
db 66
db 68
db 67
db 67
db 67
db 67
db 67
db 67
db 68
db 2
db 68
db 66
db 70
db 102
db 70
db 70
db 102
db 70
db 70
db 69
db 67
db 67
db 67
db 66
db 66
db 68
db 68
db 68
db 68
db 68
db 86
db 74
db 71
db 68
db 67
db 68
db 68
DATA_BLOCK_PROPERTIES:
db 0
db 1
db 1
db 2
db 1
db 1
db 1
db 1
db 1
db 1
db 1
db 2
db 1
db 1
db 1
db 1
db 1
db 1
db 1
db 1
db 2
db 2
db 1
db 1
db 1
db 1
db 1
db 1
db 1
db 1
db 1
db 1
db 1
db 1
db 1
db 1
db 1
db 1
db 1
db 1
db 1
db 1
db 2
db 1
db 0
db 1
db 1







DATA_ROOMS:
ROOM_21:
db 3,1,1,0,2,1,10,0,2,2,4,0,1,3,9,2,22,0,1,3,3,0
db 1,4,2,0,3,2,20,0,2,5,1,3,3,0,1,4,11,0,1,6,1,1
db 3,0,2,6,3,0,1,7,1,4,1,7,3,0,1,3,4,7,7,0,1,8
db 4,6,3,0,3,1,4,0,1,4,4,0,1,3,7,0,2,2,1,0,1,8
db 1,9,4,1,10,0,1,4,4,0,1,3,6,0,3,2,2,1,6,0,1,1
db 7,0,16,2,11,0,1,1,4,0,4,6,2,9,3,1,7,6,16,0,2,1
db 1,6,6,0,3,6,1,9,3,1,1,0,1,1,6,0,1,1,9,0,1,6
db 6,0,1,6,1,9,1,1,9,0,1,1,4,0,1,1,7,0,2,1,2,6
db 2,0,1,3,1,1,26,0,2,6,1,9,1,1,1,3,16,0,1,1,10,0
db 2,6,2,0,1,3,9,0,1,8,1,6,12,0,1,3,3,0,1,6,1,9
db 2,0,1,3,1,0,2,6,2,1,3,0,1,8,1,6,1,1,12,0,1,3
db 2,1,1,0,1,6,2,0,1,1,1,3,2,1,1,6,4,0,3,1,3,0
db 1,1,9,0,1,3,3,0,1,6,3,0,1,3,2,0,1,6,3,0,1,6
db 16,0,1,3,3,0,1,6,1,0,1,6,1,0,1,3,2,0,5,6,16,0
db 1,3,3,0,2,6,1,1,1,0,1,3,2,0,5,6,$FF

;Monsters
db 0,0
; Room name
db CHAR_I, CHAR_C + LC, CHAR_E + LC, CHAR_SPACE, CHAR_P, CHAR_A + LC, CHAR_L + LC
db CHAR_A + LC, CHAR_C + LC, CHAR_E + LC, CHAR_SPACE, CHAR_E, CHAR_N + LC, CHAR_T + LC
db CHAR_R + LC, CHAR_A + LC, CHAR_N + LC, CHAR_C + LC, CHAR_E + LC, 0
; Gems
db 1,32,6,104,18,88,19,64,21,128,28,112

ROOM_54:
db 12,10,1,11,19,10,23,12,1,10,1,11,4,10,1,11,2,10,23,0,1,10
db 1,11,3,10,1,11,3,10,23,0,9,12,44,0,7,12,13,0,1,12,2,11
db 9,12,4,10,1,0,1,11,14,0,1,10,2,11,9,0,1,13,1,12,1,14
db 1,10,1,0,1,11,14,0,1,10,1,0,1,11,9,0,1,15,1,12,1,15
db 1,10,1,0,1,11,14,0,1,10,1,0,1,11,9,0,1,16,1,12,1,17
db 1,10,1,0,1,11,1,0,1,13,1,12,1,14,1,13,1,12,1,14,11,12
db 2,11,10,12,1,0,1,11,1,0,1,15,1,11,2,15,1,12,1,15,2,10
db 1,18,2,10,1,18,1,10,1,14,3,10,2,11,2,0,1,11,2,0,2,11
db 1,0,1,11,2,0,1,11,1,0,1,16,1,12,1,17,1,16,1,12,1,17
db 3,10,1,18,1,10,1,18,1,10,1,15,3,10,1,0,1,11,2,0,1,11
db 2,0,1,11,2,0,1,11,2,0,1,11,1,0,3,12,1,11,4,12,3,10
db 1,18,1,10,1,17,3,10,1,0,1,11,2,0,1,11,2,0,1,11,2,0
db 1,11,2,0,1,11,3,0,1,13,1,12,1,14,1,13,1,11,1,14,1,13
db 1,12,1,14,2,10,1,12,3,10,1,0,1,11,2,0,1,11,2,0,1,11
db 2,0,1,11,2,0,1,11,3,0,1,15,1,12,2,15,1,11,2,15,1,12
db 1,15,2,10,1,13,1,12,1,11,1,10,1,0,1,11,2,0,1,11,5,0
db 1,11,6,0,1,16,1,12,1,17,1,16,1,12,1,17,1,16,1,12,1,17
db 2,10,1,15,1,12,1,11,1,10,4,0,1,11,12,0,7,12,1,11,1,12
db 2,10,1,16,1,12,1,17,1,10,17,0,8,10,1,11,2,10,$FF

;Monsters
db 0,3
db 161, 16, DATA_BOTTLE, DATA_BOTTLE>>8, 1
db 82, 63, DATA_BOTTLE, DATA_BOTTLE>>8, 1
db 88, 119, DATA_BOTTLE, DATA_BOTTLE>>8, 1
; Room name
db CHAR_W, CHAR_I + LC, CHAR_N + LC, CHAR_E + LC, 255
db CHAR_C, CHAR_E + LC, CHAR_L + LC, CHAR_L + LC, CHAR_A + LC, CHAR_R + LC, 0
; Gems
db 6,104,9,112,12,104,15,96,7,64,20,24

ROOM_62:
db 4,10,17,0,15,10,17,0,15,10,17,0,15,10,11,0,1,13,16,12,4,10
db 11,0,1,15,144,0,4,10,17,0,6,12,1,11,4,12,4,19,17,0,6,10
db 1,11,4,10,4,19,17,0,2,10,2,0,2,19,1,11,4,19,4,10,17,0
db 1,10,1,11,2,0,2,10,2,11,7,19,17,0,1,19,1,11,3,0,1,19
db 2,11,1,20,2,19,4,10,17,0,1,10,1,11,1,10,2,0,2,10,2,11
db 6,19,10,0,1,15,1,0,1,15,4,0,2,11,1,19,4,0,2,11,6,19
db 10,0,1,16,1,12,1,17,4,0,2,11,1,19,4,0,2,11,34,19,$FF

;Monsters
db 0,0
; Room name
db CHAR_T, CHAR_H + LC, CHAR_E + LC, 255
db CHAR_H, CHAR_O + LC, CHAR_L + LC, CHAR_E + LC, 0
; Gems
db 3,64,20,8,21,48,3,64,20,8,15,120

ROOM_38:
db 4,0,1,21,31,0,1,21,31,0,1,21,31,0,1,21,31,0,1,21,31,0
db 1,21,31,0,1,21,16,0,1,22,4,23,1,21,4,23,1,24,17,23,1,25
db 8,0,1,21,4,0,1,26,26,0,1,21,4,0,1,26,26,0,1,21,4,0
db 1,26,26,0,1,21,4,0,1,26,26,0,1,21,4,0,1,26,26,0,1,21
db 4,0,1,26,16,0,1,27,14,23,1,28,64,0,9,23,1,21,8,23,1,25
db 22,0,1,21,22,0,$FF

;Monsters
db 4,0
db 8, 76, DATA_SNAKE, DATA_SNAKE>>8, 1
db 48, 102, DATA_SNAKE, DATA_SNAKE>>8, 0
db 88, 76, DATA_SNAKE, DATA_SNAKE>>8, 1
db 176, 80, DATA_SNAKE, DATA_SNAKE>>8, 1
; Room name
db CHAR_S, CHAR_N + LC, CHAR_A + LC, CHAR_K + LC, CHAR_E + LC, CHAR_SPACE
db CHAR_Z, CHAR_O + LC, CHAR_N + LC, CHAR_E + LC, 0
; Gems
db 10,32,4,80,9,80,29,72,4,80,9,80


ROOM_5:
db 3,29,3,0,2,29,4,0,1,29,6,0,3,29,10,0,3,29,3,0,2,29
db 3,0,3,29,2,0,2,29,1,0,3,29,3,0,2,29,1,0,1,29,3,0
db 3,29,3,0,2,29,2,0,5,29,1,0,11,29,1,0,3,29,1,0,42,29
db 1,30,1,31,1,32,9,29,1,30,1,31,1,32,10,29,1,30,1,31,1,32
db 4,29,1,30,1,31,1,32,3,29,1,30,1,31,1,32,3,29,1,30,1,31
db 1,32,2,29,1,30,1,31,1,32,12,29,1,30,1,31,1,32,9,29,1,30
db 1,31,1,32,39,29,90,0,1,33,11,0,1,33,19,0,1,34,5,0,1,29
db 5,0,1,34,11,0,22,29,24,0,2,29,14,0,1,33,15,0,2,29,7,0
db 1,33,6,0,1,34,6,0,1,33,4,0,1,33,3,0,2,29,7,0,1,34
db 3,0,6,29,4,0,1,34,4,0,1,34,3,0,10,29,3,0,6,29,3,0
db 10,29,$FF 

;Monsters
db 0,0
; Room name
db CHAR_P, CHAR_R + LC, CHAR_I + LC, CHAR_N + LC, CHAR_C + LC, CHAR_E + LC, CHAR_SPACE
db CHAR_Z, CHAR_N + LC, CHAR_E + LC, CHAR_D + LC, CHAR_W + LC, CHAR_A + LC, CHAR_R + LC
db CHAR_D + LC, CHAR_SPACE, CHAR_S, CHAR_T + LC, CHAR_R + LC, CHAR_E + LC, CHAR_E + LC, CHAR_T + LC, 0
; Gems
db 3,120,3,120,3,120,30,120,30,120,30,120

ROOM_6:
db 6,0,1,29,4,0,3,29,18,0,2,29,3,0,3,29,3,0,3,29,18,0
db 2,29,2,0,5,29,2,0,3,29,1,0,1,29,4,0,1,29,1,0,1,29
db 3,0,1,29,1,0,1,29,3,0,2,29,1,0,7,29,1,0,5,29,4,0
db 3,29,3,0,3,29,3,0,2,29,1,0,13,29,3,0,11,29,2,0,16,29
db 2,0,1,29,1,0,3,29,3,0,3,29,1,0,1,29,1,0,23,29,3,0
db 38,29,74,0,1,35,1,36,4,0,1,35,1,36,24,0,1,37,1,38,1,39
db 3,0,1,37,1,38,1,39,11,0,27,29,4,0,3,29,28,0,4,29,27,0
db 5,29,4,0,1,35,1,36,7,0,1,35,1,36,3,0,1,35,1,36,6,0
db 6,29,4,0,1,37,1,38,1,39,6,0,1,37,1,38,1,39,2,0,1,37
db 1,38,1,39,4,0,39,29,$FF 

;Monsters
db 0,0
; Room name
db CHAR_M, CHAR_O + LC, CHAR_T + LC, CHAR_O + LC, CHAR_R + LC, CHAR_W + LC, CHAR_A + LC
db CHAR_Y + LC, CHAR_SPACE, CHAR_T, CHAR_R + LC, CHAR_A + LC, CHAR_F + LC, CHAR_F + LC
db CHAR_I + LC, CHAR_C + LC, 0
; Gems
db 4,80,16,128,30,72,4,80,16,128,30,72

ROOM_17:

db 108,0,1,40,24,0,1,40,2,44,1,0,1,40,1,0,1,40,1,41,3,0
db 1,44,21,0,2,41,1,0,1,41,1,40,2,41,5,40,4,0,2,40,2,0
db 1,40,1,0,1,40,1,0,2,40,4,0,1,42,9,0,3,41,1,43,1,40
db 2,0,1,40,2,41,2,0,1,41,1,44,1,41,1,44,1,41,5,0,1,42
db 11,0,3,41,2,40,3,41,2,0,1,41,1,40,1,43,1,40,1,41,5,0
db 3,40,1,0,1,44,1,0,1,42,1,0,1,42,4,0,1,43,2,41,1,43
db 1,41,1,42,3,0,1,43,1,41,3,43,1,0,4,40,3,41,3,40,1,42
db 1,0,1,42,5,0,1,43,2,41,1,43,2,42,3,0,1,41,1,0,1,41
db 2,0,1,41,1,43,3,41,1,43,1,41,1,43,2,0,1,42,4,40,4,0
db 1,45,1,46,3,42,8,0,3,43,1,0,3,43,3,0,1,42,10,0,2,42
db 9,0,1,43,9,0,1,42,10,0,1,42,10,0,1,43,9,0,1,42,10,0
db 1,42,10,0,1,43,1,0,1,42,4,40,2,0,4,40,19,0,1,43,1,0
db 1,42,22,0,1,44,6,0,1,43,1,0,1,42,13,0,1,44,4,40,3,0
db 8,40,1,43,16,40,1,41,1,43,1,41,1,43,2,0,1,40,1,41,1,43
db 2,41,1,43,1,41,1,43,1,41,$FF 

;Monsters
db 3,0
db 56, 119, DATA_GHOST, DATA_GHOST>>8, 1
db 152, 111, DATA_GHOST, DATA_GHOST>>8, 1
db 216, 111, DATA_GHOST, DATA_GHOST>>8, 1
; Room name
db CHAR_G, CHAR_H + LC, CHAR_O + LC, CHAR_S + LC, CHAR_T + LC, CHAR_SPACE, CHAR_S
db CHAR_P + LC, CHAR_O + LC, CHAR_T + LC, 0
; Gems
db 5,24,14,24,27,24,29,24,23,64,12,104







DATA_ROOM_LIST:
db ROOM_21>>8, ROOM_21, ROOM_54>>8, ROOM_54, ROOM_5>>8, ROOM_5, ROOM_6>>8, ROOM_6
db ROOM_38>>8, ROOM_38, ROOM_62>>8, ROOM_62, ROOM_17>>8, ROOM_17, ROOM_17>>8, ROOM_17

 
;==============================================================
; Utility Functions
;==============================================================
 
;--------------------------------------------------------------
PROC
proc_clear_screen_pixels
;--------------------------------------------------------------
    ; IN: -
    ; OUT: -
    ; Affects hl, de, bc
 
    ld hl, SCREEN_PIXEL_START
    ld de, SCREEN_PIXEL_START + 1
    ld bc, SCREEN_PIXEL_SIZE - 1
    ld (hl), 0
    ldir
ret
ENDP
 
;--------------------------------------------------------------
PROC
proc_fill_screen_attribute:
;--------------------------------------------------------------
    ; IN:   a = attribute
    ; OUT:  -  
    ; AFFECTS: hl, de, bc
 
    ld hl, SCREEN_ATTRIBUTE_START
    ld de, SCREEN_ATTRIBUTE_START + 1
    ld bc, SCREEN_ATTRIBUTE_SIZE - 1
    ld (hl), a
    ldir
ret
ENDP
 
;-------------------------------------------------------------
PROC
proc_get_screen_attribute_address:
;-------------------------------------------------------------
    ; IN: b = y-cell coord (0..23), c: x-cell coord (0..31)
    ; OUT: hl = attribute address
    ; AFFECTS: hl, de, a
   
    ; Explanation
    ; b = -- -- -- y4 y3 y2 y1 y0
    ; c = -- -- -- x4 x3 x2 x1 x0
    ; hl = addr + y * 32 + x = addr + de
    ; y7 y6 y5 and x7 x6 x5 are all zero since x,y<32
    ; de = -- -- -- -- -- -- y4 y3|y2 y1 y0 x4 x3 x2 x1 x0
    ;      -----------d-----------|------------e----------
 
    ; put y4 y3 into lower two bits in d
    ld a, b
    and $18
    sra a
    sra a
    sra a
    ld d, a
 
    ; put y2..y0 in upper bits of e
    ld a, b
    sla a
    sla a
    sla a
    sla a
    sla a
 
    ; put x4...x0 in lower bits of e
    add a, c
    ld e, a
 
    ld hl, SCREEN_ATTRIBUTE_START
    add hl, de
ret
ENDP
 
;-------------------------------------------------------------
PROC
proc_get_screen_pixel_address:
;-------------------------------------------------------------
    ; IN: b = y-pixel coord (0..191), c: x-cell coord (0..31)
    ; OUT: hl = screen address
    ; AFFECTS: hl, de, a
 
    ld a, b         ; Work on the upper byte of the address
    and %00000111   ; a = Y2 Y1 y0
    or %01000000    ; first three bits are always 010
    ld h,a          ; store in h
    ld a,b          ; get bits Y7, Y6
    rra             ; move them into place
    rra             ;
    rra             ;
    and %00011000   ; mask off
    or h            ; a = 0 1 0 Y7 Y6 Y2 Y1 Y0
    ld h,a          ; calculation of h is now complete
    ld a,b          ; get y
    rla             ;
    rla             ;
    and %11100000   ; a = y5 y4 y3 0 0 0 0 0
    ld l,a          ; store in l
    ld a,c          ;
    and %00011111   ; a = X4 X3 X2 X1
    or l            ; a = Y5 Y4 Y3 X4 X3 X2 X1
    ld l,a          ; calculation of l is complete
ret
ENDP
 

;-------------------------------------------------------------
PROC
proc_get_cell_coord:
;-------------------------------------------------------------
    ; IN: b = y-pixel coord (0..191), c: x-pixel coord (0..248)
    ; OUT: b = y-cell coord (0..23), c: x-pixel coord (0..31)
    ; AFFECTS: a, b, c
	ld a,b
	ccf
	and %11111000
	rra
	rra
	rra
	ld b,a
	ld a,c
	and %11111000
	rra
	rra
	rra
	ld c,a
ret
ENDP

;-------------------------------------------------------------
PROC
proc_get_cell_index:
;-------------------------------------------------------------
    ; IN: b = y-cell coord (0..23), c: x-pixel coord (0..31)
    ; OUT: hl = cell index (0..767)
    ; AFFECTS: a, b, c, hl
	ld a,b
	ccf
	and %11111000
	rra
	rra
	rra
	ld b,a
	ld a,c
	and %11111000
	rra
	rra
	rra
	ld c,a
ret
ENDP


;-------------------------------------------------------------
PROC
proc_move_player_right:
;-------------------------------------------------------------
	inc b
	inc d
	ld hl, DATA_ZIGGY_RIGHT
	ld (PLAYER_SPRITE), hl
ret
ENDP

;-------------------------------------------------------------
PROC
proc_move_player_left:
;-------------------------------------------------------------
	dec b
	inc d
	ld hl, DATA_ZIGGY_LEFT
	ld (PLAYER_SPRITE), hl
ret
ENDP

;-------------------------------------------------------------
PROC
proc_move_player_out_walls:
;-------------------------------------------------------------
	ld a,(PLAYER_X)
	rra
	rra
	rra
	and %00011111
	ld c,a
	ld a,(PLAYER_Y)
	add a,15
	ld b,a
	push bc
	call proc_get_block_properties
	bit BLOCK_COLLISION_BIT,a
	jr nz, proc_move_player_out_walls_right
	pop bc
	push bc
	ld a,b
	sub 8
	ld b,a
	call proc_get_block_properties
	bit BLOCK_COLLISION_BIT,a
	jr z, proc_move_player_out_walls2
proc_move_player_out_walls_right:
	ld a,(PLAYER_X)
	add a,1
	ld (PLAYER_X),a
proc_move_player_out_walls2:
	pop bc
	push bc
	inc c
	push bc
	call proc_get_block_properties
	pop bc
	bit BLOCK_COLLISION_BIT,a
	jr nz, proc_move_player_out_walls_left
	ld a,b
	sub 8
	ld b,a
	call proc_get_block_properties
	bit BLOCK_COLLISION_BIT,a
	jr z, proc_move_player_out_walls3
proc_move_player_out_walls_left:
	ld a,(PLAYER_X)
	dec a
	ld (PLAYER_X),a
proc_move_player_out_walls3:
	pop bc
	ld a,b
	sub 12
	ret c
	ld b,a
	call proc_get_block_properties
	bit BLOCK_COLLISION_BIT,a
	ret z
	ld a,(PLAYER_VEL)
	ld a,1
	ld (PLAYER_VEL),a
ret
ENDP

;-------------------------------------------------------------
PROC
proc_check_transition:
;-------------------------------------------------------------
	ld a,(PLAYER_X)
	ld b,a
	ld a, 245
	cp b
	jr nc, proc_check_transition2
	ld a,8
	ld (PLAYER_X),a
	ld a,(CURRENT_ROOM_NUMBER)
	inc a
	and MAP_WIDTH-1
	ld c,a
	ld a,(CURRENT_ROOM_NUMBER)
	and ROOM_BITS & (~(MAP_WIDTH-1))
	add a,c
	ld (CURRENT_ROOM_NUMBER),a
	call proc_load_map
	ret
proc_check_transition2:
	ld a,2
	cp b
	jr c, proc_check_transition3
	ld a,240
	ld (PLAYER_X),a
	ld a,(CURRENT_ROOM_NUMBER)
	dec a
	and MAP_WIDTH-1
	ld c,a
	ld a,(CURRENT_ROOM_NUMBER)
	and ROOM_BITS & (~(MAP_WIDTH-1))
	add a,c
	ld (CURRENT_ROOM_NUMBER),a
	call proc_load_map
	ret
proc_check_transition3:
	ld a,(PLAYER_Y)
	ld b,a
	ld a,128
	cp b
	jr nc, proc_check_transition4
	ld a,160
	cp b
	jr c, proc_check_transition4
	ld a,0
	ld (PLAYER_Y),a
	ld a,(CURRENT_ROOM_NUMBER)
	sub MAP_WIDTH
	and ROOM_BITS
	ld (CURRENT_ROOM_NUMBER),a
	call proc_load_map
	ret
proc_check_transition4:
	ld a,244
	cp b
	ret nc
	ld a, 118
	ld (PLAYER_Y),a
	ld a,(CURRENT_ROOM_NUMBER)
	add a,MAP_WIDTH
	and ROOM_BITS
	ld (CURRENT_ROOM_NUMBER),a
	call proc_load_map
ret
ENDP

;-------------------------------------------------------------
PROC
proc_check_player_collect:
;-------------------------------------------------------------
	ld a,(PLAYER_X)
	add a,4
	rra
	rra
	rra
	and %00011111
	ld c,a
	ld a,(PLAYER_Y)
	add a,16
	ld e,a
	ld ix,CURRENT_ROOM_GEMS
	ld d,1
proc_check_player_collect_loop:
	ld a,(ix)
	cp $FF
	jr z,proc_check_player_collect_loop_end
	cp c
	jr nz,proc_check_player_collect_loop_end
	ld a,(ix+1)
	cp e
	jr nc,proc_check_player_collect_loop_end
	add a,4
	ld hl,PLAYER_Y
	cp (hl)
	jr c,proc_check_player_collect_loop_end
	ld hl,COLLECTED_GEMS
	ld a,(CURRENT_ROOM_NUMBER)
	ld b,0
	ld c,a
	add hl,bc
	ld a,(hl)
	or d
	ld (hl),a
	call proc_set_gem_data
	ld a,(PLAYER_GEMS)
	add a,1
	daa
	ld (PLAYER_GEMS),a
	call proc_draw_values_text
proc_check_player_collect_loop_end:
	inc ix
	inc ix
	xor a
	rl d
	ld a,d
	and %00111111
	jr nz, proc_check_player_collect_loop
ret
ENDP

;-------------------------------------------------------------
PROC
proc_check_player_death:
;-------------------------------------------------------------
	ld ix,MONSTER_START
	ld a,(PLAYER_X)
	add a,6
	ld c,a
	ld a,(PLAYER_Y)
	add a,16
	ld b,a
	ld a,(BUG_COUNT)
	ld d,a
	ld a,(WALKER_COUNT)
	add a,d
	cp 0
	jr z,proc_check_player_death_loop_end
	ld d,a
proc_check_player_death_loop:
	push de
	ld de,(PLAYER_POS)
	ld a,(ix)
	cp c
	jr nc,proc_check_player_death_end
	add a,14
	cp e
	jr c,proc_check_player_death_end
	ld a,(ix+1)
	cp b
	jr nc,proc_check_player_death_end
	add a,8
	cp d
	jr c,proc_check_player_death_end
	ld a,(PLAYER_LIVES)
	dec a
	ld (PLAYER_LIVES),a
	ld a,(PLAYER_ENTRY_X)
	ld (PLAYER_X),a
	ld a,(PLAYER_ENTRY_Y)
	ld (PLAYER_Y),a
	call proc_load_map
	pop de
	jr proc_check_player_death_loop_end
proc_check_player_death_end:
	ld de,MONSTER_SIZE
	add ix,de
	pop de
	dec d
	jr nz,proc_check_player_death_loop
	
proc_check_player_death_loop_end:
ret
ENDP

;-------------------------------------------------------------
PROC
proc_climb_ladder:
;-------------------------------------------------------------
	ld a,(PLAYER_X)
	rra
	rra
	rra
	and %00011111
	ld c,a
	ld a,(PLAYER_Y)
	add a,17
	ld b,a
	push bc
	call proc_get_block_properties
	pop bc
	bit BLOCK_LADDER_BIT,a
	jr nz,proc_climb_ladder_on
	inc c
	push bc
	call proc_get_block_properties
	pop bc
	bit BLOCK_LADDER_BIT,a
	ret z
proc_climb_ladder_on:
	ld a,0
	ld (PLAYER_VEL),a
	
	push bc
	ld bc,&FBFE
	in a,(c)
	bit 1,a
	pop bc
	jr nz, proc_climb_ladder2
	ld a,b
	sub 18
	ld b,a
	call proc_get_block_properties
	bit BLOCK_COLLISION_BIT,a
	ret nz
	ld a,254
	ld (PLAYER_VEL),a
	ret
proc_climb_ladder2:
	ld a,b
	add a,6
	ld b,a
	call proc_get_block_properties
	bit BLOCK_COLLISION_BIT,a
	ret nz
	ld bc, &FDFE
	in a,(c)
	bit 1,a
	ret nz
	ld a,1
	ld (PLAYER_VEL),a
ret
ENDP

;-------------------------------------------------------------
PROC
proc_update_player:
;-------------------------------------------------------------
	; AFFECTS: hl, de, a, b
	ld bc, &FDFE
	ld d,0
	in a,(c)
	ld (SCRATCH_ADDRESS1),a
	bit 2,a
	ld hl, PLAYER_X
	ld b,(hl)
	call z, proc_move_player_right
	bit 0,a
	call z, proc_move_player_left
proc_update_player_vel:
	ld hl, PLAYER_X
	ld (hl),b
	inc hl
	ld b,(hl)
	inc hl
	ld a,(hl)
	push hl
	ld hl,SWAP_BIT
	add a,(hl)
	pop hl
	
	cp 5
	jr nz, proc_update_player_cap
	ld a,4
proc_update_player_cap:
	push de
	push bc
	push hl
	push af
	add a,1
	ld a,(PLAYER_X)
	add a,4
	rra
	rra
	rra
	and %00011111
	ld c,a	
	ld a,(PLAYER_Y)
	add a,16
	and %11111000
	ld b,a
	call proc_get_block_properties
	ld d,a
	pop af
	ld (SCRATCH_ADDRESS2),a
	bit BLOCK_COLLISION_BIT,d
	jr z, proc_update_player_reset_vel
	pop hl
	pop bc
	ld a,b
	and %11111100
	ld b,a
	push bc
	push hl
	ld a,0
	ld (SCRATCH_ADDRESS2),a
	ld bc,&FBFE
	in a,(c)
	bit 1,a
	jr nz, proc_update_player_reset_vel
	ld a,251
	ld (SCRATCH_ADDRESS2),a
	ld a,1
	ld (SWAP_BIT),a
	
proc_update_player_reset_vel:
	ld a,(SCRATCH_ADDRESS2)
	ld (PLAYER_VEL),a
	call proc_climb_ladder
	ld a,(PLAYER_VEL)
	
	pop hl
	pop bc
	pop de
	ld (hl),a
	cp 127
	jr nc,proc_update_player_skip_reduce
	inc a
	rra
	and %00001111
proc_update_player_skip_reduce:
	dec hl
	add a,b
	ld (hl),a
	
proc_update_player_anim:
	ld hl,PLAYER_ANIM
	ld a,d
	cp 0
	jr nz,proc_update_player_anim_r
	ld (hl),0
	jr proc_update_player_end
proc_update_player_anim_r:
	inc (hl)
	ld a,16
	cp (hl)
	jr nz, proc_update_player_end
	ld (hl),0
proc_update_player_end:
	call proc_move_player_out_walls
	call proc_check_transition
ret
ENDP


;-------------------------------------------------------------
PROC
proc_update_bugs:
;-------------------------------------------------------------
	push ix
	ld ix,MONSTER_X
	ld a,(BUG_COUNT)
	cp 0
	jr z,proc_update_bugs_end
proc_update_bugs_loop:
	push af
	ld a,(ix)
	rra
	rra
	rra
	and %00011111
	ld c,a
	ld a,(ix+4)
	cp 0
	jr nz, proc_update_bugs2
	ld a,(ix+1)
	inc a
	ld (ix+1),a
	add a,17
	ld b,a
	jr proc_update_bugs3
proc_update_bugs2:
	ld a,(ix+1)
	dec a
	ld (ix+1),a
	sub 2
	ld b,a
proc_update_bugs3:
	call proc_get_block_properties
	ld a,(hl)
	cp 0
	jr nz, proc_update_bugs4
	ld a,(ix+1)
	cp 1
	jr z, proc_update_bugs4
	cp 127
	jr z, proc_update_bugs4
	jr proc_update_bugs_loop_end
proc_update_bugs4:
	ld a,(ix+4)
	ld b,a
	ld a,1
	sub b
	ld (ix+4),a
proc_update_bugs_loop_end
	ld de,5
	add ix,de
	pop af
	dec a
	jr nz,proc_update_bugs_loop
proc_update_bugs_end:
	pop ix
ret
ENDP


;-------------------------------------------------------------
PROC
proc_update_walkers:
;-------------------------------------------------------------
	ld a,(BUG_COUNT)
	ld b,a
	rla
	rla
	add a,b
	ld b,0
	ld c,a
	push ix
	ld ix,MONSTER_POS 
	add ix,bc ; ix now contains the first address of walkers
	ld a,(WALKER_COUNT)
	cp 0
	jr z,proc_update_walkers_loop_end
	ld b,a
proc_update_walkers_loop:
	push bc
	ld a,(ix+4)
	cp 0
	ld a,(ix)
	jr nz, proc_update_walkers_2
	inc a
	ld (ix),a
	add a,9
	jr proc_update_walkers_3 
proc_update_walkers_2:
	dec a
	ld (ix),a
	dec a
proc_update_walkers_3:
	rra
	rra
	rra
	and %00011111
	ld c,a
	ld a,(ix+1)
	add a,9
	ld b,a
	call proc_get_block_index
	ld a,(hl)
	cp 0
	jr z, proc_update_walkers_end
	ld b,(ix+4)
	ld a,1
	sub b
	ld (ix+4),a
proc_update_walkers_end:
	pop bc
	ld de,MONSTER_SIZE
	add ix,de
	dec b
	jr nz,proc_update_walkers_loop
proc_update_walkers_loop_end:
	

	pop ix
ret
ENDP





;-------------------------------------------------------------
PROC
proc_draw_sprite:
;-------------------------------------------------------------
	;Input: b: y-position, c: x-position, d: sprite attribute ix: sprite address
	;Affects: Everything
	
;Get sprite address from x value
	ld d,(ix)
	inc ix
	
	ld a,c
	rla
	rla
	rla
	rla
	rla
	and %11100000
	push bc
	ld b,0
	ld c,a
	add ix,bc ;ix now contains the sprite address
	pop bc
	ld a,c
	rra
	rra
	rra
	and %00011111
	ld c,a
	
	push bc
	push de
	ld a,b
	rra
	rra
	rra
	and %00011111
	ld b,a
	call proc_get_screen_attribute_address
	pop de
	ld bc,32
	ld a,d
	ld (hl),a
	inc hl
	ld (hl),a
	add hl,bc
	ld (hl),a
	dec hl
	ld (hl),a
	add hl,bc
	ld (hl),a
	inc hl
	ld (hl),a
	pop bc
	
	ld d,16
proc_draw_sprite_loop:
	push de
	call proc_get_screen_pixel_address
	ld a,(ix)
	ld (hl),a
	inc hl
	inc ix
	ld a,(ix)
	ld (hl),a	
	inc hl
	inc ix
	pop de
	inc b
	dec d
	jr nz, proc_draw_sprite_loop
ret
ENDP


;-------------------------------------------------------------
PROC
proc_draw_sprites:
;-------------------------------------------------------------
	; AFFECTS: everything
	; Draws player
	

	ld bc,(PLAYER_POS)
	ld ix,(PLAYER_SPRITE)
	ld d,BLACK_PAPER | PURPLE_INK | BRIGHT
	call proc_draw_sprite	
	
	ld iy,MONSTER_X
	ld a,(BUG_COUNT)
	ld b,a
	ld a,(WALKER_COUNT)
	add a,b
	cp 0
	jr z,proc_draw_sprites_bugs_end
	ld b,a
	ld a,0
	ld (SCRATCH_ADDRESS3),a
proc_draw_sprites_loop:
	ld a,b
	push bc
	ld a,(iy)
	ld c,a
	ld a,(iy+1)
	ld b,a
	ld a,(iy+2)
	ld (CURRENT_SPRITE),a
	ld a,(iy+3)
	ld (CURRENT_SPRITE+1),a
	ld ix,(CURRENT_SPRITE)
	ld d,BLACK_PAPER | YELLOW_INK | BRIGHT
	call proc_draw_sprite
	ld bc,MONSTER_SIZE
	add iy,bc
	pop bc
	dec b
	jr nz,proc_draw_sprites_loop
proc_draw_sprites_bugs_end:
ret
ENDP


;-------------------------------------------------------------
PROC
proc_get_block_index:
;-------------------------------------------------------------
    ; IN: b = y-pixel coord (0..191), c: x-cell coord (0..31)
    ; OUT: hl = block address
	; AFFECTS: a,bc,hl
	ld a,b
	and %11111000
	ld b,0
	ld hl,(CURRENT_ROOM_ADDRESS)
	rla
	rl b
	rla
	rl b
	add a,c
	ld c,a
	xor a
	adc a,b
	add hl,bc
ret
ENDP	

;-------------------------------------------------------------
PROC
proc_get_block_properties:
;-------------------------------------------------------------
    ; IN: b = y-pixel coord (0..191), c: x-cell coord (0..31)
    ; OUT: a = block properties
	; AFFECTS: a,bc,hl
	call proc_get_block_index
	ld c,(hl)
	ld b,0
	ld hl,DATA_BLOCK_PROPERTIES
	add hl,bc
	ld a,(hl)
ret
ENDP

;-------------------------------------------------------------
PROC
proc_draw_block:
;-------------------------------------------------------------
	; AFFECTS: everything
	call proc_get_screen_attribute_address
	ld (SCRATCH_ADDRESS1),hl
	ld a,b
	ld b,0
	rla
	rla
	rla
	and %11111000
	ld b,a
	call proc_get_screen_pixel_address
	push hl
	call proc_get_block_index
	ld a,(hl) ; Get block number
	ld hl,DATA_BLOCK_ATTRIBS
	push af ; Store block number
	push bc
	ld b,0
	ld c,a
	ld de,(SCRATCH_ADDRESS1)
	add hl,bc
	ld a,(hl)
	ld (de),a
	pop bc
	pop af
	ld bc,0
	rla
	rl b
	rla
	rl b
	rla
	rl b
	ld c,a
	ld hl,BLOCK_0
	add hl,bc
	ld b,h
	ld c,l
	pop hl
	ld d,8
proc_draw_block_loop:
	ld a,(bc)
	ld (hl),a
	inc bc
	push de
	ld de,32*8
	add hl,de
	pop de
	dec d
	jr nz, proc_draw_block_loop
ret
ENDP
	
;-------------------------------------------------------------
PROC
proc_draw_blocks:
;-------------------------------------------------------------
	; AFFECTS: everything
	ld bc,0
proc_draw_blocks_loop:
	push bc
	call proc_draw_block
	pop bc
	inc c
	ld a,32
	cp c
	jr nz,proc_draw_blocks_loop
	ld c,0
	inc b
	ld a,ROOM_HEIGHT
	cp b
	jr nz,proc_draw_blocks_loop
ret
ENDP

;-------------------------------------------------------------
PROC
proc_redraw_blocks:
;-------------------------------------------------------------
	; AFFECTS: everything
	ld bc,(PLAYER_POS)
	ld a,b
	rra
	rra
	rra
	and %00011111
	ld b,a
	ld a,c
	rra
	rra
	rra
	and %00011111
	ld c,a
	push bc
	call proc_draw_block
	pop bc
	inc c
	push bc
	call proc_draw_block
	pop bc
	inc b
	push bc
	call proc_draw_block
	pop bc
	dec c
	push bc
	call proc_draw_block
	pop bc
	inc b
	push bc
	call proc_draw_block
	pop bc
	inc c
	call proc_draw_block
	
	ld iy,MONSTER_START
	ld a,(BUG_COUNT)
	cp 0
	jr z, proc_redraw_blocks_bugs_end
	ld b,a
proc_redraw_blocks_loop:
	push bc
	ld a,(iy)
	rra
	rra
	rra
	and %00011111
	ld c,a
	ld a,(iy+1)
	dec a
	ld b,a
	ld a,(iy+4)
	cp 0
	jr z,proc_redraw_blocks2
	ld a,b
	add a,17
	ld b,a
proc_redraw_blocks2:
	push bc
	call proc_get_block_index
	pop bc
	ld (CURRENT_SPRITE),hl
	ld ix,(CURRENT_SPRITE)
	call proc_get_screen_pixel_address
	ld a,(ix)
	ld (hl),a
	inc ix
	inc hl
	ld a,(ix)
	ld (hl),a
	ld de,MONSTER_SIZE
	add iy,de
	pop bc
	dec b
	jr nz,proc_redraw_blocks_loop
proc_redraw_blocks_bugs_end:
	ld a,(WALKER_COUNT)
	cp 0
	jr z,proc_redreaw_blocks_walkers_end
	ld b,a
proc_redraw_blocks_loop2:
	push bc
	ld a,(iy)
	and %00000111
	jr nz, proc_redraw_blocks_loop2_end
	ld a,(iy)
	dec a
	rra
	rra
	rra
	and %00011111
	ld c,a
	ld a,(iy+1)
	rra
	rra
	rra
	and %00011111
	ld b,a
	inc b
	push bc
	call proc_draw_block
	pop bc
	inc b
	call proc_draw_block
proc_redraw_blocks_loop2_end:
	pop bc
	ld de, 5
	add iy,de
	dec b
	jr nz,proc_redraw_blocks_loop2
proc_redreaw_blocks_walkers_end:
ret
ENDP

;-------------------------------------------------------------
PROC
proc_draw_gems:
;-------------------------------------------------------------
	; AFFECTS: everything
	push iy
	push ix
	
	ld a,(GEM_COLOR)
	inc a
	and %00000111
	jr nz,proc_draw_gems2
	inc a
proc_draw_gems2:
	or BLACK_PAPER
	ld (GEM_COLOR),a
	
	ld ix,CURRENT_ROOM_GEMS
	ld b,6
proc_draw_gems_loop:
	push bc
	ld a,$FF
	cp (ix)
	jr z, proc_draw_gems_loop_end
	ld b,(ix+1)
	ld c,(ix)
	push bc
	ld a,b
	rra
	rra
	rra
	and %00011111
	ld b,a
	call proc_get_screen_attribute_address
	ld a, (GEM_COLOR)
	ld (hl),a
	pop bc
	call proc_get_screen_pixel_address
	ld de, 32*8
	ld b,8
	ld iy,DATA_GEM
proc_draw_gems_loop2:
	ld a,(iy)
	ld (hl),a
	inc iy
	add hl,de
	dec b
	jr nz,proc_draw_gems_loop2
proc_draw_gems_loop_end:
	inc ix
	inc ix
	pop bc
	dec b
	jr nz, proc_draw_gems_loop
	
	pop ix
	pop iy
ret
ENDP
	
;-------------------------------------------------------------
PROC
proc_set_gem_data:
;-------------------------------------------------------------
	; AFFECTS: a, bc, hl
	ld b,0
	ld a,(CURRENT_ROOM_NUMBER)
	ld c,a
	ld hl,COLLECTED_GEMS
	add hl,bc
	ld a,(hl) ; a contains gem bits and such
	ld c,6
	ld hl,CURRENT_ROOM_GEMS
proc_set_gem_loop:
	bit 0,a
	jr z,proc_set_gem_loop_end
	ld (hl),$FF
proc_set_gem_loop_end:
	inc l
	inc l
	rra
	dec c
	jr nz,proc_set_gem_loop
ret
ENDP

;-------------------------------------------------------------
PROC
proc_draw_text:
;-------------------------------------------------------------
	; Input: b: y-position, c: x-cell, a: character
	; AFFECTS: everything
	ld d,0
	rla
	rl d
	rla
	rl d
	rla
	rl d
	and %11111000
	ld e,a
	ld ix,$3D00
	add ix,de
	call proc_get_screen_pixel_address
	ld b,8
	ld de,32*8
proc_draw_text_loop:
	ld a,(ix)
	ld (hl),a
	inc ix
	add hl,de
	dec b
	jr nz,proc_draw_text_loop
ret
ENDP

;-------------------------------------------------------------
PROC
proc_draw_string:
;-------------------------------------------------------------
	; Input: b: y-position, c: x-cell, hl: string address
	; AFFECTS: everything
	ld a,(hl)
	cp 0
	ret z
	push hl
	push bc
	cp CHAR_SPACE
	call nz, proc_draw_text
	pop bc
	pop hl
	inc hl
	inc c
	jr proc_draw_string
ENDP


;-------------------------------------------------------------
PROC
proc_draw_values_text:
;-------------------------------------------------------------
	ld a,(PLAYER_GEMS)
	and $0F
	add a,CHAR_ZERO
	ld (PLAYER_GEM_TEXT+1),a
	ld a,(PLAYER_GEMS)
	rra
	rra
	rra
	rra
	and $0F
	add a,CHAR_ZERO
	ld (PLAYER_GEM_TEXT),a
	
	ld bc,$A003
	ld hl,DATA_LIVES_STRING
	call proc_draw_string
	inc hl
	ld c, 20
	call proc_draw_string
ret
ENDP

;-------------------------------------------------------------
PROC
proc_load_map:
;-------------------------------------------------------------
	; Input: None
	; AFFECTS: everything	
	ld a,(PLAYER_X)
	ld (PLAYER_ENTRY_X),a
	ld a,(PLAYER_Y)
	ld (PLAYER_ENTRY_Y),a
	
	xor a
	ld hl, $50C0
	ld bc,$0820
	ld de,32*7
proc_load_map_loop:
	ld (hl),a
	inc hl
	dec c
	jr nz,proc_load_map_loop
	ld c,32
	add hl,de
	dec b
	jr nz,proc_load_map_loop
	
	ld hl,$5A40
	ld bc,$0100
	ld a,WHITE_INK | BLUE_PAPER
proc_load_map_loop_fill:	
	ld (hl),a
	inc hl
	dec c
	jr nz,proc_load_map_loop_fill
	dec b
	jr nz,proc_load_map_loop_fill
	
	ld b,0
	ld a,(CURRENT_ROOM_NUMBER)
	rla
	and ROOM_BITS << 1
	ld c,a
	ld hl,DATA_ROOM_LIST
	add hl,bc
	ld b,(hl)
	inc hl
	ld c,(hl)
	;ld (CURRENT_ROOM_ADDRESS),bc

	
	ld de,ROOM_START
	ld (CURRENT_ROOM_ADDRESS),de
proc_load_map_loop2:
	ld a,(bc)
	cp $FF
	jr z,proc_load_map_loop2_end
	ld h,a
	inc bc
	ld a,(bc)
proc_load_map_loop3:
	ld (de),a
	inc de
	dec h
	jr nz,proc_load_map_loop3
	inc bc
	jr proc_load_map_loop2
proc_load_map_loop2_end:
	inc bc
	push bc
	call proc_draw_blocks
	pop hl
	;ld bc,ROOM_SIZE
	;add hl,bc
	ld a,(hl)
	ld de,MONSTER_START
	ld (BUG_COUNT),a
	ld b,a
	inc hl
	ld a,(hl)
	ld (WALKER_COUNT),a
	add a,b
	
	ld b,a
	rla
	rla
	add a,b
	ld b,0
	ld c,a
	inc c
	inc hl
	ldir
	dec hl
	ld bc,$B001
	call proc_draw_string
	
	inc hl
	ld bc,12
	ld de,CURRENT_ROOM_GEMS
	ldir
	call proc_set_gem_data
	call proc_draw_values_text
	
	
ret
ENDP

;-------------------------------------------------------------
PROC
proc_play_sound:
;-------------------------------------------------------------
	di
	ld hl,soundstart
	ld d,%00010000
soundloop:	
	ld b,(hl) ; 7
	ld e,8 ; 7
bitloop:
	ld a,b ; 4
	and d ; 4
	out ($FE),a ; 11
	ld c,$1C ; 7
stall:
	dec c ; 4
	jr nz,stall ; 12/7
	rrc b ; 8
	dec e ; 4
	jr z,bitloopend ; 12/7
	ld c,$01 ; 7
stall2:
	dec c ; 4
	jr z,bitloop ; 12/7 
	jr stall2 ; 12/7
bitloopend:
	inc hl ; 6
	ld a,soundend ; 7
	cp l ; 4
	jr nz,soundloop ; 12/7	
	ld a,soundend>>8 ; 7
	cp h ; 4
	jr nz,soundloop ; 12/7
	ei
ret
ENDP



org $8000
;==============================================================
; Initialization
;==============================================================
start:
	ld a, BLUE_PAPER | WHITE_INK
    call proc_fill_screen_attribute
	
	call proc_play_sound
	
	ld hl, PLAYER_POS
	ld a, 200
	ld (hl),a
	ld a, 16
	inc hl
	ld (hl),a
	xor a
	ld (PLAYER_GEMS),a
	inc hl
	ld (hl),a
	ld hl, PLAYER_ANIM
	ld (hl),a
	ld hl, DATA_ZIGGY_RIGHT
	ld (PLAYER_SPRITE), hl
	ld hl, CURRENT_ROOM_NUMBER
	ld (hl),0
	ld a,CHAR_ZERO+3
	ld (PLAYER_LIVES),a
	
	ld hl,COLLECTED_GEMS
	xor a
	ld b,64
start_reset_loop:
	ld (hl),a
	inc hl
	dec b
	jr nz,start_reset_loop
	
	call proc_load_map
loopyboy:
	halt
	call proc_redraw_blocks	
	call proc_update_player
	call proc_draw_sprites
	call proc_draw_gems
	call proc_update_bugs
	call proc_update_walkers
	call proc_check_player_collect
	call proc_check_player_death
	ld a,(SWAP_BIT)
	xor %00000001
	ld (SWAP_BIT),a
	
	ld a,(PLAYER_LIVES)
	cp CHAR_ZERO-1
	jr nz,loopyboy
	jr start
ret
end start

