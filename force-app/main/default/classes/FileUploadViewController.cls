public without sharing class FileUploadViewController {
    @AuraEnabled(cacheable=true)
    public static List<ContentDocument> getRelatedFiles(List<Id> newFiles){
        System.debug('File IDs that entered Apex: ' + newFiles);
        //List<ContentDocument> files = new List<ContentDocument>([Select Id, Title, FileExtension, CreatedDate From ContentDocument WHERE Id IN :newFiles]);
        /*for(ContentDocument conDoc : [SELECT 
                                                ContentDocument.Id, 
                                                ContentDocument.Title, 
                                                ContentDocument.CreatedDate, 
                                                ContentDocument.FileType
                                                    FROM ContentDocumentLink 
                                                        WHERE ContentDocument.Id IN :filesToInsert]){
            File file = new File();
            file.Title = conLink.ContentDocument.Title;
            file.Id = conLink.ContentDocument.Id;
            file.CreatedDate = conLink.ContentDocument.CreatedDate;
            file.Type = conLink.ContentDocument.FileType;
            files.add(file);
        }*/
        return [SELECT Id, Title, FileExtension, CreatedDate, FileType, ContentSize FROM ContentDocument WHERE Id IN :newFiles];
    }

    public class File{
        @AuraEnabled public String Title;
        @AuraEnabled public String Type;
        @AuraEnabled public Id Id;
        @AuraEnabled public Datetime CreatedDate;
    }


    @AuraEnabled(cacheable=false)
    public static List<ContentVersion> createAssetFile(List<Id> newFile){
        
        ContentDocument conDoc = [SELECT Id, Title, FileExtension, FileType FROM ContentDocument WHERE Id IN :newFile];

       


        //UNCOMMENT THIS SOON
        
        ContentVersion newContent = new ContentVersion();
        newContent.ContentDocumentId = conDoc.Id;
        newContent.VersionData = blob.valueOf(conDoc.Title);
        //newContent.FileExtension = conDoc.FileExtension;
        //newContent.FileType = conDoc.FileType;
        newContent.ContentLocation = 'S'; // 'S' = a Salesforce File
        newContent.PathOnClient = conDoc.Title + '.' + conDoc.FileExtension;
        newContent.IsAssetEnabled = true;
        newContent.Title = conDoc.Title;
        
        insert newContent;

        List<ContentVersion> findCV = [SELECT Id from ContentVersion WHERE Id =: newContent.Id];
        return findCV;







        //List<ContentVersion> updateCon = new List<ContentVersion>();

        /*for(ContentVersion con : findCV){
            con.IsAssetEnabled = true;
            updateCon.add(con);
        }

        update updateCon;

        return updateCon;*/

        
        /*ContentDistribution cd = new ContentDistribution();
            cd.Name = conDoc.Title;
            cd.ContentVersionId = newContent.id;
            cd.PreferencesAllowViewInBrowser= true;
            cd.PreferencesLinkLatestVersion=true;
            cd.PreferencesNotifyOnVisit=false;
            cd.PreferencesPasswordRequired=false;
            cd.PreferencesAllowOriginalDownload= true;
            insert cd;

        List<ContentDistribution> findCD = [SELECT Id, DistributionPublicUrl FROM ContentDistribution where Id =: cd.Id];
        return findCD;*/

    }


  /* @AuraEnabled
    public static String uploadFile(String base64, String filename) {
          ContentVersion cv = createContentVersion(base64, filename);
          //ContentDocumentLink cdl = createContentLink(cv.Id, recordId);
          //if (cv == null || cdl == null) { return null; }
          return cv.Id;
    }*/
    @AuraEnabled
    public static ContentVersion createContentVersion(String base64, String filename) {
        ContentVersion cv = new ContentVersion();
        cv.VersionData = EncodingUtil.base64Decode(base64);
        cv.Title = filename;
        cv.PathOnClient = filename;
        cv.IsAssetEnabled = true;
         
        try {
          insert cv;
          return cv;

        } catch(DMLException e) {
          System.debug(e);
          return null;
        }
      }


      /*private static ContentDocumentLink createContentLink(String contentVersionId, String recordId) {
        if (contentVersionId == null || recordId == null) { return null; }
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = [
            SELECT ContentDocumentId 
            FROM ContentVersion 
            WHERE Id =: contentVersionId
            ].ContentDocumentId;
            cdl.LinkedEntityId = recordId;
            // ShareType is either 'V', 'C', or 'I'
            // V = Viewer, C = Collaborator, I = Inferred
            cdl.ShareType = 'V';
            try {
            insert cdl;
            return cdl;
            } catch(DMLException e) {
            System.debug(e);
            return null;
            }
        }*/

    @AuraEnabled
    public static ContentVersion getDocumentID(String conVerId){
        return [SELECT ContentDocumentId, FileExtension FROM ContentVersion WHERE Id =: conVerId];
    }
    
    @AuraEnabled
    public static List<ContentDistribution> createDistribution(String conVerId){
    ContentVersion conv = [select id, title from contentversion where Id = :conVerId];
            ContentDistribution cd = new ContentDistribution();
            cd.Name = conv.title;
            cd.ContentVersionId = conv.id;
            cd.PreferencesAllowViewInBrowser= true;
            cd.PreferencesLinkLatestVersion=true;
            cd.PreferencesNotifyOnVisit=false;
            cd.PreferencesPasswordRequired=false;
            cd.PreferencesAllowOriginalDownload= true;
            insert cd;

            return [SELECT DistributionPublicUrl FROM ContentDistribution WHERE Id = :cd.Id LIMIT 1];
               
    }

    @AuraEnabled
    public static String getContentDetails(String recordId) {
        List<ContentDocumentLink> contentDocumentList = [SELECT ContentDocumentId, LinkedEntityId 
                                                            FROM   ContentDocumentLink 
                                                            WHERE  LinkedEntityId =: recordId];
        Set<Id> contentDocumentId = new Set<Id>();
            
        for(ContentDocumentLink cdl : contentDocumentList){
            contentDocumentId.add(cdl.ContentDocumentId);
        }
            
        List<ContentVersion> contentVersionList = [SELECT Id, VersionData, FileType, Title, FileExtension,
                                                    ContentDocument.CreatedBy.Name, ContentDocument.ContentSize,
                                                    CreatedDate, ContentDocumentId, ContentDocument.FileType
                                                    FROM   ContentVersion 
                                                    WHERE  ContentDocumentId IN : contentDocumentId];
        return JSON.serialize(contentVersionList);
    }

    @AuraEnabled
    public static void deleteContentDocument(String recordId) {
        Database.delete(recordId);
    }

    public static string ContentType(String fileType) {

        switch on fileType.toLowerCase(){
            when 'docx' {
                return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
            }
            when 'csv' {
                return 'application/vnd.ms-excel';
            }
            when 'wav' {
                return 'audio/wav';
            }
            when 'wmv' {
                return 'video/x-ms-wmv';
            }
            when 'mp3' {
                return 'audio/mpeg';
            }
            when 'mp4' {
                return 'video/mp4';
            }
            when 'png' {
                return 'image/png';
                
            }
            when 'pdf' {
                return 'application/pdf';
                
            }
            when else {
                return 'image/jpeg';
            }
        }

    }



}