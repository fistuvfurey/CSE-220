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
	addi	$sp, $sp, -20			# $sp = $sp + -20
	sw		$s0, 0($sp)		# state
	sw		$s1, 4($sp)		# origin_pocket
	sw		$s2, 8($sp)		# distance
	sw		$s3, 12($sp)		# current_player
	sw		$ra, 16($sp)		# save return address
		
	# Save arguments
	move 	$s0, $a0		# $s0 = $a0
	move 	$s1, $a1		# $s1 = $a1
	move 	$s2, $a2		# $s2 = $a2
	
	lb		$s3, 5($s0)		# load current_player
	
	# If distance == 99
	li		$t0, 99		# $t0 = 99
	beq		$t0, $s2, distance_is_99	# if $t0 == $s2 then distance_is_99

	# If origin_pocket >= pockets
	lb		$t0, 2($s0)		# load pockets
	bge		$s1, $t0, origin_pocket_invalid	# if $s1 >= $t0 then origin_pocket_invalid
	
	# Get stones in origin_pocket
	move 	$a0, $s0		# $a0 = $s0 (pass state)
	move 	$a1, $s3		# $a1 = $s3 (pass current_player)
	move 	$a2, $s1		# $a2 = $s1 (pass origin_pocket)
	jal		get_pocket				# jump to get_stones and save position to $ra
	# If origin_pocket has no stones, return 0. 
	# $v0 = stones in origin_pocket
	beqz $v0, return_verify_move
	# If distance != stones in origin_pocket
	bne		$s2, $v0, distance_error	# if $s2 != $v0 then distance_error
	# If distance == 0
	beqz $s2, distance_error

	# Else, move does not violate any game rules. Return 1. 
	li		$v0, 1		# $v0 = 1
	j		return_verify_move				# jump to return_verify_move
	
	distance_error:
		li		$v0, -2		# $v0 = -2
		j		return_verify_move				# jump to return_verify_move
		
	origin_pocket_invalid:
		li		$v0, -1		# $v0 = -1
		j		return_verify_move				# jump to return_verify_move
		
	distance_is_99:
		# Return 2
		li		$v0, 2		# $v0 = 2
		# Change player turn in state.
		# If current_player == 'T'
		li		$t0, 'T'		# $t0 = 'T'
		beq		$t0, $s3, flip_to_b	# if $t0 == $s3 then flip_to_b
		# Else, current_player == 'B'
		sb		$t0, 5($s0)		# set player to 'T'
		j		return_verify_move				# jump to return_verify_move
		
		flip_to_b:
			li		$t0, 'B'		# $t0 = 'B'
			sb		$t0, 5($s0)		# set player to 'B'
			j		return_verify_move				# jump to return_verify_move
			
	return_verify_move:
		lw		$s0, 0($sp)	
		lw		$s1, 4($sp)
		lw		$s2, 8($sp)
		lw		$s3, 12($sp)
		lw		$ra, 16($sp)		
		addi	$sp, $sp, 20			# $sp = $sp + 20
		jr  $ra
execute_move:
	addi	$sp, $sp, -32			# $sp = $sp + -32
	sw		$s0, 0($sp)		# state
	sw		$s1, 4($sp)		# origin_pocket
	sw		$s2, 8($sp)		# # of stones added to the mancala
	sw		$s3, 12($sp)		# return value in $v1
	sw		$s4, 16($sp)		# # of stones
	sw		$s5, 20($sp)		# pocket index
	sw		$s6, 24($sp)		# current row
	sw		$ra, 28($sp)		# save return address

	# Save arguments
	move 	$s0, $a0		# $s0 = $a0 (save state)
	move 	$s1, $a1		# $s1 = $a1 (save origin_pocket)

	# Check what player_turn it is. 
	li		$t0, 'T'		# $t0 = 'T'
	lb		$t1, 5($s0)		# load player turn
	beq		$t1, $t0, is_t_turn	# if $t1 == $t0 then is_t_turn
	li		$t0, 'B'		# $t0 = 'B'
	beq		$t0, $t1, is_b_turn	# if $t0 == $t1 then is_b_turn
	
	is_t_turn:
		# Get stones in origin_pocket
		move 	$a0, $s0		# $a0 = $s0 (pass state)
		li		$a1, 'T'		# $a1 = 'T' (pass player)		
		move 	$a2, $s1		# $a2 = $s1 (pass origin_pocket as distance)
		jal		get_pocket				# jump to get_pocket and save position to $ra
		move 	$s4, $v0		# $s4 = $v0
		# Set stones in origin_pocket to 0 
		move 	$a0, $s0		# $a0 = $s0 (pass state)
		li		$a1, 'T'		# $a1 = 'T'  
		move 	$a2, $s1		# $a2 = $s1 (pass origin_pocket as distance)
		li		$a3, 0		# $a3 = 0 (empty pocket)
		jal		set_pocket				# jump to set_pocket and save position to $ra
		# $s4 = # of stones in origin_pocket
		# Set turn to 'T'
		li		$s6, 'T'		# $s6 = 'T'
				
	is_b_turn:
		# Get stones in origin_pocket
		move 	$a0, $s0		# $a0 = $s0 (pass state)
		li		$a1, 'B'		# $a1 = 'B' (pass player)
		move 	$a2, $s1		# $a2 = $s1 (pass origin_pocket as distance)
		jal		get_pocket				# jump to get_pocket and save position to $ra
		move 	$s4, $v0		# $s4 = $v0
		# Set stones in origin_pocket to 0 
		move 	$a0, $s0		# $a0 = $s0 (pass state)
		li		$a1, 'B'		# $a1 = 'B'  
		move 	$a2, $s1		# $a2 = $s1 (pass origin_pocket as distance)
		li		$a3, 0		# $a3 = 0 (empty pocket)
		jal		set_pocket				# jump to set_pocket and save position to $ra

		# $s4 = # of stones in origin_pocket
		# Set turn to 'B'
		li		$s6, 'B'		# $s6 = 'B'
		
	move 	$s5, $s1		# $s5 = $s1 (set origin_pocket as starting index) 
	# $s5 = index
	execute_move_loop:
		# If current_row == 'T'
		li		$t0, 'T'		# $t0 = 'T'
		beq		$t0, $s6, on_t_row	# if $t0 == $s6 then on_t_row
		# Else on_b_row
		# ******* BOTTOM ROW *******
		addi	$s5, $s5, -1			# $s5 = $s5 + -1 (get next pocket)
		bltz $s5, at_bot_mancala
		# Else, deposit stones in the next pocket ($s5)
		# First check to see if there are no stones in the pocket. 
		move 	$a0, $s0		# $a0 = $s0 (pass state)
		li		$a1, 'B'		# $a1 = 'T'
		move 	$a2, $s5		# $a2 = $s5 (pass index as distance)
		jal		get_pocket				# jump to get_pocket and save position to $ra
		# If there are no stones in pocket
		beqz $v0, no_stones_in_b_pocket
		# Else, 
		li		$s3, 0		# $s3 = 0 (return 0)
		j		add_stone_to_b_pocket				# jump to add_stone_to_b_pocket
		
		no_stones_in_b_pocket:
			# Check to see if this is the current_player's row 
			lb		$t0, 5($s0)		# load player turn
			li		$t1, 'B'		# $t1 = 'B'
			# If current_player == 'B'
			beq		$t0, $t1, is_b	# if $t0 == $t1 then is_b_player
			# Else
			li		$s3, 0		# $s3 = 0 (return 0)
			j		add_stone_to_b_pocket				# jump to add_stone_to_b_pocket
			
			is_b:
				li		$s3, 1		# $s3 = 1 (load in case we have to return)
				
		add_stone_to_b_pocket:
			# first get stones in pocket 
			move 	$a0, $s0		# $a0 = $s0 (pass state)
			li		$a1, 'B'		# $a1 = 'B'
			move 	$a2, $s5		# $a2 = $s5 (pass index as distance)
			jal		get_pocket				# jump to get_pocket and save position to $ra
			addi	$a3, $v0, 1			# $a3 = $v0 + 1 (add one stone to pass into set_pocket)
			
			move 	$a0, $s0		# $a0 = $s0 (pass state)
			li		$a1, 'B'		# $a1 = 'B'
			move 	$a2, $s5		# $a2 = $s5 (pass index as distance)
			jal		set_pocket				# jump to set_pocket and save position to $ra
			addi	$s4, $s4, -1			# $s4 = $s4 + -1
			# If there are no stones left
			beqz $s4, return_execute_move
			# Else
			j		execute_move_loop				# jump to execute_move_loop
			
		at_bot_mancala:
			# If current_player == 'T' then skip mancala
			li		$t0, 'T'		# $t0 = 'T'
			lb		$t1, 5($s0)		# load player_turn
			beq		$t0, $t1, move_to_t_row	# if $t0 == $t1 then move_to_t_row
			# Else, current_player is 'B'
			# Deposit one stone in bot_mancala
			move 	$a0, $s0		# $a0 = $s0 (pass state)
			li		$a1, 'B'		# $a1 = 'B'
			li		$a2, 1		# $a2 = 1 (add one stone)
			jal		collect_stones				# jump to collect_stones and save position to $ra
			addi	$s4, $s4, -1			# $s4 = $s4 + -1 (decrement stones)
			addi	$s2, $s2, 1			# $s2 = $s2 + 1 (increment mancala counter)
			
			li		$s3, 2		# $s3 = 2 (return 2 if this is the last deposit)
			# If stones == 0 then return
			beqz $s4, return_execute_move

		# Else
		move_to_t_row:
			li		$s6, 'T'		# $s6 = 'T'
			# Set index to top_pockets
			lb		$s5, 3($s0)		# load top_pockets into index 
			j		execute_move_loop				# jump to execute_move_loop
			
			
		
		# ******* TOP ROW *******
		on_t_row:
			addi	$s5, $s5, -1			# $s5 = $s5 + -1 (get next pocket)
			bltz $s5, at_top_mancala
			# Else, deposit stones in next pocket ($s5)
			# First check to see if there are no stones in the pocket.
			move 	$a0, $s0		# $a0 = $s0 (pass state)
			li		$a1, 'T'		# $a1 = 'T'
			move 	$a2, $s5		# $a2 = $s5 (pass index as distance)
			jal		get_pocket				# jump to get_pocket and save position to $ra
			# If there are no stones in pocket
			beqz $v0, no_stones_in_t_pocket
			# Else
			li		$s3, 0		# $s3 = 0 (return 0)
			j		add_stone_to_t_pocket				# jump to add_stone_to_t_ocket
		
			no_stones_in_t_pocket:
				# Check to see if this is the current_player's row.
				lb		$t0, 5($s0)		# load player turn
				li		$t1, 'T'		# $t1 = 'T'
				# If current_player == 'T'
				beq		$t0, $t1, is_t	# if $t0 == $t1 then is_t_player
				# Else
				li		$s3, 0		# $s3 = 0 (return 0)
				j		add_stone_to_t_pocket				# jump to add_stone_to_t_pocket
				
				is_t:
					li		$s3, 1		# $s3 = 1 (load in case we have to return)
					
			add_stone_to_t_pocket:
				# first get stones in pocket 
				move 	$a0, $s0		# $a0 = $s0 (pass state)
				li		$a1, 'T'		# $a1 = 'T'
				move 	$a2, $s5		# $a2 = $s5 (pass index as distance)
				jal		get_pocket				# jump to get_pocket and save position to $ra
				addi	$a3, $v0, 1			# $a3 = $v0 + 1 (add one stone to pass into set_pocket)

				move 	$a0, $s0		# $a0 = $s0 (pass state)
				li		$a1, 'T'		# $a1 = 'T'
				move 	$a2, $s5		# $a2 = $s5 (pass index as distance) 
				jal		set_pocket				# jump to set_pocket and save position to $ra
				addi	$s4, $s4, -1			# $s4 = $s4 + -1
				# If there are no stones left
				beqz $s4, return_execute_move
				# Else,
				j		execute_move_loop				# jump to execute_move_loop
				
			at_top_mancala:
				# If current_player == 'B' then skip top_mancala. 
				li		$t0, 'B'		# $t0 = 'B'
				lb		$t1, 5($s0)		# load player turn
				beq		$t0, $t1, move_to_b_row	# if $t0 == $t1 then move_to_b_row
				# Else, current_player is 'T'. 
				# Deposit one stone in top_mancala
				move 	$a0, $s0		# $a0 = $s0 (pass state)
				li		$a1, 'T'		# $a1 = 'T' (player is 'T')
				li		$a2, 1		# $a2 = 1 (add one stone)
				jal		collect_stones				# jump to collect_stones and save position to $ra
				addi	$s4, $s4, -1			# $s4 = $s4 + -1 (decrement stones)
				addi	$s2, $s2, 1			# $s2 = $s2 + 1 (increment mancala counter)
				li		$s3, 2		# $v1 = 2 (return 2 if this was the last deposit) 
				# If stones == 0 then return 
				beqz $s4, return_execute_move
				
			# Else, move_to_b_row
			move_to_b_row:
				li		$s6, 'B'		# $s6 = 'B'
				# Set index to bot_pockets
				lb		$s5, 2($s0)		# load bot_pockets
				j		execute_move_loop				# jump to execute_move_loop
				

		return_execute_move:
			move 	$v0, $s2		# $v0 = $s2 (return mancala counter)
			move 	$v1, $s3		# $v1 = $s3

			li		$t0, 2		# $t0 = 2
			beq		$v1, $t0, take_another_turn	# if $v1 == $t0 then take_another_turn
			# Else, change turn.
			lb		$t0, 5($s0)		# load turn
			# If current turn is 'T'
			li		$t1, 'T'		# $t1 = 'T'
			beq		$t0, $t1, change_turn_to_b	# if $t0 == $t1 then change_turn_to_b
			#  Else current turn is 'B'
			sb		$t1, 5($s0)		# set turn to 'T'
			j		take_another_turn				# jump to take_another_turn
			
			change_turn_to_b:
				li		$t0, 'B'		# $t0 = 'B'
				sb		$t0, 5($s0)		# set turn to 'B'

			take_another_turn:
				# increment moves_executed
				lb		$t0, 4($s0)		# load moves_executed
				addi	$t0, $t0, 1			# $t0 = $t0 + 1 (increment)
				sb		$t0, 4($s0)		# update moves_executed

				lw		$s0, 0($sp)		 
				lw		$s1, 4($sp)
				lw		$s2, 8($sp)
				lw		$s3, 12($sp)
				lw		$s4, 16($sp)
				lw		$s5, 20($sp)
				lw		$s6, 24($sp)
				lw		$ra, 28($sp)
				addi	$sp, $sp, 32			# $sp = $sp + 32
			jr $ra
steal:
	addi	$sp, $sp, -24			# $sp = $sp + -24
	sw		$s0, 0($sp)		# state
	sw		$s1, 4($sp)		# destination_pocket
	sw		$s2, 8($sp)		# pocket to steal from	
	sw		$s3, 12($sp)		# player
	sw		$s4, 16($sp)		# stones addd to mancala
	sw		$ra, 20($sp)		# save return address
	
	# Save arguments
	move 	$s0, $a0		# $s0 = $a0
	move 	$s1, $a1		# $s1 = $a1
	
	# Get player who is stealing (opposite of player_turn)
	lb		$t0, 5($s0)		# load player_turn
	li		$t1, 'T'		# $t1 = 'T'
	# If player_turn == 'T' then pass player = 'B'
	beq		$t0, $t1, player_b	# if $t0 == $t1 then pass_b
	# Else player_turn == 'B' so player = 'T'
	move 	$s3, $t1		# $s3 = $t1 (set player to 'T')
	j		empty_destination_pocket				# jump to empty_destination_pocket
	
	player_b:
		li		$s3, 'B'		# $s3 = 'B'

	empty_destination_pocket:
		move 	$a0, $s0		# $a0 = $s0 (pass state)
		move 	$a1, $s3		# $a1 = $s3 (pass player)
		move 	$a2, $s1		# $a2 = $s1 (pass destination_pocket as distance)
		li		$a3, 0		# $a3 = 0 (set size to 0)
		jal		set_pocket				# jump to set_pocket and save position to $ra
	
	# get pocket to steal from
	# pocket to steal from = pockets - destination_pocket - 1
	lb		$t0, 2($s0)		# load pockets
	sub		$s2, $t0, $s1		# $s2 = $t0 - $s1
	addi	$s2, $s2, -1			# $s2 = $s2 + -1
	# $s2 = pocket to steal from 
	# Get stones from pocket to steal from
	move 	$a0, $s0		# $a0 = $s0 (pass state)
	# We will be stealing from player whose turn it currently is in state
	lb		$a1, 5($s0)		# load player_turn from state
	move 	$a2, $s2		# $a2 = $s2 (pass pocket_to_steal from as distance)
	jal		get_pocket				# jump to get_pocket and save position to $ra
	# $v0 = # of stones we are stealing
	# add 1 to number of stones to steal to acccount for 1 in the destination_pocket
	addi	$t0, $v0, 1			# $t0 = $v0 + 1
	move 	$s4, $v0		# $s4 = $v0 (copy # of stones stolen to return later) 
	# $t0 = # of stones we are stealing plus one already in destination_pocket
	# We need to add the # of stones in $t0 to player mancala
	move 	$a0, $s0		# $a0 = $s0 (pass state)
	move 	$a1, $s3		# $a1 = $s3 (pass player)
	move 	$a2, $t0		# $a2 = $t0 (pass stolen stones)
	jal		collect_stones				# jump to collect_stones and save position to $ra
	
	# We need to empty the stolen pocket
	move 	$a0, $s0		# $a0 = $s0 (pass state)
	lb		$a1, 5($s0)		# load player_turn
	move 	$a2, $s2		# $a2 = $s2 (pass pocket to steal from)
	li		$a3, 0		# $a3 = 0 (set size to 0)
	jal		set_pocket				# jump to set_pocket and save position to $ra
	
	# Postamble
	move 	$v0, $s4		# $v0 = $s4 (return stones added to mancala)
	lw		$s0, 0($sp)	
	lw		$s1, 4($sp)
	lw		$s2, 8($sp)
	lw		$s3, 12($sp)
	lw		$s4, 16($sp)		
	lw		$ra, 20($sp)
	addi	$sp, $sp, 24			# $sp = $sp + 24
	jr $ra

check_row:
	addi	$sp, $sp, -24			# $sp = $sp + -24
	sw		$s0, 0($sp)		# state
	sw		$s1, 4($sp)		# pockets
	sw		$s2, 8($sp)		# loop variable
	sw		$s3, 12($sp)		# current_row
	sw		$s4, 16($sp)		# mancala to add stones to
	sw		$ra, 20($sp)		# save return address

	# Save arguments
	move 	$s0, $a0	# $s0 = a0

	lb		$s1, 3($s0) # load pockets
	
	# start with top_row
	li		$s3, 'T'		# $s3 = 'T'
	check_both_rows:
		# int i = 0
		# while i < pockets (while $s2 < $s1)
		li		$s2, 0		# $s2 = 0
		iterate_row:
			# get stones in pocket
			# $s2 = pocket
			move 	$a0, $s0		# $a0 = $s0 (pass state)
			move 	$a1, $s3		# $a1 = $s3 (pass current_row)
			move 	$a2, $s2		# $a2 = $s2 (pass loop variable as distance)
			jal		get_pocket				# jump to get_pocket and save position to $ra
			# if pocket has stones then break
			bnez $v0, row_not_empty
			# else pocket is empty
			# check next pocket
			addi	$s2, $s2, 1			# $s2 = $s2 + 1 (i++)
			# If we just checked the last pocket and the control is here because it was also empty, the entire row is empty.
			beq		$s2, $s1, row_is_empty	# if $s2 == $s1 then row_is_empty
			# Else we haven't finished iterating through the entire row yet
			j		iterate_row				# jump to iterate_row

			row_not_empty:
				# If current_row == 'T' then check bottom row
				li		$t0, 'T'		# $t0 = 'T'
				beq		$s3, $t0, check_bot_row	# if $s3 == $t0 then check_bot_row
				# Else we have checked both rows and they're both empty
				j		both_not_empty				# jump to both_not_empty
				
				check_bot_row:
					# Switch row
					li		$s3, 'B'		# $s3 = 'B'
					j		check_both_rows				# jump to check_both_rows
					
			row_is_empty:
				# if current_row == 'B' then put all top_row stones in player_2 mancala
				# if current_row == 'T' then put all bot_row stones in player_1 mancala

				# If current_row == 'B'
				li		$s4, 'B'		# $s4 = 'B'
				beq		$s3, $s4, current_row_is_b	# if $s3 == $s4 then current_row_is_b
				# else current_row is 'T'
				j		call_get_stones_in_row				# jump to call_get_stones_in_row
				
				current_row_is_b:
					li		$s4, 'T'		# $t0 = 'B' (load 'T' to pass into get_stones_in_row
					
				call_get_stones_in_row:
					move 	$a0, $s0		# $a0 = $s0 (pass state)
					move 	$a1, $s4		# $a1 = $s4
					jal		get_stones_in_row				# jump to get_stones_in_row and save position to $ra
				
				# $v0 = stones in row
				# add stones in row to mancala
				move 	$a0, $s0		# $a0 = $s0 (pass state)
				move 	$a1, $s4		# $a1 = $s4 (pass player)
				move 	$a2, $v0		# $a2 = $v0 (pass stones from row)
				jal		collect_stones				# jump to collect_stones and save position to $ra
				li		$v0, 1		# $v0 = 1 (return 1 since one row was found to be empty)
				j		compare_mancalas				# jump to compare_mancalas
						
			both_not_empty:
				li		$v0, 0		# $v0 = 0 (return 0 since no rows were empty)

	compare_mancalas:			
		# End game
		# Compare player 1 mancala and player 2 mancala to determine winner
		lb		$t0, 0($s0)		# load bot_mancala
		lb		$t1, 1($s0)		# load top_mancala

		beq		$t0, $t1, tie	# if $t0 == $t1 then tie
		bgt		$t0, $t1, player1_wins	# if $t0 > $t1 then player1_wins
		# Else player 2 wins
		li		$v1, 2		# $s5 = 2
		j		return_check_row				# jump to return_check_row
					
		player1_wins:
			li		$v1, 1		# $s5 = 1
			j		return_check_row				# jump to return_check_row
				
		tie:
			li		$v1, 0		# $s5 = 0

	return_check_row:
		lw		$s0, 0($sp)
		lw		$s1, 4($sp)		
		lw		$s2, 8($sp)		
		lw		$s3, 12($sp)		
		lw		$s4, 16($sp)	
		lw		$ra, 20($sp)	
		addi	$sp, $sp, 24			# $sp = $sp + 24
		jr $ra

load_moves:
	addi	$sp, $sp, -24			# $sp = $sp + -24
	lw		$s0, 0($sp)		# moves[]
	lw		$s1, 4($sp)		# columns
	lw		$s2, 8($sp)		# rows
	lw		$s3, 12($sp)		# file descriptor
	lw		$s4, 16($sp)		# line number
	lw		$s5, 20($sp)		# current_char

	# Save moves[]
	move 	$s0, $a0	# $s0 = $a0
	
	# Open file
	li		$v0, 13		# $v0 = 13
	move 	$a0, $a1		# $a0 = $a1 (move address of the filename string)
	li		$a1, 0		# $a1 = 0 (flag for reading from a file)
	syscall
	move 	$s3, $v0		# $s3 = $v0 (save the file descriptor)
	
	# If the file descriptor is negative then the file does not exist. 
	bltz $s3, error_reading_file

	li		$s4, 0		# line number = 0
	addi	$sp, $sp, -4			# $sp = $sp + -4
	read_moves_file:
		# Read the file. 
		li		$v0, 14		# $v0 = 14
		move 	$a0, $s3		# $a0 = $s4 ($a0 = file descriptor) 
		move 	$a1, $sp		# $a1 = $sp ($a1 = address of buffer)
		li		$a2, 1		# $a2 = 1 (the maximum chars to read is 1)
		syscall
		

	
	error_reading_file:
		li		$v0, -1		# $v0 = -1
		
	jr $ra

play_game:
	jr  $ra
print_board:	
	move 	$t0, $a0		# $t0 = $a0 (save state)
	addi	$t1, $t0, 6			# $t1 = $t0 + 6 (get base address of game_board)
	# Print top_mancala
	lb		$a0, 0($t1)		# load first char
	# print first char
	li		$v0, 11		# $v0 = 11
	syscall
	# print second char
	lb		$a0, 1($t1)		# load second char
	syscall
	# print newline
	li		$a0, '\n'		# $a0 = '\n'
	syscall

	# Print bot_mancala
	lb		$t2, 3($t0)		# load pockets
	add		$t2, $t2, $t2		# $t2 = $t2 + $t2 (double pockets)
	add		$t5, $t2, $t2		# $t5 = $t2 + $t2 (double pockets again to account for top row)
	add		$t4, $t1, $t5		# $t4 = $t1 + $t5
	addi	$t4, $t4, 2			# $t4 = $t4 + 2 (get index of bot_mancala)

	# print first char
	lb		$a0, 0($t4)		# load first char
	syscall
	lb		$a0, 1($t4)		# load second char
	syscall
	
	# print newline 
	li		$a0, '\n'		# $a0 = '\n'
	syscall
	
	# Print rows
	addi	$t1, $t1, 2			# $t1 = $t1 + 2 add 2 to game_board base address to account for top_mancala
	li		$t4, 'T'		# $t4 = 'T' (current_row)
	print_row:
		# This will loop for pockets * 2 times
		# $t2 = loop max (pockets * 2)
		# set loop variable
		li		$t3, 0		# $t3 = 0 (int i = 0)
		print_pocket:
			lb		$a0, 0($t1)		# load char
			syscall

			addi	$t3, $t3, 1			# $t3 = $t3 + 1 (i++)
			addi	$t1, $t1, 1			# $t1 = $t1 + 1 (increment address)
			beq		$t3, $t2, end_loop	# if $t3 == $t2 then end_loop
			# Else
			j		print_pocket				# jump to print_pocket
		end_loop:
			# If we just printed bottom_row, then return.
			li		$t5, 'B'		# $t5 = 'B'
			beq		$t4, $t5, return_print_board	# if $t4 == $t5 then return_print_board
			# Else, print newline and switch to bottom_row to print
			move 	$t4, $t5		# $t4 = $t5 (switch to bottom_row)
			# print newline
			li		$a0, '\n'		# $a0 = '\n'
			syscall
			j		print_row				# jump to print_row
			
	return_print_board:
		jr $ra
write_board:
	addi	$sp, $sp, -8			# $sp = $sp + -8
	sw		$s0, 0($sp)		# file descriptor
	sw		$s1, 4($sp)		# state
	
	# save argument
	move 	$s1, $a0		# $s1 = $a0
	
	# Create string "output.txt" and store on the $sp
	# String "output.txt" is 10 bytes long
	addi	$sp, $sp, -10			# $sp = $sp + -10 (allocate 10 bytes)
	# store "output.txt" on the stack
	li		$t0, 'o'		
	sb		$t0, 0($sp)		
	li		$t0, 'u'		
	sb		$t0, 1($sp)
	li		$t0, 't'		
	sb		$t0, 2($sp)
	li		$t0, 'p'		
	sb		$t0, 3($sp)
	li		$t0, 'u'		
	sb		$t0, 4($sp)
	li		$t0, 't'		
	sb		$t0, 5($sp)
	li		$t0, '.'		
	sb		$t0, 6($sp)
	li		$t0, 't'		
	sb		$t0, 7($sp)
	li		$t0, 'x'		
	sb		$t0, 8($sp)
	li		$t0, 't'	
	sb		$t0, 9($sp)
	move 	$a0, $sp		# $a0 = $sp (output file name)
	li		$v0, 13		# $v0 = 13
	li		$a1, 1		# $a1 = 1 (open for writing)
	li		$a2, 0		# $a2 = 0 (mode is ignored)
	syscall # open a file 
	move 	$s0, $v0		# $s0 = $v0 (save file descriptor)
	addi	$sp, $sp, 10			# $sp = $sp + 10
	
	# WRITE FIRST LINE OF FILE	
	addi	$sp, $sp, -3			# $sp = $sp + -3 (allocate 3 bytes on stack to store 3 chars)

	addi	$t0, $s1, 6			# $t0 = $s1 + 6 (get starting address of game_board)
	lb		$t1, 0($t0)		# load first char of game_board
	lb		$t2, 1($t0)		# load second char of game_baord
		
	sb		$t1, 0($sp)		# store first char on stack
	sb		$t2, 1($sp)		# store second byte on stack

	li		$t1, '\n'		# $t1 = '\n'
	sb		$t1, 2($sp)		# store newline char on stack
		
	# write to file
	li		$v0, 15		# $v0 = 15
	move 	$a0, $s0		# $a0 = $s0 (pass file descriptor)
	move 	$a1, $sp		# $a1 = $sp (address of buffer from which to write)
	li		$a2, 3		# $a2 = 3 
	syscall
	addi	$sp, $sp, 3			# $sp = $sp + 3
	
	# WRITE SECOND LINE OF FILE
	addi	$sp, $sp, -3			# $sp = $sp + -3 (allocate space for 3 bytes on stack)
	# $t0 = base address of game_board
	lb		$t1, 3($s1)		# load pockets
	add		$t1, $t1, $t1		# $t1 = $t1 + $t1 (double pockets to account for first row)
	add		$t1, $t1, $t1		# $t1 = $t1 + $t1 (double pockets again to accout for second row)
	add		$t2, $t1, $t0		# $t2 = $t1 + $t0
	addi	$t2, $t2, 2			# $t2 = $t2 + 2 ($t2 = address of bot_mancala)

	lb		$t1, 0($t2)		# load first char of bot_mancala
	lb		$t3, 1($t2)		# load second char of bot_mancala
	sb		$t1, 0($sp)		# store first char on stack
	sb		$t3, 1($sp)		# store second char on stack
	li		$t1, '\n'		# $t1 = '\n'
	sb		$t1, 2($sp)		# store newlne char on stack

	# write to file
	li		$v0, 15		# $v0 = 15
	move 	$a0, $s0		# $a0 = $s0 (pass file descriptor)
	move 	$a1, $sp		# $a1 = $sp (address of buffer from which to write)
	li		$a2, 3		# $a2 = 3
	syscall
	addi	$sp, $sp, 3			# $sp = $sp + 3 (reallocate 3 bytes on the stack)

	# WRITE GAME_BOARD TO FILE
	addi	$t0, $t0, 2			# $t0 = $t0 + 2 add 2 to game_board base address to account for top_mancala
	li		$t1, 'T'		# $t1 = 'T' (current_row)
	lb		$t2, 3($s1)		# load pockets
	add		$t2, $t2, $t2		# $t2 = $t2 + $t2 (double pockets)
	write_row:
		# This will loop for pockets * 2 times
		# $t2 = loop max (pockets * 2)
		# set loop variable
		li		$t3, 0		# $t3 = 0 (int i = 0)
		write_char:
			lb		$t4, 0($t0)		# load char from game_board
			addi	$sp, $sp, -1			# $sp = $sp + -1 (make room on stack)
			sb		$t4, 0($sp)		# store char on stack 
			
			# write to file 
			li		$v0, 15		# $v0 = 15
			move 	$a0, $s0		# $a0 = $s0 (pass file descriptor)
			move 	$a1, $sp		# $a1 = $sp (address of buffer from which to write)
			li		$a2, 1		# $a2 = 1 (writing one char at a time) 
			syscall
			addi	$sp, $sp, 1			# $sp = $sp + 1 (reallocate space)
			
			addi	$t3, $t3, 1			# $t3 = $t3 + 1 (i++)
			addi	$t0, $t0, 1			# $t0 = $t0 + 1 (increment address)
			beq		$t3, $t2, end_write_row_loop	# if $t3 == $t2 then end_loop
			# Else
			j		write_char				# jump to write_char
		end_write_row_loop:
			# If we just wrote bottom_row, then return.
			li		$t5, 'B'		# $t5 = 'B'
			beq		$t1, $t5, return_write_board	# if $t1 == $t5 then return_print_board
			# Else, write newline and switch to bottom_row to write
			move 	$t1, $t5		# $t1 = $t5 (switch to bottom_row)
			# store newline char on the stack 
			li		$t4, '\n'		# $t4 = '\n'
			addi	$sp, $sp, -1			# $sp = $sp + -1
			sb		$t4, 0($sp)		# store newline char on the stack
			# write newline char
			li		$v0, 15		# $v0 = 15
			move 	$a0, $s0		# $a0 = $s0 (pass file descriptor)
			move 	$a1, $sp		# $a1 = $sp (address of buffer from which to write)
			li		$a2, 1		# $a2 = 1 (writing one char)
			syscall
			addi	$sp, $sp, 1			# $sp = $sp + 1
			j		write_row				# jump to write_row

	return_write_board:
		lw		$s0, 0($sp)
		lw		$s1, 4($sp)
		addi	$sp, $sp, 8			# $sp = $sp + 8
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
	
convert_to_int:
	# Converts two chars representing two digits to an int
	move 	$t0, $a0		# $t0 = $a0	(first char)
	move 	$t1, $a1		# $t1 = $a1 (first char)

	addi	$t0, $t0, -48			# $t0 = $t0 + -48 (char -> int)
	addi	$t1, $t1, -48			# $t1 = $t1 + -48 (char -> int)

	# Get proper value of first digit.
	li		$t2, 10		# $t2 = 10
	mult	$t0, $t2			# $t0 * $t2 = Hi and Lo registers
	mflo	$t0					# copy Lo to $t0
	# $t0 = proper value of first digit.
	add		$v0, $t1, $t0		# $v0 = $t1 + $t0 (int conversion)
	jr		$ra					# jump to $ra

get_stones_in_row:
	addi	$sp, $sp, -24			# $sp = $sp + -24
	sw		$s0, 0($sp)		# state
	sw		$s1, 4($sp)		# row
	sw		$s2, 8($sp)		# loop variable
	sw		$s3, 12($sp)		# pockets
	sw		$s4, 16($sp)		# stones in row (return value)
	sw		$ra, 20($sp)		# save return address 

	# Save arguments
	move 	$s0, $a0		# $s0 = $a0
	move 	$s1, $a1		# $s1 = $a1

	lb		$s3, 2($s0)		# load pockets
	li		$s4, 0		# $s4 = 0 (set stones in row to)
	
	# while i < pockets (while $s2 < $s3)
	li		$s2, 0		# $s2 = 0 (int i = 0) 
	iterate_row_get_stones:
		# get stones in current pocket
		move 	$a0, $s0		# $a0 = $s0 (pass state)
		move 	$a1, $s1		# $a1 = $s1 (pass player/row)
		move 	$a2, $s2		# $a2 = $s2 (pass loop variable as distance)
		jal		get_pocket				# jump to get_pocket and save position to $ra
		add		$s4, $s4, $v0		# $s4 = $s4 + $v0 (add stones in pocket to count)
		addi	$s2, $s2, 1			# $s2 = $s2 + 1 (i++)
		beq		$s2, $s3, return_stones	# if $s2 == $s3 then return_stones
		# Else
		j		iterate_row_get_stones				# jump to iterate_row_get_stones
		
	return_stones:
		move 	$v0, $s4		# $v0 = $s4 (return stones in row)
		lw		$s0, 0($sp)
		lw		$s1, 4($sp)
		lw		$s2, 8($sp)
		lw		$s3, 12($sp)
		lw		$s4, 16($sp)
		lw		$ra, 20($sp)
		addi	$sp, $sp, 24			# $sp = $sp + 24
		jr		$ra					# jump to $ra
		
				

		
		

		
	
	
	
	
############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################