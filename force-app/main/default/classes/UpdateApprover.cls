public with sharing class UpdateApprover {


    public static void ChangeApprover() {
    
    List<Sales_Concession_Request__c> ConcessionList = trigger.new;
    
        Map<string, User> userMap = new Map<string, User>();

        List<User> UserList = [ SELECT Id, Username FROM User ] ;

        for ( User u : UserList ){
            userMap.put(u.Username, u);
        }  
    
    
        Map<string, Sales_Concession_Request__c> scMap = new Map<string, Sales_Concession_Request__c>();
    
        List<Sales_Concession_Request__c> scList = [SELECT Select_Required_Approver__c FROM Sales_Concession_Request__c];
        
        for (Sales_Concession_Request__c sc : scList){
    
        scMap.put(sc.Select_Required_Approver__c, sc);
    
        }
        
    
      /**  for (Sales_Concession_Request__c sc : ConcessionList){
          
          sc.Approver__c = userMap.get(sc.Select__Required_Approver__c).id;
          
          } **/
        
    /** Map<string, Sales_Concession_Request__c> scMap = new Map<string, Sales_Concession_Request__c>
    
    List<Sales_Concession_Request__c> scList = [SELECT Select_Approver__c FROM Sales_Concession_Request__c];
    
    for (Sales_Concession_Request__c sc : scList){
    
    scMap.put(sc.Select_Approver__c, sc);
    
    } **/
    
    /** QUERY APPROVERS AND ADD TO A MAP USING USER NAME AS A PRIMARY KEY **/
    
   Map<String, SelectApprover__c> newApprover = new Map<String, SelectApprover__c>();
    
    List<SelectApprover__c> ApproverList = [SELECT Name, User_Name__c FROM SelectApprover__c];
    
        for (SelectApprover__c sa : ApproverList){
            newApprover.put(sa.Name, sa);
    
        } 
        
    
  /** DO MY STUFF **/
    
   for (Sales_Concession_Request__c sc : ConcessionList) {
    
    string selectedApprover;
    string approverName;
    
        if(scMap.get(sc.Select_Required_Approver__c) != null){
    
            selectedApprover = scMap.get(sc.Select_Required_Approver__c).Select_Required_Approver__c;
    
        }
    
    
        if(newApprover.get(selectedApprover) != null){
        
            approverName = newApprover.get(selectedApprover).User_Name__c;
            
        }
    
    
        if(userMap.get(approverName) != null){
    
            sc.Approver__c = userMap.get(approverName).id;
        }
        
        /** else {
        sc.Approver__c = sc.GE_LGT_Requestor__c;
        } **/
   } 
    
    
    
    
 
    }

}