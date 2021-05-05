############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
.text:

create_term:
	bltz $a1, invalid_term	# if exp is less then zero then invalid_term
	beqz $a0, invalid_term	# if coeff == 0 then invalid term
	
	# save arguments
	move 	$t1, $a0		# $t1 = $a0 (save coeff)
	move 	$t2, $a1		# $t2 = $a1 (save exp)
	
	# allocate 12 bytes to store term
	li		$a0, 12		# $a0 = 12 (allocate for 12 bytes)
	li		$v0, 9		# $v0 = 9
	syscall
	move 	$t0, $v0		# $t0 = $v0 (save newly allocated memory buffer)
	
	# initialize the term struct
	sw		$t1, 0($t0)		# store coeff
	sw		$t2, 4($t0)		# store exp
	sw		$0, 8($t0)		# initialize next_term to 0

	move 	$v0, $t0		# $v0 = $t0 (return address of term)
	j		return_create_term				# jump to return_create_term
	
	invalid_term:
		li		$v0, -1		# $v0 = -1		

	return_create_term:
		jr $ra

init_polynomial:
	jr $ra
add_N_terms_to_polynomial:
	jr $ra
update_N_terms_in_polynomial:
	jr $ra
get_Nth_term:
	jr $ra
remove_Nth_term:
	jr $ra
add_poly:
	jr $ra
mult_poly:
	jr $ra
