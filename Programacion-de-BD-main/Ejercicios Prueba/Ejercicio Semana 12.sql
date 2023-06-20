CREATE OR REPLACE PROCEDURE sp_pagos(p_fecha DATE,p_nro_pagos OUT NUMBER,
p_total_pagos OUT NUMBER)IS    
    BEGIN
        SELECT
            COUNT(id_fpago),
            NVL(SUM(monto_cancelado_pgc),0)
        INTO
            p_nro_pagos,
            p_total_pagos
        FROM pago_gasto_comun
        WHERE fecha_cancelacion_pgc BETWEEN p_fecha AND p_fecha + 7;
    END;
    
CREATE OR REPLACE FUNCTION fn_direccion_edificio(p_edificio NUMBER) RETURN VARCHAR2
    IS
    direccion VARCHAR2(500);
    BEGIN
        SELECT
            e.direccion_edif ||', '||c.nombre_comuna
        INTO
            direccion
        FROM edificio e JOIN comuna c
        ON(e.id_comuna = c.id_comuna)
        WHERE e.id_edif = p_edificio;
        
        RETURN direccion;
    END;
    
CREATE OR REPLACE FUNCTION fn_promedio RETURN NUMBER
    IS
    promedio NUMBER;
    BEGIN
        SELECT
            NVL(AVG(metros_cuadrados_depto),0)
        INTO
            promedio
        FROM departamento;
        
        return promedio;
    END;

CREATE OR REPLACE PROCEDURE sp_inserta_deptos(p_tipo VARCHAR2, p_depto NUMBER,
p_edificio NUMBER, p_direccion VARCHAR2)IS
    msg_oracle error_proceso_multas.error_oracle%TYPE;
    BEGIN
        INSERT INTO informe_deptos VALUES(
            p_tipo,
            SYSDATE,
            p_depto,
            p_edificio,
            p_direccion
            );
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
        msg_oracle := SQLERRM;
        INSERT INTO error_proceso_multas VALUES(
        SEQ_ERROR_MULTAS.nextval, 'Informe '||p_tipo||' de '||p_depto||' de edificio'
        ||p_edificio ||' para el dia '|| SYSDATE ||' ya existe','sp_inserta_resumen',
        msg_oracle
        );
    END;

CREATE OR REPLACE PROCEDURE sp_inserta_resumenes(p_inicio DATE)
    IS
    x NUMBER;
    y NUMBER;
    msg_oracle error_proceso_multas.error_oracle%TYPE;
    BEGIN
        sp_pagos(p_inicio, x, y);
        INSERT INTO resumen_pagos_semana VALUES(
        p_inicio,
        p_inicio + 7,
        x,
        y
        );
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
        msg_oracle := SQLERRM;
        INSERT INTO error_proceso_multas VALUES(
        SEQ_ERROR_MULTAS.nextval, 'Registro para la semana '||p_inicio||' ya existe','sp_inserta_resumen',
        msg_oracle
        );
    END;
--Construir el sp de la generacion del informe
CREATE OR REPLACE PROCEDURE sp_informe_pagos(p_fecha_inf DATE)
    IS
    BEGIN
        sp_inserta_resumenes(p_fecha_inf);
    END;

CREATE OR REPLACE PROCEDURE sp_informe_deptos(p_porcentaje NUMBER)
    IS
        CURSOR c_deptos(p_limite NUMBER) IS
            SELECT
                id_edif,
                nro_depto
            FROM departamento
            WHERE metros_cuadrados_depto > p_limite;
    limite NUMBER;
    direccion VARCHAR2(500);
    BEGIN
        --calcular el limite
        limite := ROUND(fn_promedio()*p_porcentaje/100);
        --obtener direccion
        
        --procesar los departamentos
        FOR reg_depto IN c_deptos(limite)LOOP
            direccion := fn_direccion_edificio(reg_depto.id_edif);
            --insertar resultados
            sp_inserta_deptos('T'||p_porcentaje, reg_depto.nro_depto, reg_depto.id_edif, direccion);
        END LOOP;
    
    END;


BEGIN
    sp_informe_pagos('01-04-2021');
    sp_informe_deptos(75);
END;

