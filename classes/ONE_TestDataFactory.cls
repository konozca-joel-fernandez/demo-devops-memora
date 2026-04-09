/**
 * Created by mbujak003 on 31.01.2021.
 */
//Generic class for test data factory
public with sharing class ONE_TestDataFactory {
	//Create catalogo de precios register
    public static ONE_Catalogo_De_Precios__c createCatalogoDePrecios(ONE_Catalogo_De_Precios__c template, Boolean insertRecord) {
        ONE_Catalogo_De_Precios__c newPrecio = template != null ?
            template?.clone(false, false, false, false) :
            new ONE_Catalogo_De_Precios__c();

        if (insertRecord) {
            insert newPrecio;
        }
        return newPrecio;
    }
	//Create entrada modelo register
    public static ONE_Entrada_De_Modelo__c createEntradaDeModelo(ONE_Entrada_De_Modelo__c template, Boolean insertRecord) {
        ONE_Entrada_De_Modelo__c newModelo = template != null ?
            template?.clone(false, false, false, false) :
            new ONE_Entrada_De_Modelo__c();

        if (insertRecord) {
            insert newModelo;
        }
        return newModelo;
    }
	//Create entrada precio register
    public static ONE_Entrada_De_Precio__c createEntradaDePrecio(ONE_Entrada_De_Precio__c template, Boolean insertRecord) {
        ONE_Entrada_De_Precio__c newPrecio = template != null ?
            template?.clone(false, false, false, false) :
            new ONE_Entrada_De_Precio__c();

        if (insertRecord) {
            insert newPrecio;
        }
        return newPrecio;
    }
	//Create image register
    public static ONE_Imagen__c createImagen(ONE_Imagen__c template, Boolean insertRecord) {
        ONE_Imagen__c newProducto = template != null ?
            template?.clone(false, false, false, false) :
            new ONE_Imagen__c();

        if (insertRecord) {
            insert newProducto;
        }
        return newProducto;
    }
    //Create Presupuesto de producto
    public static ONE_Presupuesto__c createPresupuesto(ONE_Presupuesto__c template, Boolean insertRecord) {
        ONE_Presupuesto__c newPresupuesto = template != null ?
            template?.clone(false, false, false, false) :
            new ONE_Presupuesto__c();

        if (insertRecord) {
            insert newPresupuesto;
        }
        return newPresupuesto;
    }
	//Create producto register
    public static ONE_Producto__c createProducto(ONE_Producto__c template, Boolean insertRecord) {
        ONE_Producto__c newProducto = template != null ?
            template?.clone(false, false, false, false) :
            new ONE_Producto__c();

        if (insertRecord) {
            insert newProducto;
        }
        return newProducto;
    }
	//Create relacion producto register
    public static ONE_Relacion_De_Productos__c createRelacionDeProductos(ONE_Relacion_De_Productos__c template, Boolean insertRecord) {
        ONE_Relacion_De_Productos__c newProducto = template != null ?
            template?.clone(false, false, false, false) :
            new ONE_Relacion_De_Productos__c();

        if (insertRecord) {
            insert newProducto;
        }
        return newProducto;
    }
	//Create pedido proveedor register
    public static ONE_Pedido_De_Proveedor__c createPedidoDeProveedor(ONE_Pedido_De_Proveedor__c template, Boolean insertRecord) {
        ONE_Pedido_De_Proveedor__c newTarea = template != null ?
            template?.clone(false, false, false, false) :
            new ONE_Pedido_De_Proveedor__c();

        if (insertRecord) {
            insert newTarea;
        }
        return newTarea;
    }
	//Create tarea register
    public static ONE_Tarea__c createTarea(ONE_Tarea__c template, Boolean insertRecord) {
        ONE_Tarea__c newTarea = template != null ?
            template?.clone(false, false, false, false) :
            new ONE_Tarea__c();

        if (insertRecord) {
            insert newTarea;
        }
        return newTarea;
    }
	//Create contrato register
    public static ONE_Contrato__c createContrato(ONE_Contrato__c template, Boolean insertRecord) {
        ONE_Contrato__c newContrato = template != null ?
            template?.clone(false, false, false, false) :
            new ONE_Contrato__c();

        if (insertRecord) {
            insert newContrato;
        }
        return newContrato;
    }
	//Create interlocutor register
    public static ONE_Interlocutor__c createInterlocutor(ONE_Interlocutor__c template, Boolean insertRecord) {
        ONE_Interlocutor__c newInterlocutor = template != null ?
            template?.clone(false, false, false, false) :
            new ONE_Interlocutor__c();

        newInterlocutor.Name = template?.Name != null ? template.Name : getRandomName();

        if (insertRecord) {
            insert newInterlocutor;
        }
        return newInterlocutor;
    }
	//Create service register
    public static ONE_Expediente__c createExpediente(ONE_Expediente__c template, Boolean insertRecord) {
        ONE_Expediente__c newExpediente = template != null ?
            template?.clone(false, false, false, false) :
            new ONE_Expediente__c();

        newExpediente.ONE_Centro_Del_Expediente__c = template?.ONE_Centro_Del_Expediente__c != null ?
            template.ONE_Centro_Del_Expediente__c : createAccount(
                new Account(
                    RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_CommonConstants.ACCOUNT,
                        ONE_CommonConstants.ACC_RT_CENTRO_MEMORA)),
                true).Id;

        if (insertRecord) {
            insert newExpediente;
        }
        return newExpediente;
    }
	//Create sales order register
    public static ONE_Orden_De_Venta__c createOrdenDeVenta(ONE_Orden_De_Venta__c template, Boolean insertRecord) {
        ONE_Orden_De_Venta__c ordenDeVenta = template != null ?
            template?.clone(false, false, false, false) :
            new ONE_Orden_De_Venta__c();

        if (insertRecord) {
            insert ordenDeVenta;
        }
        return ordenDeVenta;
    }
	//Create recurso register
    public static ONE_Recurso__c createRecurso(ONE_Recurso__c template, Boolean insertRecord) {
        ONE_Recurso__c newRecurso = template != null ?
            template?.clone(false, false, false, false) :
            new ONE_Recurso__c();

        newRecurso.ONE_Atributo__c = template?.ONE_Atributo__c != null ? template.ONE_Atributo__c : createAttribute(null, true).Id;
        // newRecurso.ONE_Nombre_ESP__c = template?.ONE_Nombre_EUS__c != null ? template.ONE_Nombre_ESP__c : getRandomName();
        // newRecurso.ONE_Nombre_EUS__c = template?.ONE_Nombre_EUS__c != null ? template.ONE_Nombre_EUS__c : getRandomName();
        // newRecurso.ONE_Nombre_CAT__c = template?.ONE_Nombre_CAT__c != null ? template.ONE_Nombre_CAT__c : getRandomName();
        // newRecurso.ONE_Descripcion_ESP__c = template?.ONE_Descripcion_ESP__c != null ? template.ONE_Descripcion_ESP__c : getRandomName();

        if (insertRecord) {
            insert newRecurso;
        }
        return newRecurso;
    }
	//Create product attribute register
    public static ONE_Atributo__c createAttribute(ONE_Atributo__c template, Boolean insertRecord) {
        ONE_Atributo__c newAttribute = template != null ?
            template?.clone(false, false, false, false) :
            new ONE_Atributo__c();

        newAttribute.ONE_Tipologia_De_Producto__c = template?.ONE_Tipologia_De_Producto__c != null ?
            template.ONE_Tipologia_De_Producto__c : createTipologiaProducto(null, true).Id;
        newAttribute.ONE_Nombre_ESP__c = template?.ONE_Nombre_EUS__c != null ? template.ONE_Nombre_ESP__c : getRandomName();
        newAttribute.ONE_Nombre_EUS__c = template?.ONE_Nombre_EUS__c != null ? template.ONE_Nombre_EUS__c : getRandomName();
        newAttribute.ONE_Orden__c = template?.ONE_Orden__c != null ? template.ONE_Orden__c : Math.random() * 100;
        newAttribute.ONE_Campo_En_SF__c = template?.ONE_Campo_En_SF__c != null ? template.ONE_Campo_En_SF__c : 'ONE_Color_Labios__c';
        newAttribute.ONE_Nombre_CAT__c = template?.ONE_Nombre_CAT__c != null ? template.ONE_Nombre_CAT__c : getRandomName();

        if (insertRecord) {
            insert newAttribute;
        }
        return newAttribute;
    }
	//Create product tipology register
    public static ONE_Tipologia_Producto__c createTipologiaProducto(ONE_Tipologia_Producto__c template, Boolean insertRecord) {
        ONE_Tipologia_Producto__c newTipologia = template != null ?
            template.clone(false, false, false, false) :
            new ONE_Tipologia_Producto__c();

        newTipologia.ONE_Nombre_ESP__c = template?.ONE_Nombre_ESP__c != null ? template.ONE_Nombre_ESP__c : getRandomName();
        newTipologia.ONE_Nombre_CAT__c = template?.ONE_Nombre_CAT__c != null ? template.ONE_Nombre_CAT__c : getRandomName();
        newTipologia.ONE_Nombre_EUS__c = template?.ONE_Nombre_EUS__c != null ? template.ONE_Nombre_EUS__c : getRandomName();
        newTipologia.ONE_Orden__c = template?.ONE_Orden__c != null ? template.ONE_Orden__c : Math.random() * 100;

        if (insertRecord) {
            insert newTipologia;
        }
        return newTipologia;
    }
	//Create ACC_RT_CENTRO_MEMORA register
    public static Account createCentro(Account template, Boolean insertRecord) {
        Account newAccount = template != null ?
            template.clone(false, false, false, false) :
            new Account();

        newAccount.RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_CommonConstants.ACCOUNT, ONE_CommonConstants.ACC_RT_CENTRO_MEMORA);
        newAccount.Name = template?.Name != null ? template.Name : getRandomName();

        if (insertRecord) {
            insert newAccount;
        }

        return newAccount;
    }
    //Create centro register
    public static Account createCentroCemetary(Account template, Boolean insertRecord) {
        Account acc = createCentro(template, insertRecord);
        acc.ONE_Tipo__c = ONE_CommonConstants.MOMENTO_CEMENTERIO;
        acc.ONE_Codigo_Cementerio_CB__c = ONE_CommonConstants.CEMETERY_CODE_2;
        acc.ONE_Codigo_Cementerio_CB__c = ONE_CommonConstants.CEMETERY_CODE_2;
        update acc;
        return acc;
    }
    //Create Particular Account register
    public static Account createNonCompAccount(Account template, Boolean insertRecord) {
        Account newAccount = template != null ?
            template.clone(false, false, false, false) :
            new Account();

        newAccount.LastName = template?.LastName != null ? template.LastName : getRandomName(6);
        newAccount.Phone = template?.Phone != null ? template.Phone : getRandomName(6);

        System.debug(newAccount);

        if (insertRecord) {
            insert newAccount;
        }

        return newAccount;
    }
	//Create Account register
    public static Account createAccount(Account template, Boolean insertRecord) {
        Account newAccount = template != null ?
            template.clone(false, false, false, false) :
            new Account();

        newAccount.Name = template?.Name != null ? template.Name : getRandomName(6);
        newAccount.Phone = template?.Phone != null ? template.Phone : getRandomName(6);


        System.debug(newAccount);

        if (insertRecord) {
            insert newAccount;
        }

        return newAccount;
    }
	//Create Person Account register
    public static Account createPersonAccount(Account template, Boolean insertRecord) {
        Account newAccount = template != null ?
            template.clone(false, false, false, false) :
            new Account();

        newAccount.FirstName = template?.FirstName != null ? template.FirstName : getRandomName(6);
        newAccount.LastName = template?.LastName != null ? template.LastName : getRandomName(6);
        newAccount.Phone = template?.Phone != null ? template.Phone : getRandomName(6);
        newAccount.ONE_N_Documento__pc = template?.ONE_N_Documento__pc != null ? template.ONE_N_Documento__pc : getRandomName(5);
        newAccount.RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_CommonConstants.ACCOUNT, ONE_CommonConstants.ACC_RT_PERSON_ACCOUNT_PARTICULAR);

        System.debug(newAccount);

        if (insertRecord) {
            insert newAccount;
        }

        return newAccount;
    }
	//Create Account ACC_RT_OTRAS_CUENTAS register
    public static Account createBusinessAccount(Account template, Boolean insertRecord) {
        Account newAccount = template != null ?
                template.clone(false, false, false, false) :
                new Account();

        newAccount.Name = template?.Name != null ? template.Name : getRandomName(6);
        newAccount.ONE_CIF__c = template?.ONE_CIF__c != null ? template.ONE_CIF__c : getRandomName(5);
        newAccount.RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_CommonConstants.ACCOUNT, ONE_CommonConstants.ACC_RT_OTRAS_CUENTAS);

        if (insertRecord) {
            insert newAccount;
        }

        return newAccount;
    }
	//Utility to get random name for a certain lenght
    public static String getRandomName(Integer trim) {
        return getRandomName().substring(0, trim);
    }
	//Utility to get random name
    public static String getRandomName() {
        String hashString = '1000' + String.valueOf(Datetime.now().formatGMT('yyyy-MM-dd HH:mm:ss.SSS'));
        Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(hashString));
        String hexDigest = EncodingUtil.convertToHex(hash);
        return 'RN' + hexDigest.substring(0, 10);
    }
	//Create mockup integration endpoint
    public static ONE_Integration_endpoint__mdt createIntegrationEndpointMeta(ONE_Integration_endpoint__mdt template) {
        return new ONE_Integration_endpoint__mdt(
            DeveloperName = template?.DeveloperName != null ? template.DeveloperName : getRandomName(),
            ONE_Resource__c = template?.ONE_Resource__c != null ? template.ONE_Resource__c : '/' + getRandomName(),
            ONE_Active__c = template?.ONE_Active__c != null ? template.ONE_Active__c : true,
            ONE_Named_Credentials__c = template?.ONE_Named_Credentials__c != null ? template.ONE_Named_Credentials__c : getRandomName()
        );
    }
	//Utility to get random phone number
    public static String getRandomPhoneNumber() {
        return ('999' + String.valueOf((Math.round((Math.random() + 1) * 10000000))).substring(0, 6));
    }
	//Create contrato line register
    public static ONE_Contracto_Line_Item__c createContractoLineItem(ONE_Contracto_Line_Item__c template, Boolean insertRecord) {
        ONE_Contracto_Line_Item__c newContratoLineItem = template != null ?
            template?.clone(false, false, false, false) :
            new ONE_Contracto_Line_Item__c();

        if (insertRecord) {
            insert newContratoLineItem;
        }
        return newContratoLineItem;
    }
	//Create configuracion de tarea register
    public static ONE_Configuracion_De_Tarea__c createConfiguracionDeTarea(ONE_Configuracion_De_Tarea__c template, Boolean isInsert) {
        ONE_Configuracion_De_Tarea__c configuracionDeTarea = template != null ?
            template?.clone(false, false, false, false) :
            new ONE_Configuracion_De_Tarea__c();

        if (isInsert) {
            insert configuracionDeTarea;
        }
        return configuracionDeTarea;
    }
	//Create lugar register
    public static ONE_Lugar__c createLugar(ONE_Lugar__c template, Boolean insertRecord) {
        ONE_Lugar__c newLugar = template != null ?
            template?.clone(false, false, false, false) :
            new ONE_Lugar__c();

        if (insertRecord) {
            insert newLugar;
        }
        return newLugar;
    }
    //Create product model register
    public static ONE_Modelo__c createModelo(ONE_Modelo__c template, Boolean isInsert) {
        ONE_Modelo__c newModelo = template != null ?
                template?.clone(false, false, false, false) :
        new ONE_Modelo__c();

        if (isInsert) {
            insert newModelo;
        }
        return newModelo;
    }

    public static User createUser(String codigo, Boolean isInsert) {
        User u = new User(
            Username = 'username@memoradatafactory.com',
            Alias = 'user',
            Email = 'username@memoradatafactory.com',
            EmailEncodingKey = 'UTF-8',
            FirstName = 'First',
            LastName = 'Last',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'Europe/Prague',
            ONE_Codigo_Usuario_SAP__c = codigo,
            ProfileId = [SELECT Id FROM Profile LIMIT 1].Id
        );

        if (isInsert) {
            insert u;
        }
        return u;
    }
}