--funcion almacenada
CREATE OR REPLACE FUNCTION fn_total_clientes(p_region NUMBER)RETURN NUMBER
    IS
    --almacena el total de clientes
    total_cliente NUMBER;
    BEGIN
    --obtener el total de clientes de la region
        SELECT
            COUNT(numrun)
        INTO total_cliente
        FROM cliente
        WHERE cod_region = p_region;
        RETURN total_cliente;
    END;
    
--procedimiento almacenado
CREATE OR REPLACE PROCEDURE sp_resumen
    IS
        CURSOR c_region IS
            SELECT 
                r.cod_region id_region,
                r.nombre_region nombre
            FROM region r;
    total_clientes NUMBER;
    BEGIN
    --funcion
    EXECUTE IMMEDIATE 'TRUNCATE TABLE resumen_region';
    
        FOR reg_region IN c_region LOOP
        total_clientes := fn_total_clientes(reg_region.id_region);
            INSERT INTO resumen_region VALUES(
            reg_region.id_region,
            reg_region.nombre,
            total_clientes
            );
        END LOOP;
    END;

CREATE OR REPLACE TRIGGER trg_resumen_region
    AFTER INSERT OR UPDATE OF cod_region ON cliente
    FOR EACH ROW
    BEGIN
        UPDATE resumen_region
        SET total_clientes = total_clientes + 1
        WHERE id_region = :NEW.cod_region;
        
        --verificar si se trata de una actualizacion
        IF UPDATING THEN
            UPDATE resumen_region
            SET total_clientes = total_clientes -1
            WHERE id_region = :OLD.cod_region;
        END IF;
    END;
    
UPDATE cliente
SET cod_region = 9
WHERE numrun = 16000472;



EXEC sp_resumen;







