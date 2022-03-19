# / - - - / Triqui hecho por Michael Gonzales, Jose Manuel Rodríguez y Santiago Castro / - - - / #

.data
	borde: .asciiz "  +---+---+---+\n"
	fila:  .asciiz  " |   |   |   |\n"
	cols:  .asciiz "    0   1   2  \n"
.text
	main: #Funcion principal
		addi $t0, $zero, 0
		while:
			bge $t0, 1, exit
			addi $t0, $t0, 1
			jal imprimirMatriz #Llamada a la funcion imprimirMatriz
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