<?php
/**
 *@package pXP
 *@file gen-Migracion.php
 *@author  (franklin.espinoza)
 *@date 20-09-2017 20:55:18
 *@description Archivo con la interfaz de usuario que permite la ejecucion de todas las funcionalidades del sistema
 */

header("content-type: text/javascript; charset=UTF-8");
?>
<script>
    Phx.vista.Migracion=Ext.extend(Phx.gridInterfaz,{

        constructor:function(config){
            this.maestro=config.maestro;
            this.tbarItems = ['-','Rep. x Dia: ',
                this.filCmp,'-'

            ];
            //llama al constructor de la clase padre
            Phx.vista.Migracion.superclass.constructor.call(this,config);
            this.init();
            this.addLoad();
            this.filCmp.on('select', function () {
                this.addLoad();
            },this);

            this.addButton('migrar_fotos',{
                grupo: [0,1,2,3,4,5],
                text: 'Replicar Datos',
                iconCls: 'bfolder',
                disabled: false,
                handler: this.migrarTabla,
                tooltip: '<b>Migrar Fotos</b><br><b>Nos permite migrar fotos del ERP1 al ERP2.</b>'
            });
            this.load({params:{start:0, limit:this.tam_pag}});
        },

        migrarFotos:function () {
            Ext.Ajax.request({
                url:'../../sis_sqlserver/control/Migracion/convertirImagen',
                params:{id_usuario: 0},
                success:this.successExport,
                failure: this.conexionFailure,
                timeout:this.timeout,
                scope:this
            });
        },

        migrarTabla:function () {
            Ext.Ajax.request({
                url:'../../sis_sqlserver/control/Migracion/dispararControlMigracion',
                params:{id_usuario: 0},
                success:this.successExport,
                failure: this.conexionFailure,
                timeout:this.timeout,
                scope:this
            });
        },

        addLoad: function () {
            this.store.baseParams.dia_reg = this.filCmp.getValue();
            this.load({params:{start:0, limit:this.tam_pag}});
        },

        filCmp: new Ext.form.DateField( {
            name: 'dia_reg',
            fieldLabel: 'Filtrar x dias',
            emptyText:'Filtrar x dias',
            allowBlank: true,
            anchor: '80%',
            format: 'd/m/Y',
            value: new Date(),
            renderer: function (value, p, record) {
                return value ? value.dateFormat('d/m/Y') : ''
            }
        }),

        Atributos:[
            {
                //configuracion del componente
                config:{
                    labelSeparator:'',
                    inputType:'hidden',
                    name: 'id_migracion'
                },
                type:'Field',
                form:true
            },
            {
                config:{
                    name: 'operacion',
                    fieldLabel: 'Operacion',
                    allowBlank: true,
                    anchor: '80%',
                    gwidth: 65,
                    maxLength:15,
                    renderer: function (value, p, record) {
                        var color = '';
                        if(record.data['estado']=='pendiente')
                            color = 'orange';
                        else
                            color = 'green';
                        return String.format('<span style="color: '+color+';">{0}</span>', value);
                    }
                },
                type:'TextField',
                filters:{pfiltro:'migra.operacion',type:'string'},
                id_grupo:1,
                grid:true,
                form:true
            },
            {
                config:{
                    name: 'consulta',
                    fieldLabel: 'Consulta',
                    allowBlank: false,
                    anchor: '80%',
                    gwidth: 400,
                    maxLength:-5/*,
				renderer: function (value, p, record) {

					for()
					var color = '';
					if(record.data['estado']=='pendiente')
						color = 'orange';
					else
						color = 'green';
					return String.format('<span style="color: '+color+';">{0}</span>', value);
					return '<tpl for="."><div class="x-combo-list-item" style="width: 15px;"><p><b>Consulta: </b> '+record.data['consulta']+'</p></div></tpl>';
				}*/
                },
                type:'TextField',
                filters:{pfiltro:'migra.consulta',type:'string'},
                id_grupo:1,
                grid:true,
                form:true
            },
            {
                config:{
                    name: 'estado',
                    fieldLabel: 'Estado',
                    allowBlank: true,
                    anchor: '80%',
                    gwidth: 60,
                    maxLength:20,
                    renderer: function (value, p, record) {
                        var color = '';
                        if(record.data['estado']=='pendiente')
                            color = 'orange';
                        else
                            color = 'green';
                        return String.format('<span style="color: '+color+';">{0}</span>', value);
                    }
                },
                type:'TextField',
                filters:{pfiltro:'migra.estado',type:'string'},
                id_grupo:1,
                grid:true,
                form:true
            },
            {
                config:{
                    name: 'respuesta',
                    fieldLabel: 'Respuesta',
                    allowBlank: true,
                    anchor: '80%',
                    gwidth: 250,
                    maxLength:-5
                },
                type:'TextField',
                filters:{pfiltro:'migra.respuesta',type:'string'},
                id_grupo:1,
                grid:true,
                form:true
            },
            {
                config:{
                    name: 'cadena_db',
                    fieldLabel: 'Conexion',
                    allowBlank: false,
                    anchor: '80%',
                    gwidth: 230,
                    maxLength:-5
                },
                type:'TextField',
                filters:{pfiltro:'migra.cadena_db',type:'string'},
                id_grupo:1,
                grid:true,
                form:true
            },
            {
                config:{
                    name: 'estado_reg',
                    fieldLabel: 'Estado Reg.',
                    allowBlank: true,
                    anchor: '80%',
                    gwidth: 100,
                    maxLength:10
                },
                type:'TextField',
                filters:{pfiltro:'migra.estado_reg',type:'string'},
                id_grupo:1,
                grid:true,
                form:false
            },

            {
                config:{
                    name: 'id_usuario_ai',
                    fieldLabel: '',
                    allowBlank: true,
                    anchor: '80%',
                    gwidth: 100,
                    maxLength:4
                },
                type:'Field',
                filters:{pfiltro:'migra.id_usuario_ai',type:'numeric'},
                id_grupo:1,
                grid:false,
                form:false
            },
            {
                config:{
                    name: 'usr_reg',
                    fieldLabel: 'Creado por',
                    allowBlank: true,
                    anchor: '80%',
                    gwidth: 100,
                    maxLength:4
                },
                type:'Field',
                filters:{pfiltro:'usu1.cuenta',type:'string'},
                id_grupo:1,
                grid:true,
                form:false
            },
            {
                config:{
                    name: 'usuario_ai',
                    fieldLabel: 'Funcionaro AI',
                    allowBlank: true,
                    anchor: '80%',
                    gwidth: 100,
                    maxLength:300
                },
                type:'TextField',
                filters:{pfiltro:'migra.usuario_ai',type:'string'},
                id_grupo:1,
                grid:true,
                form:false
            },
            {
                config:{
                    name: 'fecha_reg',
                    fieldLabel: 'Fecha creación',
                    allowBlank: true,
                    anchor: '80%',
                    gwidth: 100,
                    format: 'd/m/Y',
                    renderer:function (value,p,record){return value?value.dateFormat('d/m/Y H:i:s'):''}
                },
                type:'DateField',
                filters:{pfiltro:'migra.fecha_reg',type:'date'},
                id_grupo:1,
                grid:true,
                form:false
            },
            {
                config:{
                    name: 'usr_mod',
                    fieldLabel: 'Modificado por',
                    allowBlank: true,
                    anchor: '80%',
                    gwidth: 100,
                    maxLength:4
                },
                type:'Field',
                filters:{pfiltro:'usu2.cuenta',type:'string'},
                id_grupo:1,
                grid:true,
                form:false
            },
            {
                config:{
                    name: 'fecha_mod',
                    fieldLabel: 'Fecha Modif.',
                    allowBlank: true,
                    anchor: '80%',
                    gwidth: 100,
                    format: 'd/m/Y',
                    renderer:function (value,p,record){return value?value.dateFormat('d/m/Y H:i:s'):''}
                },
                type:'DateField',
                filters:{pfiltro:'migra.fecha_mod',type:'date'},
                id_grupo:1,
                grid:true,
                form:false
            }
        ],
        tam_pag:50,
        title:'Migracion',
        ActSave:'../../sis_sqlserver/control/Migracion/insertarMigracion',
        ActDel:'../../sis_sqlserver/control/Migracion/eliminarMigracion',
        ActList:'../../sis_sqlserver/control/Migracion/listarMigracion',
        id_store:'id_migracion',
        fields: [
            {name:'id_migracion', type: 'numeric'},
            {name:'operacion', type: 'string'},
            {name:'estado', type: 'string'},
            {name:'respuesta', type: 'string'},
            {name:'estado_reg', type: 'string'},
            {name:'id_presupuesto_destino', type: 'numeric'},
            {name:'tipo_cuenta', type: 'string'},
            {name:'id_presupuesto_origen', type: 'numeric'},
            {name:'id_auxiliar_destino', type: 'numeric'},
            {name:'consulta', type: 'string'},
            {name:'id_usuario_ai', type: 'numeric'},
            {name:'id_usuario_reg', type: 'numeric'},
            {name:'usuario_ai', type: 'string'},
            {name:'fecha_reg', type: 'date',dateFormat:'Y-m-d H:i:s.u'},
            {name:'id_usuario_mod', type: 'numeric'},
            {name:'fecha_mod', type: 'date',dateFormat:'Y-m-d H:i:s.u'},
            {name:'usr_reg', type: 'string'},
            {name:'usr_mod', type: 'string'},
            {name:'cadena_db', type: 'string'}

        ],
        sortInfo:{
            field: 'id_migracion',
            direction: 'ASC'
        },
        bdel:false,
        bsave:false,
        bnew:false,
        bedit:false,
        btest:false
    });
</script>

		