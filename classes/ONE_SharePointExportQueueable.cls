public with sharing class ONE_SharePointExportQueueable implements Queueable, Database.AllowsCallouts {
    public void execute(QueueableContext qc) {
        Map<String, Object> params = new Map<String, Object>();

        Flow.Interview.ONE_Exportar_Lineas_de_Planificacion_a_SharePoint flow =
            new Flow.Interview.ONE_Exportar_Lineas_de_Planificacion_a_SharePoint(params);

        flow.start();
    }
}