CREATE OR REPLACE FUNCTION sqlserver.f_get_concepto (
  p_tipo_credito varchar,
  p_tipo_viaje varchar,
  p_tipo_viatico varchar,
  p_codigo_auxiliar varchar,
  p_gestion varchar
)
RETURNS integer AS
$body$
DECLARE
V_CONTA INTEGER = -1;

v_contador_ext		integer;
v_existencia_exterior varchar;

v_contador_int		integer;
v_existencia_interior	varchar;


BEGIN
--raise exception 'A: %, B: %, C: %, D: %, E: %', p_tipo_credito, p_tipo_viaje, p_tipo_viatico, p_codigo_auxiliar,p_gestion;
if (p_codigo_auxiliar != 'entrenamiento' and p_codigo_auxiliar is not null and p_codigo_auxiliar != '') then
				raise exception 'entra aqui el dato %',p_codigo_auxiliar;
				/*Verificamos si existe el concepto VIATICOS POR VIAJES AL EXTERIOR DEL PAIS (TRIPULACION EN VUELO) en la gestion*/
                select 1 into v_contador_ext
                from param.tconcepto_ingas ing
                inner join conta.trelacion_contable re on re.id_tabla = ing.id_concepto_ingas
                inner join param.tcentro_costo cc on cc.id_centro_costo = re.id_centro_costo
                where cc.id_uo = p_codigo_auxiliar::integer and ing.id_concepto_ingas = 4815 and cc.id_gestion = p_gestion::integer
                limit 1;

                IF (v_contador_ext = 1) then
                	v_existencia_exterior = 'true';
                else
                	v_existencia_exterior = 'false';
                end if;


/*Verificamos si existe el concepto VIATICOS POR VIAJES AL INTERIOR DEL PAIS (TRIPULACION EN VUELO) en la gestion*/
                select 1 into v_contador_int
                from param.tconcepto_ingas ing
                inner join conta.trelacion_contable re on re.id_tabla = ing.id_concepto_ingas
                inner join param.tcentro_costo cc on cc.id_centro_costo = re.id_centro_costo
                where cc.id_uo = p_codigo_auxiliar::integer and ing.id_concepto_ingas = 4814 and cc.id_gestion = p_gestion::integer
                limit 1;

                IF (v_contador_ext = 1) then
                	v_existencia_interior = 'true';
                else
                	v_existencia_interior = 'false';
				end if;


end if;

--raise exception 'llega aqui dato F: %, G: %, H: %',p_tipo_viaje,p_tipo_viatico,v_existencia_interior;
return (CASE
  		   WHEN p_tipo_credito != 'viatico' then
		   	NULL
           WHEN p_tipo_viaje::text = 'nacional'::text AND p_tipo_viatico::text
             = 'operativo'::text and v_existencia_interior = 'true' THEN 4814 --VIATICOS POR VIAJES AL INTERIOR DEL PAIS (TRIPULACION EN VUELO)
           WHEN p_tipo_viaje::text = 'internacional'::text AND p_tipo_viatico
             ::text = 'operativo'::text and  v_existencia_exterior = 'true' THEN 4815 --VIATICOS POR VIAJES AL EXTERIOR DEL PAIS (TRIPULACION EN VUELO)

 		   WHEN p_tipo_viaje::text = 'nacional'::text AND p_tipo_viatico::text
             = 'operativo'::text and  v_existencia_interior='false' THEN 4872 -- VIATICOS POR VIAJES AL INTERIOR DEL PAIS
           WHEN p_tipo_viaje::text = 'internacional'::text AND p_tipo_viatico
             ::text = 'operativo'::text and  v_existencia_exterior = 'false' THEN 4873 --VIATICOS POR VIAJES AL EXTERIOR DEL PAIS


           WHEN p_tipo_viaje::text = 'nacional'::text AND p_tipo_viatico::text
             = 'administrativo'::text and  p_codigo_auxiliar = 'entrenamiento' THEN 2912 -- VIATICOS POR VIAJES AL INTERIOR DEL PAIS (TRIPULACION ENTRENAMIENTO)
           WHEN p_tipo_viaje::text = 'nacional'::text AND p_tipo_viatico::text
             = 'administrativo'::text THEN 4872 -- VIATICOS POR VIAJES AL INTERIOR DEL PAIS

           WHEN p_tipo_viaje::text = 'internacional'::text AND p_tipo_viatico::text
             = 'administrativo'::text and  p_codigo_auxiliar = 'entrenamiento' THEN 2914 -- VIATICOS POR VIAJES AL EXTERIOR DEL PAÍS (TRIPULACION ENTRENAMIENTO)
           WHEN p_tipo_viaje::text = 'internacional'::text AND p_tipo_viatico
             ::text = 'administrativo'::text THEN 4873 --VIATICOS POR VIAJES AL EXTERIOR DEL PAIS
           ELSE  NULL
           END)::INTEGER;


RETURN 0::INTEGER;
END;
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY INVOKER
COST 100;

ALTER FUNCTION sqlserver.f_get_concepto (p_tipo_credito varchar, p_tipo_viaje varchar, p_tipo_viatico varchar, p_codigo_auxiliar varchar, p_gestion varchar)
  OWNER TO postgres;
