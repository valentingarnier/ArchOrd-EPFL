.equ BALL, 0x1000 ; ball state (its position and velocity)
.equ PADDLES, 0x1010 ; paddles position
.equ SCORES, 0x1018 ; game scores
.equ LEDS, 0x2000 ; LED addresses
.equ BUTTONS, 0x2030 ; Button addresses

;BEGIN: main
	addi a0, zero, 4
	addi a1, zero, 3
	addi t1, zero, 1
	addi t2, zero, 1
	stw a0, BALL(zero)
	stw a1, BALL+4(zero)
	stw t1, BALL+8(zero)
	stw t2, BALL+12(zero)

	addi t3, zero, 3
	addi t4, zero, 3
	stw t3, PADDLES(zero)
	stw t4, PADDLES+4(zero)
	
main:
	addi sp, zero, LEDS 
	call clear_leds
	ldw a0, BALL(zero)
	ldw a1, BALL+4(zero)

	call set_pixel
	call hit_test
	call move_ball
	call move_paddles
	call draw_paddles
	br main
;END: main


;BEGIN: clear_leds
clear_leds:
	stw zero, LEDS(zero)
	stw zero, LEDS+4(zero)
	stw zero, LEDS+8(zero)
	ret
;END: clear_leds

;BEGIN: set_pixel
set_pixel:
	srli t1, a0, 2 ; diviser x par 4
	slli t1, t1, 2 ; remultiplier par 4 pour savoir quel tableau de LEDS (0, 4, 8)
	andi t2, a0, 3 ; mask pour faire un modulo sur x par 4
	slli t2, t2, 3 ; on cree l'index i ( multiplication par 8)
	add t2, t2, a1 ; on cree l'index i (en ajoutant y)
	
	addi t3, zero, 1 ; on cree un mask 00...01 (32 bits)
	sll t3, t3, t2	 ; On modifie le mask pour obtenir 0...01...0 avec le 1 a l'index qu'on veut changer (t2)
	ldw t4, LEDS(t1) ; On met dans t4 notre word qui contient notre index 
	or t4, t4, t3 ; En faisant or entre le word initial et notre mask on modifie que le bit a notre index t2 qu'on transforme en 1
	stw t4, LEDS(t1) ; On updade notre ancien word avec le nouveau cad avec notre led a l'index t2 allumée	
	ret
;END: set_pixel

;BEGIN: hit_test
hit_test:
	ldw t0, BALL(zero) ; ball position x
	ldw t1, BALL+4(zero) ; ball position y
	ldw t2, BALL+8(zero) ; ball velocity x
	ldw t3, BALL+12(zero) ; ball velocity y

	ldw t6, PADDLES(zero) ; position y du paddle 1
	ldw t7, PADDLES+4(zero) ; position y du paddle 2

	

	cmpeqi t4, t0, 0
	cmpeqi t5, t0, 11
	or t4, t4, t5 ; si on est sur un des deux bords verticaux
	beq t4, zero, test_y ; si rien a changer, alors go tester y
	sub t2, zero, t2 ; pour partir d'un bord vertical on change juste la coordonnee x de la velocity
	stw t2, BALL+8(zero)	
test_y:
	cmpeqi t4, t1, 0
	cmpeqi t5, t1, 7
	or t4, t4, t5 ; si on est sur un des deux bords horizontaux
	beq t4, zero, hit_test_ret ; si rien a changer, alors return
	sub t3, zero, t3 ; pour partir d'un bord vertical on change juste la coordonnee x de la velocity
	stw t3, BALL+12(zero)
hit_test_ret:
	ret
;END: hit_test

;BEGIN: move_ball
move_ball:
	ldw t0, BALL(zero) ; ball position x
	ldw t1, BALL+4(zero) ; ball position y
	ldw t2, BALL+8(zero) ; ball velocity x
	ldw t3, BALL+12(zero) ; ball velocity y

	add t4, t0, t2 ; coordonnee x de la nouvelle position
	add t5, t1, t3 ; coordonnee y de la nouvelle position

	stw t4, BALL(zero) ; on update
	stw t5, BALL+4(zero)
	ret
;END: move_ball

;BEGIN: move_paddles
move_paddles:
	ldw t0, PADDLES(zero) ; position y du premier paddle
	ldw t1, PADDLES+4(zero) ; position y du deuxieme paddle (a droite)
	ldw t2, BUTTONS+4(zero) ; edgecapture
buttons_3:
	andi t3, t2, 8 ; recuperer bouton 3
	cmpeqi t4, t1, 1
	bne t4, zero, buttons_2
	beq t3, zero, buttons_2
	addi t1, t1, -1
	stw t1, PADDLES+4(zero) 

buttons_2:
	andi t3, t2, 4; recupere le bouton 2
	cmpeqi t4, t1, 6
	bne t4, zero, buttons_1
	beq t3, zero, buttons_1
	addi t1, t1, 1
	stw t1, PADDLES+4(zero)	 

buttons_1:
	andi t3, t2, 2; recuperer le bouton 1
	cmpeqi t4, t0, 6
	bne t4, zero, buttons_0
	beq t3, zero, buttons_0
		addi t0, t0, 1
		stw t0, PADDLES(zero)

buttons_0:
	andi t3, t2, 1 ; recuperer le bouton 0
	cmpeqi t4, t0, 1
	bne t4, zero, end
	beq t3, zero, end
	addi t0, t0, -1
	stw t0, PADDLES(zero)
end:
stw zero, BUTTONS+4(zero)
ret
;END: move_paddles

;BEGIN: draw_paddles
draw_paddles:
	ldw a1, PADDLES(zero) 
	addi sp, sp, -4
	stw ra, 0(sp)
	
	addi a0, zero, 0
	call set_pixel
	addi a1, a1, 1
	call set_pixel
	addi a1, a1, -2
	call set_pixel

	ldw a1, PADDLES+4(zero) 
	
	addi a0, zero, 11
	call set_pixel
	addi a1, a1, 1
	call set_pixel
	addi a1, a1, -2
	call set_pixel
	 
	ldw ra, 0(sp)
	addi sp, sp, 4
	
ret
;END: draw_paddles
