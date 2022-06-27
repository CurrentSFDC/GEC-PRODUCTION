/**
 * 2021-02-17.
 */

public without sharing class CommunityProductDetailController {

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getProductDetails(Id communityContentId) {

        Map<String, Object> response = new Map<String, Object>();
        Community_Content__c communityContent = [
                SELECT Id,
                        Image_URL__c,
                        Title__c,
                        Description__c,
                        Listing_Start_Date__c,
                        Listing_End_Date__c,
                        Content_Type__c,
                        Call_To_Action__c,
                        Subtitle_1_Header__c,
                        Subtitle_2_Header__c,
                        Subtitle_1_Description__c,
                        Subtitle_2_Description__c,
                        Accordion_Header__c,
                        Display_Date__c,
                        Hyperlink_System_Name__c,
                        Hyperlink__c,
                        Open_Hyperlink_In__c,
                        Persona__c,
                        Image_Alternate_Text__c,
                        Listing_Type__c,
                        Features_and_Benefits__c,
                        Applications__c,
                        Hyperlink_Mask__c,

                (SELECT Id,Type__c,URL__c,Media_Id__c,Content_URL__c,Thumbnail__c FROM Community_Content_Medias__r)

                FROM Community_Content__c
                WHERE Id = :communityContentId
        ];
        String portalUserType = [SELECT Contact.Portal_User_Type__c FROM User WHERE Id = :UserInfo.getUserId()]?.Contact.Portal_User_Type__c;
        List<Community_Content_Sales_Kit__c> communityContentSalesKits = [
                SELECT Id,Name,File_URL__c,Content_Id__c,toLabel(Type__c)
                FROM Community_Content_Sales_Kit__c
                WHERE Community_Content__c = :communityContent.Id
                and Portal_User_Type__c IN ('All', :portalUserType)
        ];

        response.put('communityContent', communityContent);
        response.put('communityContentMedia', communityContent.Community_Content_Medias__r);
        response.put('productDocuments', communityContentSalesKits);
        return response;
    }

    @AuraEnabled
    public static void sendFilesInEmail(List<Community_Content_Sales_Kit__c> communityContentSalesKitIds, String targetEmail) {
        if (String.isBlank(targetEmail) || communityContentSalesKitIds == null || communityContentSalesKitIds.isEmpty()) {
            throw new IllegalArgumentException('targetEmail and communityContentSalesKitIds cannot be empty');
        }
        Set<Id> contentDocumentIds = new Set<Id>();
        for (Community_Content_Sales_Kit__c communityContentSalesKit : communityContentSalesKitIds) {
            contentDocumentIds.add(communityContentSalesKit.Content_Id__c);
        }
        // TODO email template required
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new List<String>{
                'gm@attentioncrm.com'
                //, targetEmail
        });
        mail.setHtmlBody('TODO');
        mail.setSubject('TODO');
        List<Messaging.EmailFileAttachment> emailFileAttachments = new List<Messaging.EmailFileAttachment>();
        for (ContentVersion contentVersion : [
                SELECT Id,VersionData,Title,FileExtension
                FROM ContentVersion
                WHERE IsLatest = TRUE
                AND ContentDocumentId IN :contentDocumentIds
        ]) {
            Messaging.EmailFileAttachment emailFileAttachment = new Messaging.EmailFileAttachment();
            emailFileAttachment.body = contentVersion.VersionData;
            emailFileAttachment.fileName = contentVersion.Title;
            emailFileAttachment.contentType = contentVersion.FileExtension;
        }
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{
                mail
        });

    }
}