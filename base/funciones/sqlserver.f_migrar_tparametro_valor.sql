CREATE OR REPLACE FUNCTION sqlserver.f_migrar_tparametro_valor (
)
RETURNS trigger AS
$body$
DECLARE

  v_consulta 		text;
  v_id_usuario 		integer;
  v_cadena_db		varchar;
  v_gestion			integer;
  v_id_parametro_valor	integer;
BEGIN



    if(new.codigo = 'SALMIN')then

      v_cadena_db = pxp.f_get_variable_global('cadena_db_sql_2');

      select tu.id_usuario
      into v_id_usuario
      from segu.tusuario tu
      where tu.cuenta = (string_to_array(current_user,'_'))[3];

      v_gestion = extract(year from new.fecha_ini);

      if(TG_OP = 'INSERT')then

          /*v_consulta =  'exec Ende_SalarioMinimo ''INS'', '||new.id_parametro_valor||', '||
                        v_gestion ||', '||new.valor||', '''||new.estado_reg||''', '''||
                        new.fecha_ini||''';';*/

      elsif(TG_OP ='UPDATE' )then
      	if(new.codigo = 'SALMIN')then
        	--raise exception 'new.fecha_ini: %', new.fecha_ini;
          select pv.id_parametro_valor
          into v_id_parametro_valor
          from plani.tparametro_valor pv
          order by pv.id_parametro_valor desc limit 1;

          v_consulta =  'exec Ende_SalarioMinimo ''INS'', '||v_id_parametro_valor||', '||
                          v_gestion ||', '||new.valor||', '''||new.estado_reg||''', '''||
                          new.fecha_ini||''';';
        end if;
              /*if(new.estado_reg = 'inactivo')then
                  v_consulta =  'exec Ende_SalarioMinimo ''DEL'', '||old.id_parametro_valor||', null, null, null, null;';
              else
                  v_consulta =  'exec Ende_SalarioMinimo ''UPD'', '||new.id_parametro_valor||', '||
                        	 	v_gestion ||', '||new.valor||', '''||new.estado_reg||''', '''||
                        	 	new.fecha_ini||''';';
              end if;   	*/
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
    end if;

RETURN NULL;

END;
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY INVOKER
COST 100;