public with sharing class GE_NAS_RMAClaimItemEvaluation {
    public GE_NAS_RMA_Lineitem__c lineItem {get;set;}
    private GE_NAS_RMA_Lineitem__c tempItem;
    Public List<GE_NAS_RMA_Item_Evaluation__c> itemeval {get;set;}
    public GE_NAS_RMAClaimItemEvaluation(ApexPages.StandardController controller) {
        tempItem = (GE_NAS_RMA_Lineitem__c) controller.getRecord();
        try {
            lineItem = [SELECT ID,GE_NAS_Item__c,Name,GE_NAS_RMA_Claim__r.Name,GE_NAS_RMA_Claim__r.GE_NAS_RMA_No__c,GE_NAS_CAT_NO__c, GE_NAS_Cost__c, GE_NAS_MfgNo__c, GE_NAS_ProdLine__c, GE_NAS_PRODU__c, GE_NAS_QTY__c, GE_NAS_RMA_Claim__c, GE_NAS_RMA_No__c, GE_NAS_TotalCost__c,GE_NAS_Customer_Letter__c,GE_NAS_Eval_Summary__c,GE_NAS_EvalBy__c from GE_NAS_RMA_Lineitem__c where id=: tempItem.ID];
            refreshLines();
        }
        catch (Exception ex) {}
    }
    public void refreshLines() {
        itemeval = [select ID,Name,GE_NAS_Sample__c,GE_NAS_Date_Code__c,GE_NAS_Date_Received__c,GE_NAS_Date_Evaluated__c,GE_NAS_Eval_Qty__c,GE_NAS_Level1__c,GE_NAS_Level2__c,GE_NAS_Delete__c,GE_NAS_RMA_Lineitem_Number__c from GE_NAS_RMA_Item_Evaluation__c where GE_NAS_RMA_Lineitem_Number__c=: lineItem.ID];    
        
    }
    public void addLine() {
        GE_NAS_RMA_Item_Evaluation__c eval = new GE_NAS_RMA_Item_Evaluation__c();
        eval.GE_NAS_RMA_Lineitem_Number__c = lineItem.ID;
        
        itemeval.add(eval);
    }
    public void deleteLine() {
        List<GE_NAS_RMA_Item_Evaluation__c> delLines = new List<GE_NAS_RMA_Item_Evaluation__c>();
        for(GE_NAS_RMA_Item_Evaluation__c val :itemeval) {
            if (val.GE_NAS_Delete__c && val.ID != null)
                delLines.add(val);
        }
        if(delLines.size()>0)
            delete delLines;
        refreshLines();
    }
    
    public void saveEval() {
        upsert itemeval;
        update lineItem;
    }
}