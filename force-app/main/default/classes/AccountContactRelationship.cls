public without sharing class AccountContactRelationship {
    public void assignRelationship(List<AccountContactRelation> accountContactRelations){
        
        //List<Platform_Processing_Log__c> plList = new List<Platform_Processing_Log__c>();
        for (AccountContactRelation acr : accountContactRelations){
            List<AccountContactRelation> newAccList = new List<AccountContactRelation>();
            Id contactID = acr.ContactId;
            Id accountID = acr.AccountId;


            System.debug('Current Account ID: '+accountID);
            System.debug('Current Contact ID: '+contactID);

            Account tempList = [SELECT Id, GE_LGT_EM_SAP_Customer_Number__c FROM Account WHERE Id =: accountID AND Account_Group__c = 'ZEAG'];
            System.Debug('Current Account: '+tempList);

            String repCode = '%'+tempList.GE_LGT_EM_SAP_Customer_Number__c+'%';
            System.debug('Rep Code: '+repCode);

            Set<Id> relationshipList = new Set<Id>();
            for (AccountContactRelation relList : [SELECT AccountId FROM AccountContactRelation WHERE ContactId =: contactID ]){
                relationshipList.add(relList.AccountId);
            }
            System.debug('Relationship List : '+relationshipList);

            Set<Id> heirarchyList = new Set<Id>();
            for (Account accList : [SELECT Id FROM Account WHERE 
            (ConnectFixtureAgents__c LIKE :repCode OR Connect_Share_with_Account_PartA__c LIKE :repCode OR Connect_Share_with_Account_PartB__c LIKE :repCode OR Connect_Share_with_Account_PartC__c LIKE :repCode)
            AND Account_Group__c = 'Z001' AND GE_LGT_EM_CustomerActiveFlag__c = true AND Id NOT IN :relationshipList FOR UPDATE]){
                heirarchyList.add(accList.Id);
            }
            System.debug('Heirarchy List : '+heirarchyList.size());

            for(Id acc : heirarchyList){
                AccountContactRelation newACR = new AccountContactRelation();
                newACR.B2B_flag__c = true;
                newACR.ContactId = contactID;
                newACR.AccountId = acc;
                newAccList.add(newACR);
            }
        
            System.debug('Relations to Insert : '+newAccList);
            insert newAccList;
                /*List<Platform_Processing_Log__c> plList = new List<Platform_Processing_Log__c>();
                try{
                    insert newAccList;
                } catch(DmlException e){
                    Platform_Processing_Log__c pl = new Platform_Processing_Log__c();
                    pl.Operation__c = 'Insert';
                    pl.Log_Type__c = 'Apex Class';
                    pl.Message__c = 'AccountContactRelationShip - Class ' + e.getMessage();
                    pl.Object__c = 'AccountContactRelation';
                    plList.add(pl);
                }
                if (plList.size() > 0){
                    insert plList;
                }*/
        }    
        

       

        
















        /*
        Set<Id> contactAndAccountIds = new Set<Id>();

        for (AccountContactRelation acr : accountContactRelations){
                contactAndAccountIds.add(acr.AccountId);
                contactAndAccountIds.add(acr.ContactId);
            

            System.debug('Account Contact Relationships Entering APEX: '+contactAndAccountIds);

            List<Account> tempList = new List<Account>();
            tempList = [SELECT Id, GE_LGT_EM_SAP_Customer_Number__c FROM Account WHERE Id IN :contactAndAccountIds AND Account_Group__c = 'ZEAG'];
            System.debug('List of ACCOUNTS: '+tempList);
            for(Integer i = 0; i < tempList.size(); i++){
                
                String repCode = '%'+tempList[i].GE_LGT_EM_SAP_Customer_Number__c+'%';
                System.debug('Rep Code: '+repCode);

                Contact conList = [select Id from Contact WHERE Id IN :contactAndAccountIds];
                
                
                Set<Id> relationshipList = new Set<Id>();
                for (AccountContactRelation relList : [SELECT AccountId FROM AccountContactRelation WHERE ContactId IN :contactAndAccountIds ]){
                    relationshipList.add(relList.AccountId);
                }
                System.debug('Relationship List : '+relationshipList);

                //List<Id> heirarchyList = [SELECT Id FROM Account WHERE ConnectFixtureAgents__c LIKE :repCode AND Account_Group__c = 'Z001' AND GE_LGT_EM_CustomerActiveFlag__c = true AND Id NOT IN :relationshipList ];


                Set<Id> heirarchyList = new Set<Id>();
                for (Account accList : [SELECT Id FROM Account WHERE ConnectFixtureAgents__c LIKE :repCode AND Account_Group__c = 'Z001' AND GE_LGT_EM_CustomerActiveFlag__c = true AND Id NOT IN :relationshipList ]){
                    heirarchyList.add(accList.Id);
                }
                System.debug('Heirarchy List : '+heirarchyList.size());

                //List<AccountContactRelation> newAccList = new List<AccountContactRelation>();
                for(Id acc : heirarchyList){
                    AccountContactRelation newACR = new AccountContactRelation();
                    newACR.B2B_flag__c = true;
                    newACR.ContactId = conList.Id;
                    newACR.AccountId = acc;
                    newAccList.add(newACR);
                }
                System.debug('Relations to Insert : '+newAccList);
            }
        }
    
        
        insert newAccList;*/


    

        /*Map<String,String> accountIdByAccountNumber = new Map<String, String>();
        for (Account heirarchyList : [SELECT Id, GE_LGT_EM_SAP_Customer_Number__c FROM Account WHERE Id IN :contactAndAccountIds AND Account_Group__c = 'ZEAG']){
            accountIdByAccountNumber.put(heirarchyList.GE_LGT_EM_SAP_Customer_Number__c, heirarchyList.Id);
        }

        String repCode = '%'+accountContactRelations.AccountId.GE_LGT_EM_SAP_Customer_Number__c+'%';
        if (accountContactRelations.AccountId.Account_Group__c == 'ZEAG'){
            List<Account> heirarchyList = [SELECT Id FROM Account WHERE ConnectFixtureAgents__c LIKE :repCode];
        }
        System.debug('List of Heirarchy: 'heirarchyList);*/
    }

   
}