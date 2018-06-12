CREATE OR REPLACE FUNCTION sqlserver.f_migrar_toficina (
)
RETURNS trigger AS
$body$
DECLARE

  v_consulta 		text;
  v_id_usuario 		integer;
  v_cadena_db		varchar;
  v_nombre_lug		record;
BEGIN
	--raise exception 'Oficina';
    v_cadena_db = pxp.f_get_variable_global('cadena_db_sql_2');

    select tu.id_usuario
    into v_id_usuario
    from segu.tusuario tu
    where tu.cuenta = (string_to_array(current_user,'_'))[3];


    select tl.nombre, tl.id_lugar
    into v_nombre_lug
    from param.tlugar tl
    where tl.id_lugar = new.id_lugar;

    if(TG_OP = 'INSERT')then

    	v_consulta =  'exec Ende_Oficina ''INS'', '||new.id_oficina||', '''||
        			  v_nombre_lug.nombre||''', '''||new.nombre||''', '''||new.codigo||''', '''||
			          new.aeropuerto||''', null, null;';
    elsif(TG_OP ='UPDATE' )then
        if new.estado_reg = 'inactivo' then
            v_consulta =  'exec Ende_Oficina ''DEL'', '||old.id_oficina||', null, null,
                      null, null, null, null;';
        else
            v_consulta =  'exec Ende_Oficina ''UPD'', '||new.id_oficina||', '''||
                          v_nombre_lug.nombre||''', '''||new.nombre||''', '''||new.codigo||''', '''||
                          new.aeropuerto||''', null, null;';
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