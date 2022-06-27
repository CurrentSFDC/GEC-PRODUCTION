/**
 * Created by Misi on 2021-07-19.
 */

trigger CommunityContentMediaTrigger on Community_Content_Media__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    switch on Trigger.operationType {
        when BEFORE_INSERT {
            CommunityContentMediaTriggerHandler.beforeInsert(Trigger.new);
        }
        when AFTER_INSERT {
            CommunityContentMediaTriggerHandler.afterInsert(Trigger.newMap);
        }
        when BEFORE_UPDATE {
            CommunityContentMediaTriggerHandler.beforeUpdate(Trigger.oldMap, Trigger.newMap);
        }
        when AFTER_UPDATE {
            CommunityContentMediaTriggerHandler.afterUpdate(Trigger.oldMap, Trigger.newMap);
        }
        when BEFORE_DELETE {
            CommunityContentMediaTriggerHandler.beforeDelete(Trigger.oldMap);
        }
        when AFTER_DELETE {
            CommunityContentMediaTriggerHandler.afterDelete(Trigger.oldMap);
        }
        when AFTER_UNDELETE {
            CommunityContentMediaTriggerHandler.afterUnDelete(Trigger.newMap);
        }
    }
}