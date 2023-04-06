SET SERVEROUTPUT ON;

--EJERCICIO 1
DECLARE
    total_clientes NUMBER;
BEGIN
    --OBTENER TOTAL DE CLIENTES
    SELECT 
        COUNT(rutcliente)
    INTO total_clientes
    FROM CLIENTE;
    
    --IMPRIMIR
    DBMS_OUTPUT.PUT_LINE('Total de clientes: '||total_clientes);
END; -- FASILONGOOOO

--EJERCICIO 2
DECLARE
    p_minimo NUMBER;
    p_maximo NUMBER;
    
BEGIN
    SELECT 
        MIN(valorpeso),
        MAX(valorpeso)
    INTO p_minimo, p_maximo
    FROM producto;
    
    DBMS_OUTPUT.PUT_LINE('Valor mínimo: $'||p_minimo);
    DBMS_OUTPUT.PUT_LINE('Valor máximo: $'|| p_maximo);
    
END;


-- EJERCICIO 3
DECLARE
    nom_cl cliente.nombre%TYPE;
    dir_cl cliente.direccion%TYPE;

BEGIN
    SELECT
        nombre,
        direccion
    INTO nom_cl, dir_cl
    FROM cliente 
    WHERE rutcliente = '44567891-4';
    
    DBMS_OUTPUT.PUT_LINE('Cliente: '|| nom_cl ||', '|| dir_cl);
END;
