.data
ErrMsg: .asciiz "Invalid Argument"
WrongArgMsg: .asciiz "You must provide exactly two arguments"
EvenMsg: .asciiz "Even"
OddMsg: .asciiz "Odd"
debugMsg: .asciiz "part2"

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
		j		here				# jump to here
		
		last_is_num:
			li		$t4, 48		# $t4 = 48
			sub	$t1, $t1, $t4			# $t1 = $t1 - $t4 (get binary representation of hex digit)
			add		$s3, $s3, $t1		# $s3 = $s3 + $t1 (add binary stored in $t1 to $s3)
		# Now, $s3 contains the binary representation of the hex arg. 
		here: 
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
		
		
		
		operation_O:
			# We need only the 6 msb so we will shift $s3 right logical by 26.
			addi	$s4, $0, 0			# $s4 = $0 + 0 (initialize $s4 to 0)
			srl $s4, $s3, 26
			# Print decimal integer in $s4.
			move $a0, $s4
			li $v0, 1
			syscall
		j		part3				# jump to part3
		
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
		j		part3				# jump to part3
		
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
		j		part3				# jump to part3
		
		operation_I:
		# We need to find the value of the MSB to determine whether or not the value is positive or negative.
		# We then need to use XOR to flip all the bits and then add 1 to get the absolute decimal value of the immediate.

		# First, to find the MSB of the immediate, we need to mask the first 16 bits. 
		li $s5, 0x0000FFFF
		and $s4, $s3, $s5 # mask the first 16 bits

		# Now, we will srl by 15 to move the MSB to the one's place. If the decimal value in the destination register is 1,
		# then it is a negative number.
		srl $s6, $s4, 15

		# Convert from 2's complement to decimal (flip all the bits and add 1)
		li $s5, 0xFFFF # $s5 = 0x0000FFFF
		xor $s4, $s4, $s5 # flip all bits in $s4
		addi	$s4, $s4, 1			# $s4 = $s4 + 1
		# Now, $s4 contains the absolute decimal value of the immediate.

		# Check to see if $s6 is 1.
		li		$t3, 1		# $t3 = 1
		beq		$s6, $t3, is_neg	# if $s6 == $t3 then is_neg
		# If we are here, it is a positive value, jump to print_immediate.
		j		print_immediate				# jump to print_immediate
		
		is_neg:
			li		$t3, -1		# $t3 = -1
			mul $s4, $s4, $t3 # negate $s4

		print_immediate:
			move $a0, $s4
			li $v0, 1
			syscall
	
	
	
	part3:
	
	# Terminate the program
	li $v0, 10
	syscall

