CREATE OR REPLACE FUNCTION sqlserver.f_get_pres (
  p_tipo_credito varchar,
  p_id_presupuesto integer,
  p_id_uo integer,
  p_id_gestion integer
)
RETURNS integer AS
$body$
DECLARE
  v_id_presupuesto	INTEGER;
BEGIN
  if (p_tipo_credito = 'viatico' and p_id_presupuesto IS NOT NULL) THEN
          v_id_presupuesto = p_id_presupuesto;
  elsif (p_tipo_credito = 'viatico' and p_id_presupuesto IS NULL) THEN
          --select por uo
          select presup.id_presupuesto into v_id_presupuesto
          from param.tcentro_costo cc
          inner join pre.tpresupuesto presup ON presup.id_presupuesto =
              cc.id_centro_costo AND presup.tipo_pres = '2' 
          where cc.id_uo = p_id_uo AND cc.id_gestion = p_id_gestion
          order by presup.id_presupuesto
          offset 0 limit 1;
  ELSE 
        	v_id_presupuesto= NULL;
  END IF;
  
  return v_id_presupuesto;

END;
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY INVOKER
COST 100;