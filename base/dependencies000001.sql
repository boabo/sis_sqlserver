
/************************************I-DEP-JRR-SQLSERVER-0-13/05/2016*************************************************/

ALTER TABLE sqlserver.tcabecera_viatico
  ADD CONSTRAINT fk_tcabecera_viatico__id_funcionario FOREIGN KEY (id_funcionario)
    REFERENCES orga.tfuncionario(id_funcionario)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
    NOT DEFERRABLE;
    
ALTER TABLE sqlserver.tcabecera_viatico
  ADD CONSTRAINT fk_tcabecera_viatico__id_int_comprobante FOREIGN KEY (id_int_comprobante)
    REFERENCES conta.tint_comprobante(id_int_comprobante)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
    NOT DEFERRABLE;
    
ALTER TABLE sqlserver.tdetalle_viatico
  ADD CONSTRAINT fk_tdetalle_viatico__id_cabecera_viatico FOREIGN KEY (id_cabecera_viatico)
    REFERENCES sqlserver.tcabecera_viatico(id_cabecera_viatico)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
    NOT DEFERRABLE;
    
 ALTER TABLE sqlserver.tdetalle_viatico
  ADD CONSTRAINT fk_tdetalle_viatico__id_uo FOREIGN KEY (id_uo)
    REFERENCES orga.tuo(id_uo)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
    NOT DEFERRABLE;
    
  ALTER TABLE sqlserver.tdetalle_viatico
  ADD CONSTRAINT fk_tdetalle_viatico__id_centro_costo FOREIGN KEY (id_centro_costo)
    REFERENCES param.tcentro_costo(id_centro_costo)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
    NOT DEFERRABLE;
    

CREATE OR REPLACE VIEW sqlserver.vcabecera_viatico(
    id_cabecera_viatico,
    acreedor,
    descripcion,
    id_depto,
    fecha,
    tipo_viatico,
    id_gestion_contable,
    id_centro_costo_depto)
AS
  SELECT cv.id_cabecera_viatico,
         cv.acreedor,
         cv.descripcion,
         d.id_depto,
         cv.fecha,
         cv.tipo_viatico,
         (
           SELECT f_get_periodo_gestion.po_id_gestion
           FROM param.f_get_periodo_gestion(cv.fecha) f_get_periodo_gestion(
             po_id_periodo, po_id_gestion, po_id_periodo_subsistema)
         ) AS id_gestion_contable,
         (
           SELECT f_get_config_relacion_contable.ps_id_centro_costo
           FROM conta.f_get_config_relacion_contable('CCDEPCON'::character
             varying, (
                        SELECT f_get_periodo_gestion.po_id_gestion
                        FROM param.f_get_periodo_gestion(cv.fecha)
                          f_get_periodo_gestion(po_id_periodo, po_id_gestion,
                          po_id_periodo_subsistema)
                ), d.id_depto, NULL::integer,
                  'No existe presupuesto administrativo relacionado al departamento de RRHH'
                  ::character varying) f_get_config_relacion_contable(
                  ps_id_cuenta, ps_id_auxiliar, ps_id_partida,
                  ps_id_centro_costo, ps_nombre_tipo_relacion)
         ) AS id_centro_costo_depto
  FROM sqlserver.tcabecera_viatico cv
       JOIN param.tdepto d ON d.codigo::text = 'CON'::text;
       
CREATE OR REPLACE VIEW sqlserver.vdetalle_viatico_credito(
    id_detalle_viatico,
    id_cabecera_viatico,
    monto,
    id_cuenta,
    id_auxiliar,
    id_partida,
    forma_pago,
    acreedor,
    glosa)
AS
  SELECT dv.id_detalle_viatico,
         cv.id_cabecera_viatico,
         dv.monto,
         (
           SELECT f_get_config_relacion_contable.ps_id_cuenta
           FROM conta.f_get_config_relacion_contable(CASE
                                                       WHEN dv.tipo_credito::
                                                         text = 'banco'::text
                                                         THEN 'BANVIAOPE'::text
                                                       WHEN dv.tipo_credito::
                                                         text = 'retencion'::
                                                         text AND
                                                         cv.tipo_viatico::text =
                                                         'operativo'::text THEN
                                                         'IVAVIAOPE'::text
                                                       WHEN dv.tipo_credito::
                                                         text = 'retencion'::
                                                         text AND
                                                         cv.tipo_viatico::text =
                                                         'administrativo'::text
                                                         THEN 'IVAVIAADM'::text
                                                       WHEN dv.tipo_credito::
                                                         text =
                                                         'retencion_aeropuerto'
                                                         ::text THEN
                                                         'AEROVIAADM'::text
                                                       WHEN dv.tipo_credito::
                                                         text =
                                                         'retencion_transitoria'
                                                         ::text THEN
                                                         'TRANVIAADM'::text
                                                       ELSE NULL::text
                                                     END::character varying,
                                                       cv.id_gestion_contable)
                                                       f_get_config_relacion_contable
                                                       (ps_id_cuenta,
                                                       ps_id_auxiliar,
                                                       ps_id_partida,
                                                       ps_id_centro_costo,
                                                       ps_nombre_tipo_relacion)
         ) AS id_cuenta,
         CASE
           WHEN dv.codigo_auxiliar IS NULL THEN (
                                                  SELECT
                                                    f_get_config_relacion_contable.ps_id_auxiliar
                                                  FROM
                                                    conta.f_get_config_relacion_contable
                                                    (CASE
                                                       WHEN dv.tipo_credito::
                                                         text = 'banco'::text
                                                         THEN 'BANVIAOPE'::text
                                                       WHEN dv.tipo_credito::
                                                         text = 'retencion'::
                                                         text AND
                                                         cv.tipo_viatico::text =
                                                         'operativo'::text THEN
                                                         'IVAVIAOPE'::text
                                                       WHEN dv.tipo_credito::
                                                         text = 'retencion'::
                                                         text AND
                                                         cv.tipo_viatico::text =
                                                         'administrativo'::text
                                                         THEN 'IVAVIAADM'::text
                                                       WHEN dv.tipo_credito::
                                                         text =
                                                         'retencion_aeropuerto'
                                                         ::text THEN
                                                         'AEROVIAADM'::text
                                                       WHEN dv.tipo_credito::
                                                         text =
                                                         'retencion_transitoria'
                                                         ::text THEN
                                                         'TRANVIAADM'::text
                                                       ELSE NULL::text
                                                     END::character varying,
                                                       cv.id_gestion_contable)
                                                       f_get_config_relacion_contable
                                                       (ps_id_cuenta,
                                                       ps_id_auxiliar,
                                                       ps_id_partida,
                                                       ps_id_centro_costo,
                                                       ps_nombre_tipo_relacion)
         )
           ELSE 
         (
           SELECT a.id_auxiliar
           FROM conta.tauxiliar a
           WHERE a.codigo_auxiliar::text = dv.codigo_auxiliar::text
         )
         END AS id_auxiliar,
         (
           SELECT f_get_config_relacion_contable.ps_id_partida
           FROM conta.f_get_config_relacion_contable(CASE
                                                       WHEN dv.tipo_credito::
                                                         text = 'banco'::text
                                                         THEN 'BANVIAOPE'::text
                                                       WHEN dv.tipo_credito::
                                                         text = 'retencion'::
                                                         text AND
                                                         cv.tipo_viatico::text =
                                                         'operativo'::text THEN
                                                         'IVAVIAOPE'::text
                                                       WHEN dv.tipo_credito::
                                                         text = 'retencion'::
                                                         text AND
                                                         cv.tipo_viatico::text =
                                                         'administrativo'::text
                                                         THEN 'IVAVIAADM'::text
                                                       WHEN dv.tipo_credito::
                                                         text =
                                                         'retencion_aeropuerto'
                                                         ::text THEN
                                                         'AEROVIAADM'::text
                                                       WHEN dv.tipo_credito::
                                                         text =
                                                         'retencion_transitoria'
                                                         ::text THEN
                                                         'TRANVIAADM'::text
                                                       ELSE NULL::text
                                                     END::character varying,
                                                       cv.id_gestion_contable)
                                                       f_get_config_relacion_contable
                                                       (ps_id_cuenta,
                                                       ps_id_auxiliar,
                                                       ps_id_partida,
                                                       ps_id_centro_costo,
                                                       ps_nombre_tipo_relacion)
         ) AS id_partida,
         dv.forma_pago,
         dv.acreedor,
         dv.glosa
  FROM sqlserver.tdetalle_viatico dv
       JOIN sqlserver.vcabecera_viatico cv ON cv.id_cabecera_viatico =
         dv.id_cabecera_viatico
  WHERE dv.tipo_transaccion::text = 'credito'::text;

CREATE OR REPLACE VIEW sqlserver.vdetalle_viatico_debito(
    id_detalle_viatico,
    id_cabecera_viatico,
    monto,
    id_presupuesto,
    id_concepto_ingas,
    glosa)
AS
  SELECT dv.id_detalle_viatico,
         cv.id_cabecera_viatico,
         dv.monto,
         CASE
           WHEN dv.id_centro_costo IS NOT NULL THEN dv.id_centro_costo
           ELSE presup.id_centro_costo
         END AS id_presupuesto,
         CASE
           WHEN dv.tipo_viaje::text = 'nacional'::text AND cv.tipo_viatico::text
             = 'operativo'::text THEN 4814
           WHEN dv.tipo_viaje::text = 'internacional'::text AND cv.tipo_viatico
             ::text = 'operativo'::text THEN 4815
           WHEN dv.tipo_viaje::text = 'nacional'::text AND cv.tipo_viatico::text
             = 'administrativo'::text THEN 1658
           WHEN dv.tipo_viaje::text = 'internacional'::text AND cv.tipo_viatico
             ::text = 'administrativo'::text THEN 1662
           ELSE NULL::integer
         END AS id_concepto_ingas,
         dv.glosa
  FROM sqlserver.tdetalle_viatico dv
       JOIN sqlserver.vcabecera_viatico cv ON cv.id_cabecera_viatico =
         dv.id_cabecera_viatico
       LEFT JOIN param.tcentro_costo cc ON cc.id_uo = dv.id_uo AND cc.id_gestion
         = cv.id_gestion_contable OR cc.id_centro_costo = dv.id_centro_costo
       LEFT JOIN pre.tpresupuesto presup ON presup.id_presupuesto =
         cc.id_centro_costo AND presup.tipo_pres::text = '2'::text
  WHERE dv.tipo_transaccion::text = 'debito'::text AND
        presup.id_presupuesto = cc.id_centro_costo;
    


/************************************F-DEP-JRR-SQLSERVER-0-13/05/2016*************************************************/

/************************************I-DEP-JRR-SQLSERVER-0-03/04/2017*************************************************/
CREATE OR REPLACE VIEW sqlserver.vdetalle_viadismi_credito(
    id_detalle_viatico,
    id_cabecera_viatico,
    monto,
    id_presupuesto,
    id_concepto_ingas,
    glosa)
AS
  SELECT dv.id_detalle_viatico,
         cv.id_cabecera_viatico,
         dv.monto,
         CASE
           WHEN dv.id_centro_costo IS NOT NULL THEN dv.id_centro_costo
           ELSE presup.id_centro_costo
         END AS id_presupuesto,
         CASE
           WHEN dv.tipo_viaje::text = 'nacional'::text AND cv.tipo_viatico::text
             = 'operativo'::text THEN 4814
           WHEN dv.tipo_viaje::text = 'internacional'::text AND cv.tipo_viatico
             ::text = 'operativo'::text THEN 4815
           WHEN dv.tipo_viaje::text = 'nacional'::text AND cv.tipo_viatico::text
             = 'administrativo'::text THEN 1658
           WHEN dv.tipo_viaje::text = 'internacional'::text AND cv.tipo_viatico
             ::text = 'administrativo'::text THEN 1662
           ELSE NULL::integer
         END AS id_concepto_ingas,
         dv.glosa
  FROM sqlserver.tdetalle_viatico dv
       JOIN sqlserver.vcabecera_viatico cv ON cv.id_cabecera_viatico =
         dv.id_cabecera_viatico
       LEFT JOIN param.tcentro_costo cc ON cc.id_uo = dv.id_uo AND cc.id_gestion
         = cv.id_gestion_contable OR cc.id_centro_costo = dv.id_centro_costo
       LEFT JOIN pre.tpresupuesto presup ON presup.id_presupuesto =
         cc.id_centro_costo AND presup.tipo_pres::text = '2'::text
  WHERE dv.tipo_transaccion::text = 'credito'::text AND
        presup.id_presupuesto = cc.id_centro_costo;


CREATE OR REPLACE VIEW sqlserver.vdetalle_viadismi_debito(
    id_detalle_viatico,
    id_cabecera_viatico,
    monto,
    id_cuenta,
    id_auxiliar,
    id_partida,
    forma_pago,
    acreedor,
    glosa)
AS
  SELECT dv.id_detalle_viatico,
         cv.id_cabecera_viatico,
         dv.monto,
         (
           SELECT f_get_config_relacion_contable.ps_id_cuenta
           FROM conta.f_get_config_relacion_contable(CASE
                                                       WHEN dv.tipo_credito::
                                                         text = 'banco'::text
                                                         THEN 'BANVIAOPEDIS'::text
                                                       WHEN dv.tipo_credito::
                                                         text = 'retencion'::
                                                         text AND
                                                         cv.tipo_viatico::text =
                                                         'operativo'::text THEN
                                                         'IVAVIAOPEDIS'::text
                                                       WHEN dv.tipo_credito::
                                                         text = 'retencion'::
                                                         text AND
                                                         cv.tipo_viatico::text =
                                                         'administrativo'::text
                                                         THEN 'IVAVIAADMDIS'::text
                                                       WHEN dv.tipo_credito::
                                                         text =
                                                         'retencion_aeropuerto'
                                                         ::text THEN
                                                         'AEROVIAADMDIS'::text
                                                       WHEN dv.tipo_credito::
                                                         text =
                                                         'retencion_transitoria'
                                                         ::text THEN
                                                         'TRANVIAADMDIS'::text
                                                       ELSE NULL::text
                                                     END::character varying,
                                                       cv.id_gestion_contable)
                                                       f_get_config_relacion_contable
                                                       (ps_id_cuenta,
                                                       ps_id_auxiliar,
                                                       ps_id_partida,
                                                       ps_id_centro_costo,
                                                       ps_nombre_tipo_relacion)
         ) AS id_cuenta,
         CASE
           WHEN dv.codigo_auxiliar IS NULL THEN (
                                                  SELECT
                                                    f_get_config_relacion_contable.ps_id_auxiliar
                                                  FROM
                                                    conta.f_get_config_relacion_contable
                                                    (CASE
                                                       WHEN dv.tipo_credito::
                                                         text = 'banco'::text
                                                         THEN 'BANVIAOPEDIS'::text
                                                       WHEN dv.tipo_credito::
                                                         text = 'retencion'::
                                                         text AND
                                                         cv.tipo_viatico::text =
                                                         'operativo'::text THEN
                                                         'IVAVIAOPEDIS'::text
                                                       WHEN dv.tipo_credito::
                                                         text = 'retencion'::
                                                         text AND
                                                         cv.tipo_viatico::text =
                                                         'administrativo'::text
                                                         THEN 'IVAVIAADMDIS'::text
                                                       WHEN dv.tipo_credito::
                                                         text =
                                                         'retencion_aeropuerto'
                                                         ::text THEN
                                                         'AEROVIAADMDIS'::text
                                                       WHEN dv.tipo_credito::
                                                         text =
                                                         'retencion_transitoria'
                                                         ::text THEN
                                                         'TRANVIAADMDIS'::text
                                                       ELSE NULL::text
                                                     END::character varying,
                                                       cv.id_gestion_contable)
                                                       f_get_config_relacion_contable
                                                       (ps_id_cuenta,
                                                       ps_id_auxiliar,
                                                       ps_id_partida,
                                                       ps_id_centro_costo,
                                                       ps_nombre_tipo_relacion)
         )
           ELSE
         (
           SELECT a.id_auxiliar
           FROM conta.tauxiliar a
           WHERE a.codigo_auxiliar::text = dv.codigo_auxiliar::text
         )
         END AS id_auxiliar,
         (
           SELECT f_get_config_relacion_contable.ps_id_partida
           FROM conta.f_get_config_relacion_contable(CASE
                                                       WHEN dv.tipo_credito::
                                                         text = 'banco'::text
                                                         THEN 'BANVIAOPEDIS'::text
                                                       WHEN dv.tipo_credito::
                                                         text = 'retencion'::
                                                         text AND
                                                         cv.tipo_viatico::text =
                                                         'operativo'::text THEN
                                                         'IVAVIAOPEDIS'::text
                                                       WHEN dv.tipo_credito::
                                                         text = 'retencion'::
                                                         text AND
                                                         cv.tipo_viatico::text =
                                                         'administrativo'::text
                                                         THEN 'IVAVIAADMDIS'::text
                                                       WHEN dv.tipo_credito::
                                                         text =
                                                         'retencion_aeropuerto'
                                                         ::text THEN
                                                         'AEROVIAADMDIS'::text
                                                       WHEN dv.tipo_credito::
                                                         text =
                                                         'retencion_transitoria'
                                                         ::text THEN
                                                         'TRANVIAADMDIS'::text
                                                       ELSE NULL::text
                                                     END::character varying,
                                                       cv.id_gestion_contable)
                                                       f_get_config_relacion_contable
                                                       (ps_id_cuenta,
                                                       ps_id_auxiliar,
                                                       ps_id_partida,
                                                       ps_id_centro_costo,
                                                       ps_nombre_tipo_relacion)
         ) AS id_partida,
         dv.forma_pago,
         dv.acreedor,
         dv.glosa
  FROM sqlserver.tdetalle_viatico dv
       JOIN sqlserver.vcabecera_viatico cv ON cv.id_cabecera_viatico =
         dv.id_cabecera_viatico
  WHERE dv.tipo_transaccion::text = 'debito'::text;

/************************************F-DEP-JRR-SQLSERVER-0-03/04/2017*************************************************/

/************************************I-DEP-JRR-SQLSERVER-0-01/08/2017*************************************************/

CREATE OR REPLACE VIEW sqlserver.vdetalle_viatico_debito(
    id_detalle_viatico,
    id_cabecera_viatico,
    monto,
    id_presupuesto,
    id_cuenta,
    id_auxiliar,
    id_partida,
    forma_pago,
    acreedor,
    glosa)
AS
  SELECT dv.id_detalle_viatico,
         cv.id_cabecera_viatico,
         dv.monto,
         CASE
           WHEN dv.tipo_credito::text = 'viatico'::text THEN
             sqlserver.f_get_pres(dv.tipo_credito, dv.id_centro_costo, dv.id_uo,
             cv.id_gestion_contable)
           ELSE cv.id_centro_costo_depto
         END AS id_presupuesto,
         (
           SELECT f_get_config_relacion_contable.ps_id_cuenta
           FROM conta.f_get_config_relacion_contable(
             sqlserver.f_get_codigo_relacion(dv.tipo_credito, cv.tipo_viatico),
             cv.id_gestion_contable, sqlserver.f_get_concepto(dv.tipo_credito,
             dv.tipo_viaje, cv.tipo_viatico), sqlserver.f_get_pres(
             dv.tipo_credito, dv.id_centro_costo, dv.id_uo,
             cv.id_gestion_contable)) f_get_config_relacion_contable(
             ps_id_cuenta, ps_id_auxiliar, ps_id_partida, ps_id_centro_costo,
             ps_nombre_tipo_relacion)
         ) AS id_cuenta,
         CASE
           WHEN dv.codigo_auxiliar IS NULL THEN (
                                                  SELECT
                                                    f_get_config_relacion_contable.ps_id_auxiliar
                                                  FROM
                                                    conta.f_get_config_relacion_contable
                                                    (
                                                    sqlserver.f_get_codigo_relacion
                                                    (dv.tipo_credito,
                                                    cv.tipo_viatico),
                                                    cv.id_gestion_contable,
                                                    sqlserver.f_get_concepto(
                                                    dv.tipo_credito,
                                                    dv.tipo_viaje,
                                                    cv.tipo_viatico),
                                                    sqlserver.f_get_pres(
                                                    dv.tipo_credito,
                                                    dv.id_centro_costo,
                                                    dv.id_uo,
                                                    cv.id_gestion_contable))
                                                    f_get_config_relacion_contable
                                                    (ps_id_cuenta,
                                                    ps_id_auxiliar,
                                                    ps_id_partida,
                                                    ps_id_centro_costo,
                                                    ps_nombre_tipo_relacion)
         )
           ELSE
         (
           SELECT a.id_auxiliar
           FROM conta.tauxiliar a
           WHERE a.codigo_auxiliar::text = dv.codigo_auxiliar::text
         )
         END AS id_auxiliar,
         (
           SELECT f_get_config_relacion_contable.ps_id_partida
           FROM conta.f_get_config_relacion_contable(
             sqlserver.f_get_codigo_relacion(dv.tipo_credito, cv.tipo_viatico),
             cv.id_gestion_contable, sqlserver.f_get_concepto(dv.tipo_credito,
             dv.tipo_viaje, cv.tipo_viatico), sqlserver.f_get_pres(
             dv.tipo_credito, dv.id_centro_costo, dv.id_uo,
             cv.id_gestion_contable)) f_get_config_relacion_contable(
             ps_id_cuenta, ps_id_auxiliar, ps_id_partida, ps_id_centro_costo,
             ps_nombre_tipo_relacion)
         ) AS id_partida,
         dv.forma_pago,
         dv.acreedor,
         dv.glosa
  FROM sqlserver.tdetalle_viatico dv
       JOIN sqlserver.vcabecera_viatico cv ON cv.id_cabecera_viatico =
         dv.id_cabecera_viatico
  WHERE dv.tipo_transaccion::text = 'debito'::text;


  CREATE OR REPLACE VIEW sqlserver.vdetalle_viatico_credito(
    id_detalle_viatico,
    id_cabecera_viatico,
    monto,
    id_presupuesto,
    id_cuenta,
    id_auxiliar,
    id_partida,
    forma_pago,
    acreedor,
    glosa)
AS
  SELECT dv.id_detalle_viatico,
         cv.id_cabecera_viatico,
         dv.monto,
         CASE
           WHEN dv.tipo_credito::text = 'viatico'::text THEN
             sqlserver.f_get_pres(dv.tipo_credito, dv.id_centro_costo, dv.id_uo,
             cv.id_gestion_contable)
           ELSE cv.id_centro_costo_depto
         END AS id_presupuesto,
         (
           SELECT f_get_config_relacion_contable.ps_id_cuenta
           FROM conta.f_get_config_relacion_contable(
             sqlserver.f_get_codigo_relacion(dv.tipo_credito, cv.tipo_viatico),
             cv.id_gestion_contable, sqlserver.f_get_concepto(dv.tipo_credito,
             dv.tipo_viaje, cv.tipo_viatico), sqlserver.f_get_pres(
             dv.tipo_credito, dv.id_centro_costo, dv.id_uo,
             cv.id_gestion_contable)) f_get_config_relacion_contable(
             ps_id_cuenta, ps_id_auxiliar, ps_id_partida, ps_id_centro_costo,
             ps_nombre_tipo_relacion)
         ) AS id_cuenta,
         CASE
           WHEN dv.codigo_auxiliar IS NULL THEN (
                                                  SELECT
                                                    f_get_config_relacion_contable.ps_id_auxiliar
                                                  FROM
                                                    conta.f_get_config_relacion_contable
                                                    (
                                                    sqlserver.f_get_codigo_relacion
                                                    (dv.tipo_credito,
                                                    cv.tipo_viatico),
                                                    cv.id_gestion_contable,
                                                    sqlserver.f_get_concepto(
                                                    dv.tipo_credito,
                                                    dv.tipo_viaje,
                                                    cv.tipo_viatico),
                                                    sqlserver.f_get_pres(
                                                    dv.tipo_credito,
                                                    dv.id_centro_costo,
                                                    dv.id_uo,
                                                    cv.id_gestion_contable))
                                                    f_get_config_relacion_contable
                                                    (ps_id_cuenta,
                                                    ps_id_auxiliar,
                                                    ps_id_partida,
                                                    ps_id_centro_costo,
                                                    ps_nombre_tipo_relacion)
         )
           ELSE
         (
           SELECT a.id_auxiliar
           FROM conta.tauxiliar a
           WHERE a.codigo_auxiliar::text = dv.codigo_auxiliar::text
         )
         END AS id_auxiliar,
         (
           SELECT f_get_config_relacion_contable.ps_id_partida
           FROM conta.f_get_config_relacion_contable(
             sqlserver.f_get_codigo_relacion(dv.tipo_credito, cv.tipo_viatico),
             cv.id_gestion_contable, sqlserver.f_get_concepto(dv.tipo_credito,
             dv.tipo_viaje, cv.tipo_viatico), sqlserver.f_get_pres(
             dv.tipo_credito, dv.id_centro_costo, dv.id_uo,
             cv.id_gestion_contable)) f_get_config_relacion_contable(
             ps_id_cuenta, ps_id_auxiliar, ps_id_partida, ps_id_centro_costo,
             ps_nombre_tipo_relacion)
         ) AS id_partida,
         dv.forma_pago,
         dv.acreedor,
         dv.glosa
  FROM sqlserver.tdetalle_viatico dv
       JOIN sqlserver.vcabecera_viatico cv ON cv.id_cabecera_viatico =
         dv.id_cabecera_viatico
  WHERE dv.tipo_transaccion::text = 'credito'::text;

/************************************F-DEP-JRR-SQLSERVER-0-01/08/2017*************************************************/