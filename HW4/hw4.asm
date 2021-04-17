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
	jr $ra
is_person_exists:
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