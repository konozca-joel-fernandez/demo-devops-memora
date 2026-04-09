/**
 * Created by mbujak003 on 05.02.2021.
 * 
 * LOGs:
 * -------------------------------------------
 * DATE        USER            CHANGE
 * 08.05.2023  Miguel Serrat   + Stockable 
 * 19.11.2024  Marc Pàmies	   + Excluir
 * 22.04.2025  Marc Pàmies	   + CodigoCB
 * -------------------------------------------
 */

@RestResource(UrlMapping='/products')
global without sharing class ONE_ProductsWebService {

    @HttpGet
    global static void getProducts() {
        Map<Id, List<ONE_Relacion_De_Productos__c>> productId2RelacionDeProductos = new Map<Id, List<ONE_Relacion_De_Productos__c>>();
        Map<Id, List<ONE_Imagen__c>> productId2Images = new Map<Id, List<ONE_Imagen__c>>();

        Map<Id, ONE_Producto__c> productId2Record = new Map<Id, ONE_Producto__c>([
            SELECT Id, ONE_Codigo_Comercial__c, ONE_Descripcion_En_Catalan__c,
                ONE_Descripcion_En_Castellano__c,  ONE_Descripcion_En_Euskera__c, ONE_Categoria__c,
                ONE_Tipologia_De_Producto_Lookup__c, ONE_Nivel_De_Descuento__c, ONE_Precio_Libre__c,
                ONE_Tipo_Impositivo__c, ONE_Descriptivo_Producto_ESP__c, ONE_Descriptivo_Producto_CAT__c,
                ONE_Descriptivo_Producto_EUS__c, ONE_Order_APP__c, ONE_Stockable__c, ONE_Exclusion__c, ONE_C_digo_CB__c
            FROM ONE_Producto__c
        ]);

        for(ONE_Relacion_De_Productos__c relacion : [
            SELECT Id, ONE_Producto_Comercial_Padre__c, ONE_Producto_Incluido__c, ONE_Tipo_De_Relacion__c
            FROM ONE_Relacion_De_Productos__c
            WHERE ONE_Producto_Comercial_Padre__c IN: productId2Record.keySet()
        ]) {
            if(!productId2RelacionDeProductos.containsKey(relacion.ONE_Producto_Comercial_Padre__c)) {
                productId2RelacionDeProductos.put(relacion.ONE_Producto_Comercial_Padre__c, new List<ONE_Relacion_De_Productos__c> { relacion });
            } else {
                productId2RelacionDeProductos.get(relacion.ONE_Producto_Comercial_Padre__c).add(relacion);
            }
        }

        for(ONE_Imagen__c image : [
            SELECT Id, ONE_Producto__c, ONE_URL_Imagen__c, ONE_URL_Video__c, ONE_Orden__c, ONE_Modelo__c, ONE_Centro__c
            FROM ONE_Imagen__c
            WHERE ONE_Producto__c IN: productId2Record.keySet() AND RecordType.DeveloperName != 'Documento'
        ]) {
            if(!productId2Images.containsKey(image.ONE_Producto__c)) {
                productId2Images.put(image.ONE_Producto__c, new List<ONE_Imagen__c> { image });
            } else {
                productId2Images.get(image.ONE_Producto__c).add(image);
            }
        }
        List<Producto> allProducts = new List<Producto>();

        for(Id keyId : productId2Record.keySet()) {
            List<Image> images = new List<Image>();
            List<RelatedProduct> rProducts = new List<RelatedProduct>();

            if(productId2Images.containsKey(keyId)) {
                for(ONE_Imagen__c image : productId2Images.get(keyId)) {
                    images.add(new Image(image));
                }
            }
            if(productId2RelacionDeProductos.containsKey(keyId)) {
                for(ONE_Relacion_De_Productos__c relacion : productId2RelacionDeProductos.get(keyId)) {
                    rProducts.add(new RelatedProduct(relacion));
                }
            }
            allProducts.add(new Producto(productId2Record.get(keyId), images, rProducts));
        }

        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(allProducts, false));
    }

    public class Image {
        public String Id { get; private set; }
        public String Producto { get; private set; }
        public String URLImagen { get; private set; }
        public String URLVideo { get; private set; }
        public String Orden { get; private set; }
        public String Modelo { get; private set; }
        public String Centro { get; private set; }

        public Image(ONE_Imagen__c image) {
            Id = image.Id;
            Producto = image.ONE_Producto__c;
            URLImagen = image.ONE_URL_Imagen__c;
            URLVideo = image.ONE_URL_Video__c;
            Orden = String.valueOf(image?.ONE_Orden__c);
            Modelo = image.ONE_Modelo__c;
            Centro = image.ONE_Centro__c;
        }
    }

    public class RelatedProduct {
        public String Id { get; private set; }
        public String TipoDeRelacion { get; private set; }
        public String ProductoIncluido { get; private set; }

        public RelatedProduct(ONE_Relacion_De_Productos__c relatedProduct) {
            Id = relatedProduct.Id;
            TipoDeRelacion = relatedProduct.ONE_Tipo_De_Relacion__c;
            ProductoIncluido = relatedProduct.ONE_Producto_Incluido__c;
        }
    }

    public class Producto {
        public String Id { get; private set; }
        public String CodigoComercial { get; private set; }
        public String DescripcionEnCatalan { get; private set; }
        public String DescripcionEnCastellano { get; private set; }
        public String DescripcionEnEuskera { get; private set; }
        public String DescriptivoProductoESP { get; private set; }
        public String DescriptivoProductoCAT { get; private set; }
        public String DescriptivoProductoEUS { get; private set; }
        public String Categoria { get; private set; }
        public String TipologiaDeProductoLookup { get; private set; }
        public Boolean PrecioLibre { get; private set; }
        public String NivelDeDescuento { get; private set; }
        public String TipoImpositivo { get; private set; }
        public Decimal Order { get; private set; }
        public Boolean Stockable { get; private set; }
        public String Excluir { get; private set; }
        public String CodigoCB { get; private set; }
        public List<Image> Images { get; private set; }
        public List<RelatedProduct> relatedProducts { get; private set; }

        public Producto(ONE_Producto__c product, List<Image> images, List<RelatedProduct> relatedProducts) {
            Id = product.Id;
            CodigoComercial = product.ONE_Codigo_Comercial__c;
            DescripcionEnCatalan = product.ONE_Descripcion_En_Catalan__c;
            DescripcionEnCastellano = product.ONE_Descripcion_En_Castellano__c;
            DescripcionEnEuskera = product.ONE_Descripcion_En_Euskera__c;
            DescriptivoProductoESP = product.ONE_Descriptivo_Producto_ESP__c;
            DescriptivoProductoCAT = product.ONE_Descriptivo_Producto_CAT__c;
            DescriptivoProductoEUS = product.ONE_Descriptivo_Producto_EUS__c;
            Categoria = product.ONE_Categoria__c;
            TipologiaDeProductoLookup = product.ONE_Tipologia_De_Producto_Lookup__c;
            PrecioLibre = product.ONE_Precio_Libre__c;
            NivelDeDescuento = product.ONE_Nivel_De_Descuento__c;
            TipoImpositivo = product.ONE_Tipo_Impositivo__c;
            Order = product.ONE_Order_APP__c;
            Stockable = product.ONE_Stockable__c;
            Excluir = product.ONE_Exclusion__c;
            CodigoCB = product.ONE_C_digo_CB__c;
            this.Images = images;
            this.relatedProducts = relatedProducts;
        }
    }
}