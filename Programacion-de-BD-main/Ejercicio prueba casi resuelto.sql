--Funcion almacenada que retorna el porcentaje de antiguedad
CREATE OR REPLACE FUNCTION fn_porcentaje(p_anio NUMBER) RETURN NUMBER
    IS
    --almacena porcentaje de antiguedad
        porcentaje NUMBER;
        msg_oracle error_calc.descrip_error%TYPE;
    BEGIN
    --obtener porcentaje de antiguedad de un año
        SELECT
            porc_antiguedad
        INTO
            porcentaje
        FROM porcentaje_antiguedad
        WHERE p_anio BETWEEN annos_antiguedad_inf AND annos_antiguedad_sup;
        
        RETURN porcentaje;
    EXCEPTION WHEN NO_DATA_FOUND OR TOO_MANY_ROWS THEN
        msg_oracle := SQLERRM;
        pkg_ventas.sp_errores('Error en la funcion fn_porcentaje
            al obtener porcentaje asociado a '||p_anio||' años de antiguedad',msg_oracle);
        RETURN 0;
            
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
        
    EXCEPTION WHEN NO_DATA_FOUND OR TOO_MANY_ROWS THEN
        msg_oracle := SQLERRM;
        pkg_ventas.sp_errores('Error en la funcion fn_porc_escolaridad
            al obtener porcentaje asociado al codigo  escolaridad '||cod_escolaridad ,msg_oracle);
        RETURN 0;
    END;



CREATE OR REPLACE PACKAGE pkg_ventas IS
    MONTO_VENTAS NUMBER;

    FUNCTION fn_monto_total(p_rut NUMBER, p_periodo VARCHAR2) RETURN NUMBER;
    PROCEDURE sp_errores(p_rutina VARCHAR2, p_mensaje VARCHAR2);
    END;
    
CREATE OR REPLACE PACKAGE BODY pkg_ventas IS

    FUNCTION fn_monto_total(p_rut NUMBER, p_periodo VARCHAR2)RETURN NUMBER
        IS
            total NUMBER;
        BEGIN
            SELECT
                NVL(SUM(monto_total_boleta),0)
            INTO
                total
            FROM boleta
            WHERE run_empleado = p_rut AND TO_CHAR(fecha,'MM-YYYY') = p_periodo;
            
            RETURN total;
        END;
        
    PROCEDURE sp_errores(p_rutina VARCHAR2, p_mensaje VARCHAR2)
        IS
        BEGIN
            INSERT INTO error_calc VALUES(SEQ_ERROR.nextval, p_rutina, p_mensaje);
        END;
    END;
    
    
CREATE OR REPLACE PROCEDURE sp_informe(p_periodo VARCHAR2, p_colacion NUMBER, p_movilizacion NUMBER)
    IS
    --almacena a los empleados
        CURSOR c_empleados IS
            SELECT
                run_empleado,
                nombre||' '||paterno||' '|| materno AS nombre_emp,
                sueldo_base,
                TRUNC(MONTHS_BETWEEN(SYSDATE, fecha_contrato)/12) AS antiguedad,
                cod_escolaridad
            FROM empleado;
    porc_a porcentaje_antiguedad.porc_antiguedad%TYPE;
    asig_ant NUMBER;
    porc_esc porcentaje_escolaridad.porc_escolaridad%TYPE;
    monto_esc NUMBER;
    BEGIN
    --procesa a los empleados
        FOR reg_empleados IN c_empleados LOOP
            --obtener el monto total de ventas
            pkg_ventas.MONTO_VENTAS := pkg_ventas.fn_monto_total(reg_empleados.run_empleado, p_periodo);
            --obtener el porcentaje de antiguedad
            porc_a := fn_porcentaje(reg_empleados.antiguedad);
            --calcular la asignacion por antiguedad
            asig_ant := ROUND(pkg_ventas.MONTO_VENTAS * porc_a/100);
            --obtener la asignacion por escolaridad
            porc_esc := fn_porc_escolaridad(reg_empleados.cod_escolaidad);
            --calcular el % de escolaridad
            monto_esc := ROUND(reg_empleados.sueldo_base*porc_esc/100);
            
            --monto de comision de ventas
            BEGIN
                SELECT
                    porc_comision
                FROM porcentaje_comision_ventas
                WHERE pkg_ventas.MONTO_VENTAS BETWEEN venta_inf AND venta_sup;
            EXCEPTION WHEN TOO_MANY_ROWS THEN
                INSERT INTO
                
            END;
        END LOOP;
        
    END;
    
    
    
    
    
    
    
    
    
    
