CREATE OR REPLACE FUNCTION "sqlserver"."ft_cabecera_viatico_sel"(	
				p_administrador integer, p_id_usuario integer, p_tabla character varying, p_transaccion character varying)
RETURNS character varying AS
$BODY$
/**************************************************************************
 SISTEMA:		Sistemas en Sql Server
 FUNCION: 		sqlserver.ft_cabecera_viatico_sel
 DESCRIPCION:   Funcion que devuelve conjuntos de registros de las consultas relacionadas con la tabla 'sqlserver.tcabecera_viatico'
 AUTOR: 		 (jrivera)
 FECHA:	        13-05-2016 21:04:18
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
			    
BEGIN

	v_nombre_funcion = 'sqlserver.ft_cabecera_viatico_sel';
    v_parametros = pxp.f_get_record(p_tabla);

	/*********************************    
 	#TRANSACCION:  'SQL_CABVI_SEL'
 	#DESCRIPCION:	Consulta de datos
 	#AUTOR:		jrivera	
 	#FECHA:		13-05-2016 21:04:18
	***********************************/

	if(p_transaccion='SQL_CABVI_SEL')then
     				
    	begin
    		--Sentencia de la consulta
			v_consulta:='select
						cabvi.id_cabecera_viatico,
						cabvi.id_funcionario,
						cabvi.id_int_comprobante,
						cabvi.estado_reg,
						cabvi.tipo_viatico,
						cabvi.descripcion,
						cabvi.acreedor,
						cabvi.id_usuario_reg,
						cabvi.usuario_ai,
						cabvi.fecha_reg,
						cabvi.id_usuario_ai,
						cabvi.fecha_mod,
						cabvi.id_usuario_mod,
						usu1.cuenta as usr_reg,
						usu2.cuenta as usr_mod	
						from sqlserver.tcabecera_viatico cabvi
						inner join segu.tusuario usu1 on usu1.id_usuario = cabvi.id_usuario_reg
						left join segu.tusuario usu2 on usu2.id_usuario = cabvi.id_usuario_mod
				        where  ';
			
			--Definicion de la respuesta
			v_consulta:=v_consulta||v_parametros.filtro;
			v_consulta:=v_consulta||' order by ' ||v_parametros.ordenacion|| ' ' || v_parametros.dir_ordenacion || ' limit ' || v_parametros.cantidad || ' offset ' || v_parametros.puntero;

			--Devuelve la respuesta
			return v_consulta;
						
		end;

	/*********************************    
 	#TRANSACCION:  'SQL_CABVI_CONT'
 	#DESCRIPCION:	Conteo de registros
 	#AUTOR:		jrivera	
 	#FECHA:		13-05-2016 21:04:18
	***********************************/

	elsif(p_transaccion='SQL_CABVI_CONT')then

		begin
			--Sentencia de la consulta de conteo de registros
			v_consulta:='select count(id_cabecera_viatico)
					    from sqlserver.tcabecera_viatico cabvi
					    inner join segu.tusuario usu1 on usu1.id_usuario = cabvi.id_usuario_reg
						left join segu.tusuario usu2 on usu2.id_usuario = cabvi.id_usuario_mod
					    where ';
			
			--Definicion de la respuesta		    
			v_consulta:=v_consulta||v_parametros.filtro;

			--Devuelve la respuesta
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
$BODY$
LANGUAGE 'plpgsql' VOLATILE
COST 100;
ALTER FUNCTION "sqlserver"."ft_cabecera_viatico_sel"(integer, integer, character varying, character varying) OWNER TO postgres;
