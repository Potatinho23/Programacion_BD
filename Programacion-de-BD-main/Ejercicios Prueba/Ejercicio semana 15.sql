-- Encabezado del package
CREATE OR REPLACE PACKAGE pkg_ventas IS
	-- Variable
	MONTO_VENTAS NUMBER;
	-- Funciones/procedimientos publicos
	FUNCTION fn_monto_ventas(p_rut VARCHAR2, p_periodo VARCHAR)
    RETURN NUMBER;
    PROCEDURE sp_inserta_error(p_rutina VARCHAR2, p_mensaje VARCHAR);
END;

CREATE OR REPLACE PACKAGE BODY pkg_ventas IS
    FUNCTION fn_monto_ventas(p_rut VARCHAR2, p_periodo VARCHAR)
    RETURN NUMBER
    IS
        total NUMBER;
    BEGIN
        SELECT NVL(SUM(monto_total_boleta),0) INTO total
        FROM boleta
        WHERE run_empleado = p_rut AND TO_CHAR(fecha, 'MM-YYYY') = p_periodo;
        RETURN total;
    END;
    PROCEDURE sp_inserta_error(p_rutina VARCHAR2, p_mensaje VARCHAR)
    IS
    BEGIN
        INSERT INTO error_calc
        VALUES(seq_error.NEXTVAL, p_rutina, p_mensaje);
    END;
END;

-- Funcion almacenada
CREATE OR REPLACE FUNCTION fn_porc_antiguedad(p_antiguedad NUMBER)
RETURN NUMBER
IS
	porcentaje porcentaje_antiguedad.porc_antiguedad%TYPE;
	-- Almacena el error de oracle
	msg_error error_calc.descrip_error%TYPE;
BEGIN
	SELECT porc_antiguedad INTO porcentaje
	FROM porcentaje_antiguedad
	WHERE p_antiguedad BETWEEN annos_antiguedad_inf AND annos_antiguedad_sup;
	
	RETURN porcentaje;
EXCEPTION WHEN NO_DATA_FOUND OR TOO_MANY_ROWS THEN
	msg_error := SQLERRM;
	pkg_ventas.sp_inserta_error('En la funcion fn_porc_antiguedad al obtener el porcentaje asociado a '
	|| p_antiguedad || ' años de antiguedad', msg_error);
	RETURN 0;
END;

CREATE OR REPLACE FUNCTION fn_porc_escolaridad(p_escolaridad NUMBER)
RETURN NUMBER
IS
	porcentaje porcentaje_escolaridad.porc_escolaridad%TYPE;
	-- Almacena el error de oracle
	msg_error error_calc.descrip_error%TYPE;
BEGIN
	SELECT porc_escolaridad INTO porcentaje
	FROM porcentaje_escolaridad
	WHERE p_escolaridad = cod_escolaridad;
	
	RETURN porcentaje;
EXCEPTION WHEN NO_DATA_FOUND OR TOO_MANY_ROWS THEN
	msg_error := SQLERRM;
	pkg_ventas.sp_inserta_error('En la funcion fn_porc_escolaridad al obtener el porcentaje asociado a '
	|| p_escolaridad, msg_error);
	RETURN 0;
END;

CREATE OR REPLACE PROCEDURE sp_informe
(p_periodo VARCHAR2, p_colacion NUMBER, p_movilziacion NUMBER)
IS
	-- Almacena a los empleados
	CURSOR c_empleados IS
		SELECT run_empleado, nombre || ' ' || paterno || ' ' || materno nom_empleado,
		sueldo_base, TRUNC(MONTHS_BETWEEN(SYSDATE, fecha_contrato)/12) antiguedad
		cod_escolaridad
		FROM empleado;
	-- Almacena el % de antiguedad
	porc_a porcentaje_antiguedad.porc_antiguedad%TYPE;
	-- Almacena el monto por antiguedad
	asig_ant NUMBER;
	-- Almacena el % de escolaridad
	porc_e porcentaje_escolaridad.porc_escolaridad%TYPE;
	-- Almacena el monto por escolaridad
	monto_esc NUMBER;	
	-- Almacena el % de la comision por ventas
	porc_ventas porcentaje_comision_venta.porc_comision%TYPE;
	-- Almacena el monto de comision
	monto_comision NUMBER;
	-- Almacena el error de oracle
	msg_error error_calc.descrip_error%TYPE;	
	-- Almacena el total de haberes
	total_haberes NUMBER;
BEGIN
	-- Procesa a los empleados
	FOR reg IN c_empleados LOOP
		-- Obtener el monto total de ventas
		pkg_ventas.MONTO_VENTAS := pkg_ventas.fn_monto_ventas(reg.run_empleado, p_periodo);
		-- Obtener el % de antiguedad
		porc_a := fn_porc_antiguedad(reg.antiguedad);
		asig_ant := ROUND(pkg_ventas.MONTO_VENTAS*porc_a/100);
		-- Obtener la asignacion por escolaridad
		-- Obtener el % de escolaridad
		porc_e := fn_porc_escolaridad(reg.cod_escolaridad);
		monto_esc := ROUND(reg.sueldo_base*porc_e/100);
		-- Monto de comsion de ventas
		BEGIN
			SELECT porc_comision INTO porc_ventas
			FROM porcentaje_comision_venta
			WHERE pkg_ventas.MONTO_VENTAS BETWEEN venta_inf AND venta_sup;
			
			monto_comision := ROUND(pkg_ventas.MONTO_VENTAS*porc_ventas/100);
		EXCEPTION WHEN NO_DATA_FOUND THEN	
			monto_comision := 0;
			msg_error := SQLERRM;
			pkg_ventas.sp_inserta_error('Error', msg_error);			
		END;
		total_haberes := reg.sueldo_base + p_colacion + p_movilziacion + asig_ant + 
		monto_esc + monto_comision;
		
		INSERT INTO detalle_haberes_mensual
		VALUES(SUBSTR(p_periodo,1,2), SUBSTR(p_periodo, 4), reg.run_empleado, 
			reg.nom_empleado, reg.sueldo_base, p_colacion, p_movilizacion, asig_ant, 
			monto_esc, monto_comision, total_haberes);
	END LOOP;
END;

CREATE OR REPLACE TRIGGER trg_ventas
AFTER INSERT ON detalle_haberes_mensual
FOR EACH ROW
DECLARE
	-- Almacena la calificacion
	calificacion VARCHAR2(100);
BEGIN
	-- Obtener la calificacion
	calificacion := CASE
		WHEN :NEW.total_haberes BETWEEN 400000 AND 700000 
			THEN 'Empleado con Salario Bajo Promedio'
		WHEN :NEW.total_haberes BETWEEN 700001 AND 900000 
			THEN 'Empleado con Salario Promedio'	
		ELSE 'Empleado con Salario sobre Promedio'
	END;
	-- Inserta el regsitro en la tabla
	INSERT INTO calificacion_mensual_empleado
	VALUES(:NEW.mes, :NEW.anno, :NEW.run_empleado, :NEW.total_haberes, calificacion);
END;
