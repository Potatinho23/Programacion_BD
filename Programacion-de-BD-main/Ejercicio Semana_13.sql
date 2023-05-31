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
    --procedimiento privado
    PROCEDURE sp_inserta(p_rut NUMBER, p_cantidad NUMBER, p_costo NUMBER, 
    p_promedio NUMBER, p_proporcion NUMBER) IS
    msg_oracle errores_proceso.descripcion_error%TYPE;
        BEGIN
            --insertar resumen medico
            INSERT INTO resumen_medico VALUES(
            pkg_medicos.PERIODO,
            p_rut,
            p_cantidad,
            p_costo,
            p_promedio,
            p_proporcion);
        EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
            msg_oracle := SQLERRM;
            INSERT INTO errores_proceso VALUES(
            SEQ_ERROR.nextval, 'sp_insertar_registro',msg_oracle);
        END;
    PROCEDURE sp_informe IS
        CURSOR c_medicos(p_limite NUMBER)IS
            SELECT
                med_run AS run
            FROM medico
            WHERE TRUNC(MONTHS_BETWEEN(SYSDATE, fecha_contrato)/12) > p_limite;
    --almacena el monto total de las atenciones
    monto NUMBER;
    cantidad_atenciones NUMBER;
    promedio_atenciones NUMBER;
    total_periodo NUMBER;
    proporcion_resumen_medicos NUMBER;
    BEGIN
    --obtener el total de monto de atenciones
        SELECT
            NVL(SUM(costo),0)
        INTO 
            total_periodo
        FROM atencion
        WHERE TO_CHAR(fecha_atencion,'MM-YYYY') = pkg_medicos.PERIODO;
        --recorrer el cursor
        FOR reg_medico IN c_medicos(pkg_medicos.LIMITE_ANTIGUEDAD) LOOP
            --obtiene el costo total de atenciones del medico
            monto := fn_monto_total_atencion(reg_medico.run, pkg_medicos.PERIODO);
            
            cantidad_atenciones := pkg_medicos.fn_cantidad_atencion(reg_medico.run);
            IF cantidad_atenciones > 0 THEN
                promedio_atenciones := ROUND(monto/cantidad_atenciones);
            ELSE
                promedio_atenciones := 0;
            END IF;
            IF total_periodo > 0 THEN
                proporcion_resumen_medicos := ROUND(monto/total_periodo,2);
            ELSE
                proporcion_resumen_medicos := 0;
            END IF;
            sp_inserta(reg_medico.run, cantidad_atenciones, monto, promedio_atenciones,
            proporcion_resumen_medicos);
            
        END LOOP;
    END;
END;

BEGIN
    pkg_medicos.PERIODO := '01-2021';
    pkg_medicos.LIMITE_ANTIGUEDAD := 15;
    pkg_medicos.sp_informe;
END;




