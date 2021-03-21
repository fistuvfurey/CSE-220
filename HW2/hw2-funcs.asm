############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################

############################## Do not .include any files! #############################

.text
eval:
  # $a0 contains the base address of an asciiz string that represents an AExp.
  # preamble
  addi	$sp, $sp, -36			# $sp = $sp + -36
  sw		$ra, 0($sp)		# store return address
  sw		$s0, 4($sp)		
  sw		$s1, 8($sp)	
  sw		$s2, 12($sp) 
  sw		$s3, 16($sp)		 
  sw		$s4, 20($sp)
  sw		$s5, 24($sp)
  sw		$s6, 28($sp)
  sw		$s7, 32($sp)	 
  # *** function body *** 
  la		$s6, op_stack		# load the base address of the op_stack
  addi	$s6, $s6, 2000			# $s6 = $s6 + 2000 (Add 2000 to the base address of the op_stack to avoid any overlap
  # between the two stacks.
  # We will use $s6 from now on when we need the base address of the op_stack.
  move 	$s0, $a0 		# $s0 = $a0 ($s0 = base address of AExp string)
  addi	$s5, $0, 0			# $s5 = $0 + 0 (op_stack tp, starts off at zero)
  addi	$s1, $0, 0			# $s1 = $0 + 0 (tp of val_stack, starts off at zero)
  # First, lets make sure we don't have an empty string. Also, lets make sure that the first char is a digit.
  # If either of those things, throw an error.
  lb		$s2, 0($s0)		# load the first char
  beqz $s2, parse_error # if the first char is null, throw parse error.
  # If the first char is an open paranthesis, then we have a valid string.
  li		$t0, '('		# $t0 = '('
  beq		$t0, $s2, parse_aexp	# if $t0 == $s2 then parse_aexp
  # If we are here, then the first char is not an open paranthesis. 
  # The first char has to be a digit in order for it to be a valid expression. 
  move 	$a0, $s2		# $a0 = $s2
  jal		is_digit				# jump to is_digit and save position to $ra
  li		$t0, 1		# $t0 = 1
  bne		$t0, $v0, parse_error	# if $t0 != $v0 then target
  parse_aexp:
    lb		$s2, 0($s0)		# load a char of the string into $s2
    beqz $s2, finished_parsing # exit loop if char is null
    move 	$a0, $s2		# $a0 = $s2 (load the char into $a0)
    jal		is_digit				# jump to is_digit and save position to $ra
    li		$t1, 1		# $t1 = 1
    beq		$t1, $v0, char_is_digit	# if $t1 == $v0 then char_is_digit
    # If we are here, than the char is an operator.
    # First, lets check to see if this is a parantheses. 
    li		$t1, '('		# $t1 = '('
    beq		$t1, $s2, is_open_parantheses	# if $t1 == $s2 then is_open_parantheses
    li		$t1, ')'		# $t1 = ')'
    beq		$t1, $s2, is_closed_parantheses	# if $t1 == $s2 then is_closed_parantheses
    # If we are here, then it is not a parantheses, so let's skip these next two labels. 
    j		is_op				# jump to is_op
    is_closed_parantheses:
      # Since we've encountered a closed parantheses, we pop from the op_stack until we encounter a right paranthesis. 
      # We perform the binary operation on two vals at a time from the top of the val_stack.
      # Pop from the op_stack. 
      addi	$s5, $s5, -4			# $s5 = $s5 + -4 (get the address of the top element on the op_stack)
      move 	$a0, $s5		# $a0 = $s5 (pass the tp of the op_stack as arg1)
      move 	$a1, $s6		# $a1 = $s6		# pass the address of the op_stack as arg2)
      jal		stack_pop				# jump to stack_pop and save position to $ra
      move 	$s5, $v0		# $s5 = $v0 (save the new tp of the op_stack)
      move 	$s7, $v1		# $s7 = $v1 (save the operator into $s7)
      # We need to check to see if the operator is an open paranthesis.
      # If it is, we need to break this loop.
      li		$t1, '('		# $t1 = '('
      beq		$t1, $s7, open_paranthesis_break	# if $t1 == $s7 then parse_axp (if the operator is an open paranthesis, we discard it and parse the next char)
      # If we are here, then the operator is not an open paranthesis.
      j		compute_paranthesis				# jump to compute_paranthesis
      open_paranthesis_break:
        addi	$s0, $s0, 1			# $s0 = $s0 + 1 (get next char of string)
        j		parse_aexp				# jump to parse_aexp
      compute_paranthesis: 
        # Pop twice from the val_stack to get the two operands.
        # Get 2nd operand.
        addi	$s1, $s1, -4			# $s1 = $s1 + -4 (get the address of the top element on the val_stack)
        move 	$a0, $s1		# $a0 = $s1
        la		$a1, val_stack
        jal		stack_pop				# jump to stack_pop and save position to $ra
        move 	$s1, $v0		# $s1 = $v0 (save the new tp of the val_stack)
        move 	$s3, $v1		# $s3 = $v1 (save the 2nd operand) 
        # Get the 1st operand.
        addi	$s1, $s1, -4			# $s1 = $s1 + -4 (get the address of the top element on the val_stack)
        move 	$a0, $s1		# $a0 = $s1 (pass the tp of the val_stack as arg1)
        # $a1 already contains the address of the val_stack.
        jal		stack_pop				# jump to stack_pop and save position to $ra
        move 	$s1, $v0		# $s1 = $v0 (save the new tp of the val_stack)
        # $v1 contains the 1st operand.
        # Apply the binary operator to the 1st and 2nd operand.
        move 	$a0, $v1		# $a0 = $v1 (pass the 1st operand as arg1)
        move 	$a1, $s7		# $a1 = $s7 (pass the operator as arg2)
        move 	$a2, $s3		# $a2 = $s3 (pass the 2nd operand as arg3)
        jal		apply_bop				# jump to apply_bop and save position to $ra
        # $v0 contans the result. 
        # Push the result onto the val_stack.
        move 	$a0, $v0		# $a0 = $v0 (pass the result as arg1)
        move 	$a1, $s1		# $a1 = $s1 (pass the tp of the val_stack as arg1)
        la		$a2, val_stack		
        jal		stack_push				# jump to stack_push and save position to $ra
        move 	$s1, $v0		# $s1 = $v0 (save the new tp of the val_stack)
        j		is_closed_parantheses				# jump to is_closed_parantheses
    ### *** End of Loop ***
    is_open_parantheses:
      # Since this is an open parantheses, we can just push it on the stack. 
      move 	$a0, $s2		# $a0 = $s2
      move 	$a1, $s5		# $a1 = $s5
      move 	$a2, $s6		# $a2 = $s6		
      jal		stack_push				# jump to stack_push and save position to $ra
      move 	$s5, $v0		# $s5 = $v0 (save new tp of operator stack)
      addi	$s0, $s0, 1			# $s0 = $s0 + 1 (increment string base address to get next char)
      
      j		parse_aexp				# jump to parse_aexp
    is_op:
      # First, let's check to see if we have a valid op. 
      move 	$a0, $s2		# $a0 = $s2 (pass the op as arg1)
      jal		valid_ops				# jump to valid_ops and save position to $ra
      li		$t1, 0		# $t1 = 0
      beq		$t1, $v0, empty_stack_error	# if $t1 == $v0 then empty_stack_error (throw bad token error message)
      # Now, we also need to check to see if the next char is also an operator. If so, then we have an ill-formed 
      # expression. But, if the next digit is an open parenthesis, then we still have a valid expression thus far.
      # Let's check if the next char is an open paranthesis first. 
      lb		$t1, 1($s0)		# load the next char
      li		$t0, '('		# $t1 = '('
      beq		$t0, $t1, valid_expression	# if $t1 == $t1 then valid_expression
      # Else, if we are here, then the next char isn't an open parenthesis. It must then be a digit. Let's check.
      move 	$a0, $t1		# $a0 = $t1
      jal		is_digit				# jump to is_digit and save position to $ra
      li		$t1, 1 		# $t1 = 1
      bne		$v0, $t1, parse_error	# if $v0 != $t1 then parse_error
      valid_expression:
        # Else if we are here, then the next char is a digit and we have a valid expression thus far.
        # If the op_stack is empty, we can just push the operator onto the stack.
        addi	$a0, $s5, -4			# $a0 = $s5 + -4
        jal		is_stack_empty				# jump to is_stack_empty and save position to $ra
        li		$t1, 1		# $t1 = 1
        beq		$t1, $v0, op_stack_is_empty	# if $t1 == $v0 then op_stack_is_empty
        # Else, if we are here, then the op_stack isn't empty. 
        # First, let's see if the top element of the op_stack is a paranthesis. If it is, then we can just pop
        # the current op onto the op_stack. 
        addi	$a0, $s5, -4			# $a0 = $s5 + -4
        move 	$a1, $s6		# $a1 = $s6
        jal		stack_peek				# jump to stack_peek and save position to $ra
        move 	$s3, $v0		# $s3 = $v0 (save the op at the top of the op_stack)
        li		$t1, '('		# $t1 = '('
        beq		$t1, $s3, op_stack_is_empty	# if $t1 == $s3 then op_stack_is_empty
        # Else, if we are here, then the op at the top of the op_stack is not a parenthesis.
        # Let's get the precedence of the current operator so that we can compare it with the operator at the
        # top of the op_stack. 
        move 	$a0, $s2		# $a0 = $s2
        jal		op_precedence				# jump to op_precedence and save position to $ra
        move 	$s4, $v0		# $s4 = $v0 (save the op_precedence of the current op into $s4
        # $s3 contains the op at the top of the op_stack.
        move 	$a0, $s3		# $a0 = $s3 (the op at the top of the stack)
        jal		op_precedence				# jump to op_precedence and save position to $ra
        bge		$v0, $s4, peek_precedence_gte	# if $v0 >= $s4 then peek_precedence_gte
    op_stack_is_empty:
      # Else, if we are here, then the current op has a greater precedence than the peek (or the op_stack is empty) 
      # and we can just push the op onto the op_stack.
      move 	$a0, $s2		# $a0 = $s2
      move 	$a1, $s5		# $a1 = $s5
      move 	$a2, $s6		# $a2 = $s6
      jal		stack_push				# jump to stack_push and save position to $ra
      move 	$s5, $v0		# $s5 = $v0 (save the tp of the op_stack)
      addi	$s0, $s0, 1			# $s0 = $s0 + 1 (get address of next char)
      j		parse_aexp				# jump to parse_aexp
    peek_precedence_gte:
      # If we are here, then the peek has an op precedence greater than or equal to the current op. 
      while_op_stack_not_empty: 
        # Pop the op from the op_stack
        addi	$s5, $s5, -4			# $s5 = $s5 + -4 (get address of the top element on the op_stack)
        move 	$a0, $s5		# $a0 = $s5
        move 	$a1, $s6		# $a1 = $s6
        jal		stack_pop				# jump to stack_pop and save position to $ra
        move 	$s5, $v0		# $s5 = $v0 (save new op_stack tp into $s5)
        move 	$s7, $v1		# $s7 = $v1 (save op into $s7)
        # Next, pop the 2nd operand from the top of val_stack.
        addi	$s1, $s1, -4			# $s1 = $s1 + -4 (get the address of the top element on the val_stack)
        move 	$a0, $s1		# $a0 = $s1 (pass tp of val_stack as arg1)
        la		$a1, val_stack 
        jal		stack_pop				# jump to stack_pop and save position to $ra
        move 	$s1, $v0		# $s1 = $v0 (save new val_stack tp into $s1)
        move 	$s3, $v1		# $t1 = $v1 (save 2nd operand into $s3)
        # Next, pop the 1st operand from the top of val_stack.
        addi	$s1, $s1, -4			# $s1 = $s1 + -4 (get the address of the top element on the val_stack)
        move 	$a0, $s1		# $a0 = $s1 (pass the tp of val_stack as arg1)
        # The address of val_stack should already be loaded into $a1 from last time.
        jal		stack_pop				# jump to stack_pop and save position to $ra
        move 	$s1, $v0		# $s1 = $v0 (save the new tp of val_stack into $s1)
        # $v1 contains the val of the 1st operand.
        # Apply the operator to the two operands.
        move 	$a0, $v1		# a0 = $v1 (pass the 1st operand as arg1)
        move 	$a1, $s7		# $a1 = $s7 (pass the operator as arg2)
        move 	$a2, $s3		# $a2 = $s3 (pass the 2nd operand as arg2)
        jal		apply_bop				# jump to apply_bop and save position to $ra
        # $v0 contains the result of the binary operation.
        # Push the result onto the val_stack.
        move 	$a0, $v0	#a0 = $v0 (pass the result as arg1)
        move 	$a1, $s1		# $a1 = $s1 (pass the tp of val_stack as arg2)
        la		$a2, val_stack		# load the address of the val_stack as arg3
        jal		stack_push				# jump to stack_push and save position to $ra
        move 	$s1, $v0		# $s1 = $v0 (save the new tp of val_stack into $s1)
        # Now, let's check to see if the op_stack is empty and if the top op on the op_stack has greater-than or equal precedence as the current op.
        addi	$a0, $s5, -4			# $a0 = $s5 + -4 (pass the tp of the op_stack as arg1)
        jal		is_stack_empty				# jump to is_stack_empty and save position to $ra
        li		$t1, 1		# $t1 = 1
        beq		$t1, $v0, push_current_op	# if $t1 == $v0 then push_current_op
        # If we are here, then the op_stack is not empty.
        # Let's compare to see if the top element on the op has greater-than or equal precedence as the current op.
        # $s4 contains the precedence of the current op. 
        move 	$a0, $s5 		# $a0 = $s5 (pass the tp of the op_stack as arg1)
        move 	$a1, $s6		# $a1 = $s6		(load the address of the op_stack as arg2)
        jal		stack_peek				# jump to stack_peek and save position to $ra
        move 	$a0, $v0		# load the top element of the op_stack into $a0 so we can pass it into op_precedence
        jal		op_precedence				# jump to op_precedence and save position to $ra
        # $v0 contains the precedence of the op at the top of the op_stack
        bge		$v0, $s4, while_op_stack_not_empty	# if $v0 >= $s4 then while_op_stack_not_empty
        # If we are here, than the op at the top of the op_stack has a precedence less than the current op.
        # We can push the current op onto the op_stack.
        j		push_current_op				# jump to push_current_op
      push_current_op:
        # $s2 = current op
        move 	$a0, $s2		# $a0 = $s2
        move 	$a1, $s5		# $a1 = $s5 (pass the tp of the op_stack as arg2)
        move 	$a2, $s6		# $a2 = $s6		# pass the address of the op_stack as arg3)
        jal		stack_push				# jump to stack_push and save position to $ra
        move 	$s5, $v0		# $s5 = $v0 (save the new tp of the op_stack into $s5)
        addi	$s0, $s0, 1			# $s0 = $s0 + 1 (increment string address to get the next char)
        j		parse_aexp				# jump to parse_aexp
    char_is_digit:
      # The char is a digit. First, let's check to see if this is an integer greater than 9. We need to check if consecutive chars are also digits.
      move 	$t2, $s0		# $t2 = $s0 (copy base address of string into $t0 so we don't lose our place)
      while_is_digit:
        addi	$t2, $t2, 1			# $t2++ (increment address by 1 to get next char)
        lb		$t3, 0($t2)		# load the next char into $t3
        move 	$a0, $t3		# $a0 = $t3 (load the next char into $a0)
        jal		is_digit				# jump to is_digit and save position to $ra
        li		$t1, 1		# $t1 = 1
        beq		$t1, $v0, while_is_digit	# if $t1 == $v0 then while_is_digit ($t1 = 1)
        addi	$t2, $t2, -1			# $t2 = $t2 + -1
        
      # *** end of while loop ***
      addi	$s3, $t2, 0			# $s3 = $t2 + 0 (save the address of the least-significant digit so that we can use it later to get the next char)
      addi	$t4, $0, 0			# $t4 = $0 + 0 ($t4 will hold the numeric value of the char(s))
      addi	$t5, $0, 0			# $t5 = $0 + 0 (loop variable, i = 0)      
      convert_to_num:
        # Loop from least-significant digit and convert char to decimal integer (start from the address of the least-significant digit).
        # $t2 = address of the least-significant digit.
        lb		$t7, 0($t2)		# load least-significant digit into $t7
        addi	$t7, $t7, -48			# $t2 = $t2 + -48 (subtracting 48 from the char representation gives us the actual numeric value)
        li		$a0, 10		# $a0 = 10
        move 	$a1, $t5		# $a1 = $t5 ($a1 = i)
        jal		pow				# jump to pow and save position to $ra (10^i)
        # Now, $v0 = 10^i.
        mult	$t7, $v0			# $t7 * $v0 = Hi and Lo registers ($t7 * 10^i) 
        mflo	$t6					# copy Lo to $t6 ($t6 the actual value of that digit with proper significance)
        add		$t4, $t6, $t4		# $t4 = $t6 + $t4 ($t4 += $t6)
        addi	$t2, $t2, -1			# $t2 = $t2 + -1 (decrement address to get the next char on the left)
        addi	$t5, $t5, 1			# $t5 = $t5 + 1 (i++)
        blt		$t2, $s0, push_val	# if $t2 < $s0 then push_val
        j		convert_to_num				# jump to convert_to_num
      # *** end of convert_to_num loop ***
      push_val:
        # Now that we have the correct val as a number, let's push it onto the stack. 
        # $t4 contains the numeric value of the val we want to push. 
        move 	$a0, $t4		# $a0 = $t4 (load our num val as an arg for stack_push)
        move 	$a1, $s1		# $a1 = $s1 (load the val_stack top as an arg for stack_push)
        la		$a2, val_stack		 
        jal		stack_push				# jump to stack_push and save position to $ra
        add		$s1, $0, $v0		# $s1 = $0 + $v0 (save the new tp into $s1)
        # Revert back address originally held in $t2 so we can move to the next correct char.
        move 	$s0, $t2		# $s0 = $t2
        sub		$t4, $s3, $s0		# $t4 = $s3 - $s0
        add		$s0, $t4, $s0		# $s0 = $t4 + $s0
        addi	$s0, $s0, 1		# $s0 = $s0 + 1 (increment the address of the string so we can parse the next char)
        j		parse_aexp				# jump to parse_aexp
  # *** End of parsing loop ***
  finished_parsing:
    # Now that we have finished parsing, we need to pop form the operator stack until it is empty and perform the
    # operations on two operands from the val_stack at a time.
    # First, check to see if the op_stack is empty.
    addi	$a0, $s5, -4			# $a0 = $s5 + -4
    jal		is_stack_empty				# jump to is_stack_empty and save position to $ra
    li		$t0, 1		# $t0 = 1
    beq		$t0, $v0, print_arithmetic_result	# if $t0 == $v0 then return_arithmetic_result
    # If we are here, then the op_stack is not empty.
    # First, pop an operator from the op_stack.
    # $a0 already contains the address of the element to pop.
    move 	$a1, $s6		# $a1 = $s6		 
    jal		stack_pop				# jump to stack_pop and save position to $ra
    move 	$s5, $v0		# $s5 = $v0 (save new tp of op_stack)
    move 	$s7, $v1		# $s7 = $v1 (save operator)
    # Pop the 2nd operand from the val_stack.
    addi	$a0, $s1, -4			# $a0 = $s1 + -4 (pass the tp of the val_stack as arg1)
    la		$a1, val_stack		
    jal		stack_pop				# jump to stack_pop and save position to $ra
    move 	$s1, $v0		# $s5 = $v0 (save the new tp of the val_stack)
    move 	$s3, $v1		# $t1 = $v1 (save the 2nd operand)
    addi	$a0, $s1, -4			# $a0 = $s5 + -4
    # $a1 already contains the base address of val_stack
    jal		stack_pop				# jump to stack_pop and save position to $ra
    move 	$s1, $v0		# $s5 = $v0 (save the new tp of the val_stack)
    # $v1 contains the 1st operator.
    # Perform the binary operation.
    move 	$a0, $v1		# $a0 = $v1 (pass the 1st operand as arg1)
    move 	$a1, $s7		# $a1 = $s7 (pass the operator as arg2)
    move 	$a2, $s3		# $a2 = $t1 (pass the 2nd operator as arg3)
    jal		apply_bop				# jump to apply_bop and save position to $ra
    # $v0 contains the result of the binary operation.
    # Push result onto val_stack. 
    move 	$a0, $v0		# $a0 = $v0 (pass the result as arg1)
    move 	$a1, $s1		# $a1 = $s1 (pass the tp of the val_stack)
    la		$a2, val_stack		# (pass the base address of val_stack as arg3)
    jal		stack_push				# jump to stack_push and save position to $ra
    move 	$s1, $v0		# $s1 = $v0 (save new tp of val_stack)
    j		finished_parsing				# jump to finished_parsing
  # *** End of finsihed_parsing loop *** 
  print_arithmetic_result:
    # Print result of arithmetic expression. 
    # The last element on the val_stack is the final result. 
    # Let's pop that from the val_stack and return it. 
    addi	$s1, $s1, -4			# $s1 = $s1 + -4
    move 	$a0, $s1		# $a0 = $s1 (pass the tp of the val_stack as arg1)
    la		$a1, val_stack		 
    jal		stack_pop				# jump to stack_pop and save position to $ra
    # $v1 contains the final result.
    # Print result.
    li		$v0, 1		# $v0 = 1
    move 	$a0, $v1		# $a0 = $v1
    syscall
    # Postamble 
    lw		$ra, 0($sp)		# load return address
    lw		$s0, 4($sp)
    lw		$s2, 8($sp)
    lw		$s1, 12($sp)	
    lw		$s3, 16($sp)		 
    lw		$s4, 20($sp)
    lw		$s5, 24($sp)
    lw		$s6, 28($sp)
    lw		$s7, 32($sp)
    addi	$sp, $sp, 36			# $sp = $sp + 36 (reallocate memory)
    jr $ra

is_digit:
  # $a0 contains the char to check.
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
  # $a0 is tp, is the offset for the top element of the stack and can be used to read an element at the top
  # of the stack.
  # $a1 is the base address of the stack.
  # First, we want to check to see if the stack is empty by calling is_stack_empty
  addi	$sp, $sp, -12			# $sp = $sp + -12 (allocate space)
  sw		$ra, 0($sp)		# store the return address
  sw		$s0, 4($sp)		
  sw		$s1, 8($sp)		 
  move 	$s0, $a0		# $s0 = $a0 ($s0 = tp)
  move 	$s1, $a1		# $s1 = $a1 ($s1 = base address of stack)
  jal		is_stack_empty				# jump to is_stack_empty and save position to $ra
  li		$t0, 1		# $t0 = 1
  beq		$v0, $t0, empty_stack_error	# if $v0 == $t0 then empty_stack_error
  # If we are here, then the stack isn't empty and we can continue peeking.
  add		$t1, $s0, $s1		# $t1 = $s0 + $s1 ($t1 = the address of the top element of the stack)
  lw		$v0, 0($t1)		# load the top element into $v0 to return 
  # postamble
  lw		$ra, 0($sp)		# load back return address
  lw		$s0, 4($sp)		
  lw		$s1, 8($sp)
  addi	$sp, $sp, 12			# $sp = $sp + 12 (reallocate space)
  jr $ra

stack_pop:
  # $a0 is tp, the offset for the top element on the stack.
  # $a1 is the base address of the stack.
  # First, we want to check to see if the stack is empty by calling is_stack_empty
  addi	$sp, $sp, -12			# $sp = $sp + -12 (allocate space)
  sw		$ra, 0($sp)		# store return address
  sw		$s0, 4($sp)		
  sw		$s1, 8($sp)		
  move 	$s0, $a0		# $s0 = $a0 ($s0 = tp, the offset for the top element on the stack)
  move 	$s1, $a1		# $s1 = $a1 ($s1 = the base address of the stack)
  jal		is_stack_empty				# jump to is_stack_empty and save position to $ra
  li		$t0, 1		# $t0 = 1
  beq		$v0, $t0, empty_stack_error	# if $v0 == $t0 then empty_stack_error
  # If we are here, then the stack isn't empty and we can continue with popping from the stack.
  add		$t1, $s0, $s1		# $t1 = $s0 + $s1 ($t1 = the address of the top element of the stack)
  lw		$v1, 0($t1)		# load the top element into $v1 to return
  move 	$v0, $s0		# $v0 = $s0 ($v0 = the new top of the stack)
  # postamble
  lw		$ra, 0($sp)		# load back return address
  lw		$s0, 4($sp)		
  lw		$s1, 8($sp)		 
  addi	$sp, $sp, 12			# $sp = $sp + 12 (reallocate space) 
  jr $ra

is_stack_empty:
  # $a0 contains the tp of the stack.
  li		$t0, 0		# $t0 = 0
  blt		$a0, $t0, stack_is_empty	# if $a0 < $t0 then stack_is_empty
  # If we are here, then the stack isn't empty
  addi	$v0, $0, 0			# $v0 = $0 + 0
  j		return_is_empty				# jump to return_is_empty
  stack_is_empty:
    addi	$v0, $0, 1			# $v0 = $0 + 1
  return_is_empty:  
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

empty_stack_error:
  la		$a0, BadToken		# load error message
  li		$v0, 4		# $v0 = 4
  syscall # print error message
  li		$v0, 10		# $v0 = 10
  syscall # terminate

parse_error:
  la		$a0, ParseError		# load error message
  li		$v0, 4		# $v0 = 4
  syscall # print error message
  li		$v0, 10		# $v0 = 10
  syscall # terminate

pow:
  # Takes two args, $a0 and $a1, and returns $a0^$a1
  addi	$t0, $0, 0			# $t0 = $0 + 0 (loop variable, i = 0)
  addi	$v0, $0, 1			# $v0 = $0 + 1 (result)
  loop:
    beq		$t0, $a1, done	# if $t0 == $a1 then done
    mult	$v0, $a0			# $v0 * $a0 = Hi and Lo registers
    mflo	$v0					# copy Lo to $v0
    addi	$t0, $t0, 1			# $t0 = $t0 + 1 (i++)
    j		loop				# jump to loop
  done:
    jr		$ra					# jump to $ra
    
