CREATE OR REPLACE FUNCTION sqlserver.f_migrar_tafp (
)
RETURNS trigger AS
$body$
DECLARE

  v_record_emp 		record;
  v_consulta 		text;
  v_id_usuario 		integer;
  v_codigo_aux		varchar;
  v_nombre_aux		varchar;
  v_corriente		varchar;
  v_lugar_nac		varchar;
  v_cadena_db		varchar;
BEGIN

    v_cadena_db = pxp.f_get_variable_global('cadena_db_sql_2');

    if(TG_OP = 'INSERT')then
    	v_consulta =  'exec Ende_Afp ''INS'', '||new.id_funcionario_afp||', '||new.id_funcionario||', '||
         			  new.id_afp||', '||new.nro_afp||', ''activo'' ;';
    elsif(TG_OP ='UPDATE' )then
    	if new.estado_reg = 'inactivo' then
          select tf.id_funcionario, tf.codigo
          into v_record_emp
          from orga.tfuncionario tf
          where id_funcionario = new.id_funcionario;

          v_consulta =  'exec Ende_Afp ''DEL'', '''||coalesce(new.id_funcionario_afp,'')||''', '''||coalesce(new.id_funcionario,'')||''', '''||
         			   coalesce(new.id_afp,'')||''', '''||coalesce(new.nro_afp,'')||''', ''activo'' ;';
        else
          v_consulta =  'exec Ende_Afp ''UPD'', '||new.id_funcionario_afp||', '||new.id_funcionario||', '||
                         new.id_afp||', '||new.nro_afp||', ''activo'' ;';
        end if;

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