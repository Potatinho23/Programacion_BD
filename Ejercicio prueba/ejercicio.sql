VARIABLE edad_min NUMBER
EXEC :edad_min := 40;

VARIABLE edad_max NUMBER
EXEC :edad_max := 60;

VARIABLE monto_1 NUMBER
EXEC :monto_1 := 1000;
VARIABLE monto_2 NUMBER
EXEC :monto_2 := 1500;
VARIABLE monto_3 NUMBER
EXEC :monto_3 := 1700;
DECLARE
    id_cliente NUMBER;
    run_cliente cliente_todosuma.run_cliente%TYPE;
    nom_cliente VARCHAR2(300);
    desc_tipo_cliente VARCHAR2(200);
    total_creditos NUMBER;
    monto_pesos NUMBER;
    
    edad NUMBER;
    porcentaje NUMBER;
    total_pesos NUMBER;
    puntos_asignados NUMBER;
    min_id_cl NUMBER;
    max_id_cl NUMBER;
    
    fecha_consulta VARCHAR2(7) := '&mes_y_año';
    
BEGIN
    EXECUTE IMMEDIATE 'TRUNCATE TABLE cliente_todosuma';
    SELECT
        MIN(nro_cliente),
        MAX(nro_cliente)
    INTO min_id_cl, max_id_cl
    FROM cliente;
    
    FOR id_cl IN min_id_cl..max_id_cl LOOP

        SELECT
            c.numrun ||'-'||c.dvrun,
            c.pnombre||' '||' '||c.appaterno||' '||c.apmaterno,
            tc.nombre_tipo_cliente,
            TRUNC((TO_NUMBER(TO_CHAR(SYSDATE,'YYYYMMDD'))- TO_NUMBER(TO_CHAR(c.fecha_nacimiento,'YYYYMMDD')))/10000)
        INTO
            run_cliente,
            nom_cliente,
            desc_tipo_cliente,
            edad
        FROM cliente c JOIN tipo_cliente tc
        ON(c.cod_tipo_cliente = tc.cod_tipo_cliente)
        WHERE c.nro_cliente = id_cl;
        
        --Total creditos
        
        SELECT
            NVL(SUM(monto_solicitado),0)
        INTO
            total_creditos
        FROM credito_cliente
        WHERE TO_CHAR(fecha_otorga_cred,'MM/YYYY') = fecha_consulta AND nro_cliente = id_cl;
        
        --Puntos asignados por edad
        
        puntos_asignados := CASE 
        WHEN
            edad < :edad_min THEN :monto_1
        WHEN
            edad BETWEEN :edad_min AND :edad_max THEN :monto_2
        ELSE :monto_3
        END;
       
        SELECT
            porc_puntos
        INTO porcentaje
        FROM
            rango_puntos
         WHERE total_creditos BETWEEN monto_minimo AND monto_maximo;
        
        total_pesos:= total_creditos*porcentaje + puntos_asignados + total_creditos;
        
        IF total_creditos > 0 THEN
            INSERT INTO cliente_todosuma VALUES(
            id_cl,
            run_cliente,
            nom_cliente,
            desc_tipo_cliente,
            total_creditos,
            total_pesos);
            END IF;
   
    END LOOP;
END;
