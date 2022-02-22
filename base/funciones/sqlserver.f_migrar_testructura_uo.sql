CREATE OR REPLACE FUNCTION sqlserver.f_migrar_testructura_uo (
)
RETURNS trigger AS
$body$
DECLARE

  v_consulta 		text;
  v_id_usuario 		integer;
  v_cadena_db		varchar;
  v_id_padre		integer;
  v_record_uo		record;
BEGIN
	--raise exception 'Organigrama';
    v_cadena_db = pxp.f_get_variable_global('cadena_db_sql_2');

    select tu.id_usuario
    into v_id_usuario
    from segu.tusuario tu
    where tu.cuenta = (string_to_array(current_user,'_'))[2];

	v_id_usuario = coalesce(v_id_usuario, 397);



    if(TG_OP = 'INSERT')then
		select tu.id_uo, tu.nombre_unidad, tu.nombre_cargo, tu.codigo, tu.descripcion, tu.correspondencia,
    	   tu.id_nivel_organizacional, tu.estado_reg
    	into v_record_uo
    	from orga.tuo tu
    	where tu.id_uo = new.id_uo_hijo;


        v_consulta =  	'exec Ende_Organigrama "INS", '||v_record_uo.id_uo||', '||
        				new.id_uo_padre||', "'||coalesce(v_record_uo.nombre_unidad,'')||'", "'||coalesce(v_record_uo.descripcion,'')||'", "'||
                        coalesce(v_record_uo.codigo,'')||'", "'||coalesce(v_record_uo.correspondencia,'')||'", null, '||extract(year from current_date)||',  '||v_record_uo.id_nivel_organizacional||
                        ', "'||v_record_uo.estado_reg||'", '||new.id_uo_padre_operativo||', "'||coalesce(new.fecha_ini::varchar,'')||'", "'||coalesce(new.fecha_fin::varchar,'')||'";';





    elsif(TG_OP ='UPDATE' )then
    	    if(new.estado_reg = 'inactivo')then
            	v_consulta =  'exec Ende_Organigrama "DEL", '||old.id_uo||', null, null, null, null, null, null, null, null, null, null, null, "'||coalesce(new.fecha_fin::varchar,'')||'";';
            else
            	select tu.id_uo_padre
                into v_id_padre
                from orga.testructura_uo tu
                where tu.id_uo_hijo = new.id_uo;
--raise 'a: %, b: %',new.id_uo, v_id_padre;
    			v_consulta =  'exec Ende_Organigrama "UPD", '||new.id_uo||', '||
        			  v_id_padre||', "'||coalesce(new.nombre_unidad,'')||'", "'||coalesce(new.descripcion,'')||'", "'||
			          coalesce(new.codigo,'')||'", "'||coalesce(new.correspondencia,'')||'", null, null,  '||new.id_nivel_organizacional||
                      ', "'||new.estado_reg||'", '||v_id_padre||', "'||coalesce(new.fecha_ini::varchar,'')||'", "'||coalesce(new.fecha_fin::varchar,'')||'";';
            end if;
	end if;

	/*INSERT INTO migra.tregistro_modificado(
    	id_usuario_reg,
        id_tabla,
        tabla,
        operacion
    )VALUES (
        v_id_usuario,
        new.id_uo,
        'testructura_uo',
        TG_OP::varchar
    );*/

	if v_consulta is not null then
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
          'testructura_uo'
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
            new.id_uo,
            'testructura_uo',
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

ALTER FUNCTION sqlserver.f_migrar_testructura_uo ()
  OWNER TO postgres;