<?php
/**
 *@package pXP
 *@file gen-MODMigracion.php
 *@author  (franklin.espinoza)
 *@date 20-09-2017 20:55:18
 *@description Clase que envia los parametros requeridos a la Base de datos para la ejecucion de las funciones, y que recibe la respuesta del resultado de la ejecucion de las mismas
 */
include_once(dirname(__FILE__).'/../../lib/lib_modelo/ConexionSqlServer.php');
//include_once(dirname(__FILE__).'/../../lib/lib_modelo/conexionInformix.php');
class MODMigracion extends MODbase{

    function __construct(CTParametro $pParam){
        parent::__construct($pParam);
    }

    function listarMigracion(){
        //Definicion de variables para ejecucion del procedimientp
        $this->procedimiento='sqlserver.ft_migracion_sel';
        $this->transaccion='SQL_MIGRA_SEL';
        $this->tipo_procedimiento='SEL';//tipo de transaccion


        //Definicion de la lista del resultado del query
        $this->captura('id_migracion','int4');
        $this->captura('cadena_db','varchar');
        $this->captura('operacion','varchar');
        $this->captura('estado','varchar');
        $this->captura('respuesta','text');
        $this->captura('estado_reg','varchar');
        $this->captura('consulta','text');
        $this->captura('id_usuario_ai','int4');
        $this->captura('id_usuario_reg','int4');
        $this->captura('usuario_ai','varchar');
        $this->captura('fecha_reg','timestamp');
        $this->captura('id_usuario_mod','int4');
        $this->captura('fecha_mod','timestamp');
        $this->captura('usr_reg','varchar');
        $this->captura('usr_mod','varchar');

        //Ejecuta la instruccion
        $this->armarConsulta();
        //var_dump($this->consulta);exit;
        $this->ejecutarConsulta();

        //Devuelve la respuesta
        return $this->respuesta;
    }

    function insertarMigracion(){
        //Definicion de variables para ejecucion del procedimiento
        $this->procedimiento='sqlserver.ft_migracion_ime';
        $this->transaccion='SQL_MIGRA_INS';
        $this->tipo_procedimiento='IME';

        //Define los parametros para la funcion
        $this->setParametro('operacion','operacion','varchar');
        $this->setParametro('estado','estado','varchar');
        $this->setParametro('respuesta','respuesta','text');
        $this->setParametro('estado_reg','estado_reg','varchar');
        $this->setParametro('id_presupuesto_destino','id_presupuesto_destino','int4');
        $this->setParametro('tipo_cuenta','tipo_cuenta','varchar');
        $this->setParametro('id_presupuesto_origen','id_presupuesto_origen','int4');
        $this->setParametro('id_auxiliar_destino','id_auxiliar_destino','int4');
        $this->setParametro('consulta','consulta','text');
        $this->setParametro('id_usuario_reg','id_usuario_reg','integer');

        //Ejecuta la instruccion
        $this->armarConsulta();
        $this->ejecutarConsulta();

        //Devuelve la respuesta
        return $this->respuesta;
    }

    function modificarMigracion(){
        //Definicion de variables para ejecucion del procedimiento
        $this->procedimiento='sqlserver.ft_migracion_ime';
        $this->transaccion='SQL_MIGRA_MOD';
        $this->tipo_procedimiento='IME';

        //Define los parametros para la funcion
        $this->setParametro('id_migracion','id_migracion','int4');
        $this->setParametro('operacion','operacion','varchar');
        $this->setParametro('estado','estado','varchar');
        $this->setParametro('respuesta','respuesta','text');
        $this->setParametro('estado_reg','estado_reg','varchar');
        $this->setParametro('id_presupuesto_destino','id_presupuesto_destino','int4');
        $this->setParametro('tipo_cuenta','tipo_cuenta','varchar');
        $this->setParametro('id_presupuesto_origen','id_presupuesto_origen','int4');
        $this->setParametro('id_auxiliar_destino','id_auxiliar_destino','int4');
        $this->setParametro('consulta','consulta','text');
        $this->setParametro('id_usuario_reg','id_usuario_reg','integer');

        //Ejecuta la instruccion
        $this->armarConsulta();
        $this->ejecutarConsulta();

        //Devuelve la respuesta
        return $this->respuesta;
    }

    function eliminarMigracion(){
        //Definicion de variables para ejecucion del procedimiento
        $this->procedimiento='sqlserver.ft_migracion_ime';
        $this->transaccion='SQL_MIGRA_ELI';
        $this->tipo_procedimiento='IME';

        //Define los parametros para la funcion
        $this->setParametro('id_migracion','id_migracion','int4');

        //Ejecuta la instruccion
        $this->armarConsulta();
        $this->ejecutarConsulta();

        //Devuelve la respuesta
        return $this->respuesta;
    }

    function listarMigracionPendiente(){

        //Definicion de variables para ejecucion del procedimientp
        $this->procedimiento='sqlserver.ft_migracion_sel';
        $this->transaccion='SQL_MIGRA_PEND_SEL';
        $this->tipo_procedimiento='SEL';//tipo de transaccion
        $this->setCount(false);
        //$this->tipo_conexion='seguridad';

        //Definicion de la lista del resultado del query
        $this->captura('id_migracion','int4');
        $this->captura('cadena_db','varchar');
        $this->captura('operacion','varchar');
        $this->captura('estado','varchar');
        $this->captura('respuesta','text');
        $this->captura('consulta','text');

        $this->captura('estado_reg','varchar');
        $this->captura('id_usuario_ai','int4');
        $this->captura('id_usuario_reg','int4');
        $this->captura('usuario_ai','varchar');
        $this->captura('fecha_reg','timestamp');
        $this->captura('id_usuario_mod','int4');
        $this->captura('fecha_mod','timestamp');
        $this->captura('usr_reg','varchar');
        $this->captura('usr_mod','varchar');
        $this->captura('tipo_conexion','varchar');

        //Ejecuta la instruccion
        $this->armarConsulta();
        //var_dump($this->consulta);exit;
        $this->ejecutarConsulta();

        //recuperamos los registros a migrar de la bd
        $datos = json_decode(json_encode($this->respuesta));
        //var_dump($datos->datos);exit;
        //variables para la ocnexion sql server.
        $bandera_conex='';
        $conn = '';
        $ids_fallas = '';
        $ids_exitos = '';
        $param_conex = array();
        $conexion = '';

        if(($datos->datos) == null){
            return $this->respuesta;
        }

        //recorremos los registros
        foreach ($datos->datos as $data){
            if($data->tipo_conexion  != 'informix') {

                if ($data->cadena_db != $bandera_conex) {
                    if ($conn != '') {
                        $conexion->closeSQL();
                    }
                    $param_conex = explode(',', $data->cadena_db);
                    $conexion = new ConexionSqlServer($param_conex[0], $param_conex[2], $param_conex[3], $param_conex[1]);
                    $conn = $conexion->conectarSQL();
                    $bandera_conex = $data->cadena_db;
                }
            }else{

                if ($data->cadena_db != $bandera_conex) {
                    if ($conn != '') {
                        $conexion->cerrarConexion();
                    }

                    // $param_conex = explode(',', $data->cadena_db);
                    //  $conexion = new conexionInformix($param_conex[0],$param_conex[1],$param_conex[2]);
                    $dbh = "informix:host=" . $_SESSION['_HOST_INFORMIX'] . ";service=informixport;database=" . $_SESSION['_DATABASE_INFORMIX'] . ";server=" . $_SESSION['_SERVER_INFORMIX'] . "; protocol=onsoctcp;charset=utf8";
                    $conexion = new conexionInformix($dbh, $_SESSION['_USER_INFORMIX'], $_SESSION['_PASS_INFORMIX']);
                    //   var_dump('llega');exit;
                    $conn = $conexion->abrirConexion();

                }

            }
            try{

                $error = '';

                if($conn=='connect') {
                    $error = 'connect';
                    throw new Exception("connect: La conexión a la bd SQL Server ".$param_conex[1]." ha fallado.");
                }else if($conn=='select_db'){
                    $error = 'select_db';
                    throw new Exception("select_db: La seleccion de la bd SQL Server ".$param_conex[1]." ha fallado.");
                }else {
                    if ($data->tipo_conexion  != 'informix'){
                        if ($param_conex[1] == 'msdb') {
                            try {
                                @mssql_query(utf8_decode($data->consulta), $conn);
                            }catch (Exception $e){
                                echo ('ERROR1: '.$e->getMessage());
                            }
                        } else {

                            try {

                                $cone = new conexion();
                                $link = $cone->conectarpdo();

                                if ($link) {
                                    try {
                                        $consulta = @mssql_query(utf8_decode($data->consulta), $conn);
                                    }catch (Exception $e){
                                        echo ('ERROR2: '.$e->getMessage());
                                    }
                                }

                                if (!$consulta) {

                                    $ids_fallas .= $data->id_migracion . "," . "query: " . mssql_get_last_message() . ';';

                                } else {

                                    $ids_exitos .= $data->id_migracion . ",";

                                }
                            } catch (Exception $e) {

                                throw new Exception("La conexion a la bd POSTGRESQL ha fallado.");
                            }

                        }
                    }else{
                        try {

                            $sql= $conn->prepare($data->consulta);
                            // var_dump($sql);exit;
                            $con =  $sql->execute();
                            //var_dump($con);exit;
                            $conn->commit();
                            if (!$con) {

                                $ids_fallas .= $data->id_migracion . "," . "query: " . mssql_get_last_message() . ';';

                            } else {

                                $ids_exitos .= $data->id_migracion . ",";

                            }
                        }catch (Exception $e){
                            $conn->rollBack();
                        }

                    }
                }

            }catch (Exception $e){

                $ids_fallas .=  $data->id_migracion.",".$e->getMessage().';';
            }
        }$conexion->closeSQL();
        //$conexion->cerrarConexion();

        $ids_fallas = trim($ids_fallas,';');
        $ids_exitos = trim($ids_exitos,',');

        //var_dump($ids_exitos);exit;

        try {
            $cone = new conexion();
            $link = $cone->conectarpdo();

            $link->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
            $link->beginTransaction();
            //Definicion de variables para ejecucion del procedimiento
            $this->procedimiento = 'sqlserver.ft_migracion_ime';
            $this->transaccion = 'SQL_MIGRA_ESTADO_MOD';
            $this->tipo_procedimiento = 'IME';

            $this->arreglo['ids_fallas'] = str_replace("'", "",$ids_fallas);
            $this->arreglo['ids_exitos'] = $ids_exitos;

            /*echo "fallas";
            var_dump($this->arreglo['ids_fallas']);
            exit;*/

            //var_dump($ids_fallas);
            //Define los parametros para la funcion
            $this->setParametro('ids_fallas','ids_fallas','varchar');
            $this->setParametro('ids_exitos','ids_exitos','varchar');
            //var_dump($this->consulta);exit;
            //Ejecuta la instruccion
            $this->armarConsulta();
            $stmt = $link->prepare($this->consulta);
            $stmt->execute();
            $result = $stmt->fetch(PDO::FETCH_ASSOC);


            //recupera parametros devuelto depues de insertar ... (id_solicitud)
            $resp_procedimiento = $this->divRespuesta($result['f_intermediario_ime']);
            if ($resp_procedimiento['tipo_respuesta']=='ERROR') {
                throw new Exception("Error al actualizar las migraciones en la bd", 3);
            }
            $respuesta = $resp_procedimiento['datos'];

            $link->commit();
            $this->respuesta=new Mensaje();
            $this->respuesta->setMensaje($resp_procedimiento['tipo_respuesta'],$this->nombre_archivo,$resp_procedimiento['mensaje'],$resp_procedimiento['mensaje_tec'],'base',$this->procedimiento,$this->transaccion,$this->tipo_procedimiento,$this->consulta);
            $this->respuesta->setDatos($respuesta);
        }catch (Exception $e) {
            $link->rollBack();
            $this->respuesta = new Mensaje();
            if ($e->getCode() == 3) {
                $this->respuesta->setMensaje($resp_procedimiento['tipo_respuesta'], $this->nombre_archivo, $resp_procedimiento['mensaje'], $resp_procedimiento['mensaje_tec'], 'base', $this->procedimiento, $this->transaccion, $this->tipo_procedimiento, $this->consulta);
            } else if ($e->getCode() == 2) {
                $this->respuesta->setMensaje('ERROR', $this->nombre_archivo, $e->getMessage(), $e->getMessage(), 'modelo', '', '', '', '');
            } else {
                throw new Exception($e->getMessage(), 2);
            }
        }

        //var_dump($this->respuesta);exit;

        //Devuelve la respuesta
        return $this->respuesta;
    }

    function modificarMigracionEstado(){
        //Definicion de variables para ejecucion del procedimiento
        $this->procedimiento='sqlserver.ft_migracion_ime';
        $this->transaccion='SQL_MIGRA_ESTADO_MOD';
        $this->tipo_procedimiento='IME';

        //definicion de variables
        $this->tipo_conexion='seguridad';

        $this->count=false;

        $this->setParametro('id_usuario','id_usuario','integer');
        $this->setParametro('tipo','tipo','varchar');
        $this->setParametro('errores_id','errores_id','varchar');
        $this->setParametro('errores_msg','errores_msg','codigo_html');
        $this->setParametro('pendiente','pendiente','varchar');

        //Define los parametros para la funcion
        //$this->setParametro('id_alarma','id_alarma','int4');
        //Ejecuta la instruccion
        $this->armarConsulta();
        $this->ejecutarConsulta();

        //Devuelve la respuesta
        return $this->respuesta;
    }

    function convertirImagen(){
        //Definicion de variables para ejecucion del procedimiento
        $this->procedimiento='sqlserver.ft_migracion_sel';
        $this->transaccion='SQL_MIGRA_IMG_SEL';
        $this->tipo_procedimiento='SEL';
        $this->count=false;
        //Define los parametros para la funcion
        /*$this->captura('id_cc','int4');
        $this->captura('foto','bytea');*/

        //$this->captura('foto','bytea');
        $this->captura('id_persona','integer');
        //$this->captura('foto','bytea');
        //$this->captura('id_funcionario','integer');
        $this->captura('numero','integer');

        //$this->captura('extension','varchar');

        //Ejecuta la instruccion
        $this->armarConsulta();
        //var_dump($this->consulta);exit;
        $this->ejecutarConsulta();

        //recuperamos los registros a migrar de la bd
        $datos = json_decode(json_encode($this->respuesta));
//        $persona = array();
//        foreach ($datos->datos as $data){
//            $persona[$data->id_persona] = $data->numero;
//        }
//        //$url_base = '/home/nfs/erp_desarrollo/uploaded_files/sis_parametros/Archivo/';
//        $url_base = '/home/nfs/erp_desarrollo/uploaded_files/sis_parametros/Fotos_Pxp';
//        $archivos = scandir($url_base);
//        $fotos = [];
//        $pxpRestClient = PxpRestClient::connect('192.168.11.82', 'kerp_capacitacion/pxp/lib/rest/')->setCredentialsPxp('notificaciones','Mund0libre');
//
//        $contador = 0;
//        foreach ($archivos as $clave => $foto) {
//            $infFoto = [];
//            $infFoto['nombre'] = $foto;
//            $infFoto['ext'] = $this->getExtension($url_base.'/'.$foto);
//            if($foto!='.' && $foto!='..'){
//                $contador++;
//                $index = substr($foto, 0, strripos($foto,'.'));
//                if($foto!=null) {//var_dump(base64_decode(base64_encode(file_get_contents($url_base .'/'.$foto))));exit;
//                    //rename($url_base.'/'.$foto, $url_base.'/'.$persona[$index].".".$infFoto['ext']);
//                    //$file = base64_encode(file_get_contents($url_base .'/'.$foto));
//
//                    //$file = imagecreatefromjpeg ($url_base .'/'.$foto);
//                    /*$resp = $pxpRestClient->doPost('organigrama/CertificadoPlanilla/consultaDatosFuncionario',
//                        array( "id_funcionario"=>585)
//                    );echo $resp;*/
//                    /*$file = base64_encode(file_get_contents($url_base .'/'.$foto));
//                    $im = imagecreatefromstring(base64_decode($file));*/
//                    /*header('Content-type: image/jpeg');
//                    $file = readfile($url_base .'/'.$foto);var_dump($file);exit;*/
//                    $foto = exif_read_data($url_base .'/'.$foto);
//                    $this->arregloFiles = $foto; var_dump($foto);exit;
//                    $resp = $pxpRestClient->doPost('parametros/Archivo/subirArchivo',
//                        array(
//                            "id_tabla" => $persona[$index],
//                            "id_tipo_archivo" => 10,
//                            "extension" => $infFoto['ext'],
//                            "tabla" => "orga.tfuncionario",
//                            "codigo_tipo_archivo" => "FOTO_FUNCIONARIO",
//                            "nombre_descriptivo" => "",
//                            //"folder" => $url_base,
//                            "nombre_archivo" => $index,
//                            //"archivo" => $file//$url_base .'/'.$foto.';filename='.$foto
//                        )
//                    );//echo($resp);
//                }
//
//                /*if($infFoto['ext']=='jpeg'){
//                    $file = base64_encode(file_get_contents('/var/www/html/kerp_capacitacion/sis_seguridad/control/foto_persona/'.$foto));
//                    $im = imagecreatefromstring(base64_decode($file));
//                    header('Content-Type: image/jpeg');
//                    imagejpeg($im, '/home/nfs/erp_desarrollo/uploaded_files/sis_parametros/Fotos/'.$infFoto['nombre']);
//                    imagedestroy($im);
//                }
//                echo($foto);*/
//                    //array_push($fotos, $infFoto);
//
//            }
//
//        }


        foreach ($datos->datos as $data){
            //var_dump($data);exit;
            $image = pg_unescape_bytea($data->foto_persona);
            //var_dump($image);exit;
            //$im =  pg_escape_bytea(base64_encode($data->foto_persona));
            $im = imagecreatefromstring(base64_decode($image));

            if ($im !== false) {

                header('Content-Type: image/jpeg');

                //imagejpeg($im,'/tmp/'.$data->id_persona.'.jpeg');

                imagejpeg($im);
                //imagejpeg($im,'/home/nfs/erp_desarrollo/uploaded_files/sis_parametros/Fotos_Pxp/'.$data->id_persona.'.jpeg');
                imagedestroy($im);
            }
            else {
                echo 'Ocurrió un error.';
            }

        }



        //Devuelve la respuesta
        return $this->respuesta;
    }

    function fotoFuncionario(){
        $this->procedimiento='sqlserver.ft_migracion_sel';
        $this->transaccion='SQL_MIGRA_FOTO_SEL';
        $this->tipo_procedimiento='SEL';
        $this->setCount(false);

        $this->setParametro('id_funcionario','id_funcionario','int4');

        $this->captura('url_image','varchar');


        //Ejecuta la instruccion
        $this->armarConsulta();
        $this->ejecutarConsulta();

        //Devuelve la respuesta

        return $this->respuesta;
    }
    function getExtension($name){
        $tipo = filetype($name);

        if( $tipo== 'file'){
            return substr($name, strripos($name,'.')+1);
        }else{
            return $tipo;
        }
    }

    function getNombre($name){
        $tipo = filetype($name);
        //var_dump($name);exit;
        if( $tipo== 'file'){
            return substr($name, 1, strripos($name,'.')-1);
        }else{
            return $tipo;
        }
    }

}
?>