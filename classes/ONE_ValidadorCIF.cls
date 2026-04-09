public with sharing class ONE_ValidadorCIF {
    
    public class Request {
        @InvocableVariable
        public String cif;
    }
    public class Response {
        @InvocableVariable
        public Boolean isValid;
    }
    
    
    
    @InvocableMethod(label='Validar CIF' description='Valida el CIF proporcionado')
    public static List<Response> ONE_ValidadorCIF(List<Request> requests) {
        List<Response> responses = new List<Response>();
        
        for (Request request : requests) {
            Response response = new Response();
            response.isValid = isValidCIF(request.cif);
            responses.add(response);
        }
        
        return responses;

    }

private static Boolean isValidCIF(String cif) {
    if (cif == null || cif.length() != 9) {
        return false;
    }

    String firstChar = cif.substring(0, 1);
    String numericPart = cif.substring(1, 8);
    String controlChar = cif.substring(8, 9);


     if (Pattern.matches('\\d{8}[A-Z]', cif)) {
         String dniNumberStr = cif.substring(0, 8);
         String dniLetter = cif.substring(8, 9);

         try {
            Integer dniNumber = Integer.valueOf(dniNumberStr);
            String letters = 'TRWAGMYFPDXBNJZSQVHLCKE';
            String expectedLetter = letters.substring(Math.mod(dniNumber, 23), Math.mod(dniNumber, 23) + 1);
            return expectedLetter.equalsIgnoreCase(dniLetter);
        } catch (Exception e) {
            return false;
       }
    }


    if (!Pattern.matches('[A-HJ-NP-SUVW]', firstChar) || !Pattern.matches('\\d{7}', numericPart) || !Pattern.matches('[0-9A-J]', controlChar)) {
        return false;
    }

    Integer sum = 0;
    for (Integer i = 0; i < numericPart.length(); i++) {
        Integer digit = Integer.valueOf(numericPart.substring(i, i + 1));
        if (Math.mod(i, 2) == 0) {
            digit *= 2;
            if (digit > 9) {
                digit -= 9;
            }
        }
        sum += digit;
    }

    Integer mod = Math.mod(sum, 10);
    Integer controlDigit = (mod == 0) ? 0 : 10 - mod;
    String controlLetters = 'JABCDEFGHI';
    String expectedControlChar = '';
    // Según el primer carácter, el control puede ser letra, número o ambos
    if ('ABEH'.contains(firstChar)) {
        expectedControlChar = String.valueOf(controlDigit);
    } else if ('KPQS'.contains(firstChar)) {
        expectedControlChar = String.valueOf(controlLetters.substring(controlDigit, controlDigit + 1));
    } else {
        // Puede ser ambos
        expectedControlChar = String.valueOf(controlDigit) + controlLetters.substring(controlDigit, controlDigit + 1);
    }
    return expectedControlChar.containsIgnoreCase(controlChar);
}
}