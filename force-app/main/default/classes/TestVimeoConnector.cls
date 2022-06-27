/**
 * Created by Misi on 2021-07-26.
 */
@IsTest
public with sharing class TestVimeoConnector {

    @IsTest
    static void testVimeoConnectorOnCreate() {
        Community_Content__c content = new Community_Content__c();
        insert content;
        Community_Content_Media__c element = new Community_Content_Media__c();
        element.Content_URL__c = 'https://vimeo.com/12345';
        element.Community_Content__c = content.Id;
        element.Type__c = 'Vimeo Link';
        Test.setMock(HttpCalloutMock.class, new VimeoConnectorMock());
        Test.startTest();
        {
            insert element;
        }
        Test.stopTest();
        element = [SELECT Id,Content_URL__c,Thumbnail__c FROM Community_Content_Media__c WHERE Id =: element.Id];
        System.assert(String.isNotBlank(element.Thumbnail__c));
        System.assertEquals('https://player.vimeo.com/video/12345',element.Content_URL__c);
    }

    @IsTest
    static void testVimeoConnectorOnupdate() {
        Community_Content__c content = new Community_Content__c();
        insert content;
        Community_Content_Media__c element = new Community_Content_Media__c();
        element.Content_URL__c = 'https://player.vimeo.com/video/123456';
        element.Community_Content__c = content.Id;
        insert element;
        Test.setMock(HttpCalloutMock.class, new VimeoConnectorMock());
        element.Type__c = 'Vimeo Link';
        Test.startTest();
        {
            update element;
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testVimeoConnectorOndelete() {
        Community_Content__c content = new Community_Content__c();
        insert content;
        Community_Content_Media__c element = new Community_Content_Media__c();
        element.Content_URL__c = 'https://player.vimeo.com/video/123456';
        element.Community_Content__c = content.Id;
        insert element;
        Test.setMock(HttpCalloutMock.class, new VimeoConnectorMock());
        element.Type__c = 'Vimeo Link';
        Test.startTest();
        {
            delete element;
        }
        Test.stopTest();
    }
}