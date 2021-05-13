.data
pair: .word 1 0
terms: .word 2 2 4 3 5 0 0 -1
p: .word 0
N: .word 10

.text:
main:
    la $a0, p
    la $a1, pair
    jal init_polynomial

    la $a0, p
    la $a1, terms
    lw $a2, N
    jal add_N_terms_to_polynomial

    #write test code
    la $a0, p
    li $a1, 3
    jal get_Nth_term
    move $t0, $v0
    
    move $a0, $v1
    li $v0, 1
    syscall
    
    move $a0, $t0
    syscall 
    

    li $v0, 10
    syscall

.include "hw5.asm"
