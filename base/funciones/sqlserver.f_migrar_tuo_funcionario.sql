CREATE OR REPLACE FUNCTION sqlserver.f_migrar_tuo_funcionario (
)
RETURNS trigger AS
$body$
DECLARE

  v_consulta 		text;
  v_id_usuario 		integer;
  v_cadena_db		varchar;
  v_id_funcionario  integer;
BEGIN

    v_cadena_db = pxp.f_get_variable_global('cadena_db_sql_2');

    select tu.id_usuario
    into v_id_usuario
    from segu.tusuario tu
    where tu.cuenta = (string_to_array(current_user,'_'))[3];

    SELECT tf.id_funcionario
    INTO v_id_funcionario
    FROM segu.tusuario tu
    INNER JOIN orga.tfuncionario tf on tf.id_persona = tu.id_persona
    WHERE tu.id_usuario = v_id_usuario;

    if(TG_OP = 'INSERT')then
		-- EXCEPTION 'LLEGA';
    	v_consulta =  'exec Ende_HistorialCargo ''INS'', '||new.id_uo_funcionario||', '||new.id_funcionario||', '||
        			  new.id_cargo||', '''||new.nro_documento_asignacion||''', '''||new.fecha_asignacion||''', null, '||
                      v_id_funcionario||', '''||new.fecha_documento_asignacion||''', ''activo'';';

    elsif(TG_OP ='UPDATE' )then
    	if new.estado_reg = 'inactivo' then
        	v_consulta =  'exec Ende_HistorialCargo ''DEL'', '||old.id_uo_funcionario||', ''null'', ''null'', ''null'', ''null'', ''null'', ''null'', ''null'', ''null'' ;';
        else
    		v_consulta =  'exec Ende_HistorialCargo ''UPD'', '||new.id_uo_funcionario||', '||new.id_funcionario||', '||
        			  	  new.id_cargo||', '''||new.nro_documento_asignacion||''', '||''||new.fecha_asignacion||','||
                      	  new.fecha_finalizacion||','||v_id_funcionario||','||new.fecha_documento_asignacion||', ''activo'';';
    	end if;
	end if;


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