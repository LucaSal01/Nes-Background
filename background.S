.db "NES", $1A, 2, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0

.org $8000

.define PPUCTRL   $2000
.define PPUMASK   $2001
.define OAMADDR   $2003
.define OAMDATA   $2004
.define PPUSCROLL $2005
.define PPUADDR   $2006
.define PPUDATA   $2007
.define OAMDMA    $4014

.define JOYPAD1 $4016

.define scroll_x $00
.define scroll_y $01
.define sprite_x $02
.define sprite_y $03
.define buttons  $04

start:

    LDA #%10010000
    STA PPUCTRL
    LDA #%00011110
    STA PPUMASK
    
    ; load background palette
    LDA #$3f
    STA PPUADDR
    LDA #0
    STA PPUADDR

    LDA #$31
    STA PPUDATA
    LDA #$1F
    STA PPUDATA
    LDA #$28
    STA PPUDATA
    LDA #$4F
    STA PPUDATA

    ; load aiv on nametables
    LDA #$31
    STA PPUADDR
    LDA #0
    STA PPUADDR
    JSR load_nametable

    LDA #$25
    STA PPUADDR
    LDA #0
    STA PPUADDR
    JSR load_nametable

    ; load sprite palette
    LDA #$3f
    STA PPUADDR
    LDA #$11
    STA PPUADDR

    LDA #$0F
    STA PPUDATA
    LDA #$1B
    STA PPUDATA
    LDA #$36
    STA PPUDATA
    
    
loop:
    JMP loop

load_nametable:
    LDX #0    
    LDY #0   
    LDA #$10 
    STA $10  
    STA $11  
inner_loop_first_16:
    STX PPUDATA
    INX
    DEC $10
    BNE inner_loop_first_16
    STA $10

inner_loop_last_16:
    STY PPUDATA
    DEC $10
    BNE inner_loop_last_16

outer_loop:
    STA $10
    DEC $11
    BNE inner_loop_first_16
    RTS

readjoy:
    LDA #$01
    STA JOYPAD1
    STA buttons
    LSR A
    STA JOYPAD1
joyloop:
    LDA JOYPAD1
    LSR A 
    ROL buttons
    BCC joyloop
    RTS

nmi:
   PHA
   JSR readjoy
   PLA

    Right:
    LDA buttons                    
    AND #%00000001
    BEQ Left
    LDA sprite_x           
    CMP #$F7
    BEQ ELSE
    INC scroll_x
    INC sprite_x
    LDA #03
    STA OAMADDR
    LDA sprite_x
    STA OAMDATA

    Left:   
    LDA buttons         ; Check input
    AND #%00000010
    BEQ Up
    LDA sprite_x         ; Check screen limit
    CMP #$01
    BEQ ELSE
    DEC scroll_x
    DEC sprite_x
    LDA #03
    STA OAMADDR
    LDA sprite_x
    STA OAMDATA
    
    Up:
    LDA buttons               ; Check input
    AND #%00001000
    BEQ Down
    LDA sprite_y               ; Check screen limit
    CMP #$09
    BEQ ELSE
    DEC sprite_y
    LDA #0
    STA OAMADDR
    LDA sprite_y
    STA OAMDATA
    
    Down:
    LDA buttons                  ; Check input
    AND #%00000100
    BEQ loadscroll
    LDA sprite_y                 ; Check screen limit
    CMP #$E0
    BEQ ELSE
    INC sprite_y
    LDA #0
    STA OAMADDR
    LDA sprite_y
    STA OAMDATA

loadscroll:
    LDA scroll_x
    STA PPUSCROLL
    LDA #0
    STA PPUSCROLL
    RTI

ELSE:
NOP

irq:
    RTI

.goto $FFFA

.dw nmi
.dw start
.dw irq

.incbin mario0.chr
.incbin aiv256.chr