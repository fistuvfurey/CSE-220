.data
pair: .word 1 3
terms: .word 3 3 2 2 0 -1
p: .word 0
N: .word 1

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
    li $a1, 1
    jal get_Nth_term

    li $v0, 10
    syscall

.include "hw5.asm"
