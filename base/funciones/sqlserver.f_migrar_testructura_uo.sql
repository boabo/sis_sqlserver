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
    where tu.cuenta = (string_to_array(current_user,'_'))[3];





    if(TG_OP = 'INSERT')then
		select tu.id_uo, tu.nombre_unidad, tu.nombre_cargo, tu.codigo, tu.descripcion, tu.correspondencia,
    	   tu.id_nivel_organizacional, tu.estado_reg
    	into v_record_uo
    	from orga.tuo tu
    	where tu.id_uo = new.id_uo_hijo;
        --raise exception 'v_record_uo: %',v_record_uo;
    	v_consulta =  'exec Ende_Organigrama ''INS'', '||v_record_uo.id_uo||', '||
        			  new.id_uo_padre||', '''||v_record_uo.nombre_unidad||''', '''||v_record_uo.descripcion||''', '''||
			          v_record_uo.codigo||''', '''||v_record_uo.correspondencia||''', null, '||extract(year from current_date)||',  '||v_record_uo.id_nivel_organizacional||
                      ', '''||v_record_uo.estado_reg||''';';

    elsif(TG_OP ='UPDATE' )then
    --raise exception 'TG_OP : %',TG_OP;
    	    if(new.estado_reg = 'inactivo')then
            	v_consulta =  'exec Ende_Organigrama ''DEL'', '||old.id_uo||', null, null, null, null, null, null, null, null, null;';
            else
            	select tu.id_uo_padre
                into v_id_padre
                from orga.testructura_uo tu
                where tu.id_uo_hijo = new.id_uo;

    			v_consulta =  'exec Ende_Organigrama ''UPD'', '||new.id_uo||', '||
        			  v_id_padre||', '''||new.nombre_unidad||''', '''||new.descripcion||''', '''||
			          new.codigo||''', '''||new.correspondencia||''', null, null,  '||new.id_nivel_organizacional||
                      ', '''||new.estado_reg||''';';
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