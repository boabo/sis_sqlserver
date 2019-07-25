CREATE OR REPLACE FUNCTION sqlserver.ft_migracion_sel (
  p_administrador integer,
  p_id_usuario integer,
  p_tabla varchar,
  p_transaccion varchar
)
RETURNS varchar AS
$body$
/**************************************************************************
 SISTEMA:		Sistema Sqlserver
 FUNCION: 		sqlserver.ft_migracion_sel
 DESCRIPCION:   Funcion que devuelve conjuntos de registros de las consultas relacionadas con la tabla 'sqlserver.tmigracion'
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

	v_consulta    		varchar;
	v_parametros  		record;
	v_nombre_funcion   	text;
	v_resp				varchar;

    v_cadena_cnx		varchar;
    v_rec_persona		record;
    v_res_cone			varchar;
    v_host				varchar;
    v_puerto			varchar;
    v_dbname			varchar;
    p_user				varchar;
    v_password			varchar;

    v_archivos 			varchar[] ;
    v_archivo			varchar;
    v_index				integer;
    v_pos				integer;
    v_nombre			varchar;
    v_ext				varchar;
    v_id_tabla			integer;
BEGIN

	v_nombre_funcion = 'sqlserver.ft_migracion_sel';
    v_parametros = pxp.f_get_record(p_tabla);

	/*********************************
 	#TRANSACCION:  'SQL_MIGRA_SEL'
 	#DESCRIPCION:	Consulta de datos
 	#AUTOR:		franklin.espinoza
 	#FECHA:		20-09-2017 20:55:18
	***********************************/

	if(p_transaccion='SQL_MIGRA_SEL')then

    	begin
    		--Sentencia de la consulta
			v_consulta:='select
						migra.id_migracion,
                        migra.cadena_db,
						migra.operacion,
						migra.estado,
						migra.respuesta,
						migra.estado_reg,
						migra.consulta,
						migra.id_usuario_ai,
						migra.id_usuario_reg,
						migra.usuario_ai,
						migra.fecha_reg,
						migra.id_usuario_mod,
						migra.fecha_mod,
						usu1.cuenta as usr_reg,
						usu2.cuenta as usr_mod
						from sqlserver.tmigracion migra
						inner join segu.tusuario usu1 on usu1.id_usuario = migra.id_usuario_reg
						left join segu.tusuario usu2 on usu2.id_usuario = migra.id_usuario_mod
				        where  ';

			--Definicion de la respuesta
			v_consulta:=v_consulta||v_parametros.filtro;
			v_consulta:=v_consulta||' order by ' ||v_parametros.ordenacion|| ' ' || v_parametros.dir_ordenacion || ' limit ' || v_parametros.cantidad || ' offset ' || v_parametros.puntero;
			raise notice 'v_consulta: %',v_consulta;
			--Devuelve la respuesta
			return v_consulta;

		end;

	/*********************************
 	#TRANSACCION:  'SQL_MIGRA_CONT'
 	#DESCRIPCION:	Conteo de registros
 	#AUTOR:		franklin.espinoza
 	#FECHA:		20-09-2017 20:55:18
	***********************************/

	elsif(p_transaccion='SQL_MIGRA_CONT')then

		begin
			--Sentencia de la consulta de conteo de registros
			v_consulta:='select count(migra.id_migracion)
					    from sqlserver.tmigracion migra
					    inner join segu.tusuario usu1 on usu1.id_usuario = migra.id_usuario_reg
						left join segu.tusuario usu2 on usu2.id_usuario = migra.id_usuario_mod
					    where ';

			--Definicion de la respuesta
			v_consulta:=v_consulta||v_parametros.filtro;

			--Devuelve la respuesta
			return v_consulta;

		end;
    /*********************************
 	#TRANSACCION:  'SQL_MIGRA_PEND_SEL'
 	#DESCRIPCION:	Consulta de datos pendientes
 	#AUTOR:		franklin.espinoza
 	#FECHA:		20-09-2017 20:55:18
	***********************************/

	elsif(p_transaccion='SQL_MIGRA_PEND_SEL')then

    	begin
    		--Sentencia de la consulta
			v_consulta:='select
						migra.id_migracion,
                        migra.cadena_db,
						migra.operacion,
						migra.estado,
						migra.respuesta,
                        migra.consulta,
						migra.estado_reg,

                        migra.id_usuario_ai,
						migra.id_usuario_reg,
						migra.usuario_ai,
						migra.fecha_reg,
						migra.id_usuario_mod,
						migra.fecha_mod,
						usu1.cuenta as usr_reg,
						usu2.cuenta as usr_mod,
                        migra.tipo_conexion
						from sqlserver.tmigracion migra
						left join segu.tusuario usu1 on usu1.id_usuario = migra.id_usuario_reg
						left join segu.tusuario usu2 on usu2.id_usuario = migra.id_usuario_mod
				        where  migra.estado = ''pendiente'';';


			raise notice 'v_consulta: %', v_consulta;
			--Devuelve la respuesta
			return v_consulta;

		end;

    /*********************************
 	#TRANSACCION:  'SQL_MIGRA_IMG_SEL'
 	#DESCRIPCION:	Consulta de imagenes
 	#AUTOR:		franklin.espinoza
 	#FECHA:		20-09-2017 20:55:18
	***********************************/

	elsif(p_transaccion='SQL_MIGRA_IMG_SEL')then

    	begin

        	/*v_host='10.150.0.21';--'192.168.100.30';
            v_puerto='5432';
            v_dbname='dbkerp';--dbendesis
            p_user='franklin';
            v_password='franklin';--dblink_pxp

            v_cadena_cnx =  'hostaddr='||v_host||' port='||v_puerto||' dbname='||v_dbname||' user='||p_user||' password='||v_password;
			v_resp =  dblink_connect(v_cadena_cnx);
            raise exception '_v_resp: %',v_resp;

            IF(v_resp!='OK') THEN
               --modificar bandera de fallo
               raise exception 'FALLA CONEXION A LA BASE DE DATOS CON DBLINK';
            ELSE
             	v_consulta = 'select tp.id_persona, tp.foto_persona from sss.tsg_persona tp where tp.id_persona between 8412 and 8416'; --v_consulta = 'select * from sss.tsg_persona limit 1';
             	SELECT * INTO
                v_rec_persona
                FROM dblink(v_consulta,true) AS ( xx varchar);
              	v_res_cone=(select dblink_disconnect());
            END IF;*/

            --raise exception 'v_rec_persona: %',v_rec_persona;
    		--Sentencia de la consulta
			/*v_consulta:='select
            				id_cc, foto
            			 from rec.trelacion_cc_auxiliar trc
                         where id_cc = 830';


			--Devuelve la respuesta
			return v_consulta;*/
			/*v_consulta:='select  tp.id_persona, tp.foto, tp.extension
			 			 from segu.tpersona tp
						 where tp.id_persona = 8576';*/--(tp.id_persona between 8556 and 8560) and tp.foto is not null order by id_persona asc
            /*v_archivos = '{"8412.jpeg", "8413.jpeg" , "8415.jpeg" , "8416.jpeg" , "8417.jpeg" , "8418.jpeg" , "8419.jpeg" , "8420.jpeg" ,
              "8421.jpeg" , "8423.jpeg", "8424.jpeg" , "8425.jpeg" , "8426.jpeg" , "8428.jpeg" , "8429.jpeg" , "8430.jpeg" ,
              "8431.jpeg" , "8434.jpeg" , "8436.jpeg" , "8437.jpeg" , "8439.jpeg" , "8443.jpeg" , "8445.jpeg" , "8446.jpeg" ,
              "8448.jpeg" , "8450.jpeg" , "8451.jpeg" , "8452.jpeg" , "8453.jpeg" , "8454.jpeg" , "8455.jpeg" , "8463.jpeg",
              "8466.jpeg", "8467.jpeg", "8468.jpeg", "8471.jpeg", "8472.jpeg", "8473.jpeg", "8474.jpeg", "8475.jpeg", "8476.jpeg",
              "8479.jpeg", "8480.jpeg", "8482.jpeg", "8483.jpeg", "8484.jpeg", "8485.jpeg", "8486.jpeg", "8487.jpeg", "8488.jpeg",
              "8491.jpeg", "8492.jpeg", "8493.jpeg", "8494.jpeg", "8496.jpeg", "8497.jpeg", "8499.jpeg", "8501.jpeg", "8505.jpeg",
              "8506.jpeg", "8508.jpeg", "8509.jpeg", "8510.jpeg", "8511.jpeg", "8513.jpeg", "8514.jpeg",
              "8515.jpeg", "8516.jpeg", "8517.jpeg", "8518.jpeg", "8519.jpeg", "8520.jpeg",
              "8521.jpeg", "8522.jpeg", "8523.jpeg", "8524.jpeg", "8526.jpeg", "8528.jpeg",
              "8529.jpeg", "8531.jpeg", "8532.jpeg", "8533.jpeg", "8534.jpeg", "8535.jpeg",
              "8537.jpeg", "8538.jpeg", "8539.jpeg", "8541.jpeg", "8542.jpeg", "8543.jpeg",
              "8544.jpeg", "8545.jpeg", "8546.jpeg", "8547.jpeg", "8548.jpeg", "8549.jpeg",
              "8550.jpeg", "8551.jpeg", "8552.jpeg", "8553.jpeg", "8554.jpeg", "8555.jpeg",
              "8556.jpeg", "8557.jpeg", "8558.jpeg", "8559.jpeg", "8560.jpeg", "8563.jpeg",
              "8564.jpeg", "8565.jpeg", "8568.jpeg", "8570.jpeg", "8571.jpeg", "8574.jpeg",
              "8578.jpeg", "8579.jpeg"}';*/
            /*for v_index in 1..array_length(v_archivos,1)loop
            	v_archivo = v_archivos[v_index];
                v_pos = position('.' in v_archivo);
                v_nombre = substr(v_archivo,0,v_pos);
                v_ext	= substr(v_archivo,v_pos+1);

                select tf.id_funcionario
                into v_id_tabla
                from orga.tfuncionario tf
                where tf.id_persona = v_nombre::integer;

                --raise exception 'v_id_tabla: %',v_nombre;
                insert into param.tarchivo(
                    estado_reg,
                    folder,
                    extension,
                    id_tabla,
                    nombre_archivo,
                    id_tipo_archivo,
                    fecha_reg,
                    usuario_ai,
                    id_usuario_reg,
                    id_usuario_ai,
                    id_usuario_mod,
                    fecha_mod,
                    nombre_descriptivo
                    ) values(
                    'activo',
                    './../../../uploaded_files/sis_parametros/Archivo/',
                    v_ext,
                    v_id_tabla,
                    v_nombre,
                    10,
                    now(),
                    null,
                    612,
                    null,
                    null,
                    null,
                    'Fotografia Personal'
                  );

            end loop;*/
            v_consulta:='select  tp.id_persona,/*tp.foto,*/ tp.numero  --tf.id_funcionario, tp.numero
			 			 from segu.tpersona tp
                         --inner join orga.tfuncionario tf on tf.id_persona = tp.id_persona
                         --where tf.id_funcionario is not null and tf.id_persona is not null and tp.id_persona >=8412
                         where (tf.id_persona between 9675 and 9693) and tf.id_persona is not null
                         order by tp.id_persona ;
						 ';

            return v_consulta;
		end;
    /*********************************
 	#TRANSACCION:  'SQL_MIGRA_IMG_SEL'
 	#DESCRIPCION:	Consulta de imagenes
 	#AUTOR:		franklin.espinoza
 	#FECHA:		20-09-2017 20:55:18
	***********************************/

	elsif(p_transaccion='SQL_MIGRA_FOTO_SEL')then

    	begin

        	v_consulta = 'select (''http://192.168.11.82/kerp_capacitacion''||substr(tar.folder,11)||tar.nombre_archivo||''.''||tar.extension)::varchar
					  	  from orga.tfuncionario tf
					  	  inner join param.tarchivo tar on tar.id_tabla = tf.id_funcionario and tar.id_tipo_archivo = 10
					  	  where tf.id_funcionario = '||v_parametros.id_funcionario||' and tar.estado_reg = ''activo''';
        	return v_consulta;
        end;
	else

		raise exception 'Transaccion inexistente';

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