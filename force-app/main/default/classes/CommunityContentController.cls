public without sharing class CommunityContentController {

    @AuraEnabled(Cacheable=true)
    public static Object getCommunityContent(Map<String,Object> urlParameters) {
        Map<String, String> typeMapping = new Map<String, String>{
                'training' => 'Trainings',
                'marketing-and-promotions' => 'Marketing & Promotions',
                'webinar' => 'Webinars',
                'news' => 'News',
                'newproducts' => 'New Product Introduction',
                'tools' => 'Tools',
                'connect-training' => 'Connect Training Library'
        };
        String type = (String) urlParameters?.get('type');
        if(String.isBlank(type) || !typeMapping.containsKey(type.toLowerCase())){
            return null;
        }

        String portalUserType = [SELECT Contact.Portal_User_Type__c FROM User WHERE Id = :UserInfo.getUserId()]?.Contact.Portal_User_Type__c;

        return [
                SELECT Id,Description__c,Title__c,Image_URL__c,IMG_URL__c,Hyperlink__c,Content_Type__c,Display_Date__c,Call_To_Action__c, Open_Hyperlink_In__c
                FROM Community_Content__c
                WHERE Listing_Start_Date__c <= TODAY AND Listing_End_Date__c >= TODAY AND Listing_Type__c = : typeMapping.get(type.toLowerCase())
                AND Persona__c IN ('All', :portalUserType)
        ];
    }

    @AuraEnabled(Cacheable=true)
    public static Id getToolsCommunityContentId(){
        return [SELECT Id FROM Community_Content__c WHERE Listing_Type__c = 'Tools' ORDER BY CreatedDate DESC LIMIT 1]?.Id;
    }

    @AuraEnabled(Cacheable=true)
    public static List<Community_Content_Sales_Kit__c> getCommSalesKits(Id contentId){
        return [SELECT Id, Name, Portal_User_Type__c, Type__c, Content_Id__c FROM Community_Content_Sales_Kit__c WHERE Community_Content__c =:contentId];
    }

    @AuraEnabled(Cacheable=true)
    public static List<Community_Content_Media__c> getCommMedia(Id contentId){
        return [SELECT Id, Name, URL__c, Type__c, Media_Id__c FROM Community_Content_Media__c WHERE Community_Content__c =:contentId];
    }

}