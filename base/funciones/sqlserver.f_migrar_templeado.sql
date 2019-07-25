CREATE OR REPLACE FUNCTION sqlserver.f_migrar_templeado (
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
  v_band_func		integer;
BEGIN

    v_cadena_db = pxp.f_get_variable_global('cadena_db_sql_2');

    /*select tp.nombre, tp.apellido_paterno, tp.apellido_materno, tp.ci, tp.expedicion,
    tp.fecha_nacimiento, tp.genero, tp.nacionalidad, tp.direccion, tl.nombre as lugar_nac,
    tp.estado_reg, tp.telefono1, tp.telefono2, tp.celular1, tp.celular2,
    tp.correo, tp.correo2, tp.discapacitado, tp.carnet_discapacitado
    into v_record_emp
    from segu.tpersona tp
    left join param.tlugar tl on tl.id_lugar = tp.id_lugar
    where tp.id_persona = new.id_persona;*/

    if(TG_OP = 'INSERT')then

    	select count(tuo.id_uo_funcionario)
        into v_band_func
        from orga.tuo_funcionario tuo
        where tuo.id_funcionario = new.id_funcionario;
        --RAISE EXCEPTION 'FALLA: %, %', v_band_func, new.id_funcionario;
    	if(v_band_func = 1)	then
          --raise exception 'falla';
          select tf.id_biometrico, tf.codigo, tf.id_persona, tf.id_funcionario, tf.estado_reg, tf.fecha_ingreso, tf.email_empresa
          into v_record_emp
          from orga.tfuncionario tf
          where tf.id_funcionario = new.id_funcionario;

          select tp.nombre, tp.apellido_paterno, tp.apellido_materno, tp.ci, tp.expedicion,
          tp.fecha_nacimiento, tp.genero, tp.nacionalidad, tp.direccion, tl.nombre as lugar_nac,
          tp.estado_reg, tp.telefono1, tp.telefono2, tp.celular1,
          tp.celular2, tp.correo, tp.correo2, tp.discapacitado,
          tp.carnet_discapacitado
          into v_record_per
          from segu.tpersona tp
          left join param.tlugar tl on tl.id_lugar = tp.id_lugar
          where tp.id_persona = v_record_emp.id_persona;

          select tc.id_oficina
          into v_record_ofi
          from orga.tcargo tc
          where tc.id_cargo = new.id_cargo;

              v_consulta =  'exec EMPLEADO_INS '||coalesce(''''||v_record_emp.codigo||'''','''')||', '||coalesce(''''||v_record_per.nombre||'''','''')||', '
              ||coalesce(''''||v_record_per.apellido_paterno||'''','''')||', '||coalesce(''''||v_record_per.apellido_materno||'''','''')||', '
              ||coalesce(''''||v_record_per.ci||'''','''')||', '||coalesce(''''||v_record_per.expedicion||'''','''')||', '
              ||coalesce(''''||v_record_per.fecha_nacimiento::varchar||'''','''')||', '||coalesce(''''||v_record_per.genero||'''','''')||', '
              ||coalesce(''''||v_record_per.nacionalidad||'''','''')||', '''', '''', '||coalesce(''''||v_record_per.direccion::varchar||'''','''')||', '
              ||coalesce(''''||v_record_per.lugar_nac||'''','''')||', '''', '||coalesce(''''||v_record_emp.fecha_ingreso::varchar||'''','''')||', '''', '
              ||coalesce(''''||v_record_emp.estado_reg||'''','''')||', '||v_record_emp.id_funcionario||',0 , '
              ||coalesce(''''||v_record_per.telefono1||'''','''')||', '
              ||coalesce(''''||v_record_per.telefono2||'''','''')||', '||coalesce(''''||v_record_per.celular1||'''','''')||', '
              ||coalesce(''''||v_record_per.celular2||'''','''')||', '||coalesce(''''||v_record_per.correo||'''','''')||', '
              ||coalesce(''''||v_record_emp.email_empresa||'''','''')||', '''', '''', '''', '
              ||coalesce(''''||v_record_per.discapacitado||'''','''')||', '||coalesce(''''||v_record_per.carnet_discapacitado||'''','''')||', '
              ||v_record_ofi.id_oficina||', '||v_record_emp.id_biometrico||';';

    	end if;

    elsif(TG_OP ='UPDATE' )then
    	if(new.estado_reg = 'inactivo')then

    		v_consulta =  'exec Ende_Funcionario ''DEL'', '''||new.estado_reg||''' null, null, null,
            null, null, null, null, null, null, null, null, null, null, null, null, null, '|| old.id_funcionario||',
            0, null, null, null, null, null, null, null, null, null, null, null, null, null;';
        else

        	select tp.nombre, tp.apellido_paterno, tp.apellido_materno, tp.ci, tp.expedicion,
            tp.fecha_nacimiento, tp.genero, tp.nacionalidad, tp.direccion, tl.nombre as lugar_nac,
            tp.estado_reg, tp.telefono1, tp.telefono2, tp.celular1,
            tp.celular2, tp.correo, tp.correo2, tp.discapacitado,
            tp.carnet_discapacitado
            into v_record_emp
            from segu.tpersona tp
            left join param.tlugar tl on tl.id_lugar = tp.id_lugar
            where tp.id_persona = new.id_persona;

            v_consulta =  'exec Ende_ModificarEmpleado ''UPD'', '||coalesce(''''||v_record_emp.nombre||'''','null')||', '||
            coalesce(''''||v_record_emp.apellido_paterno||'''','null')||', '||coalesce(''''||v_record_emp.apellido_materno||'''','null')||', '||
            coalesce(''''||v_record_emp.ci||'''','null')||', '||coalesce(''''||v_record_emp.expedicion||'''','null')||', '||v_record_emp.fecha_nacimiento||
            ', '||coalesce(''''||v_record_emp.genero||'''','null')||', '||coalesce(''''||v_record_emp.nacionalidad||'''','null')||', '||
            coalesce(''''||v_record_emp.direccion||'''','null')||', '||coalesce(''''||v_record_emp.lugar_nac||'''','null')||', '||new.id_funcionario||', '''||
            coalesce(v_record_emp.discapacitado,'')||''', '||coalesce(''''||v_record_emp.carnet_discapacitado||'''','null')||';';

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