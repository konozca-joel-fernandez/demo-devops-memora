public class ONE_NecrologicaData {
    
    //Variables needed to store the data that will be show in the PDF    
    public String documentCode {public get; private set;}
    public String Fecha_Now {public get; private set;} 
    public List<NecrologicaData> expedientList {public get; public set;}
    public String ONE_Doc_Sociedad_Nombre {public get; private set;}
    public String language {public get; private set;}
    
    public class NecrologicaData {
        
        public String ONE_Doc_Difunto {public get; private set;} 
        public String ONE_Doc_Gestoria_Fecha_Hora_Defuncion {public get; private set;} 
        public String ONE_Doc_Fecha_Ceremonia {public get; private set;} 
        public String ONE_Doc_Direccion_ceremonia {public get; private set;} 
        public Integer ONE_Doc_Gestoria_Edad {public get; private set;} 
        public String ONE_Doc_Gestoria_Estado_Civil {public get; private set;} 
        public String ONE_Doc_Conyuge {public get; private set;}
        public String ONE_Municipio {public get; private set;}
        
    }

    //Set all query variable to the corresponding PDF variables    
    public ONE_NecrologicaData(String docCode, String sociedadNombre, List <ONE_Expediente__c> expedientRecord, String language) {
        
        List<NecrologicaData> lista = new List<NecrologicaData>();
        
        for(ONE_Expediente__c exp : expedientRecord){
            NecrologicaData nData = new NecrologicaData();
            nData.ONE_Doc_Direccion_ceremonia = '';
            nData.ONE_Doc_Difunto = String.isBlank(exp.ONE_Difunto__r.ONE_Nombre_Coloquial__c) ? exp.ONE_Difunto__r.FirstName + ' ' + exp.ONE_Difunto__r.LastName : exp.ONE_Difunto__r.ONE_Nombre_Coloquial__c + ' ' + exp.ONE_Difunto__r.LastName;
            nData.ONE_Doc_Gestoria_Fecha_Hora_Defuncion = exp.ONE_Fecha_De_Defuncion__c != null? exp.ONE_Fecha_De_Defuncion__c.format() :'';
            nData.ONE_Doc_Fecha_Ceremonia = exp.ONE_Inicio_Ceremonia__c != null? exp.ONE_Inicio_Ceremonia__c.format() :'';          
            if(exp.ONE_Lugar_Ceremonia__r.Name != null)  nData.ONE_Doc_Direccion_ceremonia =  nData.ONE_Doc_Direccion_ceremonia + exp.ONE_Lugar_Ceremonia__r.Name + ': ' ;
            if(exp.ONE_Direccion_Ceremonia__c != null)  nData.ONE_Doc_Direccion_ceremonia =  nData.ONE_Doc_Direccion_ceremonia + exp.ONE_Direccion_Ceremonia__c + ', ';
            if(exp.ONE_Municipio_Ceremonia__c != null)  nData.ONE_Doc_Direccion_ceremonia =  nData.ONE_Doc_Direccion_ceremonia + exp.ONE_Municipio_Ceremonia__c;
            nData.ONE_Doc_Gestoria_Edad = exp.ONE_Difunto__r.ONE_Edad__c != null? exp.ONE_Difunto__r.ONE_Edad__c.intValue(): null;
            nData.ONE_Doc_Gestoria_Estado_Civil = exp.ONE_Difunto__r.ONE_Estado_Civil__c;
            nData.ONE_Doc_Conyuge = exp.ONE_Difunto__r.ONE_Conyuge__c;
            nData.ONE_Municipio = exp.ONE_Difunto__r.ONE_Municipio__pc;
            
            lista.add(nData);
        }
        
        expedientList = lista;
        ONE_Doc_Sociedad_Nombre = sociedadNombre;
        Fecha_Now = system.today().format();
        this.language = language;
        
    }
}