public with sharing class ONE_MonitorPedidosController {

    public class LineasWrapper {
        public Integer pageSize {get;set;}
        public Integer pageNumber {get;set;}
        public Integer totalRecords {get;set;}
        public Integer recordStart {get;set;}
        public Integer recordEnd {get;set;}
        public String soqlQuery {get;set;}
        public List<ONE_Tarea__c> lineasdePedido {get;set;}
        public List<ONE_Tarea__c> allLineasdePedido {get;set;}
    }

    @AuraEnabled
    public static String getLineas(String periodoFechaPedido, String codigoRetornoSAP, String estadoOV, List<String> estadosTarea, String proveedorId, List<String> centroIdList, List<String> servicioIdList, String productType, List<String> lugarIdList, String pedidoId, Integer pageSize, Integer pageNumber, Date fechaIniPedido, Date fechaFinPedido, String periodoFechaDefuncion, Date fechaIniDefuncion, Date fechaFinDefuncion, String sortBy, String sortDirection) {
        String jsonDT = '';
        List<ONE_Tarea__c> lineas = new List<ONE_Tarea__c>();
        List<ONE_Tarea__c> lineasPag = new List<ONE_Tarea__c>();
        List<AggregateResult> counter = new List<AggregateResult>();
        String sortField = '';


        List<String> fields = new List<String> {
            'Id',
            'Name',
            'ONE_Estado__c',
            'ONE_Pedido_De_Proveedor__r.Name',
            'ONE_Pedido_De_Proveedor__r.ONE_Proveedor__r.Name',
            'ONE_Proveedor__c',
            'ONE_Proveedor__r.Name',
            'ONE_Expediente__c',
            'ONE_Pedido_De_Proveedor__c',
            'ONE_Expediente__r.Name',
            'ONE_Tipo_De_Recurso__c',
            'ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Lugar__r.Name',
            'ONE_Pedido_De_Proveedor__r.ONE_Fecha__c',
            'ONE_Pedido_De_Proveedor__r.ONE_Fecha_contabilizaci_n__c',
            'ONE_Pedido_De_Proveedor__r.ONE_Codigo_Retorno_SAP__c',
            'ONE_Pedido_De_Proveedor__r.ONE_Fecha_Codigo_Retorno_SAP__c',
            'ONE_Producto__r.Name',
            'ONE_Producto__r.ONE_Tipologia_De_Producto_Lookup__r.Name',
            'ONE_Linea_De_Expediente__r.ONE_Cantidad__c',
            'ONE_Precio_De_Compra__c',
            'ONE_Margen__c',
            'ONE_Nombre_Y_Apellidos_Del_Difunto__c',
            'ONE_Fecha_De_Defuncion__c',
            'ONE_Linea_De_Expediente__r.ONE_Presupuesto__r.Name',
            'toLabel(ONE_Linea_De_Expediente__r.ONE_Presupuesto__r.ONE_Tipo_De_Presupuesto__c)',
            'ONE_Linea_De_Expediente__r.ONE_Orden_De_Venta__r.Name',
            'toLabel(ONE_Linea_De_Expediente__r.ONE_Orden_De_Venta__r.ONE_Estado_De_La_Orden_de_Venta__c)',
            'ONE_Linea_De_Expediente__r.ONE_Orden_De_Venta__r.ONE_Numero_de_factura__c',
            'ONE_Linea_De_Expediente__r.ONE_Orden_De_Venta__r.ONE_Fecha_De_Facturacion__c',
            'ONE_Linea_De_Expediente__r.ONE_Orden_De_Venta__r.ONE_Numero_Abono_Factura__c',
            'ONE_Linea_De_Expediente__r.ONE_Orden_De_Venta__r.ONE_Fecha_Hora_Del_Abono_Factura__c',
            'ONE_Linea_De_Expediente__r.Name',
            'ONE_Linea_De_Expediente__r.ONE_Importe_Base__c',
            'ONE_Linea_De_Expediente__r.ONE_Suplido__c'
        };

        List<String> filters = new List<String>();

        //filters.add('ONE_Pedido_De_Proveedor__c != null ');
        filters.add('ONE_Pedido_De_Proveedor__r.ONE_Metodo_De_Contacto_De_Proveedor__c != \'Aplicacion\' ');

        
        System.debug('revisando periodos de fecha');
        System.debug ('fechaIni intervalo: '+ fechaIniPedido + 'fechaFin intervalo: '+ fechaFinPedido);

        System.debug('Estado Tarea: ' + estadosTarea);
        
        /* FILTROS PERIODO PEDIDO */
        if (periodoFechaPedido == 'Mes actual') {
            filters.add('ONE_Pedido_De_Proveedor__r.ONE_Fecha__c = THIS_MONTH ');
        }
        else if (periodoFechaPedido == 'Mes anterior') {
            filters.add('ONE_Pedido_De_Proveedor__r.ONE_Fecha__c = LAST_MONTH ');
        }
        else if (periodoFechaPedido == 'Últimos 3 meses') {
            filters.add('ONE_Pedido_De_Proveedor__r.ONE_Fecha__c = LAST_N_MONTHS:3 ');
        }
        
        else if (periodoFechaPedido == 'Intérvalo de fechas') {
            System.debug('entro en intervalo');
            //System.debug('Current date: ' + String.valueOf(fechaIniPedido).removeEnd(' 00:00:00'));

            filters.add('ONE_Pedido_De_Proveedor__r.ONE_Fecha__c >= '+ String.valueOf(fechaIniPedido).removeEnd(' 00:00:00') + ' AND ONE_Pedido_De_Proveedor__r.ONE_Fecha__c <= '+ String.valueOf(fechaFinPedido).removeEnd(' 00:00:00'));
        }
        else if (periodoFechaPedido == 'Sin fecha de pedido') {
            filters.add('ONE_Pedido_De_Proveedor__r.ONE_Fecha__c = null');
        }

        /* FILTROS PERIODO DEFUNCION */
        if (periodoFechaDefuncion == 'Mes actual') {
            filters.add('ONE_Fecha_De_Defuncion__c = THIS_MONTH ');
        }
        else if (periodoFechaDefuncion == 'Mes anterior') {
            filters.add('ONE_Fecha_De_Defuncion__c = LAST_MONTH ');
        }
        else if (periodoFechaDefuncion == 'Últimos 3 meses') {
            filters.add('ONE_Fecha_De_Defuncion__c = LAST_N_MONTHS:3 ');
        }
        
        else if (periodoFechaDefuncion == 'Intérvalo de fechas') {
            System.debug('entro en intervalo');
            //System.debug('Current date: ' + String.valueOf(fechaIniPedido).removeEnd(' 00:00:00'));

            filters.add('ONE_Fecha_De_Defuncion__c >= '+ String.valueOf(fechaIniDefuncion).removeEnd(' 00:00:00') + ' AND ONE_Fecha_De_Defuncion__c <= '+ String.valueOf(fechaFinDefuncion).removeEnd(' 00:00:00'));
        }

        /* filtros codigo retorno SAP */

        if (codigoRetornoSAP == 'E8') {
            filters.add('ONE_Pedido_De_Proveedor__r.ONE_Codigo_Retorno_SAP__c = \'E8\' ');
        }
        else if (codigoRetornoSAP == 'Otros') {
            filters.add('ONE_Pedido_De_Proveedor__r.ONE_Codigo_Retorno_SAP__c != \'E8\' ');
        }

        /* Filtros estado Orden Venta */
        if (String.isNotBlank(estadoOV)) {
            filters.add('ONE_Linea_De_Expediente__r.ONE_Orden_De_Venta__r.ONE_Estado_De_La_Orden_de_Venta__c = \'' + estadoOV + '\'' );
        }

        /* Filtros estado Tarea */
        if (estadosTarea.size() > 0) {
            System.debug('Entramos en Estado Tarea: ' + estadosTarea);
            System.debug('Entramos en Estado Tarea2: ' + 'ONE_Estado__c IN ' + estadosTarea.toString().replace('(', '(\'').replace(', ', '\', \'').replace(')', '\')'));
            filters.add('ONE_Estado__c IN ' + estadosTarea.toString().replace('(', '(\'').replace(', ', '\', \'').replace(')', '\')'));
        }

        /* filtros Proveedor */
        if (String.isNotBlank(proveedorId)) {
            filters.add('ONE_Pedido_De_Proveedor__r.ONE_Proveedor__c = \'' + proveedorId + '\'');
        }

        /* filtros centros */
        if (centroIdList.size() > 0) {
            filters.add('ONE_Expediente__r.ONE_Centro_Del_Expediente__c IN ' + centroIdList.toString().replace('(', '(\'').replace(', ', '\', \'').replace(')', '\')'));
        }

        /* filtros tipo productos */
        if (String.isNotBlank(productType)) {
            filters.add('ONE_Producto__r.ONE_Tipologia_De_Producto_Lookup__r.Name = \'' + productType + '\'');
        }
        /*
        if (productoIdList.size() > 0) {
            filters.add('ONE_Producto__r.Id IN :productoIdList ');
        }*/
        
        /* filtros Servicios */
        if (servicioIdList.size() > 0) {
            filters.add('ONE_Expediente__c IN ' + servicioIdList.toString().replace('(', '(\'').replace(', ', '\', \'').replace(')', '\')'));
        }

        /* filtros Lugar */
        if (lugarIdList.size() > 0) {
            filters.add('(ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Lugar__c IN ' + lugarIdList.toString().replace('(', '(\'').replace(', ', '\', \'').replace(')', '\')') + ' OR ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Lugar__r.ONE_Lugar_superior__c IN ' + lugarIdList.toString().replace('(', '(\'').replace(', ', '\', \'').replace(')', '\')') + ' OR ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Lugar__r.ONE_Lugar_superior__r.ONE_Lugar_superior__c IN ' + lugarIdList.toString().replace('(', '(\'').replace(', ', '\', \'').replace(')', '\')') + ' OR ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Lugar__r.ONE_Lugar_superior__r.ONE_Lugar_superior__r.ONE_Lugar_superior__c IN ' + lugarIdList.toString().replace('(', '(\'').replace(', ', '\', \'').replace(')', '\')') + ')');
        }

        if (String.isNotBlank(pedidoId)) {
            filters.add('ONE_Pedido_De_Proveedor__c = \'' + pedidoId + '\'');
        }

        Integer offset = (pageNumber - 1) * pageSize;

        filters.add('ONE_Tipo_De_Recurso__c = \'Proveedor\' ');

        /* Sort fields */ 
        if (String.isNotBlank(sortBy)) {
            if (sortBy == 'tareaURL') {
                sortField = 'Name';
            }
            else if (sortBy == 'pedidoURL') {
                sortField = 'ONE_Pedido_De_Proveedor__r.Name';
            }
            else if (sortBy == 'proveedorURL') {
                sortField = 'ONE_Proveedor__r.Name';
            }
            else if (sortBy == 'servicioURL') {
                sortField = 'ONE_Expediente__r.Name';
            }
            else if (sortBy == 'nombreDifunto') {
                sortField = 'ONE_Nombre_Y_Apellidos_Del_Difunto__c';
            }
            else if (sortBy == 'fechaDefuncion') {
                sortField = 'ONE_Fecha_De_Defuncion__c';
            }
            else if (sortBy == 'lugarURL') {
                sortField = 'ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Lugar__r.Name';
            }
            else if (sortBy == 'codigoRetornoSAP') {
                sortField = 'ONE_Pedido_De_Proveedor__r.ONE_Codigo_Retorno_SAP__c';
            }
            else if (sortBy == 'fechaCodigoRetornoSAP') {
                sortField = 'ONE_Pedido_De_Proveedor__r.ONE_Fecha_Codigo_Retorno_SAP__c';
            }
            else if (sortBy == 'productoURL') {
                sortField = 'ONE_Producto__r.Name';
            }
            else if (sortBy == 'fechaPedido') {
                sortField = 'ONE_Pedido_De_Proveedor__r.ONE_Fecha__c';
            }
            else if (sortBy == 'fechaContabilizacion') {
                sortField = 'ONE_Pedido_De_Proveedor__r.ONE_Fecha_contabilizaci_n__c';
            }
            else if (sortBy == 'estadoOV') {
                sortField = 'ONE_Linea_De_Expediente__r.ONE_Orden_De_Venta__r.ONE_Estado_De_La_Orden_de_Venta__c';
            }
            else if (sortBy == 'estadoTarea') {
                sortField = 'ONE_Estado__c';
            }
            else if (sortBy == 'fechaFacturacionOV') {
                sortField = 'ONE_Linea_De_Expediente__r.ONE_Orden_De_Venta__r.ONE_Fecha_De_Facturacion__c';
            }
            else if (sortBy == 'fechaAbonoOV') {
                sortField = 'ONE_Linea_De_Expediente__r.ONE_Orden_De_Venta__r.ONE_Fecha_Hora_Del_Abono_Factura__c';
            }
            else if (sortBy == 'sliURL') {
                sortField = 'ONE_Linea_De_Expediente__r.Name';
            }
        }
        
        else {
            sortField = 'ONE_Pedido_De_Proveedor__r.ONE_Fecha__c';

        }
        String soqlCounter = String.format('SELECT COUNT(Id) ct FROM ONE_Tarea__c WHERE ({0})', new List<String> {
            String.join(filters, ' AND ')
        });

        String soql = String.format('SELECT {0} FROM ONE_Tarea__c WHERE ({1}) ORDER BY ' + sortField + ' ' + sortDirection + ' NULLS LAST', new List<String> {
            String.join(fields, ', '), String.join(filters, ' AND ')
        });
        //OR ONE_Pedido_De_Proveedor__r.ONE_Fecha__c = null
        String soqlPagination = String.format('SELECT {0} FROM ONE_Tarea__c WHERE ({1}) ORDER BY '+ sortField + ' ' + sortDirection + ' NULLS LAST' + ' LIMIT ' + pageSize + ' OFFSET '+ offset , new List<String> {
            String.join(fields, ', '), String.join(filters, ' AND ')
        });

        system.debug('soql :: '+soql);
        system.debug('soqlPagination :: '+soqlPagination);
		
        counter = Database.query(soqlCounter);
        System.debug(counter);
        if ((decimal)counter[0].get('ct') > 50000) {
            CalloutException e = new CalloutException();
            e.setMessage('Este filtro tiene demasiados registros como resultado. Por favor, añade más filtros para realizar una búsqueda más óptima');
            System.debug(e);
    		throw e;
        } 

        lineas = Database.query(soql);
        lineasPag = Database.query(soqlPagination);
        
        System.debug ('SOQL: ' + soql);
        System.debug ('SOQL PAG: '+ soqlPagination);
        System.debug ('centroIdList: '+ centroIdList);
        //Offset for SOQL pagination
        
        Integer totalRecords = lineas.size();
        Integer recordEnd = pageSize * pageNumber;

        LineasWrapper paginationLineas = new LineasWrapper();
        paginationLineas.pageSize = pageSize;
        paginationLineas.pageNumber = pageNumber;
        if (totalRecords > 0) paginationLineas.recordStart = offset+1;
        else paginationLineas.recordStart = offset;
        paginationLineas.recordEnd = totalRecords >= recordEnd ? recordEnd : totalRecords;
        paginationLineas.totalRecords = totalRecords;
        paginationLineas.soqlQuery = soql;

        paginationLineas.lineasdePedido = lineasPag;
        //paginationLineas.allLineasdePedido = lineas;
        jsonDT = JSON.serialize(paginationLineas);
        System.debug('JSON is:' + jsonDT);
        return jsonDT;
    }

    @AuraEnabled
    public static List<ONE_Tarea__c> getAllLineas(String soql){
        List<ONE_Tarea__c> lineas = new List<ONE_Tarea__c>();
        lineas = Database.query(soql);
        return lineas;
    }
    
    @AuraEnabled
    public static void updateLineas(String lineasToUpdate) {

        system.debug('lineasToUpdate :: ' + lineasToUpdate);

        List<LineaPedido> lineasPedido = (List<LineaPedido>) JSON.deserialize(lineasToUpdate, List<LineaPedido>.class);

        system.debug('lineasPedido :: ' + lineasPedido);

        Set<Id> lineaIds = new Set<Id>();
        Map<Id, Id> lineaIdPedidoIdMap = new Map<Id, Id>();
        Map<Id, Id> lineaIdSLIIdMap = new Map<Id, Id>();
        List<ONE_Tarea__c> tareasToUpdate = new List<ONE_Tarea__c>();
        List<ONE_Pedido_De_Proveedor__c> pedidosToUpdate = new List<ONE_Pedido_De_Proveedor__c>();
        //Map<Id, ONE_Pedido_De_Proveedor__c> pedidosE8 = new Map<Id, ONE_Pedido_De_Proveedor__c>();

        for(LineaPedido lineaPedido : lineasPedido) {
            lineaIds.add(lineaPedido.id);
        }

        for(ONE_Tarea__c lineaWithPedido : [SELECT Id, ONE_Pedido_De_Proveedor__c, ONE_Linea_De_Expediente__c FROM ONE_Tarea__c WHERE Id IN :lineaIds]) {
            lineaIdPedidoIdMap.put(lineaWithPedido.Id, lineaWithPedido.ONE_Pedido_De_Proveedor__c);
        }

        Map<Id, ONE_Pedido_De_Proveedor__c> pedidosE8 = new Map<Id, ONE_Pedido_De_Proveedor__c>([SELECT Id FROM ONE_Pedido_De_Proveedor__c WHERE ONE_Codigo_Retorno_SAP__c = 'E8' AND Id IN :lineaIdPedidoIdMap.values()]);
        
        for(LineaPedido lineaPedido : lineasPedido) {

            ONE_Tarea__c tareaToUpdate = new ONE_Tarea__c(Id = lineaPedido.id);
            ONE_Pedido_De_Proveedor__c pedidoToUpdate = new ONE_Pedido_De_Proveedor__c(Id = lineaIdPedidoIdMap.get(lineaPedido.id));
            Set<Id> alreadyIncludedPedidoIds = (new Map<Id,ONE_Pedido_De_Proveedor__c>(pedidosToUpdate)).keySet();

            if(pedidosE8.containsKey(pedidoToUpdate.Id)){
                throw new DuplicatedPedidoException('No se puede actualizar un pedido con Código Retorno SAP igual a E8');
            } 

            // Línea de pedido fields
            if (lineaPedido.precioCompra != null) {
                tareaToUpdate.ONE_Precio_De_Compra__c = lineaPedido.precioCompra;
            }

            // Pedido fields
            if (lineaPedido.fechaPedido != null) {
                if (alreadyIncludedPedidoIds.contains(lineaIdPedidoIdMap.get(lineaPedido.id))) {
                    //throw new DuplicatedPedidoException('No es posible modificar un mismo pedido desde diferentes líneas de pedido.');
                }
                else {
                    pedidoToUpdate.ONE_Fecha__c = lineaPedido.fechaPedido;
                }
            }
            if (lineaPedido.fechaContabilizacion != null) {
                if (alreadyIncludedPedidoIds.contains(lineaIdPedidoIdMap.get(lineaPedido.id))) {
                    //throw new DuplicatedPedidoException('No es posible modificar un mismo pedido desde diferentes líneas de pedido.');
                }
                else {
                    pedidoToUpdate.ONE_Fecha_contabilizaci_n__c = lineaPedido.fechaContabilizacion;
                }
            }

            tareasToUpdate.add(tareaToUpdate);
            if (!alreadyIncludedPedidoIds.contains(lineaIdPedidoIdMap.get(lineaPedido.id))) pedidosToUpdate.add(pedidoToUpdate);
           
        }

        update tareasToUpdate;
        update pedidosToUpdate;
    }

    public class LineaPedido {
        public String id { get; private set; }
        public Date fechaPedido { get; private set; }
        public Date fechaContabilizacion { get; private set; }
        public Decimal precioCompra { get; private set; }
        public Decimal importeBaseSLI { get; private set; }
        public String codigoRetornoSAP { get; private set; }
    }

    public class DuplicatedPedidoException extends Exception {}

    @AuraEnabled(cacheable=true scope='global')
    public static List<LookupSearchResult> proveedorSearch(String searchTerm, List<String> selectedIds) {
        
        // Prepare query parameters
        searchTerm += '*';

        // Execute search query
        List<List<SObject>> searchResults = [
            FIND :searchTerm
            IN NAME FIELDS
            RETURNING
                Account(
                    Id, Name, ONE_ID_Proveedor_SAP__c, ONE_CIF__c
                    WHERE
                        Id NOT IN :selectedIds 
                        AND RecordType.DeveloperName = 'ONE_Otras_Cuentas'
                        AND ONE_Proveedor__c = true
                )
        ];

        // Prepare results
        List<LookupSearchResult> results = new List<LookupSearchResult>();

        // Extract Accounts & convert them into LookupSearchResult
        String accountIcon = 'standard:account';
        Account[] accounts = (List<Account>) searchResults[0];
        for (Account account : accounts) {
            String subtitle = account.ONE_ID_Proveedor_SAP__c + ' • ' + account.ONE_CIF__c;
            results.add(new LookupSearchResult(account.Id, 'Account', accountIcon, account.Name, subtitle));
        }

        // Optionnaly sort all results on title
        results.sort();

        return results;
    }

    @AuraEnabled(cacheable=true scope='global')
    public static List<LookupSearchResult> centroSearch(String searchTerm, List<String> selectedIds) {
        
        // Prepare query parameters
        searchTerm += '*';

        // Execute search query
        List<List<SObject>> searchResults = [
            FIND :searchTerm
            IN NAME FIELDS
            RETURNING
                Account(
                    Id, Name, ONE_Centro_Memora_Codigo_SAP__c, ONE_Lugar__r.ONE_Lugar_Superior__r.Name
                    WHERE
                        Id NOT IN :selectedIds 
                        AND RecordType.DeveloperName = 'ONE_Centro_Memora'
                )
        ];

        // Prepare results
        List<LookupSearchResult> results = new List<LookupSearchResult>();

        // Extract Accounts & convert them into LookupSearchResult
        String accountIcon = 'standard:account';
        Account[] accounts = (List<Account>) searchResults[0];
        for (Account account : accounts) {
            String subtitle = account.ONE_Centro_Memora_Codigo_SAP__c + ' • ' + account.ONE_Lugar__r.ONE_Lugar_Superior__r.Name;
            results.add(new LookupSearchResult(account.Id, 'Account', accountIcon, account.Name, subtitle));
        }

        // Optionnaly sort all results on title
        results.sort();

        return results;
    }

    @AuraEnabled(cacheable=true scope='global')
    public static List<LookupSearchResult> servicioSearch(String searchTerm, List<String> selectedIds) {
        
        // Prepare query parameters
        searchTerm += '*';

        // Execute search query
        List<List<SObject>> searchResults = [
            FIND :searchTerm
            IN NAME FIELDS
            RETURNING
                ONE_Expediente__c(
                    Id, Name, ONE_Centro_Del_Expediente__r.Name, ONE_Difunto__r.Name
                    WHERE
                        Id NOT IN :selectedIds 
                        AND RecordType.DeveloperName = 'ONE_Servicio_Defuncion'
                )
        ];

        // Prepare results
        List<LookupSearchResult> results = new List<LookupSearchResult>();

        // Extract Servicios & convert them into LookupSearchResult
        String servicioIcon = 'custom:custom15';
        ONE_Expediente__c[] servicios = (List<ONE_Expediente__c>) searchResults[0];
        for (ONE_Expediente__c servicio : servicios) {
            String subtitle = servicio.ONE_Difunto__r.Name + ' • ' + servicio.ONE_Centro_Del_Expediente__r.Name;
            results.add(new LookupSearchResult(servicio.Id, 'ONE_Expediente__c', servicioIcon, servicio.Name, subtitle));
        }

        // Optionnaly sort all results on title
        results.sort();

        return results;
    }

    /*
    @AuraEnabled(cacheable=true scope='global')
    public static List<LookupSearchResult> productoSearch(String searchTerm, List<String> selectedIds) {
        
        // Prepare query parameters
        searchTerm += '*';

        // Execute search query
        List<List<SObject>> searchResults = [
            FIND :searchTerm
            IN NAME FIELDS
            RETURNING
            ONE_Producto__c(
                    Id, Name
                    WHERE
                        Id NOT IN :selectedIds 
                )
        ];

        // Prepare results
        List<LookupSearchResult> results = new List<LookupSearchResult>();

        // Extract Accounts & convert them into LookupSearchResult
        String productoIcon = 'custom:custom29';
        ONE_Producto__c[] productos = (List<ONE_Producto__c>) searchResults[0];
        for (ONE_Producto__c producto : productos) {
            String subtitle = producto.Id;
            results.add(new LookupSearchResult(producto.Id, 'Producto', productoIcon, producto.Name, subtitle));
        }

        // Optionnaly sort all results on title
        results.sort();

        return results;
    }*/
    @AuraEnabled(cacheable=true scope='global')
    public static List<String> getTypeProducts () {

        List<String> typeNames = new List<String>();

        List<ONE_Tipologia_Producto__c> productsType = [SELECT Name from ONE_Tipologia_Producto__c];


        for (ONE_Tipologia_Producto__c type : productsType) {
            typeNames.add(type.Name);
        }
        typeNames.sort();
        System.debug ('typeNames. ' + typeNames);
        return typeNames;
    }

    @AuraEnabled(cacheable=true scope='global')
    public static List<LookupSearchResult> lugarSearch(String searchTerm, List<String> selectedIds) {
        
        // Prepare query parameters
        searchTerm += '*';

        // Execute search query
        List<List<SObject>> searchResults = [
            FIND :searchTerm
            IN NAME FIELDS
            RETURNING
            ONE_Lugar__c(
                    Id, Name
                    WHERE
                        Id NOT IN :selectedIds 
                )
        ];

        System.debug('SEARCH RESULTS: '+ searchResults);

        // Prepare results
        List<LookupSearchResult> results = new List<LookupSearchResult>();

        // Extract Servicios & convert them into LookupSearchResult
        String lugarIcon = 'custom:custom24';   
        ONE_Lugar__c[] lugares = (List<ONE_Lugar__c>) searchResults[0];
        for (ONE_Lugar__c lugar : lugares) {
            String subtitle = ' '; //+ lugar.Account_r.Name;
            results.add(new LookupSearchResult(lugar.Id, 'ONE_Lugar__c', lugarIcon, lugar.Name, subtitle));
        }

        // Optionnaly sort all results on title
        results.sort();
        System.debug('results: '+ results);
        return results;
    }

    @AuraEnabled(cacheable=true scope='global')
    public static List<LookupSearchResult> pedidoSearch(String searchTerm, List<String> selectedIds) {
        
        // Prepare query parameters
        searchTerm += '*';

        // Execute search query
        List<List<SObject>> searchResults = [
            FIND :searchTerm
            IN NAME FIELDS
            RETURNING
                ONE_Pedido_De_Proveedor__c(
                    Id, Name
                    WHERE
                        Id NOT IN :selectedIds 
                )
        ];

        // Prepare results
        List<LookupSearchResult> results = new List<LookupSearchResult>();

        // Extract Accounts & convert them into LookupSearchResult
        String pedidoIcon = 'custom:custom41';
        ONE_Pedido_De_Proveedor__c[] pedidos = (List<ONE_Pedido_De_Proveedor__c>) searchResults[0];
        for (ONE_Pedido_De_Proveedor__c pedido : pedidos) {
            String subtitle = pedido.Name;
            results.add(new LookupSearchResult(pedido.Id, 'ONE_Pedido_De_Proveedor__c', pedidoIcon, pedido.Name, subtitle));
        }

        // Optionnaly sort all results on title
        results.sort();

        return results;
    }
}