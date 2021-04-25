# add test cases to data section
# Test your code with different Network layouts
# Don't assume that we will use the same layout in all our tests
.data
Name1: .asciiz "Cacophonix"
Name2: .asciiz "Getafix"
Name3: .asciiz "Aidan"
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
	move $s0, $v0 # save address of person1
	
	# create person2
	la $a0, Network
	jal create_person
	move $s1, $v0 # save address of person2
	
	# create person3
	la $a0, Network
	jal create_person
	move $s2, $v0 # save address of person3
	
	# name person1
	la $a0, Network
	move $a1, $s0 # pass person1
	la $a2, Name_prop
	la $a3, Name1
	jal add_person_property
	
	# name person2
	la $a0, Network
	move $a1, $s1 # pass person2
	la $a2, Name_prop
	la $a3, Name2
	jal add_person_property
	
	# name person3
	la $a0, Network
	move $a1, $s2 # pass person3
	la $a2, Name_prop
	la $a3, Name3
	jal add_person_property
	
	# add relation between person1 and person2
	la $a0, Network
	move $a1, $s0 # pass person1
	move $a2, $s1 # pass person2
	jal add_relation
	
	# make person1 and person2 friends
	la $a0, Network
	move $a1, $s0 # pass person1
	move $a2, $s1 # pass person2
	la $a3, Frnd_prop
	# pass friendship value 
	addi $sp, $sp, -4
	li $t0, 1
	sw $t0, 0($sp)
	jal add_relation_property
	
	# add relation between person2 and person3
	la $a0, Network
	move $a1, $s1 # pass person2
	move $a2, $s2 # pass person3
	jal add_relation
	
	# make person2 and person3 friends
	la $a0, Network
	move $a1, $s1 # pass person2
	move $a2, $s2 # pass person3
	la $a2, Frnd_prop
	# pass friendship value 
	addi $sp, $sp, -4
	li $t0, 1
	sw $t0, 0($sp)
	jal add_relation_property
	
	# check to see if person1 and person3 are friends of friends
	la $a0, Network
	la $a1, Name1
	la $a2, Name3
	jal is_friend_of_friend
	
	move $a0, $v0
	li $v0, 1
	syscall 
	
	# terminate
	li $v0, 10
	syscall
	
.include "hw4.asm"
