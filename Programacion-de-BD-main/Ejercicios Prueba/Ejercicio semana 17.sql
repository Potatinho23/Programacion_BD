CREATE OR REPLACE PACKAGE pkg_boletas IS
    --Variables
    DIFERENCIA NUMBER;
    TOTAL_BOLETA NUMBER;
    --Procedimiento publico
    PROCEDURE sp_errores(p_le_programa VARCHAR2, p_le_descripcion_sql VARCHAR2, p_le_descripcion_real VARCHAR2);
    --Funcion publica 
    FUNCTION fn_total_boleta(p_id_boleta VARCHAR2)RETURN NUMBER;
    
END;

CREATE OR REPLACE PACKAGE BODY pkg_boletas IS
    --Cuerpo del procedimiento
    PROCEDURE sp_errores(p_le_programa VARCHAR2, p_le_descripcion_sql VARCHAR2, 
    p_le_descripcion_real VARCHAR2)
        IS
        BEGIN
            INSERT INTO log_errores VALUES(
            SQ_ERROR.nextval, p_le_programa, p_le_descripcion_sql, p_le_descripcion_real
            );
        END;
    
    FUNCTION fn_total_boleta(p_id_boleta VARCHAR2)RETURN NUMBER
        IS
        msg_oracle log_errores.le_descripcion_sql%TYPE;
        BEGIN
            SELECT
                SUM(vp_precio*bp_producto_cantidad)
            INTO
                pkg_boletas.TOTAL_BOLETA
            FROM boleta b JOIN boleta_producto bp
                ON(b.bol_numero = bp.bol_numero)
            JOIN vigencia_precio vp
                ON(bp.pro_codigo = vp.pro_codigo AND b.bol_fecha BETWEEN vp.vp_fecha_inicio_vigencia AND
                vp.vp_fecha_termino_vigencia)
            WHERE bol_numero = p_id_boleta;
            
            RETURN pkg_boletas.TOTAL_BOLETA;
            
        EXCEPTION WHEN NO_DATA_FOUND THEN
            msg_oracle := SQLERRM;
            sp_errores('fn_total_boleta', msg_oracle, ' error al calcular el total de la boleta');
        END;
END;


CREATE OR REPLACE FUNCTION fn_categoria(p_id_boleta VARCHAR2)RETURN VARCHAR2
    IS
    categoria categorizacion_diferencia.cd_categoria%TYPE;
    total_boleta NUMBER;
    BEGIN
    
    total_boleta := pkg_boletas.fn_total_boleta(p_id_boleta);
        SELECT
            cd_categoria
        INTO
            categoria
        FROM categorizacion_diferencia
        WHERE total_boleta BETWEEN cd_valor_minimo AND cd_valor_maximo;
        
        RETURN categoria;
        EXCEPTION WHEN TOO_MANY_ROWS OR NO_DATA_FOUND THEN
            msg_oracle := SQLERRM;
            pkg_boletas.sp_erorres('fn_categoria', msg_oracle, ' sin categoria');
        RETURN 'SIN CATEGORIA';
    END;
    
CREATE OR REPLACE PROCEDURE sp_informe
IS
    CURSOR c_boletas IS
        SELECT
            b.bol_numero,
            b.bol_fecha,
            b.bol_total,
            tip_nombre,
            ven_pnombre ||' '|| ven_apaterno||' '||ven_amaterno AS nombre_vendedor,
            c.cli_correo AS correo
        FROM boleta b JOIN vendedor v
        ON(b.ven_rut = v.ven_rut)
        JOIN tipo_venta tv
        ON(b.tip_id = tv.tip_id)
        JOIN cliente c
        ON(b.cli_rut = c.cli_rut)
        WHERE tip_id IN (2,3);
BEGIN
    FOR reg_boleta IN c_boletas LOOP
        
    END LOOP;
END;

