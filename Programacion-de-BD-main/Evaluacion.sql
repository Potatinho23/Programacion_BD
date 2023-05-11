DECLARE
    --cursor principal que almacena los datos de los vendedores
    CURSOR c_vendedor IS
        SELECT
            rutvendedor AS rut,
            sueldo_base,
            TRUNC(MONTHS_BETWEEN(SYSDATE, fecha_contrato)/12)AS anio_antiguedad
        FROM vendedor
        ORDER BY rutvendedor;
    --cursor secundario que almacena los detalles de factura
    CURSOR c_factura(id_vendedor VARCHAR2,p_fecha VARCHAR2)IS
        SELECT
            numfactura,
            neto AS valor_neto
        FROM factura
        WHERE TO_CHAR(fecha,'MM-YYYY') = p_fecha 
        GROUP BY neto, numfactura;
    --Periodo de consulta
    periodo VARCHAR2(7):= '&fecha';
    --Variable que almacena el bono 
    bono_vendedor NUMBER;
    --Variable que almacena el total de las facturas
    total_facturas NUMBER;
    --Variable que almacena el rango del vendedor
    rango_vendedor VARCHAR2(1);
    --ERROR ORACLE
    msg_error VARCHAR2(200);
    --ERROR DE NEGOCIO
    error_negocio EXCEPTION;
    --Calculo del bono
    calculo_bono NUMBER;
    --VARRAY
    TYPE t_valor IS VARRAY(2)OF NUMBER;
    valor t_valor;
BEGIN
    EXECUTE IMMEDIATE 'TRUNCATE TABLE resumen_vendedor';
    EXECUTE IMMEDIATE 'TRUNCATE TABLE resumen_facturas';
    EXECUTE IMMEDIATE 'TRUNCATE TABLE error_proceso';
    valor := t_valor(5000, 100000);
    FOR reg_vendedor IN c_vendedor LOOP
        
        FOR reg_factura IN c_factura(reg_vendedor.rut, periodo)LOOP
        --select para sacar el total de facturas por periodo
            SELECT
                COUNT(numfactura)
            INTO
                total_facturas
            FROM factura
            WHERE reg_vendedor.rut = rutvendedor;
        
            BEGIN
                SELECT
                    porcentaje
                INTO
                    bono_vendedor
                FROM porcentaje_bono
                WHERE reg_factura.valor_neto BETWEEN inferior AND superior;
                EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    bono_vendedor := 0;
                    msg_error := SQLERRM;
                INSERT INTO error_proceso VALUES(
                SEQ_ERROR.nextval,msg_error);
                    
            END;
            
            BEGIN
                SELECT
                    rango
                INTO
                    rango_vendedor
                FROM rango_vendedor
                WHERE reg_vendedor.anio_antiguedad BETWEEN anios_inf AND anios_sup;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                    rango_vendedor := NULL;
                    msg_error := SQLERRM;
                INSERT INTO error_proceso VALUES(
                SEQ_ERROR.nextval,msg_error);
                    rango_vendedor := '-';
            END;
            calculo_bono := reg_vendedor.sueldo_base * bono_vendedor + valor(1);
            BEGIN
                IF calculo_bono > valor(2) THEN
                    RAISE error_negocio;
                END IF;
                EXCEPTION
                WHEN error_negocio THEN
                    INSERT INTO error_proceso VALUES(
                    SEQ_ERROR.nextval,'Bono excede el limite permitido');
                    calculo_bono := valor(2);
            END;
            INSERT INTO resumen_facturas VALUES(
            reg_vendedor.rut,
            reg_factura.numfactura,
            reg_factura.valor_neto,
            calculo_bono
            );
        END LOOP;
        INSERT INTO resumen_vendedor VALUES(
            reg_vendedor.rut,
            periodo,
            total_facturas,
            rango_vendedor
            );
    END LOOP;
END;
