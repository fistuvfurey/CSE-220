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
	addi	$sp, $sp, -36			# $sp = $sp + -36
	sw		$s0, 0($sp)		# p
	sw		$s1, 4($sp)		# terms
	sw		$s2, 8($sp)		# N
	sw		$s3, 12($sp)		# current_node
	sw		$s4, 16($sp)		# term.exp
	sw		$s5, 20($sp)		# prev_node
	sw		$s6, 24($sp)		# No. of terms added
	sw		$s7, 28($sp)		# new_term_address
	sw		$ra, 32($sp)		# save return address

	# save arguments
	move 	$s0, $a0		# $s0 = $a0 (save p)
	move 	$s1, $a1		# $s1 = $a1 (save terms)
	move 	$s2, $a2		# $s2 = $a2 (save N)

	li		$s6, 0		# $s6 = 0 (initialize No. of terms added to 0)

	for_term_in_terms:
		blez $s2, return_add_N_terms_to_polynomial 		# if N <= 0 then return

		lw		$s3, 0($s0)		# set head as current_node
		lw		$a0, 0($s1)		# load coeff from terms[]
		lw		$s4, 4($s1)		# load exp from terms[]

		beqz $a0, check_if_last_term	# if coeff == 0 then check if this is the last term in terms[]
		j		create_new_term				# jump to create_new_term (else, create_new_term)
		
		check_if_last_term:
			bltz $s4, return_add_N_terms_to_polynomial		# if exp < 0 then this is the last term so return

		create_new_term:
			move 	$a1, $s4		# $a1 = $s4 (pass exp)
			jal		create_term				# jump to create_term and save position to $ra
			bltz $v0, get_next_term		# term is invalid so skip
			move 	$s7, $v0		# $s7 = $v0 (save new_term_address)

		# check to see if new_term.exp > head.exp
		lw		$t0, 4($s3)		# load head.exp
		lw		$t1, 4($s7)		# load new_term.exp
		bgt		$t1, $t0, new_term_is_new_head	# if $t1 > $t0 then new_term_is_new_head
		j		check_next_node				# else jump to check_next_node
		
		new_term_is_new_head:
			sw		$s3, 8($s7)		# set head as new_term.next
			sw		$s7, 0($s0)		# set p.head as new_term
			j		increment_and_get_next_term				# jump to increment_and_get_next_term
		
		while_next_not_null:
			lw		$t0, 4($s3)		# load current_node.exp
			beq		$t0, $t1, get_next_term	# if $t0 == $t1 (if current_node.exp == term.exp then it's a duplicate so skip)
			bgt		$t1, $t0, insert	# if $t1 > $t0 then insert (if new_term.exp > then current_node.exp then insert)
			# else
			check_next_node:
				move 	$s5, $s3		# $s5 = $s3 (prev_node = current_node)
				lw		$s3, 8($s3)		# current_node = current_node.next
				beqz $s3, is_tail	# if next is null, then we have reached the tail
				j		while_next_not_null				# else jump to while_next_not_null
			
			is_tail:
				# insert at end of list (new_term will be the new tail)
				sw		$s3, 8($s7)		# set new_term.next to current_node
				sw		$s7, 8($s5)		# set prev_node.next to new_term
				addi	$s2, $s2, -1			# $s2 = $s2 + -1 (N--)
				addi	$s6, $s6, 1			# $s6 = $s6 + 1 (increment No. of terms added)
				addi	$s1, $s1, 8			# $s1 = $s1 + 8 (increment terms[])
				move 	$s3, $s7		# $s3 = $s7 (current_term will is the new tail of the list)
				j		for_term_in_terms				# jump to for_term_in_terms

			insert:
				sw		$s3, 8($s7)		# set new_term.next to current_node
				sw		$s7, 8($s5)		# set prev_node.next to new_term

			increment_and_get_next_term:
				addi	$s2, $s2, -1			# $s2 = $s2 + -1 (N--)
				addi	$s6, $s6, 1			# $s6 = $s6 + 1 (increment No. of terms added)
				j		get_next_term				# jump to get_next_term

			get_next_term:
				addi	$s1, $s1, 8			# $s1 = $s1 + 8 (increment terms[])
				lw		$s3, 8($s3)		# get next term
				j		for_term_in_terms				# jump to for_term_in_terms

	return_add_N_terms_to_polynomial:	
		move 	$v0, $s6		# $v0 = $s6	(return No. of terms added)
		lw		$s0, 0($sp)
		lw		$s1, 4($sp)
		lw		$s2, 8($sp)
		lw		$s3, 12($sp)
		lw		$s4, 16($sp)
		lw		$s5, 20($sp)
		lw		$s6, 24($sp)
		lw		$s7, 28($sp)
		lw		$ra, 32($sp)
		addi	$sp, $sp, 36			# $sp = $sp + 36
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
