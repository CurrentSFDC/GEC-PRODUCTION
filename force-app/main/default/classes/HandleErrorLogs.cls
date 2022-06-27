public class HandleErrorLogs {
    Public static GE_LGT_EM_ErrorLog__c createErrorLog(String errMsg,id recordid,String ObjectName,String IntgStatus,List<String> FieldInfo){
        GE_LGT_EM_ErrorLog__c newerrorlog=new GE_LGT_EM_ErrorLog__c();
        newerrorlog.GE_LGT_EM_Description__c=errMsg;
        newerrorlog.ID__c=recordid;
        newerrorlog.GE_LGT_EM_Object__c=ObjectName;
        newerrorlog.GE_LGT_EM_IntegrationStatus__c=IntgStatus;
        newerrorlog.User__c=UserInfo.getUserId();
        newerrorlog.Field_Info__c=String.valueOf(FieldInfo);
        return newerrorlog;
        
    }
 }