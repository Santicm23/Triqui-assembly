# / - - - / Triqui hecho por Michael Gonzales, Jose Manuel Rodr�guez y Santiago Castro / - - - / #

.data
	borde: .asciiz "  +---+---+---+\n"
	fila:  .asciiz  " |   |   |   |\n"
	cols:  .asciiz "    0   1   2  \n"
	
	menu: .asciiz "\n---Triqui---\n"
	op1: .asciiz "1.Jugar contra el computador\n"
	op2: .asciiz "2.Jugar en local\n"
	op3: .asciiz "3.Cerrar\n"
	opI: .asciiz "\nOpcion invalida\n"
	mOp: .asciiz "\nIngrese la opcion: "

.text
	main: #Funcion principal
		addi $t0, $zero, 0
		while:# Do while:
			#   Menu   :
			li $v0, 4
			la $a0, menu
			syscall
			la $a0, op1
			syscall
			la $a0, op2
			syscall
			la $a0, op3
			syscall
			la $a0, mOp
			syscall
			
			li $v0, 5
			syscall
			move $t0, $v0
			bne $t0, 1, else1
				jal imprimirMatriz #Llamada a la funcion imprimirMatriz
				j while
			else1:
			bne $t0, 2, else2
				j while
			else2:
			beq $t0, 3, exit
			
			#default
			la $a0, opI
			syscall
		j while
		exit:

	li $v0, 10
	syscall #Fin funcion principal

	imprimirMatriz: #funcion imprimirMatriz
		addi $t1, $zero, 0
		while1:
			bge $t1, 3, exit1
			li $v0, 4
			la $a0, borde
			syscall
			li $v0, 1
			addi $a0, $t1, 0
			syscall
			li $v0, 4
			la $a0, fila
			syscall
			addi $t1, $t1, 1
		j while1
		exit1:
		la $a0, borde
		syscall
		la $a0, cols
		syscall
	jr $ra #fin funcion imprimirMatriz
