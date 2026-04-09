@IsTest
public with sharing class ONE_ValidadorCIFTest {
        
            @isTest
            static void testCIFValido() {
                ONE_ValidadorCIF.Request req = new ONE_ValidadorCIF.Request();
                req.cif = 'J79033056'; // CIF válido

            List<ONE_ValidadorCIF.Request> requests = new List<ONE_ValidadorCIF.Request>{req};
            List<ONE_ValidadorCIF.Response> responses = ONE_ValidadorCIF.ONE_ValidadorCIF(requests);

            System.assertEquals(1, responses.size());
            System.assertEquals(true, responses[0].isValid);
        }

        @isTest
        static void testCIFInvalido() {
            ONE_ValidadorCIF.Request req = new ONE_ValidadorCIF.Request();
            req.cif = 'Z0000000X'; // CIF inválido (mal primer carácter y control)

            List<ONE_ValidadorCIF.Request> requests = new List<ONE_ValidadorCIF.Request>{req};
            List<ONE_ValidadorCIF.Response> responses = ONE_ValidadorCIF.ONE_ValidadorCIF(requests);

            System.assertEquals(false, responses[0].isValid);
        }

        @isTest
        static void testCIFNull() {
            ONE_ValidadorCIF.Request req = new ONE_ValidadorCIF.Request();
            req.cif = null;

            List<ONE_ValidadorCIF.Request> requests = new List<ONE_ValidadorCIF.Request>{req};
            List<ONE_ValidadorCIF.Response> responses = ONE_ValidadorCIF.ONE_ValidadorCIF(requests);

            System.assertEquals(false, responses[0].isValid);
        }

        @isTest
        static void testCIFConLongitudIncorrecta() {
            ONE_ValidadorCIF.Request req = new ONE_ValidadorCIF.Request();
            req.cif = 'B1234'; // muy corto

            List<ONE_ValidadorCIF.Request> requests = new List<ONE_ValidadorCIF.Request>{req};
            List<ONE_ValidadorCIF.Response> responses = ONE_ValidadorCIF.ONE_ValidadorCIF(requests);

            System.assertEquals(false, responses[0].isValid);
        }

       
        
        @isTest
        static void testDNIValido() {
            ONE_ValidadorCIF.Request req = new ONE_ValidadorCIF.Request();
            req.cif = '41466249D'; // DNI válido (Z = letra correcta para 12345678)

            List<ONE_ValidadorCIF.Request> requests = new List<ONE_ValidadorCIF.Request>{req};
            List<ONE_ValidadorCIF.Response> responses = ONE_ValidadorCIF.ONE_ValidadorCIF(requests);

            System.assertEquals(true, responses[0].isValid);
        }
    }