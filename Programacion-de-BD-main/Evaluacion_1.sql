DECLARE
    --rangos
    rango_minimo NUMBER;
    rango_maximo NUMBER;
    --Datos tabla
    desc_prod resumen_ventaboletas.descripcion_completa%TYPE;
    total_vendido NUMBER;
    proporcion_2 NUMBER;
    categoria VARCHAR2(20);
    --cantidad total de unidades
    total_unidades NUMBER;
    --limite
    limite NUMBER := '&limite';
    
BEGIN
    EXECUTE IMMEDIATE 'TRUNCATE TABLE resumen_ventaboletas';
    --Select para sacar rango minimo y maximo
    SELECT
        MIN(p.codproducto),
        MAX(p.codproducto)
    INTO
        rango_minimo,
        rango_maximo
    FROM producto p;
    
    --Select para el total de unidades de todas las boletas
    SELECT
        NVL(SUM(db.cantidad),0)
    INTO
        total_unidades
    FROM detalle_boleta db;
    --Ciclo for para recorrer la tabla productos
    
    FOR cod_prod IN rango_minimo..rango_maximo LOOP
    
    --Select para obtener descripcion del producto
    
        SELECT
            p.descripcion ||' '|| CASE
            WHEN p.codunidad = 'UN' THEN 'UNITARIO'
            END
        INTO
            desc_prod
        FROM producto p
        WHERE cod_prod = p.codproducto;
        
    --Select para obtener unidades vendidas del producto
    
        SELECT
            NVL(SUM(db.cantidad),0)
        INTO
          total_vendido
        FROM detalle_boleta db
        WHERE cod_prod = db.codproducto;
        
    --Calculo de proporcion
    proporcion_2:=ROUND(total_vendido/total_unidades,2);
    
    --calculo de categorias
    categoria:=CASE
    WHEN total_vendido = limite 
        THEN 'POPULAR'
    WHEN total_vendido < limite
        THEN 'SUB POPULAR'
    WHEN total_vendido > limite 
        THEN 'SUPER POPULAR'
    WHEN total_vendido = 0 
        THEN 'SIN VENTAS'
    END;

    
    INSERT INTO resumen_ventaboletas VALUES(
        cod_prod,
        desc_prod,
        total_vendido,
        proporcion_2,
        categoria
    );
    
    
    
    
    
    END LOOP;
END;