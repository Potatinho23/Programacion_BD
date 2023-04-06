SET SERVEROUTPUT ON;


-- EJERCICIO 1

DECLARE
    comuna_cod NUMBER := &codigo_comuna;
    proporcion NUMBER(5,2) := &aumento;
    
BEGIN
    UPDATE cliente
    SET credito = credito + credito * proporcion
    WHERE codcomuna = comuna_cod;
    
    DBMS_OUTPUT.PUT_LINE('Cantidad de registros actualizados: ' || SQL%ROWCOUNT);
    
    DECLARE
        num_factura NUMBER := &numero_factura;
    BEGIN
        DELETE FROM detalle_factura 
        WHERE numfactura = num_factura;
        
        IF SQL%ROWCOUNT > 0 THEN
            DBMS_OUTPUT.PUT_LINE('Cantidad de registros eliminados: ' || SQL%ROWCOUNT);
        ELSE
            DBMS_OUTPUT.PUT_LINE('no se eliminaron registros');
        END IF;
    END;
END;


-- EJERCICIO 2 - LLENAR TABLA

CREATE TABLE resumenciudad
(
    cod_ciudad NUMBER PRIMARY KEY,
    total_comunas NUMBER NOT NULL
);

DECLARE
    ciudad_cod NUMBER := &cod_ciudad;
    total_comunas NUMBER;
    
BEGIN
    SELECT
        COUNT(codcomuna)
    INTO total_comunas
    FROM comuna
    WHERE codciudad = ciudad_cod;
    
    INSERT INTO resumenciudad VALUES (ciudad_cod, total_comunas);
    
END;
