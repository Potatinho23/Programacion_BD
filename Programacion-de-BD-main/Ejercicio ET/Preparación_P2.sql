CREATE OR REPLACE PACKAGE pkg_boleta IS
    --Almacena el total de la boleta
    TOTAL_BOLETA NUMBER;
    --Almacena la categoria
    DIFERENCIA NUMBER;

    PROCEDURE sp_errores(p_le_programa VARCHAR2, p_le_descripcion_sql VARCHAR2, p_le_descripcion_real VARCHAR2);

    FUNCTION fn_total_boleta(p_boleta VARCHAR2)RETURN NUMBER;
    
    
END;


CREATE OR REPLACE PACKAGE BODY pkg_boleta IS
    PROCEDURE sp_errores(p_le_programa VARCHAR2, p_le_descripcion_sql VARCHAR2, p_le_descripcion_real VARCHAR2)
        IS
        BEGIN
            INSERT INTO log_errores VALUES(
            SQ_ERROR.nextval,
            p_le_programa,
            p_le_descripcion_sql,
            p_le_descripcion_real);
        END;
    
    FUNCTION fn_total_boleta(p_boleta VARCHAR2)RETURN NUMBER
        IS
            msg_oracle log_errores.le_descripcion_sql%TYPE;
        BEGIN
            SELECT
                NVL(SUM(vp_precio * bp_producto_cantidad),0)
            INTO
                pkg_examen.TOTAL_BOLETA
            FROM boleta b JOIN boleta_producto bp ON(b.bol_numero = bp.bol_numero)
            JOIN vigencia_precio vp ON(bp.pro_codigo = vp.pro_codigo AND 
            b.bol_fecha BETWEEN vp.vp_fecha_inicio_vigencia AND vp.vp_fecha_termino_vigencia)
            
            WHERE b.bol_numero = p_boleta;
            
            RETURN TOTAL_BOLETA;
        EXCEPTION WHEN NO_DATA_FOUND THEN
            msg_oracle := SQLERRM;
            sp_errores('fn_total_boleta',msg_oracle,
            'Error al calcular el monto de la boleta');
            RETURN 0;
        END;
END;


CREATE OR REPLACE FUNCTION fn_categorizacion(p_diferencia NUMBER)RETURN VARCHAR2
    IS
        --almacena la categoria
        categoria categorizacion_diferencia.cd_categoria%TYPE;
        --almacena el error oracle
        msg_oracle log_errores.le_descripcion_sql%TYPE;
    BEGIN
        SELECT
            cd_categoria
        INTO
            categoria
        FROM categorizacion_diferencia
        WHERE p_diferencia BETWEEN cd_valor_minimo AND cd_valor_maximo;
        
        RETURN categoria;
    
    EXCEPTION WHEN NO_DATA_FOUND OR TOO_MANY_ROWS THEN
        msg_oracle :=SQLERRM;
        pkg_boleta.sp_errores('fn_categorizacion',msg_oracle,
            'Error al calcular la categoria');
        RETURN 'SIN CATEGORIA';
    END;
    
CREATE OR REPLACE PROCEDURE sp_informe IS
    CURSOR c_boletas IS
        SELECT bol_numero, bol_fecha, bol_total, tip_nombre,
        ven_pnombre || ' ' || ven_apaterno || ' ' || ven_amaterno AS nombre_vendedor, 
        cli_correo
        FROM boleta b JOIN vendedor v ON(b.ven_rut = v.ven_rut)
        JOIN tipo_venta tp ON(b.tip_id = tp.tip_id)
        JOIN cliente c ON(b.cli_rut = c.cli_rut)
        WHERE tp.tip_id IN (2,3);
    total_calculado NUMBER;
    categoria_a VARCHAR2(100);
    BEGIN
        FOR reg_boleta IN c_boletas LOOP
            
            total_calculado := pkg_boleta.fn_total_boleta(reg_boleta.bol_numero);
            
            
            pkg_boleta.DIFERENCIA := reg_boleta.bol_total - total_calculado;
            
            IF pkg_boleta.DIFERENCIA < 0 THEN
                pkg_boleta.DIFERENCIA := pkg_boleta.DIFERENCIA * -1;
            END IF;
            
            categoria_a := fn_categorizacion(pkg_boleta.DIFERENCIA);
            
            INSERT INTO resultado_boletas VALUES(
            SQ_RESULTADO.nextval,
            SYSDATE,
            reg_boleta.bol_numero,
            reg_boleta.bol_fecha,
            reg_boleta.bol_total,
            total_calculado,
            reg_boleta.tip_nombre,
            reg_boleta.nombre_vendedor,
            reg_boleta.cli_correo,
            pkg_boleta.DIFERENCIA,
            categoria_a
            );
        END LOOP;
    END;
    
CREATE OR REPLACE TRIGGER trg_log
AFTER INSERT ON resultado_boletas
FOR EACH ROW
DECLARE
BEGIN
    INSERT INTO log_boletas VALUES(
    sq_log.NEXTVAL, :NEW.ven_nombre,:NEW.bol_fecha ,:NEW.bol_numero, :NEW.bol_total, :NEW.diferencia_totales);
END;
/

EXEC sp_informe

    
    
