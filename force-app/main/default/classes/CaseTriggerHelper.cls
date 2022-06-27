/***********************************************************************************************
*   Class Name      : CaseTriggerHelper 
*   Date            : 5/5/2017
*   Author          : Pavan Kumar
*   Object          : Case
*   Purpose         : These methods fire on Case.
*   Test Class      : CaseTrigger_Test
**************************************************************************************************/
public class CaseTriggerHelper {
    
    /***********************************************************************************************
*   Method Name     : prepareShipmentDetails 
*   Old Name        : Elitenet2SFDCAfterInsert
*   Purpose         : This method is to prepare shipmentDetail records based on the data in the field 'GE_NAS_EmailDescription__c'
*                     or creating using parent case corresponding shipmentDetail records
*   Input           : using Trigger.new and trigger.newMap  
*   Return          : N/A
**************************************************************************************************/
    public static Map<String,Super_Admin_Profiles__c> Profiles_Super =Super_Admin_Profiles__c.getAll();
    public static Map<String,LDR_Users__c> LDR_User =LDR_Users__c.getAll();
    
    public static List<Shipment_Detail__c> prepareShipmentDetails(List<Case> newCaseList) {
        List<Shipment_Detail__c> details = new List<Shipment_Detail__c>();
        List<String> pCodeList = new List<String>();
        List<Id> parentIds = new List<Id>();
        Id NE_RECORDTYPE = Schema.SObjectType.Case.getRecordTypeInfosByName().get(CaseConstants.NE_RECORD_TYPE).getRecordTypeId();
        for(case eachCase:newCaseList) {
            if(eachCase.Origin!=null) {
                if((eachCase.Origin==CaseConstants.WEB ||eachCase.Origin==CaseConstants.ELIGHT_ORIGIN) && eachCase.GE_LGT_Business__c==CaseConstants.NE_RECORD_TYPE && eachCase.RecordTypeid==NE_RECORDTYPE && eachCase.parentid==null) {
                    if(eachCase.Subject!=null) {
                        String description= eachCase.GE_NAS_EmailDescription__c;
                        if(eachCase.Subject.Contains(CaseConstants.ELIGHT_RETURNS)) {
/*Syntax of ELIGHT RETURNS Case products in email to case should be like 
* 
*                             
Product Information 
Product Required Price Quantity Comment
000000000093053029 135.0 9 EMITIR NOTA DE CRÉDITO POR 9 LUMINARIAS MODELO LDSC8A080W0T40VQCSWHTE - 93053029
JC10-HS04-AA 136.0 3 test EMITIR NOTA DE CRÉDITO POR 9 LUMINARIAS MODELO LDSC8A080W0T40VQCSWHTE - JC10-HS04-AA
*
*/
                            List<String> values= new List<String>();
                            if(description!=null )
                            {
                                if(description.contains('Product Information')){
                                    String prodsinfo= description.substringBetween('Product Information',CaseConstants.END_OF_Products);
                                    if(prodsinfo!=null )
                                    {
                                    List<String> invidualValues=prodsinfo.split('\n');  
                                        if(invidualValues.size()>0)
                                        {
                                        system.debug('##invidualValues'+invidualValues);
                                        invidualValues.remove(0); // remove product information string from list
                                        invidualValues.remove(0); // remove header section from list
                                        system.debug('Size of List'+invidualValues.size());
                                        for(String iv:invidualValues){
                                            system.debug('test-'+iv);
                                            values=iv.split('    ',4); 
                                                if(values.size()>0 )
                                                {
                                                system.debug('values-size'+values.size());
                                                system.debug('values-'+values);
                                                /* First value in list "Product" : values.get(0)
                                                * First value in list "Required Price" : values.get(1)
                                                * First value in list "Quantity" : values.get(2)
                                                * First value in list "Comment" : values.get(3)                    
                                                */
                                                system.debug('values.get(0)-'+values.get(0));
                                                pCodeList.add(values.get(0));
                                                system.debug('pCodeList1'+pCodeList);
                                                }
                                            }
                                        }
                                    } 
                                } 
                                
                            }                           }
                        if((eachCase.Subject.Contains(CaseConstants.SHIPPING_SUBJECT))||(eachCase.Subject.Contains(CaseConstants.BILLING_ADJUSTMENT))) {
                            integer productsCount=description.countMatches('Product:');
                            if(productsCount!=null) {
                                for(integer index=1;index<=productsCount;index++) {
                                    string tempString;
                                    if(index!=productsCount) {
                                        tempString=description.substringBetween(string.valueof(index)+'.',string.valueof(index+1)+'.');
                                    } else {
                                        tempString=description.substringAfterLast('Product');
                                    }
                                    pCodeList.add(tempString.substringBetween(':','Qty:').trim());
                                }
                            }
                        }
                    }
                }
            }
            if (eachCase.ParentId !=null) {
                parentIds.add(eachCase.ParentId);
            }
        }
        Map<Id, List<Shipment_Detail__c>> childDetails = new Map<Id, List<Shipment_Detail__c>>();
        if (parentIds.size() > 0){
            //replaced 'GE_NAS_Product_Codes__c' by 'Material_Number__c'
            for (Shipment_Detail__c eachDetail : [select GE_NAS_Case_Number__c,GE_NAS_Comments__c,GE_NAS_RAP_Qty__c,GE_NAS_Type_of_Problem1__c,Material_Number__c,GE_NAS_Product_Type__c,GE_NAS_Quantity_Ordered__c,GE_NAS_Reorder1__c,GE_NAS_Unit_of_Measure1__c,GE_NAS_Unit_Price__c,GE_NAS_Wrong_Item_Overage__c from Shipment_Detail__c where GE_NAS_Case_Number__c in :parentIds]) {
                if (childDetails.containsKey(eachDetail.GE_NAS_Case_Number__c)) {
                    childDetails.get(eachDetail.GE_NAS_Case_Number__c).add(eachDetail);
                } else {
                    childDetails.put(eachDetail.GE_NAS_Case_Number__c, new List<Shipment_Detail__c>{eachDetail});
                }
            }
        }
        Map<string, Id > pCodeMap= new Map<string, Id>();
        /* for (GE_NAS_Product_Master__c each : [select Id, Name from GE_NAS_Product_Master__c where Name in :pCodeList]){
pCodeMap.put(each.Name, each.Id);
} */
        //Above code commented as we are no more going to use 'Product Master'. 
        //We are going to use 'Material Master' for the same purpose
        //New block of code written which will pull material numbers from MM object:
        system.debug('pCodeList2'+pCodeList);
        for (GE_LGT_EM_MaterialMaster__c each : [select id, GE_LGT_EM_SAP_MaterialNumber__c FROM GE_LGT_EM_MaterialMaster__c where GE_LGT_EM_SAP_MaterialNumber__c in :pCodeList]){
            system.debug('each'+each);
            pCodeMap.put(each.GE_LGT_EM_SAP_MaterialNumber__c, each.Id);
        }
        system.debug('pCodeMap'+pCodeMap);
        for(case eachCase:newCaseList) {
            string description; 
            integer productCount=0;
            if(eachCase.Origin!=null) {
                if((eachCase.Origin=='Web' ||eachCase.Origin==CaseConstants.ELIGHT_ORIGIN) && eachCase.GE_LGT_Business__c=='North America' && eachCase.RecordTypeid==NE_RECORDTYPE && eachCase.parentid==null) {
                    if(eachCase.Subject!=null) {
                       if(eachCase.GE_NAS_EmailDescription__c!=null){
                        description= eachCase.GE_NAS_EmailDescription__c;
                       if(eachCase.Subject.Contains(CaseConstants.ELIGHT_RETURNS)) {                            
                            List<String> values= new List<String>();
                           if(description!=null ){
                               if(description.contains('Product Information')){                                   
                                      String prodsinfo= description.substringBetween('Product Information',CaseConstants.END_OF_Products);
                                      if(prodsinfo!=null ){
                                  List<String> invidualValues=prodsinfo.split('\n');  
                                  if(invidualValues.size()>0){
                                    system.debug('##invidualValues'+invidualValues);
                                    invidualValues.remove(0); // remove product information string from list
                                    invidualValues.remove(0); // remove header section from list
                                    system.debug('pCodeMap'+pCodeMap);
                                     system.debug('invidualValues size'+invidualValues.size());
                                  for(String iv:invidualValues){
                                      system.debug('test-'+iv);
                                       values=iv.split('    ',4); 
                                       if(Values.size()>0)   {
                                         system.debug('Values2 size'+Values.size());
                                        system.debug('Values2'+Values);                                        
                                        
                                            if(pCodeMap.get(values.get(0))!=null) //if valid productcode not found not creating product
                                            {
                                                Shipment_Detail__c caseProducts = new Shipment_Detail__c();
                                                 caseProducts.GE_NAS_Type_of_Problem1__c='Return';
                                                caseProducts.Material_Number__c= pCodeMap.get(values.get(0));//'a2z3j000001QvzY';
                                                caseProducts.GE_NAS_Case_Number__c= eachCase.id; //'5002h000002nkNP'; 
                                                caseProducts.Invoiced_Price__c= double.valueof(values.get(1));
                                                caseProducts.GE_NAS_RAP_Qty__c=values.get(2);
                                                /*out of 4 values in list.... comments field is not mandatory.
                                                if Values size !=4 then the comments field not received from elight
												To avoid list index out of bound error....used below if condition*/
                                                if(Values.size()==4) { 
                                                    caseProducts.GE_NAS_Comments__c=values.get(3);
                                                }
                                               
                                                details.add(caseProducts);
                                                system.debug('List of Values: ' + values); 
                                            }
                                            
                                        }                                      
                                    }
                                    }
                                }                                   
                                } 
                            }
                        }
                        if(eachCase.Subject.Contains('SHIPPING DISCREPANCY')) {
                            
                            productCount=description.countMatches('Product:');
                            string tempString, rqty;
                            if(productCount!=null) {
                                for(integer i=1;i<=productCount;i++) {
                                    if(i!=productCount) {
                                        tempString=description.substringBetween(string.valueof(i)+'.',string.valueof(i+1)+'.');
                                    } else {
                                        tempString=description.substringAfterLast('Product');
                                    }
                                    string productCode, quantity, reOrder, unitOfMeasure, problemType, frieght;
                                    try {
                                        productCode=tempString.substringBetween(':','Qty:').trim();
                                        quantity=tempString.substringBetween('Qty:','RAP');
                                        rqty=tempString.substringBetween('qty:','UOM');
                                        unitOfMeasure=tempString.substringBetween('UOM:','Type'); 
                                        if(unitOfMeasure.contains('each')) {
                                            unitOfMeasure='Eaches/Bulb';
                                        }
                                        problemType=tempString.substringBetween('Discrepancy:','Reorder');
                                        if(problemType == null) {
                                            problemType = tempString.substringBetween('Discrepancy:','\n');
                                        }
                                        reOrder=tempString.substringBetween('Reorder:','Action');
                                        frieght=tempString.substringBetween('Taken:','\n');
                                        
                                    } catch(Exception ee) {}
                                    //replaced 'GE_NAS_Product_Codes__c' by 'Material_Number__c'
                                    details.add(new Shipment_Detail__c(GE_NAS_Case_Number__c=eachCase.id, GE_NAS_Action_Taken__c=frieght,
                                                                       GE_NAS_Wrong_Item_Overage__c=frieght, Material_Number__c=pCodeMap.get(productCode),
                                                                       GE_NAS_Quantity_Ordered__c=quantity, GE_NAS_RAP_Qty__c= rqty,
                                                                       GE_NAS_Reorder1__c=reOrder, GE_NAS_Type_of_Problem1__c=problemType,
                                                                       GE_NAS_Unit_of_Measure1__c=unitOfMeasure));   
                                }
                            }
                            
                            
                        }
                        
                        
                    }                        
                    }
                }
                if(eachCase.RecordTypeID==NE_RECORDTYPE && eachCase.parentid!=null) {
                    if ( childDetails.size() > 0 ){
                        for(Shipment_Detail__c eachDetail:childDetails.get(eachCase.parentid)) {
                            //replaced 'GE_NAS_Product_Codes__c' by 'Material_Number__c'
                            details.add(new Shipment_Detail__c(GE_NAS_Case_Number__c=eachCase.id, GE_NAS_Comments__c=eachDetail.GE_NAS_Comments__c,
                                                               GE_NAS_RAP_Qty__c=eachDetail.GE_NAS_RAP_Qty__c, GE_NAS_Type_of_Problem1__c=eachDetail.GE_NAS_Type_of_Problem1__c,
                                                               Material_Number__c=eachDetail.Material_Number__c, GE_NAS_Product_Type__c=eachDetail.GE_NAS_Product_Type__c,
                                                               GE_NAS_Quantity_Ordered__c=eachDetail.GE_NAS_Quantity_Ordered__c, GE_NAS_Reorder1__c=eachDetail.GE_NAS_Reorder1__c,
                                                               GE_NAS_Unit_of_Measure1__c=eachDetail.GE_NAS_Unit_of_Measure1__c, GE_NAS_Unit_Price__c=eachDetail.GE_NAS_Unit_Price__c,
                                                               GE_NAS_Wrong_Item_Overage__c=eachDetail.GE_NAS_Wrong_Item_Overage__c));
                        }           
                    }
                }
            }
        }
        return  details;     
    }

    
    
    //EXISTING
    /***********************************************************************************************
*   Method Name     : createShipmentDetails 
*   Old Name        : Elitenet2SFDCAfterInsert
*   Purpose         : This method is to create shipmentDetail records based on the data in the field 'GE_NAS_EmailDescription__c'
*                     or creating using parent case corresponding shipmentDetail records
*   Input           : using Trigger.new and trigger.newMap  
*   Return          : N/A
**************************************************************************************************/
    
    
    public static void  createShipmentDetails(List<Case> newCaseList,Map<Id,Case> newCaseMap) {
        
        List<Shipment_Detail__c> details = new List<Shipment_Detail__c>();       
        details = CaseTriggerHelper.prepareShipmentDetails(newCaseList);  
        if (details != null) {
            try {  
                insert details; 
                System.debug('shipping details' +details);
            } catch (Exception ee) {}
        }        
    }
    
    /***********************************************************************************************
*   Method Name     : beforeUpdate 
*   Purpose         : this method to update account Id, and update owner team
*   Input           : using Trigger.new, trigger.newMap, trigger.old and Trigger.oldMap 
*   Return          : N/A
**************************************************************************************************/
    
    //Email2case before update, 
    public static void beforeUpdate (List<Case> newCaseList,Map<Id,Case> newCaseMap,List<Case> oldCaseList,Map<Id,Case> oldCaseMap) {
        Id Complaint_RecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('EMEA Complaint').getRecordTypeId();
        Id EMEA_RecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('GE Lighting EMEA').getRecordTypeId();
        Id AccountRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP Account').getRecordTypeId();
        Set<id> AccountIdset= new Set<id>();
        List<Id> parentIds = new List<Id>();
        for (case cs:newCaseList) {
            if((cs.RecordTypeID==EMEA_RecordType || cs.RecordTypeID==Complaint_RecordType) && (cs.ParentId !=null)) {
                parentIds.add(cs.ParentId);
            }
        }
        Map<Id, Case> parentCases = new Map<Id,Case>();
        if (parentIds.size()!=0) {
            parentCases = new Map<Id, Case>([Select Id, Accountid from Case Where Id in :ParentIds]);
        }
        for(case eachCase:newCaseList){           
            if(eachCase.RecordTypeID==EMEA_RecordType || eachCase.RecordTypeID==Complaint_RecordType){
                
                if(eachCase.Accountid==null && eachCase.status=='closed'){            
                    eachCase.addError('Account is Mandatory to Close a Case');                
                }   
                
                if(eachCase.Parentid!=null && eachCase.Accountid==null){                    
                    eachCase.Accountid=parentCases.get(eachCase.ParentId).Accountid;
                }
                if(eachCase.Accountid!=null){
                    if(eachCase.Accountid!= oldCaseMap.get(eachCase.Id).Accountid){
                        AccountIdSet.add(eachCase.AccountId);
                    }
                }
            }
        }
        Map<Id,Account> AccountMap=new map<Id, Account>();
        if(AccountIdSet.size()>0){
            AccountMap = new Map<Id, Account>([select id,GE_LGT_EM_Email_Address__c,GE_LGT_EM_Sales_Org__c,GE_LGT_EM_SAP_Customer_Number__c from Account where RecordTypeId = :AccountRecordType and id in:AccountIdSet]);
        }   
        for(case eachCase:newCaseList){    
            if(eachCase.RecordTypeID==EMEA_RecordType || eachCase.RecordTypeID==Complaint_RecordType){      
                if(AccountMap.containskey(eachCase.Accountid)) {
                    eachCase.GE_LGT_EM_Salesorg__c = AccountMap.get(eachCase.Accountid).GE_LGT_EM_Sales_Org__c;
                    eachCase.Custumer_SAP_nr__c= AccountMap.get(eachCase.Accountid).GE_LGT_EM_SAP_Customer_Number__c;
                    eachCase.GE_LGT_EM_Email_Address__c= AccountMap.get(eachCase.Accountid).GE_LGT_EM_Email_Address__c;
                }
            }
        }
        changeOwnerTeam(newCaseList, newCaseMap, oldCaseList, oldCaseMap);
    }
    
    /***********************************************************************************************
*   Method Name     : beforeInsert 
*   Purpose         : To change/add some of the fields usinf account information, suppliedMail
*                     and to update owner ID, owner team
*   Input           : using Trigger.new 
*   Return          : N/A
**************************************************************************************************/
    //Email2case before insert
    public static void beforeInsert(List<Case> newCaseList) {
        Id AccountRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP Account').getRecordTypeId();
        Map<String,Id> AccountMap=new Map<String,Id>();
        Map<String,string> SapNumbrMap=new Map<String,string>();
        Map<String,string> salesorgMap=new Map<String,string>();
        Set<String> Emailids=new set<String>();
        Set<id> AccountIdset= new Set<id>();
        Id EMEA_RecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('GE Lighting EMEA').getRecordTypeId();
        Id Complaint_RecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('EMEA Complaint').getRecordTypeId();
        List<Id> parentIds = new List<Id>();
        for(Case eachCase:newCaseList){  
            if(eachCase.SuppliedEmail!='' && (eachCase.suppliedemail!='Sender.Robofax@ge.com'||eachCase.suppliedemail!='orders@gelightnet.com')){
                Emailids.add(eachCase.suppliedemail);
                parentIds.add(eachCase.parentId);
            }           
        }
        Map<Id, Case> parentCases = new Map<Id, Case>();
        if(parentIds.size() >0) {
            parentCases = new Map<Id, Case>([Select Id, Accountid from Case Where Id in :parentIds]);
        }
        List<Account> Accountlist=new List<Account>();       
        if(Emailids.size()>0){
            Accountlist=[select id,GE_LGT_EM_Email_Address__c,GE_LGT_EM_Sales_Org__c,GE_LGT_EM_SAP_Customer_Number__c from Account where GE_LGT_EM_Email_Address__c in:Emailids and RecordTypeId = :AccountRecordType and GE_LGT_EM_Email_Address__c!=null];                              
            for(Account acc:Accountlist){  
                AccountMap.put(acc.GE_LGT_EM_Email_Address__c,acc.Id);            
                SalesorgMap.put(acc.GE_LGT_EM_Email_Address__c,acc.GE_LGT_EM_Sales_Org__c);        
                SapNumbrMap.put(acc.GE_LGT_EM_Email_Address__c,acc.GE_LGT_EM_SAP_Customer_Number__c);         
            }
        }
        list<string> checkingCode = new List<string>();
        for (Case eachCase:newCaseList) {
            if ((eachCase.RecordTypeID==EMEA_RecordType || eachCase.RecordTypeID==Complaint_RecordType) && (eachCase.SuppliedEmail =='orders@gelightnet.com' && eachCase.subject!=null)) {
                string TempString=eachCase.subject.substringAfter('Order Receipt:');
                string[] checkfields= changeData(TempString);
                checkingCode.add(checkfields[0]+checkfields[1]+checkfields[2]+checkfields[3]);
            }
        }
        List<Account> AccList=[select id,GE_LGT_EM_Email_Address__c,Unique_Data__c,GE_LGT_EM_Sales_Org__c,GE_LGT_EM_SAP_Customer_Number__c from Account where RecordTypeId = :AccountRecordType and Unique_Data__c in :checkingCode];
        Map <String, Account> accountCodeMap =new Map<string, Account>();
        for (Account acc :AccList) {
            accountCodeMap.put(acc.Unique_Data__c, acc);
        }
        for(Case eachCase:newCaseList) {    
            if(eachCase.RecordTypeID==EMEA_RecordType || eachCase.RecordTypeID==Complaint_RecordType) {      
                if(eachCase.Parentid!=null && eachCase.Accountid==null) {                
                    eachCase.Accountid=parentCases.get(eachCase.ParentId).Accountid;
                }                   
                if(eachCase.Accountid==null && eachCase.RecordTypeID==EMEA_RecordType && eachCase.status=='closed'){            
                    eachCase.addError('Account is Mandatory to Close a Case');                
                }               
                if(eachCase.RecordTypeID==EMEA_RecordType){ 
                    if( eachCase.suppliedemail!=null) {
                        if(NAService_OriginQueueMap__c.getInstance(eachCase.origin) !=null){
                            eachCase.OwnerId = NAService_OriginQueueMap__c.getInstance(eachCase.origin).Queue_Id__c;  
                        }
                        
                    }                    
                }
                
                if(eachCase.suppliedemail!=null && (eachCase.suppliedemail!='Sender.Robofax@ge.com'||eachCase.suppliedemail!='orders@gelightnet.com')){                     
                    eachCase.Accountid=AccountMap.get(eachCase.suppliedemail);
                    eachCase.Custumer_SAP_nr__c=SapNumbrMap.get(eachCase.suppliedemail);  
                    eachCase.GE_LGT_EM_Salesorg__c=salesorgMap.get(eachCase.suppliedemail);
                    eachCase.Type='Uncategorized';
                }   
                
                if(eachCase.suppliedemail=='Sender.Robofax@ge.com'){ 
                    if(eachCase.subject!=null){ 
                        if(eachCase.subject.Contains('Received Fax From:')){                  
                            eachCase.Origin='Fax';
                            eachCase.Type='Uncategorized';
                        }   
                    }                   
                }  
                
                if(eachCase.suppliedemail==null && eachCase.Accountid!=null){
                    AccountIdset.add(eachCase.Accountid);
                }
                
                if(eachCase.suppliedemail=='orders@gelightnet.com'){    
                    if(eachCase.subject!=null){                                   
                        string TempString=eachCase.subject.substringAfter('Order Receipt:');                
                        string[] checkfields= changeData(TempString);
                        string checkCode = checkFields[0]+checkFields[1]+checkFields[2]+checkFields[3];
                        if(accountCodeMap.containsKey(checkCode)){
                            eachCase.Accountid=accountCodeMap.get(checkCode).id;
                            eachCase.Custumer_SAP_nr__c=accountCodeMap.get(checkCode).GE_LGT_EM_SAP_Customer_Number__c;  
                            eachCase.GE_LGT_EM_Salesorg__c=accountCodeMap.get(checkCode).GE_LGT_EM_Sales_Org__c;   
                            eachCase.GE_LGT_EM_Email_Address__c=accountCodeMap.get(checkCode).GE_LGT_EM_Email_Address__c; 
                        }
                        eachCase.GE_LGT_EM_SAP_Order_Number__c=checkfields[4];     
                        eachCase.Type='Order';                                             
                        eachCase.description='';
                        eachCase.GE_LGT_EM_Order_Creation_Request_Date__c=Datetime.now();
                    }                                   
                }   
            }
        }
        changeOwnerTeam(newCaseList, null, null, null);
    }
    
    /***********************************************************************************************
*   Method Name     : changeData
*   Purpose         : to get subject data, slipt it up and chage those data into account picklist values
*   Input           : string subject
*   Return          : List of strings
**************************************************************************************************/
    public static List<string> changeData(string subject) {
        string[] checkfields= subject.split(','); 
        checkfields[0]=checkfields[0].trim();  
        checkfields[1]=checkfields[1].trim();
        checkfields[2]=checkfields[2].trim();
        checkfields[3]=checkfields[3].trim();
        if(checkfields[2]=='10')
            checkfields[2]='10-Finished Products';
        else if(checkfields[2]=='20')
            checkfields[2]='20-Components';
        else if(checkfields[2]=='30')
            checkfields[2]='30-Machinery';
        if(checkfields[1]=='10')
            checkfields[1]='10-Consumer';
        else if(checkfields[1]=='20')
            checkfields[1]='20-Professional';
        else if(checkfields[1]=='30')
            checkfields[1]='30-Solutions';
        else if(checkfields[1]=='40')
            checkfields[1]='40-InterCompany';                                
        if(checkfields[3].length()==9)
            checkfields[3]='0'+checkfields[3];
        else if(checkfields[3].length()==8)
            checkfields[3]='00'+checkfields[3];
        else if(checkfields[3].length()==7)
            checkfields[3]='000'+checkfields[3];
        else if(checkfields[3].length()==6)
            checkfields[3]='0000'+checkfields[3];
        else if(checkfields[3].length()==5)
            checkfields[3]='00000'+checkfields[3];
        else if(checkfields[3].length()==4)
            checkfields[3]='000000'+checkfields[3];
        else if(checkfields[3].length()==3)
            checkfields[3]='0000000'+checkfields[3];
        else if(checkfields[3].length()==2)
            checkfields[3]='00000000'+checkfields[3];
        else if(checkfields[3].length()==1)
            checkfields[3]='000000000'+checkfields[3];
        return checkFields;
    }
    
    /***********************************************************************************************
*   Method Name     : changeOwnerTeam
*   Purpose         : to change the owner team using owner type
*                     if owner is QUEUE then assign with QUEUE name
*                     if owner is User then assign with QUEUE namw, in which user is a member
*   Input           : Trigger.new, Trigger.newMap, Trigger.Old, Trigger.oldMap
*   Return          : N/A
**************************************************************************************************/
    public static void changeOwnerTeam(List<Case> newCaseList,Map<Id,Case> newCaseMap,List<Case> oldCaseList,Map<Id,Case> oldCaseMap) {
        Id Complaint_RecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('EMEA Complaint').getRecordTypeId();
        Id EMEA_RecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('GE Lighting EMEA').getRecordTypeId();
        Set<id> ownerIds=new Set<id>();
        for (case c :newCaseList){
            ownerIds.add(c.OwnerId);
        }
        Map<string, GroupMember> ownerMap =  new Map<string, GroupMember>();
        List<GroupMember> groupMemberList =new List<GroupMember>([SELECT GroupId,Id,UserOrGroupId, Group.Type, Group.Name FROM GroupMember where group.type ='QUEUE' and UserOrGroupId in : ownerIds]);
        Map<Id, Group> queueMap = new Map<Id, Group>([SELECT Id, Name, Email, Type from Group where Type='QUEUE' and Id in :ownerIds]);
        for (GroupMember eachMember : groupMemberList) {
            ownerMap.put(eachMember.UserOrGroupId, eachMember);
        }
        for (case eachCase: newCaseList) {
            if(eachCase.RecordTypeID==EMEA_RecordType || eachCase.RecordTypeID==Complaint_RecordType) {
                if (oldCaseMap !=null) {
                    if (eachCase.OwnerId != oldCaseMap.get(eachCase.Id).ownerId) {
                        if (queueMap.containsKey(eachCase.OwnerId)) {
                            eachCase.GE_LGT_EM_Case_Owner_Team__c = queueMap.get(eachCase.OwnerId).Name;
                        }else if (ownerMap.containsKey(eachCase.OwnerId)){
                            eachCase.GE_LGT_EM_Case_Owner_Team__c= ownerMap.get(eachCase.OwnerId).group.Name;
                        }else{
                            eachCase.GE_LGT_EM_Case_Owner_Team__c = '';
                        }
                    }
                }else {
                    if (queueMap.containsKey(eachCase.OwnerId)) {
                        eachCase.GE_LGT_EM_Case_Owner_Team__c = queueMap.get(eachCase.OwnerId).Name;
                    }else if (ownerMap.containsKey(eachCase.OwnerId)){
                        eachCase.GE_LGT_EM_Case_Owner_Team__c= ownerMap.get(eachCase.OwnerId).group.Name;
                    }else {
                        eachCase.GE_LGT_EM_Case_Owner_Team__c = '';
                    }
                }
            }
            //GE_LGT_EM_TeamEmailTrigger
            //to update team email with queue email if the origin is Email
            if(eachCase.ownerid!=NULL && queueMap.containsKey(eachCase.ownerid) && oldCaseMap == null && eachCase.Origin !='Email') {
                String tempString=queueMap.get(eachCase.ownerid).email;
                if(tempString!=NULL && tempString.length()>6)
                {
                    String email=tempString.substring(6);
                    Pattern MyPattern = Pattern.compile(CaseConstants.EMAIL_REG_EXP);
                    Matcher MyMatcher = MyPattern.matcher(email);
                    if(MyMatcher.matches())
                        eachCase.Team_Email__c=email;
                }
            }
        }
    }
    /***********************************************************************************************
*   Method Name     : RepCodeLookup
*   Purpose         : to change the owner Id using Account GE_LGT_Rep_Code__c
*   Input           : Trigger.new
*   Return          : N/A
**************************************************************************************************/
    public static void RepCodeLookup (List<Case> CaseList) {
        set<id> accIdSet = new set<id>();
        for ( Case c : CaseList ){
            accIdSet.add(c.AccountId);
        }
        /*** QUERY AND MAP ACCOUNTS ***/
        Map<string, Account> repCodeMap = new Map<string, Account>( [ SELECT Id, Name, GE_LGT_Rep_Code__c FROM Account WHERE Id in :accIdSet ]); 
        
    }
    /***********************************************************************************************
*   Method Name      : createMultipleChildRecords 
*   Author          : Sai Tandra
*   Purpose         : This method is to create child "Product Returns (list)" once case is created, based on the data supplied to Case fields
*   Input           : Trigger.new
*   Return          : N/A
*   Test Class      : GE_LGT_EM_TeamEmailTrigger_Test
**************************************************************************************************/
    //Below logic is for parsing the case record to create the children records (related list) automatically once the case is created.
  /*  public  static void createMultipleChildRecords(List <Case> NewChildList){
        list<Product_Returns_list__c> listProductReturns = new list<Product_Returns_list__c>();
        ID recordTypeCaseElight=Schema.SObjectType.Case.getRecordTypeInfosByName().get('eLight - Return').getRecordTypeId();
        ID recordTypeCaseElightEMEA=Schema.SObjectType.Case.getRecordTypeInfosByName().get('eLight - EMEA Returns').getRecordTypeId();
        for(case c : NewChildList){
            
            if(c.Product_Code_1__c != null &&(c.RecordTypeId==recordTypeCaseElight||c.RecordTypeId==recordTypeCaseElightEMEA)){
                
                //Store 'Product Code' into a list
                List<String> listProductCode = new List<String>();
                if(c.Product_Code_1__c!=null){
                    listProductCode =c.Product_Code_1__c.split(';');
                }
                // Store 'Invoiced Qty' into a list
                List<String> ListInvoicedQty = new List<String>();
                if(c.eLight_Invoiced_Qty_T__c!=null){
                    ListInvoicedQty =c.eLight_Invoiced_Qty_T__c.split(';');
                }
                // Store 'Comments' into a list
                List<String> listcomments = new List<String>();
                if(c.eLight_Comments__c!=null){
                    listcomments =c.eLight_Comments__c.split(';');
                }
                // Store 'Invoiced Price' into a list
                List<String> ListInvoicedPrice = new List<String>();
                if(c.eLight_Invoiced_Price_T__c!=null){
                    ListInvoicedPrice =c.eLight_Invoiced_Price_T__c.split(';');
                }
                // Store 'Invoiced Unit Price' into a list
                List<String> ListInvoicedUnitPrice = new List<String>();
                if(c.eLight_Invoiced_Price_Unit_T__c!=null){
                    ListInvoicedUnitPrice =c.eLight_Invoiced_Price_Unit_T__c.split(';');
                }
                // Store 'Invoiced UM' into a list
                List<String> ListInvoicedUM = new List<String>();
                if(c.eLight_Invoiced_UM__c!=null){
                    ListInvoicedUM =c.eLight_Invoiced_UM__c.split(';');
                }
                // Store 'Invoiced Extended Amount' into a list
                List<String> ListInvoicedExtendedAmount = new List<String>();
                if(c.eLight_Invoiced_Extended_Amount_T__c!=null){
                    ListInvoicedExtendedAmount =c.eLight_Invoiced_Extended_Amount_T__c.split(';');
                }
                // Store 'Return Qty' into a list
                List<String> Listrq = new List<String>();
                if(c.eLight_Return_Qty_T__c!=null){
                    Listrq =c.eLight_Return_Qty_T__c.split(';');
                }
                // Store 'Return Extended Amount' into a list
                List<String> ListReturnExtendedAmount = new List<String>();
                if(c.eLight_Return_Extended_Amount_T__c!=null){
                    ListReturnExtendedAmount =c.eLight_Return_Extended_Amount_T__c.split(';');
                }
                if(c.Product_Code_1__c.contains(';')){
                    for(integer i=0; i < listProductCode.size(); i++){
                        if(listProductCode[i] != null){
                            Product_Returns_list__c prodVar = new Product_Returns_list__c();
                            prodVar.Case__c=c.id;
                            prodVar.Product_Code__c= listProductCode[i];
                            prodVar.Comments__c=comparestrings(listcomments,i);
                            prodVar.Invoiced_Price__c=comparestrings(ListInvoicedPrice,i)!=null?Decimal.valueof(comparestrings(ListInvoicedPrice,i)):null;
                            prodVar.Invoiced_Unit_Price__c=comparestrings(ListInvoicedUnitPrice,i)!=null?Decimal.valueof(comparestrings(ListInvoicedUnitPrice,i)):null;
                            prodVar.Invoiced_UM__c=comparestrings(ListInvoicedUM,i);
                            prodVar.Invoiced_Qty__c= comparestrings(ListInvoicedQty,i)!=null?Decimal.valueof(comparestrings(ListInvoicedQty,i)):null;
                            prodVar.Invoiced_Extended_Amount__c=comparestrings(ListInvoicedExtendedAmount,i)!=null?Decimal.valueof(comparestrings(ListInvoicedExtendedAmount,i)):null;
                            prodVar.Return_Qty__c=comparestrings(Listrq,i)!=null?Decimal.valueof(comparestrings(Listrq,i)):null;
                            prodVar.Return_Extended_Amount__c=comparestrings(ListReturnExtendedAmount,i)!=null?Decimal.valueof(comparestrings(ListReturnExtendedAmount,i)):null;
                            listProductReturns.add(prodVar);
                        }
                    }
                }
                else {
                    Product_Returns_list__c prodVar = new Product_Returns_list__c();
                    prodVar.Case__c=c.id;
                    prodVar.Product_Code__c=c.Product_Code_1__c;
                    prodVar.Comments__c=c.eLight_Comments__c;
                    prodVar.Invoiced_Price__c=Decimal.valueof(c.eLight_Invoiced_Price_T__c);
                    prodVar.Invoiced_Unit_Price__c=Decimal.valueof(c.eLight_Invoiced_Price_Unit_T__c);
                    prodVar.Invoiced_UM__c=c.eLight_Invoiced_UM__c;
                    prodVar.Invoiced_Qty__c= Decimal.valueof(c.eLight_Invoiced_Qty_T__c);
                    prodVar.Invoiced_Extended_Amount__c=Decimal.valueof(c.eLight_Invoiced_Extended_Amount_T__c);
                    prodVar.Return_Qty__c=Decimal.valueof(c.eLight_Return_Qty_T__c);
                    prodVar.Return_Extended_Amount__c=Decimal.valueof(c.eLight_Return_Extended_Amount_T__c);
                    listProductReturns.add(prodVar);
                    
                }
                
                
                
            }
        }      
        if(listProductReturns.size()>0){
            insert listProductReturns;
        }
    } */
    public static String comparestrings(List<String> comList,integer index){
        if(comList.size()>=index+1){
            return comList[index];
        }
        else {
            return null;
        }
    }
    
    /***********************************************************************************************
*   Method Name  : CaseBeforeDeleteValidation
*   Purpose      : Below code should to validate the Casedeletion.
*   Input        : using Trigger.Old .
*   Return       : N/A
**************************************************************************************************/
    Public void CaseBeforeDeleteValidation(List<Case> oldCaseList){
        system.debug('####Before delete event in Method#####');          
        for(case message : oldCaseList) {
            if(!Profiles_Super.containsKey(UserInfo.getProfileId()) && !LDR_User.containsKey(UserInfo.getUserId()) )
            {
                System.debug('only admins'+!Profiles_Super.containsKey(UserInfo.getProfileId()));
                message.addError('Only Admins/Super/LDR users can delete Cases');  
            }
            
        }
        
        
    }
}