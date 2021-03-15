.data
Newline: .asciiz "\n"
WrongArgMsg: .asciiz "You must provide exactly one argument"
BadToken: .asciiz "Unrecognized Token"
ParseError: .asciiz "Ill Formed Expression"
ApplyOpError: .asciiz "Operator could not be applied"

val_stack : .word 0
op_stack : .word 0

.text
.globl main
main:
  # add code to test call and test apply_bop function
  addi	$a0, $0, 5			# $a0 = $0 + 1
  addi	$a1, $0, '/'			# $a1 = $0 + '+'
  addi	$a2, $0, 0			# $a2 = $0 + 2
  jal		apply_bop				# jump to apply_bop and save position to $ra
  add		$s0, $v0, $0		# $s0 = $v0 + $0 (save result into $s0)
  
  
  
  

end:
  # Terminates the program
  li $v0, 10
  syscall

.include "hw2-funcs.asm"
