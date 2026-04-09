public with sharing class ONE_FacturaConcesionalesDataFactory {
public static ONE_FacturaConcesionalesData buildFacturaData(Id ordenDeVentaId, String language) {

        ONE_FacturaConcesionalesData data = new ONE_FacturaConcesionalesData();
        data.language = language;

     
        ONE_Orden_De_Venta__c orden = [
            SELECT Id, Name, ONE_Fecha_De_Facturacion__c, RecordType.Name, ONE_Nombre_Y_Apellidos_Del_Difunto__c, ONE_Numero_de_factura__c,
            ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_URL_logo__c,
            ONE_Servicio__r.ONE_Difunto__r.ONE_N_Documento__pc,
            ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Provincia__c,
            ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Direccion__c,
            ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Municipio_Direccion__c,
            ONE_Servicio__r.ONE_Centro_Del_Expediente__r.Phone,
            ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.ONE_URL_Web__c,
            ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.Name,
            ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.ONE_URL_logo__c,
            ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Codigo_Postal__c
            FROM ONE_Orden_De_Venta__c
            WHERE Id = :ordenDeVentaId
            LIMIT 1
        ];
    
    	Date fechaSinFormato = orden.ONE_Fecha_De_Facturacion__c;
    
    
    
    	//String logoUrl = orden.ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_URL_logo__c != null ? orden.ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_URL_logo__c : orden.ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.ONE_URL_logo__c;

        data.recordtypeName = orden.RecordType.Name;
        data.fechaFactura = DateTime.newInstance(fechaSinFormato, Time.newInstance(0, 0, 0, 0)).format('dd-MM-yyyy');
        data.numFacturaAnexa = orden.ONE_Numero_de_factura__c;
        data.nombreDifunto = orden.ONE_Nombre_Y_Apellidos_Del_Difunto__c != null ? orden.ONE_Nombre_Y_Apellidos_Del_Difunto__c : '';
    	data.dniDifunto = orden.ONE_Servicio__r.ONE_Difunto__r.ONE_N_Documento__pc;
    	data.sociedad = orden.ONE_Servicio__r?.ONE_Centro_Del_Expediente__r?.ONE_Sociedad2__r?.Name;
    	data.direccion =  ONE_CommonUtils.changeNullToBlank(orden.ONE_Servicio__r?.ONE_Centro_Del_Expediente__r?.ONE_Direccion__c) + ', ' +  ONE_CommonUtils.changeNullToBlank(orden.ONE_Servicio__r?.ONE_Centro_Del_Expediente__r?.ONE_Municipio_Direccion__c);
    	data.provinciaCP = ONE_CommonUtils.changeNullToBlank(orden.ONE_Servicio__r?.ONE_Centro_Del_Expediente__r?.ONE_Provincia__c) + ONE_CommonUtils.changeNullToBlank(orden.ONE_Servicio__r?.ONE_Centro_Del_Expediente__r?.ONE_Codigo_Postal__c);
		data.sociedadWeb = orden.ONE_Servicio__r?.ONE_Centro_Del_Expediente__r?.ONE_Sociedad2__r.ONE_URL_Web__c;
    	data.telefono = String.valueOf(orden.ONE_Servicio__r?.ONE_Centro_Del_Expediente__r?.Phone);
      
        
        data.headerLogoUrl = 'https://memora--c.vf.force.com/resource/1764859948000/LogoTanatorioTorrero?';
        //data.isLogoEmpty = data.headerLogoUrl == null;

        List<ONE_Expediente_Line_Item__c> lineas = [
            SELECT Id,
                   ONE_Nombre_del_Producto__c,
                   ONE_Importe_Base__c,
                   ONE_Impuesto__c,
            	   ONE_Importe_Impuesto__c,
                   ONE_Importe_Neto__c,
            	   ONE_Producto__c,
            	   ONE_Cantidad__c
            FROM ONE_Expediente_Line_Item__c
            WHERE ONE_Orden_De_Venta__c = :ordenDeVentaId
            AND ONE_Producto__r.ONE_Concesion__c = true
        ];

        Decimal totalBase = 0;
    	Decimal totalImpuesto = 0;
    	Decimal totalNeto = 0;
    
    	Map<String, String> basePorImpuesto = new Map<String, String>();
    	Map<String, String> impuestoPorImpuesto = new Map<String, String>();
    	
    	

        for (ONE_Expediente_Line_Item__c li : lineas) {

            String concepto = li.ONE_Nombre_del_Producto__c != null ? li.ONE_Nombre_del_Producto__c : ' ';

            String base = String.valueOf(li.ONE_Importe_Base__c != null ? li.ONE_Importe_Base__c : 0);
            String iva = String.valueOf(li.ONE_Impuesto__c != null ? li.ONE_Impuesto__c : 0);
            String impuestoIVA = String.valueOf(li.ONE_Importe_Impuesto__c != null ? li.ONE_Importe_Impuesto__c : 0);
            String neto = String.valueOf(li.ONE_Importe_Neto__c != null ? li.ONE_Importe_Neto__c : 0);
            String cantidad = String.valueOf(li.ONE_Cantidad__c != null ? li.ONE_Cantidad__c : 0);
            
            totalBase += li.ONE_Importe_Base__c != null ? li.ONE_Importe_Base__c : 0;
            totalImpuesto += li.ONE_Importe_Impuesto__c != null ? li.ONE_Importe_Impuesto__c : 0;
            
          
            Decimal baseDec = Decimal.valueOf(base);
            Decimal impuestoDec = Decimal.valueOf(impuestoIVA);
            
            if (basePorImpuesto.containsKey(iva)) {
                baseDec += Decimal.valueOf(basePorImpuesto.get(iva));
                impuestoDec += Decimal.valueOf(impuestoPorImpuesto.get(iva));
            }
            
            basePorImpuesto.put(iva, String.valueOf(baseDec));
            impuestoPorImpuesto.put(iva, String.valueOf(impuestoDec));

            data.productRows.add(
                new ONE_FacturaConcesionalesData.ONE_FacturaConcesionalesProductRow(
                    concepto,
                    base,
                    iva,
                    impuestoIVA,
                    neto,
                    cantidad
                )
            );
        }
        for(String iva : basePorImpuesto.keySet()){
            data.taxTotals.add(
                new ONE_FacturaConcesionalesData.ONE_FacturaConcesionalesTaxTotalRow(
                    iva + '%',
                    basePorImpuesto.get(iva),
                    impuestoPorImpuesto.get(iva)
                    
                )
            
            );
        }
		data.totalImpuesto = String.valueOf(totalImpuesto);
        data.totalBase = String.valueOf(totalBase);
    	data.totalNeto = String.valueOf(totalBase + totalImpuesto);

        return data;
    }
}