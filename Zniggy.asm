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
CURRENT_ROOM_ADDRESS        equ $5CCE
CURRENT_ROOM_NUMBER         equ $5CD0
 

PLAYER_POS                  equ $5F00
PLAYER_X                    equ $5F00
PLAYER_Y                    equ $5F01
PLAYER_VEL                  equ $5F02
PLAYER_ANIM                 equ $5F03
PLAYER_SPRITE               equ $5F04
PLAYER_BX                   equ $5F05
PLAYER_BY                   equ $5F06

MAP_WIDTH                   equ 32
MAP_HEIGHT                  equ 18
SCREEN_HEIGHT               equ 24

;==============================================================
; Data
;==============================================================
DATA_TILE_PIXELS:

DATA_TILE_ATTRIBUTES:
db BLACK_PAPER | PURPLE_INK | BRIGHT

DATA_SPRITES:
DATA_ZIGGY_RIGHT:
; ziggy_head
db %00011000
db %00111100
db %01111010
db %11111111
db %01110000
db %00111100
db %00011000
db %00111100
; ziggy_bottom
db %01111110
db %11111111
db %01111110
db %00111100
db %00011000
db %00011000
db %00011000
db %00011110
; ziggy_bottom2
db %01111110
db %11111111
db %01111110
db %00111100
db %00011000
db %01101100
db %10000111
db %01000000
; ziggy_bottom3
db %01111110
db %11111111
db %01111110
db %00111100
db %00011000
db %00101001
db %01000110
db %10000100
; ziggy_bottom4
db %01111110
db %11111111
db %01111110
db %00111100
db %00011000
db %00101000
db %01010000
db %01011110

DATA_ZIGGY_LEFT:
; ziggy_head
db %00011000
db %00111100
db %01011110
db %11111111
db %00001110
db %00111100
db %00011000
db %00111100
; ziggy_bottom
db %01111110
db %11111111
db %01111110
db %00111100
db %00011000
db %00011000
db %00011000
db %01111000
; ziggy_bottom2
db %01111110
db %11111111
db %01111110
db %00111100
db %00011000
db %00110110
db %11100001
db %00000010
; ziggy_bottom3
db %01111110
db %11111111
db %01111110
db %00111100
db %00011000
db %10010100
db %01100010
db %00100001
; ziggy_bottom4
db %01111110
db %11111111
db %01111110
db %00111100
db %00011000
db %00010100
db %00001010
db %01111010
 
 

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
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
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


ROOM_1:
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
db 0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,1,2,2,2,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,1,2,2,2,2,2,2,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,0,0
db 0,0,1,2,2,2,2,2,2,2,2,1,1,1,0,0,0,0,0,0,0,0,0,1,1,1,2,2,2,1,0,0
db 1,1,2,2,2,2,2,2,2,2,2,2,2,2,1,1,1,1,1,1,1,1,1,2,2,2,2,2,2,2,1,1
db 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
db 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2

DATA_ROOM_LIST:
db ROOM_0>>8, ROOM_0, ROOM_1>>8, ROOM_1

 
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
proc_draw_sprite:
;-------------------------------------------------------------
    ; IN: b = y-pixel coord (0..191), c: x-pixel coord (0..31), de = sprite address
	; AFFECTS: hl, de, a, b
	
	; This code is a fucking mess
	; This code also draws an 8x8 sprite on the screen, supposedly
	
	push de
	push bc
	ld hl, SCRATCH_ADDRESS1 ; Store c value
	ld (hl),c
	ld a,c
	rra
	rra
	rra
	and %00011111
	ld hl, SCRATCH_ADDRESS2 ; Store c cell value
	ld (hl),a
	ld c,a
	ld a,b
	ld d,b
	rra
	rra
	rra
	and %00011111
	ld b,a
	call proc_get_screen_attribute_address
	ld de, DATA_TILE_ATTRIBUTES
	ld a, (de)
	ld (hl), a
	inc c
	call proc_get_screen_attribute_address
	ld de, DATA_TILE_ATTRIBUTES
	ld a, (de)
	ld (hl), a
	dec c
	ld a,d
	and %00000111
	;jr z, proc_draw_sprite_attrib_end
	inc b
	call proc_get_screen_attribute_address
	ld de, DATA_TILE_ATTRIBUTES
	ld a, (de)
	ld (hl), a
	inc c
	call proc_get_screen_attribute_address
	ld de, DATA_TILE_ATTRIBUTES
	ld a, (de)
	ld (hl), a
	
proc_draw_sprite_attrib_end:
	
	pop bc
	pop de
	
	ld a, 8
proc_draw_sprite_loop:
	push af
	push de
	ld hl, SCRATCH_ADDRESS2
	ld c,(hl)
	call proc_get_screen_pixel_address
	ld de, SCRATCH_ADDRESS1
	ld a, (de)
	ld c, a
	pop de
	ld a, (de)
	push de
	ld e,a
	ld a,c
	and %00000111
	ld c,a
	ld a,e
	ld e, %11111111
	inc c ;;TODO: UNHACK
	dec c
	jr z, proc_draw_sprite_shift_end
proc_draw_sprite_shift_loop:
	rrc a
	ccf
	rr e
	ccf
	dec c
	jr nz, proc_draw_sprite_shift_loop
proc_draw_sprite_shift_end:
	ld c,d
	ld d,a
	and e
	ld (hl), a
	ld hl,SCRATCH_ADDRESS2
	ld a,(hl)
	or %00000111
	jr z, proc_draw_sprite_shift_skip
	ld hl, SCRATCH_ADDRESS2
	ld c,(hl)
	inc c
	call proc_get_screen_pixel_address
	ld a,e
	xor %11111111
	ld e,a
	ld a,d
	scf
	and e
	ld (hl), a
proc_draw_sprite_shift_skip:
	inc b
	pop de
	inc de
	pop af
	dec a
	jr nz, proc_draw_sprite_loop
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
	inc c
	call proc_get_block_index
	ld a,(hl)
	cp 0
	ret z
	ld a,(PLAYER_X)
	and %11111000
	dec a
	ld (PLAYER_X),a
ret
ENDP

;-------------------------------------------------------------
PROC
proc_check_transition:
;-------------------------------------------------------------
	ld a,(PLAYER_X)
	ld b,a
	ld a, 240
	cp b
	jr nc, proc_check_transition2
	ld a, 8
	ld (PLAYER_X),a
	ld a,(CURRENT_ROOM_NUMBER)
	inc a
	ld (CURRENT_ROOM_NUMBER),a
	call proc_load_map
proc_check_transition2:
	
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
	ld a,0
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
proc_draw_sprites:
;-------------------------------------------------------------
	; AFFECTS: everything
	
	; Draws player
	ld hl, PLAYER_POS
	ld c,(hl)
	inc hl
	ld b,(hl)
	
	ld de, (PLAYER_SPRITE)
	call proc_draw_sprite
	ld bc, PLAYER_POS
	ld de, (PLAYER_SPRITE)
	ld a,e
	add a,8
	ld e,a
	
	ld a, (PLAYER_ANIM)
	rla
	and %11111000
	add a,e
	ld e,a
	
	ld hl, PLAYER_POS
	ld c,(hl)
	inc hl
	ld b,(hl)
	
	ld a,b
	add a,8
	ld b,a
	call proc_draw_sprite
	
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
	ld a,0
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
	ld a,MAP_HEIGHT
	cp b
	halt	
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
	and %11111110
	ld c,a
	ld hl,DATA_ROOM_LIST
	add hl,bc
	ld b,(hl)
	inc hl
	ld c,(hl)
	ld (CURRENT_ROOM_ADDRESS),bc
	
	call proc_draw_blocks
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
	ld a, 0
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
	jr loopyboy
ret
end start