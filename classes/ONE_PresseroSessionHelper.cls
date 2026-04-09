public class ONE_PresseroSessionHelper {
    
    public static String newSessionXMLgenerator(String docCode, String docPwd){
        return '<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">' + '\n'
            + '<soap:Body>' + '\n'
                + '<startDocSession xmlns="http://www.edocbuilder.com/">' + '\n'
                    + '<docCode>' + docCode + '</docCode>' + '\n'
                    + '<docPwd>' + docPwd + '</docPwd>' + '\n'
                    + '<remote_tag>Memora</remote_tag>' + '\n'
                + '</startDocSession>' + '\n'
            + '</soap:Body>' + '\n'
        + '</soap:Envelope>';
    }
    
    public static String autocompleteXMLgenerator(Map<String,String> tareaData, String docSession){
        String XML = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">' + '\n'
    					+ '<soapenv:Body>' + '\n'
        					+ '<tns:updateCurrentSession xmlns:tns="http://www.edocbuilder.com/">' + '\n'
            				//<!-- mandatory -->
            					+ '<tns:docSessionID>' + docSession + '</tns:docSessionID>' + '\n'
            					+ '<tns:userValues>' + '\n';
        for(String name : tareaData.keySet()){
        	String value = tareaData.get(name);
           					   XML += '<tns:userEntries>' + '\n'
                                    	+ '<tns:elementName>' + name + '</tns:elementName>' + '\n'
                                    	+ '<tns:elementValue>' + value + '</tns:elementValue>' + '\n'
                                	+ '</tns:userEntries>' + '\n';
        }	
            			   XML += '</tns:userValues>' + '\n'
        					+ '</tns:updateCurrentSession>' + '\n'
    					+ '</soapenv:Body>' + '\n'
				+ '</soapenv:Envelope>' + '\n';
        return XML;
    }
    
/*    public static String copyDataXMLgenerator(Map<String,String> sessionData, List<String> fields2Delete, String docSession){
        String XML = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">' + '\n'
    					+ '<soapenv:Body>' + '\n'
        					+ '<tns:updateCurrentSession xmlns:tns="http://www.edocbuilder.com/">' + '\n'
            					+ '<tns:docSessionID>' + docSession + '</tns:docSessionID>' + '\n'
            					+ '<tns:userValues>' + '\n';
        for(String name : sessionData.keySet()){
        	String value = sessionData.get(name);
           					   XML += '<tns:userEntries>' + '\n'
                                    	+ '<tns:elementName>' + name + '</tns:elementName>' + '\n'
                                    	+ '<tns:elementValue>' + value + '</tns:elementValue>' + '\n';
			if(fields2Delete.contains(name)){
                                   XML += '<tns:textStyle>' + '\n'
                                       	    + '<tns:opacity>0.0</tns:opacity>' + '\n'
                                       	+ '</tns:textStyle>' + '\n';
            }
                               XML += '</tns:userEntries>' + '\n';
        }	
            			   XML += '</tns:userValues>' + '\n'
        					+ '</tns:updateCurrentSession>' + '\n'
    					+ '</soapenv:Body>' + '\n'
				+ '</soapenv:Envelope>' + '\n';
        return XML;
    }*/
    
    public static String getPDF_XMLgenerator(String docSession){
        return '<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">' + '\n' +
  					'<soap:Body>' + '\n' +
    					'<getOrderFile xmlns="http://www.edocbuilder.com/">' + '\n' +
      						'<docSessionID>' + docSession + '</docSessionID>' + '\n' +
      						'<email>jmiguel.rivas@memora.es</email>' + '\n' +
      						'<password>5UMarZvK</password>' + '\n' +
    					'</getOrderFile>' + '\n' +
  					'</soap:Body>' + '\n' +
				'</soap:Envelope>';
    }
    
    public static String getSessionData_XMLgenerator(String docSession){
        return '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">' + '\n' +
  					'<soap:Body>' + '\n' +
    					'<getCurrentSession xmlns="http://www.edocbuilder.com/">' + '\n' +
      						'<docSessionID>' + docSession + '</docSessionID>' + '\n' +
    					'</getCurrentSession>' + '\n' +
  					'</soap:Body>' + '\n' +
				'</soap:Envelope>';
    }
    
    public static String aproveSession_XMLgenerator(String docSession){
        return '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">' + '\n' +
 					'<soapenv:Body>' + '\n' +
  						'<tns:approveDocSession xmlns:tns="http://www.edocbuilder.com/">' + '\n' +
   							'<tns:docSessionID>' + docSession +'</tns:docSessionID>' + '\n' +
  						'</tns:approveDocSession>' + '\n' +
 					'</soapenv:Body>' + '\n' +
				'</soapenv:Envelope>';
    }
    
    public static String presseroEndpoint(){
        return 'http://engine-memora.edocbuilder.com/services/builddoc.asmx';
    }
    
    public static String getMonthName(Integer month, String language){
        if(language == 'ESP'){
            switch on month {
                when 1 {return 'Enero';}
                when 2 {return 'Febrero';}
                when 3 {return 'Marzo';}
                when 4 {return 'Abril';}
                when 5 {return 'Mayo';}
                when 6 {return 'Junio';}
                when 7 {return 'Julio';}
                when 8 {return 'Agosto';}
                when 9 {return 'Septiembre';}
                when 10 {return 'Octubre';}
                when 11 {return 'Noviembre';}
                when 12 {return 'Diciembre';}
            } 
        } else if (language == 'CAT') {
            switch on month {
                when 1 {return 'Gener';}
                when 2 {return 'Febrer';}
                when 3 {return 'Març';}
                when 4 {return 'Abril';}
                when 5 {return 'Maig';}
                when 6 {return 'Juny';}
                when 7 {return 'Juliol';}
                when 8 {return 'Agost';}
                when 9 {return 'Setembre';}
                when 10 {return 'Octubre';}
                when 11 {return 'Novembre';}
                when 12 {return 'Decembre';}
            }
        } else if (language == 'EUS') {
            switch on month {
                when 1 {return 'urtarrilaren';}
                when 2 {return 'otsailaren';}
                when 3 {return 'martxoaren';}
                when 4 {return 'apirilaren';}
                when 5 {return 'maiatzaren';}
                when 6 {return 'ekainaren';}
                when 7 {return 'uztailaren';}
                when 8 {return 'abuztuaren';}
                when 9 {return 'irailaren';}
                when 10 {return 'urriaren';}
                when 11 {return 'azaroaren';}
                when 12 {return 'abenduaren';}
            }
        }
        return 'xxx';
    }
    
    public static String getProofPdfBody(String docSession){
        return '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">' + '\n' +
                 '<soapenv:Body>' + '\n' +
                  '<tns:getProofPDF xmlns:tns="http://www.edocbuilder.com/">' + '\n' +
                   '<tns:docSessionID>' + docSession + '</tns:docSessionID>' + '\n' +
                   '<tns:allVDP>true</tns:allVDP>' + '\n' +
                  '</tns:getProofPDF>' + '\n' +
                 '</soapenv:Body>' + '\n' +
                '</soapenv:Envelope>';
    }
  
}