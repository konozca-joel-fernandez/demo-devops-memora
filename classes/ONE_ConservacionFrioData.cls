public with sharing class ONE_ConservacionFrioData {
    
    public String headerLogoUrl { public get; private set; }
    public String signatureUrl { public get; private set; }
    public List<ONE_ConservacionData> conservacionesList { public get; private set; }
    public String language { public get; private set; }
    public String fechaDocumento { public get; private set; }
    
    
    public ONE_ConservacionFrioData(String headerLogoUrl, String signatureUrl, List<ONE_ConservacionData> conservacionesList, String language, Datetime fechaDocumento){
        this.headerLogoUrl = headerLogoUrl;
        this.signatureUrl = signatureUrl;
        this.conservacionesList = conservacionesList;
        this.language = language;
        this.fechaDocumento = fechaDocumento == null ? '' : date.newinstance(fechaDocumento.year(), fechaDocumento.month(), fechaDocumento.day()).format();
    }
    
    public class ONE_ConservacionData {
        public String servicio { public get; private set; }
        public String nombreDifunto { public get; private set; }
        public String nombreFuneraria { public get; private set; }
        public String inicioDeposito { public get; private set; }
        public String inicioIncineracion { public get; private set; }
        
        public ONE_ConservacionData(String servicio, String nombreDifunto, String nombreFuneraria, Datetime inicioDeposito, Datetime inicioIncineracion){
            this.servicio = servicio;
            this.nombreDifunto = nombreDifunto;
            this.nombreFuneraria = nombreFuneraria;
            this.inicioDeposito = inicioDeposito == null ? '' : datetimeToString(inicioDeposito);
            this.inicioIncineracion = inicioIncineracion == null ? '' : datetimeToString(inicioIncineracion);
        }
        
        private String datetimeToString(Datetime fecha){
            return fecha.format('dd/MM/yyyy hh:mm');
        }
        
    }

}