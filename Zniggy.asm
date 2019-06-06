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
 
org $8000
 
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
 
SCRATCH_ADDRESS1            equ $5CCB
SCRATCH_ADDRESS2            equ $5CCD
SCRATCH_ADDRESS3            equ $5CD3
CURRENT_ROOM_ADDRESS        equ $5CCE
CURRENT_ROOM_NUMBER         equ $5CD0
CURRENT_SPRITE              equ $5CD4
SPRITE_LENGTH               equ $5CD2
BUG_COUNT                   equ $5FFF
WALKER_COUNT                equ $5FFE

PLAYER_POS                  equ $5D00
PLAYER_X                    equ $5D00
PLAYER_Y                    equ $5D01
PLAYER_VEL                  equ $5D02
PLAYER_ANIM                 equ $5D03
PLAYER_SPRITE               equ $5D04
PLAYER_BX                   equ $5D06
PLAYER_BY                   equ $5D07

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
MAP_WIDTH                   equ 2

;==============================================================
; Data
;==============================================================
DATA_TILE_PIXELS:

DATA_SPRITES:
DATA_ZIGGY_RIGHT:
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
 
 
DATA_BLOCK_SPRITES:
BLOCK_0:
db %00000000
db %00000000
db %00000000
db %00000000
db %00000000
db %00000000
db %00000000
db %00000000
BLOCK_1:
db %10110100
db %11111111
db %11111111
db %11111111
db %11111111
db %11111111
db %11111111
db %11111111
BLOCK_2:
db %00000000
db %00000000
db %00000000
db %00000000
db %00000000
db %00000000
db %00000000
db %00000000
BLOCK_3:
db %00011100
db %00111111
db %00111111
db %01111111
db %01111111
db %01111111
db %01111111
db %00111111
BLOCK_4:
db %01110110
db %11111111
db %11111111
db %11111111
db %11111111
db %11111111
db %11111111
db %11111111
BLOCK_5:
db %01100000
db %11111000
db %11111100
db %11111000
db %11111100
db %11111110
db %11111110
db %11111100
BLOCK_6:
db %01111111
db %01111111
db %00111111
db %00111111
db %00111111
db %01111111
db %00111110
db %00111100
BLOCK_7:
db %11111111
db %11111111
db %11111111
db %11111111
db %11111111
db %11111111
db %11111111
db %01001110
BLOCK_8:
db %11111100
db %11111110
db %11111110
db %11111100
db %11111110
db %11111110
db %11111110
db %11001000
DATA_BLOCK_ATTRIBS:
db BLACK_PAPER | BLACK_INK | BRIGHT
db BLACK_PAPER | GREEN_INK | BRIGHT
db GREEN_PAPER | GREEN_INK | BRIGHT
db BLACK_PAPER | WHITE_INK | BRIGHT
db BLACK_PAPER | WHITE_INK | BRIGHT
db BLACK_PAPER | WHITE_INK | BRIGHT
db BLACK_PAPER | WHITE_INK | BRIGHT
db BLACK_PAPER | WHITE_INK | BRIGHT
db BLACK_PAPER | WHITE_INK | BRIGHT

DATA_ROOMS:
ROOM_0:
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,3,4,4,5,0,0,0,0,0,0,0,0,3,4,4,4,4,5,0,0,0,0,0,0,0,3,4,4,5,0,0
db 0,6,7,7,8,0,0,3,4,5,0,0,0,6,7,7,7,7,8,0,0,3,5,0,0,0,6,7,7,8,0,0
db 0,0,0,0,0,0,0,6,7,8,0,0,0,0,0,0,0,0,0,0,0,6,7,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,3,4,4,4,4,5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,6,7,7,7,7,7,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,1,2,2,2,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,1,2,2,2,2,2,2,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,0,0
db 0,0,1,2,2,2,2,2,2,2,2,1,1,1,0,0,0,0,0,0,0,0,0,1,1,1,2,2,2,1,0,0
db 1,1,2,2,2,2,2,2,2,2,2,2,2,2,1,1,1,1,1,1,1,1,1,2,2,2,2,2,2,2,1,1
db 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
db 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
;Monsters
db 7,0
db 64, 70, DATA_BUG, DATA_BUG>>8, 1
db 88, 70, DATA_BUG, DATA_BUG>>8, 1
db 104, 70, DATA_BUG, DATA_BUG>>8, 1
db 120, 70, DATA_BUG, DATA_BUG>>8, 1
db 136, 70, DATA_BUG, DATA_BUG>>8, 1
db 152, 70, DATA_BUG, DATA_BUG>>8, 1
db 168, 70, DATA_BUG, DATA_BUG>>8, 1
db 200, 70, DATA_ZIGGY_LEFT, DATA_ZIGGY_LEFT>>8, 1

ROOM_1:
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,3,4,4,4,4,4,5,0,0,0,0,0,3,4,4,4,4,5,0,0,0,0,0,0,0,3,4,4,5,0,0
db 0,6,7,7,7,7,7,8,0,0,0,0,0,6,7,7,7,7,8,0,0,0,0,0,0,0,6,7,7,8,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,5,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,6,7,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,5,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,6,7,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,1,1,1,2,2,2,2,2,2,2,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,1,2,2,2,2,2,2,2,2,2,2,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,0,0,0,0,0,0,0,0,1,1,1,0,0,0
db 0,0,1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,0,0,0,0,0,1,1,1,2,2,2,1,0,0
db 1,1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,0,0,0,1,1,2,2,2,2,2,2,2,1,1
db 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,0,0,0,2,2,2,2,2,2,2,2,2,2,2
db 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,0,0,0,2,2,2,2,2,2,2,2,2,2,2

db 4,0
db 40, 70, DATA_BUG, DATA_BUG>>8, 1
db 88, 35, DATA_BUG, DATA_BUG>>8, 1
db 184, 35, DATA_BUG, DATA_BUG>>8, 1
db 168, 70, DATA_BUG, DATA_BUG>>8, 1

ROOM_2:
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,3,4,4,4,4,4,4,4,5,0,0,0,3,4,4,4,4,4,5,0,0,0,0,0,0,3,4,4,5,0,0
db 0,6,7,7,7,7,7,7,7,8,0,0,0,6,7,7,7,7,7,8,0,0,0,0,0,0,6,7,7,8,0,0

db 0,0

ROOM_3:
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,3,4,4,5,0,0,0,0,0,0,0,0,3,4,4,4,4,5,0,0,0,0,0,3,4,4,4,4,4,5,0
db 0,6,7,7,8,0,0,3,4,5,0,0,0,6,7,7,7,7,8,0,0,3,5,0,6,7,7,7,7,7,8,0
db 0,0,0,0,0,0,0,6,7,8,0,0,0,0,0,0,0,0,0,0,0,6,7,0,0,0,0,0,0,0,0,0

db 0,0

DATA_ROOM_LIST:
db ROOM_0>>8, ROOM_0, ROOM_1>>8, ROOM_1
db ROOM_2>>8, ROOM_2, ROOM_3>>8, ROOM_3

 
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
	add a,16
	ld b,a
	push bc
	call proc_get_block_index
	ld a,(hl)
	cp 0
	jr z, proc_move_player_out_walls2
	ld a,(PLAYER_X)
	and %11111000
	add a,8
	ld (PLAYER_X),a
proc_move_player_out_walls2:
	pop bc
	push bc
	inc c
	call proc_get_block_index
	ld a,(hl)
	cp 0
	jr z, proc_move_player_out_walls3
	ld a,(PLAYER_X)
	and %11111000
	dec a
	ld (PLAYER_X),a
proc_move_player_out_walls3:
	pop bc
	ld a,b
	sub 18
	ret c
	ld b,a
	call proc_get_block_index
	ld a,(hl)
	cp 0
	ret z
	ld a,(PLAYER_VEL)
	xor a
	ld (PLAYER_VEL),a
ret
ENDP

;-------------------------------------------------------------
PROC
proc_check_transition:
;-------------------------------------------------------------
	ld a,(PLAYER_X)
	ld b,a
	ld a, 246
	cp b
	jr nc, proc_check_transition2
	ld a,8
	ld (PLAYER_X),a
	ld a,(CURRENT_ROOM_NUMBER)
	inc a
	and MAP_WIDTH-1
	ld c,a
	ld a,(CURRENT_ROOM_NUMBER)
	and ~(MAP_WIDTH-1)
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
	and ~(MAP_WIDTH-1)
	add a,c
	ld (CURRENT_ROOM_NUMBER),a
	call proc_load_map
	ret
proc_check_transition3:
	ld a,(PLAYER_Y)
	ld b,a
	ld a,124
	cp b
	jr nc, proc_check_transition4
	ld a, 8
	ld (PLAYER_Y),a
	ld a,(CURRENT_ROOM_NUMBER)
	sub MAP_WIDTH
	ld (CURRENT_ROOM_NUMBER),a
	call proc_load_map
	ret
proc_check_transition4:
	ld a,2
	cp b
	ret c
	ld a, 111
	ld (PLAYER_Y),a
	ld a,(CURRENT_ROOM_NUMBER)
	add a,MAP_WIDTH
	ld (CURRENT_ROOM_NUMBER),a
	call proc_load_map
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
	inc a
	cp 6
	jr nz, proc_update_player_cap
	ld a,5
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
	add a,23
	and %11111000
	ld b,a
	call proc_get_block_index
	ld d,(hl)
	pop af
	inc d
	dec d
	ld (SCRATCH_ADDRESS2),a
	jr z, proc_update_player_reset_vel
	pop hl
	pop bc
	ld a,b
	or %00000111
	ld b,a
	push bc
	push hl
	xor a
	ld (SCRATCH_ADDRESS2),a
	ld bc,&FBFE
	in a,(c)
	bit 1,a
	jr nz, proc_update_player_reset_vel
	ld a,248
	ld (SCRATCH_ADDRESS2),a
	
proc_update_player_reset_vel:
	ld a,(SCRATCH_ADDRESS2)
	pop hl
	pop bc
	pop de
	ld (hl),a
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
	call proc_get_block_index
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
	add ix,bc
proc_update_walkers_loop:
	ld b,(ix)
	inc b
	ld a,(ix+4)
	cp 0
	jr z, proc_update_walkers_2
	dec b
	dec b
proc_update_walkers_2:
	ld (ix),b
	
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
	rla
	rla
	rla
	ld bc,0
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
	
	ld iy,MONSTER_X
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
	ld ixh,h
	ld ixl,l
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
ret
ENDP


;-------------------------------------------------------------
PROC
proc_load_map:
;-------------------------------------------------------------
	; AFFECTS: everything
	ld b,0
	ld a,(CURRENT_ROOM_NUMBER)
	rla
	and %00000110
	ld c,a
	ld hl,DATA_ROOM_LIST
	add hl,bc
	ld b,(hl)
	inc hl
	ld c,(hl)
	ld (CURRENT_ROOM_ADDRESS),bc
	
	push bc
	call proc_draw_blocks
	pop hl
	ld bc,ROOM_SIZE
	add hl,bc
	ld a,(hl)
	ld de,MONSTER_START
	ld (BUG_COUNT),a
	ld b,a
	inc hl
	ld a,(hl)
	ld (WALKER_COUNT),a
	add a,b
	
	inc a
	ld b,a
	rla
	rla
	add a,b
	ld b,0
	ld c,a
	inc c
	inc hl
	ldir	
ret
ENDP


;==============================================================
; Initialization
;==============================================================
start:
	ld a, BLUE_PAPER | WHITE_INK
    call proc_fill_screen_attribute
	ld hl, PLAYER_POS
	ld a, 40
	ld (hl),a
	ld a, 24
	inc hl
	ld (hl),a
	xor a
	inc hl
	ld (hl),a
	ld hl, PLAYER_ANIM
	ld (hl),a
	ld hl, DATA_ZIGGY_RIGHT
	ld (PLAYER_SPRITE), hl
	ld hl, CURRENT_ROOM_NUMBER
	ld (hl),0
	
	call proc_load_map
loopyboy:
	halt
	call proc_redraw_blocks	
	call proc_update_player
	call proc_draw_sprites
	call proc_update_bugs
	call proc_update_walkers
	jr loopyboy
ret
end start