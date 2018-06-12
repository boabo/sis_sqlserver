CREATE OR REPLACE FUNCTION sqlserver.f_migrar_tcargo (
)
RETURNS trigger AS
$body$
DECLARE

  v_record_cargo 		record;
  v_consulta 		text;
  v_id_usuario 		integer;

  v_cadena_db		varchar;
BEGIN

    v_cadena_db = pxp.f_get_variable_global('cadena_db_sql_2');

    if(TG_OP = 'INSERT')then
    	v_consulta =  'exec Ende_Cargo ''INS'', '||new.id_temporal_cargo||', '''||new.nombre||''', '||
        			  new.id_temporal_jerarquia_aprobacion||';';
    elsif(TG_OP ='UPDATE' )then
		v_consulta =  'exec Ende_Cargo ''UPD'', '||new.id_temporal_cargo||', '''||new.nombre||''', '||
        			  new.id_temporal_jerarquia_aprobacion||';';
    elsif(TG_OP ='DELETE' )then
            v_consulta =  'exec Ende_Cargo ''DEL'', '||old.id_temporal_cargo||', null, null ;';
	end if;


  	select tu.id_usuario
    into v_id_usuario
    from segu.tusuario tu
    where tu.cuenta = (string_to_array(current_user,'_'))[3];

	INSERT INTO sqlserver.tmigracion
    (	id_usuario_reg,
    	consulta,
      	estado,
      	respuesta,
        operacion,
        cadena_db
    )
    VALUES (
    	v_id_usuario,
    	v_consulta,
      	'pendiente',
      	null,
        TG_OP::varchar,
        v_cadena_db
    );

RETURN NULL;

END;
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY INVOKER
COST 100;