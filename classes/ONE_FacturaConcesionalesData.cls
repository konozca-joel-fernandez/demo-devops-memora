public with sharing class ONE_FacturaConcesionalesData {


    public String language { get; set; }
    public String recordtypeName { get; set; }
    public String headerLogoUrl { get; set; }
    public Boolean isLogoEmpty { get; set; }

    public String numFacturaAnexa { get; set; }
    public String fechaFactura { get; set; }
    public String nombreDifunto { get; set; }
    public String dniDifunto {get; set;}
    public String totalBase { get; set; }
    public String totalImpuesto {get; set;}
    public String totalNeto {get; set;}
    public String totalNetoImpuesto {get; set;}
    public String sociedad {get; set;}
    public String direccion {get; set;}
    public String provinciaCP {get; set;}
    public String telefono {get; set;}
    public String sociedadWeb {get; set;}

    
    public List<ONE_FacturaConcesionalesProductRow> productRows { get; set; }
    public List<ONE_FacturaConcesionalesTaxTotalRow> taxTotals {get; set;}

    public ONE_FacturaConcesionalesData() {
        productRows = new List<ONE_FacturaConcesionalesProductRow>();
        taxTotals = new List<ONE_FacturaConcesionalesTaxTotalRow>();
    }

    public class ONE_FacturaConcesionalesProductRow {
    public String concepto { get; set; }
    public String baseImponible { get; set; }
    public String iva { get; set; }
    public String impuestoIVA {get; set;}
    public String importe { get; set; }
    public String cantidad {get; set;}

    public ONE_FacturaConcesionalesProductRow(String concepto, String baseImponible, String iva, String impuestoIVA, String importe, String cantidad) {
        this.concepto = concepto;
        this.baseImponible = baseImponible;
        this.iva = iva;
        this.impuestoIVA = impuestoIVA;
        this.importe = importe;
        this.cantidad = cantidad;
    }
}
    public class ONE_FacturaConcesionalesTaxTotalRow {
    public String iva { get; set; }
    public String totalBase { get; set; }
    public String totalImpuesto { get; set; }
    public String totalNetoImpuesto { get; set; }

    public ONE_FacturaConcesionalesTaxTotalRow(
        String iva,
        String totalBase,
        String totalImpuesto
    ) {
        this.iva = iva;
        Decimal impBasePorImp = totalBase != null ? Decimal.valueOf(totalBase) : 0;
        this.totalBase = String.valueOf(impBasePorImp);
        Decimal impImpuestoPorImp = totalImpuesto != null ? Decimal.valueOf(totalImpuesto) : 0;
        this.totalImpuesto = String.valueOf(impImpuestoPorImp);
        this.totalNetoImpuesto = String.valueOf(impBasePorImp + impImpuestoPorImp);
    }
}

    
    

}