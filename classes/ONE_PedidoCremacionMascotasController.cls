public class ONE_PedidoCremacionMascotasController {
    Id pedidoId {get; set;}
    public String language {public get; private set;}
    public ONE_PedidoCremacionMascotasPDFService.MascotasData data {public get; private set;}

    public ONE_PedidoCremacionMascotasController() {
        pedidoId = ApexPages.currentPage().getParameters().get('pedidoId');
        language = ApexPages.currentPage().getParameters().get('language');
        setupData();
    }

    public void setupData() {
        
        ONE_Pedido_De_Proveedor__c pedido = selectPedidoDeProveedor(pedidoId);
        ONE_PedidoCremacionMascotasPDFService.MascotasData dataMascotas=new ONE_PedidoCremacionMascotasPDFService.MascotasData (
        pedido.ONE_Expediente__r?.ONE_Centro_Del_Expediente__r?.ONE_URL_logo__c!=null?pedido.ONE_Expediente__r?.ONE_Centro_Del_Expediente__r?.ONE_URL_logo__c:pedido.ONE_Expediente__r?.ONE_Centro_Del_Expediente__r?.ONE_Sociedad2__r?.ONE_URL_logo__c,
        '',
        pedido.ONE_Expediente__r?.Owner?.FirstName + ' ' + pedido.ONE_Expediente__r?.Owner?.LastName,
        System.today(),
        pedido.ONE_Expediente__r?.ONE_Nombre_Mascota__c,
        pedido.ONE_Expediente__r?.ONE_Tipo_de_Mascota__c,
        pedido.ONE_Expediente__r?.ONE_Raza__c,
        String.valueof(pedido.ONE_Expediente__r?.ONE_Edad_Mascota__c),
        pedido.ONE_Expediente__r?.ONE_Peso__c,
        pedido.ONE_Expediente__r?.ONE_N_Microchip__c,
        pedido.ONE_Expediente__r?.ONE_Fecha_De_Defuncion__c!=null? String.valueof((pedido.ONE_Expediente__r?.ONE_Fecha_De_Defuncion__c).date().format()):null,
        pedido.ONE_Expediente__r?.ONE_Direccion_De_Defuncion__c,
        pedido.ONE_Expediente__r?.ONE_Codigo_Postal_De_Defuncion__c,
        pedido.ONE_Expediente__r?.ONE_Municipio_De_Defuncion__c,
        pedido.ONE_Expediente__r?.ONE_Provincia_De_Defuncion__c,
        pedido.ONE_Expediente__r?.ONE_Declarante__r?.Firstname + ' ' +pedido.ONE_Expediente__r?.ONE_Declarante__r?.Lastname,
        pedido.ONE_Expediente__r?.ONE_Declarante__r?.Phone,
        pedido.ONE_Expediente__r?.ONE_Declarante__r?.ONE_Direccion__pc,
        pedido.ONE_Expediente__r?.ONE_Declarante__r?.ONE_Codigo_Postal__pc,
        pedido.ONE_Expediente__r?.ONE_Declarante__r?.ONE_Municipio__pc,
        pedido.ONE_Expediente__r?.ONE_Declarante__r?.ONE_Provincia__pc,
        pedido.ONE_Expediente__r?.ONE_Observaciones__c,
        pedido.ONE_Expediente__r?.ONE_Tipo_de_Incineracion__c,
        pedido.ONE_Expediente__r?.Name,
        pedido.Name,
        String.valueof(pedido.ONE_Fecha__c?.format()),
        pedido.ONE_Proveedor__r?.Name,
        pedido.ONE_Expediente__r?.ONE_Centro_Del_Expediente__r?.Name    
        );
        this.data = dataMascotas;
        
    }
    public static ONE_Pedido_De_Proveedor__c selectPedidoDeProveedor(Id pedidoId) {
        return [
                SELECT Id,
                       ONE_Expediente__r.ONE_Centro_Del_Expediente__r.Name,
                       ONE_Expediente__r.Owner.FirstName,
                       ONE_Expediente__r.Owner.LastName,
                       Name,
                       ONE_Fecha__c,
                       ONE_Proveedor__r.Name,
                       ONE_Expediente__r.Name,
                       ONE_Expediente__r.ONE_Difunto__r.FirstName,
                       ONE_Expediente__r.ONE_Difunto__r.LastName,
            		   ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_URL_logo__c,
                       ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.ONE_URL_logo__c,
                       ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.Name,
                       ONE_Expediente__r.ONE_Nombre_Mascota__c,
            		   ONE_Expediente__r.ONE_Tipo_de_Mascota__c,
            		   ONE_Expediente__r.ONE_Raza__c,
            		   ONE_Expediente__r.ONE_Edad_Mascota__c,
            		   ONE_Expediente__r.ONE_Peso__c,
            		   ONE_Expediente__r.ONE_N_Microchip__c,
                       ONE_Expediente__r.ONE_Fecha_De_Defuncion__c,
            		   ONE_Expediente__r.ONE_Direccion_De_Defuncion__c,
            		   ONE_Expediente__r.ONE_Codigo_Postal_De_Defuncion__c,
            		   ONE_Expediente__r.ONE_Municipio_De_Defuncion__c,
            		   toLabel(ONE_Expediente__r.ONE_Provincia_De_Defuncion__c),
            		   ONE_Expediente__r.ONE_Declarante__r.Firstname,
            		   ONE_Expediente__r.ONE_Declarante__r.Lastname,
            		   ONE_Expediente__r.ONE_Declarante__r.Phone,
            		   ONE_Expediente__r.ONE_Declarante__r.ONE_Direccion__pc,
            		   ONE_Expediente__r.ONE_Declarante__r.ONE_Codigo_Postal__pc,
            		   ONE_Expediente__r.ONE_Declarante__r.ONE_Municipio__pc,
            		   toLabel(ONE_Expediente__r.ONE_Declarante__r.ONE_Provincia__pc),
            		   ONE_Expediente__r.ONE_Observaciones__c,
					   ONE_Expediente__r.ONE_Tipo_de_Incineracion__c
            	FROM ONE_Pedido_De_Proveedor__c
                WHERE Id = :pedidoId
        ];
    }
}