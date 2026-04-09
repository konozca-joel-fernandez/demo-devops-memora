/**
 * Created by mbujak003 on 25.02.2021.
 * 
 * USEFULL INFO:
 * If u add a new field to send to the APP chech if it's needed to send it too in ONE_SynchronizeWebService.apxc, to avoid the elimination on that field in the app on a sync.
 * 
 * CHANGES LOG:
 * Date        User             Change
 * ----------------------------------------
 * 05.04.23    Miguel Serrat    ORI-3723 : Tramos_PVA 
 * 17.04.23    Miguel Serrat    ORI-5053 : Send service RecordType to APP
 * 24.04.23    Miguel Serrat    ORI-3723 : Tramos_PVA on Particular or Comany 
 * 27.04.23    Miguel Serrat    ORI-3723 : Tramos_PVA on Center
 * 08.05.23    Miguel Serrat    ORI-4430 : Stock in APP
 * 03.07.23    Miguel Serrat    ORI-4281 : Catálogos a fecha de creación de presupuesto 
 * 17.07.23	   Miguel Serrat    ORI-4958 : SLI padre y Número de SLI
 * 10.12.24    Marc Pàmies		ORI-6202 : Centre Cementiris
 * 07.01.25	   Marc Pàmies		ORI-6692 : No Interlocutor
 * 29.01.25    Marc Pàmies		ORI-6742 : Visibilidad Precios
 * 25.03.25    Marc Pàmies		ORI-6793 : Consulta de Presupuestos
 * ----------------------------------------
 */

@RestResource(UrlMapping='/sqs')
global with sharing class ONE_ServiceQuoteSLIWebService {
    @HttpGet
    global static void getSqs() {
        String serviceId = RestContext.request?.params?.get('serviceId');
        String quoteId = RestContext.request?.params?.get('quoteId');

        if(serviceId == null ) {
            Map<String, Object> errKey2ErrVal = new Map<String, Object> {
                'message' => 'missing \'serviceId\' parameter',
                'code' => 400
            };

            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(errKey2ErrVal));
            RestContext.response.statusCode = Integer.valueOf(errKey2ErrVal.get('code'));
            return;
        }

        ONE_Expediente__c exp = [
            SELECT Id, Name, ONE_Difunto__c,ONE_Difunto__r.FirstName, ONE_Numero_de_Poliza__c,ONE_Numero_de_Siniestro__c,
                ONE_Difunto__r.LastName, ONE_Difunto__r.ONE_Fecha_de_nacimiento__pc, ONE_Difunto__r.ONE_Fecha_de_defuncion__pc,
                ONE_Tipo_De_Difunto__c, ONE_Difunto__r.ONE_Tipo_de_documento__pc, ONE_Difunto__r.ONE_N_Documento__pc,
                ONE_Declarante__r.FirstName, ONE_Declarante__r.LastName, ONE_Servicio__c, ONE_Tipo_De_Servicio__c,
                ONE_Compania__r.Name, ONE_Capital__c, ONE_Segmento_Seleccionado__c, ONE_Segmento_Seleccionado__r.Name,
                ONE_Acuerdo_Comercial__c, ONE_Acuerdo_Comercial__r.Name, ONE_Segmentacion__c, ONE_Catalogo_De_Precios__c,
                ONE_Catalogo_De_Precios__r.Name, ONE_Catalogo_De_Precios_Acuerdo__c, ONE_Catalogo_De_Precios_Acuerdo__r.Name, ONE_Idioma__c,
                ONE_Centro_Del_Expediente__r.ONE_Tipo_De_Impuesto__c, ONE_Lugar_De_Velacion__c, ONE_Lugar_De_Velacion__r.Name,
                ONE_Lugar_De_Velacion__r.ONE_Direccion__c, ONE_Lugar_De_Velacion__r.ONE_Codigo_Postal__c,
                ONE_Lugar_De_Velacion__r.ONE_Provincia__c, ONE_Lugar_De_Velacion__r.ONE_Pais__c, ONE_Sala_De_Velacion__r.Name, ONE_Inicio_Velacion__c,
                ONE_Fin_Velacion__c, ONE_Lugar_Ceremonia__c, ONE_Sala_Ceremonia__r.Name, ONE_Lugar_Ceremonia__r.ONE_Direccion__c,
                ONE_Lugar_Ceremonia__r.ONE_Codigo_Postal__c, ONE_Lugar_Ceremonia__r.ONE_Municipio_Direccion__c,
                ONE_Lugar_Ceremonia__r.ONE_Provincia__c, ONE_Lugar_Ceremonia__r.ONE_Pais__c, ONE_Lugar_De_Velacion__r.ONE_Municipio_Direccion__c,
                ONE_Inicio_Ceremonia__c, ONE_Fin_Ceremonia__c, ONE_Lugar_Incineracion__c, ONE_Lugar_Incineracion__r.Name,
                ONE_Lugar_Incineracion__r.ONE_Direccion__c, ONE_Lugar_Incineracion__r.ONE_Codigo_Postal__c,
                ONE_Lugar_Incineracion__r.ONE_Municipio_Direccion__c, ONE_Lugar_Incineracion__r.ONE_Provincia__c,
                ONE_Lugar_Incineracion__r.ONE_Pais__c, ONE_Horno_Incineracion__r.Name, ONE_Inicio_Incineracion__c,
                ONE_Fin_Incineracion__c, ONE_Destino_Final__c, ONE_Destino_Final__r.Name, ONE_Destino_Final__r.ONE_Direccion__c,
                ONE_Destino_Final__r.ONE_Codigo_Postal__c, ONE_Destino_Final__r.ONE_Municipio_Direccion__c,
                ONE_Destino_Final__r.ONE_Provincia__c, ONE_Destino_Final__r.ONE_Pais__c,  ONE_Hora_Destino_Final__c,
                ONE_Direccion_Velacion__c, ONE_Direccion_Ceremonia__c, ONE_Direccion_Incineracion__c, ONE_Direccion_Destino_Final__c,
                ONE_Codigo_Postal_Velacion__c, ONE_Codigo_Postal_Ceremonia__c, ONE_Codigo_Postal_Incineracion__c,
                ONE_Codigo_Postal_Destino_Final__c, ONE_Municipio_Velacion__c, ONE_Municipio_Ceremonia__c, ONE_Municipio_Incineracion__c,
                ONE_Municipio_Destino_Final__c, ONE_Provincia_Velacion__c, ONE_Provincia_Ceremonia__c, ONE_Priovincia_Incineracion__c,
                ONE_Provincia_Destino_Final__c, ONE_Pais_Velacion__c, ONE_Pais_Ceremonia__c, ONE_Pais_Incineracion__c,
                ONE_Pais_Destino_Final__c, ONE_Centro_Del_Expediente__c, ONE_Centro_Del_Expediente__r.Name, ONE_Lugar_De_Defuncion__c,
                ONE_Lugar_De_Defuncion__r.Name, ONE_Lugar_De_Defuncion__r.ONE_Direccion__c, ONE_Direccion_De_Defuncion__c,
                ONE_Lugar_De_Defuncion__r.ONE_Codigo_Postal__c, ONE_Codigo_Postal_De_Defuncion__c, ONE_Lugar_De_Defuncion__r.ONE_Municipio_Direccion__c,
                ONE_Municipio_De_Defuncion__c, ONE_Lugar_De_Defuncion__r.ONE_Provincia__c, ONE_Provincia_De_Defuncion__c,
                ONE_Lugar_De_Defuncion__r.ONE_Pais__c, ONE_Pais_De_Defuncion__c, OwnerId, Owner.FirstName, Owner.LastName,
                ONE_Lugar_Ceremonia__r.Name, ONE_Difunto__r.ONE_Fecha_De_Defuncion2__c, 
                ONE_Centro_Del_Expediente__r.ONE_Lugar__r.ONE_Lugar_Superior__r.ONE_Tramo_PVA_1_Comp__c, ONE_Centro_Del_Expediente__r.ONE_Lugar__r.ONE_Lugar_Superior__r.ONE_Tramo_PVA_2_Comp__c, 
                ONE_Centro_Del_Expediente__r.ONE_Lugar__r.ONE_Lugar_Superior__r.ONE_Tramo_PVA_1_Particular__c, ONE_Centro_Del_Expediente__r.ONE_Lugar__r.ONE_Lugar_Superior__r.ONE_Tramo_PVA_2_Particular__c, 
                ONE_Centro_Del_Expediente__r.ONE_Tramo_PVA_1_Comp__c, ONE_Centro_Del_Expediente__r.ONE_Tramo_PVA_2_Comp__c,
                ONE_Centro_Del_Expediente__r.ONE_Tramo_PVA_1_Particular__c, ONE_Centro_Del_Expediente__r.ONE_Tramo_PVA_2_Particular__c,
                ONE_Centro_Comision__r.ONE_Tramo_PVA_1_Comp__c, ONE_Centro_Comision__r.ONE_Tramo_PVA_2_Comp__c, 
                ONE_Centro_Comision__r.ONE_Tramo_PVA_1_Particular__c, ONE_Centro_Comision__r.ONE_Tramo_PVA_2_Particular__c, 
            	ONE_Centro_Del_Expediente__r.ONE_Comprobar_Stock_APP__c, recordType.developerName,
                ONE_Contador_SLI__c, ONE_Centro_Del_Expediente__r.ONE_Cementiris_De_Barcelona__c,
            	ONE_Centro_Del_Expediente__r.ONE_Lugar__r.ONE_Lugar_Superior__r.ONE_Visibilidad_Precios_APP__c
            FROM ONE_Expediente__c
            WHERE Id =: serviceId
        ];

        Map<Id, ONE_Interlocutor__c> interlocutors = new Map<Id, ONE_Interlocutor__c>([
            SELECT Id, ONE_Declarante__c, ONE_Relacion_con_el_difunto__c, ONE_Clasificacion__c, ONE_Contacto__c, ONE_Contacto__r.FirstName,
                ONE_Contacto__r.LastName, ONE_Contacto__r.ONE_Direccion__pc, ONE_Contacto__r.ONE_Codigo_Postal__pc, ONE_Contacto__r.ONE_Municipio__pc,
                ONE_Contacto__r.ONE_Provincia__pc, ONE_Contacto__r.ONE_Pais__pc, ONE_Contacto__r.ONE_Tipo_de_documento__pc, ONE_Contacto__r.ONE_N_Documento__pc
            FROM ONE_Interlocutor__c
            WHERE ONE_Expediente__c =: exp.Id
                AND ONE_Contacto__c != null
        ]);

        Map<Id, ONE_Presupuesto__c> quotes = new Map<Id, ONE_Presupuesto__c>([
            SELECT Id, Name, ONE_Expediente__c, ONE_Tipo_De_Presupuesto__c, ONE_Estado__c, ONE_Total_Importe_Presupuesto__c,
                ONE_Tipo_De_Venta__c, ONE_Interlocutor__c, ONE_Tipo_De_Contrato__c, ONE_Metodo_De_Pago__c, ONE_Presupuesto_preconfigurado__c,
                ONE_Tipo_De_Descuento_De_Cabecera__c, ONE_Valor_Del_Descuento__c, ONE_Motivo_Del_Descuento__c, ONE_Importe_Descuento_Cabecera__c,
                ONE_Creation_Date__c,ONE_Expediente__r.ONE_Compania__c, ONE_Expediente__r.ONE_Compania__r.ONE_Validacion_Capital__c, ONE_precios_creaci_n_presupuesto_APP__c,
            	ONE_No_Interlocutor__c, ONE_Quitar_Impuesto__c
            FROM ONE_Presupuesto__c
            WHERE ONE_Expediente__c =: exp.Id
                AND ONE_Tipo_De_Presupuesto__c != 'Presupuesto web'
        ]);
        
        Map<Id, List<ONE_Expediente_Line_Item__c>> quoteId2QuoteLines = new Map<Id, List<ONE_Expediente_Line_Item__c>>();
        Map<String, String> qliId2Tipologia = new Map<String, String>();
        Set<Id> eliIds = new Set<Id>();
        
        if(exp.ONE_Contador_SLI__c == null){
            exp.ONE_Contador_SLI__c = 0;
        }
        
        for(ONE_Expediente_Line_Item__c expLine : [
            SELECT Id, ONE_Presupuesto__c, ONE_Producto__c, ONE_Modelo__c, ONE_Cantidad__c, ONE_Estado__c, ONE_Entrada_De_Precio__c,
                ONE_Tipo_De_Descuento_De_Posicion__c, ONE_Valor_Del_Descuento_Posicion__c, ONE_Importe_Descuento_Posicion__c,
                ONE_Motivo_Del_Descuento_De_Linea__c, ONE_Importe_Base__c, ONE_Importe_Impuesto__c,
                ONE_Importe_Neto__c, ONE_Precio__c, ONE_Categorizacion_De_Linea__c, ONE_Suplido__c, ONE_No_Servir__c, ONE_Mejora_De_Compania__c,
                ONE_Impuesto__c, ONE_Producto__r.ONE_Tipologia_De_Producto_Lookup__c, 
                ONE_Numero_SLI__c, ONE_Numero_SLI_Padre__c, ONE_PosicionCB__c
            FROM ONE_Expediente_Line_Item__c
            WHERE ONE_Presupuesto__c IN: quotes.keySet()
                AND ONE_Estado__c != 'Cancelado'
        ]) {
            eliIds.add(expLine.Id);
            //para versiones antiguas que no tuvieran el campo relleno.
            
            if(expLine.ONE_Numero_SLI__c == null){
                expLine.ONE_Numero_SLI__c = exp.ONE_Contador_SLI__c;
                exp.ONE_Contador_SLI__c ++;
            }
            
            if(expLine.ONE_Producto__r.ONE_Tipologia_De_Producto_Lookup__c != null) {
                qliId2Tipologia.put(expLine.Id, expLine.ONE_Producto__r.ONE_Tipologia_De_Producto_Lookup__c);
            }
            if(!quoteId2QuoteLines.containsKey(expLine.ONE_Presupuesto__c)) {
                quoteId2QuoteLines.put(expLine.ONE_Presupuesto__c, new List<ONE_Expediente_Line_Item__c> { expLine });
            } else {
                quoteId2QuoteLines.get(expLine.ONE_Presupuesto__c).add(expLine);
            }
        }


        Map<String, List<String>> tipologia2Attributes = new Map<String, List<String>>();
        Set<String> allAttribs = new Set<String>();
        for(ONE_Atributo__c attrib : [
            SELECT Id, ONE_Campo_En_SF__c, ONE_Tipologia_De_Producto__c
            FROM ONE_Atributo__c
            WHERE ONE_Tipologia_De_Producto__c IN: qliId2Tipologia.values()
        ]) {
            if(attrib.ONE_Campo_En_SF__c != null && attrib.ONE_Campo_En_SF__c != '') {
                if(!tipologia2Attributes.containsKey(attrib.ONE_Tipologia_De_Producto__c)) {
                    tipologia2Attributes.put(attrib.ONE_Tipologia_De_Producto__c, new List<String> { attrib.ONE_Campo_En_SF__c });
                } else {
                    tipologia2Attributes.get(attrib.ONE_Tipologia_De_Producto__c).add(attrib.ONE_Campo_En_SF__c);
                }
                allAttribs.add(attrib.ONE_Campo_En_SF__c);
            }
        }

        String qr = '';

        if(allAttribs.size() > 0) {
            qr = 'SELECT Id, ONE_Producto__r.ONE_Tipologia_De_Producto_Lookup__c, ' + String.join(new List<String>(allAttribs), ', ') +
                ' FROM ONE_Expediente_Line_Item__c WHERE Id IN: eliIds';
        } else {
            qr = 'SELECT Id, ONE_Producto__r.ONE_Tipologia_De_Producto_Lookup__c ' + String.join(new List<String>(allAttribs), ', ') +
                ' FROM ONE_Expediente_Line_Item__c WHERE Id IN: eliIds';
        }

        System.debug(qr);

        Map<Id, ONE_Expediente_Line_Item__c> eliId2Eli = new Map<Id, ONE_Expediente_Line_Item__c>((List<ONE_Expediente_Line_Item__c>)Database.query(qr));

        List<InterlocutorData> interlocutorsData = new List<InterlocutorData>();

        List<QuoteData> quotesData = new List<QuoteData>();

        for(ONE_Presupuesto__c pres : quotes.values()) {
            List<ServiceLineItemData> slisData;
            if(quoteId2QuoteLines.containsKey(pres.Id)) {
                slisData = new List<ServiceLineItemData>();
                for(ONE_Expediente_Line_Item__c eli : quoteId2QuoteLines.get(pres.Id)) {
                    ServiceLineItemData slidata = new ServiceLineItemData(eli);
                    List<AttribData> attributes = new List<AttribData>();
                    if(tipologia2Attributes.containsKey(eli.ONE_Producto__r.ONE_Tipologia_De_Producto_Lookup__c)) {
                        for(String attribute : tipologia2Attributes.get(eli.ONE_Producto__r.ONE_Tipologia_De_Producto_Lookup__c)) {
                            if(eliId2Eli.containsKey(eli.Id)) {
                                attributes.add(new AttribData(((sObject)eliId2Eli.get(eli.Id)).get(attribute), attribute));
                            }
                        }
                    }
                    slidata.setAttributes(attributes);
                    slisData.add(slidata);
                }
            }
            
            Boolean aux = exp.ONE_Capital__c < pres.ONE_Total_Importe_Presupuesto__c;
            System.debug('importe: ' + pres.ONE_Total_Importe_Presupuesto__c + '   capital: ' + exp.ONE_Capital__c + ' ' + aux);
            
            QuoteData qd = new QuoteData(pres, slisData);
            qd.CapitalExceeded = aux;
            quotesData.add(qd);
        }

        for(ONE_Interlocutor__c interlocutor : interlocutors.values()) {
            interlocutorsData.add(new InterlocutorData(interlocutor));
        }
        
        ServiceData serviceData = new ServiceData(exp, quotesData, interlocutorsData, calcularImpuesto(quoteId, quotes));

        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(serviceData, false));
    }
    
    private static Boolean calcularImpuesto(String quoteId, Map<Id, ONE_Presupuesto__c> quotes){
        ONE_Presupuesto__c p = quotes.get(quoteId);
        Boolean calcularImpuesto = !quotes.get(quoteId).ONE_Quitar_Impuesto__c;
        return calcularImpuesto != null ? calcularImpuesto : false;
    }

    public class ServiceData {
        public String Id { get; set; }
        public String nServico { get; set; }
        public String IdDecesed { get; set; }
        public String nameDeceased { get; set; }
        public String surnameDeceased { get; set; }
        public Date birthDate { get; set; }
        public Datetime deceasedDate { get; set; }
        public String deceasedType { get; set; }
        public String typeDoc { get; set; }
        public String numberDoc { get; set; }
        public String clientType { get; set; }
        public String serviceType { get; set; }
        public String company { get; set; }
        public Decimal capital { get; set; }
        public String SegmentId { get; set; }
        public String SegmentName { get; set; }
        public String AgreementId { get; set; }
        public String AgreementName { get; set; }
        public String segmentType { get; set; }
        public String priceParticularId { get; set; }
        public String priceParticularName { get; set; }
        public String priceAgreementId { get; set; }
        public String priceAgreementName { get; set; }
        public String language { get; set; }
        public String taxes { get; set; }
        public String IdVelacion { get; set; }
        public String namePlaceVelacion { get; set; }
        public String salaVelacion { get; set; }
        public Datetime StartVelacion { get; set; }
        public Datetime EndVelacion { get; set; }
        public String AddressVelacion { get; set; }
        public String PostalCodeVelacion { get; set; }
        public String CityVelacion { get; set; }
        public String ProvinceVelacion { get; set; }
        public String CountryVelacion { get; set; }
        public String IdCeremonia { get; set; }
        public String namePlaceCeremonia { get; set; }
        public String salaCeremonia { get; set; }
        public Datetime StartCeremonia { get; set; }
        public Datetime EndCeremonia { get; set; }
        public String AddressCeremonia { get; set; }
        public String PostalCodeCeremonia { get; set; }
        public String CityCeremonia { get; set; }
        public String ProvinceCeremonia { get; set; }
        public String CountryCeremonia { get; set; }
        public String IdCrematorio { get; set; }
        public String namePlaceCrematorio { get; set; }
        public String hornoCrematorio { get; set; }
        public Datetime StartCrematorio { get; set; }
        public Datetime EndCrematorio { get; set; }
        public String AddressCrematorio { get; set; }
        public String PostalCodeCrematorio { get; set; }
        public String CityCrematorio { get; set; }
        public String ProvinceCrematorio { get; set; }
        public String CountryCrematorio { get; set; }
        public String IdFinalDestination { get; set; }
        public String namePlaceFinalDestination { get; set; }
        public Datetime StartFinalDestination { get; set; }
        public String AddressFinalDestination { get; set; }
        public String PostalCodeFinalDestination { get; set; }
        public String CityFinalDestination { get; set; }
        public String ProvinceFinalDestination { get; set; }
        public String CountryFinalDestination { get; set; }
        public String IdServiceOwner { get; set; }
        public String ServiceOwnerName { get; set; }
        public String ServiceOwnerSurname { get; set; }
        public String IdServiceWorkPlace { get; set; }
        public Boolean checkStockWorkPlace { get; set; }
        public String ServiceWorkPlaceName { get; set; }
        public String IdDeceasedPlace { get; set; }
        public String NameDeceasedPlace { get; set; }
        public String AddressDeceasedPlace { get; set; }
        public String PostalCodeDeceasedPlace { get; set; }
        public String CityFinalDeceasedPlace { get; set; }
        public String ProvinceDeceasedPlace { get; set; }
        public String CountryDeceasedPlace { get; set; }
        public String SiniestroNumber { get; set; }
        public String PolizaNumber { get; set; }
        public List<InterlocutorData> interlocutors { get; set; }
        public List<QuoteData> quotes { get; set; }
        public Decimal pvaStretch1 { get; set; } 
        public Decimal pvaStretch2 { get; set; } 
        public String serviceRecordType { get; set; }
        public Decimal SLICounter { get; set; }
        public Boolean centroCementiris { get; set; }
        public Boolean priceVisibility { get; set; }

        public ServiceData(ONE_Expediente__c exp, List<QuoteData> newQuotes, List<InterlocutorData> newInterlocutors, Boolean calcularImpuesto) {
            PolizaNumber = exp.ONE_Numero_de_Poliza__c;
            SiniestroNumber = exp.ONE_Numero_de_Siniestro__c;
            CountryDeceasedPlace = exp.ONE_Lugar_De_Defuncion__c == null ?
                exp.ONE_Pais_De_Defuncion__c : exp.ONE_Lugar_De_Defuncion__r.ONE_Pais__c;
            ProvinceDeceasedPlace = exp.ONE_Lugar_De_Defuncion__c == null ?
                exp.ONE_Provincia_De_Defuncion__c : exp.ONE_Lugar_De_Defuncion__r.ONE_Provincia__c;
            CityFinalDeceasedPlace = exp.ONE_Lugar_De_Defuncion__c == null ?
                exp.ONE_Municipio_De_Defuncion__c : exp.ONE_Lugar_De_Defuncion__r.ONE_Municipio_Direccion__c;
            PostalCodeDeceasedPlace = exp.ONE_Lugar_De_Defuncion__c == null ?
                exp.ONE_Codigo_Postal_De_Defuncion__c : exp.ONE_Lugar_De_Defuncion__r.ONE_Codigo_Postal__c;
            AddressDeceasedPlace = exp.ONE_Lugar_De_Defuncion__c == null ?
                exp.ONE_Direccion_De_Defuncion__c : exp.ONE_Lugar_De_Defuncion__r.ONE_Direccion__c;
            NameDeceasedPlace = exp.ONE_Lugar_De_Defuncion__r.Name;
            IdDeceasedPlace = exp.ONE_Lugar_De_Defuncion__c;
            ServiceWorkPlaceName = exp.ONE_Centro_Del_Expediente__r.Name;
            CheckStockWorkPlace = exp.ONE_Centro_Del_Expediente__r.ONE_Comprobar_Stock_APP__c;
            IdServiceWorkPlace = exp.ONE_Centro_Del_Expediente__c;
            ServiceOwnerSurname = exp.Owner.LastName;
            ServiceOwnerName = exp.Owner.FirstName;
            IdServiceOwner = exp.OwnerId;
            CountryFinalDestination = exp.ONE_Destino_Final__c == null ?
                exp.ONE_Pais_Destino_Final__c : exp.ONE_Destino_Final__r.ONE_Pais__c;
            ProvinceFinalDestination = exp.ONE_Destino_Final__c == null ?
                exp.ONE_Provincia_Destino_Final__c : exp.ONE_Destino_Final__r.ONE_Provincia__c;
            CityFinalDestination = exp.ONE_Destino_Final__c == null ?
                exp.ONE_Municipio_Destino_Final__c : exp.ONE_Destino_Final__r.ONE_Municipio_Direccion__c;
            PostalCodeFinalDestination = exp.ONE_Destino_Final__c == null ?
                exp.ONE_Codigo_Postal_Destino_Final__c : exp.ONE_Destino_Final__r.ONE_Codigo_Postal__c;
            AddressFinalDestination = exp.ONE_Destino_Final__c == null ?
                exp.ONE_Direccion_Destino_Final__c : exp.ONE_Destino_Final__r.ONE_Direccion__c;
            StartFinalDestination = exp.ONE_Hora_Destino_Final__c;
            namePlaceFinalDestination = exp.ONE_Destino_Final__r.Name;
            IdFinalDestination = exp.ONE_Destino_Final__c;
            CountryCrematorio = exp.ONE_Lugar_Incineracion__c == null ?
                exp.ONE_Pais_Incineracion__c : exp.ONE_Lugar_Incineracion__r.ONE_Pais__c;
            ProvinceCrematorio = exp.ONE_Lugar_Incineracion__c == null ?
                exp.ONE_Priovincia_Incineracion__c : exp.ONE_Lugar_Incineracion__r.ONE_Provincia__c;
            CityCrematorio = exp.ONE_Lugar_Incineracion__c == null ?
                exp.ONE_Municipio_Incineracion__c : exp.ONE_Lugar_Incineracion__r.ONE_Municipio_Direccion__c;
            PostalCodeCrematorio = exp.ONE_Lugar_Incineracion__c == null ?
                exp.ONE_Codigo_Postal_Incineracion__c : exp.ONE_Lugar_Incineracion__r.ONE_Codigo_Postal__c;
            AddressCrematorio = exp.ONE_Lugar_Incineracion__c == null ?
                exp.ONE_Direccion_Incineracion__c : exp.ONE_Lugar_Incineracion__r.ONE_Direccion__c;
            EndCrematorio = exp.ONE_Fin_Incineracion__c;
            StartCrematorio = exp.ONE_Inicio_Incineracion__c;
            hornoCrematorio = exp.ONE_Horno_Incineracion__r.Name;
            namePlaceCrematorio = exp.ONE_Lugar_Incineracion__r.Name;
            IdCrematorio = exp.ONE_Lugar_Incineracion__c;
            CountryCeremonia = exp.ONE_Lugar_Ceremonia__c == null ?
                exp.ONE_Pais_Ceremonia__c : exp.ONE_Lugar_Ceremonia__r.ONE_Pais__c;
            ProvinceCeremonia = exp.ONE_Lugar_Ceremonia__c == null ?
                exp.ONE_Provincia_Ceremonia__c : exp.ONE_Lugar_Ceremonia__r.ONE_Provincia__c;
            CityCeremonia = exp.ONE_Lugar_Ceremonia__c == null ?
                exp.ONE_Municipio_Ceremonia__c : exp.ONE_Lugar_Ceremonia__r.ONE_Municipio_Direccion__c;
            PostalCodeCeremonia = exp.ONE_Lugar_Ceremonia__c == null ?
                exp.ONE_Codigo_Postal_Ceremonia__c : exp.ONE_Lugar_Ceremonia__r.ONE_Codigo_Postal__c;
            AddressCeremonia = exp.ONE_Lugar_Ceremonia__c == null ?
                exp.ONE_Direccion_Ceremonia__c : exp.ONE_Lugar_Ceremonia__r.ONE_Direccion__c;
            EndCeremonia = exp.ONE_Fin_Ceremonia__c;
            StartCeremonia = exp.ONE_Inicio_Ceremonia__c;
            salaCeremonia = exp.ONE_Sala_Ceremonia__r.Name;
            namePlaceCeremonia = exp.ONE_Lugar_Ceremonia__r.Name;
            IdCeremonia = exp.ONE_Lugar_Ceremonia__c;
            CountryVelacion = exp.ONE_Lugar_De_Velacion__c == null ?
                exp.ONE_Pais_Velacion__c : exp.ONE_Lugar_De_Velacion__r.ONE_Pais__c;
            ProvinceVelacion = exp.ONE_Lugar_De_Velacion__c == null ?
                exp.ONE_Provincia_Velacion__c : exp.ONE_Lugar_De_Velacion__r.ONE_Provincia__c;
            CityVelacion = exp.ONE_Lugar_De_Velacion__c == null ?
                exp.ONE_Municipio_Velacion__c : exp.ONE_Lugar_De_Velacion__r.ONE_Municipio_Direccion__c;
            PostalCodeVelacion = exp.ONE_Lugar_De_Velacion__c == null ?
                exp.ONE_Codigo_Postal_Velacion__c : exp.ONE_Lugar_De_Velacion__r.ONE_Codigo_Postal__c;
            AddressVelacion = exp.ONE_Lugar_De_Velacion__c == null ?
                exp.ONE_Direccion_Velacion__c : exp.ONE_Lugar_De_Velacion__r.ONE_Direccion__c;
            EndVelacion = exp.ONE_Fin_Velacion__c;
            StartVelacion = exp.ONE_Inicio_Velacion__c;
            salaVelacion = exp.ONE_Sala_De_Velacion__r.Name;
            namePlaceVelacion = exp.ONE_Lugar_De_Velacion__r.Name;
            IdVelacion = exp.ONE_Lugar_De_Velacion__c;
            taxes = calcularImpuesto ? exp.ONE_Centro_Del_Expediente__r.ONE_Tipo_De_Impuesto__c : null;
            language = exp.ONE_Idioma__c;
            priceAgreementName = exp.ONE_Catalogo_De_Precios_Acuerdo__r.Name;
            priceAgreementId = exp.ONE_Catalogo_De_Precios_Acuerdo__c;
            priceParticularName = exp.ONE_Catalogo_De_Precios__r.Name;
            priceParticularId = exp.ONE_Catalogo_De_Precios__c;
            segmentType = exp.ONE_Segmentacion__c;
            AgreementName = exp.ONE_Acuerdo_Comercial__r.Name;
            AgreementId = exp.ONE_Acuerdo_Comercial__c;
            SegmentName = exp.ONE_Segmento_Seleccionado__r.Name;
            SegmentId = exp.ONE_Segmento_Seleccionado__c;
            capital = exp.ONE_Capital__c;
            company = exp.ONE_Compania__r.Name;
            serviceType = exp.ONE_Tipo_De_Servicio__c;
            clientType = exp.ONE_Servicio__c;
            numberDoc = exp.ONE_Difunto__r.ONE_N_Documento__pc;
            typeDoc = exp.ONE_Difunto__r.ONE_Tipo_de_documento__pc;
            deceasedType = exp.ONE_Tipo_De_Difunto__c;
            deceasedDate = exp.ONE_Difunto__r.ONE_Fecha_De_Defuncion2__c;
            birthDate = exp.ONE_Difunto__r.ONE_Fecha_de_nacimiento__pc;
            surnameDeceased = exp.ONE_Difunto__r.LastName;
            nameDeceased = exp.ONE_Difunto__r.Firstname;
            IdDecesed = exp.ONE_Difunto__c;
            nServico = exp.Name;
            Id = exp.Id;
            interlocutors = newInterlocutors;
            quotes = newQuotes;
            if (exp.ONE_Servicio__c == 'Particular') {
                if (exp.ONE_Centro_Comision__r.ONE_Tramo_PVA_1_Particular__c != null){ //SFB - centro de comisión
                    pvaStretch1 = exp.ONE_Centro_Comision__r.ONE_Tramo_PVA_1_Particular__c;
                } else if (exp.ONE_Centro_Del_Expediente__r.ONE_Tramo_PVA_1_Particular__c != null){ //CENTRO
                    pvaStretch1 = exp.ONE_Centro_Del_Expediente__r.ONE_Tramo_PVA_1_Particular__c;
                } else { // ZONA OPERATIVA
                    pvaStretch1 = exp.ONE_Centro_Del_Expediente__r.ONE_Lugar__r.ONE_Lugar_Superior__r.ONE_Tramo_PVA_1_Particular__c;
                }
                
                if (exp.ONE_Centro_Comision__r.ONE_Tramo_PVA_2_Particular__c != null){ //SFB - centro de comisión
                    pvaStretch2 = exp.ONE_Centro_Comision__r.ONE_Tramo_PVA_2_Particular__c;
                } else if (exp.ONE_Centro_Del_Expediente__r.ONE_Tramo_PVA_2_Particular__c != null){ //CENTRO
                    pvaStretch2 = exp.ONE_Centro_Del_Expediente__r.ONE_Tramo_PVA_2_Particular__c;
                } else { // ZONA OPERATIVA
                    pvaStretch2 = exp.ONE_Centro_Del_Expediente__r.ONE_Lugar__r.ONE_Lugar_Superior__r.ONE_Tramo_PVA_2_Particular__c;
                }
            } else {
                if (exp.ONE_Centro_Comision__r.ONE_Tramo_PVA_1_Comp__c != null){ //SFB - centro de comisión
                    pvaStretch1 = exp.ONE_Centro_Comision__r.ONE_Tramo_PVA_1_Comp__c;
                } else if (exp.ONE_Centro_Del_Expediente__r.ONE_Tramo_PVA_1_Comp__c != null){ //CENTRO
                    pvaStretch1 = exp.ONE_Centro_Del_Expediente__r.ONE_Tramo_PVA_1_Comp__c;
                } else { // ZONA OPERATIVA
                    pvaStretch1 = exp.ONE_Centro_Del_Expediente__r.ONE_Lugar__r.ONE_Lugar_Superior__r.ONE_Tramo_PVA_1_Comp__c;
                }
                
                if (exp.ONE_Centro_Comision__r.ONE_Tramo_PVA_2_Comp__c != null){ //SFB - centro de comisión
                    pvaStretch2 = exp.ONE_Centro_Comision__r.ONE_Tramo_PVA_2_Comp__c;
                } else if (exp.ONE_Centro_Del_Expediente__r.ONE_Tramo_PVA_2_Comp__c != null){ //CENTRO
                    pvaStretch2 = exp.ONE_Centro_Del_Expediente__r.ONE_Tramo_PVA_2_Comp__c;
                } else { // ZONA OPERATIVA
                    pvaStretch2 = exp.ONE_Centro_Del_Expediente__r.ONE_Lugar__r.ONE_Lugar_Superior__r.ONE_Tramo_PVA_2_Comp__c;
                }
            }
            
            serviceRecordType = exp.recordType.developerName;
            SLICounter = exp.ONE_Contador_SLI__c != null ? exp.ONE_Contador_SLI__c : 0.0;
            centroCementiris = exp.ONE_Centro_Del_Expediente__r.ONE_Cementiris_De_Barcelona__c;
            priceVisibility = exp.ONE_Centro_Del_Expediente__r.ONE_Lugar__r.ONE_Lugar_Superior__r.ONE_Visibilidad_Precios_APP__c;
        }
    }

    public Class InterlocutorData {
        public String Id { get; set; }
        public String Name { get; set; }
        public String Surname { get; set; }
        public Boolean Declarante { get; set; }
        public String IdContact { get; set; }
        public String AddressInterlocutor { get; set; }
        public String PostalCodeInterlocutor { get; set; }
        public String CityInterlocutor { get; set; }
        public String ProvinceInterlocutor { get; set; }
        public String CountryInterlocutor { get; set; }
        public String relation { get; set; }
        public String classification { get; set; }
        public String DocTypeInterlocutor { get; set; }
        public String NumberId { get; set; }

        public InterlocutorData(ONE_Interlocutor__c interlocutor) {
            Id = interlocutor.Id;
            Name = interlocutor.ONE_Contacto__r.FirstName;
            Surname = interlocutor.ONE_Contacto__r.LastName;
            Declarante = interlocutor.ONE_Declarante__c;
            IdContact = interlocutor.ONE_Contacto__c;
            AddressInterlocutor = interlocutor.ONE_Contacto__r.ONE_Direccion__pc;
            PostalCodeInterlocutor = interlocutor.ONE_Contacto__r.ONE_Codigo_Postal__pc;
            CityInterlocutor = interlocutor.ONE_Contacto__r.ONE_Municipio__pc;
            ProvinceInterlocutor = interlocutor.ONE_Contacto__r.ONE_Provincia__pc;
            CountryInterlocutor = interlocutor.ONE_Contacto__r.ONE_Pais__pc;
            relation = interlocutor.ONE_Relacion_con_el_difunto__c;
            classification = interlocutor.ONE_Clasificacion__c;
            DocTypeInterlocutor = interlocutor.ONE_Contacto__r.ONE_Tipo_de_documento__pc;
            NumberId = interlocutor.ONE_Contacto__r.ONE_N_Documento__pc;
        }
    }

    public class QuoteData {
        public String Id { get; set; }
        public String quoteName { get; set; }
        public String quoteType { get; set; }
        public String status { get; set; }
        public Decimal totalAmount { get; set; }
        public String salesType { get; set; }
        public String interlocutorId { get; set; }
        public String typeOfContract { get; set; }
        public String paymentMethod { get; set; }
        public Boolean preconfigured { get; set; }
        public String discountType { get; set; }
        public Decimal valueDiscount { get; set; }
        public Decimal freePrice { get; set; }
        public String discountReason { get; set; }
        public Date CreatedDate { get; set; }
        public List<ServiceLineItemData> Lines { get; set; }
        public Boolean CapitalExceeded { get; set; }
        public Boolean validateCapital { get; set; }
        public Boolean usesOriginalPricecatalog { get; set; }
        public Boolean noInterlocutor { get; set; }

        public QuoteData(ONE_Presupuesto__c quote, List<ServiceLineItemData> newLines) {
            Id = quote.Id;
            quoteName = quote.Name;
            quoteType = quote.ONE_Tipo_De_Presupuesto__c;
            status = quote.ONE_Estado__c;
            totalAmount = quote.ONE_Total_Importe_Presupuesto__c;
            salesType = quote.ONE_Tipo_De_Venta__c;
            interlocutorId = quote.ONE_Interlocutor__c;
            typeOfContract = quote.ONE_Tipo_De_Contrato__c;
            paymentMethod = quote.ONE_Metodo_De_Pago__c;
            preconfigured = quote.ONE_Presupuesto_preconfigurado__c;
            discountType = quote.ONE_Tipo_De_Descuento_De_Cabecera__c;
            valueDiscount = quote.ONE_Valor_Del_Descuento__c;
            discountReason = quote.ONE_Motivo_Del_Descuento__c;
            CreatedDate = quote.ONE_Creation_Date__c;
            freePrice = quote.ONE_Importe_Descuento_Cabecera__c;
            validateCapital=quote.ONE_Tipo_De_Presupuesto__c =='Presupuesto servicio completo' && quote.ONE_Expediente__r.ONE_Compania__c!=null && quote.ONE_Expediente__r.ONE_Compania__r.ONE_Validacion_Capital__c ? quote.ONE_Expediente__r.ONE_Compania__r.ONE_Validacion_Capital__c:false;
            usesOriginalPricecatalog=quote.ONE_precios_creaci_n_presupuesto_APP__c;
            noInterlocutor=quote.ONE_No_Interlocutor__c;
            Lines = newLines;
            System.debug('validateCapital: '+validateCapital);
        }
    }

    public class ServiceLineItemData {
        public String Id { get; set; }
        public String productId { get; set; }
        public String modelId { get; set; }
        public Decimal quantity { get; set; }
        public String status { get; set; }
        public String pricelisEntryId { get; set; }
        public String discountType { get; set; }
        public String discountReason { get; set; }
        public Decimal discountValue { get; set; }
        public Decimal basePrice { get; set; }
        public Decimal taxPrice { get; set; }
        public Decimal discountPrice { get; set; }
        public Decimal netPrice { get; set; }
        public Decimal totalPrice { get; set; }
        public String lineCategory { get; set; }
        public Boolean Suplido { get; set; }
        public Boolean NoServir { get; set; }
        public Boolean MejoraCompania { get; set; }
        public Decimal tax { get; set; }
        public List<AttribData> Atributos { get; set; }
        public Boolean queryStock { get; set; } 
        public Decimal SLINumber { get; set; }
        public Decimal parentSLINumber { get; set; }
        public Boolean posicionCB { get; set; }        

        public void setAttributes(List<AttribData> newAtributos) {
            Atributos = newAtributos;
        }

        public ServiceLineItemData(ONE_Expediente_Line_Item__c eli) {
            Id = eli.Id;
            productId = eli.ONE_Producto__c;
            modelId = eli.ONE_Modelo__c;
            quantity = eli.ONE_Cantidad__c;
            status = eli.ONE_Estado__c;
            pricelisEntryId = eli.ONE_Entrada_De_Precio__c;
            discountType = eli.ONE_Tipo_De_Descuento_De_Posicion__c;
            discountReason = eli.ONE_Motivo_Del_Descuento_De_Linea__c;
            discountValue = eli.ONE_Valor_Del_Descuento_Posicion__c;
            basePrice = eli.ONE_Suplido__c? eli.ONE_Importe_Neto__c : eli.ONE_Importe_Base__c;
            taxPrice = eli.ONE_Importe_Impuesto__c;
            discountPrice = eli.ONE_Importe_Descuento_Posicion__c;
            netPrice = eli.ONE_Importe_Neto__c;
            totalPrice = eli.ONE_Precio__c;
            lineCategory = eli.ONE_Categorizacion_De_Linea__c;
            Suplido = eli.ONE_Suplido__c;
            NoServir = eli.ONE_No_Servir__c;
            MejoraCompania = eli.ONE_Mejora_De_Compania__c;
            tax = eli.ONE_Impuesto__c;
            queryStock = true;
            SLINumber = eli.ONE_Numero_SLI__c;
            parentSLINumber = eli.ONE_Numero_SLI_Padre__c;
            posicionCB = eli.ONE_PosicionCB__C;
        }
    }

    public class AttribData {
        public Object Value { get; set; }
        public String APIName { get; set; }

        public AttribData(Object newValue, String newAPIName) {
            Value = newValue;
            APIName = newAPIName;
        }
    }
}