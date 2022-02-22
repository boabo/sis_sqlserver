CREATE OR REPLACE FUNCTION sqlserver.f_migrar_templeado_upd (
)
RETURNS trigger AS
$body$
DECLARE

  v_record_emp 		record;
  v_record_per		record;
  v_record_ofi		record;
  v_consulta 		text;
  v_id_usuario 		integer;
  v_codigo_aux		varchar;
  v_nombre_aux		varchar;
  v_corriente		varchar;
  v_lugar_nac		varchar;
  v_cadena_db		varchar;
  v_band_func		integer=0;
BEGIN

    v_cadena_db = pxp.f_get_variable_global('cadena_db_sql_2');



	if(TG_OP ='UPDATE' )then

        	select tp.nombre, tp.apellido_paterno, tp.apellido_materno, tp.ci, tp.expedicion,
            tp.fecha_nacimiento, tp.genero, tp.nacionalidad, tp.direccion, tl.nombre as lugar_nac,
            tp.estado_reg, tp.telefono1, tp.telefono2, tp.celular1,
            tp.celular2, tp.correo, tp.correo2, tp.discapacitado,
            tp.carnet_discapacitado, tf.id_funcionario
            into v_record_emp
            from segu.tpersona tp
            inner join orga.tfuncionario tf on tf.id_persona = tp.id_persona
            left join param.tlugar tl on tl.id_lugar = tp.id_lugar
            where tp.id_persona = new.id_persona;

            if v_record_emp.id_funcionario is not null then
              v_consulta =  'exec Ende_ModificarEmpleado "UPD", '||coalesce('"'||v_record_emp.nombre||'"','null')||', '||
              coalesce('"'||v_record_emp.apellido_paterno||'"','null')||', '||coalesce('"'||v_record_emp.apellido_materno||'"','null')||', '||
              coalesce('"'||v_record_emp.ci||'"','null')||', '||coalesce('"'||v_record_emp.expedicion||'"','null')||', "'||v_record_emp.fecha_nacimiento||
              '", '||coalesce('"'||v_record_emp.genero||'"','null')||', '||coalesce('"'||v_record_emp.nacionalidad||'"','null')||', '||
              coalesce('"'||v_record_emp.direccion||'"','null')||', '||coalesce('"'||v_record_emp.lugar_nac||'"','null')||', '||v_record_emp.id_funcionario||', "'||
              coalesce(v_record_emp.discapacitado,'')||'", '||coalesce('"'||v_record_emp.carnet_discapacitado||'"','null')||';';
            end if;

	end if;

  if TG_OP = 'UPDATE' then
    if v_record_emp.id_funcionario is not null then
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
  end if;
RETURN NULL;

END;
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY INVOKER
COST 100;