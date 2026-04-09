public with sharing class ONE_IBANvalidator {

    @InvocableMethod(label='Validar IBAN')
    public static List<IBANValidationResponse> validateIBAN(List<IBANValidationRequest> requests) {
        List<IBANValidationResponse> responses = new List<IBANValidationResponse>();

        for (IBANValidationRequest request : requests) {
            IBANValidationResponse response = new IBANValidationResponse();
            response.isValid = isValidIBAN(request.iban); 
            responses.add(response);
        }

        return responses; 
    }

   
    private static Boolean isValidIBAN(String iban) {

        if (String.isBlank(iban)) return false;

        //primera validacion: espacios y simbolos raros
        Pattern invalidCharPattern = Pattern.compile('[^A-Za-z0-9]');
        if (invalidCharPattern.matcher(iban).find()) {
            System.debug('IBAN contiene espacios o símbolos.');
            return false;
        }

        // segunda validacion: norma iso 7064
        // Eliminar espacios y convertir a mayúsculas
        String cleanIban = iban.replaceAll('[\\s-]', '').toUpperCase();
        System.debug('IBAN limpio: ' + cleanIban + ', Longitud: ' + cleanIban.length());
    

        if (cleanIban.length() != 24){
            System.debug('Longitud inválida: ' + cleanIban.length());
            return false;
        } 
    
        // Verifica formato IBAN valido
        Pattern regex = Pattern.compile('^[A-Z]{2}[0-9]{2}[A-Z0-9]{20}$');
        if (!regex.matcher(cleanIban).matches()) {
            System.debug('Error de formato');
            return false;
        
        }
    
        // Reorganizar el IBAN para aplicar el algoritmo MOD 97
        String IBANarreglado = cleanIban.substring(4) + cleanIban.substring(0, 4);

        
        String numericIBAN = '';
        for (Integer i = 0; i < IBANarreglado.length(); i++) {
            String c = IBANarreglado.substring(i, i + 1);
            
            if (c >= 'A' && c <= 'Z') { 
                Integer numericValue = c.charAt(0) - 55;
                System.debug('Letra: ' + c + ', Valor numérico: ' + numericValue);
                numericIBAN += numericValue;
            } else {
                
                System.debug('Algo ha salido mal: ' + c);
                numericIBAN += c;
            }
        }

        //String numericIBAN = numIBAN_1 + numFormat + numIBAN_3;
        System.debug('Numeric IBAN: ' + numericIBAN);
    
        // Aplicar el algoritmo MOD 97
        Long mod = 0;
        Integer idx = 0;
        while (idx < numericIBAN.length()) {
            Integer take = Math.min(9, numericIBAN.length() - idx);
            String part = String.valueOf(mod) + numericIBAN.substring(idx, idx + take);
            mod = Math.mod(Long.valueOf(part), 97);
            System.debug('Resultado MOD parcial: ' + mod);
            idx += take;
        }
    
        // El IBAN es válido si el resultado del MOD 97 es 1
        return mod == 1;
    }

    // Clase interna para la solicitud del flujo
    public class IBANValidationRequest {
        @InvocableVariable(label='IBAN')
        public String iban; 
    }

    // Clase interna para la respuesta del flujo
    public class IBANValidationResponse {
        @InvocableVariable(label='Es Válido' required=true)
        public Boolean isValid; 
    }
}