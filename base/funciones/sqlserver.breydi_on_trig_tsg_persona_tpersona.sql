CREATE OR REPLACE FUNCTION sqlserver.breydi_on_trig_tsg_persona_tpersona (
  v_operacion varchar,
  p_id_persona integer,
  p_apellido_materno varchar,
  p_apellido_paterno varchar,
  p_celular1 varchar,
  p_celular2 varchar,
  p_doc_id varchar,
  p_email1 varchar,
  p_direccion varchar,
  p_fecha_ultima_modificacion timestamp,
  p_fecha_nacimiento date,
  p_fecha_registro timestamp,
  p_genero varchar,
  p_nombre varchar,
  p_telefono1 varchar,
  p_telefono2 varchar,
  p_email2 varchar,
  p_nacionalidad varchar,
  p_id_tipo_doc_identificacion integer,
  p_expedicion varchar,
  p_discapacitado varchar,
  p_lugar integer
)
RETURNS text AS
$body$
	DECLARE
    v_conexion  varchar;

	BEGIN

	    if(v_operacion = 'INSERT') THEN

				 INSERT INTO
				      sqlserver.t_breydi_persona(
						id_persona,
						apellido_materno,
						apellido_paterno,
						celular1,
						celular2,
						ci,
						correo,
						direccion,
						fecha_mod,
						fecha_nacimiento,
						fecha_reg,
						genero,
						nombre,
						telefono1,
						telefono2,
                        correo2,
                        nacionalidad,
                        id_tipo_doc_identificacion,
                        expedicion,
                        discapacitado,
                        id_lugar
                        )
				VALUES (
						p_id_persona,
						p_apellido_materno,
						p_apellido_paterno,
						p_celular1,
						p_celular2,
						p_doc_id,
						p_email1,
						p_direccion,
						p_fecha_ultima_modificacion,
						p_fecha_nacimiento,
						p_fecha_registro,
						p_genero,
						p_nombre,
						p_telefono1,
						p_telefono2,
                        p_email2,
                        p_nacionalidad,
                        p_id_tipo_doc_identificacion,
                        p_expedicion,
                        p_discapacitado,
                        p_lugar
                        );





			   ELSEIF  v_operacion = 'UPDATE' THEN


                         --chequear si ya existe el registro si no sacar un error
                              IF  not EXISTS(select 1
                                 from sqlserver.t_breydi_persona
                                 where id_persona=p_id_persona) THEN

                                  raise exception 'No existe el registro que desea modificar';

                               END IF;


                          UPDATE
						    sqlserver.t_breydi_persona
						  SET
                          apellido_materno=p_apellido_materno
						 ,apellido_paterno=p_apellido_paterno
						 ,celular1=p_celular1
						 ,celular2=p_celular2
						 ,ci=p_doc_id
						 ,correo=p_email1
						 ,direccion=p_direccion
						 ,fecha_mod=p_fecha_ultima_modificacion
						 ,fecha_nacimiento=p_fecha_nacimiento
						 ,fecha_reg=p_fecha_registro
						 ,genero=p_genero
						 ,nombre=p_nombre
						 ,telefono1=p_telefono1
						 ,telefono2=p_telefono2
                         ,correo2=p_email2
                         ,nacionalidad=p_nacionalidad
                         ,id_tipo_doc_identificacion=p_id_tipo_doc_identificacion
                         ,expedicion=p_expedicion
                         ,discapacitado = p_discapacitado
                         ,id_lugar=p_lugar
						 WHERE id_persona=p_id_persona;






		     ELSEIF  v_operacion = 'DELETE' THEN

			     --chequear si ya existe el registro si no sacar un error
                  IF  not EXISTS(select 1
                     from sqlserver.t_breydi_persona
                     where id_persona=p_id_persona) THEN

                      raise exception 'No existe el registro que desea eliminar';

                   END IF;


                 DELETE FROM  sqlserver.t_breydi_persona  WHERE  id_persona=p_id_persona;


		    END IF;

   return 'true';


  END;
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY INVOKER
COST 100;