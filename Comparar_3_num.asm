section .data
msg1 db "Ingrese 3 valores menores a 1000, presionar Enter entre cada valor ingresado",0xA
len1 equ $-msg1
msg2 db "El mayor es: "
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


	mov ecx, 3  ;valores a leer y guardar, ingresados por el usuario
lectura:
	push ecx     ;se mueve al stack ya que sera nuestro contador, para saber el numero de valores ingresados
	call lee     ;syscall para leer el teclado y guardar los valores 
	mov esi, dato ;se mueve al registro esi la direcion del dato
	call atoi     ;funcion que nos convierte el texto en numeros
	pop ecx       ;se regresa el valor del contador
	push eax      ;se mueven los valores ingreasados al stack
	loop lectura  ;se decrementa ecx y se compara con 0

	call comparar ;si ecx es 0 se hara la llamada a la funcion para comparar los valores. 
	add esp, 12   ;se adelantan la instruccion 3 posiciones para que el stack quede igual que al inicio
	jmp salir     ;se sale para poder imprimir el numero mayor


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

comparar:
  	enter 0, 0
  	mov eax, [ebp + 8]
  	mov ebx, [ebp + 12]
  	mov ecx, [ebp + 16]
  	cmp eax, ebx ;
    jl comp1     ;si eax es menor a ebx, entonces ebx es mayor
    jmp comp2    ;si eax es mayor a ebx, entonces ebx es menor
 comp1: 
  ;se compara ebx con ecx ya que eax es menor a ebx
  cmp ebx, ecx 
  jl comp3      ;si ebx es menor a ecx, ecx es el mayor 
  jmp comp4     ;si ecx es menor a ebx, ebx es el mayor
 comp2:
  ;se compara eax con ecx ya que ebx es menor a eax
  cmp eax, ecx 
  jl comp3     ;si eax es menor, ecx es el mayor
  jmp comp5    ;si ecx es menor, entonces eax es el mayor
 comp3:
  ;si llega aqui es que ecx es el mayor
  mov eax, ecx
  leave
  jmp salida
 comp4:
  ;si llega aqui es que ebx es el mayor
  mov eax, ebx
  leave
  jmp salida
 comp5:
  ;si llega aqui es que eax es el mayor
  mov eax, eax
  leave
  jmp salida

convertir:
	enter 0, 0
	push eax        ;se mueve al stack el valor de eax, en este caso es el numero mayor
	mov eax, 4      ;linea 108 a 112 son para imprimir en pantalla "El mayor es:"
	mov ebx, 1
	mov ecx, msg2
	mov edx, len2
	int 0x80
	pop eax         ;se regresa al registro eax el valor numero mayor guardado en el stack

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