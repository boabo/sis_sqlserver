CREATE OR REPLACE FUNCTION sqlserver.f_replicar_correoboa (
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

    /*if(TG_OP = 'INSERT')then
    	v_consulta =  'exec Ende_Correo '''||new.email_empresa||''', '||new.id_funcionario||';';
    els*/
    if (new.email_empresa is not null or new.email_empresa !='')then
      if(TG_OP ='UPDATE' )then
          v_consulta =  'exec Ende_Correo '''||new.email_empresa||''', '||new.id_funcionario||';';
      end if;


      select tu.id_usuario
      into v_id_usuario
      from segu.tusuario tu
      where tu.cuenta = (string_to_array(current_user,'_'))[2];

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
    end if;

RETURN NULL;

END;
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY INVOKER
COST 100;