global class BA_13_connectRelatedAccountRefresh implements Database.Batchable<sobject> {
    global String [] email = new String[] {'salesforcesupport@gecurrent.com'};
    global Database.Querylocator start (Database.BatchableContext BC) 
    {
        return Database.getQueryLocator('Select Id, Name, Portal_User_Type__c, New_Inactive__c, Owner.IsActive FROM Contact WHERE  Portal_User_Type__c = \'Agent\' AND New_Inactive__c = false');
        //return Database.getQueryLocator('Select Id, Name, Portal_User_Type__c, New_Inactive__c, Owner.IsActive FROM Contact WHERE  Portal_User_Type__c = \'Agent\' AND Id = \'0032F00000jC9VvQAK\' ');

        
    }
    global void execute (Database.BatchableContext BC, List<Contact> conList ) 
    {
        Id contactID;
        Contact uCon;
        List<AccountContactRelation> tempList = new List<AccountContactRelation>();
        List<Connect_Direct_Account__c> storeZEAG = new List<Connect_Direct_Account__c>();
        List<Platform_Processing_Log__c> plList = new List<Platform_Processing_Log__c>();
        List<AccountContactRelation> acrList = new List<AccountContactRelation>();
      
        Id tempAccID = [SELECT Name FROM Account WHERE Name = 'GE CURRENT - EXTERNAL' LIMIT 1].Id;
        System.debug('FOUND tempAccount: '+tempAccID);
        Id tempConID = [SELECT Name FROM User WHERE Name = 'SAP Integration' LIMIT 1].Id;
        System.debug('FOUND tempUser: '+tempConID);

        //List<AccountContactRelation> delList = new List<AccountContactRelation>();
        List<Contact> cList = new List<Contact>();
        
        for (Contact con : conList ) 
        {
         
            System.debug('STEP 1 - GETTING CONTACT/ACCOUNT RELATIONSHIPS THAT ARE ZEAG....');
            contactID = con.Id;
             System.debug('Current Contact ID: '+contactID);

            //GETS ALL OF THE RELEATED ACCOUNTS WHERE ACCOUNT GROUP IS ZEAG AND STORES IN THE LIST of 'tempList'
            
            acrList = [SELECT Id, B2B_Agent_flag__c, B2B_flag__c, Account.GE_LGT_Rep_Code__c, AccountId, ContactId, IsDirect FROM AccountContactRelation WHERE ContactId =: con.Id AND Account.Account_Group__c = 'ZEAG'];

            //LIST THAT WILL BE USED TO RE-CREATE ALL THE ACCOUNT CONTACT RELATIONSHIPS FOR ZEAG
            //List<AccountContactRelation> tempList = new List<AccountContactRelation>();
            tempList.addAll(acrList);
            System.debug('ITEMS IN tempList: '+tempList);

            // GETS ALL RELATED ACCOUNTS FOR THE CURRENT (ITERATED) CONTACT AND WILL THEN STORE THE LIST IN THE 'delList'
            //List<AccountContactRelation> allList = new List<AccountContactRelation>();
            //allList = [SELECT Id, B2B_Agent_flag__c, B2B_flag__c, AccountId, ContactId, IsDirect FROM AccountContactRelation WHERE ContactId =: con.Id];

            // LIST CREATED FOR FINAL DELETION - SEE BELOW
            //List<AccountContactRelation> delList = new List<AccountContactRelation>();
            //delList.addAll(allList);
           if(con.Owner.IsActive == false){
               con.OwnerId = tempConID;
           }
            con.AccountId = tempAccID;
            cList.add(con);

             //UPDATE ALL CONTACTS TO GE CURRENT EXTERNAL ACCOUNT - TEMPORAILY AS DIRECT
                                /*System.debug('STEP 2 - UPDATING CONTACTS WITH GE CURRENT EXTERNAL Account AS DIRECT....');
                                //Database.update(cList);

                                try{
                                    Database.update(cList);
                                } catch(DmlException e){
                                    Platform_Processing_Log__c pl = new Platform_Processing_Log__c();
                                    pl.Operation__c = 'Update';
                                    pl.Log_Type__c = 'Batch Processing';
                                    pl.Message__c = 'STEP 2 - UPDATING CONTACTS WITH GE CURRENT EXTERNAL Account AS DIRECT....  ' + e.getMessage();
                                    pl.Object__c = 'Contact';
                                    pl.Contact_ID__c = contactID;
                                    plList.add(pl);*/
                                }
            /*if (plList.size() > 0){
                database.insert(plList);
            }*/

            System.debug('STEP 2 - SENDING ZEAG ACCOUNTS TO BACKUP TABLE - CONNECT DIRECT ACCOUNTS OBJECT....');
            for (AccountContactRelation acrel : acrList){
                Connect_Direct_Account__c connect = new Connect_Direct_Account__c();
                if(acrel.IsDirect == true){
                    connect.Is_Direct__c = true;
                }
                connect.Direct_Account__c = acrel.AccountId;
                connect.Contact__c = acrel.ContactId;
                storeZEAG.add(connect);

                
            }

             //Database.insert(storeZEAG);
        System.debug('LIST OF CONNECT DIRECT ACCOUNT TO CREATE: '+storeZEAG);    
        //try{
            Database.insert(storeZEAG);
        /*} catch(DmlException e){
            Platform_Processing_Log__c pl = new Platform_Processing_Log__c();
            pl.Operation__c = 'Insert';
            pl.Log_Type__c = 'Batch Processing';
            pl.Message__c = 'STEP 2 - SENDING ZEAG ACCOUNTS TO BACKUP TABLE - CONNECT DIRECT ACCOUNTS OBJECT....  ' + e.getMessage();
            pl.Object__c = 'Connect_Direct_Account__c';
            pl.Contact_ID__c = contactID;
            plList.add(pl);
        }*/
        /*if (plList.size() > 0){
            database.insert(plList);
           }*/
        Set<Id> relationshipList = new Set<Id>();
        for (AccountContactRelation relList : [SELECT AccountId FROM AccountContactRelation WHERE ContactId =: contactID ]){
            relationshipList.add(relList.AccountId);
        }
        System.debug('Relationship List : '+relationshipList);

    //--------------------------- NEW CODE BLOCK ------------------------------------------------------
    Set<AccountContactRelation> newAccList = new Set<AccountContactRelation>();
    List<AccountContactRelation> listToUpdate = new List<AccountContactRelation>();
    for(AccountContactRelation acr : acrList){
            
        String repCode = '%'+acr.Account.GE_LGT_Rep_Code__c+'%';
        System.debug('REP CODE: '+repCode);
            
            

            Set<Id> heirarchyList = new Set<Id>();
            for (Account accList : [SELECT Id FROM Account WHERE 
            (ConnectFixtureAgents__c LIKE :repCode OR Connect_Share_with_Account_PartA__c LIKE :repCode OR Connect_Share_with_Account_PartB__c LIKE :repCode OR Connect_Share_with_Account_PartC__c LIKE :repCode)
            AND Account_Group__c = 'Z001' AND GE_LGT_EM_CustomerActiveFlag__c = true AND Id NOT IN :relationshipList]){
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

            //update ACR
            acr.Refreshed_On__c = Datetime.Now();
            listToUpdate.add(acr);
    }
    List<AccountContactRelation> accListToInsert = new List<AccountContactRelation>();
    accListToInsert.addAll(newAccList);
    System.debug('Relations to Insert : '+accListToInsert);
    //insert newAccList;

    System.debug('STEP 3 - ADDING NEWLY ADDED ACCOUNT RELATIONSHIPS');
    //List<Platform_Processing_Log__c> plList = new List<Platform_Processing_Log__c>();
    try{
        Database.insert(accListToInsert);
    } catch(DmlException e){
        Platform_Processing_Log__c pl = new Platform_Processing_Log__c();
        pl.Operation__c = 'Delete';
        pl.Log_Type__c = 'Batch Processing';
        pl.Message__c = 'STEP 3 - ADDING NEWLY ADDED ACCOUNT RELATIONSHIPS... ' + e.getMessage();
        pl.Object__c = 'AccountContactRelation';
        pl.Contact_ID__c = contactID;
        plList.add(pl);
    }

    System.debug('STEP 4 - UPDATING ACR LIST WITH REFRESHED DATE');
    //List<Platform_Processing_Log__c> plList = new List<Platform_Processing_Log__c>();
    //try{
        Database.update(listToUpdate);
    /*} catch(DmlException e){
        Platform_Processing_Log__c pl = new Platform_Processing_Log__c();
        pl.Operation__c = 'Delete';
        pl.Log_Type__c = 'Batch Processing';
        pl.Message__c = 'STEP 4 - UPDATING ACR LIST WITH REFRESHED DATE... ' + e.getMessage();
        pl.Object__c = 'AccountContactRelation';
        pl.Contact_ID__c = contactID;
        plList.add(pl);
    }*/


    System.debug('STEP 5 - INSERTING ANY ERRORS INTO PLATFORM PROCESSING LOG.....');
        if (plList.size() > 0){
            insert plList;
           }
    System.debug('STEP 6 - FINISHED!!!');
    

    //------------------------------------------------------------------------------------------------

    








            //System.debug('LIST TO DELETE: '+delList);
         
        
       
       

/*  REMOVE COMMENT OUT


        List<AccountContactRelation> delList = new List<AccountContactRelation>();
        System.debug('STEP 4 - GETTING ALL CONTACT/ACCOUNT RELATIONSHIPS WHERE IsDIRECT IS FALSE....');
        //for(Contact c : conList){
            
            // GETS ALL RELATED ACCOUNTS FOR THE CURRENT (ITERATED) CONTACT AND WILL THEN STORE THE LIST IN THE 'delList'
            List<AccountContactRelation> allList = new List<AccountContactRelation>();
            allList = [SELECT Id, B2B_Agent_flag__c, B2B_flag__c, AccountId, ContactId, IsDirect FROM AccountContactRelation WHERE ContactId =: contactID AND IsDirect = false];

            delList.addAll(allList);

            System.debug('LIST TO DELETE: '+delList);
        //}


    // DELETES ALL ACCOUNT CONTACT RELATIONSHIPS FOR THE QUERIED CONTACTS
    System.debug('STEP 5 - DELETING ALL CONTACT/ACCOUNT RELATIONSHIPS WHERE IsDIRECT IS FALSE....');
    //List<Platform_Processing_Log__c> plList = new List<Platform_Processing_Log__c>();
    try{
        Database.delete(delList);
    } catch(DmlException e){
        Platform_Processing_Log__c pl = new Platform_Processing_Log__c();
        pl.Operation__c = 'Delete';
        pl.Log_Type__c = 'Batch Processing';
        pl.Message__c = 'STEP 5 - DELETING ALL CONTACT/ACCOUNT RELATIONSHIPS WHERE IsDIRECT IS FALSE....  ' + e.getMessage();
        pl.Object__c = 'AccountContactRelation';
        pl.Contact_ID__c = contactID;
        plList.add(pl);
    }
   /* if (plList.size() > 0){
        database.insert(plList);
       }*/

   /* for(Contact con :conList){
        Map<String, Object> params = new Map<String, Object>();
        params.put('contactID', con.Id);
        Flow.Interview.ACCOUNT_CONTACT_RELATIONSHIPS acrFlow = new Flow.Interview.ACCOUNT_CONTACT_RELATIONSHIPS(params);
        acrFlow.start();

    }*/

/* REMOVE COMMENT OUT


    System.debug('STEP 6 - GET ALL DIRECT ACCOUNT RELATIONSHIPS - FROM CONNECT DIRECT ACCOUNTS OBJECT....');
    //GET ALL DIRECT ACCOUNT RELATIONSHIPS - FROM CONNECT DIRECT ACCOUNTS OBJECT
    List<Connect_Direct_Account__c> cdaList = new List<Connect_Direct_Account__c>();
    List<AccountContactRelation> acrInsertList = new List<AccountContactRelation>();
    cdaList = [SELECT Id, Direct_Account__c, Contact__c, Is_Direct__c, Remapped__c FROM Connect_Direct_Account__c WHERE Contact__c = :contactID AND CreatedDate = TODAY];
    System.debug('CONNECT DIRECT ACCOUNTS: '+cdaList); 
    Map<Id, Id> ContactSet = new Map<Id, Id>();
        Id conID;
        Id accID;
    
        for(Connect_Direct_Account__c cdar : cdaList){
            AccountContactRelation acrnew = new AccountContactRelation();
            acrnew.AccountId = cdar.Direct_Account__c;
            acrnew.ContactId = cdar.Contact__c;
            acrnew.B2B_Agent_flag__c = true;
            acrnew.B2B_flag__c = true;
            acrnew.Refreshed_On__c = Datetime.Now();
            if(cdar.Is_Direct__c == true){
                System.debug('STEP 6.A - DIRECT ACCOUNT FOUND FOR ACCOUNT CONTACT RELATION....');
                conID = cdar.Contact__c;
                //System.debug('Found Direct Account: '+newList.Account.Name);
                System.debug('Setting Contact ID in MAP: '+conID);
                accID = cdar.Direct_Account__c;
                System.debug('Setting Account ID in MAP: '+accID);
                ContactSet.put(conID, accID);
            }
            acrInsertList.add(acrnew);
        }
    
    
    System.debug('STEP 7 - RESTABLISHING ACCONT CONTACT RELATIONSHIPS...');
    try{
        database.insert(acrInsertList);
    } catch(DmlException e){
        Platform_Processing_Log__c pl = new Platform_Processing_Log__c();
        pl.Operation__c = 'Insert';
        pl.Log_Type__c = 'Batch Processing';
        pl.Message__c = 'STEP 7 - RESTABLISHING ACCONT CONTACT RELATIONSHIPS...  ' + e.getMessage();
        pl.Object__c = 'AccountContactRelation';
        pl.Contact_ID__c = contactID;
        plList.add(pl);
    }
    /*if (plList.size() > 0){
        database.insert(plList);
       }*/

/* REMOVE COMMENT OUT

    System.debug('STEP 8 - RE-MAPPING DIRECT ACCOUNT....');
    List<Contact> uContact = new List<Contact>();
    List<Contact> setContact = [SELECT Id FROM Contact WHERE Id IN :ContactSet.keyset()];
    for(Contact cont : setContact){
        cont.AccountId = accID;
        uContact.add(cont);
    }
    try{
        database.update(uContact);
    } catch(DmlException e){
        Platform_Processing_Log__c pl = new Platform_Processing_Log__c();
        pl.Operation__c = 'Delete';
        pl.Log_Type__c = 'Batch Processing';
        pl.Message__c = 'STEP 8 - RE-MAPPING DIRECT ACCOUNT.... ' + e.getMessage();
        pl.Object__c = 'AccountContactRelation';
        pl.Contact_ID__c = contactID;
        plList.add(pl);
    }

    System.debug('STEP 9 - CLEANING UP....');
    List<AccountContactRelation> acr = new List<AccountContactRelation>();
    acr = [SELECT Id, B2B_Agent_flag__c, B2B_flag__c, AccountId, ContactId, IsDirect FROM AccountContactRelation WHERE ContactId =: con.Id AND AccountId =: tempAccID];
    
    try{
        database.delete(acr);
    } catch(DmlException e){
        Platform_Processing_Log__c pl = new Platform_Processing_Log__c();
        pl.Operation__c = 'Delete';
        pl.Log_Type__c = 'Batch Processing';
        pl.Message__c = 'STEP 9 - CLEANING UP.... ' + e.getMessage();
        pl.Object__c = 'AccountContactRelation';
        pl.Contact_ID__c = contactID;
        plList.add(pl);
    }


        }
        System.debug('STEP 10 - INSERTING ANY ERRORS INTO PLATFORM PROCESSING LOG.....');
        if (plList.size() > 0){
            insert plList;
           }
        System.debug('STEP 11 - FINISHED!!!');
    */
    } 
    global void finish(Database.BatchableContext BC)
    {
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        AsyncApexJob a = [Select a.TotalJobItems, a.Status, a.NumberOfErrors, a.JobType, a.JobItemsProcessed, a.ExtendedStatus, a.CreatedById, a.CompletedDate From AsyncApexJob a WHERE id = :BC.getJobId()];
        System.debug('$$$ Jobid is'+BC.getJobId());
        mail.setToAddresses(email);
        mail.setReplyTo('no.reply@gecurrent.com');
        mail.setSenderDisplayName('Connect Related Account Refresh');
        mail.setSubject('Connect Related Account Refresh: '+ a.Status);
        mail.setPlainTextBody('Connect Account Refresh processing has been completed for today. The results are summarized below:' + '<br>' + 'Batches: ' + a.TotalJobItems + '<br>' + 'Errors: ' + a.NumberOfErrors + '<br>' + 'Items Processed: ' + a.JobItemsProcessed);
        Messaging.sendEmail(new Messaging.Singleemailmessage [] {mail});
       
       //BA009_SyncQuoteToOppty syncQuoteToOppty = new BA009_SyncQuoteToOppty();
       //Database.executeBatch(syncQuoteToOppty); 
    }
}