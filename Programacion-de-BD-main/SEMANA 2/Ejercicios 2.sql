SET SERVEROUTPUT ON;
SET VERIFY OFF;
-- EJERCICIO 1
DECLARE
    numero NUMBER(1) := &digito;
    patente NUMBER;

BEGIN
    SELECT 
        COUNT(nro_patente)
    INTO patente
    FROM camion
    WHERE SUBSTR(nro_patente,-1) = numero;
    
    DBMS_OUTPUT.PUT_LINE('CANTIDAD DE CAMIONES CON PATENTE TERMINADA EN "' || NUMERO ||'": ' || patente);
END;


-- EJERCICIO 2
CREATE TABLE revisiontecnica(
    digito NUMBER PRIMARY KEY,
    total_camiones NUMBER NOT NULL
);

DECLARE
    total NUMBER;

BEGIN    
    FOR i IN 0..9 LOOP   
        SELECT 
            COUNT(nro_patente)
        INTO total
        FROM camion
        WHERE SUBSTR(nro_patente,-1) = i;
        
        INSERT INTO revisiontecnica VALUES (i,total);
    
    END LOOP;
END;


-- EJERCICIO 3
DECLARE
    ingresa_marca marca.nombre_marca%TYPE := '&marca_ingresada';
    marca_id marca.id_marca%TYPE;
    minimo NUMBER;
    total_camiones NUMBER;
    
BEGIN
    -- id de la marca
    SELECT
        id_marca
    INTO marca_id
    FROM marca
    WHERE UPPER(nombre_marca) = UPPER(ingresa_marca);
    
    -- año
    SELECT
        MIN(anio)
    INTO minimo
    FROM camion
    WHERE id_marca = marca_id;
    
    -- contar camiones
    SELECT
        COUNT(nro_patente)
    INTO total_camiones
    FROM camion
    WHERE anio = minimo AND id_marca = marca_id;

    DBMS_OUTPUT.PUT_LINE('Total de camiones mas antiguos de la marca '|| ingresa_marca ||' es '||  total_camiones ||' y son del año '|| minimo);

END;
