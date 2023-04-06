-- �Qu� tablas necesito?
-- PRODUCTO, PAIS
-- �Qu� campos de las tablas necesito?
-- PAIS -> codigo y nombre
-- PRODUCTO -> codigo producto, valor unitario, cod pais
-- �Necesito filtrar registros?
-- SI
-- �Necesito usar funciones SQL?
-- SI, COUNT
-- �Necesito usar sentencia DML?
-- SI, INSERT
-- �Necesito usar sentencia SELECT?
-- SI

VARIABLE quiere_informe VARCHAR2(2);
EXEC :quiere_informe := 'SI';

DECLARE
    -- Almacena los codigos minimo y maximo del pais
    cod_minimo NUMBER;
    cod_maximo NUMBER;
    -- Almacena el nombre del pais
    nom_pais pais.nompais%TYPE;
    -- Almacena el total de productos del pais
    total_productos NUMBER;
    -- Almacena el total general de productos
    total_general NUMBER;
    -- Almacena la proporcion
    proporcion informe_pais.proporcion_pais%TYPE;
    -- Almacena la categoria
    categoria informe_pais.categoria%TYPE;
    -- Almacena el ranfo minimo y maximo
    min_rango NUMBER;
    max_rango NUMBER;
    -- Amacena el ID de cada rango de precios
    rango NUMBER;
    -- Almacena el total de productos del rango
    total_rango NUMBER;
BEGIN
    -- Truncar la tabla de acuerdo con requerimiento
    EXECUTE IMMEDIATE 'TRUNCATE TABLE informe_pais';
    EXECUTE IMMEDIATE 'TRUNCATE TABLE informe_precios';
    -- Obtener el c�digo m�nimo y m�ximo del pais
    SELECT MIN(codpais), MAX(codpais)
    INTO cod_minimo, cod_maximo
    FROM pais;
    -- Obtiene el total de productos
    SELECT COUNT(codproducto)
    INTO total_general
    FROM producto;
    -- Procesar UNO a UNO cada pa�s
    FOR cod_pais IN cod_minimo .. cod_maximo LOOP
        -- Obtener el nombre del pa�s
        SELECT nompais
        INTO nom_pais
        FROM pais
        WHERE codpais = cod_pais;
        -- Obtener la cantidad de productos del pais
        SELECT COUNT(codproducto) 
        INTO total_productos
        FROM producto
        WHERE codpais = cod_pais;
        -- Obtener la proporcion del pais
        proporcion := ROUND(total_productos/total_general, 2);
        -- Obtener la categoria del pais
        categoria := CASE
            WHEN total_productos = 0 THEN '-'
            WHEN proporcion < 0.1 THEN 'C1'
            WHEN proporcion BETWEEN 0.1 AND 0.5 THEN 'C2'
            ELSE 'C3'
        END;
        -- Insertar los resultados en el informe
        INSERT INTO informe_pais
        VALUES(SEQ_INFORME.NEXTVAL, cod_pais, nom_pais, 
        total_productos, proporcion, categoria);
        
        -- verificamos si corresponde generar el INFORME 2
        IF :quiere_informe = 'SI' THEN
            SELECT MIN(idrango), MAX(idrango)
            INTO min_rango, max_rango
            FROM rango_precios;
            rango:= min_rango;
            WHILE rango <= max_rango LOOP
                -- Obtener el total de productos del pais en ese rango de precios
                SELECT COUNT(codproducto)
                INTO total_rango
                FROM producto a JOIN rango_precios b
                ON(vunitario BETWEEN valor_minimo AND valor_maximo)
                WHERE cod_pais = codpais AND idrango = rango;
                -- Inserta resultados
                INSERT INTO informe_precios
                VALUES(cod_pais, rango, total_rango);
                rango := rango + 1;
            END LOOP;
        END IF;
    END LOOP;
END;
