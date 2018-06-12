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
    where tu.cuenta = (string_to_array(current_user,'_'))[3];


    v_cadena = string_to_array(trim(new.nombre), '');
    for v_index in 1..array_length(v_cadena,1) loop
    	if (substring(v_cadena[v_index],1,1) like upper(substring(v_cadena[v_index],1,1))) then
        	v_codigo = v_codigo || substring(v_cadena[v_index],1,1);
        end if;
    end loop;

    select tl.nombre
    into v_nom_lugar
    from param.tlugar tl
    where tl.id_lugar = new.id_lugar;

    select tt.id_temporal_cargo
    into v_id_temporal_cargo
    from orga.ttemporal_cargo tt
    where tt.nombre = new.nombre;

    if(TG_OP = 'INSERT')then
    	v_consulta =  'exec Ende_Item ''INS'', '||new.id_cargo||', '||new.id_uo||', '||
        			  new.id_tipo_contrato||', '''||new.codigo||''', '||v_id_temporal_cargo||', '||
                      new.id_escala_salarial||', '''||v_codigo||''', '||new.id_lugar||', '''||v_nom_lugar||''';';

    elsif(TG_OP ='UPDATE' )then
    	if new.estado_reg = 'inactivo' then
        	v_consulta =  'exec Ende_Item ''DEL'', '||new.id_cargo||', ''null'', ''null'', ''null'', ''null'',''null'', ''null'', ''null'', ''null'';';
        else
    		v_consulta =  'exec Ende_Item ''UPD'', '||new.id_cargo||', '||new.id_uo||', '||
        			  	  new.id_tipo_contrato||', '''||new.codigo||''', '||v_id_temporal_cargo||','||
                      	  new.id_escala_salarial||', '''||v_codigo||''', '||new.id_lugar||', '''||v_nom_lugar||''';';
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