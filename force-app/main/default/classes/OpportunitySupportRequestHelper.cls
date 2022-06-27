/***********************************************************************************************
*   Class Name      : OpportunitySupportRequestHelper 
*   Date            : 6/23/2017
*   Author          : Satish Babu
*   Object          : OpportunitySupportRequest
*   Purpose         : These methods fire on OpportunitySupportRequest.
*   Test Class      : OpportunitySupportRequestHelperTest
**************************************************************************************************/
public class OpportunitySupportRequestHelper {
Public Static ID recOrderTypeID=Schema.SObjectType.Opportunity_Support_Request__c.getRecordTypeInfosByName().get('Opportunity Management Review').getRecordTypeId();
Public Static ID recTypeDigitalPilotRequestID=Schema.SObjectType.Opportunity_Support_Request__c.getRecordTypeInfosByName().get('Digital Pilot Request').getRecordTypeId();
Public Static ID OSRPricingRequestID=Schema.SObjectType.Opportunity_Support_Request__c.getRecordTypeInfosByName().get('Pricing Request').getRecordTypeId(); 
Public Static ID AwaitingAcknowledgeRecID=Schema.SObjectType.Opportunity_Support_Request__c.getRecordTypeInfosByName().get('Awaiting Acknowledgment').getRecordTypeId(); 
public static Map<String,Super_Admin_Profiles__c> Profiles_Super =Super_Admin_Profiles__c.getAll();
 /***********************************************************************************************
    *   Method Name  : UpdateOSRResourceRevenueExcess 
    *   Old Name     : OSRAfterInsert --Trigger 
    *   Purpose      : This method is to update OSR Resource ,Revenu and Excess amount with the respective Opportunity values.
    *   Input        : using Trigger.new 
    *   Return       : N/A
 **************************************************************************************************/
    public  void UpdateOSRResourceRevenueExcess (List<Opportunity_Support_Request__c> NewOSRList) {
          
        Set<Id> opptyIds = new Set<Id>();
                for(Opportunity_Support_Request__c os : NewOSRList){
                    if(os.Opportunity_Name__c!=null ){
                    opptyIds.add(os.Opportunity_Name__c);
                    }
                }
                Map<Id,Opportunity> oppmap = new Map<Id,Opportunity>([select id, GE_LGT_GE_Opportunity_Id__c,Total_value_of_Opportunity_500K__c,There_is_a_resource_implication__c,There_s_a_Strategic_Value_Future_Revenue__c from Opportunity where Id IN :opptyIds]);
          //the below loop will update the opportunity field values to OSR fields.
                for(Opportunity_Support_Request__c osrl : NewOSRList){
                    if(osrl.Opportunity_Name__c != null ){
                        osrl.GE_Opportunity_No__c = oppmap.get(osrl.Opportunity_Name__c).GE_LGT_GE_Opportunity_Id__c;
                        if(osrl.Opportunity_Name__r.There_is_a_resource_implication__c != ''){
                            osrl.No_Yes_Not_sure__c = oppmap.get(osrl.Opportunity_Name__c).There_is_a_resource_implication__c;
                        }
                        if(osrl.Opportunity_Name__r.There_s_a_Strategic_Value_Future_Revenue__c != ''){
                        osrl.There_s_a_Strategic_Value_Future_Revenue__c = oppmap.get(osrl.Opportunity_Name__c).There_s_a_Strategic_Value_Future_Revenue__c;
                        }
                        if(osrl.Opportunity_Name__r.Total_value_of_Opportunity_500K__c != ''){
                        osrl.Total_value_of_Opporutnity_is_in_excess__c = oppmap.get(osrl.Opportunity_Name__c).Total_value_of_Opportunity_500K__c;
                        }
                      }
                    //Below code is for Field Update on Approver
                     if(osrl.Pricing_Approver__c==null){
                         if(osrl.Status__c=='acknowledged'){
                         osrl.Pricing_Approver__c=UserInfo.getUserId();
                             }
                         }
                    //Below code is for Field Update on Approver
                      if(osrl.Status__c=='responded'){
                        osrl.Pricing_Approver__c = UserInfo.getUserId();
                      }
                }
   }
/***********************************************************************************************
    *   Method Name  : BeforeUpdateOSRResourceRevenueExcess 
    *   Old Name     : OSRAfterInsert --Trigger 
    *   Purpose      : This method is to update Opportunity  Resource ,Revenu and Excess amount with the respective OSR values.
    *   Input        : using Trigger.new ,Trigger.OldMap
    *   Return       : N/A
**************************************************************************************************/
    //before udpate
     public void BeforeUpdateOSRResourceRevenueExcess (List<Opportunity_Support_Request__c> NewOSRList, Map<Id,Opportunity_Support_Request__c> OldOSRMap) {
     
         Set<Id> opptyIds1 = new Set<Id>();
                for(Opportunity_Support_Request__c os1 : NewOSRList){
                    if(os1.Opportunity_Name__c!=null && recOrderTypeID==os1.Recordtypeid){
                    opptyIds1.add(os1.Opportunity_Name__c);
                    }
                }
                Map<Id,Opportunity> oppmap1 = new Map<Id,Opportunity>([select id, Total_value_of_Opportunity_500K__c,There_is_a_resource_implication__c,There_s_a_Strategic_Value_Future_Revenue__c from Opportunity where Id IN :opptyIds1]);
          //the below loop will update the OSR field values to oppportuity field values when OSR has new values.
                for(Opportunity_Support_Request__c osrl : NewOSRList){
                    if (osrl.No_Yes_Not_sure__c != OldOSRMap.get(osrl.id).No_Yes_Not_sure__c ){
                        oppmap1.get(osrl.Opportunity_Name__c).There_is_a_resource_implication__c =osrl.No_Yes_Not_sure__c;
                    }
                    if (osrl.There_s_a_Strategic_Value_Future_Revenue__c != OldOSRMap.get(osrl.id).There_s_a_Strategic_Value_Future_Revenue__c ){
                        oppmap1.get(osrl.Opportunity_Name__c).There_s_a_Strategic_Value_Future_Revenue__c =osrl.There_s_a_Strategic_Value_Future_Revenue__c;
                    }
                    if (osrl.Total_value_of_Opporutnity_is_in_excess__c != OldOSRMap.get(osrl.id).Total_value_of_Opporutnity_is_in_excess__c ){
                        oppmap1.get(osrl.Opportunity_Name__c).Total_value_of_Opportunity_500K__c  =osrl.Total_value_of_Opporutnity_is_in_excess__c;
                    }
                    //Below code is for Field Update on Approver
                     if(osrl.Pricing_Approver__c==null){
                         if(osrl.Status__c=='acknowledged'){
                         osrl.Pricing_Approver__c=UserInfo.getUserId();
                             }
                         }
                }
                update oppmap1.values();
     }
/***********************************************************************************************
    *   Method Name  : sharingOSRrecord 
    *   Old Name     : OSRAfterInsert --Trigger 
    *   Purpose      : This method is used for sharing OSR record with Oppty Owner,Oppty Team members,Approvers(members of queue-based on Pole/Region)
    *   Input        : using Trigger.new 
    *   Return       : N/A
**************************************************************************************************/

  public void sharingOSRrecord(List<Opportunity_Support_Request__c> NewOSRList){
    List<Opportunity_Support_Request__Share> osrShareList= new List<Opportunity_Support_Request__Share>();
       
       List<ID> OppIds = new List<ID>();
       for(Opportunity_Support_Request__c osrVar1 : NewOSRList) {
        oppIds.add(osrVar1.Opportunity_Name__c);
           }
     Map<Id,Opportunity> Opptemmap= new Map<Id,Opportunity>([Select ID,ownerId ,(select UserId from OpportunityTeamMembers) from Opportunity where ID In :oppIds]);
    
      //below loop will create sharring record to OSR with the Opportunity Team members.
      for(Opportunity_Support_Request__c osrVar1 : NewOSRList){
           If(Opptemmap.containsKey(osrVar1.Opportunity_Name__c)){
                Opportunity tempOpp = Opptemmap.get(osrVar1.Opportunity_Name__c);
            
                    //share OSR to Opp ownerId. 
                    osrShareList.add(new Opportunity_Support_Request__Share(UserOrGroupId=tempOpp.OwnerId,
                                                                            ParentId = osrVar1.id,
                                                                            AccessLevel='edit',
                                                                            RowCause = Schema.Opportunity_Support_Request__Share.RowCause.OSRAccess__c));
                    //share OSR to Opp Team members
              for(OpportunityTeamMember otm :tempOpp.OpportunityTeamMembers ){
               // system.debug('Team Members :: '+otm.UserId);
               osrShareList.add(new Opportunity_Support_Request__Share(UserOrGroupId=otm.UserId,
                                                                       ParentId = osrVar1.id,
                                                                       AccessLevel='edit',
                                                                       RowCause = Schema.Opportunity_Support_Request__Share.RowCause.OSRAccess__c));
                }
          
             }
        
        }
       
       Database.SaveResult[] osrShareInsertResult = Database.insert(osrShareList,false);
      
          Set<GE_LGT_EM_ErrorLog__c> errorLogList=new Set<GE_LGT_EM_ErrorLog__c>();
            
            for(Integer i=0;i<osrShareInsertResult.size();i++)
            {
                if (osrShareInsertResult.get(i).isSuccess()) 
                {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully inserted OSR . OSR Share ID: ' + osrShareInsertResult.get(i).getId());
                }
                else
                {
                    // Operation failed, so get all errors                
                    for(Database.Error err : osrShareInsertResult.get(i).getErrors()) 
                    {
                        GE_LGT_EM_ErrorLog__c errorLog=new GE_LGT_EM_ErrorLog__c();
                        errorLog.ID__c=osrShareList.get(i).ID;
                        errorLog.GE_LGT_EM_Object__c='Opportunity_Support_Request__c';
                        errorLog.GE_LGT_EM_IntegrationStatus__c='NA';
                        errorLog.GE_LGT_EM_Description__c=err.getMessage();
                        errorLog.User__c=UserInfo.getUserId();
                        errorLogList.add(errorLog);
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('OpportunitySupportRequest fields that affected this error: ' + err.getFields());
                        
                        
                    }
                }
            }    
    }
    
/***********************************************************************************************
    *   Method Name  : SendEmailOnOSRSubmitted 
    *   Old Name     : OSRAfterInsert --Trigger 
    *   Purpose      : Below code should send email to Oppty team members - when record is submitted for approval
    *   Input        : using Trigger.new .
    *   Return       : N/A
**************************************************************************************************/

Public void SendEmailOnOSRSubmitted(List<Opportunity_Support_Request__c> NewOSRList){
        
            List<ID> OppIds = new List<ID>();
       for(Opportunity_Support_Request__c osrVar1 : NewOSRList) {
        oppIds.add(osrVar1.Opportunity_Name__c);
           }
    Map<Id,Opportunity> OppNewMap= new Map<Id,Opportunity>([Select ID,Name, (select UserId, User.isActive,User.Email from OpportunityTeamMembers where User.isActive = true) from Opportunity where ID in:oppIds]);
     
     if(OppNewMap.size()>0){
        
         //below code will send email alerts to Opportunity Team member when an OSR is submitted.
     for(Opportunity_Support_Request__c osr1:NewOSRList){
              
           if(osr1.Status__c=='Submitted'){
       
           If(OppNewMap.containsKey(osr1.Opportunity_Name__c)){
                Opportunity tempOpp = OppNewMap.get(osr1.Opportunity_Name__c);
                if(tempOpp.OpportunityTeamMembers.size()>0){
             List<String> sendTo = new List<String>();                                  
            for(OpportunityTeamMember OTM : tempOpp.OpportunityTeamMembers){
            sendTo.add(OTM.User.Email);
            }
            String osr_url = URL.getSalesforceBaseUrl().toExternalForm() +'/' + osr1.Id;
                     
            String Oppty_Name = tempOpp.Name;
                system.debug('1. Oppty Name :: '+Oppty_Name);
            String body = '<html lang="ja"><body>'+ 
                              +'An Opportunity Support Request was submitted for an Opportunity where you are a team member. Click here to go to the OSR record - '+'  '+osr_url+
                              '<br><br>'+'Please click FOLLOW on the record to be notified of future updates.'+'</body></html>';
         
                 
         String subject = 'OSR submitted for Opportunity : '+Oppty_Name;
         
         GE_LGT_MailerUtils.sendEmailNotification(string.valueof(subject),string.valueof(body),sendTo);
            }
           }
         
         }
       }
    
      }
      
   }
   /***********************************************************************************************
    *   Method Name  : OSRBeforeDeleteValidation
    *   Old Name     : OSR_Delete--Trigger 
    *   Purpose      : Below code should to validate the OSR deletion.
    *   Input        : using Trigger.Old .
    *   Return       : N/A
**************************************************************************************************/
    Public void OSRBeforeDeleteValidation(List<Opportunity_Support_Request__c> OldOSRList){
        if(!Profiles_Super.containsKey(UserInfo.getProfileId())){
            for(Opportunity_Support_Request__c message : OldOSRList) {
                message.addError('Only Admins/Superusers can delete OSRs');
            }
        }
        
    }
    /***********************************************************************************************
    *   Method Name  : showErrorMessages 
    *   Old Name     :  OpportunitySupportRequestTrigger--Trigger 
    *   Purpose      : This method will throw error messages when  Attachment noy added to Osr Record .
    *   Input        : using Trigger.new, Method called  Before Update
    *   Return       : N/A
 **************************************************************************************************/    
    public void showErrorMessages(List<Opportunity_Support_Request__c> NewOSRList)
    {
        for (Opportunity_Support_Request__c osrVar :NewOSRList){
            if(osrVar.Status__c=='Submitted' && osrVar.Recordtypeid ==recTypeDigitalPilotRequestID && !osrVar.Is_Pilot_Outcome_Map_Added__c){
                osrVar.adderror('Attach a completed Relationship Map and completed Outcome Map before Submit for Approval');
            } 
        }
    }
     
    
    
    /*
    * Author  : Shyam Prasad Nayakula
    * Date    : July - 2017
    * Purpose : This method creates a placeholder Quote whenever an OSR gets submitted for approval
    */
    public static void createQuoteFromOSR(List<Opportunity_Support_Request__c> newOSRList,Map<ID,Opportunity_Support_Request__c> oldOSRMap)
    {
        //Creating list to store quotes that are to be inserted
        List<Quote> quotesToInsert = new List<Quote>();
        //Map to Store Opportunities where GE Opportunity ID as Key
        Map<String,String> OSRMap=new Map<String,String>();
        for(Opportunity_Support_Request__c OSRVar:[SELECT ID,Opportunity_Name__r.PriceBook2Id FROM Opportunity_Support_Request__c  
                                                   WHERE ID IN:newOSRList]) 
        {
            OSRMap.put(OSRVar.ID,OSRVar.Opportunity_Name__r.PriceBook2Id);
        }
        //Looping the new OSR list to find the Submitted requests based on the Status field
        for(Opportunity_Support_Request__c osrVar:newOSRList)
        {
            //There are 2 status values which indicates submission of OSR - Submitted AND OSR Submitted
            if(osrVar.Status__c!=NULL && (osrVar.Status__c=='Submitted' || osrVar.Status__c=='OSR Submitted') 
              && (oldOSRMap.get(osrVar.ID).Status__c!='Submitted' && oldOSRMap.get(osrVar.ID).Status__c!='OSR Submitted'))
            {
                //Creating new Quote Record and assigning the Opportunity details based on OSR
                Quote newQuoteVar = new Quote();
                //Name will be updated using the workflow "Update GE Quote Number" in the format of QT{000000}
                //and this will be updated to SAP Quote Number when the Quote comes from SAP
                newQuoteVar.Name = 'FROM OSR';  
                newQuoteVar.OpportunityId = osrVar.Opportunity_Name__c;
                newQuoteVar.GE_Opportunity_No__c = osrVar.GE_Opportunity_No__c;
                newQuoteVar.GE_Opportunity_Id__c = osrVar.GE_Opportunity_No__c;
                //The below field(Generated_from_OSR__c) will be helpful in identifying the Quote which created from OSR and 
                //also this is being used in workflow "Update GE Quote Number" to map GE Quote Number and Name 
                newQuoteVar.Generated_from_OSR__c = TRUE;
                newQuoteVar.Source_OSR__c = osrVar.Name;
                if(OSRMap.containsKey(osrVar.ID) && OSRMap.get(osrVar.ID)!=NULL)
                    newQuoteVar.Pricebook2Id=OSRMap.get(osrVar.ID);
                //Adding the new Quote record to the list 
                quotesToInsert.add(newQuoteVar);
            }
        }
        System.debug('quotesToInsert::'+quotesToInsert);
        //Inserting the Quote List if it is not empty
        if(!quotesToInsert.isEmpty()){
              try{
                insert quotesToInsert;    
            }
            catch(Exception e){
                Boolean expectedExceptionThrown =  e.getMessage().contains('Once an opportunity is marked PO Received or Closed Lost, all related Quote fields are locked and cannot be edited. You will need to contact your administrator') ? true : false;
                if(expectedExceptionThrown)
                {
                 newOSRList[0].addError('Once an opportunity is marked PO Received or Closed Lost, all related Quote fields are locked and cannot be edited. You will need to contact your administrator');    
                }
               
            }           
            List<GE_LGT_EM_ErrorLog__c> errorLogList=new List<GE_LGT_EM_ErrorLog__c>();
            Database.SaveResult[] srList = Database.insert(quotesToInsert,FALSE);
            for( Database.SaveResult srVar : srList )
            {
                if( !srVar.isSuccess())
                {
                    for( Database.Error err : srVar.getErrors())
                    {
                        GE_LGT_EM_ErrorLog__c errLogVar = HandleErrorLogs.createErrorLog(err.getMessage(),srVar.getId(),'QUOTE','QUOTE INSERT Error',err.getFields());
                        errorLogList.add(errLogVar);
                    }
                }
            }
            if(!errorLogList.isEmpty())
            {
                Database.insert(errorLogList,false);
            }
        }
        //Populate Quote No back on OSR
        Map<String, String> osrQuoteMap = new Map<String, String>();
        List<quote> newQuotes = [select id, name, GE_Quote_Number__c, Source_OSR__c from Quote where id IN:quotesToInsert];
        system.debug('Test -newQuotes '+newQuotes);
        for(Quote eachQuote : newQuotes)
        {
            osrQuoteMap.put(eachQuote.Source_OSR__c, eachQuote.Name);
        }
        if (!osrQuoteMap.isEmpty())
        {
            system.debug('Test -osrQuoteMap '+osrQuoteMap);
            for (Opportunity_Support_Request__c osrVar:newOSRList) 
            {
                if (osrQuoteMap.containsKey(osrVar.Name))
                {
                    OSRVar.GE_Quote_No__c = osrQuoteMap.get(osrVar.Name);
                }
            }
        }
    } 
    /*
    * Author  : Shyam Prasad Nayakula
    * Date    : July - 2017
    * Purpose : This method assigns the Owner of OSR based on the Sales Team of Opportunity
    
    public static void assignOwnerForOSR(List<Opportunity_Support_Request__c> newOSRList,Map<ID,Opportunity_Support_Request__c> oldOSRMap)
    {
        //Set to store the Opportunity IDs from OSR
        Set<ID> opptyNameSet = new Set<ID>();
        for(Opportunity_Support_Request__c var:newOSRList)
        {
            //To handle insert event
            if(oldOSRMap==NULL && var.Opportunity_Name__c!=NULL && (var.Status__c=='Submitted' || var.Status__c=='OSR Submitted'))
            {
                opptyNameSet.add(var.Opportunity_Name__c);
            }
            //To handle upsert event
            if(oldOSRMap!=NULL && (var.Status__c=='Submitted' || var.Status__c=='OSR Submitted'))
            {
                opptyNameSet.add(var.Opportunity_Name__c);
            }
        }
        if(!opptyNameSet.isEmpty())
        {
            //Map to Store SalesTeam of Opportunities Where Opportunity ID as Key
            Map<String,String> oppTeamMap = new Map<String,String>();
            for(Opportunity oppVar:[SELECT ID,Owner.Sales_Team__c FROM Opportunity WHERE ID IN:opptyNameSet])
            {
                if(oppVar.Owner.Sales_Team__c!=NULL)
                {
                    oppTeamMap.put(oppVar.ID,oppVar.Owner.Sales_Team__c);
                }
            }
            if(!oppTeamMap.isEmpty())
            {
           
                //Map to Store Owner ID respective to Sales Team Where Sales Team as Key
                Map<String,String> approvalRouteMap = new Map<String,String>();
                for(Pricing_Team_Approval_Route__c appVar:[SELECT Owner_ID__c,Sales_Team__c,OwnerID 
                                                           FROM Pricing_Team_Approval_Route__c
                                                           WHERE Sales_Team__c IN:oppTeamMap.values()])
                {
                    approvalRouteMap.put(appVar.Sales_Team__c,appVar.OwnerID);
                }
                ID Pricing_RecordType = Schema.SObjectType.Opportunity_Support_Request__c.getRecordTypeInfosByName().get('Pricing Request').getRecordTypeId();
                for(Opportunity_Support_Request__c var:newOSRList)
                {
                    //Assigning the Owner for OSR based on the Sales Team of Opportunity Owner
                    if (var.RecordTypeId == Pricing_RecordType ||var.RecordTypeId == AwaitingAcknowledgeRecID)
                    {
                        if(oppTeamMap.containsKey(var.Opportunity_Name__c) && approvalRouteMap.containsKey(oppTeamMap.get(var.Opportunity_Name__c)))
                        {
                            var.OwnerId = approvalRouteMap.get(oppTeamMap.get(var.Opportunity_Name__c));
                        }
                    }
                        
                }
                
            }
        }
    }*/
    
}