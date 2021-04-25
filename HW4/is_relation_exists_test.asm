# add test cases to data section
# Test your code with different Network layouts
# Don't assume that we will use the same layout in all our tests
.data
Name1: .asciiz "Cacophonix"
Name2: .asciiz "Getafix"
Name_prop: .asciiz "NAME"
Frnd_prop: .asciiz "FRIEND"

Network:
  .word 5   #total_nodes (bytes 0 - 3)
  .word 10  #total_edges (bytes 4- 7)
  .word 12  #size_of_node (bytes 8 - 11)
  .word 12  #size_of_edge (bytes 12 - 15)
  .word 0   #curr_num_of_nodes (bytes 16 - 19)
  .word 0   #curr_num_of_edges (bytes 20 - 23)
  .asciiz "NAME" # Name property (bytes 24 - 28)
  .asciiz "FRIEND" # FRIEND property (bytes 29 - 35)
   # nodes (bytes 36 - 95)	
  .byte 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0	
   # set of edges (bytes 96 - 215)
  .word 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0

.text:
main:
	# create person1
	la $a0, Network
	jal create_person
	move $s0, $v0 # save person1
	
	li $v0, 1
	move $a0, $s0
	syscall
	
	li $v0, 11
	li $a0, '\n'
	syscall
	
	# create person2
	la $a0, Network
	jal create_person
	move $s1, $v0 # save person2
	
	li $v0, 1
	move $a0, $s1
	syscall
	
	# add realation between person1 and person2
	la $a0, Network
	move $a1, $s0 # pass person1
	move $a2, $s1 # pass person2
	jal add_relation
	
	# add friendship property between person1 and person2
	la $a0, Network
	move $a1, $s0 # person1
	move $a2, $s1 # pass person2
	la $a3, Frnd_prop
	addi $sp, $sp, -4
	li $t0, 1
	sw $t0, 0($sp) 
	jal add_relation_property
	
	# call is_relation_exists 
	la $a0, Network
	move $a1, $s0 # pass person1
	move $a2, $s1 # pass person2
	jal is_relation_exists
	
	# terminate
	li $v0, 10
	syscall
	
.include "hw4.asm"
