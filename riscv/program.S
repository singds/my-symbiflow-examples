
.section .text
loop:
	li x1, 0x20000000
	li x2, 1
	SW  x2, 0(x1)
	li x2, 0
	SW  x2, 0(x1)
	j loop
	