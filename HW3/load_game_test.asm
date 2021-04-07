.data
board_filename: .asciiz "game01.txt"
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

move 	$t0, $v0		# $t0 = $v0
move 	$t1, $v1		# $t1 = $v1

li		$v0, 1	# $v0 = 1
move 	$a0, $t0		# $a0 = $t0
syscall
move 	$a0, $t1		# $a0 = $t1
syscall

# You must write your own code here to check the correctness of the function implementation.

li $v0, 10
syscall

.include "hw3.asm"
