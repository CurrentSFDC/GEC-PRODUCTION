@isTest(SeeAllData=true)
public class GE_LGT_EM_ApproveReject_test{
    
    private static testMethod void myUnitTest() {
        ID  recAccTypeID=Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User').getRecordTypeId();
        Account acc1=TestDataUtil.createAccount();
        acc1.RecordTypeId = recAccTypeId;
        insert acc1;
        
        Case Caseobj=TestDataUtil.createCase(acc1);
        Caseobj.GE_LGT_EM_Salesorg__c='2GB1';
        insert Caseobj;
        ApexPages.currentPage().getParameters().put('id', Caseobj.Id);
        System.currentPageReference().getParameters().put('id',Caseobj.Id);
        
        list<GE_LGT_EM_ComplaintLineItem__c>testlist=new list<GE_LGT_EM_ComplaintLineItem__c>();         
        GE_LGT_EM_ComplaintLineItem__c acc  = new GE_LGT_EM_ComplaintLineItem__c(GE_LGT_EM_Category__c='115-Lost in transit',GE_LGT_EM_Comments__c='sample data',GE_LGT_EM_CaseNumber__c=Caseobj.id,CurrencyIsoCode='USD',GE_LGT_EM_CM_DM_RO_Number__c='500'); 
        insert acc;
        testlist.add(acc);
        system.debug('accsize--->'+acc.id);
        
        ApexPages.StandardSetController setCon = new ApexPages.StandardSetController(testlist); 
        
        GE_LGT_EM_ApproveReject sampletest=new GE_LGT_EM_ApproveReject(setCon);
        // sampletest.appPendingRecs();
        sampletest.appRej('Reject');
        sampletest.approveAll();
        sampletest.rejectAll();
        sampletest.cancel();
        sampletest.BackToParent();
        // sampletest.getSelected();
        
        GE_LGT_EM_ComplaintLineItem__c cl=new GE_LGT_EM_ComplaintLineItem__c();  
        GE_LGT_EM_ApproveReject.PendingAppRecs cli=new GE_LGT_EM_ApproveReject.PendingAppRecs(cl); 
        List<ProcessInstance> processInstances = [select Id,Status from ProcessInstance where TargetObjectId =:acc.id];
        
        system.debug('size--->'+processInstances.size());
        sampletest.getProsInsts();
        sampletest.selRecs(); 
        //sampletest.getProsInsts()=sampletest.selRecs();
        
        Test.setMock(WebServiceMock.class, new GE_LGT_EM_171WebServiceMockImpl_test()); 
        
        
        // Create an approval request for the complaint
        Approval.ProcessSubmitRequest req1 =new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
         req1.setObjectId(acc.id);
        
        Test.startTest(); 
        
        // Submit the approval request for the complaint
        Approval.ProcessResult result = Approval.process(req1);
        // Test.stoptest(); 
        //    System.assertEquals(processInstances.size(),1);
        
        
        // Verify the result
        System.assert(result.isSuccess());
        
        System.assertEquals('Pending', result.getInstanceStatus(), 
                            'Instance Status'+result.getInstanceStatus());
        
        List<Id> newWorkItemIds = result.getNewWorkitemIds();
        system.debug('newWorkItemIds --->'+newWorkItemIds );
        
        Approval.ProcessWorkitemRequest req2 =new Approval.ProcessWorkitemRequest();
        req2.setComments('Approving request.');
        req2.setAction('Approve');
        req2.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        req2.setWorkitemId(newWorkItemIds[0]);
        
        //  Test.startTest(); 
        Approval.ProcessResult result2 =  Approval.process(req2);
        system.debug('----->result2 '+result2);
        //  Test.stoptest();
        // Verify the results
        System.assert(result2.isSuccess(), 'Result Status:'+result2.isSuccess());
        
       /* System.assertEquals(
            'Approved', result2.getInstanceStatus(), 
            'Instance Status'+result2.getInstanceStatus()); */
        
        
        /*id newWorkItemIds2 =[Select Id FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId = : acc.id].id;
        Approval.ProcessWorkitemRequest req3 =new Approval.ProcessWorkitemRequest();
        req3.setComments('Reject request.');
        req3.setAction('Reject');
        req3.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        req3.setWorkitemId(newWorkItemIds2);
        
        //  Test.startTest(); 
        Approval.ProcessResult result3 =  Approval.process(req3);
        system.debug('----->result2 '+result2);
        Test.stoptest();
        // Verify the results
        System.assert(result3.isSuccess(), 'Result Status:'+result3.isSuccess());
        
        System.assertEquals(
            'Operation Cancelled', result3.getInstanceStatus(), 
            'Instance Status'+result3.getInstanceStatus());*/
    }          
    
    
}