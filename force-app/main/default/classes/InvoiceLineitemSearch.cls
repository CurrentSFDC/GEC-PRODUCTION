public class InvoiceLineitemSearch {
    public string delopptyid{get; set;}
    public List<GE_LGT_EM_InvoiceLineItem__c> InvoiceSearchList {set; get;}
    public List<GE_LGT_EM_InvoiceLineItem__c> InvoicelineListAddlines {set; get;}    
    public integer inte{get; set;}
    public integer integ{get; set;}
    public string searchStr {get;set;}
    public RMA__c RMVar {get;set;}
    public String RMId;
    public Boolean check {get;set;}
    public List<GE_NAS_RMA_Lineitem__c> RMAlineitemlist {get;set;}
    public string JSONString {get;set;}
    public String[] InvoiceNumber{get;set;}
    public List<GE_LGT_EM_InvoiceLineItem__c> InvoicelineList {set; get;}
    public boolean deletecheckflag {get;set;}
    public boolean insertcheckflag {get;set;}
    public boolean checkflag{get;set;}
    
    public InvoiceLineitemSearch(ApexPages.StandardController controller) {
    inte = 0;
    insertcheckflag =false;
    deletecheckflag =false;
    checkflag =false;
    InvoiceSearchList = new list<GE_LGT_EM_InvoiceLineItem__c>();
    InvoicelineListAddlines = new list<GE_LGT_EM_InvoiceLineItem__c>();
    RMAlineitemlist = new list<GE_NAS_RMA_Lineitem__c>();
    check = False;
    ID recordTypeCaseElight=Schema.SObjectType.Case.getRecordTypeInfosByName().get('eLight - Return').getRecordTypeId();
    RMId = controller.getID(); //gets the RMA id and stores it in RMId String 
    RMVar = [SELECT ID,Case__c,(SELECT Id,Material__c,Material_Number__c,GE_LGT_EM_Order_Number__c,SAP_Invoice_Number__c,Comments__c,Return_Qty__c,Is_Active__c,Product_Code__c,Return_Extended_Amount__c,Invoiced_Extended_Amount__c, Invoiced_Price__c,Invoiced_Qty__c,Invoiced_UM__c,Invoiced_Unit_Price__c,Invoice_Line_Item__c FROM RMA_Lineitems__r)FROM RMA__c WHERE Id =: RMId];
    RMAlineitemlist = [SELECT Id,Material__c,Material_Number__c,GE_LGT_EM_Order_Number__c,Invoice_Line_Item__r.GE_LGT_EM_SAP_Invoice_Number__c,SAP_Invoice_Number__c,Comments__c,Return_Qty__c,Is_Active__c,Product_Code__c,Return_Extended_Amount__c,
                     Invoiced_Extended_Amount__c, Invoiced_Price__c,Invoiced_Qty__c,Invoiced_UM__c,Invoiced_Unit_Price__c,Invoice_Line_Item__c,GE_NAS_RMA_No__c  
                     FROM   GE_NAS_RMA_Lineitem__c where GE_NAS_RMA_No__c =:RMId ];

    }
    
     public InvoiceLineitemSearch(ApexPages.StandardSetController controller) 
    {
         
    }
    
    // First Page Method
    public void firstcmd(){
        InvoiceSearchList = new list<GE_LGT_EM_InvoiceLineItem__c>();
        inte = 0;
            for(integer i = inte;  i < inte + 25; i++){
            InvoiceSearchList.add(InvoicelineList[i]);
            }
            
    }
    // Last Page Method
    public void lastcmd(){
        InvoiceSearchList = new list<GE_LGT_EM_InvoiceLineItem__c>();
        inte = InvoicelineList.size()-25;
            for(integer i = inte;  i < inte + 25; i++){
            InvoiceSearchList.add(InvoicelineList[i]);
            }
           
    }
    
   
    // Prev Page Method
    public void prevcmd(){
    InvoiceSearchList = new list<GE_LGT_EM_InvoiceLineItem__c>();
        inte = inte - 25;
            for(integer i = inte;  i < inte + 25; i++){
            InvoiceSearchList.add(InvoicelineList[i]);
            }
           
    }
    
    // Next Page Method
    public void nextcmd(){
        InvoiceSearchList = new list<GE_LGT_EM_InvoiceLineItem__c>();
        inte = inte + 25;
            for(integer i = inte;  i < inte + 25; i++){
            InvoiceSearchList.add(InvoicelineList[i]);
            }
            
    }
   
    
    
    public void searchInvoice()
    
    {
        system.debug('@@@@1'+ check );
        
        if(searchStr!=Null)
        {
            system.debug('3343'+searchStr);
            check =true;
            system.debug('@@@@2'+ check );
            InvoicelineList =[SELECT ID,GE_LGT_EM_Material__c,GE_LGT_EM_Material__r.GE_LGT_EM_SAP_MaterialNumber__c,GE_LGT_EM_Order_Number__c,GE_LGT_EM_Dispute_Flag__c,GE_LGT_EM_SAP_Invoice_Number__c,GE_LGT_EM_Invoiced_Quantity__c,GE_LGT_EM_Invoiced_Price__c,GE_LGT_EM_Invoiced_Price_Unit__c from GE_LGT_EM_InvoiceLineItem__c 
            where GE_LGT_EM_Order_Number__c Like : '%'+ searchStr +'%' AND GE_LGT_EM_Order_Number__c!=NULL limit 200];
            for(GE_LGT_EM_InvoiceLineItem__c Il :InvoicelineList) {
                
                Il.GE_LGT_EM_Dispute_Flag__c = false;
            }
        }
        InvoiceSearchList = new list<GE_LGT_EM_InvoiceLineItem__c>();
        inte = 0;
        if(InvoicelineList.size() > 25){
            for(integer i = inte;  i < inte + 25; i++){
            InvoiceSearchList.add(InvoicelineList[i]);
            }
            integ = InvoicelineList.size()- 25; 
        }
        else{
        InvoiceSearchList = InvoicelineList;
        integ = -1;
        }
    }
    public boolean b{get; set;}
    // save Method
    public Void SaveRMA()
    {
        try{
            insertcheckflag =true;
            deletecheckflag =false;
            checkflag =true;
            for (GE_NAS_RMA_Lineitem__c each :RMAlineitemlist) {
                each.Return_Extended_Amount__c = each.Invoiced_Price__c * each.Return_Qty__c;
            }
            Upsert RMAlineitemlist;
           /* if(RMVar.Case__c!=null){
                List<Product_Returns_list__c> productReturnsList = new List<Product_Returns_list__c>();
                List<Product_Returns_list__c> oldProductReturnsList = [select id from Product_Returns_list__c where Case__c=:RMVar.Case__c ];
                if (!oldProductReturnsList.isEmpty()){
                    delete oldProductReturnsList;
                }
                for (GE_NAS_RMA_Lineitem__c each :RMAlineitemlist) {
                    Product_Returns_list__c tempObj = new Product_Returns_list__c();
                    tempObj.Case__c = RMVar.Case__c;
                    tempObj.Invoiced_Price__c = each.Invoiced_Price__c;
                    tempObj.Invoiced_Qty__c = each.Invoiced_Qty__c;
                    tempObj.Invoiced_Unit_Price__c = each.Invoiced_Unit_Price__c;
                    tempObj.Product_Code__c=each.Product_Code__c;
                    tempObj.Comments__c=each.Comments__c;
                    tempObj.Invoiced_UM__c=each.Invoiced_UM__c;
                    tempObj.Invoiced_Extended_Amount__c=each.Invoiced_Extended_Amount__c;
                    tempObj.Return_Extended_Amount__c=each.Invoiced_Price__c*each.Return_Qty__c;
                    tempObj.Return_Qty__c=each.Return_Qty__c;
                    tempObj.Material_Number__c=each.Material_Number__c;
                    tempObj.Material__c=each.Material__c;
                    tempObj.Invoice_Line_Item__c=each.Invoice_Line_Item__c;
                    tempObj.SAP_Invoice_Number__c=each.SAP_Invoice_Number__c;
                    tempObj.GE_LGT_EM_Order_Number__c=each.GE_LGT_EM_Order_Number__c;
                    productReturnsList.add(tempObj);
                }
                if (!productReturnsList.isEmpty()) {
                    insert productReturnsList;
                }
            }   */
        }
        catch(exception e)
        {
         
        }
    
        check = false;
    }
   
    // Cancel pagereference method

    public pageReference CancelRMA()
    {  
        
        PageReference pf = new PageReference('/' + RMId);
        pf.setRedirect(true);
        return pf;

    }

    // Save & Go To RMA pagereference method
    public pageReference savegtoRMA()
    {
            SaveRMA();
            if (!ApexPages.hasMessages()){
                PageReference pf = new PageReference('/' + RMId);
                pf.setRedirect(true);
                return pf;
            }
            return null;
    }
    
    // Extension Page Refrence Method
     public pageReference onLoadPage_Invoice(){
       InvoiceNumber = new List<String>();
        InvoicelineList  = [SELECT ID,GE_LGT_EM_Order_Number__c,GE_LGT_EM_Dispute_Flag__c,GE_LGT_EM_SAP_Invoice_Number__c,GE_LGT_EM_Invoiced_Quantity__c,GE_LGT_EM_Invoiced_Price__c,GE_LGT_EM_Invoiced_Price_Unit__c from GE_LGT_EM_InvoiceLineItem__c limit 200];
        for(GE_LGT_EM_InvoiceLineItem__c InlineVar :  InvoicelineList){
            if(InlineVar.GE_LGT_EM_Order_Number__c != null)
                InvoiceNumber.add(InlineVar.GE_LGT_EM_Order_Number__c);
        }
        InvoicelineList.clear();
        JSONString = JSON.serialize(InvoiceNumber);
        system.debug('******'+JSONString);
        return null;  
    }
    
    // Add Method
    public void addLines() {
        b = false; 
        Set<String> setInvoiceID = new Set<String>();
        Map<string,string> mapPrdEnt = new Map<string,string>();
        for(GE_LGT_EM_InvoiceLineItem__c Invoice :InvoicelineListAddlines) { 
            setInvoiceID.add(Invoice.ID);
        }
        for(GE_LGT_EM_InvoiceLineItem__c Invoice :InvoiceSearchList) {    
            setInvoiceID.add(Invoice.ID);
        }
        GE_NAS_RMA_Lineitem__c RmLine = new GE_NAS_RMA_Lineitem__c();
        for(GE_LGT_EM_InvoiceLineItem__c Invoice :InvoiceSearchList) {
            if(Invoice.GE_LGT_EM_Dispute_Flag__c) {
                RmLine = new GE_NAS_RMA_Lineitem__c();
                RmLine.GE_NAS_RMA_No__c = RMVar.ID;
                RmLine.Invoiced_Qty__c=Invoice.GE_LGT_EM_Invoiced_Quantity__c;
                RmLine.Invoiced_Price__c =Invoice.GE_LGT_EM_Invoiced_Price__c;
                RmLine.Invoiced_Unit_Price__c =Invoice.GE_LGT_EM_Invoiced_Price_Unit__c;  
                RmLine.Invoice_Line_Item__c =Invoice.ID;
                RmLine.SAP_Invoice_Number__c =Invoice.GE_LGT_EM_SAP_Invoice_Number__c;
                RmLine.Material__c=Invoice.GE_LGT_EM_Material__c;
                RmLine.GE_LGT_EM_Order_Number__c=Invoice.GE_LGT_EM_Order_Number__c;
                RmLine.Material_Number__c=Invoice.GE_LGT_EM_Material__r.GE_LGT_EM_SAP_MaterialNumber__c;
                RMAlineitemlist.add(RmLine);
            }
        }

    }
    // Delete RMA Lineitem
    public void DeleteRMALineitems(){
        list<GE_NAS_RMA_Lineitem__c> DeleteRMALineitemList =new list<GE_NAS_RMA_Lineitem__c>();
        system.debug('testlist'+RMAlineitemList);
        for(GE_NAS_RMA_Lineitem__c RMALineVar :RMAlineitemlist){
            if(RMALineVar.Is_Active__c){
                DeleteRMALineitemList.add(RMALineVar);
            }
        }
            if(DeleteRMALineitemList.size()>0){
                system.debug('testlist213'+DeleteRMALineitemList);
                try{
                    insertcheckflag =false;
                    deletecheckflag =true;
                    checkflag =true;
                    delete DeleteRMALineitemList;
                    
                      /*  List<Product_Returns_list__c> productReturnsList = new List<Product_Returns_list__c>();
                        List<Product_Returns_list__c> oldProductReturnsList = [select id from Product_Returns_list__c where Case__c=:RMVar.Case__c ];
                        if (!oldProductReturnsList.isEmpty()){
                            delete oldProductReturnsList;
                        }
                        RMAlineitemlist = [SELECT Id,Material_Number__c,GE_LGT_EM_Order_Number__c,Material__c,Invoice_Line_Item__r.GE_LGT_EM_SAP_Invoice_Number__c,SAP_Invoice_Number__c,Comments__c,Return_Qty__c,Is_Active__c,Product_Code__c,Return_Extended_Amount__c,
                    Invoiced_Extended_Amount__c, Invoiced_Price__c,Invoiced_Qty__c,Invoiced_UM__c,Invoiced_Unit_Price__c,Invoice_Line_Item__c,GE_NAS_RMA_No__c  
                    FROM   GE_NAS_RMA_Lineitem__c where GE_NAS_RMA_No__c =:RMId ];
                    if(RMVar.Case__c!=null){    
                        
                        for (GE_NAS_RMA_Lineitem__c each :RMAlineitemlist) {
                            Product_Returns_list__c tempObj = new Product_Returns_list__c();
                            tempObj.Case__c = RMVar.Case__c;
                            tempObj.Invoiced_Price__c = each.Invoiced_Price__c;
                            tempObj.Invoiced_Qty__c = each.Invoiced_Qty__c;
                            tempObj.Invoiced_Unit_Price__c = each.Invoiced_Unit_Price__c;
                            tempObj.Product_Code__c=each.Product_Code__c;
                            tempObj.Comments__c=each.Comments__c;
                            tempObj.Invoiced_UM__c=each.Invoiced_UM__c;
                            tempObj.Invoiced_Extended_Amount__c=each.Invoiced_Extended_Amount__c;
                            tempObj.Return_Extended_Amount__c=each.Invoiced_Price__c*each.Return_Qty__c;
                            tempObj.Return_Qty__c=each.Return_Qty__c;
                            tempObj.Material_Number__c=each.Material_Number__c;
                            tempObj.Material__c=each.Material__c;
                            tempObj.Invoice_Line_Item__c=each.Invoice_Line_Item__c;
                            tempObj.SAP_Invoice_Number__c=each.SAP_Invoice_Number__c;
                            tempObj.GE_LGT_EM_Order_Number__c=each.GE_LGT_EM_Order_Number__c;
                            productReturnsList.add(tempObj);
                        }
                        if (!productReturnsList.isEmpty()) {
                            insert productReturnsList;
                        }
                    }*/
                    
                }
                catch(exception e){
                    
                }   
                
        }
        else if(DeleteRMALineitemList.size()==0) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Select atleast one RMA lineitem to delete'));
                        checkflag=true;
                        insertcheckflag =false;
                        deletecheckflag =false;
                }
    }
    

}