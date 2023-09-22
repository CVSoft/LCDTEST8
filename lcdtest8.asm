#define lcd_busy_quick 000Bh
#include "ti83plus.inc"

#define Result appData
#define DelayStorage appData+2

.binarymode TI8X
.variablename LCDTEST8
.org userMem-2
.db t2ByteTok,tasmCmp
.export 

Wrapper:
 ld hl,plotSScreen
 push hl
  set graphDraw,(iy+graphFlags)
  bcall(_SaveDisp)
  di ; implied by _SaveDisp but you never know these days
  xor a
  ld (Result),a
  ; di ; (_SaveDisp) disables interrupts
  call DisableLCD
  ; put calculator in 15 MHz? (call ActivateTurbo)
  call ActivateTurbo
  call CheckInstantBusy
  call CheckInstantWrites
  ; if calc was put in 15 MHz, put back to 6 MHz here (call DeactivateTurbo)
  call DeactivateTurbo
  call EnableLCD
  ld h,0
  ld a,(Result)
  ld l,a
  call PutHLinAns
 pop hl
 ld b,64
 bcall(_RestoreDisp)
 ei
 ret

CheckInstantBusy:
 ; initialize sub-result register
 ld b,0
 ; toss a command at the LCD
 ld a,$20
 out ($10),a
 call lcd_busy_quick
 ld a,$90
 out ($10),a
 call lcd_busy_quick
 ld a,$12
 out ($11),a
 ; and instantly check for a busy bit (Kinpo: scrambles VRAM pointer)
 in a,($10)
 and %10000000
 call nz,LCDIsBusy
 ld a,(Result)
 or b
 ld (Result),a
 ret

LCDIsBusy:
 ld b,$01
 ret
 
CheckInstantWrites:
 ; initialize sub-result register
 ld b,0
 ; set up an area of the LCD
 ld a,$20
 out ($10),a
 call lcd_busy_quick
 ld a,$90
 out ($10),a
 call lcd_busy_quick
 ld a,$12
 out ($11),a
 call lcd_busy_quick
 out ($11),a
 call lcd_busy_quick
 ld a,$90
 out ($10),a
 call lcd_busy_quick
 ; toss a command at the LCD
 ld a,$55
 out ($11),a
 out ($11),a
 ; and check if the second command got parsed
 ld a,$20
 out ($10),a
 call lcd_busy_quick
 ld a,$91
 out ($10),a
 call lcd_busy_quick
 ; dummy read -- these things are silly
 in a,($11)
 call lcd_busy_quick
 ; read contents of the second write
 in a,($11)
 call lcd_busy_quick
 cp $55
 call z,LCDIsFast
 ld a,(Result)
 or b
 ld (Result),a
 ret

LCDIsFast:
 ld b,$02
 ret

;---------- utility routines -------------;

DisableLCD:
 ; Turn off the LCD (it remains powered)
 push af
 ld a,$02
 DoLCDCommand:
 out ($10),a
 pop af
 jp lcd_busy_quick

EnableLCD:
 push af
 ld a,$03
 jp DoLCDCommand

PutHLinStorage:
 ; this is really a worthless routine
 ; quick substitute for PutHLinAns
 push af
  ld a,(Result)
  or h
  ld (Result),a
  ld a,(Result+1)
  or l
  ld a,(Result+1)
 pop af
 ret

PutHLinAns:
 ; Stores HL in TIOS Ans variable
 ; Inputs  : HL is integer value to store
 ; Destroys: None
 ; Outputs : TIOS variable Ans contains the value of HL
 push af
 push bc
 push de
 push hl
 jr PutHLinAnsSub
PutAinAns:
 ; Stores A in TIOS Ans variable
 ; Inputs  : A is integer value to store
 ; Destroys: None
 ; Outputs : TIOS variable Ans contains the value of HL
 push af
 push bc
 push de
 push hl
 ld h,0
 ld l,a
 PutHLinAnsSub:
 bcall(_SetXXXXOP2) ; (OP2) = HL = A
 bcall(_OP2ToOP1) ; (OP2) = (OP1)
 bcall(_StoAns)   ; Ans = (OP1)
 pop hl
 pop de
 pop bc
 pop af
 ret

ActivateTurbo:
 in a,(02h)
 and 80h
 jr z,MissingTurbo
 ; indicate whether result was performed at 15 MHz
 ld a,(Result)
 or 4
 ld (Result),a
 rlca
 out (20h),a
 ; adjust port $2A ?  if so, save existing value to (appData)
 ; dump existing delays
 push hl
  ld hl,DelayStorage
  in a,($29)
  ld (hl),a
  inc hl
  in a,($2A)
  ld (hl),a
  inc hl
  in a,($2B)
  ld (hl),a
  inc hl
  in a,($2C)
  ld (hl),a
 pop hl
 ; load absolute minimum delay
 ld a,$0C
 out ($29),a
 out ($2A),a
 out ($2B),a
 out ($2C),a
 MissingTurbo:
 ret

DeactivateTurbo:
 in a,(02h)
 and 80h
 jr z,MissingTurbo
 xor a
 out (20h),a
 ; adjust port $2A ?  if so, restore existing value from (appData)
 ; dump stored values to RAM
 push hl
  ld hl,DelayStorage
  ld a,(hl)
  out ($29),a
  inc hl
  ld a,(hl)
  out ($2A),a
  inc hl
  ld a,(hl)
  out ($2B),a
  inc hl
  ld a,(hl)
  out ($2C),a
 pop hl
 ret