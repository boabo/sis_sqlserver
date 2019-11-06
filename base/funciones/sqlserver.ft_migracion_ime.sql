CREATE OR REPLACE FUNCTION sqlserver.ft_migracion_ime (
  p_administrador integer,
  p_id_usuario integer,
  p_tabla varchar,
  p_transaccion varchar
)
RETURNS varchar AS
$body$
/**************************************************************************
 SISTEMA:		Sistema Sqlserver
 FUNCION: 		sqlserver.ft_migracion_ime
 DESCRIPCION:   Funcion que gestiona las operaciones basicas (inserciones, modificaciones, eliminaciones de la tabla 'sqlserver.tmigracion'
 AUTOR: 		 (franklin.espinoza)
 FECHA:	        20-09-2017 20:55:18
 COMENTARIOS:
***************************************************************************
 HISTORIAL DE MODIFICACIONES:

 DESCRIPCION:
 AUTOR:
 FECHA:
***************************************************************************/

DECLARE

	v_nro_requerimiento    	integer;
	v_parametros           	record;
	v_id_requerimiento     	integer;
	v_resp		            varchar;
	v_nombre_funcion        text;
	v_mensaje_error         text;
	v_id_migracion			integer;
    v_ids_exitos			INTEGER[];
    v_ids_fallas			INTEGER[];
    v_tam_exito				integer;
    v_tam_falla				integer;
    v_index					integer;
	v_cad_resp				varchar = '';
    v_id_migra_descripcion	varchar[];
    v_error					varchar;
BEGIN

    v_nombre_funcion = 'sqlserver.ft_migracion_ime';
    v_parametros = pxp.f_get_record(p_tabla);

	/*********************************
 	#TRANSACCION:  'SQL_MIGRA_INS'
 	#DESCRIPCION:	Insercion de registros
 	#AUTOR:		franklin.espinoza
 	#FECHA:		20-09-2017 20:55:18
	***********************************/

	if(p_transaccion='SQL_MIGRA_INS')then

        begin
        	--Sentencia de la insercion
        	insert into sqlserver.tmigracion(
            cadena_db,
			operacion,
			estado,
			respuesta,
			estado_reg,
			id_presupuesto_destino,
			tipo_cuenta,
			id_presupuesto_origen,
			id_auxiliar_destino,
			consulta,
			id_usuario_ai,
			id_usuario_reg,
			usuario_ai,
			fecha_reg,
			id_usuario_mod,
			fecha_mod
          	) values(
            v_parametros.cadena_db,
			v_parametros.operacion,
			v_parametros.estado,
			v_parametros.respuesta,
			'activo',
			v_parametros.id_presupuesto_destino,
			v_parametros.tipo_cuenta,
			v_parametros.id_presupuesto_origen,
			v_parametros.id_auxiliar_destino,
			v_parametros.consulta,
			v_parametros._id_usuario_ai,
			p_id_usuario,
			v_parametros._nombre_usuario_ai,
			now(),
			null,
			null



			)RETURNING id_migracion into v_id_migracion;

			--Definicion de la respuesta
			v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Migracion almacenado(a) con exito (id_migracion'||v_id_migracion||')');
            v_resp = pxp.f_agrega_clave(v_resp,'id_migracion',v_id_migracion::varchar);

            --Devuelve la respuesta
            return v_resp;

		end;

	/*********************************
 	#TRANSACCION:  'SQL_MIGRA_MOD'
 	#DESCRIPCION:	Modificacion de registros
 	#AUTOR:		franklin.espinoza
 	#FECHA:		20-09-2017 20:55:18
	***********************************/

	elsif(p_transaccion='SQL_MIGRA_MOD')then

		begin
			--Sentencia de la modificacion
			update sqlserver.tmigracion set
      --cadena_db = v_parametros.cadena_db,
			operacion = v_parametros.operacion,
			estado = v_parametros.estado,
			respuesta = v_parametros.respuesta,
			consulta = v_parametros.consulta,
			--id_usuario_mod = p_id_usuario,
			--fecha_mod = now(),
			id_usuario_ai = v_parametros._id_usuario_ai,
			usuario_ai = v_parametros._nombre_usuario_ai,
      id_usuario_reg = v_parametros.id_usuario_reg
			where id_migracion=v_parametros.id_migracion;

			--Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Migracion modificado(a)');
            v_resp = pxp.f_agrega_clave(v_resp,'id_migracion',v_parametros.id_migracion::varchar);

            --Devuelve la respuesta
            return v_resp;

		end;

	/*********************************
 	#TRANSACCION:  'SQL_MIGRA_ELI'
 	#DESCRIPCION:	Eliminacion de registros
 	#AUTOR:		franklin.espinoza
 	#FECHA:		20-09-2017 20:55:18
	***********************************/

	elsif(p_transaccion='SQL_MIGRA_ELI')then

		begin
			--Sentencia de la eliminacion
			delete from sqlserver.tmigracion
            where id_migracion=v_parametros.id_migracion;

            --Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Migracion eliminado(a)');
            v_resp = pxp.f_agrega_clave(v_resp,'id_migracion',v_parametros.id_migracion::varchar);

            --Devuelve la respuesta
            return v_resp;

		end;
    /*********************************
 	#TRANSACCION:  'SQL_MIGRA_ESTADO_MOD'
 	#DESCRIPCION:	Modificacion de estado de los registros de migracion
 	#AUTOR:		franklin.espinoza
 	#FECHA:		20-09-2017 20:55:18
	***********************************/

	elsif(p_transaccion='SQL_MIGRA_ESTADO_MOD')then

		begin
        --raise exception 'llegados';
        	--Sentencia de la modificacion
            if(v_parametros.ids_exitos!='')then
            	v_ids_exitos = string_to_array(v_parametros.ids_exitos, ',');
                v_tam_exito = array_length(v_ids_exitos,1);

                for v_index IN 1..v_tam_exito loop
                  update sqlserver.tmigracion set
                    estado = 'exito',
                    respuesta = 'Registro migrado Exitosamente.',
                    id_usuario_mod = p_id_usuario,
                    fecha_mod = now()
                  where id_migracion = v_ids_exitos[v_index]::integer;
                  v_cad_resp = v_cad_resp||','||v_ids_exitos[v_index]::integer;
                end loop;
            end if;

            if(v_parametros.ids_fallas!='')then
            	v_ids_fallas = string_to_array(v_parametros.ids_fallas, ';');
                v_tam_falla = array_length(v_ids_fallas,1);

                for v_index IN 1..v_tam_falla loop
                  v_id_migra_descripcion = string_to_array(v_ids_fallas[v_index],',');
                  if(v_id_migra_descripcion[2] like 'connect%')then
                  	v_error = 'connect';
                  elsif(v_id_migra_descripcion[2] like 'select_db%')then
                  	v_error = 'select_db';
                  elsif(v_id_migra_descripcion[2] like 'query%')then
                  	v_error = 'query';
                  end if;
                  update sqlserver.tmigracion set
                    estado = case when v_error = 'connect' or v_error = 'select_db' then 'pendiente' else 'falla' end,
                    respuesta = v_id_migra_descripcion[2],
                    id_usuario_mod = p_id_usuario,
                    fecha_mod = now()
                  where id_migracion = v_id_migra_descripcion[1]::integer;
                  --v_cad_resp = v_cad_resp||','||v_ids_exitos[v_index]::varchar;
                end loop;
            end if;


			--Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Migracion modificado(a)');
            v_resp = pxp.f_agrega_clave(v_resp,'Exito','Exito'::varchar);

            --Devuelve la respuesta
            return v_resp;

		end;
	else

    	raise exception 'Transaccion inexistente: %',p_transaccion;

	end if;

EXCEPTION

	WHEN OTHERS THEN
		v_resp='';
		v_resp = pxp.f_agrega_clave(v_resp,'mensaje',SQLERRM);
		v_resp = pxp.f_agrega_clave(v_resp,'codigo_error',SQLSTATE);
		v_resp = pxp.f_agrega_clave(v_resp,'procedimientos',v_nombre_funcion);
		raise exception '%',v_resp;

END;
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY INVOKER
COST 100;