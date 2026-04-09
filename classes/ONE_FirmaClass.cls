public class ONE_FirmaClass {
    
    private final ONE_Documentos__c ehs;

public ONE_FirmaClass (ApexPages.StandardController controller) {
    ehs = (ONE_Documentos__c)controller.getRecord();
}

@RemoteAction public static RemoteSaveResult saveSignature(Id ehsId, String signatureBody) {
    Attachment a = new Attachment(ParentId=ehsId, name='Signature.png', ContentType='image/png', Body=EncodingUtil.base64Decode(signatureBody));
    Database.saveResult result = Database.insert(a,false);
    RemoteSaveResult newResult = new RemoteSaveResult();
    newResult.success = result.isSuccess();
    newResult.attachmentId = a.Id;
    newResult.errorMessage = result.isSuccess()?'':result.getErrors()[0].getMessage();
    return newResult;
}

public class RemoteSaveResult {
    public Boolean success;
    public Id attachmentId;
    public String errorMessage;
}

public pageReference cancel(){
    pageReference page = new PageReference('/'+ehs.id);
    page.setRedirect(true);
    return page;
}

}