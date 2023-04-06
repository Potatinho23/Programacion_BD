SET SERVEROUTPUT ON;

DECLARE
    total NUMBER;
BEGIN
    SELECT 
        COUNT(nro_propiedad)
    INTO total
    FROM propiedad;
    
    DBMS_OUTPUT.PUT_LINE('TOTAL DE PROPIEDADES: ' || total);

END;

DECLARE
    total NUMBER;
    tipo tipo_propiedad.desc_tipo_propiedad%TYPE := '&tipo_propiedad';
BEGIN
    SELECT 
        COUNT(a.nro_propiedad)
    INTO total
    FROM propiedad a 
    JOIN tipo_propiedad b ON (a.id_tipo_propiedad = b.id_tipo_propiedad)
    WHERE UPPER(desc_tipo_propiedad) = UPPER(tipo);
    
    DBMS_OUTPUT.PUT_LINE('TOTAL DE PROPIEDADES DE TIPO "'|| UPPER(tipo) ||'": ' || total);

END;


DECLARE
    n_comuna comuna.nombre_comuna%TYPE := '&comuna';
    pg_comunes NUMBER;
    
BEGIN
    SELECT
        NVL(AVG(valor_gasto_comun),0)
    INTO pg_comunes
    FROM propiedad a
    JOIN comuna b ON (a.id_comuna = b.id_comuna)
    WHERE UPPER(b.nombre_comuna) = UPPER(n_comuna);
    
    IF pg_comunes = 0 THEN
        DBMS_OUTPUT.PUT_LINE('IMPROMEDIABLE VROU');
    ELSE
        DBMS_OUTPUT.PUT_LINE('PROMEDIO DE GASTOS COMUNES DE LA COMUNA "'|| UPPER(n_comuna) ||'": ' || TO_CHAR(pg_comunes, '$999g999g999'));
    END IF;
END;


DECLARE
    rut_propietario propiedad.numrut_prop%TYPE := &rut_consulta;
    valor_gc NUMBER;
    
BEGIN
    SELECT
        NVL(SUM(valor_gasto_comun),0)
    INTO valor_gc
    FROM propiedad
    WHERE numrut_prop = rut_propietario;
    
    IF valor_gc = 0 THEN
        DBMS_OUTPUT.PUT_LINE('NO HAY GASTOS COMUNES');
    ELSE
        DBMS_OUTPUT.PUT_LINE('TOTAL DE GASTOS COMUNES DEL RUT "'|| rut_propietario ||'": ' || TO_CHAR(valor_gc, '$999g999'));
    END IF;
        
END;
--12064147
