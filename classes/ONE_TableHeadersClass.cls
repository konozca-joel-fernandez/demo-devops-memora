//Sharing class for the header table definition for the PDF creation
public with sharing class ONE_TableHeadersClass {
		//Variable definition for the front end communication
        @AuraEnabled
        public String Nombre;
        @AuraEnabled
        public String SKU;
        @AuraEnabled
        public String Centro;
        @AuraEnabled
        public String NombreCentro;
        @AuraEnabled
        public String Almacen;
        @AuraEnabled
        public String Proveedor;
        @AuraEnabled
        public Integer Unidades;
		//Constructer definition
        public ONE_TableHeadersClass(
                String nombreDelModelo,
                String sku,
                String centro,
                String nombreCentro,
                String almacen,
                String proveedor,
                Integer unidades
        ) {
            this.Nombre = nombreDelModelo;
            this.SKU = sku;
            this.Centro = centro;
            this.nombreCentro = nombreCentro;
            this.Almacen = almacen;
            this.Proveedor = proveedor;
            this.Unidades = unidades;
        }

        public ONE_TableHeadersClass() {}
}