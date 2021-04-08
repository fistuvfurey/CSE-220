.data
board_filename: .asciiz "gameE1.txt"
.align 2
state:        
    .byte 0         # bot_mancala       	(byte #0)
    .byte 0         # top_mancala       	(byte #1)
    .byte 0         # bot_pockets       	(byte #2)
    .byte 0         # top_pockets        	(byte #3)
    .byte 0         # moves_executed	(byte #4)
    .byte 'B'    # player_turn        		(byte #5)
    # game_board                     		(bytes #6-end)
    .asciiz
    "1111111111111111111111111111"
.text
.globl main
main:
la $a0, state
la $a1, board_filename
jal load_game

move $t0, $v0
move $t1, $v1

li $v0, 1
move $a0, $t0
syscall
move $a0, $t1
syscall


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
   # syscall

    addi	$t0, $t0, 1			# $t0 = $t0 + 1
    addi	$t3, $t3, 1			# $t3 = $t3 + 1 (i++)       
    blt		$t3, $t2, loop	# if $t3 < $t2 then loop




# You must write your own code here to check the correctness of the function implementation.

li $v0, 10
syscall

.include "hw3.asm"
