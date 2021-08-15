
.section .text

	li x1, 100000000
	li x2, 0
	li x3, 0
loop:
	addi x2, x2, 1
	bne x2, x1, loop

	not x3, x3
	li x4, 0x20000000
	SW x3, 0(x4)

	li x2, 0
	j loop
	