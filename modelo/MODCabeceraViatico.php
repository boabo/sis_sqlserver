<?php
/**
*@package pXP
*@file gen-MODCabeceraViatico.php
*@author  (jrivera)
*@date 13-05-2016 21:04:18
*@description Clase que envia los parametros requeridos a la Base de datos para la ejecucion de las funciones, y que recibe la respuesta del resultado de la ejecucion de las mismas
*/

class MODCabeceraViatico extends MODbase{
	
	function __construct(CTParametro $pParam){
		parent::__construct($pParam);
	}
			
	function listarCabeceraViatico(){
		//Definicion de variables para ejecucion del procedimientp
		$this->procedimiento='sqlserver.ft_cabecera_viatico_sel';
		$this->transaccion='SQL_CABVI_SEL';
		$this->tipo_procedimiento='SEL';//tipo de transaccion
				
		//Definicion de la lista del resultado del query
		$this->captura('id_cabecera_viatico','int4');
		$this->captura('id_funcionario','int4');
		$this->captura('id_int_comprobante','int4');
		$this->captura('estado_reg','varchar');
		$this->captura('tipo_viatico','varchar');
		$this->captura('descripcion','text');
		$this->captura('acreedor','varchar');
		$this->captura('id_usuario_reg','int4');
		$this->captura('usuario_ai','varchar');
		$this->captura('fecha_reg','timestamp');
		$this->captura('id_usuario_ai','int4');
		$this->captura('fecha_mod','timestamp');
		$this->captura('id_usuario_mod','int4');
		$this->captura('usr_reg','varchar');
		$this->captura('usr_mod','varchar');
		
		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();
		
		//Devuelve la respuesta
		return $this->respuesta;
	}
			
	function insertarCabeceraViatico(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='sqlserver.ft_cabecera_viatico_ime';
		$this->transaccion='SQL_CABVI_INS';
		$this->tipo_procedimiento='IME';
				
		//Define los parametros para la funcion
		$this->setParametro('id_funcionario','id_funcionario','int4');
		$this->setParametro('id_int_comprobante','id_int_comprobante','int4');
		$this->setParametro('estado_reg','estado_reg','varchar');
		$this->setParametro('tipo_viatico','tipo_viatico','varchar');
		$this->setParametro('descripcion','descripcion','text');
		$this->setParametro('acreedor','acreedor','varchar');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}

	function insertarViatico(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='sqlserver.ft_cabecera_viatico_ime';
		$this->transaccion='SQL_CABVI_INS';
		$this->tipo_procedimiento='IME';
				
		//Define los parametros para la funcion
		$this->setParametro('id_funcionario','id_funcionario','int4');		
		$this->setParametro('tipo_viatico','tipo_viatico','varchar');
		$this->setParametro('descripcion','descripcion','text');
		$this->setParametro('acreedor','acreedor','varchar');
		$this->setParametro('fecha','fecha','date');
		$this->setParametro('nro_sigma','nro_sigma','varchar');
		$this->setParametro('json_detalle','json_detalle','text');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}
	
	function validarViatico(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='sqlserver.ft_cabecera_viatico_ime';
		$this->transaccion='SQL_CABVIVALI_MOD';
		$this->tipo_procedimiento='IME';
				
		//Define los parametros para la funcion
		$this->setParametro('id_int_comprobante','id_int_comprobante','int4');		
		$this->setParametro('id_funcionario','id_funcionario','int4');		

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}
			
	function modificarCabeceraViatico(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='sqlserver.ft_cabecera_viatico_ime';
		$this->transaccion='SQL_CABVI_MOD';
		$this->tipo_procedimiento='IME';
				
		//Define los parametros para la funcion
		$this->setParametro('id_cabecera_viatico','id_cabecera_viatico','int4');
		$this->setParametro('id_funcionario','id_funcionario','int4');
		$this->setParametro('id_int_comprobante','id_int_comprobante','int4');
		$this->setParametro('estado_reg','estado_reg','varchar');
		$this->setParametro('tipo_viatico','tipo_viatico','varchar');
		$this->setParametro('descripcion','descripcion','text');
		$this->setParametro('acreedor','acreedor','varchar');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}
			
	function eliminarCabeceraViatico(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='sqlserver.ft_cabecera_viatico_ime';
		$this->transaccion='SQL_CABVI_ELI';
		$this->tipo_procedimiento='IME';
				
		//Define los parametros para la funcion
		$this->setParametro('id_cabecera_viatico','id_cabecera_viatico','int4');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}
			
}
?>