CREATE OR REPLACE FUNCTION fn_total_departamentos(id_edificio IN NUMBER) RETURN NUMBER 
    IS
    cantidad_departamentos NUMBER;
    BEGIN
        SELECT
            COUNT(nro_depto)
        INTO
            cantidad_departamentos
        FROM departamento
        WHERE id_edif = id_edificio;
        
        RETURN cantidad_departamentos;
    END;
--
DECLARE
    t NUMBER;
BEGIN
    t:=fn_total_departamentos();
    DBMS_OUTPUT.put_line('Total: ' ||t);
END;

CREATE OR REPLACE PROCEDURE sp_informe
IS
    CURSOR c_edificio IS
        SELECT
            e.id_edif AS id,
            e.nombre_edif AS nombre,
            c.nombre_comuna AS comuna
        FROM edificio e JOIN comuna c
        ON(e.id_comuna = c.id_comuna);
    --almacena el total de departamentos
    total_departamentos NUMBER;
    BEGIN
        FOR reg_edificio IN c_edificio LOOP
            total_departamentos := fn_total_departamentos(reg_edificio.id);
            DBMS_OUTPUT.put_line('El edificio ' ||reg_edificio.nombre||' ubicado en la comuna de '||
            reg_edificio.comuna||' posee '||total_departamentos || ' departamentos');
        END LOOP;
    END;
    
    
BEGIN
    sp_informe;
END;
    
    
    