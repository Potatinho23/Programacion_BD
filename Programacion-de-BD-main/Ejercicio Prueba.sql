--Funcion almacenada que retorna el porcentaje de antiguedad
CREATE OR REPLACE FUNCTION fn_porcentaje(p_anio NUMBER) RETURN NUMBER
    IS
    --almacena porcentaje de antiguedad
        porcentaje NUMBER;
    BEGIN
    --obtener porcentaje de antiguedad de un año
        SELECT
            porc_antiguedad
        INTO
            porcentaje
        FROM porcentaje_antiguedad
        WHERE p_anio BETWEEN annos_antiguedad_inf AND annos_antiguedad_sup;
        
        RETURN porcentaje;
    END;
--Funcion almacenada que retorna el porcentaje de escolaridad del empleado
CREATE OR REPLACE FUNCTION fn_porc_escolaridad(p_id_esc NUMBER) RETURN NUMBER
    IS
    --variable que almacena el porcentaje
        porcentaje_esc NUMBER;
    BEGIN
    --Obtener porcentaje de escolaridad del empleado
        SELECT
            porc_escolaridad
        INTO
            porcentaje_esc
        FROM porcentaje_escolaridad
        WHERE cod_escolaridad = p_id_esc;
    END;



CREATE OR REPLACE PACKAGE pkg_ventas IS
    PERIODO VARCHAR2(7);
    MONTO_VENTAS NUMBER;

    FUNCTION fn_monto_total(p_rut NUMBER) RETURN NUMBER;
    PROCEDURE sp_errores;
    END;
CREATE OR REPLACE PACKAGE BODY pkg_ventas IS

    FUNCTION fn_monto_total(p_rut NUMBER)RETURN NUMBER
        IS
        BEGIN
            SELECT
                NVL(SUM(monto_total_boleta))
            INTO
                pkg_ventas.MONTO_VENTAS
            FROM boleta
            WHERE run_empleado = p_rut AND TO_CHAR(fecha,'MM-YYYY') = pkg_ventas.PERIODO;
        END;
        
    PROCEDURE sp_errores()
        IS
        BEGIN
        
        END;
    END;
    
