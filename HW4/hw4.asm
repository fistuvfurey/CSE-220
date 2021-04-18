############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
.text:

str_len:
	# $a0 = base address of str
	li		$v0, 0		# $v0 = 0 (length)
	iterate_str:
		lb		$t0, 0($a0)		# load char from string
		bnez $t0, is_char # if char isn't null then increment length
		# else we have reached the null-terminator for str so break
		j		return_str_length				# jump to return_str_length
		
		is_char:
			addi	$v0, $v0, 1			# $v0 = $v0 + 1 (length++)
			addi	$a0, $a0, 1			# $a0 = $a0 + 1 (increment str address)
			j		iterate_str				# jump to iterate_str
			
	return_str_length:
		jr $ra

str_equals:
	# $a0 = the base address of str1
	# $a1 = the base address of str2
	iterate_both_strs:
		lb		$t0, 0($a0)		# load char from str1
		lb		$t1, 0($a1)		# load char from str2
		bne		$t0, $t1, strs_not_equal	# if $t0 != $t1 then strs_not_equal
		# else chars are equal

		beqz $t0, strs_are_equal # if we've reached a null-terminator then strings are equal and break
		# else we are not at the end of the string yet so we need to iterate again
		addi	$a0, $a0, 1			# $a0 = $a0 + 1 (increment address of str1)
		addi	$a1, $a1, 1			# $a1 = $a1 + 1 (increment address of str2)
		j		iterate_both_strs				# jump to iterate_both_strs
	# *** end of loop ***

	strs_are_equal:
		li		$v0, 1		# $v0 = 1 (return 1)
		j		return_str_equals				# jump to return_str_equals

	strs_not_equal:
		li		$v0, 0		# $v0 = 0 (return 0)
		
	return_str_equals:
		jr $ra

str_cpy:
	# $a0 = src str address
	# $a1 = dest str address
	li		$v0, 0		# $v0 = 0 (# of chars copied)
	str_copy_loop:
		lb		$t0, 0($a0)		# load char from src str
		bnez $t0, copy_char_to_dest
		# else we have reached the null-terminator for the src string
		li		$t0, 0		# $t0 = 0
		sb		$t0, 0($a1)		# insert null-terminator at dest
		j		return_str_copy				# jump to return_str_copy
	
		copy_char_to_dest:
			sb		$t0, 0($a1)		# store char in dest
			addi	$a0, $a0, 1			# $a0 = $a0 + 1 (increment address of src str)
			addi	$a1, $a1, 1			# $a1 = $a1 + 1 (increment address of dest str)
			addi	$v0, $v0, 1			# $v0 = $v0 + 1 (increment # of chars from src str)
			j		str_copy_loop				# jump to str_copy_loop

	return_str_copy:
		jr $ra

create_person:
	# $a0 = base address of ntwrk struct
	lw		$t0, 0($a0)		# load total_nodes from ntwrk
	lw		$t1, 16($a0)		# load curr_num_of_nodes from ntwrk
	beq		$t0, $t1, reached_max_nodes	# if $t0 == $t1 then reached_max_nodes
	# else there is room for another node

	# address of new node = ntwrk + 12 * curr_num_of_nodes + 36 
	lw		$t0, 8($a0)		# load size_of_node from ntwrk 
	mult	$t0, $t1			# $t0 * $t1 = Hi and Lo registers (size of node * curr_num_of_nodes)
	mflo	$t0					# copy Lo to $t0 ($t0 = offset of first free index for new node)
	addi	$v0, $a0, 36			# $v0 = $a0 + 36 ($v0 = base address of ntwrk struct + offset for nodes[] field)
	add		$v0, $v0, $t0		# $v0 = $v0 + $t0 (address of new node)
	
	addi	$t1, $t1, 1			# $t1 = $t1 + 1 (increment curr_num_of_nodes)
	sw		$t1, 16($a0)		# update curr_num_of_nodes in ntwrk
	j		return_create_person				# jump to return_create_person

	reached_max_nodes:
		li		$v0, -1		# $v0 = -1 (return -1)
		j		return_create_person				# jump to return_create_person
	
	return_create_person:
		jr $ra
		yeah 
is_person_exists:
	# $a0 = address of ntwrk
	# $a1 = address of person
	addi	$t0, $a0, 36			# $t0 = $a0 + 36 (get address of nodes[] field)
	lw		$t1, 8($a0)		# load size_of_node from ntwrk 
	lw		$t2, 16($a0)		# load curr_num_of_nodes

	mult	$t1, $t2			# $t1 * $t2 = Hi and Lo registers (size_of_node * curr_num_of_nodes)
	mflo	$t1					# copy Lo to $t1 ($t1 = size_of_node * curr_num_of_nodes)
	add		$t0, $t0, $t1		# $t0 = $t0 + $t1 ($t0 = ntwrk + 36 + size_of_node * curr_num_of_nodes)

	blt		$a1, $t0, person_exists	# if $a1 < $t0 then person_exists
	# else person does not exist
	li		$v0, 0		# $v0 = 0
	j		return_is_person_exists				# jump to return_is_person_exists
	
	person_exists:
		li		$v0, 1		# $v0 = 1

	return_is_person_exists:	
		jr $ra
is_person_name_exists:
	jr $ra
add_person_property:
	jr $ra
get_person:
	jr $ra
is_relation_exists:
	jr $ra
add_relation:
	jr $ra
add_relation_property:
	jr $ra
is_friend_of_friend:
	jr $ra