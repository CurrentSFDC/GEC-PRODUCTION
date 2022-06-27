trigger fileUploadTrigger on ContentDocumentLink (before insert) {

    for(ContentDocumentLink l:Trigger.new)l.Visibility='AllUsers'; 
    


}