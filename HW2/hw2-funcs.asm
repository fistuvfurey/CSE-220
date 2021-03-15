############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################

############################## Do not .include any files! #############################

.text
eval:
  jr $ra

is_digit:
  # $a0 contains the arg of this function.
  # Check to see if $a0 holds a digit.
  li		$t1, 48		# $t1 = 48 (ASCII value for '0')
  blt		$a0, $t1, not_digit	# if $a0, < $t1 then not_digit
  li		$t1, 57		# $t1 = 58 (ASCII value for one above '9')
  bge		$a0, $t1, not_digit	# if $a0 >= $t1 then not_digit
  # If we are here, then the arg is a digit.
  addi	$v0, $0, 1			# $v0 = $0 + 1 (return 1 since the arg was a digit) 
  j		skip_not_digit				# jump to skip_not_digit
  not_digit:
    addi	$v0, $0, 0			# $v0 = $0 + 0 (return 0 since the arg wasn't a digit)
  skip_not_digit:
    jr $ra

stack_push:
  jr $ra

stack_peek:
  jr $ra

stack_pop:
  jr $ra

is_stack_empty:
  jr $ra

valid_ops:
  # $a0 contains the arg of this function. 
  # Check to see if $a0 holds a valid operator.
  li		$t1, '+'		# $t1 = '+'
  beq		$a0, $t1, valid_op	# if $a0 == $t1 then valid_op
  li		$t1, '-'		# $t1 = '-'
  beq		$a0, $t1, valid_op	# if $a0 == $t1 then valid_op
  li		$t1, '*'		# $t1 = '*'
  beq		$a0, $t1, valid_op	# if $a0 == $t1 then valid_op
  li		$t1, '/'		# $t1 = '/'
  beq		$a0, $t1, valid_op	# if $a0 == $t1 then valid_op
  # If we are here, then the arg was invalid.
  addi	$v0, $0, 0			# $v0 = $0 + 0 (return 0 since the arg was invalid)
  j		skip_valid_op				# jump to skip_valid_op
  valid_op:
    addi	$v0, $0, 1			# $v0 = $0 + 1 (return 1 since the arg was a valid operator)
  skip_valid_op:
    jr $ra

op_precedence:
  # $a0 already contains the operator arg we want to set a precedence to. 
  # First we want to check to see if our arg is a valid operator by calling valid_ops.
  addi	$sp, $sp, -4			# $sp = $sp + -4 (allocate space on the stack to preserve $ra)
  sw		$ra, 0($sp)		# store $ra onto the stack
  jal		valid_ops				# jump to valid_ops and save position to $ra
  add		$t0, $0, $v0		# $t0 = $0 + $v0 (save return value of valid_ops into $t0)
  # The return value of valid_ops will be 0 if the operator is invlalid.
  li		$t1, 0		# $t1 = 0
  beq		$t0, $t1, invalid_op	# if $t0 == $t1 then invalid_op
  # If we are here, then the operator is valid and we should continue.
  # Check to see which operator we have and branch to proper precedence label.
  li		$t1, '+'		# $t1 = '+'
  beq		$a0, $t1, precedence1	# if $a0 == $t1 then precedence1
  li		$t1, '-'		# $t1 = '-'
  beq		$a0, $t1, precedence1	# if $a0 == $t1 then precedence1
  li		$t1, '*'		# $t1 = '*'
  beq		$a0, $t1, precedence2	# if $a0 == $t1 then precedence2
  li		$t1, '/'		# $t1 = '/'
  beq		$a0, $t1, precedence2	# if $a0 == $t1 then precedence2
  # We should never be here. 
  precedence1:
    addi	$v0, $0, 1			# $v0 = $0 + 1 (return precedence 1)
    j		return_precedence				# jump to return_precedence    
  precedence2:
    addi	$v0, $0, 2			# $v0 = $0 + 2 (return precedence 2)
    j		return_precedence				# jump to return_precedence
  invalid_op:
    la		$a0, BadToken		# load error message
    li		$v0, 4		# $v0 = 4
    syscall # print error message
    li		$v0, 10		# $v0 = 10
    syscall # terminate
  return_precedence:
    lw		$ra, 0($sp)		# load return address
    addi	$sp, $sp, 4			# $sp = $sp + 4 (reallocate space back on to the stack)
    jr $ra

apply_bop:
  jr $ra
