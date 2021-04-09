# erase this line and type your first and last name here in a comment
# erase this line and type your Net ID here in a comment (e.g., jmsmith)
# erase this line and type your SBU ID number here in a comment (e.g., 111234567)

############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################

.text

load_game:
	# Preamble
	addi	$sp, $sp, -32			# $sp = $sp + -32
	sw		$s0, 0($sp)		# address of state
	sw		$s1, 4($sp)		# num_stones
	sw		$s2, 8($sp)		# line_number
	sw		$s3, 12($sp)		# # of pockets 
	sw		$s4, 16($sp)		# file_descriptor
	sw		$s5, 20($sp)		# current_char
	sw		$s6, 24($sp)		# number of stones in bot_mancala
	sw		$s7, 28($sp)		# address of board string
	

	move 	$s0, $a0		# $s0 = $a0 (save the address of state)
	addi	$s7, $s0, 6			# $s7 = $s0 + 6 (add 6 to address of state to get address of board. 
	
	li		$s1, 0		# $s1 = 0 (num_stones)

	# Open file. 
	li		$v0, 13		# $v0 = 13
	move 	$a0, $a1		# $a0 = $a1 (move address of the filename string)
	li		$a1, 0		# $a1 = 0 (flag for reading from a file)
	syscall
	move 	$s4, $v0		# $s4 = $v0 (save the file descriptor)

	# If the file descriptor is negative then the file does not exist. 
	bltz $s4, file_dne 
	
	li		$s2, 1		# $s2 = 1 (line_number)
	addi	$sp, $sp, -4			# $sp = $sp + -4 (allocate 4 bytes on stack for the char we are reading)
	read_file:
		# Read the file. 
		li		$v0, 14		# $v0 = 14
		move 	$a0, $s4		# $a0 = $s4 ($a0 = file descriptor) 
		move 	$a1, $sp		# $a1 = $sp ($a1 = address of buffer)
		li		$a2, 1		# $a2 = 1 (the maximum chars to read is 1)
		syscall
		lb		$s5, 0($sp)		# load the char from the stack

		# If line_number < 4
		li		$t0, 4		# $t0 = 4 (line_number 4)
		blt		$s2, $t0, parse_line123	# if $s2 < $t0 then parse_line123
		# Else, line_number >= 4
		j		parse_line45				# jump to parse_line45
		
		parse_line123:
			# Figure out what line we are on and branch accordingly. 
			li		$t0, 1		# $t0 = 1
			beq		$s2, $t0, line1	# if $s2 == $t0 then line1 (if line_number == 1)
			li		$t0, 2		# $t0 = 2
			beq		$s2, $t0, line2	# if $s2 == $t0 then line2 (if line_number == 2) 
			li		$t0, 3		# $t0 = 3
			beq		$s2, $t0, line3	# if $s2 == $t0 then line3 (if line_number == 3) 
		
		parse_line45:
			# Set loop variables: while i < # of pockets * 2 - 1
			li		$t1, 0		# $t1 = 0 ($t1 = i) 
			li		$t2, 2		# $t2 = 2
			mult	$s3, $t2			# $s3 * $t2 = Hi and Lo registers
			mflo	$t2					# copy Lo to $t2 
			addi	$t2, $t2, -1			# $t2 = $t2 + -1 ($t2 = ((# of pockets) * 2) - 1)
			
			sb		$s5, 0($s7)		# store first char of line in board string

			# Update num_stones. 
			addi	$s5, $s5, -48			# $s5 = $s5 + -48 (char -> int)
			li		$t3, 10		# $t3 = 10
			mult	$t3, $s5			# $t3 * $s5 = Hi and Lo registers
			mflo	$t3					# copy Lo to $t3
			add		$s1, $s1, $t3		# $s1 = $s1 + $t3 (update the value of num_stones) 
			
			addi	$s7, $s7, 1			# $s7 = $s7 + 1 (increment address of board string)
			li		$t6, 0		# $t6 = 0 (digit_place_flag)
			initialize_board:
				# This will loop for i < (# of pockets * 2) - 1.
				# We will repeat this loop twice for lines 4 and 5. 
				# digit_place_flag will keep track of proper value of the current char we are reading. It will flip each iteration.
				# When digit_place_flag is 0, multiply value by 10. When 1, just add value to num_stones.
				# Read in char.
				# If digit_place_flag == 0 then flip to 1.

				# Read char from file. 
				li		$v0, 14		# $v0 = 14
				move 	$a0, $s4		# $a0 = $s4 ($a0 = file descriptor)
				move 	$a1, $sp		# $a1 = $sp ($a1 = address of buffer)
				li		$a2, 1		# $a2 = 1
				syscall
				# Load char from buffer and store in board string. 
				lb		$t0, 0($sp)		# load char into $t0	
				sb		$t0, 0($s7)		# initialize board string

				# Now, update num_stones.
				# First, convert char -> int. 
				addi	$t4, $t0, -48			# $t4 = $t0 + -48 (char -> int)

				# If digit_place_flag == 0, value stays the same.
				beqz $t6, digit_place_is_0
				# Else digit_place_flag is 1 so multiply by 10 and add to num_stones. 
				li		$t3, 10		# $t3 = 10
				mult	$t3, $t4			# $t3 * $t4 = Hi and Lo registers
				mflo	$t4					# copy Lo to $t4 ($t4 = value of stones)
				add		$s1, $t4, $s1		# $s1 = $t4 + $s1 (update num_stones)
				# Flip digit_place_flag to 0. 
				li		$t6, 0		# $t6 = 0
				j		increment				# jump to increment
				
				digit_place_is_0:
					add		$s1, $s1, $t4		# $s1 = $s1 + $t4 (update num_stones)
					li		$t6, 1		# $t6 = 1 (flip digit_place_flag to 0)

				increment:
					addi	$s7, $s7, 1			# $s7 = $s7 + 1 (increment address of board string)
					addi	$t1, $t1, 1			# $t1 = $t1 + 1 (i++)
					blt		$t1, $t2, initialize_board	# if $t1 < $s3 then initialize_board
			# *** End of initialize_board loop ***
			
			# If line is not line 5, then move on to next line.
			li		$t1, 5		# $t1 = 5
			bne		$s2, $t1, while_newline	# if $s2 != $t1 then while_newline
			# Else, we just finihed parsing line 5.
			# Now, lets finish initializing board by setting the last two chars of the string to be the number of stones in the 
			# bot_mancala.
			# $s6 = # of stones in bot_mancala. 
			li		$t0, 10		# $t0 = 10
			div		$s6, $t0			# $s6 / $t0
			mflo	$t1					# $t1 = floor($s6 / $t0) ($t1 = first digit)
			mfhi	$t2					# $t2 = $s6 mod $t0 ($t2 = second digit)

			addi	$t1, $t1, 48			# $t1 = $t1 + 48 (int -> char)
			addi	$t2, $t2, 48			# $t2 = $t2 + 48 (int -> char)

			sb		$t1, 0($s7)		# set 2nd to last char of board string to first digit
			sb		$t1, 1($s7)		# set last char of board string to second digit

			# Initialize moves to 0
			li		$t0, 0		# $t0 = 0
			sb		$t0, 4($s0)		# initialize moves to 0 
			
			# Initialize player_turn to 'B'.
			li		$t0, 'B'		# $t0 = 'B'
			sb		$t0, 5($s0)		# initialize player_turn to 'B'

			# Finished initializing GameState succcesfully.
			li		$t0, 1		# $t0 = 1
			beq		$t7, $t0, too_many_pockets_error	# if $t7 == $t0 then too_many_stones_error
			# Else, we have a valid number of pockets. 
			# Return total number of pockets.
			li		$t0, 2		# $t0 = 2
			mult	$s3, $t0			# $s3 * $t0 = Hi and Lo registers
			mflo	$t7					# copy Lo to $v1
			j		postamble				# jump to postamble
			
			too_many_pockets_error:
				li		$t7, 0		# $t7 = 0
				j		postamble				# jump to postamble
				
			line1:
				# Read next char, see if it is a second digit or a newline char. 
				li		$v0, 14		# $v0 = 14
				move 	$a0, $s4		# $a0 = $s4 ($a0 = file descriptor)
				move 	$a1, $sp		# $a1 = $sp ($a1 = address of buffer)
				li		$a2, 1		# $a2 = 1 (the maximum chars to read is 1)
				syscall
				lb		$t0, 0($sp)		# load next char into $t0

				# If $t0 is a newline char. 
				li		$t1, '\r'		# $t1 = '\r'
				beq		$t0, $t1, end_line1	# if $t0 == $t1 then end_line1
				li		$t1, '\n'		# $t1 = '\n'
				beq		$t0, $t1, end_line1	# if $t0 == $t1 then end_line1
				# Else, $t0 is an int char. 
				# Intialize top_mancala.
				# Number of stones in top_mancala = (int) $s5 * 10 + (int) $t0
				# First, initalize the first two chars of gameboard. 
				# $s7 = address of board string
				sb		$s5, 0($s7)		# first char is first int char we read
				sb		$t0, 1($s7)		# second char is the second int char we read
				addi	$s7, $s7, 2			# $s7 = $s7 + 2 (increment base address of board string)
				
				addi	$s5, $s5, -48			# $s5 = $s5 + -48 (char -> int)
				addi	$t0, $t0, -48			# $t0 = $t0 + -48 (char -> int)
				# Get proper value of stones in top_mancala
				li		$t1, 10		# $t1 = 10
				mult	$t1, $s5			# $t1 * $s5 = Hi and Lo registers
				mflo	$t1					# copy Lo to $t1 ($t1 = proper value of first digit)
				add		$t1, $t1, $t0		# $t1 = $t1 + $t0 ($t1 = # of stones in top_mancala)
				sb		$t1, 1($s0)		# intialize top_mancala in state
				add		$s1, $s1, $t1		# $s1 = $s1 + $t1 (update # of stones)
				
				while_newline:
					# Read next char.
					li		$v0, 14		# $v0 = 14
					move 	$a0, $s4		# $a0 = $s4 ($a0 = file descriptor)
					move 	$a1, $sp		# $a1 = $sp ($a1 = address of buffer)
					li		$a2, 1		# $a2 = 1 (the maximum chars to read is 1)
					syscall
					lb		$t0, 0($sp)		# load next char into $t0	
					# If char == '\n' then the char immediately after is the first char of next line. 
					# line_number++ and jump to read_file.
					li		$t1, '\n'		# $t1 = '\n'
					beq		$t0, $t1, is_last_char	# if $t0 == $t1 then is_last_char
					# Else, the char may be a '\r' char.
					# If it is, loop again to discard it.
					li		$t1, '\r'		# $t1 = '\r'
					beq		$t0, $t1, while_newline	# if $t0 == $t1 then while_newline
					# Else, the char is another digit. We cannot have another digit so there is an error.
					# Check what line number we are on.
					# If we are on line 1 or 2 then there are too many stones in the mancalas.
					li		$t1, 1		# $t1 = 1
					beq		$s2, $t1, line12_error	# if $s2 == $t1 then line12_error
					# Else, we must be on line 3 and there are too many pockets.
					j		too_many_pockets_error				# jump to too_many_pockets_error
					
					line12_error:
						li		$t6, 0		# $t6 = 0 (return value for $v0)
						# Get to the end of the line.
						j		while_newline				# jump to while_newline
						
					is_last_char:
						addi	$s2, $s2, 1			# $s2 = $s2 + 1 (line_number++)
						j		read_file				# jump to read_file
				
				end_line1:
					# Intitialize top_mancala
					# $s5 = char representataion of number of stones in top_mancala
					# Frist, intitialize first two chars of gameboard. 
					li		$t1, '0'		# $t1 = '0'
					sb		$t1, 0($s7)		# first char of board is '0' since this is a single digit number of stones in top_mancala. 
					sb		$s5, 1($s7)		# digit char of stones in top_mancala
					addi	$s7, $s7, 2			# $s7 = $s7 + 2 (increment base address of board string)
					
					addi	$s5, $s5, -48			# $s5 = $s5 + -48 (char -> int)
					sb		$s5, 1($s0)		# intitialize top_mancala in state
					add		$s1, $s1, $s5		# $s1 = $s1 + $s5 (update # of stones)
					
					# If $t0 is the last digit in the line then read_file. 
					li		$t1, '\n' 		# $t1 = '\n'
					beq		$t0, $t1, last_char	# if $t0 == $t1 then last_char
					# Else, loop to last digit in line. 
					j		while_newline				# jump to while_newline 

					last_char:
						addi	$s2, $s2, 1			# $s2 = $s2 + 1
						 j		read_file				# jump to read_file
						 
			line2:
				# Read next char, see if it is a second digit or a newline char.
				li		$v0, 14		# $v0 = 14
				move 	$a0, $s4		# $a0 = $s4 ($a0 = file descriptor)
				move 	$a1, $sp		# $a1 = $sp ($a1 = address of buffer)
				li		$a2, 1		# $a2 = 1 (the maximum chars to read is 1) 
				syscall
				lb		$t0, 0($sp)		# load next char into $t0

				# If $t0 is a newline char. 
				li		$t1, '\r'		# $t1 = '\r'
				beq		$t0, $t1, end_line2	# if $t0 == $t1 then end_line2
				li		$t1, '\n'		# $t1 = '\n'
				beq		$t0, $t1, end_line2	# if $t0 == $t1 then end_line2
				# Else, $t0 is an int char.
				# Intitialze bot_mancala. 
				# Number of stones in bot_mancala = (int) $s5 * 10 + (int) $t0
				# We also need to save the correct number of stones in the bot_mancala 
				addi	$s5, $s5, -48			# $s5 = $s5 + -48 (char -> int)
				addi	$t0, $t0, -48			# $t0 = $t0 + -48 (char -> int)
				li		$t1, 10		# $t1 = 10
				mult	$s5, $t1			# $s5 * $t1 = Hi and Lo registers
				mflo	$t1					# copy Lo to $t1
				add		$s6, $t1, $t0		# $s6 = $t1 + $t0 ($s6 = # of stones in bot_mancala)
				sb		$s6, 0($s0)		# initialize bot_mancala in state
				add		$s1, $s1, $s6		# $s1 = $s1 + $s6 (update the number of stones)
				
				# Get to the end of the line. 
				j		while_newline				# jump to while_newline
				
				end_line2:
					# Intialize bot_mancala
					# $s5 = char representation of number of stones in top_mancala. 
					# We want to copy $s5 into $s6 to save for later so when we get to the end of the board string we can 
					# Initialize the last two chars to the number of stones in the bot_mancala.
					# Let's save it as an int. 
					addi	$s6, $s5, -48			# $s6 = $s5 + -48 (char -> int)
					sb		$s6, 0($s0)		# initialize bot_mancala in state
					add		$s1, $s6, $s1		# $s6 = $s6 + $s1 (update the number of stones)
					
					# If $t0 is the last digit in the line then last_char. 
					li		$t1, '\n'		# $t1 = '\n'
					beq		$t0, $t1, last_char	# if $t0 == $t1 then last_char
					# Else, loop to the last digit in the line. 
					j		while_newline				# jump to while_newline
			
			line3:
				# Read next char, see if it is a second digit or a newline char. 
				li		$v0, 14		# $v0 = 14
				move 	$a0, $s4		# $a0 = $s4 ($a0 = file descriptor) 
				move 	$a1, $sp		# $a1 = $sp ($a1 = address of buffer)
				li		$a2, 1		# $a2 = 1 (the maximum chars to read is 1)
				syscall
				lb		$t0, 0($sp)		# load next char into $t0

				# If $t0, is a newline char. 
				li		$t1, '\r'		# $t1 = '\r'
				beq		$t0, $t1, end_line3	# if $t0 == $t1 then end_line3
				li		$t1, '\n'		# $t1 = '\n'
				beq		$t0, $t1, end_line3	# if $t0 == $t1 then end_line3
				# Else, $t0 is an int char. 
				# Initialize top and bottom pockets. 
				# # of pockets = (int) $s5 * 10 + (int) $t0
				addi	$s5, $s5, -48			# $s5 = $s5 + -48 (char -> int) 
				addi	$t0, $t0, -48			# $t0 = $t0 + -48 (char -> int)
				li		$t1, 10		# $t1 = 10
				mult	$s5, $t1			# $s5 * $t1 = Hi and Lo registers
				mflo	$t1					# copy Lo to $t1
				add		$s5, $t1, $t0		# $s5 = $t1 + $t0 ($5 = # of pockets)
				# Mutiply pockets by 2 to get total pockets. 
				li		$t1, 2		# $t1 = 2
				mult	$s5, $t1			# $s5 * $t1 = Hi and Lo registers
				mflo	$t3					# copy Lo to $t3
				# Check to make sure that we don't have more than 98 pockets.
				li		$t1, 98		# $t1 = 98
				bgt		$t3, $t1, too_many_pockets_error	# if $t3 > $t1 then too_many_pockets_error
				# Else, let $t7 = $s6 (return the number of pockets)
				move 	$t7, $s5		# $t7 = $s5
				j		initialize_pockets				# jump to initialize_pockets
				
					
				initialize_pockets:
					sb		$s5, 2($s0)		# initialize bot_pockets
					sb		$s5, 3($s0)		# initialize top_pockets 
					move 	$s3, $s5		# $s3 = $s5 (save # of pockets)
					# Get to the end of the line. 
					j		while_newline				# jump to while_newline
				
				end_line3:
					# Intitialize bot_pockets and top_pockets in state. 
					# $s5 = # of pockets in top and bottom. 
					addi	$s5, $s5, -48			# $s5 = $st + -48 (char -> int)
					sb		$s5, 2($s0)		# initialize bot_pockets
					sb		$s5, 3($s0)		# initialize top_pockets
					move 	$s3, $s5		# $s3 = $s5 (save # of pockets)
					# If $t0 is the last digit in the line then last_char
					li		$t1, '\n'		# $t1 = '\n'
					beq		$t0, $t1, last_char	# if $t0 == $t1 then last_char
					# Else, loop to the last digit in the line. 
					j		while_newline				# jump to while_newline

	file_dne:
		li		$v0, -1		# $v0 = -1 (return -1)
		li		$v1, -1		# $v1 = -1 (return -1)
		j		return				# jump to return
		
	postamble:
		# Close the file.
		li		$v0, 16		# $v0 = 16
		move 	$a0, $s4		# $a0 = $s4 ($a0 = file descriptor)
		syscall
		addi	$sp, $sp, 4			# $sp = $sp + 4 (reallocate memory on stack)
		# If $t6 = 0, then there were too many stones in the mancalas.
		beqz $t6, too_many_stones
		# If num_stones > 99 then return 0 in $v0.  
		li		$t0, 99		# $t0 = 99
		bgt		$s1, $t0, too_many_stones	# if $s1 > $t0 then too_many_stones
		# Else, return 1 in $v0.
		li		$v0, 1		# $v0 = 1
		j		restore_registers				# jump to restore_registers
		
		too_many_stones:
			li		$v0, 0		# $v0 = 0
			j		restore_registers				# jump to restore_registers
			

			
		restore_registers:
			move 	$v1, $t7		# $v1 = $t7 (return num_pockets)
			# Restore registers. 
			return:
				lw		$s0, 0($sp)
				lw		$s1, 4($sp)		
				lw		$s2, 8($sp)		
				lw		$s3, 12($sp)		 
				lw		$s4, 16($sp)		
				lw		$s5, 20($sp)		
				lw		$s6, 24($sp)		 
				lw		$s7, 28($sp)		
				addi	$sp, $sp, 32		# $sp = $sp + 32
				jr $ra
get_pocket:
	# Preamble
	addi	$sp, $sp, -20			# $sp = $sp + -20
	sw		$s0, 0($sp)		# state
	sw		$s1, 4($sp)		# player 
	sw		$s2, 8($sp)		# distance
	sw		$s3, 12($sp)		# base address of board string 
	sw		$s4, 16($sp)		# top_pockets
	
	# Save arguments
	move 	$s0, $a0		# $s0 = $a0
	move 	$s1, $a1		# $s1 = $a1
	move 	$s2, $a2		# $s2 = $a2
	
	lb		$s4, 3($s0)		# load top_pockets
	addi	$t0, $s4, -1			# $t0 = $s4 + -1
	bgt		$s2, $t0, invalid_distance	# if $s2 > $t0 then invalid_distance
	# Else, distance is valid. Continue.
	# Get base address of board string. 
	addi	$s3, $s0, 6			# $s3 = $s0 + 6
	
	# Check to see what player we have.
	li		$t0, 'T'		# $t1 = 'T'
	beq		$s1, $t0, is_t_player	# if $s1 == $t0 then is_t_player
	li		$t0, 'B'		# $t0 = 'B'
	beq		$s1, $t0, is_b_player	# if $s1 == $t0 then is_b_player
	# Else, player is invalid. 
	li		$v0, -1		# $v0 = -1 (return -1)
	j		return_pocket				# jump to return_pocket
	
	is_t_player:
		# Is top player. 
		# We are looking at the top row. 
		addi	$s3, $s3, 2			# $s3 = $s3 + 2 (skip the first two chars of the string since those are the top_mancala)
		# Get the first char of the pocket.
		# Multiply distance by 2.
		li		$t0, 2		# $t0 = 2
		mult	$t0, $s2			# $t0 * $s2 = Hi and Lo registers
		mflo	$t0					# copy Lo to $t0
		add		$s3, $s3, $t0		# $s3 = $s3 + $t0 ($s3 = first char of pocket)
		j		get_stones				# jump to get_stones
		
	is_b_player:
		# Is bottom player.
		# We are looking at the bottom row. 
		# Get address of first char of pocket. 
		# Multiply top_pockets by 2.
		li		$t1, 2		# $t1 = 2
		mult	$s4, $t1			# $s4 * $t1 = Hi and Lo registers
		mflo	$t1					# copy Lo to $t1
		add		$t1, $t1, $t1		# $t1 = $t1 + $t1 (double to account for bot_pockets)
		# Add 2 to account for top_mancala.
		addi	$t1, $t1, 2			# $t1 = $t1 + 2
		# Multiply distance by 2. 
		li		$t0, 2		# $t0 = 2
		mult	$t0, $s2			# $t0 * $s2 = Hi and Lo registers
		mflo	$t0					# copy Lo to $t0
		# Subtract distance from offset.
		sub		$t1, $t1, $t0		# $t1 = $t1 - $t0
		addi	$t1, $t1, -2			# $t1 = $t1 + -2 (now we have offset for first digit char)
		# Add offset to base address. 
		add		$s3, $s3, $t1		# $s3 = $s3 + $t1 (add offset to base address to get address of first char of pocket. 
		j		get_stones				# jump to get_stones
		
	get_stones:
		# $s3 = address of first char in pocket.
		lb		$t1, 0($s3)		# load first char
		addi	$t1, $t1, -48			# $t1 = $t1 + -48 (convert char -> int) 
		lb		$t2, 1($s3)		# load second char
		addi	$t2, $t2, -48			# $t2 = $t2 + -48 (convert char -> int) 
		
		# Multiply first digit by 10 then add second digit to get proper value.
		li		$t0, 10		# $t0 = 10
		mult	$t0, $t1			# $t0 * $t1 = Hi and Lo registers
		mflo	$t1					# copy Lo to $t1 ($t1 = first digit with proper value)
		
		add		$v0, $t1, $t2		# $v0 = $t1 + $t2 ($v0 = num_stones in pocket)
		j		return_pocket				# jump to return_pocket
		
	invalid_distance:
		li		$v0, -1		# $v0 = -1
		
	return_pocket:
		# Postamble
		lw		$s0, 0($sp)
		lw		$s1, 4($sp)
		lw		$s2, 8($sp)
		lw		$s3, 12($sp)
		lw		$s4, 16($sp)
		addi	$sp, $sp, 20			# $sp = $sp + 20
		jr $ra
set_pocket:
	# Preamble
	addi	$sp, $sp, -28			# $sp = $sp + -28
	sw		$s0, 0($sp)		# state
	sw		$s1, 4($sp)		# player
	sw		$s2, 8($sp)		# distance
	sw		$s3, 12($sp)		# size
	sw		$s4, 16($sp)		# top_pockets
	sw		$s5, 20($sp)		# game_board string base address
	sw		$ra, 24($sp)		# store return address
	
	# Save arguments
	move 	$s0, $a0		# $s0 = $a0
	move 	$s1, $a1		# $s1 = $a1
	move 	$s2, $a2		# $s2 = $a2
	move 	$s3, $a3		# $s3 = $a3

	# Get base address of game_board.
	addi	$s5, $s0, 6			# $s5 = $s0 + 6
	
	# Check to see if size is valid.
	li		$t0, 99		# $t0 = 99
	bgt		$s3, $t0, invalid_size	# if $s3 > $t0 then invalid_size
	bltz $s3, invalid_size
	# Else, size is valid.

	# Validate distance for this board.
	lb		$s4, 3($s0)		# load top_pockets
	addi	$t0, $s4, -1			# $t0 = $s4 + -1
	bgt		$s2, $t0, invalid_set_distance	# if $s2 > $t0 then invalid_set_distance
	# Else, distance is valid. 
	# Double distance.
	add		$s2, $s2, $s2		# $s2 = $s2 + $s2
	# Check to see what player we have.
	li		$t0, 'T'		# $t0 = 'T'
	beq		$t0, $s1, set_pocket_t	# if $t0 == $s1 then set_pocket_t
	li		$t0, 'B'		# $t0 = 'B'
	beq		$t0, $s1, set_pocket_b	# if $t0 == $s1 then set_pocket_b
	# Else, player is invalid.
	li		$v0, -1		# $v0 = -1
	j		return_set_pocket				# jump to return_set_pocket
	
	set_pocket_t:
		# Convert int size to char.
		move 	$a0, $s3		# $a0 = $s3
		jal		convert_to_char				# jump to convert_to_char and save position to $ra
		move 	$t0, $v0		# $t0 = $v0 (first digit char)
		move 	$t1, $v1		# $t1 = $v1 (second digit char)
		# $s5 = base address of game_board
		addi	$s5, $s5, 2			# $s5 = $s5 + 2 (skip the first two chars of the string since those are the top_mancala)
		add		$s5, $s5, $s2		# $s5 = $s5 + $s2 (add offset to base address of string)
		j		set_stones				# jump to set_stones
	
	set_pocket_b:
		# Convert int size to char. 
		move 	$a0, $s3		# $a0 = $s3
		jal		convert_to_char				# jump to convert_to_char and save position to $ra
		move 	$t0, $v0		# $t0 = $v0 (first digit char)
		move 	$t1, $v1		# $t1 = $v1 (second digit char)
		# Double top_pockets
		add		$s4, $s4, $s4		# $s4 = $s4 + $s4
		# Double again to account for bot_pockets
		add		$s4, $s4, $s4		# $s4 = $s4 + $s4
		addi	$s4, $s4, 2			# $s4 = $s4 + 2 (add 2 to account for top_mancala)
		sub		$s4, $s4, $s2		# $s4 = $s4 - $s2 (sub distance from offset)
		addi	$s4, $s4, -2			# $s4 = $s4 + -2 (now we have address of first digit)
		add		$s5, $s5, $s4		# $s5 = $s5 + $s4 (add offset to base address)
		j		set_stones				# jump to set_stones

	set_stones:
		# $s5 = address of string with proper offset
		# $t0 = first digit char
		# $t1 = second digit char
		sb		$t0, 0($s5)		# store first char in game_board
		sb		$t1, 1($s5)		# store second char in game_board
		move	$v0, $s3		# $v0 = $s3
		j		return_set_pocket				# jump to return_set_pocket

	invalid_set_distance:
		li		$v0, -1		# $v0 = -1
		j		return_set_pocket				# jump to return_set_pocket
		
	invalid_size:
		li		$v0, -2		# $v0 = -2
		j		return_set_pocket				# jump to return_set_pocket
			
	return_set_pocket:
		lw		$s0, 0($sp)		
		lw		$s1, 4($sp)
		lw		$s2, 8($sp)
		lw		$s3, 12($sp)
		lw		$s4, 16($sp)
		lw		$s5, 20($sp)		
		lw		$ra, 24($sp)		
		addi	$sp, $sp, 28			# $sp = $sp + 20
		jr $ra
collect_stones:
	addi	$sp, $sp, -20			# $sp = $sp + -20
	sw		$s0, 0($sp)		# state
	sw		$s1, 4($sp)		# player
	sw		$s2, 8($sp)		# stones
	sw		$s3, 12($sp)		# base addres of game_board string
	sw		$ra, 16($sp)		# save return address
	
	# Save arguments
	move 	$s0, $a0		# $s0 = $a0
	move 	$s1, $a1		# $s1 = $a1
	move 	$s2, $a2		# $s2 = $a2

	# Validate stones
	blez $s2, invalid_stones

	addi	$s3, $s0, 6			# $s3 = $s0 + 6 (get base address of game_board)
	
	# Check which player we have. 
	li		$t0, 'T'		# $t0 = 'T'
	beq		$t0, $s1, collect_stones_t	# if $t0 == $s1 then collect_stones_t
	li		$t0, 'B'		# $t0 = 'B'
	beq		$t0, $s1, collect_stones_b	# if $t0 == $s1 then collect_stones_b
	# Else, invalid player.
	li		$v0, -1		# $v0 = -1
	j		return_collect_stones				# jump to return_collect_stones
	
	collect_stones_t:
		# First update top_mancala in state.
		lb		$t0, 1($s0)		# load stones from top_mancala
		
		add		$t0, $t0, $s2		# $t0 = $t0 + $s2 (add stones to mancala)
		sb		$t0, 1($s0)		# store stones in top_mancala
		# $t0 = updated stones in top_mancala.
		# Convert to two digit char
		move 	$a0, $t0		# $a0 = $t0
		jal		convert_to_char				# jump to convert_to_char and save position to $ra
		move 	$t0, $v0		# $t0 = $v0 (first digit char)
		move 	$t1, $v1		# $t1 = $v1 (second digit char)
		sb		$t0, 0($s3)		# update first char of game_board
		sb		$t1, 1($s3)		# update second char of game_board
		j		return_collect_stones				# jump to return_collect_stones
		
	collect_stones_b:
		# First update bot_mancala in state. 
		lb		$t0, 0($s0)		# load stones from bot_mancala

		add		$t0, $t0, $s2		# $t0 = $t0 + $s2 (add stones to mancala)
		sb		$t0, 0($s0)		# store stones in bot_mancala
		# $t0 = updated stones in bot_mancala
		# Convert to two digit char. 
		move 	$a0, $t0		# $a0 = $t0
		jal		convert_to_char				# jump to convert_to_char and save position to $ra
		move 	$t0, $v0		# $t0 = $v0 (first digit char)
		move 	$t1, $v1		# $t1 = $v1 (second digit char)
		
		lb		$t2, 2($s0)		# load pockets
		add		$t2, $t2, $t2		# $t2 = $t2 + $t2 (double pockets)
		add		$t2, $t2, $t2		# $t2 = $t2 + $t2 (double pockets again to account for top row)

		add		$s3, $s3, $t2		# $s3 = $s3 + $t2 (add offest to base address)
		addi	$s3, $s3, 2			# $s3 = $s3 + 2 (add 2 to account for top_mancala)
		
		sb		$t0, 0($s3)		# update first digit of bot_mancala in game_board
		sb		$t1, 1($s3)		# update the second digit of bot_mancala in game_board
		j		return_collect_stones				# jump to return_collect_stones

	invalid_stones:
		li		$v0, -2		# $v0 = -2
		j		return_collect_stones				# jump to return_collect_stones
		
	return_collect_stones:
		lw		$s0, 0($sp)	
		lw		$s1, 4($sp)
		lw		$s2, 8($sp)	
		lw		$s3, 12($sp)	
		lw		$ra, 16($sp)	
		addi	$sp, $sp, 20			# $sp = $sp + 20
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

convert_to_char:
	# Converts a two digit integer to char
	move 	$t0, $a0		# $t0 = $a0 (int to convert)
	# Divide by 10. 
	li		$t1, 10		# $t1 = 10
	div		$t0, $t1			# $t0 / $t1
	mflo	$t2					# $t2 = floor($t0 / $t1)
	mfhi	$t3					# $t3 = $t0 mod $t1 
	# $t2 = first digit int
	# $t3 = second digit int
	addi	$t2, $t2, 48			# $t2 = $t2 + 48 (int -> char)
	addi	$t3, $t3, 48			# $t3 = $t3 + 48 (int -> char)
	# Return 
	move 	$v0, $t2		# $v0 = $t2 (return first digit char)
	move 	$v1, $t3		# $v1 = $t3 (return 2nd digit char)
	jr		$ra					# jump to $ra
	
	
	
	
	
############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################