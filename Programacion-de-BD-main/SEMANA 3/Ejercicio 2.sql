SET SERVEROUTPUT ON;

VARIABLE min_limite NUMBER;
EXEC :min_limite := 2;

VARIABLE max_limite NUMBER;
EXEC :max_limite := 6;

VARIABLE min_inv NUMBER;
EXEC :min_inv := 3;

VARIABLE max_inv NUMBER;
EXEC :max_inv := 5;


DECLARE
    periodo_consulta VARCHAR2(7) := '&periodo';
    min_clientes NUMBER;
    max_clientes NUMBER;
    
    nombre_completo VARCHAR2(203);
    edad NUMBER;
    cant_creditos NUMBER;
    cant_inversiones NUMBER;
    
    categoria_c VARCHAR2(1);
    categoria_i VARCHAR2(1);

BEGIN
    SELECT MIN(nro_cliente), MAX(nro_cliente)
    INTO min_clientes, max_clientes
    FROM cliente;
    
    FOR i IN min_clientes..max_clientes LOOP
        SELECT
            pnombre ||' '|| snombre ||' '|| appaterno ||' '|| apmaterno,
            TRUNC(MONTHS_BETWEEN(SYSDATE, fecha_nacimiento)/12)
        INTO nombre_completo, edad
        FROM cliente
        WHERE nro_cliente = i;
        
        SELECT 
            COUNT(nro_solic_credito)
        INTO cant_creditos
        FROM credito_cliente
        WHERE nro_cliente = i AND TO_CHAR(fecha_solic_cred, 'MM/YYYY') = periodo_consulta;
        
        categoria_c := CASE
            WHEN cant_creditos < :min_limite THEN 'A'
            WHEN cant_creditos BETWEEN :min_limite AND :max_limite THEN 'B'
            ELSE 'C'
        END;
        
        SELECT 
            COUNT(nro_solic_prod)
        INTO cant_inversiones
        FROM producto_inversion_cliente
        WHERE nro_cliente = i AND TO_CHAR(fecha_solic_prod, 'MM/YYYY') = periodo_consulta;
        
        categoria_i := CASE
            WHEN cant_inversiones < :min_inv THEN 'A'
            WHEN cant_inversiones BETWEEN :min_inv AND :max_inv THEN 'B'
            ELSE 'C'
        END;

        IF i=0 THEN
            DBMS_OUTPUT.PUT_LINE('NO EXISTEN CLIENTES EN EL PERIODO CONSULTADO');
        ELSE 
            DBMS_OUTPUT.PUT_LINE(nombre_completo ||' '|| edad ||' '|| cant_creditos ||' '|| categoria_c ||' '|| cant_inversiones ||' '|| categoria_i);
        END IF;
    
    END LOOP;
    
    
END;
