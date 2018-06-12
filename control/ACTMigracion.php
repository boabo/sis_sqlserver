<?php
/**
 *@package pXP
 *@file gen-ACTMigracion.php
 *@author  (franklin.espinoza)
 *@date 20-09-2017 20:55:18
 *@description Clase que recibe los parametros enviados por la vista para mandar a la capa de Modelo
 */

class ACTMigracion extends ACTbase{

    function listarMigracion(){
        $this->objParam->defecto('ordenacion','id_migracion');

        $this->objParam->defecto('dir_ordenacion','asc');

        if($this->objParam->getParametro('dia_reg')!=''){
            $this->objParam->addFiltro("migra.fecha_reg::date = ''".$this->objParam->getParametro('dia_reg')."''::date");
        }

        if($this->objParam->getParametro('tipoReporte')=='excel_grid' || $this->objParam->getParametro('tipoReporte')=='pdf_grid'){
            $this->objReporte = new Reporte($this->objParam,$this);
            $this->res = $this->objReporte->generarReporteListado('MODMigracion','listarMigracion');
        } else{
            $this->objFunc=$this->create('MODMigracion');

            $this->res=$this->objFunc->listarMigracion($this->objParam);
        }
        $this->res->imprimirRespuesta($this->res->generarJson());
    }

    function insertarMigracion(){
        $this->objFunc=$this->create('MODMigracion');
        if($this->objParam->insertar('id_migracion')){
            $this->res=$this->objFunc->insertarMigracion($this->objParam);
        } else{
            $this->res=$this->objFunc->modificarMigracion($this->objParam);
        }
        $this->res->imprimirRespuesta($this->res->generarJson());
    }

    function eliminarMigracion(){
        $this->objFunc=$this->create('MODMigracion');
        $this->res=$this->objFunc->eliminarMigracion($this->objParam);
        $this->res->imprimirRespuesta($this->res->generarJson());
    }

    function dispararControlMigracion(){
        $this->objFunc=$this->create('MODMigracion');
        $this->res=$this->objFunc->listarMigracionPendiente($this->objParam);
        $this->res->imprimirRespuesta($this->res->generarJson());
    }

    function convertirImagen(){
        $this->objFunc=$this->create('MODMigracion');
        $this->res=$this->objFunc->convertirImagen($this->objParam);
        $this->res->imprimirRespuesta($this->res->generarJson());
    }

    function fotoFuncionario(){

        $this->objFunc=$this->create('MODMigracion');
        $this->res=$this->objFunc->fotoFuncionario($this->objParam);
        $this->res->imprimirRespuesta($this->res->generarJson());
    }
}

?>