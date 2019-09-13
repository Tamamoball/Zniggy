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
 
INCLUDE Data.asm

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
SCRATCH_ADDRESS4            equ $5CD5
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
PLAYER_ON_LADDER            equ $5D09

SPRITE_SIZE_8X8             equ 0
SPRITE_SIZE_16X8            equ 8
SPRITE_SIZE_8X16            equ 8
SPRITE_SIZE_16X16           equ 24
SPRITE_SIZE_24X8            equ 16
SPRITE_LOOKUP_OFFSET        equ 1
SPRITE_WIDTH_OFFSET         equ 2
SPRITE_HEIGHT_OFFSET        equ 3
SPRITE_DATA_SIZE            equ 4

MONSTER_START               equ $6100
MONSTER_POS                 equ $6100
MONSTER_X                   equ $6100
MONSTER_Y                   equ $6101
MONSTER_SPRITE              equ $6102
MONSTER_DIR                 equ $6104
MONSTER_SIZE                equ 8

MONSTER_POS_OFFSET          equ 0
MONSTER_X_OFFSET            equ 0
MONSTER_Y_OFFSET            equ 1
MONSTER_SPRITE_OFFSET       equ 2
MONSTER_DIR_OFFSET          equ 4
MONSTER_WIDTH_OFFSET        equ 6
MONSTER_BWIDTH_OFFSET       equ 5
MONSTER_HEIGHT_OFFSET       equ 7

ROOM_WIDTH                  equ 32
ROOM_HEIGHT                 equ 18
ROOM_SIZE                   equ 32*18
SCREEN_HEIGHT               equ 24
MAP_WIDTH                   equ 8

ROOM_START                  equ $6B00
ROOM_END                    equ $6D41

ROOM_BITS                   equ %00111111

 
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
	sub 9
	ld b,a
	call proc_get_block_properties
	bit BLOCK_COLLISION_BIT,a
	jr z, proc_move_player_out_walls2
proc_move_player_out_walls_right:
	ld a,(PLAYER_X)
	add a,2
	ld (PLAYER_X),a
proc_move_player_out_walls2:
	pop bc
	push bc
	ld a,(PLAYER_X)
	add a,7
	rra
	rra
	rra
	and %00011111
	ld c,a
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
	dec a
	ld (PLAYER_X),a
proc_move_player_out_walls3:
	pop bc
	ld a,b
	sub 8
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
	add a,MAP_WIDTH
	and ROOM_BITS
	ld (CURRENT_ROOM_NUMBER),a
	call proc_load_map
	ret
proc_check_transition4:
	ld a,244
	cp b
	ret nc
	ld a,(PLAYER_ON_LADDER)
	cp 0
	ret z
	ld a, 118
	ld (PLAYER_Y),a
	ld a,(CURRENT_ROOM_NUMBER)
	sub MAP_WIDTH
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
	add a,(ix+MONSTER_WIDTH_OFFSET)
	sub 4
	cp e
	jr c,proc_check_player_death_end
	ld a,(ix+1)
	cp b
	jr nc,proc_check_player_death_end
	add a,(ix+MONSTER_HEIGHT_OFFSET)
	sub 4
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
	xor a
	ld (PLAYER_ON_LADDER),a
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
	ld a,1
	ld (PLAYER_ON_LADDER),a
	ld a,(PLAYER_VEL)
	sub 248
	jr nc, proc_climb_ladder_reset_vel_end
	ld a,0
	ld (PLAYER_VEL),a
proc_climb_ladder_reset_vel_end:	
	push bc
	ld bc,&FBFE
	in a,(c)
	bit 1,a
	pop bc
	jr nz, proc_climb_ladder2
	ld a,b
	sub 8
	ld b,a
	call proc_get_block_properties
	bit BLOCK_COLLISION_BIT,a
	ret nz
	;ld a,(PLAYER_VEL)
	;add a,254
	;ld (PLAYER_VEL),a
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
	jr nz, proc_update_player_check_jump
	bit BLOCK_LADDER_BIT,d
	jr z, proc_update_player_reset_vel
	jr proc_update_player_skip_ground
proc_update_player_check_jump:
	pop hl
	pop bc
	ld a,b
	and %11111100
	ld b,a
	push bc
	push hl
proc_update_player_skip_ground:
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
	bit 0,a
	jr nz, proc_update_bugs2
	ld a,(ix+1)
	inc a
	ld (ix+1),a
	add a,(ix+MONSTER_HEIGHT_OFFSET)
	inc a
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
	cp 2
	jr nc, proc_update_bugs_reset
	ld b,a
	ld a,1
	sub b
	ld (ix+4),a
	jr proc_update_bugs_loop_end
proc_update_bugs_reset:
	ld a,(ix+MONSTER_Y_OFFSET)
	rra 
	rra 
	rra
	and %00011111
	ld b,a
	ld a,(ix+MONSTER_X_OFFSET)
	rra 
	rra 
	rra
	and %00011111
	ld c,a
	push bc
	call proc_draw_block
	pop bc
	inc b
	call proc_draw_block
	ld a,(ix+4)
	ld (ix+1),a
proc_update_bugs_loop_end
	ld de,MONSTER_SIZE
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
	rla
	rla
	rla
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
	add a,(ix+MONSTER_WIDTH_OFFSET)
	sub 7
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
	cp 0
	jr z, proc_update_walkers_switch
	ld a,(ix+1)
	add a,(ix+MONSTER_HEIGHT_OFFSET)
	sub 7
	ld b,a
	call proc_get_block_index
	ld a,(hl)
	cp 0
	jr z, proc_update_walkers_end
proc_update_walkers_switch:
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
	
	ld a,c
	exx
	ld b,(ix+SPRITE_HEIGHT_OFFSET)
	and %00000111
	ld h,SPRITE_LOOKUP>>8
	add a,(ix+SPRITE_LOOKUP_OFFSET)
	ld l,a
	ld d,0
	ld e,(hl)
	ld a,(ix+SPRITE_WIDTH_OFFSET)
	ld (SCRATCH_ADDRESS4),a
	add ix,de ;ix now contains the sprite address	
	ld a,b
	rra
	rra
	rra
	inc a
	and %00011111
	ex af,af'
	exx
	ld a,c
	rra
	rra
	rra
	and %00011111
	ld c,a
	
	push bc
	push de
	ld a,b
	and $07
	jr nz,proc_draw_sprite_skip_tile
	ex af,af'
	dec a
	ex af,af'
proc_draw_sprite_skip_tile:
	ld a,b
	rra
	rra
	rra
	and %00011111
	ld b,a
	call proc_get_screen_attribute_address
	pop de
	ld bc,32
	ex af,af'
	ld e,a
proc_draw_sprite_attrib_loop:
	ld a,(SCRATCH_ADDRESS4)
	push hl
proc_draw_sprite_attrib_loop2:
	ld (hl),d
	inc hl
	dec a
	jr nz,proc_draw_sprite_attrib_loop2
	pop hl
	add hl,bc
	dec e
	jr nz,proc_draw_sprite_attrib_loop
	pop bc
	

	ld (SCRATCH_ADDRESS3),ix
	ld de,(SCRATCH_ADDRESS3)
	ld hl,SPRITE_DATA_SIZE
	add hl,de
	ex de,hl
	exx
proc_draw_sprite_loop:
	exx
	push de
	call proc_get_screen_pixel_address
	pop de
	exx
	ld a,(SCRATCH_ADDRESS4)
	ld c,a
proc_draw_sprite_loop2:
	exx
	ld a,(de)
	ld (hl),a
	inc hl
	inc de
	exx
	dec c
	jr nz, proc_draw_sprite_loop2
	exx
	inc b
	exx
	dec b
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
	ld a,160
	cp b
	jr c, proc_draw_sprites_skip_player
	ld ix,(PLAYER_SPRITE)
	ld d,BLACK_PAPER | PURPLE_INK | BRIGHT
	call proc_draw_sprite	
proc_draw_sprites_skip_player:
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
	ld a,0
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
	ld a,160
	cp b
	jr c,proc_redraw_blocks_skip_player
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
proc_redraw_blocks_skip_player:
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
	bit 0,a
	jr z,proc_redraw_blocks2
	ld a,b
	add a,(iy+MONSTER_HEIGHT_OFFSET)
	inc a
	ld b,a
proc_redraw_blocks2:
	push bc
	call proc_get_block_index
	pop bc
	ld (CURRENT_SPRITE),hl
	ld ix,(CURRENT_SPRITE)
	call proc_get_screen_pixel_address
	ld d,(iy+MONSTER_BWIDTH_OFFSET)
proc_redraw_blocks2_inner:
	ld a,(ix)
	ld (hl),a
	inc ix
	inc hl
	dec d
	jr nz,proc_redraw_blocks2_inner
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
	ld de,MONSTER_SIZE
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
	
	inc hl
	cp 0
	jr z,proc_load_map_loop4_end
proc_load_map_loop4:
	ex af,af'
	ld bc,2
	ldir
	ld a,(hl)
	ld (de),a
	ld c,a
	inc hl
	inc de
	ld a,(hl)
	ld (de),a
	ld b,a
	inc hl
	inc de
	ld a,(hl)
	ld (de),a
	inc hl
	inc de
	
	inc bc
	inc bc
	ld a,(bc)
	ld (de),a
	inc de
	rla
	rla
	rla
	ld (de),a
	inc bc
	inc de
	ld a,(bc)
	ld (de),a
	inc de
	ex af,af'
	dec a
	jr nz,proc_load_map_loop4
proc_load_map_loop4_end:
	ld bc,$B001
	call proc_draw_string
	inc hl
	ld bc,12
	ld de,CURRENT_ROOM_GEMS
	ldir
	
	ld a,(CURRENT_ROOM_NUMBER)
	cp 8
	jr nz,proc_load_map5
	ld hl,ROOM_8_TEXT
	ld bc,$2813
	call proc_draw_string
	inc hl
	ld bc,$3811
	call proc_draw_string
	inc hl
	ld bc,$4813
	call proc_draw_string
	inc hl
	ld bc,$5810
	call proc_draw_string
proc_load_map5:
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
	ld a, 124
	ld (hl),a
	ld a, 100
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
	ld (hl),35
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
	ld a,$FF
	ld (COLLECTED_GEMS+35),a
	
	call proc_load_map
loopyboy:
	ei
	halt
	halt
	di
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
	
	;The code below gives a reliable way to prevent flickering at the cost of a frame
	;ei
	;halt
	;di
	;ld bc,$6A0
;gameloopstall:
	;dec bc
	;ld a,0
	;cp b
	;jr nz,gameloopstall

	
	ld a,(PLAYER_LIVES)
	cp CHAR_ZERO-1
	jr nz,loopyboy
	jr start
ret
end start

