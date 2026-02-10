DROP DATABASE IF EXISTS recm_brewery;

CREATE DATABASE recm_brewery;

DROP TABLE IF EXISTS recm_brewery.detalle_factura;

DROP TABLE IF EXISTS recm_brewery.producto_insumo;

DROP TABLE IF EXISTS recm_brewery.factura;

DROP TABLE IF EXISTS recm_brewery.producto;

DROP TABLE IF EXISTS recm_brewery.elaboracion;

DROP TABLE IF EXISTS recm_brewery.insumo;

DROP TABLE IF EXISTS recm_brewery.proveedor;

DROP TABLE IF EXISTS recm_brewery.crew;

DROP TABLE IF EXISTS recm_brewery.cliente;

DROP TABLE IF EXISTS recm_brewery.cerveceria;

-- Tabla: cerveceria

CREATE TABLE recm_brewery.cerveceria (
    idl int NOT NULL,
    nombre varchar(200) NOT NULL,
    direccion varchar(200) NOT NULL,
    CONSTRAINT pk_cerveceria PRIMARY KEY (idl)
);

-- Tabla: cliente

CREATE TABLE recm_brewery.cliente (
    dni int NOT NULL,
    nombre varchar(200) NOT NULL,
    email varchar(200) NOT NULL,
    telefono varchar(200) NOT NULL,
    CONSTRAINT pk_cliente PRIMARY KEY (dni)
);

-- Tabla: crew  

CREATE TABLE recm_brewery.crew (
    idc int NOT NULL,
    dni int NOT NULL,
    nombre varchar(200) NOT NULL,
    email varchar(200) NOT NULL,
    telefono varchar(200) NOT NULL,
    rol varchar(200) NOT NULL,
    idl int NOT NULL,
    CONSTRAINT pk_crew PRIMARY KEY (idc),
    CONSTRAINT fk_crew_local FOREIGN KEY (idl)
        REFERENCES recm_brewery.cerveceria (idl)
);

-- Tabla: proveedor

CREATE TABLE recm_brewery.proveedor (
    idprov int NOT NULL,
    nombre varchar(200) NOT NULL,
    email varchar(200) NOT NULL,
    telefono varchar(200) NOT NULL,
    CONSTRAINT pk_proveedor PRIMARY KEY (idprov)
);

-- Tabla: insumo

CREATE TABLE recm_brewery.insumo (
    idi int NOT NULL,
    nombre varchar(200) NOT NULL,
    tipo varchar(200) NOT NULL,
    costo decimal(10,2) NOT NULL,
    idprov int NOT NULL,
    CONSTRAINT pk_insumo PRIMARY KEY (idi),
    CONSTRAINT fk_insumo_proveedor FOREIGN KEY (idprov)
        REFERENCES recm_brewery.proveedor (idprov)
);

-- Tabla: elaboracion
CREATE TABLE recm_brewery.elaboracion (
    ide int NOT NULL,
    tipo varchar(200) NOT NULL,
    CONSTRAINT pk_elaboracion PRIMARY KEY (ide)
);

-- Tabla: producto

CREATE TABLE recm_brewery.producto (
    idp int NOT NULL,
    nombre varchar(200) NOT NULL,
    precio decimal(10,2) NOT NULL,
    tipo varchar(200) NOT NULL,
    ide int NOT NULL,
    CONSTRAINT pk_producto PRIMARY KEY (idp),
    CONSTRAINT fk_producto_elaboracion FOREIGN KEY (ide)
        REFERENCES recm_brewery.elaboracion (ide)
);

-- Tabla: factura 

CREATE TABLE recm_brewery.factura (
    idf int NOT NULL,
    valor decimal(10,2) NOT NULL,
    dni int NOT NULL,
    idc int NOT NULL,
    CONSTRAINT pk_factura PRIMARY KEY (idf),
    CONSTRAINT fk_factura_cliente FOREIGN KEY (dni)
        REFERENCES recm_brewery.cliente (dni),
    CONSTRAINT fk_factura_crew FOREIGN KEY (idc)
        REFERENCES recm_brewery.crew (idc)
);

-- Tabla: detalle_factura

CREATE TABLE recm_brewery.detalle_factura (
    idf int NOT NULL,
    idp int NOT NULL,
    cantidad int NOT NULL,
    p_uni decimal(10,2) NOT NULL,
    CONSTRAINT pk_detalle_factura PRIMARY KEY (idf, idp),
    CONSTRAINT fk_df_factura FOREIGN KEY (idf)
        REFERENCES recm_brewery.factura (idf),
    CONSTRAINT fk_df_producto FOREIGN KEY (idp)
        REFERENCES recm_brewery.producto (idp)
);

-- Tabla: producto_insumo

CREATE TABLE recm_brewery.producto_insumo (
    idp int NOT NULL,
    idi int NOT NULL,
    cantidad decimal(10,2) NOT NULL,
    CONSTRAINT pk_producto_insumo PRIMARY KEY (idp, idi),
    CONSTRAINT fk_pi_producto FOREIGN KEY (idp)
        REFERENCES recm_brewery.producto (idp),
    CONSTRAINT fk_pi_insumo FOREIGN KEY (idi)
        REFERENCES recm_brewery.insumo (idi)
);