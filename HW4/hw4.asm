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

is_person_exists:
	# $a0 = address of ntwrk
	# $a1 = address of person
	addi	$t0, $a0, 36			# $t0 = $a0 + 36 (get address of nodes[] field)
	# if person address is invalid
	blt		$a1, $t0, person_does_not_exist	# if $a1 < $t0 then person_does_not_exist
	# else
	lw		$t1, 8($a0)		# load size_of_node from ntwrk 
	lw		$t2, 16($a0)		# load curr_num_of_nodes

	mult	$t1, $t2			# $t1 * $t2 = Hi and Lo registers (size_of_node * curr_num_of_nodes)
	mflo	$t1					# copy Lo to $t1 ($t1 = size_of_node * curr_num_of_nodes)
	add		$t0, $t0, $t1		# $t0 = $t0 + $t1 ($t0 = ntwrk + 36 + size_of_node * curr_num_of_nodes)

	blt		$a1, $t0, person_exists	# if $a1 < $t0 then person_exists
	# else
	person_does_not_exist:
		li		$v0, 0		# $v0 = 0
		j		return_is_person_exists				# jump to return_is_person_exists
	
	person_exists:
		li		$v0, 1		# $v0 = 1

	return_is_person_exists:	
		jr $ra

is_person_name_exists:
	addi	$sp, $sp, -28		# $sp = $sp + -28
	sw		$s0, 0($sp)		# ntwrk
	sw		$s1, 4($sp)		# base address of name str
	sw		$s2, 8($sp)		# index
	sw		$s3, 12($sp)		# curr_num_of_nodes
	sw		$s4, 16($sp)		# size_of_node
	sw		$s5, 20($sp)		# int i (iteration)
	sw		$ra, 24($sp)		# save return address
	
	# save arguments 
	move 	$s0, $a0		# $s0 = $a0 (save ntwrk)
	move 	$s1, $a1		# $s1 = $a1 (save name)

	addi	$s2, $s0, 36			# $s2 = $s0 + 36 ($s2 = nodes[0])
	lw		$s3, 16($s0)		# load curr_num_of_nodes from ntwrk
	lw		$s4, 8($s0)		# load size_of_node from ntwrk
	li		$s5, 0		# $s5 = 0 (int i = 0)
	search_for_names:
		move 	$a0, $s2		# $a0 = $s2 (pass name from ntwrk)
		move 	$a1, $s1		# $a1 = $s1 (name we are looking for)
		jal		str_equals				# jump to str_equals and save position to $ra
		# if the strings are equal then name_exists
		li		$t0, 1		# $t0 = 1
		beq		$t0, $v0, name_exists	# if $t0 == $v0 then name_exists
		# else keep looking
		addi	$s5, $s5, 1			# $s5 = $s5 + 1 (i++)
		# if we've checked every person in the ntwrk and still haven't found the name then the name does not exist
		bge		$s5, $s3, name_does_not_exist	# if $s5 == $s3 then name_does_not_exist (if i == curr_num_of_nodes) 
		# else get and check next person's name
		add		$s2, $s2, $s4		# $s2 = $s2 + $s4 (get reference to next person) 
		j		search_for_names				# jump to search_for_names
		
	name_does_not_exist:
		li		$v0, 0		# $v0 = 0 
		j		return_is_person_name_exists				# jump to return_is_person_name_exists
		
	name_exists:
		li		$v0, 1		# $v0 = 1 (return 1 since name exists)
		move 	$v1, $s2		# $v1 = $s2 (return reference to person)
		
	return_is_person_name_exists:
		lw		$s0, 0($sp)	
		lw		$s1, 4($sp)
		lw		$s2, 8($sp)
		lw		$s3, 12($sp)
		lw		$s4, 16($sp)
		lw		$s5, 20($sp)
		lw		$ra, 24($sp)
		addi	$sp, $sp, 28			# $sp = $sp + 28
		jr $ra

add_person_property:
	addi	$sp, $sp, -20			# $sp = $sp + -20
	sw		$s0, 0($sp)		# ntwrk
	sw		$s1, 4($sp)		# person
	sw		$s2, 8($sp)		# prop_name
	sw		$s3, 12($sp)		# prop_val
	sw		$ra, 16($sp)		# save return address

	# save arguments
	move 	$s0, $a0		# $s0 = $a0	(save netwrk)
	move 	$s1, $a1		# $s1 = $a1 (save person)
	move 	$s2, $a2		# $s2 = $a2 (save prop_name)
	move 	$s3, $a3		# $s3 = $a3 (save prop_val)

	# VALIDATION...

	# check to see if prop_name == "NAME"
	addi	$t0, $s0, 24			# $t0 = $s0 + 24 (get base address of name property asciiz)
	move 	$a0, $t0		# $a0 = $t0 (pass base address of asciiz str name property)
	move 	$a1, $s2		# $a1 = $s2 (pass base address of prop_name)
	jal		str_equals				# jump to str_equals and save position to $ra
	beqz $v0, invalid_prop_name		# if prop_name != "NAME" then throw invalid_prop_name
	# else
	j		check_if_person_exists				# jump to check_if_person_exists
	
	invalid_prop_name:
		li		$v0, 0		# $v0 = 0 (return 0)
		j		return_add_person_property				# jump to return_add_person_property
		
	check_if_person_exists:
		move 	$a0, $s0		# $a0 = $s0 (pass ntwrk)
		move 	$a1, $s1		# $a1 = $s1 (pass person)
		jal		is_person_exists				# jump to is_person_exists and save position to $ra
		beqz $v0, person_dne		# if person does not exist then throw person_dne
		# else
	 	j		validate_prop_val				# jump to validate_prop_val
		
	person_dne:
		li		$v0, -1		# $v0 = -1 (return -1)
		j		return_add_person_property				# jump to return_add_person_property
		
	validate_prop_val:
		# get size of prop_val str
		move 	$a0, $s3		# $a0 = $s3 (pass prop_val)
		jal		str_len				# jump to str_len and save position to $ra
		# get size_of_node
		lw		$t0, 8($s0)		# load size_of_node from ntwrk
		bge		$v0, $t0, invalid_prop_val	# if $v0 >= $t0 then invalid_prop_val
		# else
		j		is_prop_val_unique				# jump to is_prop_val_unique
		
	invalid_prop_val:
		li		$v0, -2		# $v0 = -2 (return -2)
		j		return_add_person_property				# jump to return_add_person_property
		
	is_prop_val_unique:
		# check to see if the person's name already exists in the ntwrk
		move 	$a0, $s0		# $a0 = $s0 (pass ntwrk)
		move 	$a1, $s3		# $a1 = $s3 (pass prop_val)
		jal		is_person_name_exists				# jump to is_person_name_exists and save position to $ra
		li		$t0, 1		# $t0 = 1
		beq		$t0, $v0, name_not_unique	# if $t0 == $v0 then name_not_unique
		# else
		j		add_property				# jump to add_property	
		
	name_not_unique:
		li		$v0, -3		# $v0 = -3 (return -3) 
		j		return_add_person_property				# jump to return_add_person_property
		

	# ADD NAME TO PERSON...
	add_property:
		# call str_copy
		move 	$a0, $s3		# $a0 = $s3 (pass base address of prop_val str as src)
		move 	$a1, $s1		# $a1 = $s1 (pass person as dest)
		jal		str_cpy				# jump to str_cpy and save position to $ra
		li		$v0, 1		# $v0 = 1 (return 1)
		
	return_add_person_property:
		lw		$s0, 0($sp)
		lw		$s1, 4($sp)
		lw		$s2, 8($sp)
		lw		$s3, 12($sp)
		lw		$ra, 16($sp)
		addi	$sp, $sp, 20			# $sp = $sp + 20
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