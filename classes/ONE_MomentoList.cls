/**
 * Created by msulek003 on 14.04.2021.
 */

/*This class is to generate the Momento Object and all his corresponding agrupation, categories and total sumatory of the contracted lines in it*/

public with sharing class ONE_MomentoList {
    public  Decimal netoSum {public get; private set;} //Variable to store the sumatory of import of one particular category
    public  List<ONE_MomentoData> momentoList {public get; private set;} //Momento's list
    public List<String> agrupacionList {public get; private set;} //Agrupation list
    public Map<String, List<String>> categoriaMap {public get; private set;} //Categories list

    public ONE_MomentoList (List<ONE_Expediente_Line_Item__c> momentoLineItems, Map<Decimal, List<ONE_Expediente_Line_Item__c>> lineItemParentIdToChildMap,
        String language, List<String> agrupacionList, Map<String, List<String>> categoriaMap){
        this.agrupacionList = agrupacionList;
        this.categoriaMap = categoriaMap;
        netoSum = 0;
        momentoList = new List<ONE_MomentoData>();
        calculateMomentoList(momentoLineItems, lineItemParentIdToChildMap, language);
    }
	//Create momento's structure and them calls createPrestacionList() to add all the agrupations and categories
    public void calculateMomentoList (List<ONE_Expediente_Line_Item__c> momentoLineItems,
        Map<Decimal, List<ONE_Expediente_Line_Item__c>> lineItemParentIdToChildMap, String language) {
        momentoList = createPrestacionList(momentoLineItems, lineItemParentIdToChildMap, language);
    }

    //Add all service lines to the corresponding aggrupation and categories, calls createPrestacionItem() to add the services line to the correspoding places
    public List<ONE_MomentoData> createPrestacionList (
        List<ONE_Expediente_Line_Item__c> prestacionLineItems, 
        Map<Decimal, List<ONE_Expediente_Line_Item__c>> prestacionParentIdToChildMap, 
        String language
    ){

        List<ONE_MomentoData> prestacionList = new List<ONE_MomentoData>();
		//Iterate to all the agrupation and categories to add the contracted lines
        for(String agrupacionString: this.agrupacionList) {
            System.debug('Agrupacion: ' + agrupacionString);
            for(String categoriaName : this.categoriaMap.get(agrupacionString)){
                
                //Check the category in with the line shoul be added comparing the Name if the ONE_Categoria__c with the value indicated in the category in ONE_MomentoServiceConstants
                for(ONE_Expediente_Line_Item__c lineItem: prestacionLineItems) {
                    if(lineItem.ONE_Producto__r?.ONE_Categoria__r?.Name != null &&
                        lineItem.ONE_Producto__r?.ONE_Categoria__r?.Name.toLowerCase() == categoriaName.toLowerCase()){
                        prestacionList.add(createPrestacionItem(lineItem, prestacionParentIdToChildMap.get(lineItem.ONE_Numero_SLI__c), language)); // add service line into the category with the corresponding lenguage
                        if(lineItem.ONE_Importe_Neto__c != null){ //summatory to display the total value of that category in the document.
                            this.netoSum += lineItem.ONE_Importe_Neto__c;
                        }
                    }
                }
            }
        }
        return prestacionList;
    }
	//Method to add the service line into the category
    private ONE_MomentoData createPrestacionItem (ONE_Expediente_Line_Item__c lineItem, List<ONE_Expediente_Line_Item__c> childItems, String language) {
        ONE_MomentoData momentoDataItem = createLineItemRow(lineItem, language);

        if(childItems!= null && !childItems.isEmpty()){
            List<ONE_MomentoData> childList = new List<ONE_MomentoData>();
            for (ONE_Expediente_Line_Item__c childLineItem: childItems){
                childList.add(createPrestacionItem(childLineItem, null , language));
            }
            momentoDataItem.addChildList(childList);
        }
        return momentoDataItem;
    }
	
    //Populate data for each product line that is display in the corresponding aggrupation
    public static ONE_MomentoData createLineItemRow (ONE_Expediente_Line_Item__c lineItem, String language) {
        return new ONE_MomentoData (
            lineItem.ONE_Cantidad__c,
            lineItem.ONE_Texto_Banda_O_Lazo__c,
            lineItem.ONE_Precio__c,
            lineItem.ONE_Importe_Descuento_Posicion__c,
            lineItem.ONE_Impuesto__c,
            lineItem.ONE_Importe_Impuesto__c,
            lineItem.ONE_Importe_Neto__c,
            lineItem.ONE_Importe_Base__c,
            getProductName(lineItem, language)
        );
    }
	
    //Get name of the product that should be display in the correspoinding categories.
    private static String getProductName (ONE_Expediente_Line_Item__c lineItem, String language) {
        if(lineItem.ONE_Orden_de_venta__r.RecordType.DeveloperName=='ONE_OrdendeVenta_Gestoria' && language != null && (language == 'ES' || language == 'Spanish')){
            System.debug('INE ITEM: ' + lineItem.ONE_Producto__r.ONE_Descripcion_En_Castellano__c +' - '+ lineItem.ONE_Expediente__r.Name  +' - '+ (lineItem.ONE_Expediente__r.ONE_Difunto__r.Name!=null?lineItem.ONE_Expediente__r.ONE_Difunto__r.Name:'') + ' - '+ (lineItem.ONE_Expediente__r.ONE_Numero_de_Siniestro__c!=null?lineItem.ONE_Expediente__r.ONE_Numero_de_Siniestro__c:''));
            return lineItem.ONE_Producto__r.ONE_Descripcion_En_Castellano__c +' - '+ lineItem.ONE_Expediente__r.Name  +' - '+ (lineItem.ONE_Expediente__r.ONE_Difunto__r.Name!=null?lineItem.ONE_Expediente__r.ONE_Difunto__r.Name:'') + ' - '+ (lineItem.ONE_Expediente__r.ONE_Numero_de_Siniestro__c!=null?lineItem.ONE_Expediente__r.ONE_Numero_de_Siniestro__c:'');
        } else if(lineItem.ONE_Orden_de_venta__r.RecordType.DeveloperName=='ONE_OrdendeVenta_Gestoria' && language != null && (language == 'CA' || language == 'Castellano')){
            return lineItem.ONE_Producto__r.ONE_Descripcion_En_Catalan__c+' - '+ lineItem.ONE_Expediente__r.Name  +' - '+ lineItem.ONE_Expediente__r.ONE_Difunto__r.Name!=null?lineItem.ONE_Expediente__r.ONE_Difunto__r.Name:'' + ' - '+ lineItem.ONE_Expediente__r.ONE_Numero_de_Siniestro__c!=null?lineItem.ONE_Expediente__r.ONE_Numero_de_Siniestro__c:'';
        } else if(lineItem.ONE_Orden_de_venta__r.RecordType.DeveloperName=='ONE_OrdendeVenta_Gestoria' && language != null && (language == 'EU' || language == 'Euskera')){
            return lineItem.ONE_Producto__r.ONE_Descripcion_En_Euskera__c+' - '+ lineItem.ONE_Expediente__r.Name  + ' - '+ lineItem.ONE_Expediente__r.ONE_Difunto__r.Name!=null?lineItem.ONE_Expediente__r.ONE_Difunto__r.Name:'' + ' - '+ lineItem.ONE_Expediente__r.ONE_Numero_de_Siniestro__c!=null?lineItem.ONE_Expediente__r.ONE_Numero_de_Siniestro__c:'';
        } else if(lineItem.ONE_Orden_de_venta__r.RecordType.DeveloperName=='ONE_OrdendeVenta_Gestoria' && language != null && (language == 'EN_US' || language == 'Ingles')){
            return lineItem.ONE_Producto__r.ONE_Descripcion_En_Ingles__c+' - '+ lineItem.ONE_Expediente__r.Name  + ' - '+ lineItem.ONE_Expediente__r.ONE_Difunto__r.Name!=null?lineItem.ONE_Expediente__r.ONE_Difunto__r.Name:'' + ' - '+ lineItem.ONE_Expediente__r.ONE_Numero_de_Siniestro__c!=null?lineItem.ONE_Expediente__r.ONE_Numero_de_Siniestro__c:'';
        }  else if(language != null && (language == 'ES' || language == 'Spanish')){
            return lineItem.ONE_Producto__r.ONE_Descripcion_En_Castellano__c;
        } else if(language != null && (language == 'CA' || language == 'Castellano')){
            return lineItem.ONE_Producto__r.ONE_Descripcion_En_Catalan__c;
        } else if(language != null && (language == 'EU' || language == 'Euskera')){
            return lineItem.ONE_Producto__r.ONE_Descripcion_En_Euskera__c;
        } else if(language != null && (language == 'EN_US' || language == 'Ingles')){
            return lineItem.ONE_Producto__r.ONE_Descripcion_En_Ingles__c;
        }else {
            return '';
        }
    }
}