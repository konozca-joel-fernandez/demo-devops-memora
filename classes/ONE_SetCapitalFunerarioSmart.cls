public with sharing class ONE_SetCapitalFunerarioSmart {
    public ONE_SetCapitalFunerarioSmart() {
        //Lista de contratos SB y SP sin capital funerario informado
        List<ONE_Contrato__c> contratosSBSP = 
            [SELECT Id, ONE_Tipo_De_Presupuesto__c, ONE_Tipo_Servicio_Smart__c, ONE_Direccion_Provincia_Smart__c, ONE_Contratante__r.ONE_Provincia__pc
            FROM ONE_Contrato__c 
            WHERE RecordType.Name LIKE '%Electium%' AND (ONE_Tipo_De_Presupuesto__c ='SB' OR ONE_Tipo_De_Presupuesto__c ='SP') 
            AND ONE_Capital_Smart__c = null AND ONE_Tipo_De_Contrato__c = 'Principal' LIMIT 200];
        
        //Lista de contratos SR sin capital funerario informado
        List<ONE_Contrato__c> contratosSR = 
            [SELECT Id, ONE_Tipo_De_Presupuesto__c, ONE_Tipo_Servicio_Smart__c, ONE_Pais_de_Repatriacion__c, ONE_Contratante__r.ONE_Pais__pc
            FROM ONE_Contrato__c 
            WHERE RecordType.Name LIKE '%Electium%' AND ONE_Tipo_De_Presupuesto__c ='SR' 
            AND ONE_Capital_Smart__c = null AND ONE_Tipo_De_Contrato__c = 'Principal' LIMIT 200];

        List<ONE_Contrato__c> contratosAModificar = new List<ONE_Contrato__c>(); 

        //Lista precios Provincia
        List<ONE_Precios_Electium__c> preciosProvincia = 
            [SELECT Id, ONE_Provincia__c, ONE_Capital_Funerario__c, ONE_Capital_Funerario_Deposito__c 
            FROM ONE_Precios_Electium__c 
            WHERE ONE_Provincia__c != ''];

        //Lista precios Pais
        List<ONE_Precios_Electium__c> preciosPais = 
            [SELECT Id, ONE_Pais_Repatriacion__c, ONE_Capital_Funerario__c 
            FROM ONE_Precios_Electium__c 
            WHERE ONE_Pais_Repatriacion__c != ''];

        String provincia, pais;

        for(ONE_Contrato__c contrato : contratosSBSP) {
            //Contratos Smart Basic y Smart Premium
            if (contrato.ONE_Tipo_De_Presupuesto__c == 'SB' && contrato.ONE_Tipo_Servicio_Smart__c == '1') {
                //Velatorio
                provincia = (contrato.ONE_Direccion_Provincia_Smart__c != '') ? contrato.ONE_Direccion_Provincia_Smart__c : contrato.ONE_Contratante__r.ONE_Provincia__pc;                    

                for (ONE_Precios_Electium__c precio : preciosProvincia) {
                    if (precio.ONE_Provincia__c == provincia) {
                        contrato.ONE_Capital_Smart__c = precio.ONE_Capital_Funerario__c;
                        break;
                    }
                }

            } else if (contrato.ONE_Tipo_De_Presupuesto__c == 'SB' && contrato.ONE_Tipo_Servicio_Smart__c == '2') {
                //Deposito
                provincia = (contrato.ONE_Direccion_Provincia_Smart__c != '') ? contrato.ONE_Direccion_Provincia_Smart__c : contrato.ONE_Contratante__r.ONE_Provincia__pc;                    


                for (ONE_Precios_Electium__c precio : preciosProvincia) {
                    if (precio.ONE_Provincia__c == provincia) {
                        contrato.ONE_Capital_Smart__c = precio.ONE_Capital_Funerario_Deposito__c;
                        break;
                    }
                }

            } else if (contrato.ONE_Tipo_De_Presupuesto__c == 'SP') {
                //Premium
                provincia = (contrato.ONE_Direccion_Provincia_Smart__c != '') ? contrato.ONE_Direccion_Provincia_Smart__c : contrato.ONE_Contratante__r.ONE_Provincia__pc;                    

                for (ONE_Precios_Electium__c precio : preciosProvincia) {
                    if (precio.ONE_Provincia__c == provincia) {
                        contrato.ONE_Capital_Smart__c = precio.ONE_Capital_Funerario__c;
                        break;
                    }
                }
            }

           contratosAModificar.add(contrato);
        }

        //Contratos Smart Repatriacion
        for(ONE_Contrato__c contrato : contratosSR) {
            
            pais = (contrato.ONE_Pais_de_Repatriacion__c != '') ? contrato.ONE_Pais_de_Repatriacion__c : contrato.ONE_Contratante__r.ONE_Pais__pc;                    

            for (ONE_Precios_Electium__c precio : preciosPais ) {
                if (precio.ONE_Pais_Repatriacion__c == pais) {
                    contrato.ONE_Capital_Smart__c = precio.ONE_Capital_Funerario__c;
                    break;
                }
            }
            
            contratosAModificar.add(contrato);
        }
        
        //Actualizamos los que se hayan modificado
        update contratosAModificar;
    }
}