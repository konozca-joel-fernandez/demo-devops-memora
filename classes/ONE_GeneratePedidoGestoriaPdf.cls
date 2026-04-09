public with sharing class ONE_GeneratePedidoGestoriaPdf {
    @InvocableMethod
    public static void generatePdf() {
    
        PageReference pdf = new PageReference('/apex/ONE_PedidoGestoriaPdf');
        ONE_PedidoGestoriaPdfController contr = new ONE_PedidoGestoriaPdfController();
        
    }
}