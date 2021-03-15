.data
Newline: .asciiz "\n"
WrongArgMsg: .asciiz "You must provide exactly one argument"
BadToken: .asciiz "Unrecognized Token"
ParseError: .asciiz "Ill Formed Expression"
ApplyOpError: .asciiz "Operator could not be applied"
Comma: .asciiz ","

val_stack : .word 0
op_stack : .word 0

.text
.globl main
main:
  # add code to call and test valid_op function
  addi	$a0, $0, 'h'			# $a0 = $0 + '+'
  jal		valid_ops				# jump to valid_ops and save position to $ra
  add		$s0, $0, $v0		# $s0 = $0 + $v0 (save return value into $s0)
  
  
  

end:
  # Terminates the program
  li $v0, 10
  syscall

.include "hw2-funcs.asm"
