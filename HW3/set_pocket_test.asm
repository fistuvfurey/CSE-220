.data
player: .byte 'B'
distance: .byte 1
size: .word 101
.align 2
state:        
    .byte 0         # bot_mancala       	(byte #0)
    .byte 1         # top_mancala       	(byte #1)
    .byte 6         # bot_pockets       	(byte #2)
    .byte 6         # top_pockets        	(byte #3)
    .byte 2         # moves_executed	(byte #4)
    .byte 'B'    # player_turn        		(byte #5)
    # game_board                     		(bytes #6-end)
    .asciiz
    "0104040404040420010240000500"
.text
.globl main
main:
la $a0, state
lb $a1, player
lb $a2, distance
lw $a3, size
jal set_pocket
# You must write your own code here to check the correctness of the function implementation.
la		$t0, state		# 
lb		$t2, 2($t0)		# load # of pockets 
add		$t2, $t2, $t2		# $t2 = $t2 + $t2 (double pockets)
add		$t2, $t2, $t2		# $t2 = $t2 + $t2
addi	$t2, $t2, 4		# $t2 = $t2 + 4


li		$t3, 0		# $t3 = 0 (int i = 0) 

addi	$t0, $t0, 6			# $t0 = $t0 + 6
loop:
    lb		$t1, 0($t0)		# load char
    # print char 
    li		$v0, 11		# $v0 = 11
    move 	$a0, $t1		# $a0 = $t1
    syscall

    addi	$t0, $t0, 1			# $t0 = $t0 + 1
    addi	$t3, $t3, 1			# $t3 = $t3 + 1 (i++)       
    blt		$t3, $t2, loop	# if $t3 < $t2 then loop

li $v0, 10
syscall

.include "hw3.asm"
