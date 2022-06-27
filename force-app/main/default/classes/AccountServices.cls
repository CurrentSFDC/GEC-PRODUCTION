public class AccountServices {
    public static List<Account> getRelatedAccountsByContactId(String contactId) {

        List<Account> relatedAccounts = [SELECT Id, Name, GE_LGT_EM_SAP_Customer_Number__c FROM Account WHERE Id IN (SELECT AccountId FROM AccountContactRelation WHERE ContactId =: contactId)];
        return relatedAccounts;
    }

    public static List<Account> getRelatedAccountsByAccountId(String accountId) {

        Account effectiveAcct = [SELECT GE_LGT_Rep_Code__c from Account Where Id =: accountId];
        String repCode = effectiveAcct.GE_LGT_Rep_Code__c;
        String likeString = '%'+repCode+'%';
        List<Account> relatedAccounts = [SELECT Id, Name, GE_LGT_EM_SAP_Customer_Number__c,GE_LGT_EM_Order_Block__c,Customer_Segmentation__c FROM Account WHERE ConnectFixtureAgents__c  LIKE: likeString  or Connect_Share_with_Account_PartA__c LIKE: likeString or Connect_Share_with_Account_PartB__c LIKE: likeString or Connect_Share_with_Account_PartC__c LIKE:likeString ORDER BY Name];
        return relatedAccounts;
    }
    
    public static List<Account> getStrategicAccountsByAccountId() {

        /*Account effectiveAcct = [SELECT GE_LGT_Rep_Code__c from Account Where Id =: accountId];
        String repCode = effectiveAcct.GE_LGT_Rep_Code__c;
        String likeString = '%'+repCode+'%'; */
        List<Account> relatedAccounts = [SELECT Id, Name, GE_LGT_EM_SAP_Customer_Number__c,GE_LGT_EM_Order_Block__c,Customer_Segmentation__c FROM Account WHERE GE_LGT_EM_CustomerActiveFlag__c = True and Account_Group__c = 'ZSTG'];
        return relatedAccounts;
    }
    
    public static List<Account> getConnectFixtureAgents(String accountId) {
        
        List<Account> relatedRepCodes = new List<Account>();
        Account effectiveAcct = [SELECT ConnectFixtureAgents__c,Customer_Segmentation__c from Account Where Id =: accountId];
        if(effectiveAcct.Customer_Segmentation__c == 'FD'){
            String connectFixture = effectiveAcct.ConnectFixtureAgents__c;
            List<String> connectFixtureList =connectFixture.split('\\,') ;
            relatedRepCodes = [SELECT Id,GE_LGT_Rep_Code__c,Name FROM Account WHERE GE_LGT_Rep_Code__c IN:connectFixtureList];
            Map<String,Account> uniqueList=new Map<String,Account>();

			for(Account unique:relatedRepCodes){
    			uniqueList.put(unique.GE_LGT_Rep_Code__c,unique);
			}
            relatedRepCodes.clear();
            relatedRepCodes.addall(uniqueList.values());
            return relatedRepCodes;
        }
        else{
            return relatedRepCodes;
        }
        
        
    }
}