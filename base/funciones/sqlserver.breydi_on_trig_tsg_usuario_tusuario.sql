CREATE OR REPLACE FUNCTION sqlserver.breydi_on_trig_tsg_usuario_tusuario (
  v_operacion varchar,
  p_login varchar,
  p_id_usuario integer,
  p_id_nivel_seguridad integer,
  p_id_persona integer,
  p_autentificacion varchar,
  p_contrasenia varchar,
  p_estado_usuario varchar,
  p_estilo_usuario varchar,
  p_fecha_expiracion date,
  p_fecha_registro date
)
RETURNS text AS
$body$
						DECLARE

						BEGIN

						    if(v_operacion = 'INSERT') THEN

						          INSERT INTO

			sqlserver.tusuario(
						cuenta,
						id_usuario,
						id_persona,
						autentificacion,
						contrasena,
						estado_reg,
						estilo,
						fecha_caducidad,
						fecha_reg
						)
				VALUES (
						p_login,
						p_id_usuario,
						p_id_persona,
						p_autentificacion,
						p_contrasenia,
						p_estado_usuario,
						p_estilo_usuario,
						p_fecha_expiracion,
						p_fecha_registro);


							    ELSEIF  v_operacion = 'UPDATE' THEN


                                --chequear si ya existe el registro si no sacar un error
                              IF  not EXISTS(select 1
                                 --from SEGU.tusuario
                                 from sqlserver.tusuario
                                 where id_usuario=p_id_usuario) THEN

                                  raise exception 'No existe el registro que desea modificar';

                               END IF;





                                       UPDATE
						                  --SEGU.tusuario
						                  sqlserver.tusuario
						                SET
						  cuenta=p_login
						 ,id_persona=p_id_persona
						 ,autentificacion=p_autentificacion
						 ,contrasena=p_contrasenia
						 ,estado_reg=p_estado_usuario
						 ,estilo=p_estilo_usuario
						 ,fecha_caducidad=p_fecha_expiracion
						 ,fecha_reg=p_fecha_registro
						 WHERE id_usuario=p_id_usuario;


						       ELSEIF  v_operacion = 'DELETE' THEN

						          --chequear si ya existe el registro si no sacar un error
                                 IF  not EXISTS(select 1
                                   --from SEGU.tusuario
                                   from sqlserver.tusuario
                                    where id_usuario=p_id_usuario) THEN

                                     raise exception 'No existe el registro que desea eliminar';

                                 END IF;


                                 DELETE FROM
						              --SEGU.tusuario
						              sqlserver.tusuario
             						 WHERE id_usuario=p_id_usuario;


						       END IF;

						 return 'true';

						-- statements;
						--EXCEPTION
						--WHEN exception_name THEN
						--  statements;
						END;
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY INVOKER
COST 100;