/**
 * Created by mkuzak001 on 02.02.2021.
 */

public with sharing class ONE_FuneflorDeleteIntegrationCallout extends ONE_FuneflorIntegrationCallout {
    private static final String QUERY_REFCLI = 'refcli';
    private static final String QUERY_IDCLI = 'id_cli';
    public ONE_FuneflorDeleteIntegrationCallout(String endpointMetadataName, ONE_Integration.RestMethod restMethod, ONE_Pedido_De_Proveedor__c pedido) {
        super(endpointMetadataName, restMethod);
        validateRequest(pedido);
        pedido = ONE_FuneflorIntegrationHelper.selectPedidoDeProveedor(pedido.Id);
        putParam(QUERY_REFCLI, pedido.Name);
        putParam(QUERY_IDCLI, pedido.ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.ONE_Numero_Cliente_Funeflor__c);
        putHeader(QUERY_REFCLI, pedido.Name);
        putHeader(QUERY_IDCLI, pedido.ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.ONE_Numero_Cliente_Funeflor__c);
    }
    
    public void validateRequest(ONE_Pedido_De_Proveedor__c pedido) {
        if (pedido.Name == null) {
            throw new ONE_FuneflorIntegrationCalloutException(String.format(Label.FieldIsMandatory, new List<String>{'ONE_Pedido_De_Proveedor__c.Name'}));
        }
    }
}