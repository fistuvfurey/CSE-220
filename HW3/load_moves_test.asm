.data
filename: .asciiz "moves01.txt"
.align 0
moves: .byte 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
.text
.globl main
main:
la $a0, moves
la $a1, filename
jal load_moves

# You must write your own code here to check the correctness of the function implementation.

la		$t0, moves		# load moves base address
li		$t1, 0		# $t1 = 0 (int i = 0)
print_moves:
    # print int from moves[]
    li		$v0, 1		# $v0 = 1
    lb		$a0, 0($t0)		# load int from moves[]
    syscall
    
    addi	$t0, $t0, 1			# $t0 = $t0 + 1 (increment base address of moves[]
    addi	$t1, $t1, 1			# $t1 = $t1 + 1 (i++)
    
    li		$t2, 5		# $t2 = 5
    beq		$t2, $t1, break_print_moves	# if $t2 == $t1 then break_print_moves
    j		print_moves				# jump to print_moves
    
break_print_moves:
    li $v0, 10
    syscall

.include "hw3.asm"
