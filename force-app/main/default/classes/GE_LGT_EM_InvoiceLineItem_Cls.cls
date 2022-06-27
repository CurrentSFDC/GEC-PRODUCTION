/*
###########################################################################
# File..................:GE_LGT_EM_InvoiceLineItem_Cls
# Version...............: 1.0
# Created by............:Jojan,Murugan, István Kádár-Tóth 
# Created Date..........: 
# Description...........: This class is used to create Complaint lineItem in bulk 
#                         1) It has a search capability on SAP Invoice number and related customer of the case
#                         2) It has a search capability on related customer number of the case
#                       
# Copyright (c) GE Lighting EMEA. All Rights Reserved.
#
# Created by the TechMahindra Software Centre. Modification must retain the above copyright #notice.
#
# Permission to use, copy, modify, and distribute this software and its
# documentation for any commercial purpose, without fee, and without a written
# agreement from GE Lighting EMEA, is hereby forbidden. Any modification to #source
# code, must include this paragraph and copyright.
#
# Permission is not granted to anyone to use this software for commercial uses.
# Company URL : 
*/
public with sharing class GE_LGT_EM_InvoiceLineItem_Cls {
    
    //**** declaration parts Starts here ****
    
    list<GE_LGT_EM_ComplaintLineItem__c>insertlist=new list<GE_LGT_EM_ComplaintLineItem__c>();
    Public Id Caseid = System.currentPageReference().getParameters().get('id');   
    
    
    public string Invoice_id{get;set;}
    public string category_id{get;set;}     
    public string ValidateBD{get;set;}
    
    String strQuery; 
    
    String txtSAPNo;
    
    
    public Set<Id> selectedInvoiceIds;
    
    Map<String, String> catgoryMap = new Map<String, String>();
    public List<GE_LGT_EM_InvoiceLineItem__c> selectedInvoice1;
    public String contextItem{get;set;}  
    
    public List<Case> AccCusid=new List<Case>();
    
    transient public string accountids {get;set;}
    public string accountcustomerNo {get;set;} 
    
    @TestVisible GE_LGT_EM_CustomIterable obj;
    public list<GE_LGT_EM_CategoryInner> catInnerObj {get;set;}    
    public string sQuery;
    
    //**** declaration parts End here****   
    
    
    //****constructor in onload page for getting records ****      
    public GE_LGT_EM_InvoiceLineItem_Cls(ApexPages.StandardSetController controller) {
        
        
        AccCusid=[SELECT AccountId,Account.GE_LGT_EM_SAP_Customer_Number__c FROM Case where id=:Caseid];     
        for(Case accids:AccCusid){
            accountids=accids.AccountId; 
            accountcustomerNo=accids.Account.GE_LGT_EM_SAP_Customer_Number__c;
        }
        this.selectedInvoiceIds= new Set<Id>();   
        sQuery ='select Name,GE_LGT_EM_SAP_Invoice_Number__c,CurrencyIsoCode,GE_LGT_EM_Order_Number__c,GE_LGT_EM_Invoiced_Price_Unit__c,GE_LGT_EM_InvoicedValue__c,GE_LGT_EM_Invoiced_Quantity__c,GE_LGT_EM_Category__c,GE_LGT_EM_Delivery_Plant__c,GE_LGT_EM_SAP_LineItemNumber__c,GE_LGT_EM_Material__r.GE_LGT_EM_SAP_MaterialNumber__c from GE_LGT_EM_InvoiceLineItem__c where GE_LGT_EM_Payer_Sold_to_Account_Number__c='+'\''+accountcustomerNo+'\' and id not in(SELECT GE_LGT_EM_Ref_InvoiceLineItem__c FROM GE_LGT_EM_ComplaintLineItem__c where GE_LGT_EM_CaseNumber__c='+'\''+Caseid+'\') LIMIT 2000';
        obj = new GE_LGT_EM_CustomIterable(sQuery); 
        obj.setPageSize = 10;
        next();      
    }
    
    
    // ****handle item Selected****
    public void doSelectItem(){
        this.selectedInvoiceIds.add(this.contextItem);
        
    }
    
    //****handle item deselected****
    public void doDeselectItem(){
        this.selectedInvoiceIds.remove(this.contextItem);
        
    }  
    
    
    // ****selected invoice list added into Wrapper class****
    public List<GE_LGT_EM_InvoiceLineItem__c> getcatInnerObj(){
        
        selectedInvoice1 =new List <GE_LGT_EM_InvoiceLineItem__c>();
        
        for(GE_LGT_EM_CategoryInner selectinnerlist:obj.ListLineItemObj()) {
            
            if(this.selectedInvoiceIds.contains(selectinnerlist.cat.Id)){
                
                selectedInvoice1.add(selectinnerlist.cat);
                
            }
        }      
        
        return selectedInvoice1;
        
    }
    
    // ****Selected invoicelist insert into the complaintlineitem object****  
    public PageReference processSelected() {
        transient integer counter=0;
        
        list<GE_LGT_EM_ComplaintLineItem__c> ListLineItemCount=[SELECT GE_LGT_EM_Complaint_Reference_Number__c FROM GE_LGT_EM_ComplaintLineItem__c where GE_LGT_EM_CaseNumber__c=:Caseid and GE_LGT_EM_Complaint_Reference_Number__c !=null  order by GE_LGT_EM_Complaint_Reference_Number__c desc limit 1];
        
        id devRecordTypeId =Schema.SObjectType.GE_LGT_EM_ComplaintLineItem__c.getRecordTypeInfosByName().get('Complaint Line Items').getRecordTypeId();
        
        for(GE_LGT_EM_ComplaintLineItem__c ar:ListLineItemCount){
            
            counter= integer.valueof(ar.GE_LGT_EM_Complaint_Reference_Number__c);
        }
        for(GE_LGT_EM_InvoiceLineItem__c InvObj:getcatInnerObj() ) {
            
            if(counter==0){
                counter=10;
            }
            else{
                counter=counter+10;
            }
            
            
            GE_LGT_EM_ComplaintLineItem__c GELineItem = new GE_LGT_EM_ComplaintLineItem__c();
            GELineItem.GE_LGT_EM_CaseNumber__c=Caseid;
            GELineItem.RecordTypeId =devRecordTypeId;
            GELineItem.CurrencyIsoCode=InvObj.CurrencyIsoCode;
            GELineItem.GE_LGT_EM_Ref_InvoiceLineItem__c=InvObj.id ; 
            GELineItem.GE_LGT_EM_InvoicedQuantity__c=InvObj.GE_LGT_EM_Invoiced_Quantity__c;
            //Added by István Kádár-Tóth GE_LGT_EM_Req_Price_Unit__c
            GELineItem.GE_LGT_Req_Price__c=(InvObj.GE_LGT_EM_InvoicedValue__c /InvObj.GE_LGT_EM_Invoiced_Quantity__c);
            GELineItem.GE_LGT_EM_Invoiced_Price_Unit__c=InvObj.GE_LGT_EM_Invoiced_Price_Unit__c;
            GELineItem.GE_LGT_EM_Req_Price_Unit__c=InvObj.GE_LGT_EM_Invoiced_Price_Unit__c; 
            GELineItem.GE_LGT_EM_RequestedValue__c=InvObj.GE_LGT_EM_InvoicedValue__c;
            GELineItem.GE_LGT_EM_InvoicedValue__c=InvObj.GE_LGT_EM_InvoicedValue__c;
            GELineItem.GE_LGT_EM_RequestedQuantity__c=InvObj.GE_LGT_EM_Invoiced_Quantity__c;
            GELineItem.GE_LGT_EM_RequestedValue__c=InvObj.GE_LGT_EM_InvoicedValue__c;
            GELineItem.GE_LGT_EM_ApprovedQuantity__c=InvObj.GE_LGT_EM_Invoiced_Quantity__c;
            GELineItem.GE_LGT_EM_InvoicedPrice__c=(InvObj.GE_LGT_EM_InvoicedValue__c /InvObj.GE_LGT_EM_Invoiced_Quantity__c);
            GELineItem.GE_LGT_EM_ApprovedUnitPrice__c=(InvObj.GE_LGT_EM_InvoicedValue__c /InvObj.GE_LGT_EM_Invoiced_Quantity__c);
            GELineItem.SAP_Order_Nr__c=InvObj.GE_LGT_EM_Order_Number__c;
            GELineItem.GE_LGT_EM_Complaint_Reference_Number__c=counter;
            
            if(catgoryMap.get(InvObj.id) !='' && catgoryMap.get(InvObj.id) !=null ){
                system.debug('inside condition');
                GELineItem.GE_LGT_EM_Category__c=catgoryMap.get(InvObj.id);
            }
            else{
                system.debug('inside else ');
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Please choose category for the selected record'));
                return null;
            }
            
            GELineItem.GE_LGT_EM_Material_Number__c=InvObj.GE_LGT_EM_Material__r.id;
            GELineItem.GE_LGT_EM_Plant__c=InvObj.GE_LGT_EM_Delivery_Plant__c;
            
            insertlist.add(GELineItem); 
            system.debug('insertlist--->'+insertlist.size());
            
            
        }  
        
        if(insertlist.size()>0 ){        
            try{
                insert insertlist;                    
            }catch(exception ee){
                if(ee.getmessage().contains('Customer is B&D Checked'))        
                    return null;
            }
            set<string>cliID=new set<string>();
            for(GE_LGT_EM_ComplaintLineItem__c updateApp:insertlist){
                cliID.add(updateApp.id);
            }
            list<GE_LGT_EM_ComplaintLineItem__c> updateApprovalSteps=[select GE_LGT_EM_Category__c from GE_LGT_EM_ComplaintLineItem__c where Id =:cliID];
            update updateApprovalSteps;
            PageReference reference= new PageReference('/'+Caseid);   
            reference.setRedirect(true);
            return reference;         
        }
        else{
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Please select atleast one record'));
            return null;
        }
        
        return null;
        
    }
    
    // ****when clicking on back button its going to parent page****
    public PageReference BackToParent(){
        
        PageReference reference= new PageReference('/'+Caseid);   
        reference.setRedirect(true);
        return reference;
        
    }
    
    
    //*********** pagenation Start here********************
    
    public Boolean hasNext {
        
        get {
            return obj.hasNext();
        }
        set;
    }
    
    // ****indicates whether there are more records before the current page set ****
    public Boolean hasPrevious {
        
        get {
            return obj.hasPrevious();
        }
        set;
    }
    
    
    // ****returns the previous page of records****
    public void previous() {
        
        catInnerObj = obj.previous();
    }
    
    //**** returns the next page of records****
    public void next() {
        
        catInnerObj = obj.next();
        
    }
    
    
    
    
    //************ End Pagenation******************  
    
    public String gettxtSAPNo(){
        
        return txtSAPNo;
    } 
    
    public void settxtSAPNo(String txtSAPNo){
        
        this.txtSAPNo=txtSAPNo;
    }
    
    
    
    //************** Search functionality starts here********************
    
    public PageReference Search() {
        
        String varNo=gettxtSAPNo();
        
        System.debug('varNo------>  '+varNo);
        
        if(txtSAPNo=='' || txtSAPNo==null){
            
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Please enter SAP Invoice Number'));
            return null;
        }
        else{
            strQuery='select Name,GE_LGT_EM_SAP_Doc_Type__c ,GE_LGT_EM_Material__r.GE_LGT_EM_SAP_MaterialNumber__c,GE_LGT_EM_Order_Number__c,GE_LGT_EM_InvoicedValue__c,GE_LGT_EM_Invoiced_Price_Unit__c,GE_LGT_EM_SAP_Invoice_Number__c,GE_LGT_EM_Invoiced_Quantity__c,GE_LGT_EM_SAP_LineItemNumber__c,GE_LGT_EM_Category__c,GE_LGT_EM_Delivery_Plant__c from GE_LGT_EM_InvoiceLineItem__c where GE_LGT_EM_Payer_Sold_to_Account_Number__c='+'\''+accountcustomerNo+'\'and';
            
            if( txtSAPNo !=''){
                
                strQuery=strQuery+' '+'GE_LGT_EM_SAP_Invoice_Number__c '+'='+'\''+varNo+'\'';  
                
                obj = new GE_LGT_EM_CustomIterable(strQuery); 
                obj.setPageSize = 10;
                next(); 
                
            }
        } 
        
        txtSAPNo='';
        return null;
    }
    //************** Search functionality End here********************
    
    // this method using for getting category values once event is onchanged 
    public void save_categary() {
        
        catgoryMap.put(Invoice_id,category_id);
    } 
}

//***************************** End main class********************************