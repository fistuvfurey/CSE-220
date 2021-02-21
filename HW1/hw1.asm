.data
ErrMsg: .asciiz "Invalid Argument"
WrongArgMsg: .asciiz "You must provide exactly two arguments"
EvenMsg: .asciiz "Even"
OddMsg: .asciiz "Odd"

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
	lw $s0, arg1_addr
	lbu $t0, 0($s0) # $t0 = first char of arg1

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

	# This block executes if arg1 isn't valid. 
	# Print ErrMsg and terminate.
	la $a0, ErrMsg
	li $v0, 4
	syscall
	li $v0, 10
	syscall

	validate_arg2:
	lw $s0, arg2_addr
	lbu $t1, 0($s0) # $t1 = first char of arg2
	# First check to see if the first char is a '0'. 
	li $a0, '0' # $a0 = '0'
	beq		$t1, $a0, validate_char2	# if $t1 == $a0 then validate_char2

	# This block executes if the first char isn't a '0'.
	# Print ErrMsg and terminate.


	la $a0, ErrMsg
	li $v0, 4
	syscall
	li $v0, 10
	syscall

	validate_char2:
	lbu $t1, 1($s0) #t1 = 2nd char of arg2
	# Check to see if char2 == 'x'
	li $a0, 'x' # $a0 = 'x'
	beq		$t1, $a0, validate_hex	# if $t1 == $a0 then validate_hex

	# This block executes if the char2 isn't a 'x'.
	# Print ErrMsg and terminate. 
	la $a0, EvenMsg
	li $v0, 4
	syscall
	la $a0, ErrMsg
	li $v0, 4
	syscall
	li $v0, 10
	syscall

	validate_hex:
	
	

	 




	

	# Terminate the program
	li $v0, 10
	syscall

