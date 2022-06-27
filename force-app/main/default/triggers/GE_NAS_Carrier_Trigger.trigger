trigger GE_NAS_Carrier_Trigger on GE_NAS_Carrier__c (before insert,before update) {

 Set<String> SetAccNo=new Set<String>();
 List<Account> LstAcc=new List<Account>();
 Map<String,Id> mapAccCar=new Map<String,Id>();

 for(GE_NAS_Carrier__c car:Trigger.New){
    if(car.GE_NAS_Account_Number__c!=null)
    SetAccNo.add(car.GE_NAS_Account_Number__c);
    }

 LstAcc=[SELECT Id,GE_NAS_AccountNo__c FROM Account WHERE  GE_NAS_AccountNo__c IN:SetAccNo];

 for(Account Acc:LstAcc){
    mapAccCar.put(Acc.GE_NAS_AccountNo__c,Acc.Id);
    }

 for(GE_NAS_Carrier__c car:Trigger.New){
    if(car.GE_NAS_Account_Number__c!=null)
    car.GE_NAS_Carriers_Name__c=mapAccCar.get(car.GE_NAS_Account_Number__c);
    }
 }