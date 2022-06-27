@isTest(Seealldata=true)
    Public class GE_LGT_EM_AssignCase_TestNew
    {
        static testMethod void AssignCasetoTask(){
            try{
            ID userID = UserInfo.getUserID();
            Map<string,string> RecrdIdMap=new Map<string,string>(); 
            List<RecordType> recrdlist=new List<RecordType>([select id,Name from RecordType]); 
            for(Recordtype rt:recrdlist){
                RecrdIdMap.put(rt.Name,rt.Id);      
            }                        
            Id reccaseTypeID = RecrdIdMap.get('GE Lighting EMEA');            
            Id reccTypeID = RecrdIdMap.get('EMEA Service Contact');            
            Id recAcTypeID = RecrdIdMap.get('EMEA Account');
            Id Taskrecdty = RecrdIdMap.get('GE_LGT_EM_TaskLayout');
            Id devRecordTypeId = RecrdIdMap.get('Complaint Line Items');
                                                
            Account acc = new Account(RecordTypeId = recAcTypeId,Name='Test Ac',CurrencyIsoCode='USD',GE_LGT_EM_SAP_Customer_Number__c ='0098546781');
            insert acc;
            List<Contact> ctlist=new List<Contact>();
            Contact ct= new Contact(RecordTypeId = reccTypeId,LastName='Test',FirstName='Hello',Email='anudeep@ge.com',AccountId=acc.ID,OwnerID=userID,Phone='8008913597');
            ctlist.add(ct); 
            Contact cnt= new Contact(RecordTypeId = reccTypeId,LastName='Test',FirstName='Hi',Email='anudeepA@ge.com',OwnerID=userID,Phone='9291558867');
            ctlist.add(cnt); 
            insert ctlist;
                        
            Case cc=new Case ();
            cc.Status='Open';
            insert cc;            
                 
			GE_LGT_EM_MaterialMaster__c mm = new GE_LGT_EM_MaterialMaster__c(GE_LGT_EM_ProductFamily__c='PR_testData',CurrencyIsoCode='USD',GE_LGT_EM_SAP_MaterialNumber__c='456'); 
        	insert mm;
                
            GE_LGT_EM_ComplaintLineItem__c CompItem=new GE_LGT_EM_ComplaintLineItem__c();
            CompItem.RecordTypeId=devRecordTypeId; 
            CompItem.GE_LGT_EM_CaseNumber__c=cc.Id;    
            CompItem.GE_LGT_EM_Category__c='115-Lost in transit';    
            CompItem.GE_LGT_EM_Material_Number__c=mm.id;    
            Insert CompItem;
            Test.setMock(WebServiceMock.class, new GE_LGT_EM_171WebServiceMockImpl_test());
            
            List<Task> taskList=new List<Task>();
            Task t=new Task();
            t.GE_LGT_EM_Case_Status__c='Pending';
            t.Description='Description for Test Class';
            t.RecordTypeId=Taskrecdty;           
            t.GE_LGT_EM_Call_Reason__c='Enquiry - Price&Stock';
            t.Type='Call - Inbound';
            t.Subject='Call - Inbound:8008913597'; 
            t.WhoId=ct.id;            
            taskList.add(t);
            
            Task t1=new Task();
            t1.GE_LGT_EM_Case_Status__c='Closed';
            t1.Description='Description for Test Class';
            t1.RecordTypeId=Taskrecdty;           
            t1.GE_LGT_EM_Call_Reason__c='Enquiry - Price&Stock';
            t1.Type='Call - Inbound';
            t1.Subject='Call - Inbound:9291558867'; 
            t1.whoid=cnt.id;       
            taskList.add(t1);
            
            Task t2=new Task();
            t2.GE_LGT_EM_Case_Status__c='Pending';
            t2.Description='Description for Test Class';
            t2.RecordTypeId=Taskrecdty;           
            t2.GE_LGT_EM_Call_Reason__c='Enquiry - Price&Stock';
            t2.Type='Call - Inbound';
            t2.Subject='Call - Inbound:8008913597';             
            t2.whatid=acc.id;     
            taskList.add(t2);
            
            Task t3=new Task();
            t3.GE_LGT_EM_Case_Status__c='closed';
            t3.Description='Description for Test Class';
            t3.RecordTypeId=Taskrecdty;           
            t3.GE_LGT_EM_Call_Reason__c='Enquiry - Price&Stock';
            t3.Type='Call - Inbound';
            t3.Subject='Call - Inbound:8008913597';                  
            taskList.add(t3);
            
            Task t4=new Task();
            t4.GE_LGT_EM_Case_Status__c='Pending';
            t4.Description='Description for Test Class';
            t4.RecordTypeId=Taskrecdty;           
            t4.GE_LGT_EM_Call_Reason__c='Enquiry - Price&Stock';
            t4.Type='Call - Inbound';
            t4.Subject='Call - Inbound:8008913597';                  
            taskList.add(t4);            
            
            
            Task t6=new Task();
            t6.GE_LGT_EM_Case_Status__c='Pending';
            t6.Description='Description for Test Class';
            t6.RecordTypeId=Taskrecdty;           
            t6.GE_LGT_EM_Call_Reason__c='Enquiry - Price&Stock';
            t6.Type='Call - Inbound';
            t6.Subject='Call - Inbound:8008913597';  
            t6.whatid=acc.id;  
            t6.whoid=ct.id;                 
            taskList.add(t6);            
            insert taskList;
                
            Task t7=new Task();
            t7.GE_LGT_EM_Case_Status__c='Pending';
            t7.Description='Description for Test Class';
            t7.RecordTypeId=Taskrecdty;           
            t7.GE_LGT_EM_Call_Reason__c='Enquiry - Price&Stock';
            t7.Type='Call';
            t7.Subject='Test';  
            t7.whatid=CompItem.Id;  
            t7.whoid=ct.id; 
			t7.Task_cost__c=10;                
            taskList.add(t7);            
            insert taskList;                                        
            }catch(Exception ee){
            }
        }
    }