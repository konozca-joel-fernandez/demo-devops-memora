/**
 * Created by msulek003 on 13.04.2021.
 */

public with sharing class ONE_MomentoService {
	
    //Query all the information needed to generate the documents based on a Presupuesto ID
    public static ONE_PresupuestoComercialData.MomentoListData getMomentoLists (Id presupuestoId, String language){

        List<ONE_Expediente_Line_Item__c> allLineItems = ONE_MomentoSelector.getAllRelatedLineItems(presupuestoId);//!uery all service lines for the particular presupuesto ID.
        Map<String, List<ONE_Expediente_Line_Item__c>> momentoNameToMomentoLineItems = createMomentoNameToMomentoLineItemsMap(allLineItems);//Create list with the momento's name.
        List<ONE_Expediente_Line_Item__c> prestacionLineItemsWithParents = ONE_MomentoSelector.getPrestacionLineItemsWithParents(presupuestoId);//Query all parents service lines for the particular presupuesto ID.
        Map<Decimal, List<ONE_Expediente_Line_Item__c>> parentIdToChildMap = createParentIdToChildMap(prestacionLineItemsWithParents); // Map parents product with his corresponding child to display in the document.

        ONE_PresupuestoComercialData.MomentoListData momentoListData = createAllMomentoList(momentoNameToMomentoLineItems, parentIdToChildMap, language); // Create momento structure.
        return momentoListData;
    }
    
    //Query all the information needed to generate the documents based on a Orden de Venta ID
    public static ONE_PresupuestoComercialData.MomentoListData getFacturaMomentoLists (Id ordenDeVentaId, String language){

        List<ONE_Expediente_Line_Item__c> allLineItems = ONE_MomentoSelector.getAllRelatedFacturaLineItems(ordenDeVentaId);//Query all service lines for the particular Sales Order ID.
        Map<String, List<ONE_Expediente_Line_Item__c>> momentoNameToMomentoLineItems = createMomentoNameToMomentoLineItemsMap(allLineItems);//Create list with the momento's name.
        List<ONE_Expediente_Line_Item__c> prestacionLineItemsWithParents = ONE_MomentoSelector.getFacturaLineItemsWithParents(ordenDeVentaId);//Query all parents service lines for the particular Sales Order ID.
        Map<Decimal, List<ONE_Expediente_Line_Item__c>> parentIdToChildMap = createParentIdToChildMap(prestacionLineItemsWithParents);//Map parents product with his corresponding child to display in the document.

        ONE_PresupuestoComercialData.MomentoListData momentoListData = createAllMomentoList(momentoNameToMomentoLineItems, parentIdToChildMap, language);// Create momento structure.
        return momentoListData;
    }

    //Query all the information needed to generate the documents based on a Abono Parcial ID
    public static ONE_PresupuestoComercialData.MomentoListData getAbonoParcialMomentoLists (Id abonoParcialId, String documentType, String language){

        List<ONE_Expediente_Line_Item__c> allLineItems = ONE_MomentoSelector.getAllRelatedAbonoParcialLineItems(abonoParcialId, documentType);//Query all service lines for the particular Abono Parcial ID.
        Map<String, List<ONE_Expediente_Line_Item__c>> momentoNameToMomentoLineItems = createMomentoNameToMomentoLineItemsMap(allLineItems);//Create list with the momento's name.
        List<ONE_Expediente_Line_Item__c> prestacionLineItemsWithParents = ONE_MomentoSelector.getAbonoParcialLineItemsWithParents(abonoParcialId, documentType);//Query all parents service lines for the particular Abono Parcial ID.
        Map<Decimal, List<ONE_Expediente_Line_Item__c>> parentIdToChildMap = createParentIdToChildMap(prestacionLineItemsWithParents);//Map parents product with his corresponding child to display in the document.

        ONE_PresupuestoComercialData.MomentoListData momentoListData = createAllMomentoList(momentoNameToMomentoLineItems, parentIdToChildMap, language);// Create momento structure.
        return momentoListData;
    }

    public static Map<List<ONE_MomentoData>, Boolean> getDescuentosLists(Id presupuestoId, String language) { //Query product discounts for the document generation based on the input Presupuesto ID
        List<ONE_Expediente_Line_Item__c> descLineItems = ONE_MomentoSelector.getAllDescuentosLineItems(presupuestoId);
        return new Map<List<ONE_MomentoData>, Boolean>{createSimpleLineItemList(descLineItems, language) => checkIfDescuentosApplied(descLineItems)};
    }

    public static Map<List<ONE_MomentoData>, Boolean> getSuplidosLists(Id presupuestoId, String language){ //Query product type Suplidos for the document generation based on the input Presupuesto ID
        List<ONE_Expediente_Line_Item__c> suplidosLineItems = ONE_MomentoSelector.getAllSuplidosLineItems(presupuestoId);
        return new Map<List<ONE_MomentoData>, Boolean>{createSimpleLineItemList(suplidosLineItems, language) => checkIfDescuentosApplied(suplidosLineItems)};
    }

    public static Map<List<ONE_MomentoData>, Boolean> getFacturaDescuentosLists(Id ordenDeVentaId, String language){ //Query product discounts for the document generation based on the input Sales Order ID
        List<ONE_Expediente_Line_Item__c> descLineItems = ONE_MomentoSelector.getAllFacturaDescuentosLineItems(ordenDeVentaId);
        return new Map<List<ONE_MomentoData>, Boolean>{createSimpleLineItemList(descLineItems, language) => checkIfDescuentosApplied(descLineItems)};
    }

    public static Map<List<ONE_MomentoData>, Boolean> getFacturaSuplidosLists(Id ordenDeVentaId, String language){ //Query product for the document generation based on the input Sales Order ID
        List<ONE_Expediente_Line_Item__c> suplidosLineItems = ONE_MomentoSelector.getAllFacturaSuplidosLineItems(ordenDeVentaId);
        return new Map<List<ONE_MomentoData>, Boolean>{createSimpleLineItemList(suplidosLineItems, language) => checkIfDescuentosApplied(suplidosLineItems)};
    }

    public static Map<List<ONE_MomentoData>, Boolean> getAbonoParcialDescuentosLists(Id abonoParcialId, String documentType, String language){ //Query product discounts for the document generation based on the input Abono Parcial ID
        List<ONE_Expediente_Line_Item__c> descLineItems = ONE_MomentoSelector.getAllAbonoParcialDescuentosLineItems(abonoParcialId, documentType);
        return new Map<List<ONE_MomentoData>, Boolean>{createSimpleLineItemList(descLineItems, language) => checkIfDescuentosApplied(descLineItems)};
    }

    public static Map<List<ONE_MomentoData>, Boolean> getAbonoParcialSuplidosLists(Id abonoParcialId, String documentType, String language){ //Query product for the document generation based on the input Abono Parcial ID
        List<ONE_Expediente_Line_Item__c> suplidosLineItems = ONE_MomentoSelector.getAllAbonoParcialSuplidosLineItems(abonoParcialId, documentType);
        return new Map<List<ONE_MomentoData>, Boolean>{createSimpleLineItemList(suplidosLineItems, language) => checkIfDescuentosApplied(suplidosLineItems)};
    }

    //Create all Moments, Aggrupation and Categories.
    private static ONE_PresupuestoComercialData.MomentoListData createAllMomentoList ( 
        Map<String, List<ONE_Expediente_Line_Item__c>> momentoNameToMomentoLineItems,
        Map<Decimal, List<ONE_Expediente_Line_Item__c>> parentIdToChildMap, 
        String language
    ){
        System.debug('MOMENTO MAP SIZE: ' + momentoNameToMomentoLineItems.size());
        System.debug('MOMENTO MAP: ' + momentoNameToMomentoLineItems);
        
        List <ONE_MomentoList> momentoList = new List <ONE_MomentoList>();
		
        //Create Prestación Momento Structure
        ONE_MomentoList prestacionList = new ONE_MomentoList(
            momentoNameToMomentoLineItems.get(ONE_MomentoServiceConstants.PRESTACION_SERVICO_MOMENT.toLowerCase()),
            parentIdToChildMap,
            language,
            ONE_MomentoServiceConstants.PRESTACION_SERVICO_AGRUPACION_LIST,
            ONE_MomentoServiceConstants.PRESTACION_SERVICO_CATEGORIA_MAP
        );
        //Create Velación Momento Structure
        ONE_MomentoList velacionList = new ONE_MomentoList(momentoNameToMomentoLineItems.get(ONE_MomentoServiceConstants.VELACION_SERVICO_MOMENT.toLowerCase()), parentIdToChildMap,
            language, ONE_MomentoServiceConstants.VELACION_SERVICO_AGRUPACION_LIST, ONE_MomentoServiceConstants.VELACION_SERVICO_CATEGORIA_MAP);
        //Create Ceremonia Momento Structure
        ONE_MomentoList ceremoniaList = new ONE_MomentoList(momentoNameToMomentoLineItems.get(ONE_MomentoServiceConstants.CEREMONIA_SERVICO_MOMENT.toLowerCase()), parentIdToChildMap,
            language, ONE_MomentoServiceConstants.CEREMONIA_SERVICO_AGRUPACION_LIST, ONE_MomentoServiceConstants.CEREMONIA_SERVICO_CATEGORIA_MAP);
        //Create Arte Florar Momento Structure
        ONE_MomentoList arteFloralList = new ONE_MomentoList(momentoNameToMomentoLineItems.get(ONE_MomentoServiceConstants.ARTE_FLORAL_SERVICO_MOMENT.toLowerCase()), parentIdToChildMap,
            language, ONE_MomentoServiceConstants.ARTE_FLORAL_SERVICO_AGRUPACION_LIST, ONE_MomentoServiceConstants.ARTE_FLORAL_SERVICO_CATEGORIA_MAP);
        //Create Recuerdos Momento Structure
        ONE_MomentoList productosRecurdoList = new ONE_MomentoList(momentoNameToMomentoLineItems.get(ONE_MomentoServiceConstants.PRODUCTOS_RECUERDO_SERVICO_MOMENT.toLowerCase()), parentIdToChildMap,
            language, ONE_MomentoServiceConstants.PRODUCTOS_RECUERDO_SERVICO_AGRUPACION_LIST, ONE_MomentoServiceConstants.PRODUCTOS_RECUERDO_SERVICO_CATEGORIA_MAP);
        //Create Traslado Momento Structure
        ONE_MomentoList trasladosList = new ONE_MomentoList(momentoNameToMomentoLineItems.get(ONE_MomentoServiceConstants.TRASLADOS_SERVICO_MOMENT.toLowerCase()), parentIdToChildMap,
            language, ONE_MomentoServiceConstants.TRASLADOS_SERVICO_AGRUPACION_LIST, ONE_MomentoServiceConstants.TRASLADOS_SERVICO_CATEGORIA_MAP);
        //Create Seguimos Acompañandote Momento Structure
        ONE_MomentoList seguimosAcompanandoteList = new ONE_MomentoList(momentoNameToMomentoLineItems.get(ONE_MomentoServiceConstants.SEGUIMOS_ACOMPANANDOTE_SERVICO_MOMENT.toLowerCase()),
            parentIdToChildMap, language, ONE_MomentoServiceConstants.SEGUIMOS_ACOMPANANDOTE_SERVICO_AGRUPACION_LIST,
            ONE_MomentoServiceConstants.SEGUIMOS_ACOMPANANDOTE_SERVICO_CATEGORIA_MAP);
        //Create Comunicación Momento Structure
        ONE_MomentoList comunicacionList = new ONE_MomentoList(momentoNameToMomentoLineItems.get(ONE_MomentoServiceConstants.COMUNICACION_SERVICO_MOMENT.toLowerCase()), parentIdToChildMap,
            language, ONE_MomentoServiceConstants.COMUNICACION_SERVICO_AGRUPACION_LIST, ONE_MomentoServiceConstants.COMUNICACION_SERVICO_CATEGORIA_MAP);
        //Create Destino Incinearción Momento Structure
        ONE_MomentoList destinoIncineracionList = new ONE_MomentoList(momentoNameToMomentoLineItems.get(ONE_MomentoServiceConstants.DESTINO_INCINERACION_SERVICO_MOMENT.toLowerCase()),
            parentIdToChildMap, language, ONE_MomentoServiceConstants.DESTINO_INCINERACION_SERVICO_AGRUPACION_LIST,
            ONE_MomentoServiceConstants.DESTINO_INCINERACION_SERVICO_CATEGORIA_MAP);
        //Create Desitono Inhumación Momento Structure
        ONE_MomentoList destinoInhumacionList = new ONE_MomentoList(momentoNameToMomentoLineItems.get(ONE_MomentoServiceConstants.DESTINO_INHUMACION_SERVICO_MOMENT.toLowerCase()),
            parentIdToChildMap, language, ONE_MomentoServiceConstants.DESTINO_INHUMACION_SERVICO_AGRUPACION_LIST,
            ONE_MomentoServiceConstants.DESTINO_INHUMACION_SERVICO_CATEGORIA_MAP);
        //Create Servicio Compañia Momento Structure
        ONE_MomentoList serviciosCompaniasList = new ONE_MomentoList(momentoNameToMomentoLineItems.get(ONE_MomentoServiceConstants.OTROS_SERVICO_MOMENT.toLowerCase()),
            parentIdToChildMap, language, ONE_MomentoServiceConstants.SERVICIOS_COMPANIAS_SERVICO_AGRUPACION_LIST,
            ONE_MomentoServiceConstants.SERVICIOS_COMPANIAS_SERVICO_CATEGORIA_MAP); 
        
        //Return all creted Momentos and his corresponding total sumatory of imports    
        return new ONE_PresupuestoComercialData.MomentoListData(
            prestacionList.momentoList, prestacionList.netoSum,
            velacionList.momentoList, velacionList.netoSum,
            ceremoniaList.momentoList, ceremoniaList.netoSum,
            arteFloralList.momentoList, arteFloralList.netoSum,
            productosRecurdoList.momentoList, productosRecurdoList.netoSum,
            trasladosList.momentoList, trasladosList.netoSum,
            seguimosAcompanandoteList.momentoList, seguimosAcompanandoteList.netoSum,
            comunicacionList.momentoList, comunicacionList.netoSum,
            destinoIncineracionList.momentoList, destinoIncineracionList.netoSum,
            destinoInhumacionList.momentoList, destinoInhumacionList.netoSum,
            serviciosCompaniasList.momentoList, serviciosCompaniasList.netoSum
        );

    }

	//Create lines of the document based on the inputs service line and language.
    private static List<ONE_MomentoData> createSimpleLineItemList(List<ONE_Expediente_Line_Item__c> lineItems, String language){
        List<ONE_MomentoData> lineItemList = new List<ONE_MomentoData>();
        for(ONE_Expediente_Line_Item__c lineItem: lineItems){
            lineItemList.add(ONE_MomentoList.createLineItemRow(lineItem, language));
        }
        return lineItemList;
    }

    private static Boolean checkIfDescuentosApplied(List<ONE_Expediente_Line_Item__c> listOfOneExpedienteLineItem) {
        for (ONE_Expediente_Line_Item__c item : listOfOneExpedienteLineItem) {
            if (item.ONE_Importe_Descuento_Posicion__c != null && item.ONE_Importe_Descuento_Posicion__c != 0) {
                return true;
            }
        }
        return false;
    }

	//Create parent product lines of the document based on the inputs service line and language.
    private static  Map<Decimal, List<ONE_Expediente_Line_Item__c>> createParentIdToChildMap (List<ONE_Expediente_Line_Item__c> lineItems){
        Map<Decimal, List<ONE_Expediente_Line_Item__c>> prestacionParentIdToChildMap = new Map<Decimal, List<ONE_Expediente_Line_Item__c>>();
        
        for(ONE_Expediente_Line_Item__c childLineItem: lineItems){
            if(prestacionParentIdToChildMap.get(childLineItem.ONE_Numero_SLI_Padre__c) == null){
                prestacionParentIdToChildMap.put(childLineItem.ONE_Numero_SLI_Padre__c, new List<ONE_Expediente_Line_Item__c>{childLineItem});
            } else{
                prestacionParentIdToChildMap.get(childLineItem.ONE_Numero_SLI_Padre__c).add(childLineItem);
            }
        }
        return prestacionParentIdToChildMap;
    }

    public static Map<String, List<ONE_Expediente_Line_Item__c>> createMomentoNameToMomentoLineItemsMap( 
        List<ONE_Expediente_Line_Item__c> allLineItems
    ){
        Map<String, List<ONE_Expediente_Line_Item__c>> momentoNameToMomentoLineItems = new Map<String, List<ONE_Expediente_Line_Item__c>>();
        for(String momentName: ONE_MomentoServiceConstants.MOMENTOS_NAMES){
            momentoNameToMomentoLineItems.put(momentName.toLowerCase(), new List<ONE_Expediente_Line_Item__c>());
        }

        for(ONE_Expediente_Line_Item__c lineItem: allLineItems){
            String lineItemMomentoName = lineItem.ONE_Producto__r?.ONE_Categoria__r?.ONE_Agrupacion__r?.ONE_Momento__r?.Name;
            if(lineItemMomentoName != null 
               && momentoNameToMomentoLineItems.keySet().contains(lineItemMomentoName.toLowerCase())
               && lineItem.ONE_Numero_SLI_Padre__c == null
            ){
                momentoNameToMomentoLineItems.get(lineItemMomentoName.toLowerCase()).add(lineItem);
            }
        }

        return momentoNameToMomentoLineItems;
    }
}