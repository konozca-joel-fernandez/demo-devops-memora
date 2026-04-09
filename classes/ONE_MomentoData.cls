/**
 * Created by msulek003 on 14.04.2021.
 */

//Momento structure data class, used to display all the information related to the Moments, Aggrupation and Categories

public with sharing class ONE_MomentoData {
    public Decimal unitNumber {public get; private set;}
    public String textoBandaLazo {public get; private set;}
    public String precioUnidad {public get; private set;}
    public String descuento {public get; private set;}
    public Decimal IVA_IGIC {public get; private set;}
    public String IVA {public get; private set;}
    public String precisioNeto {public get; private set;}
    public String precisioBase {public get; private set;}
    public String productName {public get; private set;}
    public List<ONE_MomentoData> childList {public get; private set;}

    public ONE_MomentoData(Decimal unitNumber, String textoBandaLazo, Decimal precioUnidad, Decimal descuento, Decimal IVA_IGIC, Decimal IVA, Decimal precisioNeto, Decimal precisioBase, String productName) {
        this.unitNumber = unitNumber;
        this.textoBandaLazo = textoBandaLazo;
        this.precioUnidad = precioUnidad == null ? '' : formatWithTwoDecimalPlaces(precioUnidad);
        this.descuento = formatWithTwoDecimalPlaces(descuento);
        this.IVA_IGIC = IVA_IGIC;
        this.IVA = formatWithTwoDecimalPlaces(IVA);
        this.precisioNeto = precisioNeto == null ? '' : formatWithTwoDecimalPlaces(precisioNeto);
        this.precisioBase = precisioBase == null ? '' : formatWithTwoDecimalPlaces(precisioBase);
        this.productName = productName;
    }

//Obsolete code, there is a new constructor method
/*
    public ONE_MomentoData(Decimal unitNumber, Decimal precioUnidad, Decimal descuento, Decimal IVA_IGIC, Decimal IVA, Decimal precisioNeto, Decimal precisioBase,
        String productName) {
        this.unitNumber = unitNumber;
        this.precioUnidad = precioUnidad == null ? '' : precioUnidad.format();
        this.descuento = descuento == null ? '0' : descuento.format();
        this.IVA_IGIC = IVA_IGIC;
        this.IVA = IVA;
        this.precisioNeto = precisioNeto == null ? '' : precisioNeto.format();
        this.precisioBase = precisioBase == null ? '' : precisioBase.format();
        this.productName = productName;
    }

    public ONE_MomentoData(Decimal unitNumber, Decimal precioUnidad, Decimal descuento, Decimal IVA_IGIC, Decimal IVA, Decimal precisioNeto,
            String productName) {
        this.unitNumber = unitNumber;
        this.precioUnidad = precioUnidad == null ? '' : precioUnidad.format();
        this.descuento = descuento == null ? '0' : descuento.format();
        this.IVA_IGIC = IVA_IGIC;
        this.IVA = IVA;
        this.precisioNeto = precisioNeto == null ? '' : precisioNeto.format();
        this.productName = productName;
    }
*/
    public void addChildList(List<ONE_MomentoData> childList){
        this.childList = childList;
    }

    private String formatWithTwoDecimalPlaces(Decimal d) {
        if (d == null || d == 0) {
            return '0';
        }

        String output = d.setScale(2).format();
        if (output.contains(',')) {
            if (output.indexOf(',') == output.length() - 2) {
                return output + '0';
            } else {
                return output;
            }
        } else {
            return output + ',00';
        }
    }
}