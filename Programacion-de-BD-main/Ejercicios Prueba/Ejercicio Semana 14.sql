CREATE OR REPLACE PROCEDURE sp_resumen(p_periodo VARCHAR2)
    IS
    CURSOR c_cliente(p_periodo_consulta VARCHAR2) IS
        SELECT 
            c.numrun run,
            COUNT(1) AS cantidad,
            NVL(SUM(monto_transaccion),0) AS monto_total
        FROM cliente c JOIN tarjeta_cliente tc
        ON(c.numrun = tc.numrun)
        JOIN transaccion_tarjeta_cliente ttc
        ON(tc.nro_tarjeta = ttc.nro_tarjeta)
        WHERE TO_CHAR(fecha_transaccion,'MM-YYYY')= p_periodo_consulta
        GROUP BY c.numrun;
    BEGIN
        FOR reg IN c_cliente(p_periodo)LOOP
        
            INSERT INTO resumen_cliente VALUES(
            reg.run,
            p_periodo,
            reg.cantidad,
            reg.monto_total);
        END LOOP;
    END;
    
CREATE OR REPLACE TRIGGER trg_resumen
    AFTER INSERT ON resumen_cliente
    DECLARE
        cat_cliente rango_montos.categoria%TYPE;
    BEGIN
    --Obtener calificacion
    SELECT calificacion
    INTO cat_cliente
    FROM rango_montos
    WHERE :NEW.monto_total_transaccion BETWEEN monto_minimo AND monto_maximo;
        UPDATE categoria_cliente
        SET calificacion = cat_cliente
        WHERE numrun = :NEW.run AND periodo = :NEW.periodo;
        
        IF SQL%ROWCOUNT = 0 THEN
            INSERT INTO categoria_cliente VALUES(
            :NEW.run,
            :NEW.periodo,
            cat_cliente
            );
        END IF;
    END;


EXEC sp_resumen('01-2023');
    
    
    
    
    
