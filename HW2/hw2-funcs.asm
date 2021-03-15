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
  # $a0 denotes the integer element to be pushed onto the stack.
  # $a1 is tp, an int that indicates the top of the stack.
  # $a2 is the int base address of the stack.
  li		$t1, 2004		# $t1 = 2004 (2004 is the offset for 500 elements in the stack)
  beq		$a1, $t1, max_elements_reached	# if $a1 == $t1 then max_elements_reached
  # If we are here then the stack isn't full. We can continue with pushing the new element. 
  add	$t0, $a2, $a1			# $t0 = $a2 + $a1 ($t0 = address of the top of the stack)
  sw		$a0, 0($t0)		# store the int element at the top of the stack
  addi	$v0, $a1, 4			# $v0 = $a1 + 4 (increment the top of the stack to return) 
  j		return_tp				# jump to return_tp
  max_elements_reached:
    la		$a0, BadToken		# load error message string
    li		$v0, 4		# $v0 = 4
    syscall # print error message
    li		$v0, 10		# $v0 = 10
    syscall # terminate
  return_tp:  
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
  addi	$sp, $sp, -8			# $sp = $sp + -8 (allocate space on the stack)
  sw		$ra, 0($sp)		# store $ra onto the stack
  sw		$s0, 4($sp)		# store $s0 onto the stack
  move 	$s0, $a0		# $s0 = $a0 (save arg into $s0)
  jal		valid_ops				# jump to valid_ops and save position to $ra
  add		$t0, $0, $v0		# $t0 = $0 + $v0 (save return value of valid_ops into $t0)
  # The return value of valid_ops will be 0 if the operator is invlalid.
  li		$t1, 0		# $t1 = 0
  beq		$t0, $t1, invalid_op	# if $t0 == $t1 then invalid_op
  # If we are here, then the operator is valid and we should continue.
  # Check to see which operator we have and branch to proper precedence label.
  li		$t1, '+'		# $t1 = '+'
  beq		$s0, $t1, precedence1	# if $a0 == $t1 then precedence1
  li		$t1, '-'		# $t1 = '-'
  beq		$s0, $t1, precedence1	# if $a0 == $t1 then precedence1
  li		$t1, '*'		# $t1 = '*'
  beq		$s0, $t1, precedence2	# if $a0 == $t1 then precedence2
  li		$t1, '/'		# $t1 = '/'
  beq		$s0, $t1, precedence2	# if $a0 == $t1 then precedence2
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
    lw		$s0, 4($sp)		# load back in $s0
    addi	$sp, $sp, 8			# $sp = $sp + 8 (reallocate space back on to the stack)
    jr $ra

apply_bop:
  # $a0 contains first integer operand
  # $a1 contains the char operation
  # $a2 contains the second integer operand
  li		$t0, '+'		# $t0 = '+'
  beq		$t0, $a1, addition	# if $t0 == $a1 then addition
  li		$t0, '-'		# $t0 = '-'
  beq		$t0, $a1, subtraction	# if $t0 == $a1 then subtraction
  li		$t0, '*'		# $t0 = '*'
  beq		$t0, $a1, multiplication	# if $t0 == $a1 then multiplication
  li		$t0, '/'		# $t0 = '/'
  beq		$t0, $a1, division	# if $t0 == $a1 then division
  # We should never be here. 
  addition:
    add		$v0, $a0, $a2		# $v0 = $a0 + $a2
    j		return_op_result				# jump to return_op_result
  subtraction:
    sub		$v0, $a0, $a2		# $v0 = $a0 - $a2
    j		return_op_result				# jump to return_op_result
  multiplication:
    mult	$a0, $a2			# $a0 * $a2 = Hi and Lo registers
    mflo	$v0					# copy Lo to $v0
    j		return_op_result				# jump to return_op_result
  division:
    # First, make sure we aren't trying to divde by 0.
    beq		$a2, $0, division_by_zero_error	# if $a2 == $0 then division_by_zero_error
    
    div		$a0, $a2			# $a0 / $a2
    mflo	$t1				# $t1 = floor($a0 / $a2) 
    # Now check to see if either of the operands are negative.
    blt		$a0, $0, op_is_negative	# if $a0 < $0 then op_is_negative
    blt		$a2, $0, op_is_negative	# if $a2 < $0 then op_is_negative
    # If we are here, then none of the operators are negative and the result of the floor division is the low register.
    move 	$v0, $t1		# $v0 = $t1
    j		return_op_result				# jump to return_op_result
    op_is_negative:
      # If we are here, the result of the floor division is the lo register - 1.
      # $t1 contains the value from the lo register. 
      addi	$v0, $t1, -1			# $v0 = $t1 - 1 
      j		return_op_result				# jump to return_op_result
    division_by_zero_error:
      la		$a0, ApplyOpError		# error message to be printed
      li		$v0, 4		# $v0 = 4
      syscall # print the error message
      li		$v0, 10		# $v0 = 10
      syscall # terminate   
    return_op_result:
      jr $ra
