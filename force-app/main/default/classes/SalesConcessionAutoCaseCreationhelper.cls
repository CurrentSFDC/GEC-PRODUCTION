/****************************************************************************************************************************************************************************************************
*   Class Name      : SalesConcessionAutoCaseCreationhelper
*   Date            : 
*   Author          : 
*   Object          : Sales Concession Request
*   Purpose         : This method is to create Case record once Sales Concession Request is created, based on if GE_LGT_Concession_Status__c is 'Approved' OR  GE_LGT_Concession_Status__c is 'Denied'
*   Test Class      : GE_LGT_SalesConcession_Test
*****************************************************************************************************************************************************************************************************/
public class SalesConcessionAutoCaseCreationhelper {

    public static void AutoCaseCreation (list <Sales_Concession_Request__c> newSCRList){
        List<Contact> ContactList = [Select Id From Contact Where LastName = 'Sales Concession'];
        ID recCaseTypeID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('North America').getRecordTypeId();
        List <GROUP> Queuelist = [select id from Group where Type = 'Queue' AND DeveloperName = 'GE_NAS_Support_Team']; //RQT-1730 changed from CS_Support to Support Team Queue: GE_NAS_Support_Team
        List<Case> CaseList = new List<Case>();
        for (Sales_Concession_Request__c scr_obj : newSCRList){
        //  scr_obj.GE_LGT_Concession_Status__c == 'Denied')
            if(scr_obj.GE_LGT_Concession_Status__c == 'Approved' && scr_obj.Region_of_Requestor__c == 'North America' && scr_obj.Concession_Type__c != 'Non Warranty Install Costs'){
                Case cVar = new Case();
                if (!ContactList.isEmpty()) { 
                cVar.ContactId = ContactList[0].Id;
                }
                cVar.Accountid = scr_obj.Account_Name__c;
                cVar.Type = 'Sales Concession';            
                cVar.Origin = 'Sales Concession';            
                cVar.Subject = scr_obj.Name;            
                cVar.Description = 'https://gecurrent.my.salesforce.com/' + scr_obj.Id;  //CHANGED TO gecurrent.my.salesforce.com  FROM gelighting          
                cVar.Status = 'Open';
                if (!Queuelist.isEmpty()) { 
                cVar.OwnerId = Queuelist[0].ID; 
                }           
                cVar.recordtypeid = recCaseTypeID;
                CaseList.add(cVar);
            }
        }
            if(CaseList.size()>0){
                insert CaseList;
            }   
    }       
}