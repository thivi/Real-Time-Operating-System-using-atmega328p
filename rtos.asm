;
; RTOS.asm
;
; Created: 9/17/2016 11:24:33 PM
; Author : thivi
;


; Replace with your application code
.equ total_task=4
.equ task_index=(RAMEND-10)
.equ sp_backup_base=(RAMEND-12)
.equ task1_stack=(RAMEND-50)
.equ task2_stack=(RAMEND-350)
.equ task3_stack=(RAMEND-650)
.equ task4_stack=(RAMEND-950)
.equ task1_select=(RAMEND-1800)

.equ base=(RAMEND-3)
.equ counter=(RAMEND-1900)

.equ reds=(RAMEND-1300)
.equ blues=(RAMEND-1301)
.equ greens=(RAMEND-1302)
.equ oranges=(RAMEND-1303)

.equ index=(RAMEND-1350)
.INCLUDE "m328pdef.inc"
.ORG 0x0000
	RJMP main
.ORG INT0addr
	RJMP pro_select
.ORG PCI0addr
	RJMP pro_select1
.ORG PCI1addr
	RJMP pro_select2
.ORG PCI2addr
	RJMP pro_select3
.ORG 0x0020
	RJMP context_switch
main:

LDI r16, 0b11110000
OUT DDRD, r16
LDI r16, 0b11111110
OUT DDRB, r16
SBIC PINB, 1
	call fifs
SBIC PINB, 2
	call prio
SBIC PINB,3
	call cs


ret
;---cs---
cs:
call bui

clr r16
sts task1_stack, r16
sts (task1_stack-1), r16
sts task2_stack, r16
sts (task2_stack-1), r16
sts (task3_stack), r16
sts (task3_stack-1), r16
sts (task4_stack), r16
sts (task4_stack-1), r16

ldi r28, LOW(sp_backup_base)
ldi r29, HIGH(sp_backup_base)

ldi r16, HIGH(task1_stack)
st y, r16
out SPH, r16
ldi r16, LOW(task1_stack)
st -y, r16
out SPL, r16

ldi r16, HIGH(task2_stack-35)
st -y, r16
ldi r16, LOW(task2_stack-35)
st -y, r16

ldi r16, HIGH(task3_stack-35)
st -y, r16
ldi r16, LOW(task3_stack-35)
st -y, r16

ldi r16, HIGH(task4_stack-35)
st -y, r16
ldi r16, LOW(task4_stack-35)
st -y, r16

clr r16
sts task_index, r16

sts counter, r16
sts task1_select, r16




call wait
call wait
call wait
call wait

;--TIMER0_INTERTUPT---------------------
 ldi r16,  0b00000101
   out TCCR0B, r16      ; set the Clock Selector Bits CS00, CS01, CS02 to 101
                         ; this puts Timer Counter0, TCNT0 in to FCPU/1024 mode
                         ; so it ticks at the CPU freq/1024
   ldi r16, 0b00000001
   sts TIMSK0, r16      ; set the Timer Overflow Interrupt Enable (TOIE0) bit 
                         ; of the Timer Interrupt Mask Register (TIMSK0)

   sei                   ; enable global interrupts -- equivalent to "sbi SREG, I"

   clr r16
   out TCNT0, r16       ; initialize the Timer/Counter to 0
;----------------------------------------

lds r16, task1_select

cpi r16, 1
lds r17, 0x5F
SBRC r17, 1
	call redf

cpi r16, 2
lds r17, 0x5F
SBRC r17, 1
	call bluef

cpi r16, 3
lds r17, 0x5F
SBRC r17, 1
	call greenf

cpi r16, 4
lds r17, 0x5F
SBRC r17, 1
	call orangef






;---------
;--context_switch----
context_switch:
	push r31
    push r30
    push r29
    push r28
    push r27
    push r26
    push r25
    push r24
    push r23
    push r22
    push r21
    push r20
    push r19
    push r18
    push r17
    push r16
    push r15
    push r14
    push r13
    push r12
    push r11
    push r10
    push r9
    push r8
    push r7
    push r6
    push r5
    push r4
    push r3
    push r2
    push r1
    push r0   
    in r17, SREG
    push r17            ;pushing status register
;-------CONTEXT SWITCHING -------------------;
    lds r16, TASK_INDEX
    ldi r30, low(SP_BACKUP_bASE)
    ldi r31, high(SP_BACKUP_bASE)
    clr r0
    sub r30,r16
    sbc r31,r0
    sub r30,r16
    sbc r31,r0
    in r17, SPH
    st Z, r17
    in r17, SPL
    st -Z, r17
    inc r16
    cpi r16, TOTAL_TASK
    brne SKIP1
    ldi r30, low(SP_BACKUP_bASE)
    ldi r31, high(SP_BACKUP_bASE)
    clr r16
    sts TASK_INDEX, r16
    ld r17, Z
    rjmp SKIP2    
SKIP1:
    sts TASK_INDEX,r16
    ld r17, -Z
SKIP2:
    out SPH,r17
    ld r17, -Z
    out SPL,r17
;-----NOW I GOT THE NEW STACK POINTER, SO THE TASK IS SWITCHED!-------;
; 
;Now the next process is to restore the status register and 
;all the cpu registers as it's previous state for the selected
;task....
    pop r17
    out SREG, r17
    pop r0
    pop r1
    pop r2
    pop r3
    pop r4
    pop r5
    pop r6
    pop r7
    pop r8
    pop r9
    pop r10
    pop r11
    pop r12
    pop r13
    pop r14
    pop r15
    pop r16
    pop r17
    pop r18
    pop r19
    pop r20
    pop r21
    pop r22
    pop r23
    pop r24
    pop r25
    pop r26
    pop r27
    pop r28
    pop r29
    pop r30
    pop r31

reti

;------------------
;---FIFS-----
fifs:
ldi r31, HIGH(BASE)
ldi r30, LOW(BASE)
call bui
call wait
call wait
call wait
call wait
call wait


;-------------------------
lds r16, (BASE)
cpi r16, 1
lds r17, 0x5F
SBRC r17, 1
	call redf

cpi r16, 2
lds r17, 0x5F
SBRC r17, 1
	call bluef

cpi r16, 3
lds r17, 0x5F
SBRC r17, 1
	call greenf

cpi r16, 4
lds r17, 0x5F
SBRC r17, 1
	call orangef
;---------------------------

;-------------------------
lds r16, (BASE+1)
cpi r16, 1
lds r17, 0x5F
SBRC r17, 1
	call redf

cpi r16, 2
lds r17, 0x5F
SBRC r17, 1
	call bluef

cpi r16, 3
lds r17, 0x5F
SBRC r17, 1
	call greenf

cpi r16, 4
lds r17, 0x5F
SBRC r17, 1
	call orangef
;---------------------------

;-------------------------
lds r16, (BASE+2)
cpi r16, 1
lds r17, 0x5F
SBRC r17, 1
	call redf

cpi r16, 2
lds r17, 0x5F
SBRC r17, 1
	call bluef

cpi r16, 3
lds r17, 0x5F
SBRC r17, 1
	call greenf

cpi r16, 4
lds r17, 0x5F
SBRC r17, 1
	call orangef
;---------------------------

;-------------------------
lds r16, (BASE+3)
cpi r16, 1
lds r17, 0x5F
SBRC r17, 1
	call redf

cpi r16, 2
lds r17, 0x5F
SBRC r17, 1
	call bluef

cpi r16, 3
lds r17, 0x5F
SBRC r17, 1
	call greenf

cpi r16, 4
lds r17, 0x5F
SBRC r17, 1
	call orangef
;---------------------------

ret
;-----------

;---Prio----
prio:
call bui
ldi r21, 0
ldi r20, 0
sts greens, r20
sts reds, r20
sts blues, r20
sts oranges, r20
call wait
call wait
call wait
call wait


prioloop:
lds r17, greens
cpi r17, 1
lds r17, 0x5F
sts greens, r21
SBRC r17, 1
	inc r20
SBRC r17, 1
	call greenf

lds r17, reds
cpi r17, 1
lds r17, 0x5F
sts reds, r21
SBRC r17, 1
	inc r20
SBRC r17, 1
	call redf

lds r17, oranges
cpi r17, 1
lds r17, 0x5F
sts oranges, r21
SBRC r17, 1
	inc r20
SBRC r17, 1
	call orangef

lds r17, blues
cpi r17, 1
lds r17, 0x5F
sts blues, r21
SBRC r17, 1
	inc r20
SBRC r17, 1
	call bluef

cpi r20, 4
BRNE prioloop

ret
;----------

;--Button Interrupt-------
bui:
sei 
CBI DDRD, 2
ldi r16, 0b00000111
sts PCICR, r16
ldi r16, 0b00000001
sts PCMSK0, r16
sts PCMSK1, r16
ldi r16, 0b00001000
sts PCMSK2, r16
ldi r16, 0b00000011
sts EICRA, r16
ldi r16, 0b00000001
out EIMSK, r16
ret
;--------------

;---RPRO_SELECT----
pro_select:
ldi r16, 0b00000000
out eimsk, r16
lds r16, counter
inc r16
sts counter, r16
ldi r20, LOW(redf)
ldi r21, HIGH(redf)
ldi r22, 1

cpi r16, 1
lds r17, 0x5F
SBRC r17, 1
	sts task1_select, r22


cpi r16, 2
lds r17, 0x5F
SBRC r17, 1
	sts task2_stack, r20
cpi r16, 2
lds r17, 0x5F
SBRC r17, 1
	sts (task2_stack-1), r21

cpi r16, 3
lds r17, 0x5F
SBRC r17, 1
	sts task3_stack, r20
cpi r16, 3
lds r17, 0x5F
SBRC r17, 1
	sts (task3_stack-1), r21

cpi r16, 4
lds r17, 0x5F
SBRC r17, 1
	sts task4_stack, r20
cpi r16, 4
lds r17, 0x5F
SBRC r17, 1
	sts (task4_stack-1), r21


ldi r16, 1
sts reds, r16
ldi r16, 1
st z+, r16
ldi r16, LOW(redf)
st -x, r16
ldi r16, HIGH(redf)
st -x, r16
reti
;-----------
;---BPRO_SELECT1---
pro_select1:
ldi r16, 0b00000000
sts pcmsk0, r16 
lds r16, counter
inc r16
sts counter, r16

ldi r20, LOW(bluef)
ldi r21, HIGH(bluef)
ldi r22, 2
cpi r16, 1
lds r17, 0x5F
SBRC r17, 1
	sts task1_select, r22


cpi r16, 2
lds r17, 0x5F
SBRC r17, 1
	sts task2_stack, r20
cpi r16, 2
lds r17, 0x5F
SBRC r17, 1
	sts (task2_stack-1), r21

cpi r16, 3
lds r17, 0x5F
SBRC r17, 1
	sts task3_stack, r20
cpi r16, 3
lds r17, 0x5F
SBRC r17, 1
	sts (task3_stack-1), r21

cpi r16, 4
lds r17, 0x5F
SBRC r17, 1
	sts task4_stack, r20
cpi r16, 4
lds r17, 0x5F
SBRC r17, 1
	sts (task4_stack-1), r21


ldi r16, 1
sts blues, r16
ldi r16, 2
st z+, r16
ldi r16, LOW(bluef)
st -x, r16
ldi r16, HIGH(bluef)
st -x, r16
reti
;----------------
;---GPRO_SELECT2----
pro_select2:
ldi r16, 0b00000000
sts pcmsk1, r16
lds r16, counter
inc r16
sts counter, r16

ldi r20, LOW(greenf)
ldi r21, HIGH(greenf)
ldi r22, 3
cpi r16, 1
lds r17, 0x5F
SBRC r17, 1
	sts task1_select, r22


cpi r16, 2
lds r17, 0x5F
SBRC r17, 1
	sts task2_stack, r20
cpi r16, 2
lds r17, 0x5F
SBRC r17, 1
	sts (task2_stack-1), r21

cpi r16, 3
lds r17, 0x5F
SBRC r17, 1
	sts task3_stack, r20
cpi r16, 3
lds r17, 0x5F
SBRC r17, 1
	sts (task3_stack-1), r21

cpi r16, 4
lds r17, 0x5F
SBRC r17, 1
	sts task4_stack, r20
cpi r16, 4
lds r17, 0x5F
SBRC r17, 1
	sts (task4_stack-1), r21


ldi r16, 1
sts greens, r16
ldi r16, 3
st z+, r16
ldi r16, LOW(greenf)
st -x, r16
ldi r16, HIGH(greenf)
st -x, r16
reti
;------------------
;---OPRO_SELECT3----
pro_select3:
ldi r16, 0b00000000
sts pcmsk2, r16
lds r16, counter
inc r16
sts counter, r16

ldi r20, LOW(orangef)
ldi r21, HIGH(orangef)
ldi r22, 4
cpi r16, 1
lds r17, 0x5F
SBRC r17, 1
	sts task1_select, r22

cpi r16, 2
lds r17, 0x5F
SBRC r17, 1
	sts task2_stack, r20
cpi r16, 2
lds r17, 0x5F
SBRC r17, 1
	sts (task2_stack-1), r21

cpi r16, 3
lds r17, 0x5F
SBRC r17, 1
	sts task3_stack, r20
cpi r16, 3
lds r17, 0x5F
SBRC r17, 1
	sts (task3_stack-1), r21

cpi r16, 4
lds r17, 0x5F
SBRC r17, 1
	sts task4_stack, r20
cpi r16, 4
lds r17, 0x5F
SBRC r17, 1
	sts (task4_stack-1), r21
ldi r16, 1
sts oranges, r16
ldi r16, 4
st z+, r16
ldi r16, LOW(orangef)
st -x, r16
ldi r16, HIGH(orangef)
st -x, r16
reti
;-----------------
;---RED---
REDF:
LDI r17, 5 
RED:
	SBI PortD, 4
	call WAIT
	CBI PortD, 4
	call WAIT
	dec r17
BRNE RED
ret
;--------

;---BLUE---
BLUEF:
LDI r17, 5
BLUE:
	SBI PortD, 5
	call WAIT
	CBI PortD, 5
	call WAIT
	dec r17
	BRNE BLUE
ret
;--------

;---ORANGE---
ORANGEF:
LDI r17, 5
ORANGE:
	SBI PortD, 6
	call WAIT
	CBI PortD, 6
	call WAIT
	dec r17
	BRNE ORANGE
ret
;---------

;---GREEN-----
GREENF:
LDI r17, 5
GREEN:
	SBI PortD, 7
	call WAIT
	CBI PortD, 7
	call WAIT
	dec r17
	BRNE GREEN
ret
;-------------

;---WAIT--------
WAIT:
call delay
	call delay
	call delay
	call delay
	call delay
	call delay
	call delay
	call delay
	call delay
	call delay
	call delay
	call delay
	call delay
	call delay
	call delay
	call delay
	call delay
	call delay
	call delay
	call delay
	call delay
	call delay
	call delay
	call delay
	call delay
	call delay
	call delay
	call delay
	call delay
	call delay
	call delay
ret
;-----------------------------------------
;-----DELAY------------------------------------------
delay:
LDI r16, 255
LDI r18, 255
LDI r19, 255
LDI r20, 255
LDI r21, 255
LDI r22, 255
LDI r23, 255
LDI r24, 255
LDI r25, 255
LDI r26, 255
delay1:
		delay2:
			NOP
			NOP
			NOP
			NOP
			NOP
			NOP
			NOP
			NOP
			NOP
			NOP
			NOP
			NOP
			dec r18
				delay3:
					NOP
					NOP
					NOP
					NOP
					
					dec r19
						delay4:
							NOP
							NOP
							NOP
							NOP
							dec r20
								delay5:
									NOP
									NOP
									NOP
									NOP
									dec r21
										delay6:
											NOP
											NOP
											NOP
											NOP
											dec r22
												delay7:
													NOP
													NOP
													NOP
													NOP
													dec r23
														delay8:
															NOP
															NOP
															NOP
															NOP
															dec r24
																delay9:
																	NOP
																	NOP
																	NOP
																	NOP
																	dec r25
																		delay10:
																			NOP
																			NOP
																			NOP
																			NOP
																			dec r26
																		BRNE delay10
																BRNE delay9
															
														BRNE delay8
												BRNE delay7
										BRNE delay6
								BRNE delay5
						BRNE delay4
				BRNE delay3
			BRNE delay2
	DEC r16
	BRNE delay1
ret
;-------------------------------------------------------------------------