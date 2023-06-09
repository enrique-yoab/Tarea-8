section .data
msg1 db "Ingrese cuatro valores de 3 digitos, presionar Enter entre cada valor",0xA
len1 equ $-msg1
msg2 db "El resultado de la suma de los numero es: "
len2 equ $-msg2
salto db 0xA

section .bss
dato resb 4
buffer resb 10
aux resb 10

section .text
global _start

_start:
	mov eax,4 
	mov ebx,1
	mov ecx, msg1
	mov edx, len1
	int 0x80


	mov ecx, 3
lectura:
	push ecx
	call lee
	mov esi, dato
	call atoi
	pop ecx
	push eax
	loop lectura

	call suma
	add esp, 12
	jmp salir


lee:
	enter 0, 0
  num:
	mov eax, 3
	mov ebx, 0
	mov ecx, dato
	mov edx, 4
	int 0x80
	
	mov eax, [dato]
	
	leave
	ret

atoi:
    enter 0, 0
    xor eax, eax 
  .top:
    movzx ecx, byte [esi] ; obtener un caracter
    inc esi ; leer la siguiente dirección
    cmp ecx, '0' ; digito valido?
    jb .done
    cmp ecx, '9'
    ja .done
    sub ecx, '0' ; "convertir" caracter a numero
    imul eax, eax, 10 ; multiplicar el resultado obtenido por unidades correspondientes 
    add eax, ecx ; sumatoria 
    jmp .top ; until done
  .done:
    leave
    ret

suma:
  	enter 0, 0
  	mov eax, [ebp + 8]
  	mov ebx, [ebp + 12]
  	mov ecx, [ebp + 16]
  	add eax, ebx
  	add eax, ecx
  	leave
  	ret

convertir:
	enter 0, 0
	push eax        ;se mueve al stack el resultado de la suma de los 3 valores
	mov eax, 4      ;linea 84 a 88 son para imprimir en pantalla "El resultado es:"
	mov ebx, 1
	mov ecx, msg2
	mov edx, len2
	int 0x80
	pop eax         ;se regresa el resultado de la suma al registro eax, dejando normal el stack

	xor edx, edx    ;necesario para tenerlo en 0 el registro edx
	mov ecx, 10     ;se pone un 10 al registro eax, para ir dividiendolo e ir separando digito por digito
	mov ebx, buffer ;se mueve a ebx la direccion del buffer
	mov edi, ebx    ;se mueve a edi la direccion del buffer por medio de ebx

convert_loop:
 	xor edx, edx   ; establecer edx en 0 para la división
    div ecx        ; dividir eax por 10 y se guarda en edx, edx = eax / 10
    add edx, '0'   ; convertir el resto a su representación ASCII
    mov [edi], dl  ; guardar el carácter del registro mas pequeño de edx ASCII en el búfer 
    inc edi        ; incrementar el puntero del búfer
    cmp eax, 0     ; si eax es 0, hemos terminado
    jne convert_loop ;bucle para ir dividiendolo en 10 hasta llegar a 0
	leave          ;quitar el stack frame
	ret            ;regresa en donde fue llamada la funcion convertir

strlen:
 cmp byte [edi + eax], 0 ;se compara con un cero ya que al terminar la cadena habra un 0
 jz salida   ;cuando salte aqui es que ya leyo todo la cadena y para luego invertirla
 inc eax     ;incrementa eax ya que contara cuantos caracteres tiene
 mov ebx, eax ;movemos el valor del tamaño al registro ebx
 jmp strlen  ;se salta a strlen para que se haga un bucle

;es necesario invertir ya que la conversion del entero a ASCCI se muestra al reves,
;por lo que se debe invertir.
invertir:
 mov ecx, [edi + eax] ;movemos al registro ecx, la ultima letra de la cadena
 mov [esi], ecx  ;movemos a la variable aux, el valor de ecx
 shr ecx, 1          ;dezplazamos un byte a la derecha en el registro ecx
 cmp eax, 0          ;comparamos eax con 0 ya que es el tamaño de la cadena
 jz salida           ;si es igual a 0 es que ya recorrio toda la cadena y imprime la cadena inverida
 inc esi             ;incrementamos eax para movernos al otro lado del caracter
 dec eax             ;decrementamos una unidad ebx
 jmp invertir        ;salta a la etiqueta invertir para continuar con el sig caracter

salida:
 ret

imprime:
 mov eax, 4
 mov ebx, 1
 mov ecx, aux
 mov edx, ebp
 int 0x80

 mov eax, 4
 mov ebx, 1
 mov ecx, salto
 mov edx, 1
 int 0x80

 jmp salida

salir:
	call convertir
	mov ebx, buffer
	mov edi, ebx
	mov ebx, aux
	mov esi, ebx
	call strlen
	mov ebp, ebx
	dec eax
	call invertir
	call imprime

	mov eax, 1
	xor ebx, ebx
	int 0x80