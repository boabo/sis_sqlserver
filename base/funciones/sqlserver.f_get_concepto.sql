CREATE OR REPLACE FUNCTION sqlserver.f_get_concepto (
  p_tipo_credito varchar,
  p_tipo_viaje varchar,
  p_tipo_viatico varchar,
  p_codigo_auxiliar varchar
)
RETURNS integer AS
$body$
DECLARE

BEGIN
  return (CASE
  			WHEN p_tipo_credito != 'viatico' then
            	NULL
           WHEN p_tipo_viaje::text = 'nacional'::text AND p_tipo_viatico::text
             = 'operativo'::text THEN 4814
           WHEN p_tipo_viaje::text = 'internacional'::text AND p_tipo_viatico
             ::text = 'operativo'::text THEN 4815
           WHEN p_tipo_viaje::text = 'nacional'::text AND p_tipo_viatico::text
             = 'administrativo'::text and  p_codigo_auxiliar = 'entrenamiento' THEN 2912
           WHEN p_tipo_viaje::text = 'nacional'::text AND p_tipo_viatico::text
             = 'administrativo'::text THEN 4872
           WHEN p_tipo_viaje::text = 'internacional'::text AND p_tipo_viatico::text
             = 'administrativo'::text and  p_codigo_auxiliar = 'entrenamiento' THEN 2914
           WHEN p_tipo_viaje::text = 'internacional'::text AND p_tipo_viatico
             ::text = 'administrativo'::text THEN 4873
           ELSE NULL
           END)::INTEGER;

END;
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY INVOKER
COST 100;