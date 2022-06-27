/*
Name - AccountTriggerHelper
Test Class - GE_LGT_preventDuplicateAccount_Test
Author - Shyam Prasad Nayakula
Purpose - As part of code modification due to SOQL issue code has been moved from Triggers to this helper class
Date - Aug-2016
Modified History:
**********************
Sept 2016 - Shyam Prasad Nayakula - Added Condition in createSoldToForAgentAccounts - KAFZY-1733
Sept 2016 - Andras Arva - Added Condition for Distribution_Channel - KAFZY-1797
Febr 2017 - Andras Arva - Add 3 Account lookups for Fam/Am; RCM; Rep KAFZY-2087
FEB 2017 - Shyam Prasad Nayakula - Moved all the code from Triggers to Helper Class and optimized SOQLs
*/
public class AccountTriggerHelper 
{
    public void methodsToInvokeOnInsert(List<Account> newAccountList)
    {
        //updateFieldsOnInsert(newAccountList);
        createSoldToForAgentAccounts(newAccountList);
    }
    public void methodsToInvokeOnUpdate(List<Account> newAccountList)
    {
        updateTeamMembersOnAccount(newAccountList);
        updateHierarchy(newAccountList); //Added by Neel: This method will establish hierarchical relationship (SAP Feed)
    }
    public void methodsToInvokeOnInsertAndUpdate(List<Account> newAccountList,List<Account> oldAccountList,Map<ID,Account> newMap,Map<ID,Account> oldMap)
    {
        updateFieldsOnInsert(newAccountList,oldMap);
        updateVerticals(newAccountList);
        updateNAFields(newAccountList,oldMap);
        updateBillingAddress(newAccountList,oldMap);
        updateFixtureAgentInformation(newAccountList);
        //ManageCustHierarchies(oldAccountList,newAccountList,oldMap,newMap);
    }
    
    public void createSoldToForAgentAccounts(List<Account> agentAccounts)
    {
        List<Account> soldToAccounts=new List<Account>();
        ID recordTypes=Schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP Account').getRecordTypeId();
        for(Account acc:agentAccounts)
        {
            if(acc.GE_LGT_EM_SAPUniqueIdentifier__c!=NULL && acc.GE_LGT_EM_SAPUniqueIdentifier__c.subStringAfterLast('-')=='Z4')
            {
                if(acc.GE_LGT_EM_Sales_Org__c!=NULL && (acc.GE_LGT_EM_Sales_Org__c=='1CA1' || acc.GE_LGT_EM_Sales_Org__c=='1US1') && 
                (acc.GE_LGT_Rep_Code__c!=NULL && !acc.GE_LGT_Rep_Code__c.endsWithIgnoreCase('0001')))
                {
                    Account newAcc=new Account();
                    System.debug('IN IF:');
                    newAcc=acc.clone();
                    if(acc.GE_LGT_EM_SAPUniqueIdentifier__c!=NULL)
                        newAcc.GE_LGT_EM_SAPUniqueIdentifier__c=acc.GE_LGT_EM_SAPUniqueIdentifier__c.subStringBeforeLast('-')+'-SP';
                    newAcc.GE_LGT_EM_PF_Type__c='SP';
                    newAcc.Account_Group__c='Z001';
                    if(recordTypes!=NULL )
                        newAcc.RecordTypeId=recordTypes;
                    soldToAccounts.add(newAcc);
                }
            }
            
        }
        System.debug('soldToAccounts:'+soldToAccounts);
        if(!soldToAccounts.isEmpty())
            Database.insert(soldToAccounts,false);
    }
    public void updateHierarchy(List<Account> acctList){
        List<ID> accIdLst = new List<ID>();
        for(Account acctVar:acctList){
            accIdLst.add(acctVar.id);
        }
    }
    
    public void updateTeamMembersOnAccount(List<Account> accounts)
    {
        List<ID> accIds=new List<ID>();
        for(Account acct:accounts)
        {
            accIds.add(acct.ID);
        }
        List<AccountTeamMember> acct_team_list= [select accountid, User.Name from AccountTeamMember where AccountId IN:accIds];
        system.debug('SOQL Consumed :: '+Limits.getQueries());
        Map<ID,String> accTeamMap=new Map<ID,String>();
        for(AccountTeamMember atm:acct_team_list)
        {
            if(!accTeamMap.containsKey(atm.AccountID))
            {
                accTeamMap.put(atm.AccountId,atm.User.Name);
            }
            else
            {
                String str= accTeamMap.get(atm.AccountId)+';'+atm.User.Name;
                if(str.length()>=254)
                {
                    str=str.substring(0,253);
                }
                accTeamMap.put(atm.AccountId,str);
            }
        }
        for(Account acct:accounts)
        {
            acct.GE_LGT_Account_Team_Members__c = accTeamMap.get(acct.Id);
        }
    }
    
    public void updateBillingAddress(List<Account> accounts,Map<ID,Account> oldMap)
    {
        Set<Id> recordTypeIds=new set<id>();
        Map<Id,Schema.RecordTypeInfo> recTypemap = Account.sObjectType.getDescribe().getRecordTypeInfosById();
        for(id reid:recTypemap.keySet())
        {
            string accRecordType=recTypemap.get(reid).getName();
            if(accRecordType=='SAP Account' ||accRecordType=='SAP Account - Strategic'||accRecordType=='SAP Account - Agent'||
               accRecordType=='SAP Account - Fixture Agent')
            {
                recordTypeIds.add(reid);
            }
        }
        Map<String, Account> AccountMapCustomerNum = new Map<String, Account>();
        Map<String, Account> AccountMapSalesorg = new Map<String, Account>();
        Map<String, Account> AccountMapDivision = new Map<String, Account>();
        Map<String, Account> AccountMapPFType = new Map<String, Account>();    //added by Neel to add 'GE_LGT_EM_PF_Type__c' for checking duplicate
        Map<String, Account> AccountMapDistribution = new Map<String, Account>();
        for(Account acct:accounts)
        {
            if(recordTypeIds.contains(acct.RecordTypeId))
            {
                if((Trigger.isInsert && acct.ShippingStreet!=NULL) || (Trigger.isUpdate && oldMap.get(acct.ID).ShippingStreet != acct.ShippingStreet ))
                    acct.BillingStreet=acct.ShippingStreet;
                if((Trigger.isInsert && acct.ShippingCity!=NULL) || (Trigger.isUpdate && oldMap.get(acct.ID).ShippingCity!= acct.ShippingCity))
                    acct.BillingCity=acct.ShippingCity;
                if((Trigger.isInsert && acct.ShippingState!=NULL) || (Trigger.isUpdate && oldMap.get(acct.ID).ShippingState!= acct.ShippingState))
                    acct.BillingState=acct.ShippingState;
                if((Trigger.isInsert && acct.ShippingPostalCode!=NULL) || (Trigger.isUpdate && oldMap.get(acct.ID).ShippingPostalCode!= acct.ShippingPostalCode))
                    acct.BillingPostalCode=acct.ShippingPostalCode;
                if((Trigger.isInsert && acct.ShippingCountry!=NULL) || (Trigger.isUpdate && oldMap.get(acct.ID).ShippingCountry!= acct.ShippingCountry))
                    acct.BillingCountry=acct.ShippingCountry;
                if(acct.GE_LGT_EM_Deletion_Flag__c=='X') 
                {
                    acct.GE_LGT_EM_Deletion_Flag__c='TRUE';    // SAP sends X for true                
                }
                if(acct.GE_LGT_EM_Deletion_Flag__c=='') 
                {
                    acct.GE_LGT_EM_Deletion_Flag__c='FALSE';    // SAP sends null for false
                }    
            }
        }
    }
    /*
    public void deleteEndUserAccounts(List<Account> newAccounts)
    {
        Map<String, Account> AccountMapCustomerNum = new Map<String, Account>();
        Map<String, Account> AccountMapSalesorg = new Map<String, Account>();
        Map<String, Account> AccountMapDivision = new Map<String, Account>();
        Map<String, Account> AccountMapPFType = new Map<String, Account>();
        Map<String, Account> AccountMapDistribution = new Map<String, Account>();
        Set<ID> newAccountIDs=new Set<ID>();
        for(Account acct:newAccounts)
        {
            if(!acct.GE_LGT_EM_CustomerActiveFlag__c)
            {
                newAccountIDs.add(acct.ID);
                AccountMapCustomerNum.put(acct.GE_LGT_EM_SAP_Customer_Number__c, acct);
                AccountMapSalesorg.put(acct.GE_LGT_EM_Sales_Org__c,acct);
                //AccountMapDivision.put(acct.GE_LGT_EM_Division__c,acct); 
                //AccountMapPFType.put(acct.GE_LGT_EM_PF_Type__c,acct);
                //AccountMapDistribution.put(acct.GE_LGT_EM_Distribution_Channel__c,acct); 
            }
        }
        ID EndUserRecTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User').getRecordTypeId();
        List<account> dupeAccList=[SELECT ID,Name,GE_LGT_EM_SAP_Customer_Number__c,GE_LGT_EM_Sales_Org__c
                                   GE_LGT_EM_Distribution_Channel__c,
                                   FROM Account
                                   WHERE ID NOT IN:newAccountIDs AND RecordTypeid=:EndUserRecTypeID AND 
                                   GE_LGT_EM_SAP_Customer_Number__c IN:AccountMapCustomerNum.KeySet() AND
                                   GE_LGT_EM_Sales_Org__c IN:AccountMapSalesorg.KeySet() /*AND
                                   GE_LGT_EM_Distribution_Channel__c IN: AccountMapDistribution.KeySet()
                                   ];//GE_LGT_EM_Division__c,
                                   //GE_LGT_EM_Division__c IN:AccountMapDivision.KeySet() AND 
        List<account> existingAccList=[SELECT ID,Name,GE_LGT_EM_SAP_Customer_Number__c,GE_LGT_EM_Sales_Org__c
                                       GE_LGT_EM_Distribution_Channel__c,GE_LGT_EM_PF_Type__c
                                       FROM Account
                                       WHERE ID IN:newAccountIDs];//GE_LGT_EM_Division__c,
        System.debug('TESTTTTTT:'+dupeAccList);
        List<Account> toDelete = new List<Account>();
        for(Account c:dupeAccList)
        {
            for(Account acct:existingAccList) 
            {
                //if(c.GE_LGT_EM_SAP_Customer_Number__c ==acct.GE_LGT_EM_SAP_Customer_Number__c && c.GE_LGT_EM_Distribution_Channel__c ==acct.GE_LGT_EM_Distribution_Channel__c && 
                //   c.GE_LGT_EM_Sales_Org__c==acct.GE_LGT_EM_Sales_Org__c && c.GE_LGT_EM_Division__c==acct.GE_LGT_EM_Division__c && 
                 //  c.GE_LGT_EM_PF_Type__c==acct.GE_LGT_EM_PF_Type__c) 
               // {
                //    toDelete.add(acct);
              //  }
            }
        }
        Database.delete(toDelete,False);
    }
    */
     //Added by Shyam for updating child fixture information in Parent Accounts - KAFZY-1942
  public static void updateParentFixtureInformation(List<Account> agentAccounts,Map<ID,Account> oldMap)
    {
        Set<ID> parentAccountIDs=new Set<ID>();
        ID recSpFAAgentypeID =Schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP Account - Fixture Agent').getRecordTypeId();
        ID recALBAgentypeID =Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent - Lamp & Ballast').getRecordTypeId();
        ID recAfLBtypeID =Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency - Fixtures / Lamp & Ballast').getRecordTypeId();
        ID recGAPypeID =Schema.SObjectType.Account.getRecordTypeInfosByName().get('Global Agent Parent').getRecordTypeId();
        ID recSASRtypeID =Schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP Account - Agent').getRecordTypeId();
        for(Account acc:agentAccounts)
        {
         if(trigger.isinsert){
            if(acc.ParentID!=NULL)
                parentAccountIDs.add(acc.ParentID);
            if(oldMap!=NULL && oldMap.containsKey(acc.ID) && oldMap.get(acc.ID).ParentID!=NULL)
                parentAccountIDs.add(oldMap.get(acc.ID).ParentID);
         }
            if(trigger.isupdate){ if(acc.GE_LGT_C_I__c!=oldMap.get(acc.ID).GE_LGT_C_I__c||acc.GE_LGT_Utility__c!=oldMap.get(acc.ID).GE_LGT_Utility__c||acc.GE_LGT_Controls__c!=oldMap.get(acc.ID).GE_LGT_Controls__c||acc.GE_LGT_Roadway__c!=oldMap.get(acc.ID).GE_LGT_Roadway__c||acc.Others__c!=oldMap.get(acc.ID).Others__c||acc.Lamp_Ballast__c!=oldMap.get(acc.ID).Lamp_Ballast__c||acc.GE_LGT_Architecture__c!=oldMap.get(acc.ID).GE_LGT_Architecture__c||acc.GE_LGT_DOT__c!=oldMap.get(acc.ID).GE_LGT_DOT__c||acc.GE_LGT_Sports__c!=oldMap.get(acc.ID).GE_LGT_Sports__c||acc.ParentID!=oldMap.get(acc.ID).ParentID){
                    if(acc.ParentID!=NULL)
                        parentAccountIDs.add(acc.ParentID);
                    if(oldMap!=NULL && oldMap.containsKey(acc.ID) && oldMap.get(acc.ID).ParentID!=NULL)
                        parentAccountIDs.add(oldMap.get(acc.ID).ParentID);
                        }
            }
        }
        if(parentAccountIDs.size()>0)
        {
            Map<ID,Account> parentAccountMap=new Map<ID,Account>();
                
            For (Account a :[SELECT ID,(SELECT ID,GE_LGT_C_I__c,GE_LGT_Utility__c,GE_LGT_Controls__c,GE_LGT_Roadway__c,Others__c,
                             Lamp_Ballast__c,GE_LGT_Architecture__c,GE_LGT_DOT__c,GE_LGT_Sports__c
                             FROM ChildAccounts) FROM Account WHERE ID IN:parentAccountIDs AND (Recordtypeid =:recSpFAAgentypeID OR Recordtypeid =:recALBAgentypeID OR Recordtypeid =:recAfLBtypeID OR Recordtypeid =:recGAPypeID OR Recordtypeid =:recSASRtypeID)]){
                parentAccountMap.put(a.id,a);        
            }                
            List<Account> parentsToUpdate=new List<Account>();
            for(Account parentAcc:parentAccountMap.values())
            {    
                Boolean ci=false,utility=false,controls=false,roadway=false,others=false,lamp=false,architecture=false,dot=false,sports=false;
                if(parentAcc.ChildAccounts.size()>0)
                {
                    for(Account childAcc:parentAcc.ChildAccounts)
                    {
                        if(childAcc.GE_LGT_C_I__c)
                            ci=true;
                        if(childAcc.GE_LGT_Utility__c)
                            utility=true;
                        if(childAcc.GE_LGT_Controls__c)
                            controls=true;
                        if(childAcc.GE_LGT_Roadway__c)
                            roadway=true;
                        if(childAcc.Others__c)
                            others=true;
                        if(childAcc.Lamp_Ballast__c)
                            lamp=true;
                        if(childAcc.GE_LGT_Architecture__c)
                            architecture=true;
                        if(childAcc.GE_LGT_DOT__c)
                            dot=true;
                        if(childAcc.GE_LGT_Sports__c)
                            sports=true;
                        
                    }
                    parentAcc.GE_LGT_C_I__c=ci;parentAcc.GE_LGT_Utility__c=utility;parentAcc.GE_LGT_Controls__c=controls;
                    parentAcc.GE_LGT_Roadway__c=roadway;parentAcc.Others__c=others;parentAcc.Lamp_Ballast__c=lamp;
                    parentAcc.GE_LGT_Architecture__c=architecture;parentAcc.GE_LGT_DOT__c=dot;
                    parentAcc.GE_LGT_Sports__c=sports;
                    parentsToUpdate.add(parentAcc);
                }
            }
            
            //System.debug('CheckRecursive.updateParentFixtureInfo:'+CheckRecursive.updateParentFixtureInfo);
            System.debug('parentsToUpdate:'+parentsToUpdate);
            if(parentsToUpdate.size()>0)
            {
                Database.update(parentsToUpdate,false);
            }
        }
    }

    
    public void updateFixtureAgentInformation(List<Account> agentAccounts)
    {          
        Map<String,Fixture_Agent_Information__c> fixtureFieldMap=Fixture_Agent_Information__c.getAll();
        //Map<ID,Account> parentAccMap=new Map<ID,Account>([SELECT ID FROM Account WHERE ParentID IN:agentAccounts]);
        Set<String> allFields=new Set<String>();
        allFields.add('Others__c');
        System.debug('fixtureFieldMap:'+fixtureFieldMap);
        if(fixtureFieldMap!=NULL)
        {
            for(Fixture_Agent_Information__c agent:fixtureFieldMap.values())
            {
                allFields.add(agent.Field_Name__c);
            }
        }
        //Start - AA - District Manager SSO logic
        //Store DistrictManager SSO and sfdc id in a set(for query) and then in a map
        Set<String> agentFederationIDs=new Set<String>();
        for (Account acct:agentAccounts) 
        {
            if(acct.GE_LGT_District_Manager__c !=NULL)
                agentFederationIDs.add(acct.GE_LGT_District_Manager__c );
            if(acct.GE_LGT_Regional_Manager__c !=NULL)
                agentFederationIDs.add(acct.GE_LGT_Regional_Manager__c );
        }       
        List<User> userlist=[SELECT ID,FederationIdentifier FROM User WHERE FederationIdentifier IN :agentFederationIDs AND IsActive=True AND FederationIdentifier!=NULL];
        Map<String,User> userAgentMap=new Map<String,User>();
        for(User usr : userlist)
        {
            userAgentMap.put(usr.FederationIdentifier, usr);
        }
        for(Account acc:agentAccounts)
        {
            if(acc.GE_LGT_District_Manager__c!=NULL && userAgentMap.containsKey(acc.GE_LGT_District_Manager__c))
            {
                acc.District_Manager_Name__c=userAgentMap.get(acc.GE_LGT_District_Manager__c).ID;               
            }
            else 
            {
                acc.District_Manager_Name__c=NULL;
            }
            
            if(acc.GE_LGT_Regional_Manager__c!=NULL && userAgentMap.containsKey(acc.GE_LGT_Regional_Manager__c))
            {
                acc.Regional_Manager_Name__c=userAgentMap.get(acc.GE_LGT_Regional_Manager__c).ID;             
            }
            else 
            {
                acc.Regional_Manager_Name__c=NULL;
            }                                    
            //end- AA - District Manager SSO logic
            
            
            if(acc.SAP_Fixture_Code__c!=NULL && fixtureFieldMap.containsKey(acc.SAP_Fixture_Code__c))
            {
                acc.put(fixtureFieldMap.get(acc.SAP_Fixture_Code__c).Field_Name__c,True);
            }
            else if(acc.SAP_Fixture_Code__c!=NULL && !fixtureFieldMap.containsKey(acc.SAP_Fixture_Code__c))
            {
                acc.put('Others__c',True);
            }
        }
    }
    
    //Below method is to track Delected enduser records -KAFZY-1950
    public void TrackDeletedRecordsToNewCO (List<Account> del_list)
    {
        ID recEDurypeID =Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User').getRecordTypeId();
        list<SAP_Records_Recycle__c>  de_co = new list<SAP_Records_Recycle__c>();
        for(Account de :del_list){
            if(de.Recordtypeid==recEDurypeID && de.Act_Converted_to_End_User__c==true){
                SAP_Records_Recycle__c denduser=new SAP_Records_Recycle__c();
                denduser.GE_LGT_EM_Distribution_Channel__c =de.GE_LGT_EM_Distribution_Channel__c;
                denduser.GE_LGT_EM_Division__c = de.GE_LGT_EM_Division__c;
                denduser.GE_LGT_EM_PF_Type__c  = de.GE_LGT_EM_PF_Type__c;
                denduser.GE_LGT_EM_Sales_Org__c = de.GE_LGT_EM_Sales_Org__c;
                denduser.GE_LGT_EM_SAP_Customer_Number__c = de.GE_LGT_EM_SAP_Customer_Number__c;
                denduser.RecordType__c='End User';
                denduser.Object__c='Account';
                denduser.Account_Name__c=de.Name;
                de_co.add(denduser);
            }
        }
        insert de_co;
    }
    
    //Below method is to avoid duplicate enduser records -KAFZY-1950
    public void DeleteDuplicateEdAccounts(List<Account> accounts_dellist)
    {
        set<String> AccountMap = new set<String>();
        set<String> AccountMapSalesorg = new set<String>();
        set<String> AccountMapDivision = new set<String>();
        set<String> AccountMapPFType = new set<String>();   
        set<String> AccountMapDistribution = new set<String>();  
        list<account> deletedupeaccount = new list<account>();
        set<id> accids=new set<id>();
        ID recSASypeID1 =Schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP Account - Strategic').getRecordTypeId();
        ID recSASypeID2 =Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User').getRecordTypeId();
        list<account> accounts_dellist1 =[Select id,GE_LGT_EM_SAP_Customer_Number__c,GE_LGT_EM_Sales_Org__c,GE_LGT_EM_Division__c,GE_LGT_EM_PF_Type__c,
        GE_LGT_EM_Distribution_Channel__c FROM account where Act_Converted_to_End_User__c=true AND Recordtypeid=:recSASypeID2  AND id IN: accounts_dellist];
        
        for (Account acc :accounts_dellist) 
        {
            if(acc.GE_LGT_EM_SAP_Customer_Number__c !=null && acc.Recordtypeid==recSASypeID1)
            {
                accids.add(acc.id);
                AccountMap.add(acc.GE_LGT_EM_SAP_Customer_Number__c);
                AccountMapSalesorg.add(acc.GE_LGT_EM_Sales_Org__c);
                AccountMapDivision.add(acc.GE_LGT_EM_Division__c); 
                AccountMapPFType.add(acc.GE_LGT_EM_PF_Type__c);
                AccountMapDistribution.add(acc.GE_LGT_EM_Distribution_Channel__c); 
            }
        }
        if(accids.size()>0){
            List<SAP_Records_Recycle__c> Delacclist=[Select id,GE_LGT_EM_SAP_Customer_Number__c,GE_LGT_EM_PF_Type__c,GE_LGT_EM_Sales_Org__c,GE_LGT_EM_Division__c,
                                                     GE_LGT_EM_Distribution_Channel__c from SAP_Records_Recycle__c where GE_LGT_EM_SAP_Customer_Number__c IN:AccountMap OR
                                                     GE_LGT_EM_Sales_Org__c IN:AccountMapSalesorg OR
                                                     GE_LGT_EM_Division__c IN:AccountMapDivision OR
                                                     GE_LGT_EM_Distribution_Channel__c IN: AccountMapDistribution OR
                                                     GE_LGT_EM_PF_Type__c IN:AccountMapPFType];
                                                    
            
            for(Account c:accounts_dellist)
            {
                for(SAP_Records_Recycle__c d:Delacclist) 
                {
                    if(c.GE_LGT_EM_CustomerActiveFlag__c==false && c.GE_LGT_EM_SAP_Customer_Number__c ==d.GE_LGT_EM_SAP_Customer_Number__c && 
                       c.GE_LGT_EM_Distribution_Channel__c ==d.GE_LGT_EM_Distribution_Channel__c && c.GE_LGT_EM_Sales_Org__c==d.GE_LGT_EM_Sales_Org__c && 
                       c.GE_LGT_EM_Division__c==d.GE_LGT_EM_Division__c && c.GE_LGT_EM_PF_Type__c==d.GE_LGT_EM_PF_Type__c) {
                           deletedupeaccount.add(c);
                           
                       }
                }
            }
            if(deletedupeaccount.size()>0)
                delete [select id from Account  where id in:deletedupeaccount];
        }
    }
    
    //To update the fields on Insert of Account
    public void updateFieldsOnInsert(List<Account> newAccountList,Map<ID,Account> oldMap)
    {
        ID recSAPAgentypeID =Schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP Account - Fixture Agent').getRecordTypeId();
        Set<String> federationIDs=new Set<String>();
        Map<String,User> userMap=new Map<String,User>();
        for (Account acc :newAccountList) 
        {
             if(Trigger.isInsert && acc.Owner_SSO__c!=NULL)
                federationIDs.add(acc.Owner_SSO__c);
            if(Trigger.isUpdate && (acc.Owner_SSO__c!=oldMap.get(acc.Id).Owner_SSO__c) && acc.Account_Group__c!='ZEAG'&& acc.RecordTypeid!=recSAPAgentypeID)
                federationIDs.add(acc.Owner_SSO__c);
        }
        List<User> userList=new List<User>();
        userList=[SELECT ID,FederationIdentifier FROM User WHERE FederationIdentifier IN:federationIDs AND  IsActive=True];
        userMap=new Map<String,User>();
        for(User u:userList)
        {
            userMap.put(u.FederationIdentifier, u);
        }
        for (Account acc :newAccountList) 
        {
            if(acc.Owner_SSO__c!=NULL && userMap.get(acc.Owner_SSO__c)!=NULL)
            {
                acc.OwnerID=userMap.get(acc.Owner_SSO__c).ID;
            }   
        }
    }
    
    //To update the fields on Insert and Update of Account
    public void updateVerticals(List<Account> newAccountList)
    {
        List<Account_KeyValue_Store__c> customValues=Account_KeyValue_Store__c.getAll().values();   //load custom settings for three fields(key and value mapping)
        Map<String, String> mapVerticalKeyValue = new Map<String, String>();
        Map<String, String> mapSubVerticalKeyValue = new Map<String, String>();
        Map<String, String> mapSalesOfficeKeyValue = new Map<String, String>();
        Map<String, String> mapSalesGroupKeyValue = new Map<String, String>();
        for(Account_KeyValue_Store__c  c:customValues)
        {
            if(c.FieldName__c=='Vertical')
                mapVerticalKeyValue.put(c.Code__c,c.Description__c);
            else if(c.FieldName__c=='Sub Vertical')
                mapSubVerticalKeyValue.put(c.Code__c,c.Description__c);
            else if(c.FieldName__c=='SalesOffice')
                mapSalesOfficeKeyValue.put(c.Code__c,c.Description__c);
            else if(c.FieldName__c=='SalesGroup')
                mapSalesGroupKeyValue.put(c.Code__c,c.Description__c);
        }
        for (Account acc :newAccountList) 
        {
            if( mapVerticalKeyValue.get(acc.GE_LGT_Vertical__c)!=null )
            {
                acc.GE_LGT_Vertical__c=mapVerticalKeyValue.get(acc.GE_LGT_Vertical__c); 
            }
            if( mapSubVerticalKeyValue.get(acc.GE_LGT_Sub_Vertical__c)!=null )
            {
                acc.GE_LGT_Sub_Vertical__c=mapSubVerticalKeyValue.get(acc.GE_LGT_Sub_Vertical__c); 
            }
            if( mapSalesGroupKeyValue.get(acc.GE_LGT_Sales_Group__c)!=null )
            {
                acc.GE_LGT_Sales_Group__c  = mapSalesGroupKeyValue.get(acc.GE_LGT_Sales_Group__c);
            }
            if( mapSalesOfficeKeyValue.get(acc.GE_LGT_Sales_Office__c)!=null)
            {
                acc.GE_LGT_Sales_Office__c = mapSalesOfficeKeyValue.get(acc.GE_LGT_Sales_Office__c);
            }      
        }
    }
    
    //To update the fields on Insert and Update of Account
    public void updateNAFields(List<Account> newAccountList,Map<ID,Account> oldMap)
    {
        System.debug('Trigger.New1:'+Trigger.New);
        Set<String> AcctNameSet=new Set<String>();
        Set<String> AcctSiteSet=new Set<String>();
        Set<String> AcctUniqueSet=new Set<String>();
        
        for(Account currentObj:newAccountList)
        {
            if(currentObj.site!=null) 
            {
                if(Trigger.isInsert ||(currentObj.name!=oldMap.get(currentObj.id).name ||currentObj.site!=oldMap.get(currentObj.id).site))
                {
                    AcctNameSet.add(currentObj.name);
                    AcctSiteSet.add(currentObj.site);
                    
                }
            }
        }
        List<Account> AcctName =new List<Account>();  
        AcctName =[SELECT name,site FROM Account WHERE name in : AcctNameSet AND site in : AcctSiteSet AND site != null];
        for(Account Acct:AcctName)    
        {
            AcctUniqueSet.add(Acct.name.toUpperCase() + '^^' + Acct.site.toUpperCase());
        }
        for(Account Acct:newAccountList)
        {
            if(Acct.site!=null) 
            {
                if(AcctUniqueSet.contains(Acct.Name.toUpperCase() + '^^' + Acct.site.toUpperCase()))
                {
                    Acct.addError('Account \''+Acct.name+'\' at \''+Acct.site+'\' already exist in the system. Please use the existing Account');
                }
            }
        }
        //GE_NAS List of value code
        ID ShiptorecTypID= Schema.SObjectType.Account.getRecordTypeInfosByName().get('NA Service Ship To Account').getRecordTypeId();
        ID BilltorecTypID =Schema.SObjectType.Account.getRecordTypeInfosByName().get('NA Service Bill To Account').getRecordTypeId();
        Map<String,String> national_type_lov=new map<String,String>();
        Map<String,String> account_status_lov=new map<String,String>();
        Map<String,String> business_code_lov=new map<String,String>();
        Map<String,String> Language_lov=new map<String,String>();
        Map<String,String> shipping_type_lov=new map<String,String>();
        Map<String,String> shipping_schedule_lov=new map<String,String>();
        Map<String,String> preferred_carrier_lov=new map<String,String>();
        Map<String,String> NCSC_component_code_lov=new map<String,String>();
        Map<String,String> Default_Distribution_Center_lov=new map<String,String>();
        Map<String,ID> map_parentID=new Map<String,ID>();
        /*List<Account> lst_billtoAcc=new List<Account>();
        Set<String> set_billToNo=new Set<String>();
        List<Account> lst_NationalAcc=new List<Account>();
        Set<String> set_NaionalNo=new Set<String>();
        
        for(Account acc:newAccountList)
        {
        if(acc.GE_NAS_Bill_To_Account_Number__c!=null)
        set_billToNo.add(acc.GE_NAS_Bill_To_Account_Number__c);
        if(acc.GE_NAS_National_Account_Number__c!=null)
        set_NaionalNo.add(acc.GE_NAS_National_Account_Number__c);
        }
        if(set_billToNo.size()>0)
        {
        lst_billtoAcc=[SELECT ID,GE_NAS_AccountNo__c FROM Account WHERE GE_NAS_AccountNo__c != NULL AND GE_NAS_AccountNo__c IN :set_billToNo];
        if(lst_billtoAcc.size()>0)
        for(Account acc:lst_billtoAcc)
        map_parentID.put(acc.GE_NAS_AccountNo__c,acc.ID);
        }
        if(set_NaionalNo.size()>0)
        {
        lst_NationalAcc=[SELECT ID,GE_NAS_AccountNo__c FROM Account WHERE GE_NAS_AccountNo__c != NULL AND GE_NAS_AccountNo__c IN :set_NaionalNo];
        if(lst_NationalAcc.size()>0)
        for(Account acc:lst_NationalAcc)
        map_parentID.put(acc.GE_NAS_AccountNo__c,acc.ID);
        }
        */
        //Commented above code to reduce the SOQLs - Shyam
        Set<String> NASAccNumSet=new Set<String>();
        for(Account acc:newAccountList)
        {
            if(acc.GE_NAS_Bill_To_Account_Number__c!=null)
                NASAccNumSet.add(acc.GE_NAS_Bill_To_Account_Number__c);
            if(acc.GE_NAS_National_Account_Number__c!=null)
                NASAccNumSet.add(acc.GE_NAS_National_Account_Number__c);
        }
        List<Account> retrivedAccList = [SELECT ID,GE_NAS_AccountNo__c FROM Account WHERE GE_NAS_AccountNo__c != NULL 
                                         AND GE_NAS_AccountNo__c IN :NASAccNumSet];
        for(Account acc:retrivedAccList)
        {
            map_parentID.put(acc.GE_NAS_AccountNo__c,acc.ID);   
        }
        
        List<String> fieldList=new List<String>();
        fieldList.add('GE_NAS_National_Type');
        fieldList.add('GE_NAS_Account_status');
        fieldList.add('GE_NAS_GE_Business_Code');
        fieldList.add('GE_NAS_Language');
        fieldList.add('GE_NAS_Shipping_Type');
        fieldList.add('GE_NAS_Shipping_Schedule');
        fieldList.add('GE_NAS_Preferred_Carrier');
        fieldList.add('GE_NAS_NCSC_Component_Code');
        fieldList.add('GE_NAS_Default_Distribution_Center');
        Map<String,String> mapLV = new Map<String,String>();
        List<GE_NAS_List_of_Value__c> lv = [select GE_NAS_Code_Value__c,GE_NAS_Val__c from GE_NAS_List_of_Value__c where GE_NAS_Object__c='Account' and Name IN:fieldList];
        for(GE_NAS_List_of_Value__c l :lv)
        {
            mapLV.put(l.GE_NAS_Code_Value__c,l.GE_NAS_Val__c);
        }        
        for(Account Acc:newAccountList)
        {
            if(mapLV.containsKey(Acc.GE_NAS_National_Type__c))
            {
                Acc.GE_NAS_National_Type_Desc__c=mapLV.get(Acc.GE_NAS_National_Type__c);
            }
            if(mapLV.containsKey(Acc.GE_NAS_Account_status__c))
            {
                Acc.GE_NAS_Account_status__c=mapLV.get(Acc.GE_NAS_Account_status__c);
            }
            if(mapLV.containsKey(Acc.GE_NAS_GE_Business_Code__c))
            {
                Acc.GE_NAS_Business_Code_Description__c=mapLV.get(Acc.GE_NAS_GE_Business_Code__c);
            }
            if(mapLV.containsKey(Acc.GE_NAS_Language__c))
            {
                Acc.GE_NAS_Language_Description__c=mapLV.get(Acc.GE_NAS_Language__c);
            }
            if(mapLV.containsKey(Acc.GE_NAS_Shipping_Type__c))
            {
                Acc.GE_NAS_Shipping_Type_Desc__c=mapLV.get(Acc.GE_NAS_Shipping_Type__c);
            }
            if(mapLV.containsKey(Acc.GE_NAS_Shipping_Schedule__c))
            {
                Acc.GE_NAS_Shipping_Schedule_Desc__c=mapLV.get(Acc.GE_NAS_Shipping_Schedule__c);
            }
            if(mapLV.containsKey(Acc.GE_NAS_Preferred_Carrier__c))
            {
                Acc.GE_NAS_Preferred_Carrier_Desc__c=mapLV.get(Acc.GE_NAS_Preferred_Carrier__c);
            }
            if(mapLV.containsKey(Acc.GE_NAS_NCSC_Component_Code__c))
            {
                Acc.GE_NAS_NCSC_Component_Description__c=mapLV.get(Acc.GE_NAS_NCSC_Component_Code__c);
            }
            if(mapLV.containsKey(Acc.GE_NAS_Default_Distribution_Center__c))
            {
                Acc.GE_NAS_Distribution_Center_Desc__c=mapLV.get(Acc.GE_NAS_Default_Distribution_Center__c);
            }
            if(Acc.RecordTypeId==ShiptorecTypID)
            {
                if(map_parentID.containsKey(Acc.GE_NAS_Bill_To_Account_Number__c))
                    Acc.ParentId=map_parentID.get(Acc.GE_NAS_Bill_To_Account_Number__c);
                else
                    Acc.ParentId=null;
            }
            if(Acc.RecordTypeId==BilltorecTypID)
            {
                if(map_parentID.containsKey(Acc.GE_NAS_National_Account_Number__c))
                    Acc.ParentId=map_parentID.get(Acc.GE_NAS_National_Account_Number__c);
                else
                    Acc.ParentId=null;
            }
        } 
    }
    
    /*public void deleteDuplicateAccounts(List<Account> accounts)
    {
        Map<String, Account> AccountMap = new Map<String, Account>();
        Map<String, Account> AccountMapSalesorg = new Map<String, Account>();
        Map<String, Account> AccountMapDivision = new Map<String, Account>();
        Map<String, Account> AccountMapPFType = new Map<String, Account>();    //added by Neel to add 'GE_LGT_EM_PF_Type__c' for checking duplicate
        Map<String, Account> AccountMapDistribution = new Map<String, Account>();  // Added by Andras
        Map<id,account> updateacc = new Map<id,Account>();
        set<string> deletedupeaccount = new set<string>();
        set<id>newaccountids=new set<id>();
        set<string>newduplicate=new set<string>();
        Set<Id> recordTypeIds=new set<id>();
        Map<Id,Schema.RecordTypeInfo> recTypemap = Account.sObjectType.getDescribe().getRecordTypeInfosById();
        for(id reid:recTypemap.keySet())
        {
            string accRecordType=recTypemap.get(reid).getName();
            if(accRecordType=='SAP Account' ||accRecordType=='SAP Account - Strategic'||accRecordType=='SAP Account - Agent'||
               accRecordType=='SAP Account - Fixture Agent'||accRecordType=='End User' || accRecordType=='SAP Account Strategic Pole'
              || accRecordType == 'SAP Account Strategic Global')
            {
                recordTypeIds.add(reid);
                
            }
        }
        for (Account acc :accounts) 
        {
            //If the Account SAP_Customer Number is not null and the Record type matches "SAP Account", "SAP Account - Strategic" or "SAP Account - Agent" 
            if(acc.GE_LGT_EM_SAP_Customer_Number__c !=null && recordTypeIds.contains(acc.RecordTypeid))
            {
                AccountMap.put(acc.GE_LGT_EM_SAP_Customer_Number__c, acc);//collect all new customernumber
                AccountMapSalesorg.put(acc.GE_LGT_EM_Sales_Org__c,acc);
                //AccountMapDivision.put(acc.GE_LGT_EM_Division__c,acc); 
                //AccountMapPFType.put(acc.GE_LGT_EM_PF_Type__c,acc);
                AccountMapDistribution.put(acc.GE_LGT_EM_Distribution_Channel__c,acc); // Added by Andras
                newaccountids.add(acc.id);//collect all new ids
                system.debug('newaccountids----->'+newaccountids);
            }
        }
        //find the same customer number already exist or not in system 
        list<account> Dupeacclist=[SELECT id,
                                   Name,
                                   SAP_Strategic_Sales_Group__c, //Added-Nov2016 -By Neel
                                   GE_LGT_EM_Partner_Function__c,
                                   BillingStreet,
                                   GE_LGT_EM_Sales_Org__c,
                                   GE_LGT_EM_Division__c,
                                   GE_LGT_EM_Distribution_Channel__c, // Added by Andras
                                   BillingCity,
                                   BillingState,
                                   BillingPostalCode,
                                   ShippingStreet,
                                   ShippingCity,
                                   ShippingState,
                                   ShippingPostalCode,
                                   Recordtypeid,
                                   Phone,
                                   Website,
                                   ParentID,
                                   Pricing_Group__c,
                                   GE_LGT_EM_CustomerActiveFlag__c,
                                   GE_LGT_EM_Tax_Number_1__c,
                                   GE_LGT_EM_Tax_Number_2__c,
                                   CurrencyIsoCode,
                                   GE_LGT_EM_Plant__c,
                                   GE_LGT_EM_PF_Type__c,
                                   GE_LGT_EM_Customer_Phone__c,  // Added by Andras - SAP Phone number
                                   GE_LGT_EM_Deletion_Flag__c,   // Deleletion flag SAP sends X for true
                                   SAP_Fixture_Code__c,
                                   GE_LGT_EM_SAP_Customer_Number__c FROM Account
                                   WHERE id NOT IN:newaccountids and RecordTypeid IN: recordTypeIds and 
                                   GE_LGT_EM_SAP_Customer_Number__c IN:AccountMap.KeySet() and
                                   GE_LGT_EM_Sales_Org__c IN:AccountMapSalesorg.KeySet() and
                                   GE_LGT_EM_Division__c IN:AccountMapDivision.KeySet() and 
                                   GE_LGT_EM_Distribution_Channel__c IN: AccountMapDistribution.KeySet() and //Added by Andras
                                   GE_LGT_EM_PF_Type__c IN : AccountMapPFType.KeySet() ];
        system.debug('already dupe in system newaccountids----->'+Dupeacclist);
        
        list<account> newacclist=[SELECT id,GE_LGT_EM_SAP_Customer_Number__c FROM Account WHERE RecordTypeid IN: recordTypeIds and
                                  GE_LGT_EM_SAP_Customer_Number__c IN:AccountMap.KeySet() and GE_LGT_EM_Sales_Org__c IN:AccountMapSalesorg.KeySet() and
                                  GE_LGT_EM_Division__c IN:AccountMapDivision.KeySet() and GE_LGT_EM_PF_Type__c IN : AccountMapPFType.KeySet() and
                                  GE_LGT_EM_Distribution_Channel__c IN: AccountMapDistribution.KeySet() ];
        system.debug('newaccounts and old accounts----->'+newacclist.size());
        ID recEDypeID =Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User').getRecordTypeId();
        ID recSASypeID =Schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP Account - Strategic').getRecordTypeId();
        ID recSAPAgentypeID =Schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP Account - Fixture Agent').getRecordTypeId();
        for(Account c:accounts)
        {
            for(Account acct:Dupeacclist) 
            {
                if(recordTypeIds.contains(c.RecordTypeid) && c.GE_LGT_EM_SAP_Customer_Number__c ==acct.GE_LGT_EM_SAP_Customer_Number__c && 
                   c.GE_LGT_EM_Distribution_Channel__c ==acct.GE_LGT_EM_Distribution_Channel__c && c.GE_LGT_EM_Sales_Org__c==acct.GE_LGT_EM_Sales_Org__c && 
                   c.GE_LGT_EM_Division__c==acct.GE_LGT_EM_Division__c && c.GE_LGT_EM_PF_Type__c==acct.GE_LGT_EM_PF_Type__c) {
                       //Below if condition logic added by Sai (KAFZY-1859:Description Issue -2)
                       if(acct.RecordTypeid!=recEDypeID)
                       { 
                           acct.Name=c.Name;
                           
                           // SAP sends one address and the same should go to Shipping as welll as billing address in sfdc
                           acct.BillingStreet=c.ShippingStreet;
                           acct.BillingCity=c.ShippingCity;
                           acct.BillingState=c.ShippingState;
                           acct.BillingPostalCode=c.ShippingPostalCode;
                           acct.BillingCountry=c.ShippingCountry;
                           //Adding Shipping info
                           acct.ShippingStreet=c.ShippingStreet;
                           acct.ShippingCity=c.ShippingCity;
                           acct.ShippingState=c.ShippingState;
                           acct.ShippingPostalCode=c.ShippingPostalCode;
                           acct.ShippingCountry=c.ShippingCountry;
                           //Phone and Website - added April2016
                           acct.Phone=c.Phone;
                           acct.Website=c.Website;
                           acct.SAP_Strategic_Sales_Group__c=c.SAP_Strategic_Sales_Group__c; //Addeed-Nov-2016 -By Neel
                           //if(c.Account_Group__c !='ZSTG' && c.RecordTypeid!=recSASypeID ){
                           acct.GE_LGT_EM_CustomerActiveFlag__c=c.GE_LGT_EM_CustomerActiveFlag__c;
                           //}
                           acct.GE_LGT_EM_Tax_Number_1__c=c.GE_LGT_EM_Tax_Number_1__c;
                           acct.GE_LGT_EM_Tax_Number_2__c=c.GE_LGT_EM_Tax_Number_2__c;
                           acct.Account_Group__c=c.Account_Group__c;
                           acct.GE_LGT_Sales_Group__c=c.GE_LGT_Sales_Group__c;
                           acct.GE_LGT_Sales_Office__c=c.GE_LGT_Sales_Office__c;
                           acct.GE_LGT_Sub_Vertical__c=c.GE_LGT_Sub_Vertical__c;
                           acct.GE_LGT_Vertical__c=c.GE_LGT_Vertical__c;
                           acct.Pricing_Group__c=c.Pricing_Group__c;
                           acct.GE_LGT_FAM_AM__c=c.GE_LGT_FAM_AM__c;                     //by Andras KAFZY-2087
                           acct.GE_LGT_Regional_Manager__c=c.GE_LGT_Regional_Manager__c;
                           acct.GE_LGT_District_Manager__c=c.GE_LGT_District_Manager__c; //End AA
                           acct.Owner_SSO__c=c.Owner_SSO__c;
                           if(c.Account_Group__c!='ZEAG'&& c.RecordTypeid!=recSAPAgentypeID )
                           {  //Below if condition logic added by SIVA (KAFZY-2196:Agent Owner mapping need to Delete this logic )
                               
                               acct.OwnerID=c.OwnerID;
                           }
                           acct.GE_LGT_EM_SAPUniqueIdentifier__c = c.GE_LGT_EM_SAPUniqueIdentifier__c;
                           acct.GE_LGT_EM_Customer_Phone__c=c.GE_LGT_EM_Customer_Phone__c;  // Added by Andras - SAP Phone number
                           acct.GE_LGT_EM_Distribution_Channel__c=c.GE_LGT_EM_Distribution_Channel__c; // Added by Andras
                           acct.SAP_Fixture_Code__c = c.SAP_Fixture_Code__c;
                           if(c.GE_LGT_EM_Deletion_Flag__c=='X') 
                           {
                               acct.GE_LGT_EM_Deletion_Flag__c='TRUE';    // SAP sends X for true                
                           }
                           if(c.GE_LGT_EM_Deletion_Flag__c=='') 
                           {
                               acct.GE_LGT_EM_Deletion_Flag__c='FALSE';    // SAP sends null for false
                           }                
                           updateacc.put(acct.id,acct);
                           
                           system.debug('newduplicate----->'+newduplicate);
                       }
                       //Below if condition added by sai -KAFZY-1969
                       system.debug('Customer Flag and RecordType Before ----->'+c.GE_LGT_EM_CustomerActiveFlag__c+c.Recordtypeid);
                       if(c.Account_Group__c!='ZSTG'){
                           newduplicate.add(c.id);
                       }
                       if(c.Account_Group__c =='ZSTG' && c.GE_LGT_EM_CustomerActiveFlag__c==false){
                       newduplicate.add(c.id);
                       }
                       if(acct.GE_LGT_EM_CustomerActiveFlag__c==true && c.Account_Group__c =='ZSTG' && acct.RecordTypeid==recSASypeID &&c.GE_LGT_EM_CustomerActiveFlag__c==true){
                       newduplicate.add(c.id);
                       }
                   }
            }
        } 
        system.debug('updateacc1 ---->'+updateacc);
        if(updateacc.size()>0)
        {
            system.debug('updateacc2 ---->'+updateacc);
            update updateacc.values();
            system.debug('updateacc3 ---->'+updateacc);         
        }
        if(newduplicate.size()>0)
            system.debug('newduplicate Last1 ---->'+newduplicate);
            GE_LGT_EM_deleteduplicateaccount.Dupdeleteaccount(newduplicate);
            system.debug('newduplicate Last2 ---->'+newduplicate);
    }*/
    
    // This method will organize a list of Accounts into a hierarchy
    // using the SAP Parent Customer Number to lookup the corresponding 
    // AccountId in a map of Salesforce Accounts
    
    public static void ManageCustHierarchies (  Map<Id, Account> newAccMap, Map<Id, Account> oldAccMap){
    
        set<string> cNumSet = new set<string>();
        set<string> accIdSet = new Set<string>();
    
        Map<string, Account> thatAccMap = new Map<string, Account>();
    
        List<Account> AccUpdList = new List<Account>();
    
        Account[] thisAccList = trigger.isDelete ? trigger.old : trigger.new ;
    
        for ( Account acc : thisAccList ){
    
            string accGroup = acc.Account_Group__c!=null?acc.Account_Group__c:'' ;
    
            if ( acc.GE_LGT_EM_SAP_Customer_Number__c != null && ( accGroup.equals('ZSTG') || accGroup.equals('ZSH5') ) ){
    
                if ( trigger.isInsert ){
                    accIdSet.add(acc.id);
                    cNumSet.add(acc.GE_LGT_EM_SAP_Customer_Number__c);
                    cNumSet.add(acc.SAP_Parent_Customer_No__c);
                }
    
                if ( trigger.isUpdate ){
    
                    if ( oldAccMap.get(acc.id).SAP_Parent_Customer_No__c != newAccMap.get(acc.id).SAP_Parent_Customer_No__c ){
                        accIdSet.add(acc.id);
                        cNumSet.add(oldAccMap.get(acc.id).SAP_Parent_Customer_No__c);
                        cNumSet.add(newAccMap.get(acc.id).SAP_Parent_Customer_No__c);
                        cNumSet.add(oldAccMap.get(acc.id).GE_LGT_EM_SAP_Customer_Number__c );
                        cNumSet.add(newAccMap.get(acc.id).GE_LGT_EM_SAP_Customer_Number__c );
                        cNumSet.add(acc.SAP_Parent_Customer_No__c);
                    }
    
                    if ( oldAccMap.get(acc.id).GE_LGT_EM_SAP_Customer_Number__c != newAccMap.get(acc.id).GE_LGT_EM_SAP_Customer_Number__c ){
                        accIdSet.add(acc.id);
                        cNumSet.add(oldAccMap.get(acc.id).GE_LGT_EM_SAP_Customer_Number__c );
                        cNumSet.add(newAccMap.get(acc.id).GE_LGT_EM_SAP_Customer_Number__c );
                        cNumSet.add(oldAccMap.get(acc.id).SAP_Parent_Customer_No__c);
                        cNumSet.add(newAccMap.get(acc.id).SAP_Parent_Customer_No__c);
                        cNumSet.add(acc.SAP_Parent_Customer_No__c);
                    }
    
                    if ( oldAccMap.get(acc.id).Account_Group__c != newAccMap.get(acc.id).Account_Group__c ){
                        accIdSet.add(acc.id);
                        cNumSet.add(acc.GE_LGT_EM_SAP_Customer_Number__c);
                        cNumSet.add(acc.SAP_Parent_Customer_No__c);
                    }
                }
            }
        }
    
        cNumSet.remove(null);
    
        if ( accIdSet.size() > 0 ){
    
          //Account[] thatAccList = [ SELECT Id, ParentId, SAP_Parent_Customer_No__c, GE_LGT_EM_SAP_Customer_Number__c, Account_Group__c FROM Account WHERE Account_Group__c = 'ZSTG' OR Account_Group__c = 'ZSH5' ] ;
              Account[] thatAccList = [ SELECT Id, ParentId, SAP_Parent_Customer_No__c, GE_LGT_EM_SAP_Customer_Number__c, Account_Group__c FROM Account WHERE Account_Group__c in ('ZSTG','ZSH5') AND Account_Group__c != ''] ;
    
            for ( Account acc : thatAccList ){
                thatAccMap.put(acc.GE_LGT_EM_SAP_Customer_Number__c, acc);
            }
    
            for ( Account acc : thatAccList ){
                
                id parId = acc.SAP_Parent_Customer_No__c != null ? ( thatAccMap.get(acc.SAP_Parent_Customer_No__c) != null ? thatAccMap.get(acc.SAP_Parent_Customer_No__c).id : null ) : null ;
                
                if ( parId != acc.ParentId ){
                    acc.ParentId = parId ;
                    AccUpdList.add(acc);
                }
            }
    
            if ( AccUpdList.size() > 0 ){
                update AccUpdList;
            }
        }
    }
    
    public void UpdateIsGlobalParentActiveOnGlobalAccount(List<Account> globalAccList,map<id,Account> allAccOldMAp){
    ID recGAtypeID =Schema.SObjectType.Account.getRecordTypeInfosByName().get('Global Agent Parent').getRecordTypeId();
    ID recSAPFAAgentypeID =Schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP Account - Fixture Agent').getRecordTypeId();
    ID recAgentypeFixAgentID =Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent - Lamp & Ballast').getRecordTypeId();
    set <ID> setidsSAFA = new set <ID>();
    set <ID> setidsGAP = new set <ID>();
    for(Account acc:globalAccList){
        System.debug('trigger.isupdate:'+trigger.isupdate);
        if(trigger.isInsert){
            if(acc.parentid!=null && (acc.Recordtypeid==recSAPFAAgentypeID || acc.Recordtypeid == recAgentypeFixAgentID) && acc.GE_LGT_EM_CustomerActiveFlag__c) {
                    setidsSAFA.add(acc.parentid);
            }
        } 
        if(trigger.isupdate){
            if (acc.Recordtypeid==recSAPFAAgentypeID || acc.Recordtypeid == recAgentypeFixAgentID) {
                if (acc.parentid != allAccOldMAp.get(acc.Id).parentid) {
                    if (acc.parentid != null){
                            setidsSAFA.add(acc.parentid);
                    }
                            setidsSAFA.add(allAccOldMAp.get(acc.Id).parentid);
                }else if(acc.GE_LGT_EM_CustomerActiveFlag__c != allAccOldMAp.get(acc.Id).GE_LGT_EM_CustomerActiveFlag__c) {
                            setidsSAFA.add(acc.parentid);
                    }
            }
        }   
        if(trigger.isdelete){
            if (allAccOldMAp.get(acc.id).Recordtypeid==recSAPFAAgentypeID || allAccOldMAp.get(acc.id).Recordtypeid == recAgentypeFixAgentID) {
                if (allAccOldMAp.get(acc.id).parentid != null && allAccOldMAp.get(acc.id).GE_LGT_EM_CustomerActiveFlag__c) {
                        setidsSAFA.add(allAccOldMAp.get(acc.id).parentid);
                }
            }
        }
        if(trigger.isundelete){
            if (acc.Recordtypeid==recSAPFAAgentypeID || acc.Recordtypeid == recAgentypeFixAgentID) {
                if (acc.parentid != null && acc.GE_LGT_EM_CustomerActiveFlag__c) {
                    setidsSAFA.add(allAccOldMAp.get(acc.id).parentid);
                }
            }
        }
    }
    System.debug('setidsSAFA.size():'+setidsSAFA.size());
    if(setidsSAFA.size()>0){
        list<Account> acclist =new list<Account>();
            for(account a : [select id,IsGlobalParentActive__c,(select id from ChildAccounts where GE_LGT_EM_CustomerActiveFlag__c=:true AND (recordTypeId =:recSAPFAAgentypeID OR recordTypeId =:recAgentypeFixAgentID))from account where id IN:setidsSAFA AND Recordtypeid =:recGAtypeID]){
                    System.debug('ChildAccount1:'+a.ChildAccounts.size());
                    if(a.ChildAccounts.size()>0){
                        a.IsGlobalParentActive__c=true;
                        acclist.add(a);
                    }else {
                        a.IsGlobalParentActive__c=false;
                        acclist.add(a);
                    }
        }
        System.debug('acclist.size():'+acclist.size());
                    if(acclist.size()>0)
                    update acclist;
                    System.debug('UpdateSAccount1:'+acclist);
    }
} 
}