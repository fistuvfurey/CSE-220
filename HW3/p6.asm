.data
origin_pocket1: .byte 5
origin_pocket2: .byte 3
origin_pocket3: .byte 0
origin_pocket4: .byte 0

case1: .asciiz "Case1"
case2: .asciiz "Case2"
case3: .asciiz "Case3"
case4: .asciiz "Case4"
print_reg_s: .asciiz "Register $"
before_method_string: .asciiz "Before Method Call Values: \n"
after_method_string: .asciiz "After Method Call Values: \n"
returnend_string: .asciiz "Return end\n"
instruction_count_string: .asciiz "IC:"
student_board_string: .asciiz "Student board: \n"
correct_board_string: .asciiz "Correct board: \n"
boardend_string: .asciiz "Board end\n"
bot_man_string: .asciiz "Bot Mancala: "
top_man_string:  .asciiz "Top Mancala: "
bot_poc_string: .asciiz "Bot Pockets: "
top_poc_string: .asciiz "Top Pockets: "
mov_exe_string: .asciiz "Moves Done: "
play_turn_string: .asciiz "Player Turn: "
game_board_string1: .asciiz "Game Board \n"

.align 2
state1:        
    .byte 0         # bot_mancala       	(byte #0)
    .byte 0         # top_mancala       	(byte #1)
    .byte 6         # bot_pockets       	(byte #2)
    .byte 6         # top_pockets        	(byte #3)
    .byte 2         # moves_executed	(byte #4)
    .byte 'T'    # player_turn        		(byte #5)
    # game_board                     		(bytes #6-end)
    .asciiz
    "0004000404040404040404040400"
state1ans:        
    .byte 0         # bot_mancala       	(byte #0)
    .byte 0         # top_mancala       	(byte #1)
    .byte 6         # bot_pockets       	(byte #2)
    .byte 6         # top_pockets        	(byte #3)
    .byte 3         # moves_executed	(byte #4)
    .byte 'B'    # player_turn        		(byte #5)
    # game_board                     		(bytes #6-end)
    .asciiz
    "0004010505050004040404040400"    
state2:        
    .byte 0         # bot_mancala       	(byte #0)
    .byte 0         # top_mancala       	(byte #1)
    .byte 6         # bot_pockets       	(byte #2)
    .byte 6         # top_pockets        	(byte #3)
    .byte 12         # moves_executed	(byte #4)
    .byte 'T'    # player_turn        		(byte #5)
    # game_board                     		(bytes #6-end)
    .asciiz
    "0000010004040404040404040400"
state2ans:        
    .byte 0         # bot_mancala       	(byte #0)
    .byte 1         # top_mancala       	(byte #1)
    .byte 6         # bot_pockets       	(byte #2)
    .byte 6         # top_pockets        	(byte #3)
    .byte 13         # moves_executed	(byte #4)
    .byte 'T'    # player_turn        		(byte #5)
    # game_board                     		(bytes #6-end)
    .asciiz
    "0101020100040404040404040400"
state3:        
    .byte 6         # bot_mancala       	(byte #0)
    .byte 5         # top_mancala       	(byte #1)
    .byte 6         # bot_pockets       	(byte #2)
    .byte 6         # top_pockets        	(byte #3)
    .byte 0         # moves_executed	(byte #4)
    .byte 'T'    # player_turn        		(byte #5)
    # game_board                     		(bytes #6-end)
    .asciiz
    "0513000000000000000000000006"
state3ans:        
    .byte 6         # bot_mancala       	(byte #0)
    .byte 6         # top_mancala       	(byte #1)
    .byte 6         # bot_pockets       	(byte #2)
    .byte 6         # top_pockets        	(byte #3)
    .byte 1         # moves_executed	(byte #4)
    .byte 'B'    # player_turn        		(byte #5)
    # game_board                     		(bytes #6-end)
    .asciiz
    "0601010101010101010101010106"
state4:        
    .byte 6         # bot_mancala       	(byte #0)
    .byte 5         # top_mancala       	(byte #1)
    .byte 6         # bot_pockets       	(byte #2)
    .byte 6         # top_pockets        	(byte #3)
    .byte 0         # moves_executed	(byte #4)
    .byte 'T'    # player_turn        		(byte #5)
    # game_board                     		(bytes #6-end)
    .asciiz
    "0539000000000000000000000006"
state4ans:        
    .byte 6         # bot_mancala       	(byte #0)
    .byte 8         # top_mancala       	(byte #1)
    .byte 6         # bot_pockets       	(byte #2)
    .byte 6         # top_pockets        	(byte #3)
    .byte 1         # moves_executed	(byte #4)
    .byte 'B'    # player_turn        		(byte #5)
    # game_board                     		(bytes #6-end)
    .asciiz
    "0803030303030303030303030306"
.text
.include "macros.asm"
.globl main
main:

# test case 1
new_line
printAsciiLabel(case1)
new_line
printAsciiLabel(before_method_string)
fill_garbage_s
print_all_s_hex
print_spra_hex
la $a0, state1
lb $a1, origin_pocket1
jal execute_move
printAsciiLabel(after_method_string)
printAsciiLabel(student_board_string)
la $a0, state1
print_state($a0)
printAsciiLabel(correct_board_string)
la $a0, state1ans
print_state($a0)
printAsciiLabel(boardend_string)

print_returns_int
printAsciiLabel(returnend_string)
print_all_s_hex
print_spra_hex

# test case 2
new_line
printAsciiLabel(case2)
new_line
printAsciiLabel(before_method_string)
fill_garbage_s
print_all_s_hex
print_spra_hex
la $a0, state2
lb $a1, origin_pocket2
jal execute_move
printAsciiLabel(after_method_string)
printAsciiLabel(student_board_string)
la $a0, state2
print_state($a0)
printAsciiLabel(correct_board_string)
la $a0, state2ans
print_state($a0)
printAsciiLabel(boardend_string)

print_returns_int
printAsciiLabel(returnend_string)
print_all_s_hex
print_spra_hex

# test case 3
new_line
printAsciiLabel(case3)
new_line
printAsciiLabel(before_method_string)
fill_garbage_s
print_all_s_hex
print_spra_hex
la $a0, state3
lb $a1, origin_pocket3
jal execute_move
printAsciiLabel(after_method_string)
printAsciiLabel(student_board_string)
la $a0, state3
print_state($a0)
printAsciiLabel(correct_board_string)
la $a0, state3ans
print_state($a0)
printAsciiLabel(boardend_string)

print_returns_int
printAsciiLabel(returnend_string)
print_all_s_hex
print_spra_hex

# test case 4
new_line
printAsciiLabel(case4)
new_line
printAsciiLabel(before_method_string)
fill_garbage_s
print_all_s_hex
print_spra_hex
la $a0, state4
lb $a1, origin_pocket4
jal execute_move
printAsciiLabel(after_method_string)
printAsciiLabel(student_board_string)
la $a0, state4
print_state($a0)
printAsciiLabel(correct_board_string)
la $a0, state4ans
print_state($a0)
printAsciiLabel(boardend_string)

print_returns_int
printAsciiLabel(returnend_string)
print_all_s_hex
print_spra_hex
# You must write your own code here to check the correctness of the function implementation.
printAsciiLabel(instruction_count_string)


li $v0, 10
syscall

.include "hw3.asm"
