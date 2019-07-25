CREATE OR REPLACE FUNCTION sqlserver.ffotos (
)
RETURNS void AS
$body$
DECLARE
   v_archivos 			varchar[] ;
    v_archivo			varchar;
    v_record			record;
    v_pos				integer;
    v_nombre			varchar;
    v_ext				varchar;
    v_id_tabla			integer;

    v_host				varchar;
    v_puerto			varchar;
    v_dbname			varchar;
    v_user				varchar;
    v_password			varchar;
    v_cadena_cnx		varchar;
    v_resp				varchar;

    v_consulta			varchar;
    v_res_cone			varchar;
BEGIN

	v_host='192.168.100.30';
    v_puerto='5432';
    v_dbname='dbendesis';
    v_user='dblink_pxp';
    v_password='dblink_pxp';

    v_cadena_cnx =  'hostaddr='||v_host||' port='||v_puerto||' dbname='||v_dbname||' user='||v_user||' password='||v_password;
    v_resp =  dblink_connect(v_cadena_cnx);

    IF(v_resp!='OK') THEN
    	raise exception 'FALLA CONEXION A LA BASE DE DATOS CON DBLINK';
    ELSE
        v_consulta = 'select tp.id_persona, tp.foto_persona from sss.tsg_persona tp where tp.id_persona = 8412 '; --v_consulta = 'select * from sss.tsg_persona limit 1';
    END IF;

    CREATE TEMP TABLE foto_persona ON COMMIT DROP AS (
    				SELECT id_persona, foto_persona
          			FROM dblink(migra.f_obtener_cadena_conexion(),v_consulta)
          			AS(id_persona integer, foto_persona bytea)
    );

    FOR v_record IN (SELECT * FROM foto_persona)LOOP
    	--RETURN NEXT v_registros;
        raise exception 'v_record: %',v_record;
    END LOOP;

   for v_record in (SELECT id_persona, foto_persona
                	FROM dblink(v_consulta,true) AS foto(
                      id_persona integer,
                      foto_persona bytea

                    )
   					) loop

            	/*v_archivo = v_archivos[v_index];
                v_pos = position('.' in v_archivo);
                v_nombre = substr(v_archivo,0,v_pos);
                v_ext	= substr(v_archivo,v_pos+1);*/

                select tf.id_funcionario
                  into v_id_tabla
                  from orga.tfuncionario tf
                  where tf.id_persona = v_record.id_persona::integer;

                IF(v_id_tabla is not null and v_record.extension is not null and v_record.numero is not null)then

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
                    v_record.extension,
                    v_id_tabla,
                    v_record.numero,
                    10,
                    now(),
                    null,
                    612,
                    null,
                    null,
                    null,
                    'Fotografia Personal'
                  );
   		    end if;
            end loop;
            v_res_cone=(select dblink_disconnect());

            /*SELECT foto.id_persona, foto.numero, foto.extension
				   FROM dblink(migra.f_obtener_cadena_conexion(),'SELECT
                    PERSON.id_persona,
                    PERSON.foto_persona,
                    PERSON.numero,
                    PERSON.extension
                    FROM sss.tsg_persona PERSON
                    WHERE PERSON.foto_persona is not null order by id_persona')
          			AS foto(
                      id_persona integer,
                      foto_persona bytea,
                      numero integer,
                      extension varchar
                    )*/
END;
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY INVOKER
COST 100;