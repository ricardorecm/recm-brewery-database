-- ============================================================
-- RECM Brewery 
-- Creación de tablas e inserción de datos
-- ============================================================

DROP DATABASE IF EXISTS recm_brewery;
CREATE DATABASE recm_brewery;
USE recm_brewery;

-- ============================================================
-- CREACIÓN DE TABLAS
-- ============================================================

-- Tabla: cerveceria

CREATE TABLE cerveceria (
    idl int NOT NULL,
    nombre varchar(200) NOT NULL,
    direccion varchar(200) NOT NULL,
    CONSTRAINT pk_cerveceria PRIMARY KEY (idl)
);

-- Tabla: cliente

CREATE TABLE cliente (
    dni int NOT NULL,
    nombre varchar(200) NOT NULL,
    email varchar(200) NOT NULL,
    telefono varchar(200) NOT NULL,
    CONSTRAINT pk_cliente PRIMARY KEY (dni)
);

-- Tabla: crew

CREATE TABLE crew (
    idc int NOT NULL,
    dni int NOT NULL,
    nombre varchar(200) NOT NULL,
    email varchar(200) NOT NULL,
    telefono varchar(200) NOT NULL,
    rol varchar(200) NOT NULL,
    idl int NOT NULL,
    CONSTRAINT pk_crew PRIMARY KEY (idc),
    CONSTRAINT fk_crew_local FOREIGN KEY (idl)
        REFERENCES cerveceria (idl)
);

-- Tabla: proveedor

CREATE TABLE proveedor (
    idprov int NOT NULL,
    nombre varchar(200) NOT NULL,
    email varchar(200) NOT NULL,
    telefono varchar(200) NOT NULL,
    CONSTRAINT pk_proveedor PRIMARY KEY (idprov)
);

-- Tabla: insumo

CREATE TABLE insumo (
    idi int NOT NULL,
    nombre varchar(200) NOT NULL,
    tipo varchar(200) NOT NULL,
    costo decimal(10,2) NOT NULL,
    idprov int NOT NULL,
    CONSTRAINT pk_insumo PRIMARY KEY (idi),
    CONSTRAINT fk_insumo_proveedor FOREIGN KEY (idprov)
        REFERENCES proveedor (idprov)
);

-- Tabla: elaboracion

CREATE TABLE elaboracion (
    ide int NOT NULL,
    tipo varchar(200) NOT NULL,
    CONSTRAINT pk_elaboracion PRIMARY KEY (ide)
);

-- Tabla: producto

CREATE TABLE producto (
    idp int NOT NULL,
    nombre varchar(200) NOT NULL,
    precio decimal(10,2) NOT NULL,
    tipo varchar(200) NOT NULL,
    ide int NOT NULL,
    CONSTRAINT pk_producto PRIMARY KEY (idp),
    CONSTRAINT fk_producto_elaboracion FOREIGN KEY (ide)
        REFERENCES elaboracion (ide)
);

-- Tabla: factura

CREATE TABLE factura (
    idf int NOT NULL,
    valor decimal(10,2) NOT NULL,
    dni int NOT NULL,
    idc int NOT NULL,
    CONSTRAINT pk_factura PRIMARY KEY (idf),
    CONSTRAINT fk_factura_cliente FOREIGN KEY (dni)
        REFERENCES cliente (dni),
    CONSTRAINT fk_factura_crew FOREIGN KEY (idc)
        REFERENCES crew (idc)
);

-- Tabla: detalle_factura

CREATE TABLE detalle_factura (
    idf int NOT NULL,
    idp int NOT NULL,
    cantidad int NOT NULL,
    p_uni decimal(10,2) NOT NULL,
    CONSTRAINT pk_detalle_factura PRIMARY KEY (idf, idp),
    CONSTRAINT fk_df_factura FOREIGN KEY (idf)
        REFERENCES factura (idf),
    CONSTRAINT fk_df_producto FOREIGN KEY (idp)
        REFERENCES producto (idp)
);

-- Tabla: producto_insumo

CREATE TABLE producto_insumo (
    idp int NOT NULL,
    idi int NOT NULL,
    cantidad decimal(10,2) NOT NULL,
    CONSTRAINT pk_producto_insumo PRIMARY KEY (idp, idi),
    CONSTRAINT fk_pi_producto FOREIGN KEY (idp)
        REFERENCES producto (idp),
    CONSTRAINT fk_pi_insumo FOREIGN KEY (idi)
        REFERENCES insumo (idi)
);

-- Tablas auxiliares de auditoría 

CREATE TABLE log_cambio_precio (
    id_log          int NOT NULL AUTO_INCREMENT,
    idp             int NOT NULL,
    nombre          varchar(200),
    precio_anterior decimal(10,2),
    precio_nuevo    decimal(10,2),
    fecha_cambio    datetime DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_log_precio PRIMARY KEY (id_log)
);

CREATE TABLE log_factura_eliminada (
    id_log     int NOT NULL AUTO_INCREMENT,
    idf        int NOT NULL,
    valor      decimal(10,2),
    dni        int,
    idc        int,
    fecha_baja datetime DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_log_factura PRIMARY KEY (id_log)
);

-- ============================================================
-- INSERCIÓN DE DATOS
-- ============================================================

-- Tabla: cerveceria

INSERT INTO cerveceria (idl, nombre, direccion) VALUES
(1, 'RECM Brewery Central', 'Av. Corrientes 1234, CABA'),
(2, 'RECM Brewery Norte',   'Av. Cabildo 567, CABA'),
(3, 'RECM Brewery Sur',     'Av. Hipólito Yrigoyen 890, Lanús');

-- Tabla: cliente

INSERT INTO cliente (dni, nombre, email, telefono) VALUES
(12345678, 'Juan Pérez',       'juan.perez@email.com',       '1145678901'),
(23456789, 'María García',     'maria.garcia@email.com',     '1156789012'),
(34567890, 'Carlos López',     'carlos.lopez@email.com',     '1167890123'),
(45678901, 'Ana Martínez',     'ana.martinez@email.com',     '1178901234'),
(56789012, 'Roberto Sánchez',  'roberto.sanchez@email.com',  '1189012345'),
(67890123, 'Lucía Fernández',  'lucia.fernandez@email.com',  '1190123456'),
(78901234, 'Diego Torres',     'diego.torres@email.com',     '1101234567'),
(89012345, 'Valentina Ruiz',   'valentina.ruiz@email.com',   '1112345678'),
(90123456, 'Martín Gómez',     'martin.gomez@email.com',     '1123456789'),
(10234567, 'Camila Díaz',      'camila.diaz@email.com',      '1134567890');

-- Tabla: crew

INSERT INTO crew (idc, dni, nombre, email, telefono, rol, idl) VALUES
(1,  11111111, 'Ricardo Castillo',  'ricardo.castillo@recm.com',  '1145000001', 'Maestro Cervecero', 1),
(2,  22222222, 'Sofía Molina',      'sofia.molina@recm.com',      '1145000002', 'Bartender',         1),
(3,  33333333, 'Tomás Herrera',     'tomas.herrera@recm.com',     '1145000003', 'Mozo',              1),
(4,  44444444, 'Paula Vargas',      'paula.vargas@recm.com',      '1145000004', 'Cajera',            1),
(5,  55555555, 'Esteban Romero',    'esteban.romero@recm.com',    '1145000005', 'Maestro Cervecero', 2),
(6,  66666666, 'Carla Suárez',      'carla.suarez@recm.com',      '1145000006', 'Bartender',         2),
(7,  77777777, 'Nicolás Acosta',    'nicolas.acosta@recm.com',    '1145000007', 'Mozo',              2),
(8,  88888888, 'Florencia Ibáñez',  'florencia.ibanez@recm.com',  '1145000008', 'Cajera',            3),
(9,  99999999, 'Andrés Paredes',    'andres.paredes@recm.com',    '1145000009', 'Maestro Cervecero', 3),
(10, 10101010, 'Miriam Espinoza',   'miriam.espinoza@recm.com',   '1145000010', 'Mozo',              3);

-- Tabla: proveedor

INSERT INTO proveedor (idprov, nombre, email, telefono) VALUES
(1,  'Malta Argentina S.A.',     'ventas@maltaarg.com',          '1150001111'),
(2,  'Lúpulos del Sur',          'contacto@lupulosdelsur.com',   '1150002222'),
(3,  'Levaduras Premium',        'info@levaduraspremium.com',    '1150003333'),
(4,  'Granos & Cereales S.R.L.', 'ventas@granosyc.com',          '1150004444'),
(5,  'Aditivos Cerveceros',      'pedidos@aditivosc.com',        '1150005555'),
(6,  'Empaques y Botellas S.A.', 'empaques@byb.com',             '1150006666'),
(7,  'Agua Pura Industrial',     'agua@aguapura.com',            '1150007777'),
(8,  'Ingredientes Gourmet',     'gourmet@ingred.com',           '1150008888'),
(9,  'Frío y Fresco S.A.',       'friofreso@fyf.com',            '1150009999'),
(10, 'Distribuidora Norte',      'norte@distr.com',              '1150010000');

-- Tabla: insumo

INSERT INTO insumo (idi, nombre, tipo, costo, idprov) VALUES
(1,  'Malta Pale Ale',      'Malta',    850.00,  1),
(2,  'Malta Caramelo',      'Malta',    920.00,  1),
(3,  'Lúpulo Cascade',      'Lúpulo',  1200.00,  2),
(4,  'Lúpulo Centennial',   'Lúpulo',  1350.00,  2),
(5,  'Levadura Ale US-05',  'Levadura', 450.00,  3),
(6,  'Levadura Lager W-34', 'Levadura', 480.00,  3),
(7,  'Avena en copos',      'Cereal',   320.00,  4),
(8,  'Trigo malteado',      'Cereal',   380.00,  4),
(9,  'Agua mineralizada',   'Agua',      50.00,  7),
(10, 'Cáscara de naranja',  'Aditivo',  280.00,  5),
(11, 'Jengibre fresco',     'Aditivo',  350.00,  8),
(12, 'Miel de abeja',       'Aditivo',  600.00,  8),
(13, 'Pan brioche',         'Panadería',420.00,  8),
(14, 'Carne picada',        'Proteína',980.00,  9),
(15, 'Queso cheddar',       'Lácteo',   560.00,  9),
(16, 'Jamón cocido',        'Fiambre',  740.00,  9),
(17, 'Salame',              'Fiambre',  820.00,  9),
(18, 'Papa fresca',         'Verdura',  120.00, 10),
(19, 'Aceite de girasol',   'Aceite',   310.00, 10),
(20, 'Queso brie',          'Lácteo',   890.00,  9);

-- Tabla: elaboracion

INSERT INTO elaboracion (ide, tipo) VALUES
(1, 'Fermentación Alta'),
(2, 'Fermentación Baja'),
(3, 'Fermentación Espontánea'),
(4, 'Cocción Directa'),
(5, 'Maceración en Frío');

-- Tabla: producto

INSERT INTO producto (idp, nombre, precio, tipo, ide) VALUES
(1,  'Pale Ale RECM',         850.00, 'Cerveza', 1),
(2,  'Lager Clásica',         750.00, 'Cerveza', 2),
(3,  'Stout Oscura',          950.00, 'Cerveza', 1),
(4,  'Wheat Beer',            800.00, 'Cerveza', 1),
(5,  'IPA Lupulada',         1050.00, 'Cerveza', 1),
(6,  'Honey Ale',             980.00, 'Cerveza', 1),
(7,  'Tabla de Fiambres',    1500.00, 'Comida',  4),
(8,  'Hamburguesa Artesanal',1800.00, 'Comida',  4),
(9,  'Papas Rústicas',        900.00, 'Comida',  4),
(10, 'Picada RECM',          2200.00, 'Comida',  4);

-- Tabla: factura

INSERT INTO factura (idf, valor, dni, idc) VALUES
(1,  2550.00, 12345678, 2),
(2,  3600.00, 23456789, 3),
(3,  1800.00, 34567890, 4),
(4,  4250.00, 45678901, 2),
(5,  1700.00, 56789012, 6),
(6,  5100.00, 67890123, 3),
(7,  2800.00, 78901234, 4),
(8,  3950.00, 89012345, 6),
(9,  1050.00, 90123456, 2),
(10, 4700.00, 10234567, 3);

-- Tabla: detalle_factura

INSERT INTO detalle_factura (idf, idp, cantidad, p_uni) VALUES
(1,  1,  2, 850.00),
(1,  9,  1, 900.00),
(2,  5,  2, 1050.00),
(2,  8,  1, 1800.00),
(3,  8,  1, 1800.00),
(4,  5,  2, 1050.00),
(4,  7,  1, 1500.00),
(4,  3,  1,  950.00),
(5,  2,  2,  750.00),
(5,  1,  1,  850.00),
(6,  6,  2,  980.00),
(6,  10, 1, 2200.00),
(7,  4,  2,  800.00),
(7,  9,  1,  900.00),
(8,  5,  2, 1050.00),
(8,  10, 1, 2200.00),
(9,  5,  1, 1050.00),
(10, 6,  3,  980.00),
(10, 8,  1, 1800.00);

-- Tabla: producto_insumo

-- Cervezas

INSERT INTO producto_insumo (idp, idi, cantidad) VALUES
(1,  1,  4.50),   -- Pale Ale: malta pale ale
(1,  3,  0.80),   -- Pale Ale: lúpulo cascade
(1,  5,  0.02),   -- Pale Ale: levadura ale
(1,  9,  20.00),  -- Pale Ale: agua
(2,  1,  4.00),   -- Lager: malta pale ale
(2,  6,  0.02),   -- Lager: levadura lager
(2,  9,  20.00),  -- Lager: agua
(3,  2,  3.00),   -- Stout: malta caramelo
(3,  1,  2.00),   -- Stout: malta pale ale
(3,  5,  0.02),   -- Stout: levadura ale
(3,  9,  20.00),  -- Stout: agua
(4,  8,  2.50),   -- Wheat: trigo malteado
(4,  1,  2.00),   -- Wheat: malta pale ale
(4,  5,  0.02),   -- Wheat: levadura ale
(4,  9,  20.00),  -- Wheat: agua
(5,  1,  4.50),   -- IPA: malta pale ale
(5,  3,  1.20),   -- IPA: lúpulo cascade
(5,  4,  0.50),   -- IPA: lúpulo centennial
(5,  5,  0.02),   -- IPA: levadura ale
(5,  9,  20.00),  -- IPA: agua
(6,  1,  4.00),   -- Honey Ale: malta pale ale
(6,  5,  0.02),   -- Honey Ale: levadura ale
(6,  12, 0.50),   -- Honey Ale: miel
(6,  9,  20.00),  -- Honey Ale: agua

-- Comidas

(7,  16, 0.15),   -- Tabla de Fiambres: jamón cocido
(7,  17, 0.15),   -- Tabla de Fiambres: salame
(7,  20, 0.10),   -- Tabla de Fiambres: queso brie
(8,  14, 0.20),   -- Hamburguesa: carne picada
(8,  13, 0.10),   -- Hamburguesa: pan brioche
(8,  15, 0.05),   -- Hamburguesa: queso cheddar
(9,  18, 0.30),   -- Papas Rústicas: papa fresca
(9,  19, 0.05),   -- Papas Rústicas: aceite
(10, 16, 0.12),   -- Picada RECM: jamón cocido
(10, 17, 0.12),   -- Picada RECM: salame
(10, 20, 0.15),   -- Picada RECM: queso brie
(10, 15, 0.10);   -- Picada RECM: queso cheddar

SELECT * FROM recm_brewery.producto