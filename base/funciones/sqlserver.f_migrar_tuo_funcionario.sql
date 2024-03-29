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

  v_id_oficina      integer;
  v_codigo			    varchar;
  v_id_usr 				integer;
BEGIN

    v_cadena_db = pxp.f_get_variable_global('cadena_db_sql_2');

    select tu.id_usuario
    into v_id_usuario
    from segu.tusuario tu
    where tu.cuenta = (string_to_array(current_user,'_'))[2];

	v_id_usuario = coalesce(v_id_usuario, 397);

    SELECT tf.id_funcionario
    INTO v_id_funcionario
    FROM segu.tusuario tu
    INNER JOIN orga.tfuncionario tf on tf.id_persona = tu.id_persona
    WHERE tu.id_usuario = v_id_usuario;
	/*RAISE EXCEPTION 'v_id_funcionario: %, %, %, %,%, %, %, %', new.id_uo_funcionario,new.id_funcionario,
        			  new.id_cargo,new.nro_documento_asignacion,new.fecha_asignacion,new.fecha_finalizacion,v_id_funcionario,new.fecha_documento_asignacion;*/

    select tc.id_oficina, tl.codigo
    into v_id_oficina, v_codigo
    from orga.tcargo tc
    inner join param.tlugar tl on tl.id_lugar = tc.id_lugar
    where tc.id_cargo = new.id_cargo;

    v_tipo = new.tipo;

    if(TG_OP = 'INSERT')then
      if v_tipo != 'funcional' then
        v_consulta =  'exec Ende_HistorialCargo "INS", '||new.id_uo_funcionario||', '||new.id_funcionario||', '||
                  new.id_cargo||', "'||coalesce(new.nro_documento_asignacion::varchar,'')||'", "'||coalesce(new.fecha_asignacion::varchar,'')||'", "'||coalesce(new.fecha_finalizacion::varchar,'')||'", '||
                        v_id_funcionario||', "'||coalesce(new.fecha_documento_asignacion::varchar,'')||'", "activo", '||v_id_oficina||', "'||v_codigo||'";';
      end if;

	  --bvasquez, 05/08/2021, habilitacion de usuario por nuevo carga
	  select u.id_usuario into v_id_usr
      from orga.tfuncionario f
      inner join segu.tusuario u on u.id_persona = f.id_persona and u.estado_reg = 'activo'
      where f.id_funcionario = new.id_funcionario;

      if (v_id_usr is not null and v_tipo != 'funcional') then
         update segu.tusuario set
          fecha_caducidad=coalesce(new.fecha_finalizacion,'31/12/9999'::date),
          id_usuario_mod=1,
          fecha_mod=now()
         where id_usuario = v_id_usr;
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
        if new.estado_reg = 'inactivo' then
          /*if new.estado_reg = 'inactivo'
            v_consulta =  'exec Ende_HistorialCargo "DEL", '||old.id_uo_funcionario||', null, null, null, null, null, null, null, null;';
          else*/
            v_consulta =  'exec Ende_HistorialCargo "DEL", '||new.id_uo_funcionario||', '||new.id_funcionario||', '||
                      new.id_cargo||', "'||coalesce(new.nro_documento_asignacion::varchar,'')||'", "'||old.fecha_asignacion||'", "'||
                      coalesce(new.fecha_finalizacion::varchar,'')||'", '||v_id_funcionario||', "'||coalesce(new.fecha_documento_asignacion::varchar,'')||'", "inactivo", '||v_id_oficina||',  "'||v_codigo||'";';
          --end if;
        elsif new.estado_funcional = 'inactivo' or new.fecha_finalizacion <= current_date then
            v_consulta =  'exec Ende_HistorialCargo "UPD", '||new.id_uo_funcionario||', '||new.id_funcionario||', '||
                      new.id_cargo||', "'||coalesce(new.nro_documento_asignacion::varchar,'')||'", "'||old.fecha_asignacion||'", "'||
                            coalesce(new.fecha_finalizacion::varchar,'')||'", '||v_id_funcionario||', "'||coalesce(new.fecha_documento_asignacion::varchar,'')||'", "inactivo", '||v_id_oficina||', "'||v_codigo||'";';

        else
          v_consulta =  'exec Ende_HistorialCargo "UPD", '||new.id_uo_funcionario||', '||new.id_funcionario||', '||
                      new.id_cargo||', "'||coalesce(new.nro_documento_asignacion::varchar,'')||'", "'||old.fecha_asignacion||'", "'||
                            coalesce(new.fecha_finalizacion::varchar,'')||'", '||v_id_funcionario||', "'||coalesce(new.fecha_documento_asignacion::varchar,'')||'", "activo", '||v_id_oficina||', "'||v_codigo||'";';
        end if;

        if (new.fecha_finalizacion is not null) then
      	     update segu.tusuario set
              fecha_caducidad=new.fecha_finalizacion,
              id_usuario_mod=1,
              fecha_mod=now()
            where id_usuario in (select u.id_usuario
                                  from orga.tfuncionario f
                                  inner join segu.tusuario u on u.id_persona = f.id_persona and u.estado_reg = 'activo'
                                  where f.id_funcionario = new.id_funcionario
                                  );
        end if;
      end if;

	  end if;

    /*INSERT INTO migra.tregistro_modificado(
    	id_usuario_reg,
        id_tabla,
        tabla,
        operacion
    )VALUES (
        v_id_usuario,
        new.id_uo_funcionario,
        'tuo_funcionario',
        TG_OP::varchar
    );*/

    if v_tipo != 'funcional' and v_consulta is not null then
      INSERT INTO sqlserver.tmigracion
        (	id_usuario_reg,
          consulta,
            estado,
            respuesta,
            operacion,
            cadena_db,
            tabla
        )
        VALUES (
          v_id_usuario,
          v_consulta,
            'pendiente',
            null,
            TG_OP::varchar,
            v_cadena_db,
            'tuo_funcionario'
        );
    else
    	/*INSERT INTO migra.tregistro_falla
        (	id_usuario_reg,
            id_tabla,
            tabla,
            operacion
        )
        VALUES (
            v_id_usuario,
            new.id_uo_funcionario,
            'tuo_funcionario',
            TG_OP::varchar
        );*/

    end if;

RETURN NULL;

END;
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY INVOKER
COST 100;

ALTER FUNCTION sqlserver.f_migrar_tuo_funcionario ()
  OWNER TO postgres;