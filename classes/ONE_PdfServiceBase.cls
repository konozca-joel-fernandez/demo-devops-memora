//Abstract class for PDF service generation
public with sharing abstract class ONE_PdfServiceBase {
    private List<FlowInput> inputs;
    protected Id templateId;
    protected String emailProveedor;
    //Constructor definition
    public ONE_PdfServiceBase(List<FlowInput> inputs) {
        this.inputs = inputs;
    }
    //Method to call PDF generation and send it attetched via email
    public List<FlowOutput> sendEmailWithPdf(String fileName) {
        try {
        FlowInput input = inputs.get(0);        
        Blob pdfContent = buildPdfContent(input);
        Id pdfId = savePdf(pdfContent, input.pedidoId, fileName);
        Messaging.SingleEmailMessage emailMessage = setupEmail(pdfContent, emailProveedor, fileName);
        sendEmail(emailMessage);
        } catch (Exception ex) {
            return new List<FlowOutput>{new FlowOutput(false, null, ex.getMessage())};
        }
        return new List<FlowOutput>{new FlowOutput(true, 'El envío del correo ha sido enviado correctamente a la dirección ' +emailProveedor , null )};
    }
    //Protected virtual class
    protected virtual Blob buildPdfContent(FlowInput inputs) {
        return null;
    }
    //Method to generate PDF using input Blop pdf content
    protected Id savePdf(Blob pdfContent, Id parentId, String fileName) {
         system.debug('savePdf IN' );
        ContentVersion versionData = new ContentVersion();
        versionData.ContentLocation = 'S';
        versionData.VersionData = pdfContent;
        versionData.Title = fileName;
        versionData.PathOnClient = fileName;
        insert versionData; // Insert version data
        
        Id contentDocumentId = [
            SELECT Id, ContentDocumentId
            FROM ContentVersion
            WHERE Id = :versionData.Id
        ].ContentDocumentId; // Get document ID
        
        system.debug('contentDocumentId-->' +  ContentDocumentId);
        ContentDocumentLink conDocLink = new ContentDocumentLink();
        conDocLink.ContentDocumentId = contentDocumentId;
        conDocLink.LinkedEntityId = parentId;
        
        insert conDocLink; // Link with related object
        system.debug('conDocLink-->' + conDocLink);
        return contentDocumentId;
    }
    //SetupEmail protected virtual class definition
    protected virtual Messaging.SingleEmailMessage setupEmail(Blob pdfContent, String toEmail, String fileName) {
        Messaging.SingleEmailMessage emailMessage = Messaging.renderStoredEmailTemplate(templateId, null, null);
        emailMessage.toAddresses = new List<String>{toEmail};
        List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        efa.setFileName(fileName);
        efa.setBody(pdfContent);
        attachments.add(efa);
        emailMessage.setFileAttachments(attachments);
        return emailMessage;
    }
    //Send email class
    protected void sendEmail(Messaging.SingleEmailMessage emailMessage) {
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{emailMessage});
    }
    //Flow input variable definition
    public virtual class FlowInput {
        @InvocableVariable
        public Id pedidoId;
        @InvocableVariable
        public String language;
        @InvocableVariable
        public String documentoId;
        @InvocableVariable
        public String documentoRecordTypeName;
    }
    //Flow output variable definition
    public virtual class FlowOutput {
        @InvocableVariable
        public Boolean success;
        @InvocableVariable
        public String errorMessage;
        @InvocableVariable
        public String successMessage;
        
        public FlowOutput(Boolean success, String successMessage, String errorMessage) {
            this.success = success;
            this.successMessage = successMessage;
            this.errorMessage = errorMessage;
        }
    }
    //Header data structure definition
    public virtual class HeaderData {
        public String centro {public get; private set;}
        public String telefono {public get; private set;}
        public String asesor {public get; private set;}
        public String nPedido {public get; private set;}
        public String fechaPedido {public get; private set;}
        public String proveedor {public get; private set;}
        public String nServizio {public get; private set;}
        public String difunto {public get; private set;}
        public String domicilioMortuorio {public get; public set;}
        public String lugarDeVelacion {public get; public set;}
        public String fechaHoraVelacion {public get; public set;}
        public String salaVelacion {public get; public set;}
        public String lugarDeCeremonia {public get; public set;}
        public String fechaHoraCeremonia {public get; public set;}
        public String lugarDestinoFinal {public get; public set;}
        public String fechaHoraDestino {public get; public set;}
        public String logoUrl {public get; public set;}
        public Boolean isLogoEmpty {public get; public set;}
        public String title {public get; public set;}
        public String parroquia {public get; public set;}

        public HeaderData(String centro, String telefono, String asesor, String nPedido, String fechaPedido, String proveedor,
            String nServizio, String difunto, String logoUrl, String title) {
            this.centro = centro;
            this.telefono = telefono;
            this.asesor = asesor;
            this.nPedido = nPedido;
            this.fechaPedido = fechaPedido;
            this.proveedor = proveedor;
            this.nServizio = nServizio;
            this.difunto = difunto;
            this.logoUrl = logoUrl;
            this.isLogoEmpty = logoUrl == null ? true : false;
            this.title = title;

        }
    }

    //Data used in generic pdf generation, possibly to remove if generic generation not used, now is used for factura, presupuesto, suplido's document
    public virtual class Header {
        public Block leftBlock {public get; private set;}
        public Block rightBlock {public get; private set;}
        public Block centralBlock {public get; private set;}
		//Header standar block
        public Header(Block leftBlock, Block rightBlock, Block centralBlock) {
            this.leftBlock = leftBlock;
            this.rightBlock = rightBlock;
            this.centralBlock = centralBlock;
        }
    }
	//Section data structure definition
    public class Block {
        public List<Field> fields {public get; private set;}
        public String firstColumnWidthPercent {public get; private set;}
        public Boolean displayBorderAroundBlock {public get; private set;}
        public String header {public get; private set;}

        public Block(List<Field> fields, String firstColumnWidthPercent, Boolean displayBorderAroundBlock, String header) {
            this.fields = fields;
            this.firstColumnWidthPercent = firstColumnWidthPercent;
            this.displayBorderAroundBlock = displayBorderAroundBlock;
            this.header = header;
        }

        public Block(List<Field> fields, String firstColumnWidthPercent, Boolean displayBorderAroundBlock) {
            this(fields, firstColumnWidthPercent, displayBorderAroundBlock, '');
        }

        public Block(List<Field> fields) {
            this(fields, '20%', false, '');
        }
    }
	//Basic field definition
    public class Field {
        public String label {public get; private set;}
        public String value {public get; private set;}
        public Integer numberOfLines {public get; private set;}
        public Boolean labelOnly {public get; private set;}
        public String fontWeight {public get; private set;}

        public Field(String label, String value, Integer numberOfLines, Boolean labelOnly, String fontWeight) {
            this.label = label;
            this.value = value;
            this.numberOfLines = numberOfLines;
            this.labelOnly = labelOnly;
            this.fontWeight = fontWeight;
        }

        public Field(String label, String value, Boolean labelOnly) {
            this(label, value, 1, labelOnly, 'normal');
        }

        public Field(String label, String value) {
            this(label, value, 1, false, 'normal');
        }
    }
	//Table structure
    public virtual class Table {
        public String title {public get; private set;}
        public List<TableItem> items {public get; private set;}

        public Table(String title, List<TableItem> items) {
            this.title = title;
            this.items = items;
        }
    }
	//Table line structure
    public class TableItem {
        public List<Field> fields {public get; private set;}
        public Integer index {public get; private set;}
        public TableItem(List<Field> fields, Integer index) {
            this.fields = fields;
            this.index = index;
        }
    }
}