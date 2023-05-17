-- Construir la funcion almacenada
CREATE OR REPLACE FUNCTION fn_total_edificios RETURN NUMBER IS
    total NUMBER;
BEGIN
    SELECT
        COUNT(id_edif)
    INTO total
    FROM
        edificio;

    RETURN total;
END;

-- Probar la función

SET SERVEROUTPUT ON;

DECLARE
    t NUMBER;
BEGIN
    t := fn_total_edificios();
    dbms_output.put_line('Total de edificios ' || t);
END;

CREATE OR REPLACE PROCEDURE sp_total_ed_adm (
    p_rut NUMBER,
    p_total OUT NUMBER
)IS
BEGIN
    SELECT
        COUNT(id_edif)
    INTO p_total
    FROM
        edificio
    WHERE
        numrun_adm = p_rut;

END;

-- Llamada al SP

DECLARE
    total_de_edificios NUMBER;
BEGIN
    sp_total_ed_adm(15018444, total_de_edificios);
    dbms_output.put_line(total_de_edificios);
END;


CREATE OR REPLACE PROCEDURE sp_informe
IS
    CURSOR c_administradores IS
        SELECT
            numrun_adm,
            appaterno_adm||' '||apmaterno_adm||' '||pnombre_adm AS nombre
        FROM administrador;
    --almacena el total general de edificios 
    total_general NUMBER;
    --Almacena el total de edificios del administrador
    total_e_adm NUMBER;
    porcentaje NUMBER;
BEGIN
    FOR reg_adm IN c_administradores LOOP
    --calcular el % de edificios del administrador
    total_general := fn_total_edificios();
    --obtener el total del administrador
    sp_total_ed_adm(reg_adm.numrun_adm, total_e_adm);
    
    porcentaje := ROUND(total_e_adm / total_general*100);
        DBMS_OUTPUT.PUT_LINE (reg_adm.nombre ||' administra el '||porcentaje||'% de los edificios equivalente a '||total_e_adm||' edificio(s)');
    END LOOP;
END;
SET SERVEROUTPUT ON;
--llamar al procedimiento
BEGIN
    sp_informe;
END;
        
        
        
        
        