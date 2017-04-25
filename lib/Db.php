<?php
Class Db{

    private $servidor='172.17.45.133';
    private $usuario='UsrErp';
    private $password='Boa.2017';
    private $base_datos='SSISDB';
    private $link;
    private $stmt;
    private $array;

    static $_instance;

    /*La función construct es privada para evitar que el objeto pueda ser creado mediante new*/
    private function __construct(){
        $this->conectar();
    }

    /*Evitamos el clonaje del objeto. Patrón Singleton*/
    private function __clone(){ }

    /*Función encargada de crear, si es necesario, el objeto.
    Esta es la función que debemos llamar desde fuera de la clase
    para instanciar el objeto, y así, poder utilizar sus métodos*/
    public static function getInstance(){
        if (!(self::$_instance instanceof self)){
            self::$_instance=new self();
        }
        return self::$_instance;
    }

    /*Realiza la conexión a la base de datos.*/
    private function conectar(){
        $this->link = mssql_connect($this->servidor, $this->usuario, $this->password);
        if (!$this->link) {
            die('Algo fue mal mientras se conectaba a MSSQL');
        }
        mssql_select_db($this->base_datos,$this->link);
        //@mysql_query("SET NAMES 'utf8'");
    }

    /*Método para ejecutar una sentencia sql*/
    public function ejecutar($sql){
        $this->stmt=mysql_query($sql,$this->link);
        return $this->stmt;
    }

    /*Método para obtener una fila de resultados de la sentencia sql*/
    public function obtener_fila($stmt,$fila){
        if ($fila==0){
            $this->array=mysql_fetch_array($stmt);
        }else{
            mysql_data_seek($stmt,$fila);
            $this->array=mysql_fetch_array($stmt);
        }
        return $this->array;
    }

    //Devuelve el último id del insert introducido
    public function lastID(){
        return mysql_insert_id($this->link);
    }

    public function desconectar(){
        mssql_close($this->link);
    }

}
?>