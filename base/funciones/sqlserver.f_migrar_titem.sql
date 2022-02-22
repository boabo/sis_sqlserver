CREATE OR REPLACE FUNCTION sqlserver.f_migrar_titem (
)
RETURNS trigger AS
$body$
DECLARE

  v_consulta 			text;
  v_id_usuario 			integer;
  v_cadena_db			varchar;
  v_id_funcionario  	integer;
  v_index 				integer;
  v_cadena				varchar[];
  v_codigo				varchar = '';
  v_nom_lugar			varchar;
  v_id_temporal_cargo 	integer;
BEGIN
	--raise exception 'Item';
    v_cadena_db = pxp.f_get_variable_global('cadena_db_sql_2');

    select tu.id_usuario
    into v_id_usuario
    from segu.tusuario tu
    where tu.cuenta = (string_to_array(current_user,'_'))[2];

	v_id_usuario = coalesce(v_id_usuario, 1);

	select uo.codigo
    into v_codigo
    from orga.tuo uo
    where uo.id_uo = new.id_uo;

    if v_codigo is null /*or v_codigo = ''*/ then
      v_cadena = string_to_array(trim(new.nombre), '');
      for v_index in 1..array_length(v_cadena,1) loop
          if (substring(v_cadena[v_index],1,1) like upper(substring(v_cadena[v_index],1,1))) then
              v_codigo = v_codigo || substring(v_cadena[v_index],1,1);
          end if;
      end loop;
    end if;


    select tl.nombre
    into v_nom_lugar
    from param.tlugar tl
    where tl.id_lugar = new.id_lugar;

    select tt.id_temporal_cargo
    into v_id_temporal_cargo
    from orga.ttemporal_cargo tt
    where tt.nombre = new.nombre;



    if(TG_OP = 'INSERT')then
    	v_consulta =  'exec Ende_Item "INS", '||new.id_cargo||', '||new.id_uo||', '||
        			  new.id_tipo_contrato||', "'||new.codigo||'", '||new.id_temporal_cargo||', '||
                      new.id_escala_salarial||', "'||coalesce (v_codigo,'')||'", '||new.id_lugar||', "'||v_nom_lugar||'", "'||coalesce(new.fecha_ini::varchar,'')||'", "'||coalesce(new.fecha_fin::varchar,'')||'", "'||new.estado_reg||'";';

    elsif(TG_OP ='UPDATE' )then
    	if new.estado_reg = 'inactivo' then
        	v_consulta =  'exec Ende_Item "DEL", '||new.id_cargo||', null, null, null, null, null, null, null, null, null, "'||coalesce(new.fecha_fin::varchar,'')||'", "'||new.estado_reg||'";';
        else
        	if old.id_temporal_cargo != new.id_temporal_cargo or old.id_escala_salarial != new.id_escala_salarial or old.codigo != new.codigo or new.estado_reg = 'activo' then
              v_consulta =  'exec Ende_Item "UPD", '||new.id_cargo||', '||new.id_uo||', '||
                            new.id_tipo_contrato||', "'||new.codigo||'", '||new.id_temporal_cargo||','||
                            new.id_escala_salarial||', "'||coalesce (v_codigo,'')||'", '||new.id_lugar||', "'||v_nom_lugar||'", "'||coalesce(new.fecha_ini::varchar,'')||'", "'||coalesce(new.fecha_fin::varchar,'')||'", "'||new.estado_reg||'";';
    		end if;
        end if;
	end if;

	INSERT INTO migra.tregistro_modificado(
    	id_usuario_reg,
        id_tabla,
        tabla,
        operacion
    )VALUES (
        v_id_usuario,
        new.id_cargo,
        'tcargo',
        TG_OP::varchar
    );

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
          'tcargo'
      );
	else
    	INSERT INTO migra.tregistro_falla
        (	id_usuario_reg,
            id_tabla,
            tabla,
            operacion
        )
        VALUES (
            v_id_usuario,
            new.id_cargo,
            'tcargo',
            TG_OP::varchar
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

ALTER FUNCTION sqlserver.f_migrar_titem ()
  OWNER TO postgres;