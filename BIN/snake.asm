IDEAL
MODEL small
STACK 100h
DATASEG
max_x_value dw 320
max_y_value dw 200
game_over_message db "game over", 10, 13, '$'
red dw 4
blue dw 1
green dw 2
white dw 15
black dw 0
gameOver db 0
size_of_squaer dw 10
snake db 1072 dup (0)
direction db 1 dup (0,0)
change_direction db 0
change_direction_ascii db 0
apple db 1 dup (11,10)
;---------------------------
CODESEG

proc printPixel
    push bp
    mov bp, sp
    push ax
    push bx
    push cx
    push dx
    mov bh,0h
    mov cx, [bp + 8] ; x value
    dec cx
    mov dx, [bp + 6] ; y value
    dec dx
    mov al, [bp + 4] ; color
    mov ah,0ch
    int 10h
    pop dx
    pop cx
    pop bx
    pop ax
    pop bp
    ret 6
endp printPixel

proc printSquare
    push bp
    mov bp, sp
    push ax
    push bx
    push cx
    xor ax, ax
    xor bx, bx
    mov cx, [bp + 4]
    sub cx, 1
    mov bx, [bp + 8] ; y value if the max y value was 200 / size
    mov ax, [bp + 10] ; x value if the max x value was 320 / size
    mul [bp + 4]
    push ax
    mov ax, bx
    mul [bp + 4]
    mov bx, ax
    pop ax
    printLoop:
        push cx
        mov cx, [bp + 4]
        sub cx, 1
        printColumnLoop:
            push ax
            push bx
            push [bp + 6]
            call printPixel
            dec bx
        loop printColumnLoop
        pop cx
        add bx, [bp + 4]
        sub bx, 1
        dec ax     
    loop printLoop
    pop cx
    pop bx
    pop ax
    pop bp
    ret 8
endp printSquare

proc drowBorders
    push bp
    mov bp, sp
    push ax
    push bx
    push cx
    mov ax, [max_x_value]
    div [size_of_squaer]
    xor cx, cx
    mov cl, al
    xor ax, ax
    mov ax, [max_y_value]
    div [size_of_squaer]
    mov bx, 1
    drow_x:
        push bx
        push 1
        push [bp + 4]
        push [size_of_squaer]
        call printSquare
        push bx
        push ax
        push [bp + 4]
        push [size_of_squaer]
        call printSquare
        inc bx
    loop drow_x
    mov ax, [max_y_value]
    div [size_of_squaer]
    xor cx, cx
    mov cl, al
    xor ax, ax
    mov ax, [max_x_value]
    div [size_of_squaer]
    mov bx, 1
    drow_y:
        push 1
        push bx
        push [bp + 4]
        push [size_of_squaer]
        call printSquare
        push ax
        push bx
        push [bp + 4]
        push [size_of_squaer]
        call printSquare
        inc bx
    loop drow_y
    pop cx
    pop bx
    pop ax
    pop bp
    ret 2
endp drowBorders

proc drowSnake
    push ax
    push bx
    xor ax, ax
    xor bx, bx
    mov bx, offset snake
    cmp [bx], 0
    je end_of_loop
    mov al, [bx]
    inc bx
    push ax
    mov al, [bx]
    push ax
    push [blue]
    push [size_of_squaer]
    call printSquare
    inc bx
    drow_loop:
        cmp [bx], 0
        je end_of_loop
        mov al, [bx]
        inc bx
        push ax
        mov al, [bx]
        push ax
        push [green]
        push [size_of_squaer]
        call printSquare
        inc bx
        jmp drow_loop
    end_of_loop:
    pop bx
    pop ax
    ret
endp drowSnake

proc AdvanceSnake
    push ax
    push bx
    push cx
    xor bx, bx
    xor ax, ax
    cmp al, [direction]
    jne snake_does_move
    cmp al, [direction + 1]
    jne snake_does_move
    jmp end_of_proc_AdvanceSnake
    snake_does_move:
    mov bx, offset snake
    add_loop:
        cmp [bx], 0
        je end_of_add_loop
        inc bx
        jmp add_loop
    end_of_add_loop:
    cmp [bx - 1], -1
    je AdvanceLoop
    sub bx, 2
    mov al, [bx]
    push ax
    mov al, [bx + 1]
    push ax
    push [black]
    push [size_of_squaer]
    call printSquare
    AdvanceLoop:
        cmp bx, offset snake
        je end_of_AdvanceLoop
        mov al, [bx - 2]
        mov [bx], al
        mov al, [bx - 1]
        mov [bx + 1], al
        sub bx, 2
        jmp AdvanceLoop
    end_of_AdvanceLoop:
    mov al, [direction]
    add [snake], al
    mov al, [direction + 1]
    add [snake + 1], al
    end_of_proc_AdvanceSnake:
    pop cx
    pop bx
    pop ax
    ret
endp AdvanceSnake

proc isPointOnSnakeOrOnBordersToDl
    push bp
    mov bp, sp
    push ax
    push bx
    push cx
    mov bx, offset snake
    snake_loop:
        cmp [bx], 0
        je end_snake_loop
        mov al, [bp + 6]
        cmp [bx], al
        jne x_are_not_equals_snake
        mov al, [bp + 4]
        cmp [bx + 1], al
        je true
        x_are_not_equals_snake:
        add bx, 2
    jmp snake_loop
    end_snake_loop:
    cmp [bp + 6], 1
    je true
    cmp [bp + 4], 1
    je true
    mov ax, [max_x_value]
    div [size_of_squaer]
    cmp [bp + 6], al
    je true
    mov ax, [max_y_value]
    div [size_of_squaer]
    cmp [bp + 4], al
    je true
    jmp end_of_proc_isPointOnSnakeOrOnBordersToDl
    true:
        mov dl, 1
    end_of_proc_isPointOnSnakeOrOnBordersToDl:
    pop cx
    pop bx
    pop ax
    pop bp
    ret 4
endp isPointOnSnakeOrOnBordersToDl

proc generateAppleForASizeOfSquaer10
    push ax
    push bx
    push dx
    mov ax, 40h
    mov es, ax
    generateX:
        mov ax, [es:6ch]
        mov ah, [byte cs:bx]
        xor al, ah
        and al, 00001111b
        mov [apple], al
        mov ax, [es:6ch]
        mov ah, [byte cs:bx]
        xor al, ah
        and al, 00000111b
        add [apple], al
        mov ax, [es:6ch]
        mov ah, [byte cs:bx]
        xor al, ah
        and al, 00000011b
        mov ax, [es:6ch]
        mov ah, [byte cs:bx]
        xor al, ah
        and al, 00000011b
        add [apple], al
        inc bx
        cmp [apple], 28
        jg generateX
    add [apple], 2
    generateY:
        mov ax, [es:6ch]
        mov ah, [byte cs:bx]
        xor al, ah
        and al, 00001111b
        mov [apple + 1], al
        mov ax, [es:6ch]
        mov ah, [byte cs:bx]
        xor al, ah
        and al, 00000001b
        add [apple + 1], al
        inc bx
        cmp [apple + 1], 17
        jg generateY
    add [apple + 1], 2
    xor ax, ax
    mov al, [apple]
    push ax
    mov al, [apple + 1]
    push ax
    call isPointOnSnakeOrOnBordersToDl
    cmp dl, 1
    je generateX
    mov al, [apple]
    push ax
    mov al, [apple + 1]
    push ax
    push [red]
    push [size_of_squaer]
    call printSquare
    pop dx
    pop bx
    pop ax
    ret
endp generateAppleForASizeOfSquaer10

proc enlargeTheSnake
    push bx
    mov bx, offset snake
    get_to_the_end_of_the_snake_loop:
        cmp [bx], 0
        je end_of_get_to_the_end_of_the_snake_loop
        inc bx
        jmp get_to_the_end_of_the_snake_loop
    end_of_get_to_the_end_of_the_snake_loop:
    mov [bx], -1
    pop bx
    ret
endp enlargeTheSnake

start:
    mov ax, @data
    mov ds, ax
;---------------------------
    mov ax, 13h
    int 10h

    mov [snake], 16
    mov [snake + 1], 10
    mov [snake + 2], 17
    mov [snake + 3], 10
    mov [snake + 4], 18
    mov [snake + 5], 10
    mov [snake + 6], 19
    mov [snake + 7], 10
    mov [snake + 8], 20
    mov [snake + 9], 10
    call drowSnake

    push [white]
    call drowBorders   

    mov al, [apple]
    push ax
    mov al, [apple + 1]
    push ax
    push [red]
    push [size_of_squaer]
    call printSquare    

    mov ax, 40h
    mov es, ax

    gameLoop:
        mov cx, 2
        DelayLoop:
            mov ax, [es:6ch]
        Tick:
            cmp ax, [es:6ch]
            je Tick
            mov ah, 1
            int 16h
            jz didnt_got_data
            mov ah, 0
            int 16h
            mov [change_direction_ascii], al
            mov [change_direction], 1
            didnt_got_data:
        loop DelayLoop
        cmp [change_direction], 1
        jne didnt_change_direction
        mov [change_direction], 0
        cmp [change_direction_ascii], 'a'
        je leftArrow
        cmp [change_direction_ascii], 'd'
        je rightArrow
        cmp [change_direction_ascii], 'w'
        je upArrow
        cmp [change_direction_ascii], 's'
        je downArrow
        jmp didnt_change_direction

        leftArrow:
            cmp [direction], 0
            jne didnt_change_direction
            mov [direction], -1
            mov [direction + 1], 0
            jmp didnt_change_direction

        rightArrow:
            cmp [direction], 0
            jne didnt_change_direction
            cmp [direction + 1], 0
            je didnt_change_direction
            mov [direction], 1
            mov [direction + 1], 0
            jmp didnt_change_direction

        upArrow:
            cmp [direction + 1], 0
            jne didnt_change_direction
            mov [direction], 0
            mov [direction + 1], -1
            jmp didnt_change_direction
        
        downArrow:
            cmp [direction + 1], 0
            jne didnt_change_direction
            mov [direction], 0
            mov [direction + 1], 1
            jmp didnt_change_direction

        didnt_change_direction:
        cmp [direction], 0
        jne snake_did_move
        cmp [direction + 1], 0
        jne snake_did_move
        jmp end_of_game_loop
        snake_did_move:
        xor cx, cx
        mov cl, [snake]
        add cl, [direction]
        push cx
        mov cl, [snake + 1]
        add cl, [direction + 1]
        push cx
        call isPointOnSnakeOrOnBordersToDl
        cmp dl, 1
        je game_over
        mov cl, [apple]
        push cx
        mov cl, [apple + 1]
        push cx
        call isPointOnSnakeOrOnBordersToDl
        cmp dl, 1
        jne end_of_game_loop
        call enlargeTheSnake
        call generateAppleForASizeOfSquaer10
        end_of_game_loop:
        call AdvanceSnake
        call drowSnake
    jmp gameLoop 

    game_over:
    mov ah, 0
    mov al, 2
    int 10h

    mov ah, 9h
    mov dx, offset game_over_message
    int 21h
;---------------------------

exit:
    mov ax, 4c00h
    int 21h
END start
