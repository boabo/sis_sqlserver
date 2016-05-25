<?php
/**
*@package pXP
*@file gen-ACTCabeceraViatico.php
*@author  (jrivera)
*@date 13-05-2016 21:04:18
*@description Clase que recibe los parametros enviados por la vista para mandar a la capa de Modelo
*/

class ACTCabeceraViatico extends ACTbase{    
				
	function insertarViatico(){
		$this->objFunc=$this->create('MODCabeceraViatico');	
		if($this->objParam->insertar('id_cabecera_viatico')){
			$this->res=$this->objFunc->insertarViatico($this->objParam);			
		} else{			
			$this->res=$this->objFunc->modificarCabeceraViatico($this->objParam);
		}
		$this->res->imprimirRespuesta($this->res->generarJson());
	}
	
	function validarViatico(){
		$this->objFunc=$this->create('MODCabeceraViatico');	
				
		$this->res=$this->objFunc->validarViatico($this->objParam);
		
		$this->res->imprimirRespuesta($this->res->generarJson());
	}
			
}

?>