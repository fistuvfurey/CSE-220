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

	# allocate 4 bytes for base address of updated[]
	li		$a0, 4		# $a0 = 4 (allocate for 4 bytes)
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
	addi	$sp, $sp, -20			# $sp = $sp + -20
	sw		$s0, 0($sp)		# p
	sw		$s1, 4($sp)		# q
	sw		$s2, 8($sp)		# r
	sw		$s3, 12($sp)		# N
	sw		$ra, 16($sp)		# save return address 
	
	# save arguments
	move 	$s0, $a0		# $s0 = $a0 (save p)
	move 	$s1, $a1		# $s1 = $a1 (save q)
	move 	$s2, $a2		# $s2 = $a2 (save r)

	
	
	
	jr $ra
mult_poly:
	jr $ra
