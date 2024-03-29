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
	sw		$s1, 4($sp)		# terms[]
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
		# check to see if new_term.exp == head.exp
		beq		$t0, $t1, get_next_term	# if $t0 == $t1 then get_next_term
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
	# $t0 = current_node
	# $t1 = t.exp
	# $t2 = current_node.exp
	# $t3 = base address of updated[]
	# $t6 = first free index of updated[]
	addi	$sp, $sp, -16			# $sp = $sp + -16
	sw		$s0, 0($sp)		# p
	sw		$s1, 4($sp)		# terms[]
	sw		$s2, 8($sp)		# N
	sw		$s3, 12($sp)		# No. of terms updated

	# save arguments
	move 	$s0, $a0		# $s0 = $a0 (save p)
	move 	$s1, $a1		# $s1 = $a1 (save terms)
	move 	$s2, $a2		# $s2 = $a2 (save N)

	li		$s3, 0		# $s3 = 0 (initialize No. of terms updated to 0)

	# allocate space for updated[]
	li		$t0, 4		# $t0 = 4
	mult	$t0, $s2			# $t0 * $s2 = Hi and Lo registers
	mflo	$a0					# copy Lo to $a0 ($a0 = amount of space to allocate on heap for array)
	li		$v0, 9		# $v0 = 9
	syscall
	move 	$t3, $v0		# $t3 = $v0 (save newly allocated memory buffer as base address of updated[])
	move 	$t6, $t6		# $t6 = $t6 (copy address of updated[])

	for_t_in_terms:
		blez $s2, return_update_N_terms_in_polynomial 		# if N <= 0 then return
		lw		$t0, 0($s0)		# set current_node to head

		search_for_t_in_polynomial:
			lw		$t1, 4($s1)		# load t.exp
			bltz $t1, return_update_N_terms_in_polynomial		# if t.exp is less than 0 then return
			lw		$t2, 4($t0)		# load current_node.exp
			beq		$t2, $t1, check_if_already_updated	# if $t2 == $t1 then check_if_already_updated (if current_node.exp == t.exp)
			lw		$t0, 8($t0)		# current_node = current_node.next
			beqz $t0, get_next_t	# if current_node == null then move on to the next t
			j		search_for_t_in_polynomial				# jump to search_for_t_in_polynomial (else keep searching for term in polynomial)

			get_next_t:
				addi	$s1, $s1, 8			# $s1 = $s1 + 8 (increment terms[])
				j		for_t_in_terms				# jump to for_t_in_terms

			check_if_already_updated:
				move 	$t5, $t3		# $t5 = $t3 (copy base address of updated[])
				for_exp_in_updated:
					lw		$t4, 0($t5)		# load exp from updated[]
					beqz $t4, first_update	# if $t4 == null then we have reached the end of updated[] so this term has not been updated yet (break)
					beq		$t4, $t1, already_updated	# if $t4 == $t1 then already_updated (if t.exp == exp)
					addi	$t5, $t5, 4			# $t5 = $t5 + 4 (else increment updated[])
					j		for_exp_in_updated				# jump to for_exp_in_updated (exp != t.exp so keep searching)

				already_updated:
					lw		$t5, 0($s1)		# load t.coeff
					sw		$t5, 0($t0)		# update coeff of current_node
					j		get_next_t				# jump to get_next_t
					
				first_update:
					lw		$t5, 0($s1)		# load t.coeff
					sw		$t5, 0($t0)		# update coeff of current_node
					addi	$s2, $s2, -1			# $s2 = $s2 + -1 (N--)
					addi	$s3, $s3, 1			# $s3 = $s3 + 1 (increment No. of terms updated)
					sw		$t1, 0($t3)		# put t.exp in updated[]
					addi	$t6, $t6, 4			# $t6 = $t6 + 4 (update address of next free index of updated[])
					j		get_next_t				# jump to get_next_t	
	
	return_update_N_terms_in_polynomial:
		move 	$v0, $s3		# $v0 = $s3 (return No. of terms updated)
		lw		$s0, 0($sp)
		lw		$s1, 4($sp)
		lw		$s2, 8($sp)
		lw		$s3, 12($sp)
		addi	$sp, $sp, 16			# $sp = $sp + 16
		jr $ra

get_Nth_term:
	# t0 = current_node_number
	# $t1 = current_node
	addi	$sp, $sp, -8			# $sp = $sp + -8
	sw		$s0, 0($sp)		# p
	sw		$s1, 4($sp)		# N

	# save arguments
	move 	$s0, $a0		# $s0 = $a0 (save p) 
	move 	$s1, $a1		# $s1 = $a1 (save N)

	li		$t0, 1		# $t0 = 1 (current_node_number)
	lw		$t1, 0($s0)		# set current_node to head
	beqz $t1, term_dne		# if p is null return this term_dne since the polynomial is empty 
	while_current_node_not_N:
		beq		$t0, $s1, return_this_node	# if $t0 == $s1 then return_this_node (if current_node_number == N then break)
		addi	$t0, $t0, 1			# $t0 = $t0 + 1 (current_node_number++)
		lw		$t1, 8($t1)		# current_node = current_node.next
		beqz $t1, term_dne		# if current_node.next == null then we have reached the end of list so the term DNE 
		j		while_current_node_not_N				# jump to while_current_node_not_N
	
	return_this_node:
		lw		$v0, 4($t1)		# return current_node.exp
		lw		$v1, 0($t1)		# return current_node.coeff
		j		return_Nth_term				# jump to return_Nth_term
		
	term_dne:
		# return (-1, 0)
		li		$v0, -1		# $v0 = -1
		li		$v1, 0		# $v1 = 0

	return_Nth_term:
		lw		$s0, 0($sp)
		lw		$s1, 4($sp)
		addi	$sp, $sp, 8			# $sp = $sp + 8
		jr $ra

remove_Nth_term:
	# $t0 = current_node_number
	# $t1 = current_node
	# $t2 = prev_node
	addi	$sp, $sp, -8			# $sp = $sp + -8
	sw		$s0, 0($sp)		# p
	sw		$s1, 4($sp)		# N

	# save arguments
	move 	$s0, $a0		# $s0 = $a0 (save p)
	move 	$s1, $a1		# $s1 = $a1 (save N)

	li		$t0, 1		# $t0 = 1 (current_node_number)
	# check to see if the term to remove is the head
	beq		$t0, $s1, remove_head	# if $t0 == $s1 (if current_node_number == N then remove_head)
	addi	$t0, $t0, 1			# $t0 = $t0 + 1 (current_node_number++)
	lw		$t1, 0($s0)		# current_node = head
	move 	$t2, $t1		# $t2 = $t1 (prev_node = head)
	lw		$t1, 8($t1)		# current_node = head.next

	while_current_node_not_term_to_remove:	
		beq		$t0, $s1, remove_this_term	# if $t0 == $s1 then remove_this_term
		addi	$t0, $t0, 1			# $t0 = $t0 + 1 (current_node_number++)
		lw		$t1, 8($t1)		# current_node = current_node.next
		beqz $t1, term_not_found	# if current_node.next == null then we have reached the end of the list and the term was not found
		j		while_current_node_not_term_to_remove				# jump to while_current_node_not_term_to_remove

	remove_head:
		lw		$t0, 0($s0)		# get head from p
		lw		$v0, 4($t0)		# return head.exp
		lw		$v1, 0($t0)		# return head.coeff
		lw		$t0, 8($t0)		# load head.next
		sw		$t0, 0($s0)		# head = head.next
		j		return_remove_Nth_term				# jump to return_remove_Nth_term
		
	remove_this_term:
		lw		$v0, 4($t1)		# return current_node.exp
		lw		$v1, 0($t1)		# return current_node.coeff
		lw		$t0, 8($t1)		# $t0 = current_node.next
		sw		$t0, 8($t2)		# prev_node.next = current_node.next
		j		return_remove_Nth_term				# jump to return_remove_Nth_term
		
	term_not_found:
		# (return (-1, 0)
		li		$v0, -1		# $v0 = -1
		li		$v1, 0		# $v1 = 0

	return_remove_Nth_term:
		lw		$s0, 0($sp)
		lw		$s1, 4($sp)
		addi	$sp, $sp, 8			# $sp = $sp + 8
		jr $ra

add_poly:
	addi	$sp, $sp, -36			# $sp = $sp + -36
	sw		$s0, 0($sp)		# p
	sw		$s1, 4($sp)		# q
	sw		$s2, 8($sp)		# r
	sw		$s3, 12($sp)		# N.p
	sw		$s4, 16($sp)		# N.q
	sw		$s5, 20($sp)		# base address of terms[]
	sw		$s6, 24($sp)		# pointer to current term in terms[]
	sw		$s7, 28($sp)		# number of terms in terms[]
	sw		$ra, 32($sp)		# save return address 
	
	# save arguments
	move 	$s0, $a0		# $s0 = $a0 (save p)
	move 	$s1, $a1		# $s1 = $a1 (save q)
	move 	$s2, $a2		# $s2 = $a2 (save r)

	li		$s3, 1		# $s3 = 1 (int N.p = 1)
	li		$s4, 1		# $s4 = 1 (int N.q = 1)
	
	# check to see if p is empty
	move 	$a0, $s0		# $a0 = $s0 (pass p) 
	move 	$a1, $s3		# $a1 = $s3 (pass N.p)
	jal		get_Nth_term				# jump to get_Nth_term and save position to $ra
	beqz $v1, p_is_empty	# if p is empty then check to see if q is empty
	j		create_terms_array				# else jump to create_terms_array
	
	p_is_empty:
		# check to see if q is also empty
		move 	$a0, $s1		# $a0 = $s1 (pass q)
		move 	$a1, $s4		# $a1 = $s3 (pass N.q)
		jal		get_Nth_term			# jump to get_Nth_term and save position to $ra
		beqz $v1, add_failure	# if q is also empty then add_failure

	create_terms_array:
		# allocate space on the heap for base address of terms[]
		li		$a0, 0xFFFF
		li		$v0, 9		# $v0 = 9
		syscall
		move 	$s5, $v0		# $s5 = $v0 (save base address of terms[])
		move 	$s6, $s5		# $s7 = $s5 (copy base address of terms[] for pointer) 

	for_term_in_polynomial:
		# get term from p
		move 	$a0, $s0		# $a0 = $s0 (pass p) 
		move 	$a1, $s3		# $a1 = $s3 (pass N.p)
		jal		get_Nth_term				# jump to get_Nth_term and save position to $ra
		beqz $v1, add_remaining_terms		# check to see if we have reached the end of p
		move 	$t0, $v0		# $t0 = $v0 (save exp)
		move 	$t1, $v1		# $t1 = $v1 (save coeff)

		# make room on heap
		li		$a0, 12		# $a0 = 12
		li		$v0, 9		# $v0 = 9
		syscall
		sw		$s7, 0($v0)		# store no. of terms
		sw		$t0, 4($v0)		# store exp
		sw		$t1, 8($v0)		# store coeff
		move 	$s7, $v0		# $s7 = $v0 (save address of array)
		
		# get term from q
		move 	$a0, $s1		# $a0 = $s1 (pass q)
		move 	$a1, $s4		# $a1 = $s3 (pass N.q)
		jal		get_Nth_term				# jump to get_Nth_term and save position to $ra
		beqz $v1, add_remaining_terms		# check to see if we have reached the end of q

		lw		$t0, 4($s7)		# load exp
		lw		$t1, 8($s7)		# load coeff
		lw		$s7, 0($s7)		# load no. of terms

		# compare exps
		# case 1 (p.exp == q.exp)
		beq		$v0, $t0, exps_are_equal	# if $v1 == $t0 then exps_are_equal
		# case 2 (p.exp > q.exp)
		bgt		$t0, $v0, p_exp_greater	# if $t0 > $v0 then p_exp_greater
		# case 3 (q.exp > p.exp)
		# add term from q to terms[]
		sw		$v1, 0($s6)		# store q.coeff in terms[]
		sw		$v0, 4($s6)		# store q.exp in terms[]
		addi	$s6, $s6, 8			# $s6 = $s6 + 8 (increment terms[] pointer)
		addi	$s4, $s4, 1			# $s4 = $s4 + 1 (N.q++)
		addi	$s7, $s7, 1			# $s7 = $s7 + 1 (increment number of terms in terms[])
		j		for_term_in_polynomial				# jump to for_term_in_polynomial

		exps_are_equal:
			# add coeffs
			add		$t1, $v1, $t1		# $t0 = $v1 + $t0 (r.coeff = q.coeff + p.coeff)
			beqz $t1, increment			# if terms cancel each other out then don't add this term		
			sw		$t1, 0($s6)		# store r.coeff in terms[]
			# store exp in terms[]
			sw		$t0, 4($s6)		# store exp in terms[]
			increment:
				addi	$s6, $s6, 8			# $s6 = $s6 + 8 (increment terms[] pointer)
				addi	$s3, $s3, 1			# $s3 = $s3 + 1 (N.p++)
				addi	$s4, $s4, 1			# $s4 = $s4 + 1 (N.q++)
				addi	$s7, $s7, 1			# $s7 = $s7 + 1 (increment number of terms in terms[])
				j		for_term_in_polynomial				# jump to for_term_in_polynomial

		p_exp_greater:
			# add term from p to terms[]
			sw		$t1, 0($s6)		# store p.coeff in terms[]
			sw		$t0, 4($s6)		# store p.exp in terms[]
			addi	$s6, $s6, 8			# $s6 = $s6 + 8 (increment terms[] pointer)
			addi	$s3, $s3, 1			# $s3 = $s3 + 1 (N.p++)
			addi	$s7, $s7, 1			# $s7 = $s7 + 1 (increment number of terms in terms[])
			j		for_term_in_polynomial				# jump to for_term_in_polynomial

	add_remaining_terms:
		beq		$a0, $s0, while_q_not_empty	# if $a0 == $s0 then while_q_not_empty

		while_p_not_empty:
			# get term from p 
			move	$a0, $s0		# $a0 = $s0 (pass p) 
			move	$a1, $s3		# $a1 = $s3 (pass N.p)
			jal		get_Nth_term				# jump to get_Nth_term and save position to $ra
			beqz $v1, add_terms_to_r		# if we have reached the end of p then we add all terms in terms[] to r
			# store p.coeff and p.exp in terms[]
			sw		$v1, 0($s6)		# store q.coeff in terms[]
			sw		$v0, 4($s6)		# store q.exp in terms[]
			addi	$s6, $s6, 8			# $s6 = $s6 + 8 (increment terms[] pointer)
			addi	$s3, $s3, 1			# $s3 = $s3 + 1 (N.p++)
			addi	$s7, $s7, 1			# $s7 = $s7 + 1 (increment number of terms in terms[])
			j		while_p_not_empty				# jump to while_p_not_empty

		while_q_not_empty:
			# get term from q 
			move	$a0, $s1		# $a0 = $s1 (pass q)
			move	$a1, $s4		# $a1 = $s4 (pass N.q)
			jal		get_Nth_term				# jump to get_Nth_term and save position to $ra
			beqz, $v1, add_terms_to_r		# if we have reached end of q then add all terms in terms[] to r 
			# store q.coeff and q.exp in terms[]
			sw		$v1, 0($s6)		# store q.coeff in terms[]
			sw		$v0, 4($s6)		# store q.exp in terms[]
			addi	$s6, $s6, 8			# $s6 = $s6 + 8 (increment terms[] pointer)
			addi	$s4, $s4, 1			# $s4 = $s4 + 1 (N.q++)
			addi	$s7, $s7, 1			# $s7 = $s7 + 1 (increment number of terms in terms[])
			j		while_q_not_empty				# jump to while_q_not_empty
			
	add_terms_to_r:
		# add (0, -1) as last term in r
		li		$t0, 0		# $t0 = 0
		sw		$t0, 0($s6)		# load 0 as last coeff in terms[]
		li		$t0, -1		# $t0 = -1
		sw		$t0, 4($s6)		# load -1 as last exp in terms[]
		
		# init r
		move 	$a0, $s2		# $a0 = $s2 (pass r)
		move 	$a1, $s5		# $a1 = $s5 (pass base address of terms)
		lw		$t0, 0($a1)		# load first coeff from terms[]
		beqz $t0, add_failure	# if the result polynomial r is empty then add_failure
		jal		init_polynomial				# jump to init_polynomial and save position to $ra
		bltz $v0, add_failure		# if return value is less than 0 then return add_failure
		addi	$s5, $s5, 8			# $s5 = $s5 + 8	(increment base address of terms[])
		addi	$s7, $s7, -1			# $s7 = $s7 + -1 (decrement number of terms in terms[])
		
		# add terms in terms[] to r	
		move 	$a0, $s2		# $a0 = $s2 (pass r)
		move 	$a1, $s5		# $a1 = $s5 (pass base address of terms[]				
		move 	$a2, $s7		# $a2 = $s7 (pass number of terms in terms[])
		jal		add_N_terms_to_polynomial				# jump to add_N_terms_to_polynomial and save position to $ra
		li		$v0, 1		# $v0 = 1 (add was successful so return 1)
		j		return_add_poly				# jump to return_add_poly
			
	add_failure:
		li		$v0, 0		# $v0 = 0
					
	return_add_poly:
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

mult_poly:
	addi	$sp, $sp, -36			# $sp = $sp + -36
	sw		$s0, 0($sp)		# p
	sw		$s1, 4($sp)		# q
	sw		$s2, 8($sp)		# r
	sw		$s3, 12($sp)		# N.p
	sw		$s4, 16($sp)		# N.q
	sw		$s5, 20($sp)		# base address of terms[]
	sw		$s6, 24($sp)		# pointer for terms[]
	sw		$s7, 28($sp)		# No. of terms in terms[]
	sw		$ra, 32($sp)		# save return address

	# save arguments
	move 	$s0, $a0		# $s0 = $a0 (save p)
	move 	$s1, $a1		# $s1 = $a1 (save q)
	move 	$s2, $a2		# $s2 = $a2 (save r)

	# allocate space on the heap for base address of terms[]
	li		$a0, 0xFFFF
	li		$v0, 9		# $v0 = 9
	syscall
	move 	$s5, $v0		# $s5 = $v0 (save base address of terms[])
	move 	$s6, $s5		# $s7 = $s5 (copy base address of terms[] for pointer)
	# intitalize terms[] to [0, -1]
	sw		$0, 0($s5)
	li		$t0, -1		# $t0 = -1
	sw		$t0, 4($s5)

	# start off at first term in p 
	li		$s3, 1		# $s3 = 1 (int N.p = 0)

	# check to see if p is empty
	move 	$a0, $s0		# $a0 = $s0 (pass p) 
	move 	$a1, $s3		# $a1 = $s3 (pass N.p)
	jal		get_Nth_term				# jump to get_Nth_term and save position to $ra
	beqz $v1, empty	# if p is empty then check to see if q is empty

	# check to see if q is empty
	move 	$a0, $s1		# $a0 = $s0 (pass q)
	move 	$a1, $s3		# $a1 = $s3 (pass N.p)
	jal		get_Nth_term				# jump to get_Nth_term and save position to $ra
	beqz $v1, while_p_not_null
	j		for_term_in_p				# else jump to for_term_in_p

	empty:
		# check to see if q is also empty
		move 	$a0, $s1		# $a0 = $s1 (pass q)
		move 	$a1, $s3		# $a1 = $s3 (pass N.p)
		jal		get_Nth_term			# jump to get_Nth_term and save position to $ra
		beqz $v1, mult_failure	# if q is also empty then mult_failure
		# else set r to be every term in q 
		while_q_not_null:
			move 	$a0, $s1		# $a0 = $s1 (pass q)
			move 	$a1, $s3		# $a1 = $s3 (pass N)
			jal		get_Nth_term				# jump to get_Nth_term and save position to $ra
			beqz $v1, add_terms		# if we've reached end of q then add terms to r 
			sw		$v1, 0($s6)		# add coeff to terms[]
			sw		$v0, 4($s6)		# add exp to terms[]
			# set end of terms[] to be [0,-1]
			li		$t0, -1		# $t0 = -1
			sw		$0, 8($s6)
			sw		$t0, 12($s6)
			addi	$s6, $s6, 8			# $s6 = $s6 + 8 (update terms[] pointer)
			addi	$s3, $s3, 1			# $s3 = $s3 + 1 (increment N)
			addi	$s7, $s7, 1			# $s7 = $s7 + 1 (increment no. of terms)
			j		while_q_not_null				# jump to while_q_not_null

	while_p_not_null:
		move 	$a0, $s0		# $a0 = $s0 (pass p)
		move 	$a1, $s3		# $a1 = $s3 (pass N)
		jal		get_Nth_term				# jump to get_Nth_term and save position to $ra
		beqz $v1, add_terms		# if we've reached the end of q then add terms to r
		sw		$v1, 0($s6)		# add coeff to terms[]
		sw		$v0, 4($s6)		# add exp to terms[]
		# set end of terms[] to be [0,-1]
		li		$t0, -1		# $t0 = -1
		sw		$0, 8($s6)
		sw		$t0, 12($s6)
		addi	$s6, $s6, 8			# $s6 = $s6 + 8 (update terms[] pointer)
		addi	$s3, $s3, 1			# $s3 = $s3 + 1 (increment N)
		addi	$s7, $s7, 1			# $s7 = $s7 + 1 (increment no. of terms)
		j		while_p_not_null				# jump to while_p_not_null
		
	for_term_in_p:
		# get term from p
		move 	$a0, $s0		# $a0 = $s0 (pass p) 
		move 	$a1, $s3		# $a1 = $s3 (pass N.p)
		jal		get_Nth_term				# jump to get_Nth_term and save position to $ra
		beqz $v1, add_terms		# check to see if we have reached the end of p
		
		# start off at first term in q
		li		$s4, 1		# $s4 = 1 (N.q = 1)
		for_term_in_q:
			# get term from q
			move 	$a0, $s1		# $a0 = $s1 (pass q)
			move 	$a1, $s4		# $a1 = $s3 (pass N.q)
			jal		get_Nth_term				# jump to get_Nth_term and save position to $ra
			beqz $v1, get_next_term_in_p		# check to see if we have reached the end of q
			move 	$t0, $v0		# $t0 = $v0 (save exp)
			move 	$t1, $v1		# $t1 = $v1 (save coeff)

			# create array to save coeff and exp
			li		$a0, 12		# $a0 = 12
			li		$v0, 9		# $v0 = 9
			syscall 
			sw		$s7, 0($v0)		# save no. of terms
			sw		$t0, 4($v0)		# save exp
			sw		$t1, 8($v0)		# save coeff
			move 	$s7, $v0		# $s7 = $v0 (save address of array)

			# get term from p
			move 	$a0, $s0		# $a0 = $s0 (pass p)
			move 	$a1, $s3		# $a1 = $s3 (pass N.p)
			jal		get_Nth_term				# jump to get_Nth_term and save position to $ra
			
			lw		$t0, 4($s7)		# load exp
			lw		$t1, 8($s7)		# load coeff
			lw		$s7, 0($s7)		# load no. of terms
			
			# add both exps to get new_exp
			add		$t0, $t0, $v0		# $t0 = $t0 + $v0 (new_exp = q.exp + p.exp)
			# new_coeff = p.coeff * q.coeff
			mult	$t1, $v1			# $t1 * $v1 = Hi and Lo registers (q.coeff * p.coeff)
			mflo	$t1					# copy Lo to $t1 ($t1 = new_coeff)

			move 	$t2, $s5		# $t2 = $s5 (copy base address of terms[])
			for_term_in_r:
				# search for newly created exp in terms[]
				lw		$t3, 4($t2)		# load exp from terms[]
				bltz $t3, add_new_term_to_terms		# if we have reached the end of terms[] then add new term to terms[]
				beq		$t0, $t3, update_coeff	# if $t0 == $t3 then update_coeff
				addi	$t2, $t2, 8			# $t2 = $t2 + 8 (increment terms[] pointer)
				j		for_term_in_r				# jump to for_term_in_r

			update_coeff:
				lw		$t3, 0($t2)		# load coeff from terms[]
				add		$t3, $t3, $t1		# $t3 = $t3 + $t1 (add both coeffs)
				sw		$t3, 0($t2)		# store updated coeff in terms[]
				addi	$s4, $s4, 1			# $s4 = $s4 + 1 (N.q++)
				j		for_term_in_q				# jump to for_term_in_q
				
			add_new_term_to_terms:
				sw		$t1, 0($s6)		# insert new coeff
				sw		$t0, 4($s6)		# insert new exp
				addi	$s7, $s7, 1			# $s7 = $s7 + 1 (increment No. of terms in terms[])
				
				# set [0, -1] as end of terms[]
				sw		$0, 8($s6)
				li		$t0, -1		# $t0 = -1	
				sw		$t0, 12($s6) 
				addi	$s6, $s6, 8			# $s6 = $s6 + 8 (update pointer for terms[])
				addi	$s4, $s4, 1			# $s4 = $s4 + 1 (N.q++)
				j		for_term_in_q				# jump to for_term_in_q
				
			get_next_term_in_p:
				addi	$s3, $s3, 1			# $s3 = $s3 + 1 (N.p++)
				j		for_term_in_p				# jump to for_term_in_p

	add_terms:
		# init r
		move 	$a0, $s2		# $a0 = $s2 (pass r)
		move 	$a1, $s5		# $a1 = $s5 (pass base addess of terms[]
		jal		init_polynomial				# jump to init_polynomial and save position to $ra
		bltz $v0, mult_failure		# if return value is less than 0 then return mult_failure
		addi	$s5, $s5, 8			# $s5 = $s5 + 8 (increment base address of terms[])
		addi	$s7, $s7, -1			# $s7 = $s7 + -1 (decrement No. of terms in terms[])

		# add terms in terms[] to r
		move 	$a0, $s2		# $a0 = $s2 (pass r)
		move 	$a1, $s5		# $a1 = $s5 (pass base address of terms[])
		move 	$a2, $s7		# $a2 = $s7 (pass No. of terms in terms[])
		jal		add_N_terms_to_polynomial				# jump to add_N_terms_to_polynomial and save position to $ra
		li		$v0, 1		# $v0 = 1 (multiplication was successful so return 1)
		j		return_mult_poly				# jump to return_mult_poly

	mult_failure:
		li		$v0, 0		# $v0 = 0
		
	return_mult_poly:
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