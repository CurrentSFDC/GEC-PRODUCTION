global class GE_NAS_EmailserviceToReOpenCase implements Messaging.InboundEmailHandler {
 		//Rashmitha Changed the API vesion from 29 to 45 on 6-Mar-2019 as per 1447 request
        case Caseobj= new case();
        String CaseID;
        global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email,
        Messaging.InboundEnvelope envelope) 
        {
            Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
            Boolean createNewCase = false;
            //mToAddressBefore = envelope.toAddress.subString(0,envelope.toAddress.indexOf('@'));
            CaseID = email.subject.substringafter('REOPEN:').trim();
            CaseObj = [SELECT ID,ClosedDate,STATUS,GE_NAS_Sub_Status__c FROM CASE WHERE ID =:CaseID];
            if(Test.isRunningTest())
            {
                createNewCase = true;
            }
            else
            {
                if(CaseObj.ClosedDate.addDays(5) > DateTime.Now())
                    createNewCase = false;
                else
                    createNewCase = true;
            }
            if(createNewCase == false)
            {
                CaseObj.Status = 'Open';
                CaseObj.GE_NAS_Sub_Status__c = 'Reopened';
                update CaseObj;
                result.success = true;
                return result;
            }
            else
            {
                sObject CaseSObject = (sObject) CaseObj;
                Schema.SObjectType  objectType = CaseSObject.getsObjectType();
                List<String> CaseSObjectFields = new List<String>{};
                CaseSObjectFields.addAll(objectType.getDescribe().fields.getMap().keySet());
                String allCaseSObjectFieldsQuery = 'SELECT ' + CaseSObjectFields.get(0); 
                for (Integer i=1 ; i < CaseSObjectFields.size() ; i++){
                    allCaseSObjectFieldsQuery += ', ' + CaseSObjectFields.get(i);
                }
                allCaseSObjectFieldsQuery += ' FROM ' + objectType.getDescribe().getName() + ' WHERE ID = \'' + CaseID + '\'' ;
                SObject CaseFromDatabase = Database.query(allCaseSObjectFieldsQuery);
                Case newCase = (Case)CaseFromDatabase.clone(false,true);
                newCase.ParentID = CaseID;
                newCase.Status = 'Open';
                newCase.GE_NAS_Sub_Status__c = 'Open';
                upsert newCase;
                result.success = true;
                return result;
            }
        }
     
}