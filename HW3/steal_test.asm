.data
destination_pocket: .byte 0
.align 2
state:        
    .byte 0         # bot_mancala       	(byte #0)
    .byte 0         # top_mancala       	(byte #1)
    .byte 6         # bot_pockets       	(byte #2)
    .byte 6         # top_pockets        	(byte #3)
    .byte 0         # moves_executed	(byte #4)
    .byte 'T'    # player_turn        		(byte #5)
    # game_board                     		(bytes #6-end)
    .asciiz
    "0004040404040404000505050100"
.text
.globl main
main:
la $a0, state
lb $a1, destination_pocket
jal steal
# You must write your own code here to check the correctness of the function implementation.
la		$a0, state		
jal		print_board				# jump to print_board and save position to $ra


li $v0, 10
syscall

.include "hw3.asm"
