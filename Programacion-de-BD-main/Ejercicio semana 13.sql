CREATE OR REPLACE FUNCTION fn_monto_total_atencion(p_rut NUMBER, 
p_periodo VARCHAR2)RETURN NUMBER
    IS
    monto_total NUMBER;
    BEGIN
        --calcular el monto total de las atenciones del medico en el periodo
        SELECT
            NVL(SUM(costo),0)
        INTO
            monto_total
        FROM atencion
        WHERE med_run = p_rut AND TO_CHAR(fecha_atencion,'MM-YYYY') = p_periodo;
        RETURN monto_total;
    END;

CREATE OR REPLACE PACKAGE pkg_medicos IS
    --variables del package
    PERIODO VARCHAR2(7);
    LIMITE_ANTIGUEDAD NUMBER;
    
    FUNCTION fn_cantidad_atencion(p_rut NUMBER)RETURN NUMBER;
    PROCEDURE sp_informe;
END;
CREATE OR REPLACE PACKAGE BODY pkg_medicos IS
    FUNCTION fn_cantidad_atencion(p_rut NUMBER)RETURN NUMBER
    IS
    cantidad_atencion NUMBER;
    BEGIN
        SELECT  
            COUNT(ate_id)
        INTO
            cantidad_atencion
        FROM atencion
        WHERE med_run = p_rut AND TO_CHAR(fecha_atencion,'MM-YYYY') = pkg_medicos.PERIODO;
        RETURN cantidad_atencion;
    END;
    
    PROCEDURE sp_informe
END;






