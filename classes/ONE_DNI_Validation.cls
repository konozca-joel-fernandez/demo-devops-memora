public class ONE_DNI_Validation {

    public void obtenerLetra(string numDNI){
        
        //integer posicionLetra=numDNI%23; //Obtener la posición de la letra hallando el resto       
        //System.out.print('\u000C');//Borrar pantalla
        //En vez de presentar el numero en pantalla presento una cadena para que se presenten
        //en pantalla los ceros. Si se presenta un numero los ceros de la izquierda desaparecen y
        //no se presenta el numero del DNI completo
        List<String> letra = new List<String>{'T','R','W','A','G','M','Y','F','P','D','X','B','N','J','Z','S','Q','V','H','L','C','K','E'};
        
        
        if (numDNI.isNumeric() == true){
            integer numDNIInteger = integer.valueof(numDNI);
            Integer posicionLetra = math.mod(numDNIInteger, 23);
            String NIF= 'El DNI con numero '+numDNI+ ' tiene la letra '+letra[posicionLetra]+'\n';

        }else{
            
            System.debug('Solo se admiten numeros\n'); 
        }
        
              
    }
    

    
}