.include "configuration.inc"
.set    GPBASE,   0x3f200000
.set    GPSET0,         0x1c
.set    GPCLR0,         0x28
.set    GPLEV0,         0x34
.set    STCLO,    0x3f003004
/*LEDS MASK =0b0000G0000G0000Y00000YRR000000000*/
.set    LED1,      0b00001000000000000000000000000000
.set    LED2,      0b00000000010000000000000000000000
.set    LED3,      0b00000000000000100000000000000000
.set    LED4,      0b00000000000000000000100000000000
.set    LED5,      0b00000000000000000000010000000000
.set    LED6,      0b00000000000000000000001000000000
.set    LEDALL,   0b00001000010000100000111000000000
.set    BUZZER,        0x010

        /* Stack init for SVC mode */
	mov r0, #0b11010011
	msr cpsr_c, r0
	mov sp, #0x8000000

/* SET R0,R1,R8,R9 and turn off all leds */
start:
        ldr r0, =GPBASE
        ldr r1, =STCLO
        bl clearled
        ldr r7, =50000
        ldr r8, =1
        ldr r9, =1000000 /* 1 000 000 us = 1.00 SECONDS */
        push {lr}
        bl startmusic
        pop {lr}

/*EACH ROUND OF THE GAME*/
round:
        cmp r9, #000000
        beq endgame
        push {lr}
        bl randomwait
        pop {lr}
        push {lr}
        bl randomled
        pop {lr}
        push {lr}
        bl clearled
        pop {lr}
        b round

/*TURN OFF ALL LEDS */
clearled:
        push {r2}

        ldr r2, =LEDALL
        str r2, [r0, #GPCLR0]

        pop {r2}
        bx lr

/*TURN ON A RANDOM LED*/
randomled:
        /*GENERATE RANDOM NUMBER*/
        ldr r4, [r1]
        and r4,r4,#0b00111
        
        cmp r4, #0b00000
        ldreq r2, =LED1
        streq r2, [r0,#GPSET0]
        beq checkp2

        cmp r4, #0b00001
        ldreq r2, =LED2
        streq r2, [r0,#GPSET0]
        beq checkp2

        cmp r4, #0b00010      
        ldreq r2, =LED3
        streq r2, [r0,#GPSET0]
        beq checkp2

        cmp r4, #0b00011    
        ldreq r2, =LED3
        streq r2, [r0,#GPSET0]
        beq checkp2

        cmp r4, #0b00100
        ldreq r2, =LED4
        streq r2, [r0,#GPSET0]
        beq checkp1

        cmp r4, #0b00101   
        ldreq r2, =LED4
        streq r2, [r0,#GPSET0]
        beq checkp1

        cmp r4, #0b00110     
        ldreq r2, =LED5
        streq r2, [r0,#GPSET0]
        beq checkp1

        cmp r4, #0b00111  
        ldreq r2, =LED6
        streq r2, [r0,#GPSET0]
        beq checkp1                                                                                                     

/*GENERATE A RANDOM WAIT*/
randomwait:
        push {r2,r4}

        ldr r4, [r1]
        and r4,r4,#0b00011
        
        cmp r4, #0b00000
        ldreq r2, =575000

        cmp r4, #0b00001
        ldreq r2, =350000

        cmp r4, #0b00010
        ldreq r2, =175000

        cmp r4, #0b00011
        ldreq r2, =250000

        ldr r4,[r1]
        add r2, r4, r2
rwloop: ldr r4,[r1]
        cmp r4,r2
        blt rwloop

        pop {r2,r4}
        bx lr

/*WAIT 0.5 SECONDS*/
wait:
        push {r2,r4}

        ldr r2, =500000
        ldr r4,[r1]
        add r2, r4, r2
wloop:  ldr r4,[r1]
        cmp r4,r2
        blt wloop

        pop {r2,r4}
        bx lr

/*PLAYER 1 SHOULD PRESS HIS/HER BTN, OTHERWISE IT IS ENDGAME*/
checkp1:
        ldr r4, [r1]
        add r5, r4, r9

ret1: ldr r3, [r0,#GPLEV0]
        tst r3, #0b00100
        beq nextround
        tst r3, #0b01000
        beq winnerp1
	ldr r4,[r1]
        cmp r4,r5
        blt ret1

        b winnerp2

/*PLAYER 2 SHOULD PRESS HIS/HER BTN, OTHERWISE IT IS ENDGAME*/
checkp2:
        ldr r4, [r1]
        add r5, r4, r9

ret2:   ldr r3, [r0,#GPLEV0]
        tst r3, #0b01000
        beq nextround
	tst r3, #0b00100
        beq winnerp2
	ldr r4,[r1]
        cmp r4, r5
        blt ret2

        b winnerp1

/*PREPARE THE NEXT ROUND*/
nextround: 
        add r8,r8,#1
        sub r9, r9, r7
        bx lr

/* PLAYER 1 WINS */
winnerp1:
        push {lr}
        bl clearled
        pop {lr}
        ldr r2, =LED6
        str r2, [r0,#GPSET0]
        b endgame

/* PLAYER 2 WINS */
winnerp2:
        push {lr}
        bl clearled
        pop {lr}
        ldr r2, =LED5
        str r2, [r0,#GPSET0]
        b endgame

/* ENDGAME */
endgame:
        tst r8, #0b0001
                ldrne r2, =LED4
                strne r2, [r0,#GPSET0]
        tst r8, #0b0010
                ldrne r2, =LED3
                strne r2, [r0,#GPSET0]
        tst r8, #0b0100
                ldrne r2, =LED2
                strne r2, [r0,#GPSET0]
        tst r8, #0b1000
                ldrne r2, =LED1
                strne r2, [r0,#GPSET0]
        push {lr}        
        bl endmusic
        pop {lr}
        /*IF YOU PRESS 1,2,1,2 YOU WILL RESTART THE GAME*/
restart1:       ldr r3, [r0,#GPLEV0]
                tst r3, #0b00100
                bne restart1
restart2:       ldr r3, [r0,#GPLEV0]             
                tst r3, #0b01000
                bne restart2
restart3:       ldr r3, [r0,#GPLEV0]
                tst r3, #0b00100
                bne restart3
restart4:       ldr r3, [r0,#GPLEV0]             
                tst r3, #0b01000
                bne restart4
                
                b start

end:    b end

/* COUNTDOWN TO RACE START MARIO KART */
startmusic:
        push {r2,r4,r5}
        push {lr}
        /*RE 1 SECOND*/
        ldr r2, =LED6
        str r2, [r0, #GPSET0]

        ldr r2, =BUZZER
        ldr r4, [r1]
        ldr r5, =1000000
        add r5,r4,r5

sm1:    ldr r4, [r1]
        str r2, [r0, #GPSET0]
        bl notere
        str r2, [r0, #GPCLR0]
        bl notere
        cmp r4,r5
        blt sm1
        bl wait @0.5 pause

        /*RE 1 SECOND*/
        ldr r2, =LED5
        str r2, [r0, #GPSET0]
        
        ldr r2, =BUZZER
        ldr r4, [r1]
        ldr r5, =1000000
        add r5,r4,r5

sm2:    ldr r4, [r1]
        str r2, [r0, #GPSET0]
        bl notere
        str r2, [r0, #GPCLR0]
        bl notere
        cmp r4,r5
        blt sm2
        bl wait @0.5 pause

        /*RE 0.5 SECONDS */
        ldr r2, =LED4
        str r2, [r0, #GPSET0]
        ldr r2, =LED3
        str r2, [r0, #GPSET0]
        
        ldr r2, =BUZZER
        ldr r4, [r1]
        ldr r5, =500000
        add r5,r4,r5

sm3:    ldr r4, [r1]
        str r2, [r0, #GPSET0]
        bl notere
        str r2, [r0, #GPCLR0]
        bl notere
        cmp r4,r5
        blt sm3
        bl wait @0.5 pause

        /*RE2 2 SECONDS*/
        ldr r2, =LED2
        str r2, [r0, #GPSET0]
        ldr r2, =LED1
        str r2, [r0, #GPSET0]
                
        ldr r2, =BUZZER
        ldr r4, [r1]
        ldr r5, =2000000
        add r5,r4,r5

sm4:    ldr r4, [r1]
        str r2, [r0, #GPSET0]
        bl notere2
        str r2, [r0, #GPCLR0]
        bl notere2
        cmp r4,r5
        blt sm4
        bl wait @0.5 pause
        ldr r2, =LEDALL
        str r2, [r0, #GPCLR0]
        pop {lr}
        pop {r2,r4,r5}
        bx lr

/* ENDGAME MUSIC */
endmusic:
        push {r2,r4,r5}
        push {lr}
        /*RE 0.25 SECONDS*/
        ldr r2, =BUZZER
        ldr r4, [r1]
        ldr r5, =250000
        add r5,r4,r5

sm5:    ldr r4, [r1]
        str r2, [r0, #GPSET0]
        bl notere
        str r2, [r0, #GPCLR0]
        bl notere
        cmp r4,r5
        blt sm5
        bl wait @0.5 pause

        /*DO 1.5 SECONDS*/
        
        ldr r2, =BUZZER
        ldr r4, [r1]
        ldr r5, =1500000
        add r5,r4,r5

sm6:    ldr r4, [r1]
        str r2, [r0, #GPSET0]
        bl notedo
        str r2, [r0, #GPCLR0]
        bl notedo
        cmp r4,r5
        blt sm6
        bl wait @0.5 pause

        pop {lr}
        pop {r2,r4,r5}
        bx lr

/* NOTES */
notedo: push {r0,r1,r2,r3,r4}
        ldr r0, =STCLO
        ldr r3,[r0]
        ldr r4, =3968
        add r4, r3, r4
retdo: ldr r3,[r0]
        cmp r3,r4
        blt retdo
        pop {r0,r1,r2,r3,r4}
        bx lr

notere: push {r0,r1,r2,r3,r4}
        ldr r0, =STCLO
        ldr r3,[r0]
        ldr r4, =3413
        add r4, r3, r4
retre: ldr r3,[r0]
        cmp r3,r4
        blt retre
        pop {r0,r1,r2,r3,r4}
        bx lr

notemi: push {r0,r1,r2,r3,r4}
        ldr r0, =STCLO
        ldr r3,[r0]
        ldr r4, =3030
        add r4, r3, r4
retmi: ldr r3,[r0]
        cmp r3,r4
        blt retmi
        pop {r0,r1,r2,r3,r4}
        bx lr

notefa: push {r0,r1,r2,r3,r4}
        ldr r0, =STCLO
        ldr r3,[r0]
        ldr r4, =2865
        add r4, r3, r4
retfa: ldr r3,[r0]
        cmp r3,r4
        blt retfa
        pop {r0,r1,r2,r3,r4}
        bx lr

notesol: push {r0,r1,r2,r3,r4}
        ldr r0, =STCLO
        ldr r3,[r0]
        ldr r4, =2551
        add r4, r3, r4
retsol: ldr r3,[r0]
        cmp r3,r4
        blt retsol
        pop {r0,r1,r2,r3,r4}
        bx lr

notela: push {r0,r1,r2,r3,r4}
        ldr r0, =STCLO
        ldr r3,[r0]
        ldr r4, =2273
        add r4, r3, r4
retla: ldr r3,[r0]
        cmp r3,r4
        blt retla
        pop {r0,r1,r2,r3,r4}
        bx lr

notesi: push {r0,r1,r2,r3,r4}
        ldr r0, =STCLO
        ldr r3,[r0]
        ldr r4, =2224
        add r4, r3, r4
retsi: ldr r3,[r0]
        cmp r3,r4
        blt retsi
        pop {r0,r1,r2,r3,r4}
        bx lr

notedo2: push {r0,r1,r2,r3,r4}
        ldr r0, =STCLO
        ldr r3,[r0]
        ldr r4, =1912
        add r4, r3, r4
retdo2: ldr r3,[r0]
        cmp r3,r4
        blt retdo2
        pop {r0,r1,r2,r3,r4}
        bx lr

notere2: push {r0,r1,r2,r3,r4}
        ldr r0, =STCLO
        ldr r3,[r0]
        ldr r4, =1703
        add r4, r3, r4
retre2: ldr r3,[r0]
        cmp r3,r4
        blt retre2
        pop {r0,r1,r2,r3,r4}
        bx lr
