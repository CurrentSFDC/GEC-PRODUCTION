/***********************************************************************************************
*   Class Name      : AccountSetupTriggerHelper 
*   Date            : 7/7/2017
*   Author          : Satish Babu\Shyam
*   Object          : Distributor__c
*   Purpose         : These methods fire on Distributor__c.
*   Test Class      : AccountSetupTrigger_Test
*   Modified by     : Roja Velpuri / Andras Arva
*   Purpose         : Added a validation for the Approval Step 2 & test class coverage. 
*   Purpose         : Adding new Record types for Europe plus using developer type of records and not Label
*   Modified by     : Roja Velpuri 
*   Purpose         : Re label the Record Types (Distributor- New Core, Solutions and Controls Branch & Distributor- New Core, Solutions and Controls Distributor)
**************************************************************************************************/
public class AccountSetupTriggerHelper 
{
    /*Static Id RecordtypeId2 = [Select Id,DEVELOPERNAME, Name from RecordType where DEVELOPERNAME = 'Change_Change_in_Owner_Legal_Name_Entity' limit 1].Id;
    Static Id RecordtypeId3 = [Select Id,DEVELOPERNAME, Name from RecordType where DEVELOPERNAME = 'Change_Change_in_Terms' limit 1].Id;
    Static Id RecordtypeId6 = [Select Id,DEVELOPERNAME, Name from RecordType where DEVELOPERNAME = 'Change_Reactivation' limit 1].Id;
    Static Id RecordtypeIdDEC = [Select Id,DEVELOPERNAME, Name from RecordType where DEVELOPERNAME = 'Distributor_End_Customer' limit 1].Id;*/
    Static ID RecordtypeId2= [Select Id,DEVELOPERNAME, Name from RecordType where DEVELOPERNAME = 'Change_Change_in_Owner_Legal_Name_Entity' limit 1].Id;
    Static ID RecordtypeId3= [Select Id,DEVELOPERNAME, Name from RecordType where DEVELOPERNAME = 'Change_Change_in_Terms' limit 1].Id;
    Static ID RectypeEUchg= [Select Id,DEVELOPERNAME, Name from RecordType where DEVELOPERNAME = 'Europe_Change_Change_in_Terms' limit 1].Id;
    Static ID RecordtypeId6= [Select Id,DEVELOPERNAME, Name from RecordType where DEVELOPERNAME = 'Change_Reactivation' limit 1].Id;
    Static ID RecordtypeIdDEC= [Select Id,DEVELOPERNAME, Name from RecordType where DEVELOPERNAME = 'Distributor_End_Customer' limit 1].Id;
    Static ID RecordtypeId8= [Select Id,DEVELOPERNAME, Name from RecordType where DEVELOPERNAME = 'Europe_Change_Increase_in_Credit_Amount' limit 1].Id;
    Static ID RecordtypeEUSoldTo= [Select Id,DEVELOPERNAME, Name from RecordType where DEVELOPERNAME = 'Europe_Sold_to_Account_setup' limit 1].Id;
    Static ID RecordtypeEUShipTo= [Select Id,DEVELOPERNAME, Name from RecordType where DEVELOPERNAME = 'Europe_Ship_to_Account' limit 1].Id; //RQT-0001382-RV
    Static ID RecordtypeEUBillTo= [Select Id,DEVELOPERNAME, Name from RecordType where DEVELOPERNAME = 'Europe_Bill_to_Account' limit 1].Id; //RQT-0001386-RV
    Static ID RecordtypeEUPayer= [Select Id,DEVELOPERNAME, Name from RecordType where DEVELOPERNAME = 'Europe_Payer_AccountSetup' limit 1].Id; //RQT-0001401-RV
  /***********************************************************************************************
    *   Method Name  : updateApprovalHistory 
    *   Old Name     : Approval_History_AS_Trigger --Trigger 
    *   Purpose      : This method  will carry insert the each Approval history record into "Approval Steps History Tracking" object, 
    *   Input        : using Trigger.new,trigger.oldMap
    *   Return       : N/A
 **************************************************************************************************/
    public void updateApprovalHistory(List<Distributor__c> newDistList,Map<ID,Distributor__c> oldDistMap)
    {
        Set<id> AccsetupIds=new Set<id>();
        for(Distributor__c act:newDistList)
        {
            AccsetupIds.add(act.id);
        }
        
        //defining the instances for approval process objects
        Map<ID,ProcessInstance> PIlist = new Map<ID,ProcessInstance>([SELECT CompletedDate,CreatedByID,CreatedDate,ElapsedTimeInDays,ElapsedTimeInHours,ElapsedTimeInMinutes,ID,IsDeleted,LastActorID,LastModifiedByID,LastModifiedDate,ProcessDefinitionID,Status,SubmittedByID,SystemModstamp,TargetObjectId 
                                                                      FROM ProcessInstance 
                                                                      WHERE TargetObjectId in:AccsetupIds]);
        List<Approval_Steps_History_Tracking__c> historytackInsert=new List<Approval_Steps_History_Tracking__c>();
        List<Approval_Steps_History_Tracking__c> historytackupdate=new List<Approval_Steps_History_Tracking__c>();
        if(PIlist!=null)
        {
            Map<ID,ProcessInstanceNode> stepInstanceNodes=new Map<ID,ProcessInstanceNode>([SELECT CompletedDate,CreatedByID,CreatedDate,ElapsedTimeInDays,
                                                                                           ElapsedTimeInHours,ElapsedTimeInMinutes,ID,IsDeleted,LastActorID,LastModifiedByID,
                                                                                           LastModifiedDate,NodeStatus,ProcessInstanceID,ProcessNodeID,ProcessInstance.TargetObjectID,ProcessInstance.ProcessDefinition.name,ProcessNodeName FROM ProcessInstanceNode WHERE ProcessInstanceId in:PIlist.keyset()  order by CreatedDate DESC]);
            
            Map<ID,Approval_Steps_History_Tracking__c> apptracking=new Map<ID,Approval_Steps_History_Tracking__c>([select ID,Account_Setup__c,Approval_Step__c,End_Date__c,Approval_Status__c,ProcessInstanceID__c,ProcessInstanceName__c,ProcessInstanceNodeID__c,Start_Date__c,TotalDays__c,TotalHours__c,Total_Minutes__c from Approval_Steps_History_Tracking__c WHERE ProcessInstanceNodeID__c in:stepInstanceNodes.keyset()]);
            Map<ID,Approval_Steps_History_Tracking__c> TrackingNodeids=new Map<ID,Approval_Steps_History_Tracking__c>();
            for(id aapID:apptracking.keyset())
            {
                TrackingNodeIds.put(apptracking.get(aapID).ProcessInstanceNodeID__c,apptracking.get(aapID));
            }
            //Below code will insert Approval Steps History Tracking records when the Accountsetup is submitted for approval.
            for(ID NodeId:stepInstanceNodes.keyset())
            {
                if(!TrackingNodeIds.containsKey(NodeId))
                {
                    Approval_Steps_History_Tracking__c ASHT=new Approval_Steps_History_Tracking__c();
                    ASHT.ProcessInstanceNodeID__c=NodeId;
                    ASHT.Account_Setup__c=stepInstanceNodes.get(NodeId).ProcessInstance.TargetObjectId;
                    ASHT.ProcessInstanceID__c=stepInstanceNodes.get(NodeId).ProcessInstanceId;
                    ASHT.End_Date__c=stepInstanceNodes.get(NodeId).CompletedDate;
                    ASHT.Start_Date__c=stepInstanceNodes.get(NodeId).CreatedDate;
                    ASHT.TotalDays__c=stepInstanceNodes.get(NodeId).ElapsedTimeInDays;
                    ASHT.Approval_Step__c=stepInstanceNodes.get(NodeId).ProcessNodeName;
                    ASHT.TotalHours__c=stepInstanceNodes.get(NodeId).ElapsedTimeInHours;
                    ASHT.Total_Minutes__c=stepInstanceNodes.get(NodeId).ElapsedTimeInMinutes;
                    ASHT.ProcessInstanceName__c=stepInstanceNodes.get(NodeId).ProcessInstance.ProcessDefinition.name;
                    ASHT.Approval_Status__c=stepInstanceNodes.get(NodeId).NodeStatus;
                    ASHT.Account_Setup_RecordType__c=Schema.SObjectType.Distributor__c.getRecordTypeInfosById().get(oldDistMap.get(stepInstanceNodes.get(NodeId).ProcessInstance.TargetObjectId).recordtypeid).getname().trim();
                    historytackInsert.add(ASHT);
                }
                
                else if(TrackingNodeIds.containsKey(NodeId) && stepInstanceNodes.get(NodeId).NodeStatus != TrackingNodeIds.get(NodeId).Approval_Status__c)
                {
                    TrackingNodeIds.get(NodeId).End_Date__c=stepInstanceNodes.get(NodeId).CompletedDate;
                    TrackingNodeIds.get(NodeId).Start_Date__c=stepInstanceNodes.get(NodeId).CreatedDate;
                    TrackingNodeIds.get(NodeId).TotalDays__c=stepInstanceNodes.get(NodeId).ElapsedTimeInDays;
                    TrackingNodeIds.get(NodeId).Total_Minutes__c=stepInstanceNodes.get(NodeId).ElapsedTimeInMinutes;
                    TrackingNodeIds.get(NodeId).TotalHours__c=stepInstanceNodes.get(NodeId).ElapsedTimeInHours;
                    TrackingNodeIds.get(NodeId).Approval_Status__c=stepInstanceNodes.get(NodeId).NodeStatus;
                    historytackupdate.add(TrackingNodeIds.get(NodeId));
                }
            }
            if(historytackInsert!=null)
                insert historytackInsert;
            if(historytackupdate!=null)
                update historytackupdate;
        }
    }
    /***********************************************************************************************
    *   Method Name  : showErrorMessages 
    *   Old Name     : GE_LGT_Distributor_Insert --Trigger 
    *   Purpose      : This method will throw error messages when  Billing information , billing fields , Mailing fields, and  Shipping fields are Null
                        Covers most of the apex error message on Accountsetup .
    *   Input        : using Trigger.new, Method called Before insert or Before Update
    *   Return       : N/A
 **************************************************************************************************/
    
    public void showErrorMessages(List<Distributor__c> newDistList)
    {
        String type;
         String Status = 'Rejected'; // rqt-1445
        Map<ID, Schema.RecordTypeInfo> recordTypeMap;
        String recordType = '';
        recordTypeMap = Schema.SObjectType.Distributor__c.getRecordTypeInfosById();
        for(Distributor__c  distributorVar : newDistList)
        {
            // If Mailing Information Same as Billing? is TRUE
            if(distributorVar.RecordTypeId != RecordtypeId3 || distributorVar.RecordTypeId != RecordtypeId2 || distributorVar.RecordTypeId != RecordtypeId6)
            {
                if(distributorVar.Mail_To_Same_as_Bill_To__c == True)
                {
                    distributorVar.Mailing_Address__c       = distributorVar.Billing_Address__c;
                    distributorVar.Mailing_City__c          = distributorVar.Billing_City__c;
                    distributorVar.Mailing_State__c         = distributorVar.Billing_State__c;
                    distributorVar.Mailing_Postal_Code__c   = distributorVar.Billing_Postal_Code__c;
                    distributorVar.Mailing_Contact_Name__c  = distributorVar.Billing_Contact_Name__c;
                    distributorVar.Mailing_Contact_Phone__c = distributorVar.Billing_Contact_Phone__c;
                    distributorVar.Mailing_Contact_Email__c = distributorVar.Billing_Contact_Email__c;
                    distributorVar.Mailing_Country__c       = distributorVar.Billing_Country__c;
                }
            }
            // If Shipping Information Same as Billing? is TURE
            if(distributorVar.RecordTypeId != RecordtypeId3 && distributorVar.RecordTypeId != RecordtypeId2 && distributorVar.RecordTypeId != RecordtypeId6)
            {    
                if(distributorVar.Shipping_Information_Same_as_Bi__c == True)
                {
                    distributorVar.Shipping_Address__c       = distributorVar.Billing_Address__c;
                    distributorVar.Shipping_City__c          = distributorVar.Billing_City__c;
                    distributorVar.Shipping_State__c         = distributorVar.Billing_State__c;
                    distributorVar.Shipping_Postal_Code__c   = distributorVar.Billing_Postal_Code__c;
                    distributorVar.Shipping_Contact_Name__c  = distributorVar.Billing_Contact_Name__c;
                    distributorVar.Shipping_Contact_Phone__c = distributorVar.Billing_Contact_Phone__c;
                    distributorVar.Shipping_Contact_Email__c = distributorVar.Billing_Contact_Email__c;
                }
            }
            else 
            {
                if(distributorVar.RecordTypeId != RecordtypeId3 && distributorVar.RecordTypeId != RecordtypeId2 && distributorVar.RecordTypeId != RecordtypeId6)
                {    
                    if(distributorVar.Shipping_Address__c == null || distributorVar.Shipping_City__c == null ||  distributorVar.Shipping_State__c == null || distributorVar.Shipping_Postal_Code__c == null || distributorVar.Shipping_Contact_Name__c == null || distributorVar.Shipping_Contact_Phone__c == null || distributorVar.Shipping_Contact_Email__c == null)
                        distributorVar.addError('Following Fields are mandatory - Shipping Address,Shipping City,Shipping State/Province,Shipping Postal Code,Shipping Contact Name,Shipping Contact Phone,Shipping Contact Email');
                }
            }
            
           
                     
 
            //only Before update
            if(trigger.isUpdate)
            { 
                // This part of code makes it mandatory for Risk(Marlene) to fill some fields before approving it.
                Map<ID, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Distributor__c.getRecordTypeInfosById();
                type = rtMap.get(distributorVar.RecordTypeId).getName();
                system.debug('RecordTypeName = '+type);
                if(distributorVar.Status__c=='Risk Approved')
                {
                    //below line will additionally check another field for RecType='Direct Account Setup/Direct Account Branch Setup', Direct Account Setup/Direct Account Branch Setup Approval
                    if(type=='Direct Account Setup/Direct Account Branch Setup' || type=='Direct Account Setup/Direct Account Branch Setup Approval')
                    {
                        
                    }
                    else
                    {
                        //Updated by Aditya Ghadigaonkar 9/12/2016 New Condition for Change in terms for Risk Approval step   
                        if(distributorVar.RecordTypeId == RecordtypeId3)
                        {
                            if((distributorVar.Status__c == 'Pricing/Finance Review') && distributorVar.Sales_Office_Solutions__c == null && distributorVar.Sales_District_Solutions__c == null &&  distributorVar.Sales_Group_Solutions__c == null && distributorVar.Account_Assignment_Group__c == null && distributorVar.KYC_Number__c == null && distributorVar.Credit_ID_Number__c == null && distributorVar.Credit_Limit_Approved_USD__c == null && distributorVar.Credit_Quality_Rating__c == null )
                            {
                                distributorVar.addError('Please fill information under Risk Section to Approve.');   
                            }      
                        }
                    }
                }
                // Below code validates Direct Account Setup/Direct Account Branch Setup records at various Distributor Status
                if(type=='Direct Account Setup/Direct Account Branch Setup' || type=='Direct Account Setup/Direct Account Branch Setup Approval')
                {
                    if(distributorVar.Status__c=='In Set Up – Risk Approved')
                    {
                        if(distributorVar.D_B_Check__c==false || distributorVar.GE_LGT_Sabrix_Setup_Complete__c==false || distributorVar.Customer_Master_Setup_Solutions_Controls__c==false || distributorVar.Account_Solutions_Controls__c=='' )
                        {
                            distributorVar.addError('Following fields are mandatory to be able to approve the record - Risk Screening, Sabrix Setup Complete, Customer Master Setup – Solutions/Controls, Account # Solutions/Controls, ');
                        }
                    }
                    if(distributorVar.Status__c=='Core Approved')
                    {
                        if(distributorVar.Core_Customer_Master_setup__c==false || distributorVar.Account_Core__c ==null || distributorVar.Ship_To_Sent_to_GENPAC__c ==false)
                        {
                            distributorVar.addError('Following fields are mandatory to be able to approve the record - Core Customer Master Setup, Account # Core, & Ship To Sent to GENPAC');
                        }
                    }
                }
            }
            
            //Direct Account Setup/Direct Account Branch Setup validation ends
            
            if(type=='Distributor- New Core Branch' || type=='Distributor- New Core Branch Approvals' || type=='Distributor- New Core Distributor' || type=='Distributor- New Core Distributor Risk Approved' || type=='Distributor- New Core Distributor Approvals' )
            {
                if(distributorVar.Status__c=='In Set Up – Risk Approved')
                {
                    if(distributorVar.D_B_Check__c==false)
                    {
                        distributorVar.addError('Risk Screening is mandatory to be able to approve the record');
                    }
                }
            }
            // KAFZY-200 - July2015
            System.debug('@@@@@@@  ---->'+ type);
            if(type=='Distributor- New Solutions and/or Controls Distributor Approval' || type=='Distributor- New Solutions and/or Controls Distributor' || type=='Distributor- New Solutions and/or Controls Distributor Risk Approved' ||
               type=='Distributor- New Core, Solutions and Controls Distributor' || type=='Distributor- New Core, Solutions and Controls Distributor Approval' || type=='Distributor- New Core, Solutions and Controls Distributor Risk Approved' ||
               type=='Distributor- New Core, Solutions and Controls Branch' || type=='Distributor- New Core, Solutions and Controls Branch Risk Approved' || type=='Distributor- New Core, Solutions and Controls Branch Approvals' ||
               type=='Distributor- New Solutions and/or Controls Branch' || type=='Distributor- New Solutions and/or Controls Branch Risk Approved' || type=='Distributor- New Solutions and/or Controls Branch Approval' )
            {
                if(distributorVar.Status__c=='In Set Up – Risk Approved')
                {
                    if(distributorVar.D_B_Check__c==false || distributorVar.QAD_Account_Number__c=='' || distributorVar.QAD_Account_Controls__c=='' )
                    {
                        distributorVar.addError('Following fields are mandatory to be able to approve the record - Risk Screening; Account # Solutions; Account # Controls;');
                    }
                }
            }                   
            system.debug('distributorVar.Core_Customer_Master_setup__c = '+distributorVar.Core_Customer_Master_setup__c);
            system.debug('Status__c = '+distributorVar.Status__c);
            System.debug('@@@@@@@@@ ---->'+ type);
            if(type=='Distributor- New Core Branch' || type=='Distributor- New Core Branch Approvals' || type=='Distributor- New Core Distributor' || type=='Distributor- New Core Distributor Approvals' || type=='Distributor- New Core, Solutions and Controls Branch' || type=='Distributor- New Core, Solutions and Controls Branch Approvals' || type=='Distributor- New Core, Solutions and Controls Distributor' || type=='Distributor- New Core, Solutions and Controls Distributor Approval')
            {
                if(distributorVar.Status__c=='In Setup')
                {
                    if(distributorVar.Core_Customer_Master_setup__c==false || distributorVar.Account_Core__c==null || distributorVar.EDI_Setup__c==false|| distributorVar.Elitenet_Registration_Sent__c==false)
                    {
                        distributorVar.addError('Following fields are mandatory to be able to approve the record - Core Customer Master Set up, Account # Core, EDI Setup, Elitenet Registration Sent');
                    }
                }
            }
            //Post RiskApproval - mandatory fields - to make fields mandatory before it is submitted for 'Exec Review'
            if(distributorVar.Status__c=='Exec Review')
            {
                if(type=='Distributor- New Core Distributor Risk Approved')
                {
                    if(distributorVar.Core_choose_all_that_apply__c==null || distributorVar.Requested_Terms__c==null || distributorVar.Estimated_Annual_Volume_in_Dollars__c==null || distributorVar.Amount_of_First_Order__c==null || distributorVar.Does_Customer_Have_EDI_Capability__c==null  || distributorVar.Customer_On_Electronic_Funds_Tra__c==null || distributorVar.Is_the_Customer_Tax_Exempt__c==null || distributorVar.Equipped_to_Handle_GE_Product__c==null || distributorVar.Date_of_Visit_by_Account_Manager__c==null || distributorVar.GE_Sales_Representative_Contact_Core__c==null || distributorVar.GE_Sales_Representative_Core__c==null || distributorVar.Region_District_Core__c==null)
                      
                       
                    {
                        distributorVar.addError('Following Fields are mandatory -Core (choose all that apply), Requested Terms, Estimated Annual Volume in Dollars, Amount of First Order, Does Customer Have EDI Capability?, Customer On Electronic Funds Transfer?, Is the Customer Tax Exempt?, Equipped to Handle GE Product, Date of Visit by Account Manager, GE Sales Rep Contact (Core), GE Sales Rep # (Core), Region/District # (Core)');
                    }
                }
                //Exec Review validation for 'Distributor- New Solutions and/or Controls Distributor'
                if(type=='Distributor- New Solutions and/or Controls Distributor Risk Approved' || type=='Distributor- New Solutions and/or Controls Distributor Approval'){
                    if(distributorVar.Sales_Office_Solutions__c==null || distributorVar.Sales_District_Solutions__c==null || distributorVar.Sales_Group_Solutions__c==null || distributorVar.Account_Assignment_Group__c==null  || distributorVar.GE_LGT_Major_Channel__c==null || distributorVar.GE_LGT_Minor_Channel__c==null || distributorVar.GE_LGT_Vertical__c==null)
                      
                    {
                        distributorVar.addError('Following Fields are mandatory - Sales Office Solutions; Sales District Solutions; Sales Group Solutions; Account Assignment Group; Major Channel; Minor Channel; Vertical');
                    }
                }
                // RecType='Distributor- New Core, Solutions and Controls Branch'
                if(type=='Distributor- New Core, Solutions and Controls Branch Risk Approved' || type=='Distributor- New Core, Solutions and Controls Branch Approvals')
                {
                    if(distributorVar.Sales_Office_Solutions__c==null || distributorVar.Sales_District_Solutions__c==null || distributorVar.Sales_Group_Solutions__c==null || distributorVar.Account_Assignment_Group__c==null || distributorVar.GE_LGT_Major_Channel__c==null || distributorVar.GE_LGT_Minor_Channel__c==null || distributorVar.GE_LGT_Vertical__c==null)
                       
                    {
                        distributorVar.addError('Following Fields are mandatory - Sales Office Solutions; Sales District Solutions; Sales Group Solutions; Account Assignment Group; Major Channel; Minor Channel; Vertical');
                    }
                }
                // RecType='Distributor- New Solutions and/or Controls Branch'
                if(type=='Distributor- New Solutions and/or Controls Branch Risk Approved' || type=='Distributor- New Solutions and/or Controls Branch Approval')
                {
                    if(distributorVar.Sales_Office_Solutions__c==null || distributorVar.Sales_District_Solutions__c==null || distributorVar.Sales_Group_Solutions__c==null || distributorVar.Account_Assignment_Group__c==null  || distributorVar.GE_LGT_Major_Channel__c==null || distributorVar.GE_LGT_Minor_Channel__c==null || distributorVar.GE_LGT_Vertical__c==null)
                      
                    {
                        distributorVar.addError('Following Fields are mandatory - Sales Office Solutions; Sales District Solutions; Sales Group Solutions; Account Assignment Group; Major Channel; Minor Channel; Vertical');
                    }
                }
            } 
            //Status=Exec Review-loop closes
            // KAFZY-653 Oct2015
            if(distributorVar.Status__c=='Commercial Finance Review')
            {
                if(type=='Distributor- New Solutions and/or Controls Distributor Risk Approved' || type=='Distributor- New Solutions and/or Controls Distributor Approval')
                {
                    
                    if(distributorVar.Mailing_Address__c ==Null ||distributorVar.Mailing_City__c ==Null ||  distributorVar.Mailing_State__c ==Null || distributorVar.Mailing_Postal_Code__c ==Null || distributorVar.Mailing_Contact_Name__c ==Null || distributorVar.Mailing_Contact_Email__c ==Null || distributorVar.Mailing_Contact_Phone__c ==Null||distributorVar.Shipping_Address__c ==Null || distributorVar.Shipping_City__c ==Null || distributorVar.Shipping_State__c ==Null || distributorVar.Shipping_Postal_Code__c ==Null || distributorVar.Shipping_Contact_Name__c ==Null || distributorVar.Shipping_Contact_Email__c ==Null || distributorVar.Shipping_Contact_Phone__c ==Null||distributorVar.Agent_Name__c==Null ||distributorVar.Agent_Rep_Code__c==Null||distributorVar.Agency_Contacts_for_Customer_Connect__c==null)
                    {
                        distributorVar.addError('Following Fields are mandatory - Mailing Address, Mailing City,Mailing State/Province,Mailing Postal Code,Mailing Contact Name, Mailing Contact Phone,Mailing Contact Email,Shipping Address,Shipping City,Shipping State/Province,Shipping Postal Code, Shipping Contact Name,Shipping Contact Phone,Shipping Contact Email,Agent Name,Agent Rep Code,Agency Contacts for Customer Connect');
                    }
                    
                }
            }
            //If Status is Commercial Finance Review check the validation rules
            if(distributorVar.Status__c=='Commercial Finance Review')
            {
                if(type=='Distributor- New Solutions and/or Controls Branch' || type=='Distributor- New Solutions and/or Controls Branch Risk Approved' || type=='Distributor- New Solutions and/or Controls Branch Approval')
                {
                    if(distributorVar.Agent_Name__c==Null ||distributorVar.GE_Sales_Rep_Solutions__c ==Null||distributorVar.Distributor_HQ_Account__c ==Null||distributorVar.Agency_Contacts_for_Customer_Connect__c ==Null||distributorVar.Solutions_choose_all_that_apply__c==null || distributorVar.Shipping_Contact_Phone__c ==Null||distributorVar.Shipping_Contact_Email__c ==Null || distributorVar.Shipping_Contact_Name__c ==Null ||distributorVar.Shipping_Postal_Code__c ==Null || distributorVar.Shipping_State__c ==Null || distributorVar.Shipping_City__c ==Null || distributorVar.Shipping_Address__c ==Null || distributorVar.Mailing_Contact_Phone__c ==Null|| distributorVar.Mailing_Contact_Email__c ==Null ||  distributorVar.Mailing_Contact_Name__c ==Null ||  distributorVar.Mailing_Postal_Code__c ==Null ||distributorVar.Mailing_State__c ==Null || distributorVar.Mailing_City__c ==Null ||  distributorVar.Mailing_Address__c ==Null ||distributorVar.Branch__c==Null || distributorVar.City__c==Null ||  distributorVar.Agent_Rep_Code__c==Null)
                    {
                        distributorVar.addError('Following Fields are mandatory - Branch #,City,Mailing Address, Mailing City,Mailing State/Province,Mailing Postal Code,Mailing Contact Name, Mailing Contact Phone,Mailing Contact Email, Shipping Address,Shipping City,Shipping State/Province,Shipping Postal Code, Shipping Contact Name,Shipping Contact Phone,Shipping Contact Email,Solutions (choose all that apply),Agency Contacts for Customer Connect, Distributor HQ Account #,GE Sales Rep # (Solutions), Agent Name,Agent Rep Code');
                    }
                }
            }
            //If Status is Commercial Finance Review check the validation rules
            System.debug('@@@@@@@@@ ---->'+ type);
            System.debug('@@@@@@@@@ ---->'+ distributorVar.Status__c);
            if(distributorVar.Status__c=='Commercial Finance Review')
            {
                if(type=='Distributor- New Core, Solutions and Controls Distributor' || type=='Distributor- New Core, Solutions and Controls Distributor Risk Approved' || type=='Distributor- New Core, Solutions and Controls Distributor Approval')
                {
                    if(distributorVar.Agent_Name__c==Null || distributorVar.Agent_Rep_Code__c==Null || distributorVar.Agency_Contacts_for_Customer_Connect__c==Null) 
                    {
                        distributorVar.addError('Following Fields are mandatory - Agent Name,Agent Rep Code,Agency Contacts for Customer Connect ');
                    }
                }
            }
            
            //If Status is Commercial Finance Review check the validation rules
            if(distributorVar.Status__c=='Commercial Finance Review')
            {
                if(type=='Distributor- New Core, Solutions and Controls Branch' || type=='Distributor- New Core, Solutions and Controls Branch Risk Approved' || type=='Distributor- New Core, Solutions and Controls Branch Approvals')
                {
                    if(distributorVar.Branch__c==Null || distributorVar.City__c==Null ||  distributorVar.Mailing_Address__c ==Null ||  distributorVar.Mailing_City__c ==Null || distributorVar.Mailing_State__c ==Null || distributorVar.Mailing_Postal_Code__c ==Null || distributorVar.Mailing_Contact_Name__c ==Null || distributorVar.Mailing_Contact_Email__c ==Null || distributorVar.Mailing_Contact_Phone__c ==Null||distributorVar.Shipping_Address__c ==Null ||distributorVar.Shipping_City__c ==Null || distributorVar.Shipping_State__c ==Null || distributorVar.Shipping_Postal_Code__c == Null || distributorVar.Shipping_Contact_Name__c ==Null || distributorVar.Shipping_Contact_Email__c ==Null || distributorVar.Shipping_Contact_Phone__c ==Null||distributorVar.Core_choose_all_that_apply__c== Null ||distributorVar.Solutions_choose_all_that_apply__c== Null || distributorVar.Agency_Contacts_for_Customer_Connect__c ==Null|| distributorVar.Distributor_HQ_Account__c ==Null||distributorVar.Agent_Name__c==Null ||distributorVar.Agent_Rep_Code__c==Null)
                    {
                        distributorVar.addError('Following Fields are mandatory - Branch #,City,Mailing Address, Mailing City,Mailing State/Province,Mailing Postal Code,Mailing Contact Name, Mailing Contact Phone,Mailing Contact Email,Shipping Address,Shipping City,Shipping State/Province,Shipping Postal Code, Shipping Contact Name,Shipping Contact Phone,Shipping Contact Email,Core (choose all that apply),Solutions (choose all that apply),Agency Contacts for Customer Connect, Distributor HQ Account #, Agent Name,Agent Rep Code');
                    }
                }
            }
                        
        }
    }
    
    
    
    /***********************************************************************************************
    *   Method Name  : showErrorMessages 
    *   Old Name     : GE_LGT_Distributor_Insert --Trigger 
    *   Purpose      : This method will check all the validation rules based on the conditions
                        Covers most of the apex error message on Accountsetup .
    *   Input        : using Trigger.new,  called After and before udpate
    *   Return       : N/A
 **************************************************************************************************/
    
   
    public void showErrorMessagesAfterUpdate(List<Distributor__c> newDistList)
    {
       
        GE_LGT_Distributor_Insert_Handler handler = new GE_LGT_Distributor_Insert_Handler();
        handler.afterUpdateValidation(newDistList);
        for(Distributor__c  distributorVar1 : newDistList)
        {
            //Updated by Aditya Ghadigaonkar 9/12/2016 
            // Below validation is no longer required as the fields are removed from the layout of Change in terms page layout 
            if((distributorVar1.RecordTypeId == RecordtypeId3) || (distributorVar1.RecordTypeId == RectypeEUchg))
            {    
                if((distributorVar1.Status__c == 'Pricing/Finance Review') && distributorVar1.Credit_ID_Number__c == null && distributorVar1.Credit_Limit_Approved_USD__c == null && distributorVar1.Credit_Quality_Rating__c == null )
                {
                    distributorVar1.addError('Please fill information under Risk Review Section to Approve.');   
                }      
            }
            
            
            
            //Updated by Aditya Ghadigaonkar 9/12/2016 
            //Validation for field to be populated by the Risk Team before approval for Change in Owner Legal Name Entity
            if(distributorVar1.RecordTypeId == RecordtypeId2)
            {    
                if((distributorVar1.Status__c == 'Complete') &&/* distributorVar1.Sales_Office_Solutions__c == null && distributorVar1.Sales_District_Solutions__c == null &&  distributorVar1.Sales_Group_Solutions__c == null && distributorVar1.Account_Assignment_Group__c == null &&*/ distributorVar1.KYC_Number__c == null && distributorVar1.Credit_ID_Number__c == null && distributorVar1.Credit_Limit_Approved_USD__c == null && distributorVar1.Credit_Quality_Rating__c == null )
                {
                    distributorVar1.addError('Please fill information under Risk Review Section to Approve.');   
                }  
            }
            //Updated by Aditya Ghadigaonkar 9/12/2016 
            //Validation for field to be populated by the Risk Team before approval for Change – Reactivation
            if(distributorVar1.RecordTypeId == RecordtypeId6)
            {
                if((distributorVar1.Status__c == 'Compliance Review') && distributorVar1.Sales_Office_Solutions__c == null && distributorVar1.Sales_District_Solutions__c == null &&  distributorVar1.Sales_Group_Solutions__c == null && distributorVar1.Account_Assignment_Group__c == null && distributorVar1.KYC_Number__c == null && distributorVar1.Credit_ID_Number__c == null && distributorVar1.Credit_Limit_Approved_USD__c == null && distributorVar1.Credit_Quality_Rating__c == null )
                {
                    distributorVar1.addError('Please fill information under Risk Review Section to Approve.');   
                } 
            }
            
            if(distributorVar1.RecordTypeId == RecordtypeId8 && distributorVar1.Status__c == 'Risk Changes')
            {
                
                if(distributorVar1.Recommended_Credit_Line__c==Null || distributorVar1.Financials_Avaliable__c==Null || distributorVar1.Requires_DOA_Approval__c==Null || distributorVar1.Account_Currency_Recommended_Credit_Line__c==Null )
                {
                    distributorVar1.addError('Please fill in details for Recommended Credit Line, Account Currency, Financials Available and Requires DOA Approvals under the Credit Assesment Section');
                }
            }
            
            if(distributorVar1.RecordTypeId == RecordtypeEUSoldTo && distributorVar1.Status__c == 'Credit Risk Review') // RQT-0001359 EU SOld to Account setup
            {
                
                if(distributorVar1.Account_Solutions_Controls__c==Null)
                {
                    distributorVar1.addError('Please fill in details for SAP Customer # under the Setup Requirements Section');
                }
            }   
             if(distributorVar1.RecordTypeId == RecordtypeEUSoldTo && distributorVar1.Status__c == 'MPCOE/Account Setup') // RQT-0001359 EU SOld to Account setup
            {
                
                if(distributorVar1.GE_LGT_Signed_Agreement_if_Applicable__c==Null || 
                distributorVar1.KYC_Number__c==Null || 
                distributorVar1.Credit_ID_Number__c==Null || 
                distributorVar1.Credit_Limit_Approved__c==Null )
                {
                    distributorVar1.addError('Please fill in details for Signed Agreement if Applicable, KYC Number, Credit ID Number, Credit Limit Approved under the RISK Section');
                }
            }
            
            
            
            // RQT-0001382 EU ShipTo Account setup
            if(distributorVar1.RecordTypeId == RecordtypeEUShipTo && distributorVar1.Status__c == 'In Setup') 
            {
                
                if(distributorVar1.Account_Solutions_Controls__c==Null)
                {
                    distributorVar1.addError('Please fill in details for SAP Customer # under the Setup Requirements Section');
                }
            }
            //RQT-0001386 EU BillTo Account setup
            if(distributorVar1.RecordTypeId == RecordtypeEUBillTo && distributorVar1.Status__c == 'In Setup')  
            {
                
                if(distributorVar1.Account_Solutions_Controls__c==Null)
                {
                    distributorVar1.addError('Please fill in details for SAP Customer # under the Setup Requirements Section');
                }
            }  
            
            
            //if(distributorVar1.RecordTypeId == RecordtypeEUPayer && distributorVar1.Status__c == 'Payer')  
            if(distributorVar1.RecordTypeId == RecordtypeEUPayer && distributorVar1.Status__c == 'MPCOE/Account Setup')  
            {
                
                if(distributorVar1.GE_LGT_Signed_Agreement_if_Applicable__c == Null ||
                  distributorVar1.KYC_Number__c == Null ||
                   distributorVar1.Credit_ID_Number__c == Null ||
                   distributorVar1.Credit_Quality_Rating__c == Null )
                  
                {
                    distributorVar1.addError('Please fill in details for Risk Review Section');
                }
            }  
            
           //if(distributorVar1.RecordTypeId == RecordtypeEUPayer && distributorVar1.Status__c == 'In Setup')  
           if(distributorVar1.RecordTypeId == RecordtypeEUPayer && distributorVar1.Status__c == 'Credit Risk Review')  
            
           {
                
                if(distributorVar1.Account_Solutions_Controls__c == Null)
                {
                    distributorVar1.addError('Please fill in details for SAP Customer # under the Setup Requirements Section');
                }
            }
        }
    }
    
      
    /***********************************************************************************************
    *   Method Name  : autoSubmitToProcess
    *   Purpose      : automatically submit for approval of record type "   LATAM - Temporary Account Activation/Deactivation
    *   Input        : 
    *   Request      : RQT-0000535
    *   Return       : N/A
 **************************************************************************************************/
     
    public void autoSubmitToProcess(List<Distributor__c> newDistList,Map<id,Distributor__c> oldDistMap){
        
        ID RecordtypeId3=Schema.SObjectType.Distributor__c.getRecordTypeInfosByName().get('LATAM - Temporary Account Activation/Deactivation').getRecordTypeId();
            for(Distributor__c dis:newDistList){
                try{
                    if(dis.recordtypeID==RecordtypeId3 && dis.status__c!=oldDistMap.get(dis.id).status__c && dis.status__c=='Rejected'){
                    Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                    req1.setComments('Submitting request for approval.');
                    req1.setObjectId(dis.Id);
                    req1.setSubmitterId(dis.ownerid);
                      // Submit the approval request for the Distributor  
                    Approval.ProcessResult result1 = Approval.process(req1); 
                        }
                }
                catch(exception e){
                    
                }
            
            }
        
        
    }
    
 
}