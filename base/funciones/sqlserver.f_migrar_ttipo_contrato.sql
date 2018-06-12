CREATE OR REPLACE FUNCTION sqlserver.f_migrar_ttipo_contrato (
)
RETURNS trigger AS
$body$
DECLARE

  v_consulta 		text;
  v_id_usuario 		integer;
  v_cadena_db		varchar;

BEGIN

      v_cadena_db = pxp.f_get_variable_global('cadena_db_sql_2');

      select tu.id_usuario
      into v_id_usuario
      from segu.tusuario tu
      where tu.cuenta = (string_to_array(current_user,'_'))[3];
      if(TG_OP = 'INSERT')then
          v_consulta =  'exec Ende_TipoContrato ''INS'', '||new.id_tipo_contrato||', '||
                        new.nombre ||', '||new.codigo||';';
      elsif(TG_OP ='UPDATE' )then
      	if new.estado_reg = 'inactivo' then
        	v_consulta =  'exec Ende_TipoContrato ''DEL'', '||old.id_tipo_contrato||', null, null;';
        else
          v_consulta =  'exec Ende_TipoContrato ''UPD'', '||new.id_tipo_contrato||', '||
                        new.nombre ||', '||new.codigo||';';
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