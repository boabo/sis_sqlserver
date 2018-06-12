CREATE OR REPLACE FUNCTION sqlserver.f_migrar_tfuncionario_cuenta_bancaria (
)
RETURNS trigger AS
$body$
DECLARE

  v_consulta 			text;
  v_id_usuario 			integer;

  v_cadena_db		varchar;
BEGIN

    v_cadena_db = pxp.f_get_variable_global('cadena_db_sql_2');
    --raise exception 'tcuenta_bancaria: %',TG_OP ;
    if(TG_OP = 'INSERT')then

    	v_consulta =  'exec Ende_CuentaBancaria ''INS'', '||new.id_funcionario_cuenta_bancaria||', '||new.id_funcionario||', '||
        			  new.nro_cuenta||', ''activo'';';

    elsif(TG_OP ='UPDATE' )then
    	if new.estado_reg = 'inactivo' then
        	v_consulta =  'exec Ende_CuentaBancaria ''DEL'', '||new.id_funcionario_cuenta_bancaria||', '||new.id_funcionario||', '||
        			  new.nro_cuenta||', ''activo'';';
        else
    		v_consulta =  'exec Ende_CuentaBancaria ''UPD'', '||new.id_funcionario_cuenta_bancaria||', '||new.id_funcionario||', '||
        			  new.nro_cuenta||', ''activo'';';
        end if;
	end if;


  	select tu.id_usuario
    into v_id_usuario
    from segu.tusuario tu
    where tu.cuenta = (string_to_array(current_user,'_'))[3];

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