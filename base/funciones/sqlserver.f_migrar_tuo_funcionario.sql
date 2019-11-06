CREATE OR REPLACE FUNCTION sqlserver.f_migrar_tuo_funcionario (
)
RETURNS trigger AS
$body$
DECLARE

  v_consulta 		text;
  v_id_usuario 		integer;
  v_cadena_db		varchar;
  v_id_funcionario  integer;
  v_tipo            varchar;
  v_record_emp      record;
BEGIN

    v_cadena_db = pxp.f_get_variable_global('cadena_db_sql_2');

    select tu.id_usuario
    into v_id_usuario
    from segu.tusuario tu
    where tu.cuenta = (string_to_array(current_user,'_'))[2];

    SELECT tf.id_funcionario
    INTO v_id_funcionario
    FROM segu.tusuario tu
    INNER JOIN orga.tfuncionario tf on tf.id_persona = tu.id_persona
    WHERE tu.id_usuario = v_id_usuario;
	/*RAISE EXCEPTION 'v_id_funcionario: %, %, %, %,%, %, %, %', new.id_uo_funcionario,new.id_funcionario,
        			  new.id_cargo,new.nro_documento_asignacion,new.fecha_asignacion,new.fecha_finalizacion,v_id_funcionario,new.fecha_documento_asignacion;*/
    v_tipo = new.tipo;
    if(TG_OP = 'INSERT')then
      if v_tipo != 'funcional' then
        v_consulta =  'exec Ende_HistorialCargo ''INS'', '||new.id_uo_funcionario||', '||new.id_funcionario||', '||
                  new.id_cargo||', '''||new.nro_documento_asignacion||''', '''||coalesce(new.fecha_asignacion::varchar,'')||''', '''||coalesce(new.fecha_finalizacion::varchar,'')||''', '||
                        v_id_funcionario||', '''||coalesce(new.fecha_documento_asignacion::varchar,'')||''', ''activo'';';
      end if;
    elsif(TG_OP ='UPDATE' )then
      select tf.id_biometrico, tf.codigo, tf.id_persona, tf.id_funcionario, tf.estado_reg, tf.fecha_ingreso, tf.email_empresa, tc.id_oficina, tuo.tipo
      into v_record_emp
      from orga.tuo_funcionario tuo
      inner join orga.tfuncionario tf  on tf.id_funcionario = tuo.id_funcionario
      inner join orga.tcargo tc on tc.id_cargo = tuo.id_cargo
      where tuo.id_uo_funcionario = new.id_uo_funcionario;
      v_tipo = v_record_emp.tipo;
      if v_tipo != 'funcional' then
        if new.estado_reg = 'inactivo' or new.estado_funcional = 'inactivo' then
          if new.estado_reg = 'inactivo'
            v_consulta =  'exec Ende_HistorialCargo "DEL", '||old.id_uo_funcionario||', null, null, null, null, null, null, null, null;';
          else
            v_consulta =  'exec Ende_HistorialCargo ''UPD'', '||new.id_uo_funcionario||', '||new.id_funcionario||', '||
                      new.id_cargo||', '''||new.nro_documento_asignacion||''', '''||old.fecha_asignacion||''', '''||
                      coalesce(new.fecha_finalizacion::varchar,'')||''', '||v_id_funcionario||', '''||coalesce(new.fecha_documento_asignacion::varchar,'')||''', ''inactivo'';';
          end if;
        else
          v_consulta =  'exec Ende_HistorialCargo ''UPD'', '||new.id_uo_funcionario||', '||new.id_funcionario||', '||
                      new.id_cargo||', '''||new.nro_documento_asignacion||''', '''||old.fecha_asignacion||''', '''||
                            coalesce(new.fecha_finalizacion::varchar,'')||''', '||v_id_funcionario||', '''||coalesce(new.fecha_documento_asignacion::varchar,'')||''', ''activo'';';
        end if;
      end if;
	  end if;
  if v_tipo != 'funcional' then
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