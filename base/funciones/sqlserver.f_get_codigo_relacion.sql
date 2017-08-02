CREATE OR REPLACE FUNCTION sqlserver.f_get_codigo_relacion (
  p_tipo_credito varchar,
  p_tipo_viatico varchar
)
RETURNS varchar AS
$body$
DECLARE

BEGIN
  return (CASE
                                                       WHEN p_tipo_credito::
                                                         text = 'banco'::text
                                                         THEN 'BANVIAOPE'::text
                                                       WHEN p_tipo_credito::
                                                         text = 'retencion'::
                                                         text AND
                                                         p_tipo_viatico::text =
                                                         'operativo'::text THEN
                                                         'IVAVIAOPE'::text
                                                       WHEN p_tipo_credito::
                                                         text = 'retencion'::
                                                         text AND
                                                         p_tipo_viatico::text =
                                                         'administrativo'::text
                                                         THEN 'IVAVIAADM'::text
                                                       WHEN p_tipo_credito::
                                                         text =
                                                         'retencion_aeropuerto'
                                                         ::text THEN
                                                         'AEROVIAADM'::text
                                                       WHEN p_tipo_credito::
                                                         text =
                                                         'retencion_transitoria'
                                                         ::text THEN
                                                         'TRANVIAADM'::text
                                                       WHEN p_tipo_credito::
                                                         text =
                                                         'viatico'
                                                         ::text THEN
                                                         'CUECOMP'::text
                                                       ELSE NULL::text
                                                     END);

END;
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY INVOKER
COST 100;