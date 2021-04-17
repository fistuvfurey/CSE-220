# add test cases to data section
.data
src: .asciiz ""
dest: .asciiz ""

.text:
main:
	la $a0, src
	la $a1, dest
	jal str_cpy
	#write test code
	la		$t0, dest		# load base address of dest str

	iterate_dest_str:
		lb		$a0, 0($t0)		# load char from dest str
		beqz $a0, break_iterate_dest_str # if we reached null-terminator for dest str then break 
		# else print char
		li		$v0, 11		# $v0 = 11
		syscall
		addi	$t0, $t0, 1			# $t0 = $t0 + 1 (increment addres of dest str)
		j		iterate_dest_str				# jump to iterate_dest_str
		
	break_iterate_dest_str:
		li $v0, 10
		syscall
	
.include "hw4.asm"
