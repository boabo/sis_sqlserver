CREATE OR REPLACE FUNCTION sqlserver.f_migrar_tcomunicacion (
)
RETURNS trigger AS
$body$
DECLARE

  v_consulta 		text;
  v_id_usuario 		integer;
  v_cadena_db		varchar;
  r_persona		record;
BEGIN

      v_cadena_db = pxp.f_get_variable_global('cadena_db_sql_2');

      select tu.id_usuario
      into v_id_usuario
      from segu.tusuario tu
      where tu.cuenta = (string_to_array(current_user,'_'))[3];

      if(TG_OP = 'INSERT')then

      	  select tp.correo, tp.telefono1, tp.telefono2, tp.celular1, tp.celular2
          into r_persona
      	  from orga.tfuncionario tf
          inner join segu.tpersona tp on tp.id_persona = tf.id_persona
      	  where tf.id_funcionario = new.id_funcionario;

          v_consulta =  'exec Ende_Comunicacion ''INS'', ''activo'', '||new.id_funcionario||', '''||
          				r_persona.telefono1||''', '''||r_persona.celular1||''', '''||r_persona.correo||''', '''||
                        new.email_empresa||''', '''||new.telefono_ofi||''';';

      elsif(TG_OP = 'UPDATE' )then
      	  if(TG_TABLE_NAME = 'tfuncionario')then
          	select tp.correo, tp.telefono1, tp.telefono2, tp.celular1, tp.celular2
            into r_persona
            from orga.tfuncionario tf
            inner join segu.tpersona tp on tp.id_persona = tf.id_persona
            where tf.id_funcionario = new.id_funcionario;
            if (r_persona IS NOT NULL)then
            	if new.estado_reg = 'inactivo' then
                    v_consulta = 'exec Ende_Comunicacion ''UPD'', ''inactivo'', '||new.id_funcionario||', '''||r_persona.telefono1||''', '''||
                                 r_persona.celular1||''', '''||r_persona.correo||''', null, null;';
                else
                	v_consulta = 'exec Ende_Comunicacion ''UPD'', ''activo'', '||new.id_funcionario||', '''||r_persona.telefono1||''', '''||
                                 r_persona.celular1||''', '''||r_persona.correo||''', '''||
                                 new.email_empresa||''', '''||new.telefono_ofi||''';';
                end if;
            end if;
          elsif(TG_TABLE_NAME = 'tpersona')then

            select tf.id_funcionario, tf.telefono_ofi, tf.email_empresa
            into r_persona
            from  segu.tpersona tp
            inner join orga.tfuncionario tf on tf.id_persona = tp.id_persona
            where tp.id_persona = new.id_persona;
            if (r_persona IS NOT NULL)then
              v_consulta = 'exec Ende_Comunicacion ''DEL'', ''inactivo'', '||r_persona.id_funcionario||', null, null, null, null, null;';
            end if;
          end if;

      elsif(TG_OP ='DELETE')then
          --RAISE EXCEPTION 'operacion %', TG_OP;
      	  select tf.id_funcionario, tf.telefono_ofi, tf.email_empresa
          into r_persona
          from  segu.tpersona tp
          inner join orga.tfuncionario tf on tf.id_persona = tp.id_persona
          where tp.id_persona = old.id_persona;
          if (r_persona IS NOT NULL)then
              v_consulta = 'exec Ende_Comunicacion ''DEL'', ''inactivo'', '||r_persona.id_funcionario||', '''||old.telefono1||''', '''||
              	           old.celular1||''', '''||old.correo||''', '''||
                           r_persona.email_empresa||''', '''||r_persona.telefono_ofi||''';';
            end if;
      end if;
      if (v_consulta is not null) then
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