; This section is for including files that either need to be in the home section, or files where it doesn't matter 
SECTION "Includes_home",ROM0

; Prior to importing GingerBread, some options can be specified

; Max 15 characters, should be uppercase ASCII
GAME_NAME EQUS "TECH DEMO"

; Set the size of the ROM file here. 0 means 32 kB, 1 means 64 kB, 2 means 128 kB and so on.
ROM_SIZE EQU 1

; Set the size of save RAM inside the cartridge. 
; If printed to real carts, it needs to be small enough to fit. 
; 0 means no RAM, 1 means 2 kB, 2 -> 8 kB, 3 -> 32 kB, 4 -> 128 kB 
RAM_SIZE EQU 0

INCLUDE "gingerbread.asm"

; This section is for including files that need to be in data banks
SECTION "Includes_banks",ROMX
INCLUDE "meat_logo_tiles.inc"
INCLUDE "font_main_tiles.inc"
INCLUDE "meat_games_background_map.inc"

; Macro for copying a rectangular region into VRAM
; Changes ALL registers
; Arguments:
; 1 - Height (number of rows)
; 2 - Width (number of columns)
; 3 - Source to copy from
; 4 - Destination to copy to
CopyRegionToVRAM: MACRO

I SET 0
REPT \1

    ld bc, \2
    ld hl, \3+(I*\2)
    ld de, \4+(I*32)
    
    call mCopyVRAM
    
I SET I+1
ENDR
ENDM   

SECTION "StartOfGameCode",ROM0    
begin: ; GingerBread assumes that the label "begin" is where the game should start

; Load title image into VRAM
    
    ;test scroll background
    ;ld a, -10
    ;ld [SCROLL_X], a
    ;ld [SCROLL_Y], a
    ;xor a

    ; We need to switch bank to whatever bank contains the tile data 
    ld a, BANK(meat_logo_tiles)
    ld [ROM_BANK_SWITCH], a 
    
    ld hl, meat_logo_tiles
    ld de, TILEDATA_START
    ld bc, meat_logo_tiles_data_size
    call mCopyVRAM

    ; Load font tiles as a separate tile set for reuse across all screens (is it optimal?)
    ld a, BANK(font_main_tiles)
    ld [ROM_BANK_SWITCH], a 
    
    ld hl, font_main_tiles
    ld de, TILEDATA_START + 16*210
    ld bc, font_main_tiles_data_size
    call mCopyVRAM
    
    ld a, BANK(meat_logo_background_map)
    ld [ROM_BANK_SWITCH], a 
    
    CopyRegionToVRAM 6, 6, meat_logo_background_map, BACKGROUND_MAPDATA_START + 7 + 4*32
    
    ; Show logo text
    ld b, $d0 ; end character 
    ld c, 0 ; draw to background
    ld d, 5 ; X start position (0-19)
    ld e, 12 ; Y start position (0-17)
    ld hl, LogoText ; text to write 
    call RenderTextToEnd

    call StartLCD

TitleLoop:
    ld b, 100

.loop:

    halt
    nop ; Always do a nop after a halt, because of a CPU bug
    
    call ReadKeys
    and KEY_A | KEY_START
    cp 0
    
    jp nz, TransitionToMainMenu
    
    ld a, 1
    dec b 
    ld a, b
    cp 0 
    
    jr nz, .loop

    jr TransitionToMainMenu

ShortWait:
    ld b, 20
    
.loop:    
    ld a, 1 
    
    halt 
    nop 
    
    dec b 
    ld a, b
    cp 0 
    jr nz, .loop 
    
    ret 

FadeOut:
    ld a, %11111001
    ld [BG_PALETTE], a
    
    call ShortWait
    
    ld a, %11111110
    ld [BG_PALETTE], a
    
    call ShortWait
    
    ld a, %11111111
    ld [BG_PALETTE], a
    
    call ShortWait

    ret

FadeIn:
    ld a, %11111110
    ld [BG_PALETTE], a
    
    call ShortWait
    
    ld a, %11111001
    ld [BG_PALETTE], a 
    
    call ShortWait
    
    ld a, %11100100
    ld [BG_PALETTE], a 
    
    call ShortWait

    ret

TransitionToMainMenu:

    call FadeOut
    
    ; Now that the screen is completely black, load the game graphics
    ; Clear out the background 
    ld a, 1 
    ld hl, BACKGROUND_MAPDATA_START
    ld bc, 32*32
    call mSetVRAM

    call FadeIn

    ; Show main menu text
    ld b, $d0 ; end character 
    ld c, 0 ; draw to background
    ld d, 3 ; X start position (0-19)
    ld e, 4 ; Y start position (0-17)
    ld hl, MenuText ; text to write 
    call RenderTextToEnd

    jp GameLoop

GameLoop:

    halt 
    nop

    jr GameLoop

SECTION "Text definitions",ROM0 
; Charmap definition (based on the pong.png image, and looking in the VRAM viewer after loading it in BGB helps finding the values for each character)
CHARMAP "A",$e5
CHARMAP "B",$e6
CHARMAP "C",$e7
CHARMAP "D",$e8
CHARMAP "E",$e9
CHARMAP "F",$ea
CHARMAP "G",$eb
CHARMAP "H",$ec
CHARMAP "I",$ed
CHARMAP "J",$ee
CHARMAP "K",$ef
CHARMAP "L",$f0
CHARMAP "M",$f1
CHARMAP "N",$f2
CHARMAP "O",$f3
CHARMAP "P",$f4
CHARMAP "Q",$f5
CHARMAP "R",$f6
CHARMAP "S",$f7
CHARMAP "T",$f8
CHARMAP "U",$f9
CHARMAP "V",$fa
CHARMAP "W",$fb
CHARMAP "X",$fc
CHARMAP "Y",$fe
CHARMAP "Z",$fd
CHARMAP "<happy>",$70
CHARMAP "<sad>",$71
CHARMAP "<heart>",$72
CHARMAP " ",$d1
CHARMAP "<end>",$d0 ; Choose some non-character tile that's easy to remember

LogoText:
DB "MEAT GAMES<end>"

MenuText:
DB "HORRIBLE DEATH<end>"