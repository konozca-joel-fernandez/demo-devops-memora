/**
 * Created by mbujak003 on 04.02.2021.
 */

@RestResource(UrlMapping='/typology')
global without sharing class ONE_TopologyWebService {

    @HttpGet
    global static void getTypology() {

        String serviceId = RestContext.request?.params?.get('serviceId');

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

        ONE_Expediente__c servicio = [SELECT Id, ONE_Centro_Del_Expediente__r.ONE_Lugar__r.ONE_Lugar_Superior__c FROM ONE_Expediente__c
                                      WHERE Id = :serviceId
                                      LIMIT 1];

        Map<Id, List<ONE_Atributo__c>> tipoId2Attribute = new Map<Id, List<ONE_Atributo__c>>();
        Map<Id, List<ONE_Recurso__c>> attributeId2Resource = new Map<Id, List<ONE_Recurso__c>>();
        Map<Id, List<ONE_Valores_Picklist__c>> attributeId2Picklist = new Map<Id, List<ONE_Valores_Picklist__c>>();
        Set<Id> attributeIds = new Set<Id>();
        List<ONE_Recurso__c> piezasPorZona = new List<ONE_Recurso__c>();
        List<ONE_Recurso__c> piezasSinZona = new List<ONE_Recurso__c>();


        Map<Id, ONE_Tipologia_Producto__c> tipoId2Record = new Map<Id, ONE_Tipologia_Producto__c>(
            ONE_TipologiaProductoHelper.fetchTipologiaProductos()
        );

        for(ONE_Atributo__c attribute : ONE_AtributoHelper.fetchAttributesWIthProducts(tipoId2Record.keySet())) {
            if(!tipoId2Attribute.containsKey(attribute.ONE_Tipologia_De_Producto__c)) {
                tipoId2Attribute.put(attribute.ONE_Tipologia_De_Producto__c, new List<ONE_Atributo__c> { attribute });
            } else {
                tipoId2Attribute.get(attribute.ONE_Tipologia_De_Producto__c).add(attribute);
            }
            attributeIds.add(attribute.Id);
        }

        for(ONE_Recurso__c resource : ONE_RecursoHelper.fetchRecursosWithAttributes(attributeIds)) {
            if(!attributeId2Resource.containsKey(resource.ONE_Atributo__c)) {
                attributeId2Resource.put(resource.ONE_Atributo__c, new List<ONE_Recurso__c> { resource });
            } else {
                attributeId2Resource.get(resource.ONE_Atributo__c).add(resource);
            }
            if(resource.ONE_Lugar__c == servicio.ONE_Centro_Del_Expediente__r.ONE_Lugar__r.ONE_Lugar_Superior__c && resource.ONE_Tipo_De_Registro__c == '01') {
                piezasPorZona.add(resource);
            }
            if(resource.ONE_Lugar__c == null && resource.ONE_Tipo_De_Registro__c == '01') {
                piezasSinZona.add(resource);
            }
        }

        for(ONE_Valores_Picklist__c picklist : ONE_ValoresPicklistHelper.fetchValoresPicklistsWithAttributes(attributeIds)) {
            if(!attributeId2Picklist.containsKey(picklist.ONE_Atributo__c)) {
                attributeId2Picklist.put(picklist.ONE_Atributo__c, new List<ONE_Valores_Picklist__c> { picklist });
            } else {
                attributeId2Picklist.get(picklist.ONE_Atributo__c).add(picklist);
            }
        }

        List<TipologiaProducto> allTipos = new List<TipologiaProducto>();
        for(Id tipoId : tipoId2Record.keySet()) {
            List<Atributo> attributesDto = new List<Atributo>();
            if(tipoId2Attribute.containsKey(tipoId)) {
                List<ONE_Atributo__c> attributesForDto = tipoId2Attribute.get(tipoId);
                List<Recurso> resourcesDto = new List<Recurso>();
                List<ValoresPicklist> picklistsDto = new List<ValoresPicklist>();
                for(ONE_Atributo__c attributeForDto : attributesForDto) {
                    resourcesDto = new List<Recurso>();
                    if(attributeId2Resource.containsKey(attributeForDto.Id)) {
                        if(attributeForDto.Name == 'Piezas Seleccionadas') {
                            if(piezasPorZona.size() > 0){
                                for(ONE_Recurso__c resourceForDto : piezasPorZona) {
                                    resourcesDto.add(new Recurso(resourceForDto));
                                }
                            }
                            else {
                                for(ONE_Recurso__c resourceForDto : piezasSinZona) {
                                    resourcesDto.add(new Recurso(resourceForDto));
                                }
                            }
                        }
                        else{
                            for(ONE_Recurso__c resourceForDto : attributeId2Resource.get(attributeForDto.Id)) {
                                resourcesDto.add(new Recurso(resourceForDto));
                            }
                        }
                    }
                    if(attributeId2Picklist.containsKey(attributeForDto.Id)) {
                        picklistsDto = new List<ValoresPicklist>();
                        for(ONE_Valores_Picklist__c picklistForDto : attributeId2Picklist.get(attributeForDto.Id)) {
                            picklistsDto.add(new ValoresPicklist(picklistForDto));
                        }
                    }
                    attributesDto.add(new Atributo(attributeForDto, resourcesDto, picklistsDto));
                }
            }
            allTipos.add(new TipologiaProducto(tipoId2Record.get(tipoId), attributesDto));
        }
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(allTipos).replace('_x', ''));
    }

    public class Recurso {
        public String Id { get; private set; }
        public String Nombre { get; private set; }
        public String CategoriaESP { get; private set; }
        public String CategoriaCAT { get; private set; }
        public String CategoriaEUS { get; private set; }
        public String TipoDeRegistro { get; private set; }
        public String Descripcion { get; private set; }

        public Recurso(ONE_Recurso__c recurso) {
            Id = recurso.Id;
            Nombre = recurso.Name;
            Descripcion = recurso.ONE_Descripcion__c;
            TipoDeRegistro = recurso.ONE_Tipo_De_Registro__c;
            CategoriaESP = recurso.ONE_Categoria_ESP__c;
            CategoriaCAT = recurso.ONE_Categoria_CAT__c;
            CategoriaEUS = recurso.ONE_Categoria_EUS__c;
        }
    }

    public class Atributo { 
        public String Id { get; private set; }
        public String NombreESP { get; private set; }
        public String NombreCAT { get; private set; }
        public String NombreEUS { get; private set; }
        public Decimal Orden { get; private set; }
        public String TipologiaUX { get; private set; }
        public String CampoEnSF { get; private set; }
        public List<Recurso> Resources { get; private set; }
        public List<ValoresPicklist> Valorespicklist { get; private set; }
        public Boolean Requerido { get; private set; }

        public Atributo(ONE_Atributo__c atributo, List<Recurso> newResources, List<ValoresPicklist> newValoresPicklist) {
            Id = atributo.Id;
            NombreESP = atributo.ONE_Nombre_ESP__c;
            NombreCAT = atributo.ONE_Nombre_CAT__c;
            NombreEUS = atributo.ONE_Nombre_EUS__c;
            Orden = atributo.ONE_Orden__c;
            TipologiaUX = atributo.ONE_Tipologia_UX__c;
            CampoEnSF = atributo.ONE_Campo_En_SF__c;
            Resources = newResources;
            Valorespicklist = newValoresPicklist;
            Requerido = atributo.ONE_Requerido__c;
        }
    }

    public class ValoresPicklist {
        public String Id { get; set; }
        public String NombreESP { get; set; }
        public String NombreCAT { get; set; }
        public String NombreEUS { get; set; }
        public String Valor { get; set; }

        public ValoresPicklist(ONE_Valores_Picklist__c vPicklist) {
            Id = vPicklist.Id;
            NombreESP = vPicklist.ONE_Nombre_ESP__c;
            NombreCAT = vPicklist.ONE_Nombre_CAT__c;
            NombreEUS = vPicklist.ONE_Nombre_EUS__c;
            Valor = vPicklist.ONE_Valor__c;
        }
    }

    public class TipologiaProducto {
        public String Id { get; private set; }
        public String NombreESP { get; private set; }
        public String NombreCAT { get; private set; }
        public String NombreEUS { get; private set; }
        public Decimal Orden { get; private set; }
        public Boolean Cantidad { get; private set; }
        public Boolean SeveralLines { get; private set; }
        public String LocalizacionAtributos { get; private set; }
        public String Exception_x { get; private set; }
        public Boolean NoServirMejora { get; private set; }
        public List<Atributo> Attributes { get; private set; }

        public TipologiaProducto(ONE_Tipologia_Producto__c tipoProducto, List<Atributo> newAttributes) {
            Id = tipoProducto.Id;
            NombreESP = tipoProducto.ONE_Nombre_ESP__c;
            NombreCAT = tipoProducto.ONE_Nombre_CAT__c;
            NombreEUS = tipoProducto.ONE_Nombre_EUS__c;
            Orden = tipoProducto.ONE_Orden__c;
            SeveralLines = tipoProducto.ONE_Varias_lineas_producto_por_unidad__c;
            LocalizacionAtributos = tipoProducto.ONE_Localizacion_Atributos__c;
            Exception_x = tipoProducto.ONE_Excepcion__c;
            NoServirMejora = tipoProducto.ONE_Boton_No_Servir_Marcar_Como_Mejora__c;
            Cantidad = tipoProducto.ONE_Cantidad__c;
            Attributes = newAttributes;
        }
    }
}