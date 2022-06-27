/**
 * Created by Misi on 2021-07-19.
 */

public with sharing class CommunityContentMediaTriggerHandler {

    public static void beforeInsert(List<Community_Content_Media__c> newList) {
        convertVimeoContentURL(newList);
    }

    public static void afterInsert(Map<Id, Community_Content_Media__c> newMap) {
        List<Community_Content_Media__c> vimeoMediaElements = filterVimeoContent(newMap.values());
        if (vimeoMediaElements.size() > 0) {
            List<Id> ids = new List<Id>();
            for (Community_Content_Media__c element : vimeoMediaElements) {
                ids.add(element.Id);
            }
            Database.executeBatch(new VimeoConnector(ids), 1);
        }
    }

    public static void beforeUpdate(Map<Id, Community_Content_Media__c> oldMap, Map<Id, Community_Content_Media__c> newMap) {
    }

    public static void afterUpdate(Map<Id, Community_Content_Media__c> oldMap, Map<Id, Community_Content_Media__c> newMap) {
        List<Community_Content_Media__c> vimeoMediaElements = filterVimeoContentOnURLChange(oldMap, newMap);
        if (vimeoMediaElements.size() > 0) {
            List<Id> ids = new List<Id>();
            for (Community_Content_Media__c element : vimeoMediaElements) {
                ids.add(element.Id);
            }
            Database.executeBatch(new VimeoConnector(ids), 1);
        }
    }

    public static void beforeDelete(Map<Id, Community_Content_Media__c> oldMap) {
    }

    public static void afterDelete(Map<Id, Community_Content_Media__c> oldMap) {
    }

    public static void afterUnDelete(Map<Id, Community_Content_Media__c> newMap) {
    }

    private static void convertVimeoContentURL(List<Community_Content_Media__c> communityContentMedia) {
        for (Community_Content_Media__c mediaElement : communityContentMedia) {
            if (mediaElement.Type__c == 'Vimeo Link' && String.isNotBlank(mediaElement.Content_URL__c) && Pattern.matches('^(https://|www\\.)vimeo\\.com.*', mediaElement.Content_URL__c.trim())) {
                mediaElement.Content_URL__c = mediaElement.Content_URL__c.replaceFirst('vimeo\\.com', 'player.vimeo.com/video').trim();
            }
        }
    }

    private static List<Community_Content_Media__c> filterVimeoContent(List<Community_Content_Media__c> communityContentMedia) {
        List<Community_Content_Media__c> vimeoMediaElements = new List<Community_Content_Media__c>();
        for (Community_Content_Media__c mediaElement : communityContentMedia) {
            if (String.isNotBlank(mediaElement.Content_URL__c) && mediaElement.Type__c == 'Vimeo Link' && String.isBlank(mediaElement.Thumbnail__c)) {
                vimeoMediaElements.add(mediaElement);
            }
        }
        return vimeoMediaElements;
    }

    private static List<Community_Content_Media__c> filterVimeoContentOnURLChange(Map<Id, Community_Content_Media__c> oldCommunityContentMedia, Map<Id, Community_Content_Media__c> communityContentMedia) {
        List<Community_Content_Media__c> vimeoMediaElements = new List<Community_Content_Media__c>();
        for (Community_Content_Media__c communityContentMediaElement : communityContentMedia.values()) {
            Community_Content_Media__c oldCommunityContentMediaElement = oldCommunityContentMedia.get(communityContentMediaElement.Id);
            if ((oldCommunityContentMediaElement.Content_URL__c != communityContentMediaElement.Content_URL__c || oldCommunityContentMediaElement.Type__c != communityContentMediaElement.Type__c) &&
                    String.isNotBlank(communityContentMediaElement.Content_URL__c) && communityContentMediaElement.Type__c == 'Vimeo Link') {
                vimeoMediaElements.add(oldCommunityContentMediaElement);
            }
        }
        return vimeoMediaElements;
    }
}