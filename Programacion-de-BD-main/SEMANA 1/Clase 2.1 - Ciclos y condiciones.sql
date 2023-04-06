-- Ingresar número para saber si es par
DECLARE
    x NUMBER := &Numero;
BEGIN
    IF REMAINDER(x,2)=0 THEN
        DBMS_OUTPUT.PUT_LINE('el número '|| x ||' es PAR');  
    ELSE
        DBMS_OUTPUT.PUT_LINE('el número '|| x ||' es IMPAR');
    END IF;
END;


DECLARE
    x NUMBER := &Numero;
    resto NUMBER;
BEGIN
    resto := MOD(x,2);
    IF resto = 0 THEN
        DBMS_OUTPUT.PUT_LINE('el número '|| x ||' es PAR');  
    ELSE
        DBMS_OUTPUT.PUT_LINE('el número '|| x ||' es IMPAR');
    END IF;
END;


-- Números del 1 al 10
BEGIN
    FOR i IN 1..10 LOOP
        DBMS_OUTPUT.PUT_LINE(i);
    END LOOP;
END;

DECLARE
    i NUMBER := 1;
BEGIN
    WHILE i<=10 LOOP
        DBMS_OUTPUT.PUT_LINE (i);
        i:= i+1;
    END LOOP;
END;

DECLARE
    i NUMBER :=1;
BEGIN
    LOOP
        EXIT WHEN i=11;
        DBMS_OUTPUT.PUT_LINE (i);
        i:=i+1;
    END LOOP;
END;

