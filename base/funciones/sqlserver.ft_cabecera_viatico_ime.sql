CREATE OR REPLACE FUNCTION sqlserver.ft_cabecera_viatico_ime (
  p_administrador integer,
  p_id_usuario integer,
  p_tabla varchar,
  p_transaccion varchar
)
  RETURNS varchar AS
  $body$
/**************************************************************************
 SISTEMA:		Sistemas en Sql Server
 FUNCION: 		sqlserver.ft_cabecera_viatico_ime
 DESCRIPCION:   Funcion que gestiona las operaciones basicas (inserciones, modificaciones, eliminaciones de la tabla 'sqlserver.tcabecera_viatico'
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

	v_nro_requerimiento    	integer;
	v_parametros           	record;
	v_id_requerimiento     	integer;
	v_resp		            varchar;
	v_nombre_funcion        text;
	v_mensaje_error         text;
	v_id_cabecera_viatico	integer;
    v_id_usuario_reg		integer;
    v_registros				record;
    v_id_int_comprobante	integer;
    v_respu					varchar;
    v_conexion				varchar;
    v_resbool				boolean;
			    
BEGIN

    v_nombre_funcion = 'sqlserver.ft_cabecera_viatico_ime';
    v_parametros = pxp.f_get_record(p_tabla);

	/*********************************    
 	#TRANSACCION:  'SQL_CABVI_INS'
 	#DESCRIPCION:	Insercion de registros
 	#AUTOR:		jrivera	
 	#FECHA:		13-05-2016 21:04:18
	***********************************/

	if(p_transaccion='SQL_CABVI_INS')then
					
        begin
        	select u.id_usuario into v_id_usuario_reg
            from orga.tfuncionario f
            inner join segu.tusuario u on f.id_persona = u.id_persona
            where f.id_funcionario = v_parametros.id_funcionario;
            
            if (v_id_usuario_reg is null) then
            	raise exception 'No se puede generar el comprobante ya que el empleado no tiene un usuario en el ERP';
            end if;
            
            
        	--Sentencia de la insercion
        	insert into sqlserver.tcabecera_viatico(
			id_funcionario,				
			tipo_viatico,
			descripcion,
			acreedor,
			id_usuario_reg,
            fecha,
            nro_sigma
			
          	) values(
			v_parametros.id_funcionario,			
			v_parametros.tipo_viatico,
			v_parametros.descripcion,
			v_parametros.acreedor,
			v_id_usuario_reg,
            v_parametros.fecha,
            v_parametros.nro_sigma		
			
			)RETURNING id_cabecera_viatico into v_id_cabecera_viatico;
            
            for v_registros in (select * 
            					from json_populate_recordset(null::sqlserver.detalle_viatico,v_parametros.json_detalle::json))loop
            	INSERT INTO 
                  sqlserver.tdetalle_viatico
                (
                  id_usuario_reg,                  
                  id_cabecera_viatico,
                  tipo_viaje,
                  tipo_transaccion,
                  monto,
                  tipo_credito,
                  id_uo,
                  id_centro_costo,
                  codigo_auxiliar,
                  forma_pago,
                  acreedor,
                  glosa
                )
                VALUES (
                  v_id_usuario_reg,                  
                  v_id_cabecera_viatico,
                  v_registros.tipo_viaje,
                  v_registros.tipo_transaccion,
                  v_registros.monto,
                  v_registros.tipo_credito,
                  v_registros.id_uo,
                  v_registros.id_centro_costo,
                  v_registros.codigo_auxiliar,
                  v_registros.forma_pago,
                  v_registros.acreedor,
                  v_registros.glosa
                );
            end loop;
            
            v_id_int_comprobante =   conta.f_gen_comprobante (v_id_cabecera_viatico,'DEVPAGVIA',NULL,v_id_usuario_reg,NULL,NULL, NULL); 
			
                        
             
             
            update sqlserver.tcabecera_viatico set 
            	id_int_comprobante = v_id_int_comprobante
            where id_cabecera_viatico = v_id_cabecera_viatico;
            
			--Definicion de la respuesta
			v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Cabecera Viatico almacenado(a) con exito (id_cabecera_viatico'||v_id_cabecera_viatico||')'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_cabecera_viatico',v_id_cabecera_viatico::varchar);
            v_resp = pxp.f_agrega_clave(v_resp,'id_int_comprobante',v_id_int_comprobante::varchar);

            --Devuelve la respuesta
            return v_resp;

		end;

	/*********************************    
 	#TRANSACCION:  'SQL_CABVI_MOD'
 	#DESCRIPCION:	Modificacion de registros
 	#AUTOR:		jrivera	
 	#FECHA:		13-05-2016 21:04:18
	***********************************/

	elsif(p_transaccion='SQL_CABVIVALI_MOD')then

		begin
        	select u.id_usuario into v_id_usuario_reg
            from orga.tfuncionario f
            inner join segu.tusuario u on f.id_persona = u.id_persona
            where f.id_funcionario = v_parametros.id_funcionario;
            
            if (v_id_usuario_reg is null) then
            	raise exception 'No se puede generar el comprobante ya que el empleado no tiene un usuario en el ERP';
            end if;
            v_resbool = conta.f_igualar_cbte(v_parametros.id_int_comprobante,v_id_usuario_reg,false);
			v_respu = conta.f_validar_cbte(v_id_usuario_reg,NULL,NULL,v_parametros.id_int_comprobante,'si');
               
			--Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Comprobante validado'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_int_comprobante',v_parametros.id_int_comprobante::varchar);
               
            --Devuelve la respuesta
            return v_resp;
            
		end;

	/*********************************    
 	#TRANSACCION:  'SQL_CABVI_ELI'
 	#DESCRIPCION:	Eliminacion de registros
 	#AUTOR:		jrivera	
 	#FECHA:		13-05-2016 21:04:18
	***********************************/

	elsif(p_transaccion='SQL_CABVI_ELI')then

		begin
			--Sentencia de la eliminacion
			delete from sqlserver.tcabecera_viatico
            where id_cabecera_viatico=v_parametros.id_cabecera_viatico;
               
            --Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Cabecera Viatico eliminado(a)'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_cabecera_viatico',v_parametros.id_cabecera_viatico::varchar);
              
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