SET SERVEROUTPUT ON;
DECLARE
    id_cliente NUMBER;-- ok
    run_cliente NUMBER;-- ok
    nom_cliente VARCHAR2(300);--oo
    desc_tipo_cliente VARCHAR2(200);
    total_creditos NUMBER;
    monto_pesos NUMBER;
    edad NUMBER;
    min_id_cl NUMBER;
    max_id_cl NUMBER;
BEGIN
    SELECT
        MIN(nro_cliente),
        MAX(nro_cliente)
    INTO min_id_cl, max_id_cl
    FROM cliente;
    FOR id_cl IN min_id_cl..max_id_cl LOOP
        SELECT
            c.numrun,
            c.pnombre,
            tc.nombre_tipo_cliente
        INTO
            run_cliente,
            nom_cliente,
            desc_tipo_cliente
        FROM cliente c
        JOIN tipo_cliente tc ON(c.cod_tipo_cliente = tc.cod_tipo_cliente)
        --JOIN credito_cliente cc ON(c.nro_cliente = cc.nro_cliente)
        WHERE nro_cliente = id_cl;
        SELECT
            TRUNC((TO_NUMBER(TO_CHAR(SYSDATE,'YYYYMMDD'))- TO_NUMBER(TO_CHAR(fecha_nacimiento,'YYYYMMDD')))/10000)
        INTO
            edad
        FROM
            cliente
        WHERE nro_cliente = id_cl;
    
    DBMS_OUTPUT.PUT_LINE(id_cliente || run_cliente ||
    nom_cliente ||
    desc_tipo_cliente ||
    total_creditos ||
    monto_pesos ||' '|| edad);
    END LOOP;
END;
