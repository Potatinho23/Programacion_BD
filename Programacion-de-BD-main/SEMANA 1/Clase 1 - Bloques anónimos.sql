-- OLA MUNDO00O0Ooo0O0O0O
SET SERVEROUTPUT ON;
BEGIN
    DBMS_OUTPUT.PUT_LINE('OLA MUNDO00O0Ooo0O0O0O');
END;

-- CONSTRUIR BLOQUE PARA LEER NUMERO E IMPRIMIRLO EN PANTALLA


DECLARE
    numero NUMBER := &valor;
BEGIN
    DBMS_OUTPUT.PUT_LINE('el número ingresado es '|| numero);
END;


DECLARE
    x NUMBER := &Numero;
    doble NUMBER;
BEGIN
    doble := 2*x;
    DBMS_OUTPUT.PUT_LINE('el doble del número ingresado es '|| doble);
END;
