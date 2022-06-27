@isTest(SeeAllData=true)
public class GE_LGT_EM_SubmitforApproval_test{
    private static testMethod void myUnitTest() {
    ID  recAccTypeID=Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User').getRecordTypeId();
    Account acc1=TestDataUtil.createAccount();
    acc1.RecordTypeId = recAccTypeId;
    insert acc1;
    
    Case Caseobj=TestDataUtil.createCase(acc1);
    Caseobj.GE_LGT_EM_Salesorg__c='2GB1';Caseobj.Subject='test sample data';
    insert Caseobj;
    
    ApexPages.currentPage().getParameters().put('id', Caseobj.Id);
    System.currentPageReference().getParameters().put('id',Caseobj.Id);
    
    list<GE_LGT_EM_ComplaintLineItem__c>testlist=new list<GE_LGT_EM_ComplaintLineItem__c>();         
    GE_LGT_EM_ComplaintLineItem__c acc  = new GE_LGT_EM_ComplaintLineItem__c(GE_LGT_EM_Category__c='115-Lost in transit',GE_LGT_EM_Comments__c='sample data',GE_LGT_EM_CaseNumber__c=Caseobj.id,CurrencyIsoCode='USD',GE_LGT_EM_CM_DM_RO_Number__c='500'); 
    insert acc;
    testlist.add(acc);
    system.debug('accsize--->'+acc.id);
    
    Test.setMock(WebServiceMock.class, new GE_LGT_EM_171WebServiceMockImpl_test());
    ApexPages.StandardSetController setCon = new ApexPages.StandardSetController(testlist);  
    wrapperClassController sampletest=new wrapperClassController(setCon);
    sampletest.getContacts();
    sampletest.BackToParent();
    sampletest.getSelected();
    sampletest.processSelected();  
    sampletest.getSelectedCount();    
    GE_LGT_EM_ComplaintLineItem__c cl=new GE_LGT_EM_ComplaintLineItem__c();      
    wrapperClassController.cContact cli=new wrapperClassController.cContact(cl);   
    wrapperClassController.cContact clitest=new wrapperClassController.cContact(cl,'muru'); 
    List<ProcessInstance> processInstances = [select Id,Status from ProcessInstance where TargetObjectId =:acc.id];
    
    test.starttest();
    //Create an approval request for the change
    Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
    req1.setComments('Submitting request for approval.');
    req1.setObjectId(acc.id);
    Approval.ProcessResult result = Approval.process(req1);
    test.stoptest();
    //Verify the result
    System.assert(result.isSuccess());
            
    System.assertEquals('Pending', result.getInstanceStatus(), 'Instance Status'+result.getInstanceStatus());          
               
           
      }     
private static testMethod void myUnitTestselected() {
    ID  recAccTypeID=Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User').getRecordTypeId();
    Account acc1=TestDataUtil.createAccount();
    acc1.RecordTypeId = recAccTypeId;
    insert acc1;
    
    Case Caseobj=TestDataUtil.createCase(acc1);
    Caseobj.GE_LGT_EM_Salesorg__c='2GB1';Caseobj.Subject='test sample data';
    insert Caseobj;
    
    ApexPages.currentPage().getParameters().put('id', Caseobj.Id);
    System.currentPageReference().getParameters().put('id',Caseobj.Id);
    
    list<GE_LGT_EM_ComplaintLineItem__c>testlist=new list<GE_LGT_EM_ComplaintLineItem__c>();         
    GE_LGT_EM_ComplaintLineItem__c acc  = new GE_LGT_EM_ComplaintLineItem__c(GE_LGT_EM_Category__c='115-Lost in transit',GE_LGT_EM_Comments__c='sample data',GE_LGT_EM_CaseNumber__c=Caseobj.id,CurrencyIsoCode='USD',GE_LGT_EM_CM_DM_RO_Number__c='500'); 
    insert acc;
    testlist.add(acc);
    system.debug('accsize--->'+acc.id);
    
    Test.setMock(WebServiceMock.class, new GE_LGT_EM_171WebServiceMockImpl_test());
    ApexPages.StandardSetController setCon = new ApexPages.StandardSetController(testlist);  
    wrapperClassController sampletest=new wrapperClassController(setCon);
    sampletest.getContacts();
    sampletest.BackToParent();
    sampletest.row[0].selected=true;
    sampletest.getSelected();
    sampletest.processSelected();  
    sampletest.getSelectedCount();    
    GE_LGT_EM_ComplaintLineItem__c cl=new GE_LGT_EM_ComplaintLineItem__c();      
    wrapperClassController.cContact cli=new wrapperClassController.cContact(cl);   
    wrapperClassController.cContact clitest=new wrapperClassController.cContact(cl,'muru'); 
    List<ProcessInstance> processInstances = [select Id,Status from ProcessInstance where TargetObjectId =:acc.id];
       
    }   
            
      
}