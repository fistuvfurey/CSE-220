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
	addi	$sp, $sp, -12			# $sp = $sp + -12
	sw		$s0, 0($sp)		# p
	sw		$s1, 4($sp)		# pair
	sw		$ra, 8($sp)		# save return address

	# save arguments
	move 	$s0, $a0		# $s0 = $a0 (save p)
	move 	$s1, $a1		# $s1 = $a1 (save pair)

	# create term
	lw		$a0, 0($s1)		# load coeff from pair and pass
	lw		$a1, 4($s1)		# load exp from pair and pass
	jal		create_term				# jump to create_term and save position to $ra
	bltz $v0, return_init_polynomial	# if head_term is invalid then return -1
	sw		$v0, 0($s0)		# else initialize p->head with term's address
	li		$v0, 1		# $v0 = 1 (return 1)
	
	return_init_polynomial:
		lw		$s0, 0($sp)
		lw		$s1, 4($sp)
		lw		$ra, 8($sp)
		addi	$sp, $sp, 12			# $sp = $sp + 12
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
