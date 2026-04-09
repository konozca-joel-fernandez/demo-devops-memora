@isTest
public class ONE_IBANvalidatorTest {

    @isTest
    static void testIBANValido() {
        // IBAN español válido de ejemplo: ES9121000418450200051332
        ONE_IBANvalidator.IBANValidationRequest req = new ONE_IBANvalidator.IBANValidationRequest();
        req.iban = 'ES9121000418450200051332';

        List<ONE_IBANvalidator.IBANValidationRequest> requestList = new List<ONE_IBANvalidator.IBANValidationRequest>{req};

        List<ONE_IBANvalidator.IBANValidationResponse> responses = ONE_IBANvalidator.validateIBAN(requestList);

        System.assertEquals(1, responses.size());
        System.assertEquals(true, responses[0].isValid);
    }

    @isTest
    static void testIBANInvalido_Longitud() {
        // IBAN con longitud incorrecta
        ONE_IBANvalidator.IBANValidationRequest req = new ONE_IBANvalidator.IBANValidationRequest();
        req.iban = 'ES91210004184502000513'; // < 24 caracteres

        List<ONE_IBANvalidator.IBANValidationRequest> requestList = new List<ONE_IBANvalidator.IBANValidationRequest>{req};

        List<ONE_IBANvalidator.IBANValidationResponse> responses = ONE_IBANvalidator.validateIBAN(requestList);

        System.assertEquals(1, responses.size());
        System.assertEquals(false, responses[0].isValid);
    }

    @isTest
    static void testIBANInvalido_Simbolos() {
        // IBAN con símbolos inválidos
        ONE_IBANvalidator.IBANValidationRequest req = new ONE_IBANvalidator.IBANValidationRequest();
        req.iban = 'ES91-2100-0418-4502-0005-1332'; // contiene guiones

        List<ONE_IBANvalidator.IBANValidationRequest> requestList = new List<ONE_IBANvalidator.IBANValidationRequest>{req};

        List<ONE_IBANvalidator.IBANValidationResponse> responses = ONE_IBANvalidator.validateIBAN(requestList);

        System.assertEquals(1, responses.size());
        System.assertEquals(false, responses[0].isValid);
    }

    @isTest
    static void testIBANVacio() {
        // IBAN vacío
        ONE_IBANvalidator.IBANValidationRequest req = new ONE_IBANvalidator.IBANValidationRequest();
        req.iban = '';

        List<ONE_IBANvalidator.IBANValidationRequest> requestList = new List<ONE_IBANvalidator.IBANValidationRequest>{req};

        List<ONE_IBANvalidator.IBANValidationResponse> responses = ONE_IBANvalidator.validateIBAN(requestList);

        System.assertEquals(1, responses.size());
        System.assertEquals(false, responses[0].isValid);
    }
}