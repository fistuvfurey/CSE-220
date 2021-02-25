.data
ErrMsg: .asciiz "Invalid Argument"
WrongArgMsg: .asciiz "You must provide exactly two arguments"
EvenMsg: .asciiz "Even"
OddMsg: .asciiz "Odd"
mantissa: .asciiz "1."

arg1_addr : .word 0
arg2_addr : .word 0
num_args : .word 0

.text:
.globl main
main:
	sw $a0, num_args

	lw $t0, 0($a1)
	sw $t0, arg1_addr
	lw $s1, arg1_addr

	lw $t1, 4($a1)
	sw $t1, arg2_addr
	lw $s2, arg2_addr

	j start_coding_here

# do not change any line of code above this section
# you can add code to the .data section
start_coding_here:
	# First, check to see if we have exactly 2 arguments
	addi	$s0, $0, 2			# $s0 = 0 + 2 (generate constant 2 for comparison)
	beq		$a0, $s0, validate_arg1	# if $a0 == $s0 then validate_arg1 (check to see if the num_args == 2.
	# This block executes if there is an incorrect number of args.
	# Print WrongArgMsg, then terminate the program. 
	la $a0, WrongArgMsg
	li $v0, 4
	syscall
	li $v0, 10
	syscall

	# Program execution continues here if 2 args are provided. 
	validate_arg1: 
		# Store first character of first arg
		lbu $t0, 0($s1) # $t0 = first char of arg1
		# First check to see if arg1 is 'O', then 'S', 'T', 'I', 'E', 'C', 'X', and 'M'. 
		# If arg1 isn't any of those characters, print ErrMsg and terminate. 
		li $a0, 'O' # $a0 = 'O'
		beq		$t0, $a0, validate_arg2	# if $s0 == $a0 then validate_arg2

		li $a0, 'S' # $a0 = 'S'
		beq		$t0, $a0, validate_arg2	# if $s0 == $a0 then validate_arg2

		li $a0, 'T' # $a0 = 'T'
		beq		$t0, $a0, validate_arg2	# if $s0 == $a0 then validate_arg2

		li $a0, 'I' # $a0 = 'I'
		beq		$t0, $a0, validate_arg2	# if $s0 == $a0 then validate_arg2

		li $a0, 'E' # $a0 = 'E'
		beq		$t0, $a0, validate_arg2	# if $s0 == $a0 then validate_arg2

		li $a0, 'C' # $a0 = 'C'
		beq		$t0, $a0, validate_arg2	# if $s0 == $a0 then validate_arg2

		li $a0, 'X' # $a0 = 'X'
		beq		$t0, $a0, validate_arg2	# if $s0 == $a0 then validate_arg2

		li $a0, 'M' # $a0 = 'M'
		beq		$t0, $a0, validate_arg2	# if $s0 == $a0 then validate_arg2
		# If we are here, then the first arg is invalid.
		# Jump to invalid_arg. 
		j		invalid_arg				# jump to invalid_arg

	validate_arg2:
		lbu $t1, 0($s2) # $t1 = first char of arg2
		# First check to see if the first char is a '0'. 
		li $a0, '0' # $a0 = '0'
		beq		$t1, $a0, validate_char2	# if $t1 == $a0 then validate_char2
		# If we are here, char is invalid. Jump to invalid_arg.
		j		invalid_arg				# jump to invalid_arg
		
	validate_char2:
		lbu $t1, 1($s2) # $t1 = 2nd char of arg2
		# Check to see if char2 == 'x'
		li $a0, 'x' # $a0 = 'x'
		beq		$t1, $a0, validate_hex	# if $t1 == $a0 then validate_hex
		# This block executes if the char2 isn't a 'x'. Jump to invalid_arg.
		j		invalid_arg				# jump to invalid_arg

	validate_hex:
		# In this label, we will loop over the hex string to see if it is a valid hex.
		# $s2 already contains arg2_addr
		li $t2, 0 # counter
		li $t3, 8 # number of characters to check (iterations)		
		addi	$s4, $s2, 2			# $s4 = $s2 + 2 (we want to start off at the third char)
		validate_loop: 
			lbu $t1, 0($s4)
			# $t1 = character in hex

			# Check to see if the character is less than 48 (ASCII for '0').
			li		$s3, 48		# $s3 = 48
			blt		$t1, $s3, invalid_arg	# if $t1 < $s3 then invalid_arg
			# If we are here, char may still be valid. Let's check if it's < 9.
			li		$s3, 58		# $s3 = 58
			blt		$t1, $s3, valid_char	# if $t1 < $s3 then valid_char

			# Could still be valid letter, let's check to see if it's 'A'-'F'.
			# Check to see if char is less than 'A'.
			li		$s3, 65		# $s3 = 65
			blt		$t1, $s3, invalid_arg # if $t1 < $s3 then invalid_arg
			# If we are here, char may still be valid. Let's check to see if it's < 'G'.
			li		$s3, 71		# $s3 = 71
			blt		$t1, $s3, valid_char	# if $t1 < $s3 then valid_char
			# If we are here, then char > 'G' and is invalid. Jump to invalid_arg.
			j		invalid_arg				# jump to invalid_arg
			
			valid_char:
				# If this char is valid, move on to the next char and loop again.
				addi	$s4, $s4, 1			# $s4 = $s4 + 1 (get address of next char)
				addi	$t2, $t2, 1			# $t2 = $t2 + 1 (counter++)
				blt		$t2, $t3, validate_loop	# if $t2 < $t3 then validate_loop
		# ***end of loop***

		# If control exits the loop and moves here after validating arg2, jump to part2
		j		part2				# jump to part2
	
	invalid_arg:
		# This block executes if arg2 is invalid (the hex was invalid).
		# Print ErrMsg and terminate. 
		la $a0, ErrMsg
		li $v0, 4
		syscall
		li $v0, 10
		syscall

	part2:
		# Convert hex arg to binary. Loop through each char in the hex string.
		# $s2 = contains arg2_addr
		addi	$s2, $s2, 2			# $s2 = s21 + 2 (we want to start off at the third char in the hex)
		addi	$s3, $0, 0			# $s3 = $0 + 0 (initialize $s3 to 0)
		li		$t2, 0		# $t2 = 0 (counter)			
		li		$t3, 7		# $t3 = 7 (number of iterations)
		to_binary_loop:
			lbu $t1, 0($s2)
			# $t1 = character in hex				
			# We will store the binary representation of the hex in $s3. 
			# First let's check to see if $t1 is a number. 
			li		$s4, 58		# $s4 = 58
			blt		$t1, $s4, is_num	# if $t1 < $s4 then is_num
			# If we are here, then it is a letter ('A'-'F').
			li		$t4, 55		# $t4 = 55
			sub	$t1, $t1, $t4		# $t1 = $t1 - $t4 (get binary representation of hex digit)
			add		$s3, $s3, $t1		# $s3 = $s3 + $t1 (add binary stored in $t1 to $s3) 
			# Okay, now let's shift left logical. Jump to shift_bits.
			j		shift_bits				# jump to shift_bits
		
			is_num:
				li		$t4, 48		# $t4 = 48
				sub	$t1, $t1, $t4			# $t1 = $t1 - $t4 (get binary representation of hex digit)
				add		$s3, $s3, $t1		# $s3 = $s3 + $t1 (add binary stored in $t1 to $s3)
								
			shift_bits:
				# Shift to the left by 4 bits to make room for the next char to be converted.
				sll $s3, $s3, 4
				addi	$s2, $s2, 1			# $s2 = $s2 + 1 (get address of next char)
				addi	$t2, $t2, 1			# $t2 = $t2 + 1 (counter++)
				blt		$t2, $t3, to_binary_loop	# if $t2 < $t3 then to_binary_loop
		# ***end of loop***

		# Convert the last hex char. We didn't want to convert it inside the loop because we don't want to sll. 
		lbu $t1, 0($s2)
		# $t1 = character in hex
		# First let's check to see if $t1 is a number.
		li		$s4, 58		# $s4 = 58
		blt		$t1, $s4, last_is_num	# if $t1 < $s4 then last_is_num
		# If we are here, then it is a letter ('A'-'F').
		li		$t4, 55		# $t4 = 55
		sub	$t1, $t1, $t4		# $t1 = $t1 - $t4 (get binary representation of hex digit)
		add		$s3, $s3, $t1		# $s3 = $s3 + $t1 (add binary stored in $t1 to $s3)
		# If we are here, the last hex digit is a letter ('A'-'F'), so skip last_is_num label. 
		j		check_operation				# jump to check_operation
		
		last_is_num:
			li		$t4, 48		# $t4 = 48
			sub	$t1, $t1, $t4			# $t1 = $t1 - $t4 (get binary representation of hex digit)
			add		$s3, $s3, $t1		# $s3 = $s3 + $t1 (add binary stored in $t1 to $s3)
		# Now, $s3 contains the binary representation of the hex arg. 

		check_operation: 
			# Here, we will check which operation to perform based on the first arg.
			# $t0 = first char of arg1
			li		$t3, 'O'		# $t3 = 'O'
			beq		$t0, $t3, operation_O	# if $t0 == $t3 then operation_O

			li		$t3, 'S'		# $t3 = 'S'
			beq		$t0, $t3, operation_S	# if $t0 == $t1 then operation_S
			
			li		$t3, 'T'		# $t3 = 'T'
			beq		$t0, $t3, operation_T	# if $t0 == $t3 then operation_T
			
			li		$t3, 'I'		# $t3 = 'I'
			beq		$t0, $t3, operation_I	# if $t0 == $t3 then operation_I

			li		$t3, 'E'		# $t3 = 'E'
			beq		$t0, $t3, part3	# if $t0 == $t3 then part3
			
			li		$t3, 'C'		# $t3 = 'C'
			beq		$t0, $t3, part4	# if $t0 == $t3 then part4
			
			li		$t3, 'X'		# $t3 = 'X'
			beq		$t0, $t3, operation_X	# if $t0 == $t3 then operation_X
			
			li		$t3, 'M'		# $t3 = 'M'
			beq		$t0, $t3, operation_M	# if $t0 == $t3 then operation_M
			
		operation_O:
			# We need only the 6 msb so we will shift $s3 right logical by 26.
			addi	$s4, $0, 0			# $s4 = $0 + 0 (initialize $s4 to 0)
			srl $s4, $s3, 26
			# Print decimal integer in $s4.
			move $a0, $s4
			li $v0, 1
			syscall
			# Terminate the program.
			li $v0, 10
			syscall

		operation_S:
			# We need bits 7-11 inclusive, so we need to mask the first 6 bits and then srl by 21. 
			lui $s5, 0x03FF
			ori $s5, $s5, 0xFFFF # $s5 = 0x03FFFFFF
			and $s4, $s3, $s5 # mask the first 6 bits and save that in $s4
			srl $s4, $s4, 21 # srl by 21
			# Print decimal integer  in $s4.
			move $a0, $s4
			li $v0, 1
			syscall
			# Terminate the program.
			li $v0, 10
			syscall
		
		operation_T: 
			# We need bits 12-16 inclusive, so we need to mask the first 11 bits and then srl by 16.
			lui $s5, 0x001F
			ori $s5, $s5, 0xFFFF # $s5 = 0x001FFFFF
			and $s4, $s3, $s5 # mask the first 11 bits
			srl $s4, $s4, 16 # srl by 16
			# Print the decimal int. 
			move $a0, $s4
			li $v0, 1
			syscall
			# Terminate the program.
			li $v0, 10
			syscall
		
		operation_I:
			# We need to sll by 16 to get rid of the leftmost 16 bits.
			sll $s3, $s3, 16

			# Next, we need to sra by 16 bits to put the bits we want back in the right place.
			sra $s3, $s3, 16

			# Now, $s4 contains the absolute decimal value of the immediate.		
			move $a0, $s3
			li $v0, 1
			syscall
			# Terminate the program.
			li $v0, 10
			syscall
	
	
	part3:
		# $s3 contains the binary representation of the hex string.
		# Let's mask all the bits except the lsb and check to see if the lsb is a 1 or a 0 (even or odd).
		li $s5, 0x00000001
		and $s4, $s3, $s5 # mask all but the lsb

		li		$t3, 1		# $t3 = 1
		beq		$s4, $t3, odd	# if $s4 == $t3 then odd
		# If we are here, then it is even.
		la $a0, EvenMsg
		li $v0, 4
		syscall
		j		terminate				# jump to terminate
		
		odd:
			la $a0, OddMsg
			li $v0, 4
			syscall

		terminate:
			li $v0, 10
			syscall
	
	part4:
		# $s3 contains the binary representation of the hex string. 
		li		$t3, 0		# $t3 = 0 (# of 1s) 
		while_binary_not_zero:
			# Check to see if the lsb is a 1.
			andi $s4, $s3, 1 # $s4 = lsb of the binary representation
			
			li		$t4, 1		# $t4 = 1
			beq		$s4, $t4, is_1	# if $t0 == $t1 then is_1
			# If we are here, then the lsb isn't a 1. 
			j		shift_bits_right_one				# jump to shift_bits_right_one
			
			is_1:
				addi	$t3, $t3, 1			# $t3 = $t3 + 1 (increment 1s counter)
			
			shift_bits_right_one:
				# Shift bits to the right by one to get the next bit in the lsb place.
				srl $s3, $s3, 1
			 
			bgtz $s3, while_binary_not_zero # If $s3 > 0, then loop again
		# ***end of loop***
		
		# Print 1s count. 
		move $a0, $t3
		li $v0, 1
		syscall
		# Terminate.
		li $v0, 10
		syscall

	operation_X:
		# First, mask the msb of the binary representatation. 
		lui $s5, 0x7FFF
		ori $s5, $s5, 0xFFFF # $s5 = 0x7FFFFFFF
		and $s3, $s3, $s5 # mask the msb
		# Now, we want to srl by 23 bits.
		srl $s3, $s3, 23 
		# $s3 = the binary representation of the exponent.
		# Since the exponent is stored in 127-excess form, we need to subtract 127 to obtain the actual decimal value.
		li		$t3, 127 		# $t3 = 127
		sub	$s3, $s3, $t3			# $s3 = $s3 - $t3
		# Print the decimal value of the exponent.
		move $a0, $s3
		li $v0, 1
		syscall
		# Terminate the program.
		li $v0, 10
		syscall

	operation_M:
		# $s3 holds the binary representation of the hex string. 
		# We need to sll by 9 bits to append the 9 zeros and to get rid of the first 9 bits which we don't need.
		sll $s3, $s3, 9
		# Now, $s3 holds the binary representation of the mantissa with 9 appended zeros.\
		# Print the string "1.". 
		la $a0, mantissa
		li $v0, 4
		syscall
		# Print the binary representation of the mantissa. 
		move $a0, $s3
		li $v0, 35
		syscall
		# Terminate the program
		li $v0, 10
		syscall

