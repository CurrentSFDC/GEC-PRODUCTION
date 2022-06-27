/***********************************************************************************************
*   Class Name      : RMATriggerHelper 
*   Date            : 
*   Author          : 
*   Object          : RMA
*   Purpose         : This method is to create child "RMA Lineitems" once RMA is created, based on the child data supplied to Case
*   Test Class      : RMATriggerHelper_Test
**************************************************************************************************/
public class RMATriggerHelper 
{
    
    public  static void createRMAMultipleChildRecords(){
        
    }
    //This method is to create child "RMA Lineitems" once RMA is created, based on the child data supplied to Case
 /*  public  static void createRMAMultipleChildRecords(List <RMA__c> NewChildList, boolean isUpdate,Map<ID,RMA__c> oldMap){
        Set <ID> caseid = new Set <ID>();
        ID recordTypeCaseElight=Schema.SObjectType.Case.getRecordTypeInfosByName().get('eLight - Return').getRecordTypeId();
        list<GE_NAS_RMA_Lineitem__c> listRMALineItems = new list<GE_NAS_RMA_Lineitem__c>();
            for(RMA__c rVar : NewChildList){
                caseid.add(rVar.Case__c);
            }
            list<Product_Returns_list__c> ProductReturnsList = [Select Case__c,id,Comments__c,Invoiced_Extended_Amount__c,
                                                            Invoiced_Price__c,Invoiced_Qty__c,Invoiced_UM__c,Invoiced_Unit_Price__c,
                                                            Product_Code__c,Return_Extended_Amount__c,Return_Qty__c from Product_Returns_list__c
                                                            where Case__c IN:caseid AND Case__r.Recordtypeid =:recordTypeCaseElight];
                                                            
        Map<Id, list<Product_Returns_list__c>> caseProductMap =  new Map<Id, list<Product_Returns_list__c>>();
        for (Product_Returns_list__c prVar : ProductReturnsList) {
            if (caseProductMap.containsKey(prVar.Case__c)){
                caseProductMap.get(prVar.Case__c).add(prVar);
            }else {
                caseProductMap.put(prVar.Case__c, new List<Product_Returns_list__c>{prVar});
            }
        }
        if(isUpdate){
        list<GE_NAS_RMA_Lineitem__c> deleteRMALineitems =[SELECT Id FROM GE_NAS_RMA_Lineitem__c where GE_NAS_RMA_No__c =: oldMap.keySet()];
        delete deleteRMALineitems;
        }
            for(RMA__c rVar : NewChildList){
                if(caseProductMap.containsKey(rVar.Case__c)){
                    for(Product_Returns_list__c productreturnslistVar : caseProductMap.get(rVar.Case__c)){
                        GE_NAS_RMA_Lineitem__c rmalineitemsVar = new GE_NAS_RMA_Lineitem__c();
                        rmalineitemsVar.GE_NAS_RMA_No__c=rVar.Id;
                        rmalineitemsVar.Product_Code__c=productreturnslistVar.Product_Code__c;
                        rmalineitemsVar.Comments__c=productreturnslistVar.Comments__c;
                        rmalineitemsVar.Invoiced_Extended_Amount__c=productreturnslistVar.Invoiced_Extended_Amount__c;
                        rmalineitemsVar.Invoiced_Price__c=productreturnslistVar.Invoiced_Price__c;
                        rmalineitemsVar.Invoiced_Qty__c=productreturnslistVar.Invoiced_Qty__c;
                        rmalineitemsVar.Invoiced_UM__c=productreturnslistVar.Invoiced_UM__c;
                        rmalineitemsVar.Invoiced_Unit_Price__c=productreturnslistVar.Invoiced_Unit_Price__c;
                        rmalineitemsVar.Return_Extended_Amount__c=productreturnslistVar.Return_Extended_Amount__c;
                        rmalineitemsVar.Return_Qty__c=productreturnslistVar.Return_Qty__c;
                        listRMALineItems.add(rmalineitemsVar);
                    }
                }   
            }
          
        if(listRMALineItems.size()>0){
            insert listRMALineItems;
        }
       
    } */
}