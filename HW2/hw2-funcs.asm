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
  jr $ra

op_precedence:
  jr $ra

apply_bop:
  jr $ra
