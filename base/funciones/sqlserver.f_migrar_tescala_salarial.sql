CREATE OR REPLACE FUNCTION sqlserver.f_migrar_tescala_salarial (
)
RETURNS trigger AS
$body$
DECLARE

  v_consulta 			text;
  v_id_usuario 			integer;
  v_cadena_db			varchar;
  v_id_funcionario		integer;
BEGIN
    v_cadena_db = pxp.f_get_variable_global('cadena_db_sql_2');
	select tu.id_usuario
    into v_id_usuario
    from segu.tusuario tu
    where tu.cuenta = (string_to_array(current_user,'_'))[2];

    v_id_usuario = coalesce(v_id_usuario, 636);

    SELECT tf.id_funcionario
    INTO v_id_funcionario
    FROM segu.tusuario tu
    INNER JOIN orga.tfuncionario tf on tf.id_persona = tu.id_persona
    WHERE tu.id_usuario = v_id_usuario;
    --raise exception 'TG_OP: %',v_id_funcionario;
    if(TG_OP = 'INSERT')then

    	v_consulta =  'exec Ende_EscalaSalarial ''INS'', '||new.id_escala_salarial||', '||new.id_categoria_salarial||', 1, '''||
        			  new.nombre||''', '||new.nro_casos||', '||new.haber_basico||', '||v_id_funcionario||', '''||new.fecha_ini::varchar||''';';

    elsif(TG_OP ='UPDATE' )then
    	if new.estado_reg = 'inactivo' then
        	v_consulta =  'exec Ende_EscalaSalarial ''DEL'', '||old.id_escala_salarial||', '||old.id_categoria_salarial||', 1, '''||
        			      old.nombre||''', '||old.nro_casos||', '||old.haber_basico||', '||v_id_funcionario||', '''||current_date::varchar||''';';
        else
    		v_consulta =  'exec Ende_EscalaSalarial ''UPD'', '||new.id_escala_salarial||', '||new.id_categoria_salarial||', 1, '''||
        			  	  new.nombre||''', '||new.nro_casos||', '||new.haber_basico||', '||v_id_funcionario||', '''||new.fecha_ini::varchar||''';';
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