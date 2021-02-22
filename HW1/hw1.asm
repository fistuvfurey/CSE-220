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
	# If we are here, then the first ag is invalid.
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
		addi	$s2, $s2, 2			# $s2 = $s2 + 2 (we want to start off at the third char)
		loop: 
			lbu $t1, 0($s2)
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
				addi	$s2, $s2, 1			# $s2 = $s2 + 1 (get address of next char)
				addi	$t2, $t2, 1			# $t2 = $t2 + 1 (counter++)
				blt		$t2, $t3, loop	# if $t2 < $t3 then loop
			# ***End of loop***
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
		la $a0, debugMsg
		li $v0, 4
		syscall


	
	

	 




	

	# Terminate the program
	li $v0, 10
	syscall

