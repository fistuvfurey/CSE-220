# Aidan Furey
# afurey
# 112622264

############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################

.text

load_game:
	move 	$s0, $a0		# $s0 = $a0 (save address of state)

	# Open the file.
	li		$v0, 13		# $v0 = 13 (open file syscall code)
	move 	$a0, $a1		# $a0 = $a1 (move address of the filename string)
	li		$a1, 0		# $a1 = 0 (flag for reading from a file)
	syscall
	move 	$t0, $v0		# $t0 = $v0 (save the file descriptor)
	
	li		$t4, 1		# $t4 = 1 (line_number)
	li		$t5, 0		# $t5 = 0 (flag that indicates how many chars read into current pocket)
	li		$t6, 0		# $t6 = 0 (previous_char, reverts back to zero for every two chars read)
	li		$t7, 0		# $t7 = 0 (digit place)
	addi	$s1, $s0, 6			# $s1 = $s0 + 6 (starting address of asciiz string 
	read_file:
		# Read the file.
		li		$v0, 14		# $v0 = 14 (open file syscall code)
		move 	$a0, $t0		# $a0 = $t0 ($a0 = file descriptor)
		addi	$sp, $sp, -4			# $sp = $sp + -4 (allocate 4 bytes of memory on stack for the char we are reading)
		move 	$a1, $sp		# $a1 = $sp ($a1 = address of buffer to hold the one char)
		li		$a2, 1		# $a2 = 1 (maximum chars to be read is 1)
		syscall

		move 	$t1, $v0		# $t1 = $v0 (save the return value of syscall 14)
		lb		$t2, 0($sp)		# Load char we have read
		# $t2 contains the char we just read.

		# If the current char is a newline char, discard and continue. 
		li		$t3, '\r'		# $t3 = '\r'
		beq		$t2, $t3, new_line	# if $t2 == $t3 then new_line
		li		$t3, '\n'		# $t3 = '\n'
		beq		$t2, $t3, new_line	# if $t2 == $t3 then new_line
		# Else, update GameState struct. 

		# Check current line_number and initialize data field in GameState accordingly. 
		li		$t3, 1		# $t3 = 1
		beq		$t4, $t3, initialize_top_mancala	# if $t4 == $t3 then initialize_top_mancala (if line_number == 1)
		li		$t3, 2		# $t3 = 2
		beq		$t4, $t3, initialize_bot_mancala	# if $t4 == $t3 then initialize_bot_mancala (if line_number == 2)
		li		$t3, 3		# $t3 = 3
		beq		$t4, $t3, initialize_num_pockets	# if $t4 == $t3 then initialize_num_pockets (if line_number == 3)
		li		$t3, 4		# $t3 = 4
		beq		$t4, $t3, initialize_top_row	# if $t4 == $t3 then initialize_top_row (if line_number == 4) 
		li		$t3, 5		# $t3 = 5
		beq		$t4, $t3, initialize_bot_row	# if $t4 == $t3 then initialize_bot_row (if line_number == 5) 


		# If end-of-file, break loop. 
		li		$t3, 0		# $t3 = 0
		bne		$t1, $t3, read_file	# if $t1 != $t3 then read_file
	# *** End of read_file loop ***
	j		postamble				# jump to postamble
	
	# Increment new_line and loop again to next line. 
	new_line:
		# If the char is a newline char, and we are at line 1, 2, or 3, we may need to update some data fields if
		# digit_place == 0. 
		li		$t3, 1		# $t3 = 1
		beq		$t4, $t3, leaving_line1	# if $t4 == $t3 then leaving_line1
		li		$t3, 2		# $t3 = 2 
		beq		$t4, $t3, leaving_line2	# if $t4 == $t3 then leaving_line2
		li		$t3, 3		# $t3 = 3
		beq		$t4, $t3, leaving_line3	# if $t4 == $t3 then leaving_line3

		leaving_line1:
			# If we are leaving line 1 and digit_place == 1, then we have to initialize top_mancala.
			
		
		
		
		# If the previous char was also a newline char, no need to increment line_number, just continue loop.
		li		$t3, '\n'		# $t3 = '\n'
		beq		$t6, $t3, read_file	# if $t6 == $t3 then read_file
		li		$t3, '\r'		# $t3 = '\r'
		beq		$t6, $t3, read_file	# if $t6 == $t3 then read_file
		# Else, line_number++ and save this char.
		move 	$t6, $t2		# $t6 = $t2 (save this char)
		addi	$t4, $t4, 1			# $t4 = $t4 + 1 (line_number++)
		li		$t7, 0		# $t7 = 0 (set digit place to 0 since we are moving onto a new line)
		j		read_file				# jump to read_file

	initialize_top_mancala:
		# First, let's check to see if this is the first digit.
		beqz $t7, is_first_top_mancala
		# Else, this is the second digit.
		# First, we want to update game_board string with this char.
		# $t2 should be a char.
		sb		$t2, 0($s1)		# update second char of game_board
		addi	$t2, $t2, -48			# $t2 = $t2 + -48 (char -> int)
		add		$t6, $t2, $t6		# $t6 = $t2 + $t6 ($t6 = proper value of stones)
		sb		$t6, 1($s0)		# initialize top_mancala
		j		read_file				# jump to read_file

	initialize_bot_mancala:
		sb		$t2, 0($s0)		# initialize bot_mancala
		move 	$t6, $t2		# $t6 = $t2 (save this char)
		j		read_file				# jump to read_file

	initialize_num_pockets:
		sb		$t2, 2($s0)		# initialize bot_pockets
		sb		$t2, 3($s0)		# initialize top_pockets
		move 	$t6, $t2		# $t6 = $t2 (save this char)
		j		read_file				# jump to read_file

	initialize_top_row:
		# Check digit place.
		beqz $t7, is_first_digit # If digit_place flag is 0, save digit as proper value and move on.
		# Else, this is the second digit.
		add		$t6, $t2, $t6		# $t6 = $t2 + $t6 ($t6 = proper value of stones in pocket)
		addi	$t6, $t6, 48			# $t6 = $t6 + 48 (convert int -> char)
		sb		$t6, 0($s1)		# store in game_board string
		addi	$s1, $s1, 1			# $s1 = $s1 + 1 (increment game_board address)
		li		$t7, 0		# $t7 = 0 (set digit_place flag to 0)
		j		read_file				# jump to read_file
		
		
	is_first_digit:
		# Multiply digit by 10 to get proper value, save, and move on.
		li		$t3, 10		# $t3 = 10
		mult	$t2, $t3			# $t2 * $t3 = Hi and Lo registers
		mflo	$t6					# copy Lo to $t6
		li		$t7, 1		# $t7 = 1 (set digit_place flag to 1)
		j		read_file				# jump to read_file

	is_first_top_mancala:		
		sb		$t2, 0($s1)		# Update first char of game_board string with the current char
		addi	$s1, $s1, 1			# $s1 = $s1 + 1 (increment address of game_board string)
		addi	$t6, $t2, -48			# $t6 = $t2 + -48 (convert char to int and save in $t6) 
		# Multiply digit by 10 to get proper value.
		li		$t3, 10		# $t3 = 10
		mult	$t6, $t3			# $t6 * $t3 = Hi and Lo registers
		mflo	$t6					# copy Lo to $t6
		# $t6 now contains proper value of first digit.
		li		$t7, 1		# $t7 = 1 (change digit_place flag to 1)
		j		read_file				# jump to read_file
		
	initialize_bot_row:
		
	postamble:
		jr $ra
get_pocket:
	jr $ra
set_pocket:
	jr $ra
collect_stones:
	jr $ra
verify_move:
	jr  $ra
execute_move:
	jr $ra
steal:
	jr $ra
check_row:
	jr $ra
load_moves:
	jr $ra
play_game:
	jr  $ra
print_board:
	jr $ra
write_board:
	jr $ra
	
############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################