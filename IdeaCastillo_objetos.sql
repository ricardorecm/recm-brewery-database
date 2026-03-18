-- ============================================================
-- RECM Brewery 
-- Vistas, Funciones, Procedimientos y Triggers
-- ============================================================

USE recm_brewery;

-- ============================================================
-- VISTAS
-- ============================================================

-- Vista 1: vista_ventas_detalladas

DROP VIEW IF EXISTS vista_ventas_detalladas;
CREATE VIEW vista_ventas_detalladas AS
SELECT
    f.idf                     AS id_factura,
    c.nombre                  AS cliente,
    c.email                   AS email_cliente,
    cr.nombre                 AS empleado,
    cr.rol                    AS rol_empleado,
    ce.nombre                 AS local,
    p.nombre                  AS producto,
    p.tipo                    AS tipo_producto,
    df.cantidad,
    df.p_uni                  AS precio_unitario,
    (df.cantidad * df.p_uni)  AS subtotal,
    f.valor                   AS total_factura
FROM factura f
JOIN cliente         c  ON f.dni  = c.dni
JOIN crew            cr ON f.idc  = cr.idc
JOIN cerveceria      ce ON cr.idl = ce.idl
JOIN detalle_factura df ON f.idf  = df.idf
JOIN producto        p  ON df.idp = p.idp;


-- Vista 2: vista_costo_produccion

DROP VIEW IF EXISTS vista_costo_produccion;
CREATE VIEW vista_costo_produccion AS
SELECT
    p.idp,
    p.nombre                                AS producto,
    p.tipo                                  AS categoria,
    p.precio                                AS precio_venta,
    e.tipo                                  AS proceso_elaboracion,
    SUM(pi.cantidad * i.costo)              AS costo_total_insumos,
    (p.precio - SUM(pi.cantidad * i.costo)) AS margen_bruto
FROM producto        p
JOIN elaboracion     e  ON p.ide  = e.ide
JOIN producto_insumo pi ON p.idp  = pi.idp
JOIN insumo          i  ON pi.idi = i.idi
GROUP BY p.idp, p.nombre, p.tipo, p.precio, e.tipo;


-- Vista 3: vista_resumen_ventas_por_local

DROP VIEW IF EXISTS vista_resumen_ventas_por_local;
CREATE VIEW vista_resumen_ventas_por_local AS
SELECT
    ce.idl,
    ce.nombre                 AS local,
    ce.direccion,
    COUNT(DISTINCT f.idf)     AS cantidad_facturas,
    SUM(f.valor)              AS total_recaudado,
    AVG(f.valor)              AS ticket_promedio,
    COUNT(DISTINCT f.dni)     AS clientes_distintos
FROM cerveceria ce
JOIN crew       cr ON ce.idl = cr.idl
JOIN factura    f  ON cr.idc = f.idc
GROUP BY ce.idl, ce.nombre, ce.direccion;


-- ============================================================
-- FUNCIONES
-- ============================================================

-- Función 1: fn_total_vendido_cliente

DROP FUNCTION IF EXISTS fn_total_vendido_cliente;

DELIMITER //
CREATE FUNCTION fn_total_vendido_cliente(p_dni INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE total DECIMAL(10,2);
    SELECT COALESCE(SUM(valor), 0)
    INTO total
    FROM factura
    WHERE dni = p_dni;
    RETURN total;
END//
DELIMITER ;


-- Función 2: fn_margen_producto

DROP FUNCTION IF EXISTS fn_margen_producto;

DELIMITER //
CREATE FUNCTION fn_margen_producto(p_idp INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE precio DECIMAL(10,2);
    DECLARE costo  DECIMAL(10,2);
    DECLARE margen DECIMAL(10,2);

    SELECT p.precio INTO precio
    FROM producto p
    WHERE p.idp = p_idp;

    SELECT COALESCE(SUM(pi.cantidad * i.costo), 0) INTO costo
    FROM producto_insumo pi
    JOIN insumo i ON pi.idi = i.idi
    WHERE pi.idp = p_idp;

    IF precio = 0 OR costo = 0 THEN
        RETURN 0;
    END IF;

    SET margen = ((precio - costo) / precio) * 100;
    RETURN ROUND(margen, 2);
END//
DELIMITER ;


-- ============================================================
-- PROCEDIMINETOS
-- ============================================================

-- Stored Procedure 1: sp_ranking_locales_ganancia

DROP PROCEDURE IF EXISTS sp_ranking_locales_ganancia;

DELIMITER //
CREATE PROCEDURE sp_ranking_locales_ganancia(IN p_limite INT)
BEGIN
   
    SET p_limite = COALESCE(p_limite, 999999);
    SELECT
        ce.idl,
        ce.nombre                                               AS local,
        ce.direccion,
        COUNT(DISTINCT f.idf)                                   AS cantidad_facturas,
        SUM(f.valor)                                            AS total_facturado,
        SUM(df.cantidad * pi.cantidad * i.costo)                AS costo_total_insumos,
        SUM(f.valor) - SUM(df.cantidad * pi.cantidad * i.costo) AS ganancia_bruta
    FROM cerveceria      ce
    JOIN crew            cr ON ce.idl = cr.idl
    JOIN factura         f  ON cr.idc = f.idc
    JOIN detalle_factura df ON f.idf  = df.idf
    JOIN producto_insumo pi ON df.idp = pi.idp
    JOIN insumo          i  ON pi.idi = i.idi
    GROUP BY ce.idl, ce.nombre, ce.direccion
    ORDER BY ganancia_bruta DESC
    LIMIT p_limite;
END//
DELIMITER ;


-- Stored Procedure 2: sp_productos_mas_vendidos

DROP PROCEDURE IF EXISTS sp_productos_mas_vendidos;

DELIMITER //
CREATE PROCEDURE sp_productos_mas_vendidos(IN p_tipo VARCHAR(200))
BEGIN
    SELECT
        p.idp,
        p.nombre                    AS producto,
        p.tipo,
        p.precio                    AS precio_unitario,
        SUM(df.cantidad)            AS unidades_vendidas,
        SUM(df.cantidad * df.p_uni) AS ingreso_total
    FROM producto        p
    JOIN detalle_factura df ON p.idp = df.idp
    WHERE (p_tipo IS NULL OR p.tipo = p_tipo)
    GROUP BY p.idp, p.nombre, p.tipo, p.precio
    ORDER BY unidades_vendidas DESC;
END//
DELIMITER ;


-- ============================================================
-- TRIGGERS
-- ============================================================

-- Trigger 1: trg_log_cambio_precio

DROP TRIGGER IF EXISTS trg_log_cambio_precio;

DELIMITER //
CREATE TRIGGER trg_log_cambio_precio
BEFORE UPDATE ON producto
FOR EACH ROW
BEGIN
    IF OLD.precio <> NEW.precio THEN
        INSERT INTO log_cambio_precio (idp, nombre, precio_anterior, precio_nuevo)
        VALUES (OLD.idp, OLD.nombre, OLD.precio, NEW.precio);
    END IF;
END//
DELIMITER ;


-- Trigger 2: trg_backup_factura_eliminada

DROP TRIGGER IF EXISTS trg_backup_factura_eliminada;

DELIMITER //
CREATE TRIGGER trg_backup_factura_eliminada
BEFORE DELETE ON factura
FOR EACH ROW
BEGIN
    INSERT INTO log_factura_eliminada (idf, valor, dni, idc)
    VALUES (OLD.idf, OLD.valor, OLD.dni, OLD.idc);
END//
DELIMITER ;