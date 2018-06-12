CREATE OR REPLACE FUNCTION sqlserver.f_migrar_tpersona (
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
  v_expedicion		varchar;
  v_record			record;
BEGIN

    v_cadena_db = pxp.f_get_variable_global('cadena_db_sql_2');



        if(TG_OP = 'UPDATE')then

            select tf.id_funcionario, count(tf.id_funcionario) as bandera
            into v_record
            from orga.tfuncionario tf
            where tf.id_persona = NEW.id_persona
            group by tf.id_funcionario;

        if(v_record.bandera is not null)then

              v_consulta =  'exec Ende_ModificarEmpleado ''UPD'', '''||coalesce(NEW.nombre,'')||''', '''||
              coalesce(NEW.apellido_paterno,'')||''', '''||coalesce(NEW.apellido_materno,'')||''', '''||
              coalesce(NEW.ci,'')||''', '''||coalesce(NEW.expedicion,'')||''', '''||NEW.direccion||''', '||v_record.id_funcionario||', '''||
              coalesce(NEW.telefono1,'')||''', '''||coalesce(NEW.telefono2,'')||''', '''||coalesce(NEW.celular1,'')||''', '''||
              coalesce(NEW.celular2,'')||''', '''||coalesce(NEW.correo,'')||''';';



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
        end if;
        end if;





RETURN NULL;

END;
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY INVOKER
COST 100;