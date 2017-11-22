.equ BALL, 0x1000 ; ball state (its position and velocity)
.equ PADDLES, 0x1010 ; paddles position
.equ SCORES, 0x1018 ; game scores
.equ LEDS, 0x2000 ; LED addresses
.equ BUTTONS, 0x2030 ; Button addresses

;BEGIN: main

	stw zero, SCORES(zero) ; score initial player 1
	stw zero, SCORES+4(zero) ; score initial player 2
	
reset:
	addi a0, zero, 5 ; ball x
	addi a1, zero, 4 ; ball y
	addi t0, zero, 1 ; velocity x
	addi t1, zero, 1 ; velocity y
	stw a0, BALL(zero)
	stw a1, BALL+4(zero)
	stw t0, BALL+8(zero)
	stw t1, BALL+12(zero)

	addi t2, zero, 3 
	addi t3, zero, 3
	stw t2, PADDLES(zero) ; paddle 1 milieu
	stw t3, PADDLES+4(zero) ; paddle 2 milieu

	addi t4, zero, 0
	addi t5, zero, 0
	addi sp, zero, LEDS 

	
main:

	call move_paddles

	call hit_test

	bne v0, zero, score_managing
	call move_ball
	call clear_leds
	
	ldw a0, BALL(zero)
	ldw a1, BALL+4(zero)

	call set_pixel
	call draw_paddles
	call wait
	br main
score_managing:
	slli t0, v0, 2
	addi t0, t0, -4
	ldw t1, SCORES(t0)
	addi t1, t1, 1
	stw t1, SCORES(t0)
	call display_score
	
	
	ldw t1, SCORES+4(t0)
	ldw t3, SCORES(t0)
	cmpeqi t2, t1, 0xA
	cmpeqi t4, t3, 0xA
	or t5, t4, t2
	bne t5, zero, reset_integral 
	call wait
	call wait
	call wait
	call wait
	call wait
	br reset


reset_integral: 
	break

;END: main


wait:
	addi s1, zero, 1
	slli s1, s1, 20
loop:
	cmpeqi s2, s1, 0
	addi s1, s1, -1
	beq s2, zero, loop
	ret

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
	
	addi v0, zero, 0
	
test_bord_horizontal:
	cmpeqi t4, t1, 0
	cmpeqi t5, t1, 7
	or t4, t4, t5 ; si on est sur un des deux bords horizontaux
	beq t4, zero, test_bord_gauche ; si rien a changer, alors return
	sub t3, zero, t3 ; pour partir d'un bord horizontal on change juste la coordonnee y de la velocity
	stw t3, BALL+12(zero)

test_bord_gauche:
	cmpeqi t4, t0, 1
	beq t4, zero, test_bord_droite
	beq t1, t6, hit_paddle_front ; si on est en face des trois cases -> milieu
	addi t6, t6, 1
	beq t1, t6, hit_paddle_front ; -> front bas 
	addi t6, t6, -2
	beq t1, t6, hit_paddle_front ; -> front haut
	
	add t0, t0, t2 ; futur pos ball x
	add t1, t1, t3 ; futur pos ball y

	cmpeq t4, t1, t6 ; si notre futur y est sur le y du paddle
	cmpeqi t5, t0, 0 ; si notre futur x est sur le x du paddle
	
	sub t0, t0, t2
	sub t1, t1, t3 ; on retourne dans le hit paddle alors qu'il faut pas
	
	beq t4, zero, test_partie_inferieur_paddle_1 ; si notre futur y n'y est pas on se barre
	beq t4, t5, velocity_inverse ; si la position est bien ce qu'on veut on inverse la velocity
	addi v0, v0, 2 	
	br hit_test_ret
	
	;l'autre x maintenant
test_bord_droite:
	cmpeqi t4, t0, 10
	beq t4, zero, hit_test_ret ; si on est pas sur le bord droite on finit le hit test
	beq t1, t7, hit_paddle_front ; front milieu
	addi t7, t7, 1
	beq t1, t7, hit_paddle_front ; font bas 
	addi t7, t7, -2
	beq t1, t7, hit_paddle_front ; front haut

	add t0, t0, t2 ; calcul de la pos futur de la balle -> x
	add t1, t1, t3 ; -> y

	cmpeq t4, t1, t7 ; futur y est sur le paddle
	cmpeqi t5, t0, 11 ; futur x est sur le paddle 

	sub t0, t0, t2
	sub t1, t1, t3 ; on retourne dans le hit paddle alors qu'il faut pas

	beq t4, zero, test_partie_inferieur_paddle_2
	beq t4, t5, velocity_inverse
	addi v0, v0, 1
	br hit_test_ret
	
test_partie_inferieur_paddle_1:
	addi t6, t6, 2
	add t0, t0, t2
	add t1, t1, t3
	cmpeq t4, t1, t6 ; si notre futur y est sur le paddle
	cmpeqi t5, t0, 0 ; si notre futur x est sur notre paddle
	sub t0, t0, t2
	sub t1, t1, t3
	beq t4, zero, winner2 ; si notre futur y n'y est pas on se barre
	beq t4, t5, velocity_inverse ; si la position est bien ce qu'on veut on inverse la velocity	

test_partie_inferieur_paddle_2:
	addi t7, t7, 2
	add t0, t0, t2
	add t1, t1, t3
	cmpeq t4, t1, t7 ; si notre futur y est sur le paddle
	cmpeqi t5, t0, 11 ; si notre futur x est sur notre paddle
	sub t0, t0, t2
	sub t1, t1, t3
	beq t4, zero, winner1 ; si notre futur y n'y est pas on se barre
	beq t4, t5, velocity_inverse ; si la position est bien ce qu'on veut on inverse la velocity	

winner1:
	addi v0, v0, 1
	br hit_test_ret

winner2:
	addi v0, v0, 2
	br hit_test_ret

velocity_inverse:
	sub t2, zero, t2
	stw t2, BALL+8(zero)
	sub t3, zero, t3
	stw t3, BALL+12(zero)

	cmpeqi t4, t1, 0
	cmpeqi t5, t1, 7
	or t4, t4, t5
	bne t4, zero, changing_velocity
	br hit_test_ret
	
changing_velocity:
 	sub t3, zero, t3
	stw t3, BALL+12(zero)
	br hit_test_ret

hit_paddle_front:
	sub t2, zero, t2
	stw t2, BALL+8(zero)
	br hit_test_ret
		
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

;BEGIN: display_score
display_score:
	ldw t0, SCORES(zero) ; score player 1
	ldw t1, SCORES+4(zero) ; score player 2

	slli t0, t0, 2
	ldw t2, font_data(t0)

	slli t1, t1, 2
	ldw t3, font_data(t1)
	addi t5, zero, 64
	ldw t4, font_data(t5)

	stw t2, LEDS(zero)
	stw t3, LEDS+8(zero)
	stw t4, LEDS+4(zero)
ret
;END: display_score
font_data:
	.word 0x7E427E00 ; 0
	.word 0x407E4400 ; 1
	.word 0x4E4A7A00 ; 2
	.word 0x7E4A4200 ; 3
	.word 0x7E080E00 ; 4
	.word 0x7A4A4E00 ; 5
	.word 0x7A4A7E00 ; 6
	.word 0x7E020600 ; 7
	.word 0x7E4A7E00 ; 8
	.word 0x7E4A4E00 ; 9
	.word 0x7E127E00 ; A
	.word 0x344A7E00 ; B
	.word 0x42423C00 ; C
	.word 0x3C427E00 ; D
	.word 0x424A7E00 ; E
	.word 0x020A7E00 ; F
	.word 0x00181800 ; separator


