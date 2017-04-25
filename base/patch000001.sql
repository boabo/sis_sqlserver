
/************************************I-SCP-JRR-SQLSERVER-0-13/05/2016*************************************************/

CREATE TABLE sqlserver.tcabecera_viatico (
  id_cabecera_viatico SERIAL NOT NULL,
  id_funcionario INTEGER NOT NULL,
  descripcion TEXT NOT NULL,
  acreedor VARCHAR(255) NOT NULL,
  tipo_viatico VARCHAR(50) NOT NULL,
  id_int_comprobante INTEGER ,
  fecha	DATE NOT NULL,
  nro_sigma VARCHAR(150) NOT NULL,
  PRIMARY KEY(id_cabecera_viatico)
) INHERITS (pxp.tbase);

CREATE TABLE sqlserver.tdetalle_viatico (
  id_detalle_viatico SERIAL NOT NULL,
  id_cabecera_viatico INTEGER NOT NULL,  
  tipo_viaje VARCHAR(50) NOT NULL,
  tipo_transaccion VARCHAR(50) NOT NULL,
  monto NUMERIC(18,2) NOT NULL,
  tipo_credito VARCHAR(150),
  id_uo INTEGER,
  id_centro_costo INTEGER,
  codigo_auxiliar VARCHAR(50),
  forma_pago VARCHAR(50),
  acreedor VARCHAR(255),
  glosa TEXT,
  PRIMARY KEY(id_detalle_viatico)
) INHERITS (pxp.tbase);

COMMENT ON COLUMN sqlserver.tcabecera_viatico.tipo_viatico
IS 'valores: administrativo | operativo';

COMMENT ON COLUMN sqlserver.tdetalle_viatico.tipo_viaje
IS 'valores: internacional | nacional';

COMMENT ON COLUMN sqlserver.tdetalle_viatico.tipo_transaccion
IS 'valores: debito | credito';

COMMENT ON COLUMN sqlserver.tdetalle_viatico.tipo_credito
IS 'valores: banco | retencion | retencion_aeropuerto | retencion_transitoria';

COMMENT ON COLUMN sqlserver.tdetalle_viatico.forma_pago
IS 'valores: cheque | transferencia';


CREATE TYPE sqlserver.detalle_viatico AS (
  tipo_viaje VARCHAR(50),
  tipo_transaccion VARCHAR(50),
  tipo_credito VARCHAR(50),
  monto NUMERIC(18,2),
  id_uo INTEGER,
  id_centro_costo INTEGER,
  codigo_auxiliar VARCHAR(50),
  forma_pago VARCHAR(50),
  acreedor VARCHAR(255),
  glosa TEXT
);

/************************************F-SCP-JRR-SQLSERVER-0-13/05/2016*************************************************/