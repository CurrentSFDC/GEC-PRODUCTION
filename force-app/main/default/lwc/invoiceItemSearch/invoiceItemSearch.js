import { LightningElement, track, api, wire } from 'lwc';
import findInvLineRecords from "@salesforce/apex/LwcLookupControllerCust.findInvLineRecords";
import getInvLineNewList from "@salesforce/apex/LwcLookupControllerCust.getInvLineNewList";
import getOrderId from "@salesforce/apex/OrderProductController.getOrderId";
import updateInvoiceLines from '@salesforce/apex/connectCreateCase.updateInvLines';
import { updateRecord, deleteRecord } from 'lightning/uiRecordApi';

import getReturnList from '@salesforce/apex/OrderProductController.getReturnList';
//import updateOrderItemList from '@salesforce/apex/OrderProductController.updateOrderItemList';
import updateInvItem from '@salesforce/apex/LwcLookupControllerCust.updateInvItem';
import updateReturnItemList from '@salesforce/apex/OrderProductController.updateReturnItemList';


import soldToFiltering from "@salesforce/apex/LwcLookupControllerCust.soldToFiltering";

//--- CLASSES USED FOR WARRANY & MANUAL ENTRY ----
//import getProdFamilies from '@salesforce/apex/LwcLookupControllerCust.getProductFamilies';
import getProdFamilies from '@salesforce/apex/StockBalancingReturnLwcController.getProductFamilies';
import createReturnItem from '@salesforce/apex/ReturnOrderItemController.createReturnOrderItems';
import updReturnOrderItems from '@salesforce/apex/ReturnOrderItemController.updReturnOrderItems';
import deleteReturnItemList from '@salesforce/apex/OrderProductController.delReturnItems';
// - END CLASSES USED FOR MANUAL PRODUCT ENTRY


import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const actions = [
    { label: 'Edit', name: 'edit'},
    { label: 'Delete', name: 'delete'}
];

import {loadStyle} from 'lightning/platformResourceLoader'
import COLORS from '@salesforce/resourceUrl/colors'



export default class InvoiceItemSearch extends LightningElement {

    
// REMOVE THESE ATTRIBUTES????????
    @track recordsList;  
    @track recordsListNew;
    @track searchKey = "";  
    @track searchKeyNew = ""; 
    @api selectedValue;  
    @api selectedValueNew; 
    @api selectedRecordId;  
    @api selectedRecordIdNew; 
    @api filterFieldVal='DEFAULT';  
    @api iconName;  
    @api lookupLabel; 
    @api orderagency; 
    @track message;
    @api defOrd;
    @track searchText;  
    @track options = [];
    @track selectedAccount;
    @track accounts;
    @track currentRecordOrder;
    @track returnAmount;
    @track currentRecordDtl;
    @api getorder;
    @track isOrderIdAvailable = false;
    @track flagIndi = false;
    @track orderId='';
    draftValues = [];
    @track error;
    @track orderItemList=[];
    @track rowReturnTotal;
    @track paramString;
    @api agentNumber;
    @api showDistroField= false;
    @track distLines;
    @track distAccName;
    @api soldToAccount;
    @track disAccount;
    @track disName=[];
    @track overrideOption;
    
    @api preslectedSoldTo(){
        this.searchDisabled = false;
    }


//ATTRIBUTES RECEIVED FROM PARENT COMPONENT
    @api columns;
    @api cartColumns;
    @api prodFamilies;
    @api orderNumber;
    @api caseType;
    @api preselectedOrder;
    @api transactionID;
    @api preSelectedAccount;
    @api selectedDistributorID;
    @api objectApiName = '';
    @api filterFieldName = '';
    @api orderID;
    @api popOptions = [];
    @api headerAction;
    @api selectorNumber;
    @api userType;
    @track soldToInvoiceLines = [];
    @api preloadLines = [];
    @track noPO = "";


//USED FOR PAGINATION
    @track page = 1; //this is initialize for 1st page
    @track data = [];
    @track startingRecord = 1; //start record position per page
    @track endingRecord = 0; //end record position per page
    @track pageSize = 5; //default value we are assigning
    @track totalRecountCount = 0; //total record count received from all retrieved records
    @track totalPage = 0; //total number of page is needed to display all records

//COMMON ATTRIBUTES AND FUNCTIONS
    @api valuetopass;
    @api selectedOrder;
    @api storedLines;
    @track currentRecordId;
    @track oldTempNumber;
    @track oldOrderNumber;
    @track linesToUpdate = [];
    @track invLines = [];
    @track tempList = [];    
    @track hasLines = false;
    @track isEditForm = false;
    @track isCssLoaded = false;
    @track returnItemId;
    @track deleteModal = false;
    @api selectedSoldToAccountName;

    handleKey(event){
        if(event.which == 13){
            //this.searchLines();
            this.finalFilter();
        }
    }

    keyChange(){
        let input = this.template.querySelector('.sk').value;
        //let orderLength = this.orderNumber;
        console.log('KEY CHANGE --> Checking PreSelectedOrder Length...');
        //if(input.length > 2 || orderLength.length > 2){
            if(input.length > 2){         
                this.searchButtonDisabled = false;
             
        } else {
            this.searchButtonDisabled = true;
        }
    }

    @api setPreloadedLines(inputData){
    
        this.soldToInvoiceLines = inputData.lines;
        this.preloadLines = inputData.lines;
        console.log('PRELOADED LINES SET FROM PARENT COMPONENT: ' + JSON.stringify(this.soldToInvoiceLines));
        
        
    }

    ///PRE-LOADING LINES INTO INVOICE SEARCH
    filterPreLoad(){
        console.log('SOLD TO ACCOUNT SELECTED IN THE ACCOUNT SELECTOR...EXECUTING FILTERING...');
        console.log('filterFieldName Attribute = '+this.filterFieldName);
        console.log('preloadLines Attribute = '+JSON.stringify(this.preloadLines));

        soldToFiltering({soldTo: this.filterFieldName, invLines : this.preloadLines})
        .then(result => {
            this.soldToInvoiceLines = result;
            console.log('PRELOADED INVOICE LINES --> SOLD TO CHANGED: '+JSON.stringify(result));
            console.log('SOLDTOINVOICELINES ATTRIBUTE --> SOLD TO CHANGED: '+JSON.stringify(this.soldToInvoiceLines));

        
        });            

        
    }

    async finalFilter(event){
  
        console.log('SOLD TO --> Filtering based on Search Text...');
        this.searchKey = this.template.querySelector('.sk').value;
        console.log('SEARCH KEY ENTERED: '+this.searchKey);
        var searchText = this.searchKey.toUpperCase();
       
        console.log('Search Term: ' + searchText);
        var allRecords = this.soldToInvoiceLines;
        console.log('SEARCHING SOLD TO INVOICE LINES ARRAY.....PLEASE WAIT....' + JSON.stringify(this.soldToInvoiceLines));
        console.log('SEARCHING ALLRECORDS ARRAY.....PLEASE WAIT....' + JSON.stringify(allRecords));
        var searchResults = [];
        var i;

        for (i = 0; i < allRecords.length; i++) {
            console.log('ITEM NUMBER: '+i);
            console.log('Current Item Order Number: '+allRecords[i].GE_LGT_EM_Order_Number__c);
            console.log('Current Item PO Number: '+allRecords[i].GE_LGT_EM_Customer_PO_Number__c);
            console.log('Current Item Invoice Number: '+allRecords[i].GE_LGT_EM_SAP_Invoice_Number__c);

           if ((allRecords[i].GE_LGT_EM_Order_Number__c.toUpperCase().includes(searchText)) ||
                (allRecords[i].GE_LGT_EM_Customer_PO_Number__c.toUpperCase().includes(searchText) ) ||
                (allRecords[i].GE_LGT_EM_SAP_Invoice_Number__c.toUpperCase().includes(searchText))) {

                    searchResults.push(allRecords[i]);
            }
        }

        console.log('Searchable Array: ' + JSON.stringify(searchResults));
        console.log('SearchResults Array Length: '+searchResults.length);

            if(searchResults.length > 0){
                this.tempList = [];
                if(this.caseType === 'Credit' || this.caseType === 'Overage' || this.caseType === 'Shortage' || this.caseType === 'Lost/Damaged' || this.caseType === "Warranty"){
                    console.log('JSON FILTER RESULTS: '+JSON.stringify(searchResults));
                    this.tempList = searchResults.map(item=>{
                        
                        const tempNumber = item.GE_LGT_EM_Order_Number__c;
                        
                        let newNumber = tempNumber.replace(/^0+/, "");
                        //console.log('Material Supply Chain Status: '+item.GE_LGT_EM_Material__r.GE_LGT_EM_Distribution_Chain_Status__c);
                        //let chainStatus = item.GE_LGT_EM_Material__r.GE_LGT_EM_Distribution_Chain_Status__c;
                        //let cellColor = item.Available_for_Return__c == 0  ? "slds-text-color_error":"slds-text-color_default"
                        let buttonColor = item.Available_for_Return__c > 0 ? "brand":"brand-inverse"
                        let textColor = item.Available_for_Return__c == 0 ? "slds-text-color_error":"slds-text-color_default"
                        let iconName = item.Available_for_Return__c == 0 ? "utility:lock":"utility:new"
                        let rowIcon = item.Available_for_Return__c == 0 ? "utility:lock":""
                        let iconTitle = item.Available_for_Return__c == 0 ? "Return Depleted":""
                        let actionDisabled = item.Available_for_Return__c == 0 ? true:false
                        return {...item, 
                            "actionDisabled":actionDisabled,
                            "iconName":iconName,
                            "textColor":textColor,
                            //"cellColor":cellColor,
                            'buttonColor':buttonColor,
                            'rowIcon': rowIcon,
                            'iconTitle':iconTitle,
                            'newNumber': newNumber
                        }
                    });
                } else if (this.caseType === 'Return' || this.caseType === 'Return/Replace'){
                    console.log('JSON FILTER RESULTS: '+JSON.stringify(searchResults));
                    this.tempList = searchResults.map(item=>{
                        
                        
                        console.log(item.GE_LGT_EM_SAP_Invoice_Number__c);
                   
                        
                        const tempNumber = item.GE_LGT_EM_Order_Number__c;
                        let newNumber = tempNumber.replace(/^0+/, "");
                        
                        //console.log('Material Supply Chain Status: '+item.GE_LGT_EM_Material__r.GE_LGT_EM_Distribution_Chain_Status__c);
                        //let chainStatus = item.GE_LGT_EM_Material__r.GE_LGT_EM_Distribution_Chain_Status__c;
                        //let cellColor = item.Available_for_Return__c == 0  ? "slds-text-color_error":"slds-text-color_default"
                        let buttonColor = (item.Available_for_Return__c > 0 && item.GE_LGT_EM_Material__r.GE_LGT_EM_Distribution_Chain_Status__c == '02') ? "brand":"brand-inverse"
                        console.log('Assigning Button Color: '+buttonColor);
                        let textColor = (item.Available_for_Return__c == 0 || item.GE_LGT_EM_Material__r.GE_LGT_EM_Distribution_Chain_Status__c != '02' ) ? "slds-text-color_error":"slds-text-color_default"
                        let iconName = (item.Available_for_Return__c == 0 || item.GE_LGT_EM_Material__r.GE_LGT_EM_Distribution_Chain_Status__c != '02' ) ? "utility:lock":"utility:new"
                        let rowIcon = (item.Available_for_Return__c == 0 || item.GE_LGT_EM_Material__r.GE_LGT_EM_Distribution_Chain_Status__c != '02' ) ? "utility:lock":""
                        let iconTitle = (item.Available_for_Return__c == 0 || item.GE_LGT_EM_Material__r.GE_LGT_EM_Distribution_Chain_Status__c != '02' )? "Return Depleted":""
                        let actionDisabled = (item.Available_for_Return__c == 0 || item.GE_LGT_EM_Material__r.GE_LGT_EM_Distribution_Chain_Status__c != '02' ) ? true:false
                        return {...item, 
                            "actionDisabled":actionDisabled,
                            "iconName":iconName,
                            "textColor":textColor,
                            //"cellColor":cellColor,
                            'buttonColor':buttonColor,
                            'rowIcon': rowIcon,
                            'iconTitle':iconTitle,
                            'newNumber': newNumber
                        }
                    });
                }
            
            
               
                this.invLines = this.tempList;
                console.log('invLines Assigned: '+JSON.stringify(this.invLines));
                
                this.totalRecountCount = searchResults.length;
                this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize); //here it is 5
              
              //initital data to be displayed ----------->
              //slice will take 0th element and ends with 5, but it doesn't include 5th element
              //so 0 to 4th rows will be display in the table
              
              
                this.data = this.invLines.slice(0,this.pageSize);
                console.log('DATA IN JSON FORMAT: '+JSON.stringify(this.data));
                var inputData = {
                    totalPages:this.totalPage
                };
                this.hasLines = true;
                //this.template.querySelector("c-paginator").setButtons(inputData);
                if(this.totalRecountCount < this.pageSize){
                    this.endingRecord = this.totalRecountCount;
                } else {
                this.endingRecord = this.pageSize;
                }




              //this.columns = columns;
              this.error = undefined;
                window.console.log(JSON.stringify(searchResults, null, '\t'));
                window.console.log(searchResults.id);
                searchResults.forEach(function (item, key) {
                    window.console.log('Key: '+key); 
                    window.console.log('Item: '+item); 
                });


                this.hasLines = true;
                
            
            }
    }

    searchLines(event){
        console.log('CASE TYPE IN SEARCH LINES: '+this.caseType);
        this.searchKey = this.template.querySelector('.sk').value;
        this.isLoading = true;
        console.log('Search Key: '+this.searchKey);
        console.log('Sending Sold To Number: '+this.filterFieldName);
        findInvLineRecords({searchKey: this.searchKey, objectName: this.objectApiName, filterField: this.filterFieldName})
        .then(result => {
            this.tempList = [];
            if(result){
                this.hasLines = true;
                /* this.tempList = result.map(item=>{
                    let depleted = item.Available_for_Return__c = 0 ? "slds-text-color_error" : "slds-text-color_default"
                    return {...item, "depleted":depleted} 
                })*/
                    if(this.caseType == "Credit" || this.caseType === 'Overage' || this.caseType === 'Shortage' || this.caseType === 'Lost/Damaged' || this.caseType === 'Warranty'){
                        console.log('JSON RESULTS: '+JSON.stringify(result));
                        this.tempList = result.map(item=>{
                        const tempNumber = item.GE_LGT_EM_Order_Number__c;
                        let newNumber = tempNumber.replace(/^0+/, "");
                            console.log('Material Supply Chain Status: '+item.GE_LGT_EM_Material__r.GE_LGT_EM_Distribution_Chain_Status__c);
                            //let chainStatus = item.GE_LGT_EM_Material__r.GE_LGT_EM_Distribution_Chain_Status__c;
                            //let cellColor = item.Available_for_Return__c == 0  ? "slds-text-color_error":"slds-text-color_default"
                            let buttonColor = item.Available_for_Return__c > 0 ? "brand":"brand-inverse"
                            let textColor = item.Available_for_Return__c == 0 ? "slds-text-color_error":"slds-text-color_default"
                            let iconName = item.Available_for_Return__c == 0 ? "utility:lock":"utility:new"
                            let rowIcon = item.Available_for_Return__c == 0 ? "utility:lock":""
                            let iconTitle = item.Available_for_Return__c == 0 ? "Return Depleted":""
                            let actionDisabled = item.Available_for_Return__c == 0 ? true:false
                            return {...item, 
                                "actionDisabled":actionDisabled,
                                "iconName":iconName,
                                "textColor":textColor,
                                //"cellColor":cellColor,
                                'buttonColor':buttonColor,
                                'rowIcon': rowIcon,
                                'iconTitle':iconTitle,
                                'newNumber': newNumber
                            }
                        });
                    } else if (this.caseType === 'Return' || this.caseType === 'Return/Replace'){
                        console.log('JSON RESULTS: '+JSON.stringify(result));
                        this.tempList = result.map(item=>{
                            const tempNumber = item.GE_LGT_EM_Order_Number__c;
                        let newNumber = tempNumber.replace(/^0+/, "");
                            console.log('Material Supply Chain Status: '+item.GE_LGT_EM_Material__r.GE_LGT_EM_Distribution_Chain_Status__c);
                            //let chainStatus = item.GE_LGT_EM_Material__r.GE_LGT_EM_Distribution_Chain_Status__c;
                            //let cellColor = item.Available_for_Return__c == 0  ? "slds-text-color_error":"slds-text-color_default"
                            let buttonColor = (item.Available_for_Return__c > 0 && item.GE_LGT_EM_Material__r.GE_LGT_EM_Distribution_Chain_Status__c == '02') ? "brand":"brand-inverse"
                    let textColor = (item.Available_for_Return__c == 0 || item.GE_LGT_EM_Material__r.GE_LGT_EM_Distribution_Chain_Status__c != '02' ) ? "slds-text-color_error":"slds-text-color_default"
                    let iconName = (item.Available_for_Return__c == 0 || item.GE_LGT_EM_Material__r.GE_LGT_EM_Distribution_Chain_Status__c != '02' ) ? "utility:lock":"utility:new"
                    let rowIcon = (item.Available_for_Return__c == 0 || item.GE_LGT_EM_Material__r.GE_LGT_EM_Distribution_Chain_Status__c != '02' ) ? "utility:lock":""
                    let iconTitle = (item.Available_for_Return__c == 0 || item.GE_LGT_EM_Material__r.GE_LGT_EM_Distribution_Chain_Status__c != '02' )? "Return Depleted":""
                    let actionDisabled = (item.Available_for_Return__c == 0 || item.GE_LGT_EM_Material__r.GE_LGT_EM_Distribution_Chain_Status__c != '02' ) ? true:false
                   
                            return {...item, 
                                "actionDisabled":actionDisabled,
                                "iconName":iconName,
                                "textColor":textColor,
                                //"cellColor":cellColor,
                                'buttonColor':buttonColor,
                                'rowIcon': rowIcon,
                                'iconTitle':iconTitle,
                                'newNumber':newNumber
                            }
                        });
                    }
                
                    this.isLoading = false;
                }
            this.invLines = this.tempList;
            this.isLoading = false;
              this.totalRecountCount = result.length;
              this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize); //here it is 5
                  
                  //initital data to be displayed ----------->
                  //slice will take 0th element and ends with 5, but it doesn't include 5th element
                  //so 0 to 4th rows will be display in the table
                  
                  
                    this.data = this.invLines.slice(0,this.pageSize);
                    console.log('DATA IN JSON FORMAT: '+JSON.stringify(this.data));
                    var inputData = {
                        totalPages:this.totalPage
                    };
                    //this.template.querySelector("c-paginator").setButtons(inputData);
                    if(this.totalRecountCount < this.pageSize){
                        this.endingRecord = this.totalRecountCount;
                    } else {
                    this.endingRecord = this.pageSize;
                    }
    
    
    
    
                  //this.columns = columns;
                  this.error = undefined;
                    window.console.log(JSON.stringify(result, null, '\t'));
                    window.console.log(result.id);
                    result.forEach(function (item, key) {
                        window.console.log('Key: '+key); 
                        window.console.log('Item: '+item); 
                    });
    
    
              
          console.log(JSON.stringify("Lines Returned:  "+ JSON.stringify(this.invLines)));
          this.isLoading = false;
          });
    }

    handleRowActions(event) {
        this.cartLabel = "Add to Request";
        const actionName = event.detail.action.name;
        const row = event.detail.row;
    
        let rowQuantityValue = event.detail.row.GE_LGT_EM_Invoiced_Quantity__c;
        this.minOrderQty = event.detail.row.Minimum_Order_Qty__c;
        console.log('The Row Quantity: '+rowQuantityValue);
        let rowAvilForReturnValue = event.detail.row.Available_for_Return__c;
        let rowReturnTotalValue = event.detail.row.Total_Returned__c;
    
        this.rowQuantity = rowQuantityValue;
        this.rowAvailForReturn = rowAvilForReturnValue;
        this.rowReturnTotal = rowReturnTotalValue;
    
    
        console.log('Edit ActionName: '+ actionName);
        console.log('Edit Row: '+ JSON.stringify(row));
        switch (actionName) {
            case 'edit':
                if (this.caseType == "Warranty"){
                    let rowQuantityValue = event.detail.row.GE_LGT_EM_Invoiced_Quantity__c;
                    console.log('Warranty - The Row Quantity: '+rowQuantityValue);
    
                    this.rowQuantity = rowQuantityValue;
                    console.log('Warranty - Row QTY Set: '+this.rowQuantity);
                    this.editWarrantyCurrentRecord(row);
                }else {
                    this.editCurrentRecord(row);
                }
                break;
            case 'show_details':
                this.showRowDetails(row);
                break;
            default:
        }
    }
    
     // view the current record details
    viewCurrentRecord(currentRow) {
        this.bShowModal1 = true;
        this.isEditForm = false;
        this.record = currentRow;
    }

    // edit record modal
    editCurrentRecord(currentRow) {
        // open modal box
    
        this.bShowModal1 = true;
        this.isEditForm = true;

        // assign record id to the record edit form
        this.errorMessage = "";
        this.currentRecordId = currentRow.Id;
        this.currentRecordOrder = currentRow.GE_LGT_EM_Order_Number__c;
        console.log('Modifying Invoice Line ID: '+this.currentRecordId);
    }

    fetchReturnItems(){
        getReturnList({transId : this.transactionID})
            .then(result =>{
                this.storedLines = result;
                this.cartCount = this.storedLines.length;
               /* if (this.cartCount > 0 && this.caseType == "Warranty"){
                    let disableChange = true;
                    this.template.querySelector("c-sold-to-lookup-l-w-c").disableChangeButton(disableChange);
                    this.template.querySelector("c-sold-to-lookup-l-w-c").disableSearchField(disableChange);
                } else {
                    let disableChange = false;
                    this.template.querySelector("c-sold-to-lookup-l-w-c").disableChangeButton(disableChange);
                    this.template.querySelector("c-sold-to-lookup-l-w-c").disableSearchField(disableChange);
                }*/
                //console.log('Deduction Total: '+currentDeduction);
                console.log('RESULT: '+result.length);
                console.log('Transaction Total BEFORE LOOPING: '+this.transactionTotal);
    
                
                    this.transactionTotal = 0.00;
             
                    for(var i = 0, len = result.length; i < len; i++){
                        
                         var tempAmount = result[i].Transaction_Total__c;
                         this.transactionTotal += tempAmount;
                    }
                    //this.transactionTotal = tempAmount;
                    console.log('Transaction Total END OF LOOPING: '+this.transactionTotal);
                 /*else {
                    this.transactionTotal -= currentDeduction;
                } */   
    
                /*if(this.storedLines.length > 0){
                    var tempAmount = 0;
                    for(var Transaction_Total__c in result){
                        if (result.hasOwnProperty(Transaction_Total__c)){
                            tempAmount += parseFloat(result[Transaction_Total__c]);
                        }
                    }
                    this.transactionTotal = tempAmount;
                    console.log('Transaction Total END OF LOOPING: '+this.transactionTotal);
                }*/
                if(this.storedLines.length == 0){
                    
                    this.transactionTotal = 0.00;
                    this.storedLines = '';
                    console.log('Transaction Total: '+this.transactionTotal);
                }
               
            this.dispatchEvent(
                new CustomEvent('lineupdate', {
                    detail: {
                        lines : this.storedLines
                    }
                }));
            this.dispatchEvent(
                new CustomEvent('cartcount', {
                    detail: {
                        totalItems : this.cartCount
                    }
                }));
            this.isLoading = false;
            this.isRemoving = false;
            this.isAdding = false;
            
        });
     }

     //USED FOR CLEARING CART ON END OF SESSION TIME AND/OR WHEN NAVIGATING AWAY FROM PAGE
     @api clearSessionCart(){
        console.log('EXECUTING CLEAR SESSION CART...');
        this.sessionCartDelete();
    }

    async sessionCartDelete(){
        let listSize = this.storedLines.length;
        console.log('List size to Clear: '+listSize);
        if(listSize > 0){
        for(var i = 0, len = this.storedLines.length; i < len; i++){
            await deleteRecord (this.storedLines[i].Id)
             .then(() => {
     
                     this.fetchReturnItems();
     
             })
             await updateInvoiceLines({lines : this.linesToUpdate})
                     .then(result => {
                         
                     console.log('INVOICE LINES RESET....'+result);
                     var baseURL = window.location.origin;
                        console.log('Base URL: '+baseURL);
                        this.sfdcOrgURL = baseURL+'/s/';
                        console.log('New URL: '+this.sfdcOrgURL);
                        window.open(this.sfdcOrgURL, "_self");  
                     });
            
         }
        } else {
            console.log('NO LINES TO RESET, E.T. IS NOW PHONING HOME!!!!');
            var baseURL = window.location.origin;
            console.log('Base URL: '+baseURL);
            this.sfdcOrgURL = baseURL+'/s/';
            console.log('New URL: '+this.sfdcOrgURL);
            window.open(this.sfdcOrgURL, "_self");  
         
        }
    }

//------------------------------------------------------------------------------------------ END OF COMMON FUNCTIONS -------------------------------------------------------------------------------------------------------

//SOLD TO ACCOUNT LOOKUP LWC ATTRIBUTES AND FUNCTIONS
    @track clear;
    

  async  handleSoldToSelected(event){
        this.filterFieldName = event.detail.selectedAccount;
        console.log('Selected Sold To Number: '+this.filterFieldName);
        this.selectedDistributorID = event.detail.selectedAccountId;
        console.log('Selected Sold To ID: '+this.selectedDistributorID);
        this.selectedSoldToAccountName = event.detail.selectedSoldToAccountName;
        console.log('Selected Sold To Name: '+this.selectedSoldToAccountName);
        this.searchDisabled = false;
        this.manualDisabled = false;

        this.dispatchEvent(
            new CustomEvent('selectedsoldto', {
                detail: {
                    soldto : this.selectedDistributorID,
                    soldToName: this.selectedSoldToAccountName
                }
            }));

            if(this.caseType == "Warranty"){
                console.log('Agent Account ID: '+this.selectorAccountID);
                console.log('Sold To Account ID: '+this.selectedDistributorID);
               await getProdFamilies({soldToAccId: this.selectedDistributorID, agentAccId: this.selectorAccountID})
                    .then(result => {
                    this.prodFamilies = result;
                    console.log('getProdFamilies:' + result);
                    })
                    .catch(error => {
                        console.log(error);
                        this.error = error;
                    });
            }
            this.filterPreLoad();

    }

    clearResults(event){
        this.clear = event.detail.clear;
        console.log('CLEAR: '+this.clear);
        if(this.clear === "true"){
            this.searchKey = '';
            this.preselectedOrder = '';
            this.hasLines = false;
            this.searchDisabled = true;
            this.manualDisabled = true;
            this.accountSearchDisabled = false;
            this.searchButtonDisabled = true;
            this.invLines = [];
        }
    }

//------------------------------------------------------------------------------------------ END OF SOLD TO ACCOUNT LWC FUNCTIONS -------------------------------------------------------------------------------------------------------
    
//CART ATTRIBUTES AND FUNCTIONS
    @track isRemoving = false;
    @track bShowModal = false;
    @track cartLabel;
    @api cartCount = 0;
    @track deleteModal = false;
    @track deleteFromRow = false;
    @track deleteClearAll = false; 
    

    showCart(event) {
        this.bShowModal = true; // display modal window
    }
    
    // to close modal window set 'bShowModal' tarck value as false
    closeModal() {
        this.bShowModal = false;
    } 
    
    // POTENTIAL FUTURE - SAVE CART FUNCTION
    saveCart(){

    
        var savedCart = {
            'Name': this.orderId +' - '+this.transactionID,
            'Lines': this.storedLines
        };
        
        
    
        localStorage.setItem('Saved Cart', JSON.stringify(savedCart));
        console.log('SAVED CART: '+savedCart);
    
    
    }

    cartActions(event){
        const actionName = event.detail.action.name;
        const row = event.detail.row;

        console.log('Delete ActionName: '+ actionName);
        console.log('Delete Row: '+ JSON.stringify(row));
        switch (actionName) {
            case 'delete':
                //this.deleteCurrentRecord(row);
                this.showDeleteModal(row);
                this.deleteFromRow = true;
                this.deleteClearAll = false;
                break;
            default:
        }
   }

    showDeleteModal(currentRow){
        console.log('Row passed: '+JSON.stringify(currentRow));
        this.deleteModal = true;
        this.returnItemId = currentRow.Id;
        console.log('Return Item to Delete: '+this.returnItemId);
        this.currentSKU = currentRow.SKU__c;
        this.invoiceID = currentRow.Invoice_Line__c;
        this.Return_Qty__c = currentRow.Return_Qty__c;
        this.UnitPrice__c = currentRow.UnitPrice__c;
    }

    closeDeleteModal(){
        this.deleteModal = false;
    }

    popDeleteModal(){
        this.deleteClearAll = true;
        this.deleteModal = true;
        this.deleteFromRow = false;
    }

   async  deleteCurrentRecord(currentRow){
    this.deleteModal = false;
    this.isRemoving = true;
      console.log('Invoice Line to be Updated: '+this.invoiceID);
      const deduction = (this.Return_Qty__c * this.UnitPrice__c);
    await  deleteRecord (this.returnItemId)
       .then(() => {
           updateInvoiceLines({lines : this.invoiceID})
           .then(result => {
               this.fetchUpdatedLines();
           console.log('INVOICE LINES RESET....'+result);
           });
           this.dispatchEvent(
               new ShowToastEvent({
                   title: 'Success',
                   message: 'Cart has been cleared',
                   variant: 'success'
               })
           );          
                this.fetchReturnItems(deduction);
       })
  }

   async clearCart(event){
    this.deleteModal = false;
    this.isRemoving = true;
    for(var i = 0, len = this.storedLines.length; i < len; i++){
        await deleteRecord (this.storedLines[i].Id)
         .then(() => {
 
                 this.fetchReturnItems();
 
         })
         await updateInvoiceLines({lines : this.linesToUpdate})
                 .then(result => {
                     this.fetchUpdatedLines();
                 console.log('INVOICE LINES RESET....'+result);
                 });
         this.dispatchEvent(
             new ShowToastEvent({
                 title: 'Success',
                 message: 'Line has been deleted from the cart',
                 variant: 'success'
             })
         );
     }
   }

   //------------------------------------------------------------------------------------------ END OF CART FUNCTIONS -------------------------------------------------------------------------------------------------------

    
//RETURN/REPLACE, OVERAGE, SHORTAGE, LOST & DAMAGE ATTRIBUTES AND FUNCTIONS
    @track isOverage = false;
    @track isLostDamaged = false;
    @track isLoading = false;
    @track isAdding = false;
    @track notDistributor = true;
    @track searchButtonDisabled = true;
    @track noSoldTo = false;
    @track searchDisabled = true;
    @track accountSearchDisabled = false;
    @track bShowModal1 = false;
    @track transactionTotal = 0.00;
    @track removeMOQ;
    @track minOrderQty;
    @track setRequired;
    @track errorMessage;
    @track rowQuantity;
    @track rowAvailForReturn;
    @track linesItemNewList;
    @track shrinkWrapped;

    @api setVisibility(type){
        if(type === "Agent"){
            this.notDistributor = true;
            this.searchDisabled = true;
            this.setRequired = true;
        } else {
            this.notDistributor = false;
            this.searchDisabled = false;
            this.setRequired = false;
        }
    }
    
    @api setAction(action){
        this.action = action;
        console.log('Action set by Header: '+this.action);

        
        console.log('Current State of MOQ Attribute: '+this.removeMOQ);
        if((this.caseType == "Overage" && this.action == "Credit") || (this.caseType == "Credit" && this.action == "Credit") || (this.caseType == "Shortage" && this.action == "Credit")  || (this.caseType == "Lost/Damaged" && this.action == "Credit")){
            this.removeMOQ = true;
        } else {
            this.removeMOQ = false;
        }
        console.log('State of MOQ Attribute AFTER Logic: '+this.removeMOQ);
    }

    get SROptions() {
        return [
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No' }, 
        ];
    }

    handleDisputeChange(e){
        this.errorMessage = '';
        
    }

    handleSRChange(event){
        this.shrinkWrapped = event.target.value;
        console.log('Shrink Wrapped: '+this.shrinkWrapped);
        
    }

    handleActionChange(event){
        let action = event.target.value;
       
        if((this.caseType == "Overage" && action == "Credit") || (this.caseType == "Credit" && action == "Credit") || (this.caseType == "Shortage" && action == "Credit") || (this.caseType == "Lost/Damaged" && action == "Credit")){
            this.removeMOQ = true;
        } else {
            this.removeMOQ = false;
        }
        console.log('State of MOQ Attribute AFTER Logic: '+this.removeMOQ);
    }

    
// handleing record edit form submit
    handleSubmit(event) {
        this.isAdding = true;
        let returnQty = this.template.querySelector('.dq').value;
        console.log('Return Qty: '+returnQty);
        console.log('Row Quantity: '+this.rowQuantity);
        console.log('Available for Return: '+this.rowAvailForReturn);
        const isInputsCorrect = [...this.template.querySelectorAll('.formData')]
                .reduce((validSoFar, inputField) => {
                    inputField.reportValidity();
                    return validSoFar && inputField.checkValidity();
                    
                }, true);
            if (isInputsCorrect) {
            //perform success logic
                console.log('VALID INCREMENT....');
            


                if(this.caseType != "Overage"){
                        if(this.rowReturnTotal = 0 && returnQty > this.rowQuantity){
                            this.isAdding = false;
                        event.preventDefault();
                        this.errorMessage = "ERROR: Dispute Quantity cannot be more than the Order Quantity:  "+this.rowQuantity;
                        this.cartLabel = "Add to Request";

                        }else if (this.rowAvailForReturn > 0 && returnQty > this.rowAvailForReturn){
                            this.isAdding = false;
                        event.preventDefault();
                        this.errorMessage = "ERROR: Dispute Quantity cannot be more than Available for Return of "+this.rowAvailForReturn;
                        this.cartLabel = "Add to Request";
                        }else if (this.rowAvailForReturn == 0 && returnQty > 0) {
                            this.isAdding = false;
                        event.preventDefault();
                        this.errorMessage = "ERROR: You have returned the maximum number allowed";
                        this.cartLabel = "Add to Request";
                        }else {
                        this.errorMessage = "";
                    
                    this.cartLabel = "Adding to Request...";
                    // prevending default type sumbit of record edit form
                    //event.preventDefault();

                    // querying the record edit form and submiting fields to form
                    console.log('Inbuilt Form Data Check: ' + JSON.stringify(event.detail.fields));
                    //this.template.querySelector('lightning-record-edit-form').submit(event.detail.fields);
                    const recordInputs = event.detail.fields.slice().map(draft=>{
                        const fields = Object.assign({}, draft)
                        return {fields}
                    })
                    console.log("recordInputs", recordInputs)

                    const promises = recordInputs.map(recordInput => updateRecord(recordInput))
                    Promise.all(promises).then(result=>{
                        //this.ShowToastMsg('Success', 'Order Details Updated')
                    // this.draftValues=[];   
                    // console.log('Before Refresh: '+ JSON.stringify(this.orderItemList));
                    // console.log('Check for Refresh: '+ this.selectedOrder);

                    // showing success message
                    
                    }).catch(error=>{
                        this.cartLabel = "Add to Request";
                        this.ShowToastMsg('Error Updating Records', error.body.message, error)
                        
                    });
                    }
                } else {
                    this.errorMessage = "";

                this.cartLabel = "Adding to Request...";
                // prevending default type sumbit of record edit form
                //event.preventDefault();

                // querying the record edit form and submiting fields to form
                console.log('Inbuilt Form Data Check: ' + JSON.stringify(event.detail.fields));
                //this.template.querySelector('lightning-record-edit-form').submit(event.detail.fields);
                const recordInputs = event.detail.fields.slice().map(draft=>{
                    const fields = Object.assign({}, draft)
                    return {fields}
                })
                console.log("recordInputs", recordInputs)

                const promises = recordInputs.map(recordInput => updateRecord(recordInput))
                Promise.all(promises).then(result=>{
                    //this.ShowToastMsg('Success', 'Order Details Updated')
                // this.draftValues=[];   
                // console.log('Before Refresh: '+ JSON.stringify(this.orderItemList));
                // console.log('Check for Refresh: '+ this.selectedOrder);

                // showing success message

                }).catch(error=>{
                    this.cartLabel = "Add to Request";
                    this.ShowToastMsg('Error Updating Records', error.body.message, error)
                    
                });
                }

        } else {
            console.log('INVALID INCREMENT....');
            this.isAdding = false;
            event.preventDefault();
            this.cartLabel = "Add to Request";
            this.errorMessage = 'You must enter in increments of ' + this.minOrderQty;
        }

        

    }



// refreshing the datatable after record edit form success
    async handleSuccess() {
        let tempId = this.currentRecordId;
        let reqOver = this.template.querySelector('.op').value;
        let returnAmount = this.template.querySelector('.dq').value;
        let updateInvLine = {'sobjectType': 'GE_LGT_EM_InvoiceLineItem__c'};
        updateInvLine.Id = tempId;
        updateInvLine.Requested_Action_Override__c = reqOver;
        updateInvLine.GE_LGT_EM_DisputeCount__c = returnAmount;
        await updateInvItem({data : updateInvLine})
        .then(result => {
            console.log('Item Modified');
        })

        
        this.linesToUpdate.push(tempId);
        console.log('Lines to Update ARRAY: '+this.linesToUpdate);
        await findInvLineRecords({searchKey: this.searchKey, objectName: this.objectApiName, filterField: this.filterFieldName}) 
        .then(result => {
            this.tempList = [];
            if(result){
                this.hasLines = true;
                if(this.caseType == "Credit" || this.caseType === 'Overage' || this.caseType === 'Shortage' || this.caseType === 'Lost/Damaged' || this.caseType === 'Warranty'){
                    console.log('JSON RESULTS: '+JSON.stringify(result));
                    this.tempList = result.map(item=>{
                        const tempNumber = item.GE_LGT_EM_Order_Number__c;
                        let newNumber = tempNumber.replace(/^0+/, "");
                        //console.log('Material Supply Chain Status: '+item.GE_LGT_EM_Material__r.GE_LGT_EM_Distribution_Chain_Status__c);
                        //let chainStatus = item.GE_LGT_EM_Material__r.GE_LGT_EM_Distribution_Chain_Status__c;
                        //let cellColor = item.Available_for_Return__c == 0  ? "slds-text-color_error":"slds-text-color_default"
                        let buttonColor = item.Available_for_Return__c > 0 ? "brand":"brand-inverse"
                        let textColor = item.Available_for_Return__c == 0 ? "slds-text-color_error":"slds-text-color_default"
                        let iconName = item.Available_for_Return__c == 0 ? "utility:lock":"utility:new"
                        let rowIcon = item.Available_for_Return__c == 0 ? "utility:lock":""
                        let iconTitle = item.Available_for_Return__c == 0 ? "Return Depleted":""
                        let actionDisabled = item.Available_for_Return__c == 0 ? true:false
                        return {...item, 
                            "actionDisabled":actionDisabled,
                            "iconName":iconName,
                            "textColor":textColor,
                            //"cellColor":cellColor,
                            'buttonColor':buttonColor,
                            'rowIcon': rowIcon,
                            'iconTitle':iconTitle,
                            'newNumber': newNumber
                        }
                    });
                } else if (this.caseType === 'Return' || this.caseType === 'Return/Replace'){
                    console.log('JSON RESULTS: '+JSON.stringify(result));
                    this.tempList = result.map(item=>{
                        const tempNumber = item.GE_LGT_EM_Order_Number__c;
                        let newNumber = tempNumber.replace(/^0+/, "");
                        console.log('Material Supply Chain Status: '+item.GE_LGT_EM_Material__r.GE_LGT_EM_Distribution_Chain_Status__c);
                        //let chainStatus = item.GE_LGT_EM_Material__r.GE_LGT_EM_Distribution_Chain_Status__c;
                        //let cellColor = item.Available_for_Return__c == 0  ? "slds-text-color_error":"slds-text-color_default"
                    let buttonColor = (item.Available_for_Return__c > 0 && item.GE_LGT_EM_Material__r.GE_LGT_EM_Distribution_Chain_Status__c == '02') ? "brand":"brand-inverse"
                    let textColor = (item.Available_for_Return__c == 0 || item.GE_LGT_EM_Material__r.GE_LGT_EM_Distribution_Chain_Status__c != '02' ) ? "slds-text-color_error":"slds-text-color_default"
                    let iconName = (item.Available_for_Return__c == 0 || item.GE_LGT_EM_Material__r.GE_LGT_EM_Distribution_Chain_Status__c != '02' ) ? "utility:lock":"utility:new"
                    let rowIcon = (item.Available_for_Return__c == 0 || item.GE_LGT_EM_Material__r.GE_LGT_EM_Distribution_Chain_Status__c != '02' ) ? "utility:lock":""
                    let iconTitle = (item.Available_for_Return__c == 0 || item.GE_LGT_EM_Material__r.GE_LGT_EM_Distribution_Chain_Status__c != '02' )? "Return Depleted":""
                    let actionDisabled = (item.Available_for_Return__c == 0 || item.GE_LGT_EM_Material__r.GE_LGT_EM_Distribution_Chain_Status__c != '02' ) ? true:false
 
                        return {...item, 
                            "actionDisabled":actionDisabled,
                            "iconName":iconName,
                            "textColor":textColor,
                            //"cellColor":cellColor,
                            'buttonColor':buttonColor,
                            'rowIcon': rowIcon,
                            'iconTitle':iconTitle,
                            'newNumber':newNumber
                        }
                    });
                }

                //this.tempList.push(clone);
              this.invLines = this.tempList;

              this.totalRecountCount = result.length;
              this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize); //here it is 5
                  
                  //initital data to be displayed ----------->
                  //slice will take 0th element and ends with 5, but it doesn't include 5th element
                  //so 0 to 4th rows will be display in the table
                  this.data = this.invLines.slice(0,this.pageSize); 
                  var inputData = {
                    totalPages:this.totalPage
                };
                this.template.querySelector("c-paginator").setButtons(inputData);
                  this.endingRecord = this.pageSize;
                  //this.columns = columns;
                  this.error = undefined;
              window.console.log(JSON.stringify(result, null, '\t'));
              window.console.log(result.id);
              result.forEach(function (item, key) {
                  window.console.log('Key: '+key); 
                  window.console.log('Item: '+item); 
              });



              console.log(result);
              console.log('After refresh datatable data: ' + JSON.stringify(this.invLines));
              //this.ShowToastMsg('Success', 'Order Details Updated')
               // closing modal
               this.bShowModal1 = false;
               this.dispatchEvent(
                new CustomEvent('modifylines', {
                    detail: {
                       lineId  : this.linesToUpdate
                    }
                }));
            }
        });
                
            this.handleClick(); 
    }

    async handleClick( event ){

        //const updatedFields = event.detail.draftValues;

        await getInvLineNewList({transId: this.currentRecordId}) 
        .then(result => {
            this.linesItemNewList = result;
            console.log(result);
            console.log('Value passed from Apex for currentrow: ' + JSON.stringify(this.linesItemNewList));
        });
    //var selRows = this.template.querySelector('lightning-datatable');
        var selected = this.linesItemNewList;
        console.log('Edit Row: '+ JSON.stringify(selected));
        //console.log('Values for EDIT: '+this.draftValues);
        //this.storedLines = selected;
        console.log('Stored Lines: '+ JSON.stringify(this.storedLines));
        console.log('Order Number before Conversion: '+this.currentRecordOrder);
        this.oldTempNumber = this.oldOrderNumber;
        const tempNumber = this.currentRecordOrder;
        let newNumber = tempNumber.replace(/^0+/, "");
        this.oldOrderNumber = newNumber;
        console.log('Order Number after Conversion '+newNumber);
        
        console.log('COMPARING ORDER NUMBERS: OLD = '+this.oldTempNumber+ ' <--> NEW = '+newNumber);

        if(newNumber != this.oldTempNumber || newNumber != undefined){
            await getOrderId({orderNumber: newNumber})
            .then(result=>{
                if(result != ''){
                this.orderId = result[0].Id;
                let orderAgent = result[0].Agent_Account__c;
                console.log('ORDER AGENT ID: '+result[0].Agent_Account__c);
                this.dispatchEvent(
                    new CustomEvent('orderretrieved', {
                        detail: {
                            orderId : this.orderId,
                            orderAgent : orderAgent
                        }
                    }));
                } else {
                    this.orderId = '';
                }
            })
        }
        console.log('SENDING DISTRIBUTOR ID FOR RETURN ORDER ITEM: '+this.selectedDistributorID);

        var newselval = selected.map(row => { return { "Price_Agreement__c": row.Price_Agreement__c, "SFDC_Invoice__c": row.GE_LGT_EM_InvoiceHeaderNumber__c,"order__c": this.orderId, "Invoice_Line__c": row.Id, "Product_SKU__c": row.GE_LGT_EM_Material_Description__c, "PO__c": row.GE_LGT_EM_Customer_PO_Number__c, "Quantity__c": row.GE_LGT_EM_Invoiced_Quantity__c, "UnitPrice__c": row.GE_LGT_EM_Invoiced_Price__c,
            /*"Quick_Configure__c":row.Quick_Configure__c,*/"Quick_Stock__c":row.QuickStock__c, "SKU__c":row.SKU__c, "Type__c":this.caseType, "UnitOfMeasure__c": row.GE_LGT_EM_Sales_Unit__c, "Material__c": row.GE_LGT_EM_Material__c,
            "Shipment_Date__c":row.Shipment_Date__c,"Return_Qty__c": row.GE_LGT_EM_DisputeCount__c,"Requested_Action_Override__c":row.Requested_Action_Override__c, "Request_Action__c": this.headerAction,
            "Transaction_ID__c": this.transactionID, "Unique_ID__c": this.transactionID+'_'+row.GE_LGT_EM_SAP_Invoice_Number__c+'_'+row.GE_LGT_EM_SAP_LineItemNumber__c+'_'+row.SKU__c, "Distributor_Name__c":this.selectedSoldToAccountName, "Distributor_Id__c":this.selectedDistributorID, "Is_the_product_shrink_wrapped__c": this.shrinkWrapped

            }});

        
        
        this.valuetopass = selected;
        console.log('value to pass check:' + JSON.stringify(this.valuetopass));
        
        console.log('value to pass check:' + JSON.stringify(newselval));
        await updateReturnItemList({data: newselval})
        .then(result => {
            this.isLoading = false;
            console.log(JSON.stringify("Apex update result: "+ result));
            this.flagIndi= true;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Records added to the cart successfully',
                    variant: 'success'
                })
            );
            this.fetchReturnItems();
        });

    }

   async fetchUpdatedLines(){
        await  findInvLineRecords({searchKey: this.searchKey, objectName: this.objectApiName, filterField: this.filterFieldName})
        /*.then(result => {
            this.invLines = result;
        console.log(JSON.stringify("Lines Returned:  "+ JSON.stringify(this.invLines)));
        });*/
        .then(result => {
          this.tempList = [];
          if(result){
            this.hasLines = true;
            if(this.caseType == "Credit" || this.caseType === 'Overage' || this.caseType === 'Shortage' || this.caseType === 'Lost/Damaged' || this.caseType === 'Warranty'){
              console.log('JSON RESULTS: '+JSON.stringify(result));
              this.tempList = result.map(item=>{
                const tempNumber = item.GE_LGT_EM_Order_Number__c;
                let newNumber = tempNumber.replace(/^0+/, "");
                  //console.log('Material Supply Chain Status: '+item.GE_LGT_EM_Material__r.GE_LGT_EM_Distribution_Chain_Status__c);
                  //let chainStatus = item.GE_LGT_EM_Material__r.GE_LGT_EM_Distribution_Chain_Status__c;
                  //let cellColor = item.Available_for_Return__c == 0  ? "slds-text-color_error":"slds-text-color_default"
                  let buttonColor = item.Available_for_Return__c > 0 ? "brand":"brand-inverse"
                  let textColor = item.Available_for_Return__c == 0 ? "slds-text-color_error":"slds-text-color_default"
                  let iconName = item.Available_for_Return__c == 0 ? "utility:lock":"utility:new"
                  let rowIcon = item.Available_for_Return__c == 0 ? "utility:lock":""
                  let iconTitle = item.Available_for_Return__c == 0 ? "Return Depleted":""
                  let actionDisabled = item.Available_for_Return__c == 0 ? true:false
                  return {...item, 
                      "actionDisabled":actionDisabled,
                      "iconName":iconName,
                      "textColor":textColor,
                      //"cellColor":cellColor,
                      'buttonColor':buttonColor,
                      'rowIcon': rowIcon,
                      'iconTitle':iconTitle,
                      'newNumber':newNumber
                  }
              });
          } else if (this.caseType === 'Return' || this.caseType === 'Return/Replace'){
              console.log('JSON RESULTS: '+JSON.stringify(result));
              this.tempList = result.map(item=>{
                const tempNumber = item.GE_LGT_EM_Order_Number__c;
                let newNumber = tempNumber.replace(/^0+/, "");
                  console.log('Material Supply Chain Status: '+item.GE_LGT_EM_Material__r.GE_LGT_EM_Distribution_Chain_Status__c);
                  //let chainStatus = item.GE_LGT_EM_Material__r.GE_LGT_EM_Distribution_Chain_Status__c;
                  //let cellColor = item.Available_for_Return__c == 0  ? "slds-text-color_error":"slds-text-color_default"
                 let buttonColor = (item.Available_for_Return__c > 0 && item.GE_LGT_EM_Material__r.GE_LGT_EM_Distribution_Chain_Status__c == '02') ? "brand":"brand-inverse"
                    let textColor = (item.Available_for_Return__c == 0 || item.GE_LGT_EM_Material__r.GE_LGT_EM_Distribution_Chain_Status__c != '02' ) ? "slds-text-color_error":"slds-text-color_default"
                    let iconName = (item.Available_for_Return__c == 0 || item.GE_LGT_EM_Material__r.GE_LGT_EM_Distribution_Chain_Status__c != '02' ) ? "utility:lock":"utility:new"
                    let rowIcon = (item.Available_for_Return__c == 0 || item.GE_LGT_EM_Material__r.GE_LGT_EM_Distribution_Chain_Status__c != '02' ) ? "utility:lock":""
                    let iconTitle = (item.Available_for_Return__c == 0 || item.GE_LGT_EM_Material__r.GE_LGT_EM_Distribution_Chain_Status__c != '02' )? "Return Depleted":""
                    let actionDisabled = (item.Available_for_Return__c == 0 || item.GE_LGT_EM_Material__r.GE_LGT_EM_Distribution_Chain_Status__c != '02' ) ? true:false

                  return {...item, 
                      "actionDisabled":actionDisabled,
                      "iconName":iconName,
                      "textColor":textColor,
                      //"cellColor":cellColor,
                      'buttonColor':buttonColor,
                      'rowIcon': rowIcon,
                      'iconTitle':iconTitle,
                      'newNumber':newNumber
                  }
              });
          }
  
            //this.tempList.push(clone);
          this.invLines = this.tempList;
  
          this.totalRecountCount = result.length;
          this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize); //here it is 5
              
              //initital data to be displayed ----------->
              //slice will take 0th element and ends with 5, but it doesn't include 5th element
              //so 0 to 4th rows will be display in the table
              this.data = this.invLines.slice(0,this.pageSize); 
              var inputData = {
                totalPages:this.totalPage
            };
            this.template.querySelector("c-paginator").setButtons(inputData);
              this.endingRecord = this.pageSize;
              //this.columns = columns;
              this.error = undefined;
          window.console.log(JSON.stringify(result, null, '\t'));
          window.console.log(result.id);
          result.forEach(function (item, key) {
              window.console.log('Key: '+key); 
              window.console.log('Item: '+item); 
          });
  
  
  
          console.log(result);
          console.log('After refresh datatable data: ' + JSON.stringify(this.invLines));
          //this.ShowToastMsg('Success', 'Order Details Updated')
           // closing modal
           this.bShowModal1 = false;
           this.dispatchEvent(
            new CustomEvent('modifylines', {
                detail: {
                   lineId  : this.linesToUpdate
                }
            }));
        }
      });
    
    }
    
 //------------------------------------------------------------------------------------------ END OF RETURN, REPLACE, SHIPPING ISSUES -------------------------------------------------------------------------------------------------------   
    
    
//WARRANTY CLAIM ATTRIBUTES AND FUNCTIONS
   
    @track warrantyData = [];
    @api codeOptions;
    @api subCodeOptions;
    @track NoCAT = " ";
    @track isLoading = false;
    @track isAdding = false;
    @track noCatInput = false;
    @track noCatModal = false;
    @track editProductModal = false;
    @track reqAction;
    @track numFailed;
    @track setNumberFailed;
    @track numInstalled;
    @track dateInstalled;
    @track PO;
    @track warSubCode;
    @track shipmentDate;
    @track hoursUsed;
    @track hoursPerStart
    @track comments;
    @track warSubOptions;
    @track warrantyReason;
    @track priceAgrmtPrice;
    @track isWarranty = false;
    @track manualLines = [];
    @track materialID;
    @track materialDescription;
    @track selectedMaterial;
    @track warrantyEdit = false;
    @track manualDisabled = true;
    @track actionReason;
    //@api siteAddress;
    
    
    @track warSubOptionsControl =
    [
        { label: 'Dimming Issue', value: 'Dimming Issue' },
        { label: 'Network Connection Error', value: 'Network Connection Error'},
        { label: 'Sensor Failure', value: 'Sensor Failure' },
    ];


    @track warSubOptionsElectrical =
        [
            { label: 'Connector Failure', value: 'Connector Failure' },
            { label: 'Failed Driver', value: 'Failed Driver' },
            { label: 'Failed on Initial Energize', value: 'Failed on Initial Energize' },
            { label: 'Inoperative', value: 'Inoperative' },
            { label: 'Intermittent Operation', value: 'Intermittent Operation' },
            { label: 'LED Failure', value: 'LED Failure' },
            { label: 'Pinched Wire', value: 'Pinched Wire' },
            { label: 'Surge Protector Failed', value: 'Surge Protector Failed' },
            { label: 'Transformer Failure', value: 'Transformer Failure' },
            { label: 'Wiring Error', value: 'Wiring Error' },
        ];


    @track warSubOptionsLightOutput =
        [
            { label: 'Color Objection', value: 'Color Objection' },
            { label: 'Color Shift', value: 'Color Shift'},
            { label: 'Flicker', value: 'Flicker' },
            { label: 'Low Light Levels', value: 'Low Light Levels' },
        ];


    @track warSubOptionsMechanical =
        [
            { label: 'Assembly Defect', value: 'Color Objection' },
            { label: 'Component - Missing', value: 'Component - Missing'},
            { label: 'Component - Loose', value: 'Component - Loose' },
            { label: 'Finish/Paint Issue', value: 'Finish/Paint Issue' },
            { label: 'Lens/Diffuser - Loose', value: 'Lens/Diffuser - Loose' },
            { label: 'Other Cosmetic Issue', value: 'Other Cosmetic Issue' },
            { label: 'Water Entry', value: 'Water Entry' },
        ];

    @track warSubOptionsPackaging =
        [
            { label: 'Label Incorrect', value: 'Label Incorrect' },
            { label: 'Packaging Quality', value: 'Packaging Quality'},
            { label: 'Wrong Part in Carton', value: 'Wrong Part in Carton' },
        ];

    @track warSubOptionsSafety =
        [
            { label: 'Burnt/Overheated', value: 'Burnt/Overheated' },
            { label: 'Fallen Component/Fixture', value: ''},
            { label: 'Shock', value: 'Wrong Part in Carton' },
        ];

        handleValueChange(e){
            this.errorMessage = '';
            this.numInstalled = e.detail.value;
        }
        
        handleFailedValueChange(e){
            


            this.errorMessage = '';
            var failed = e.detail.value;
            if (failed < 100){
                this.numFailed = "0"+failed;
            } else{
            this.numFailed = failed;
            }
            console.log('Failed Converted: '+this.numFailed);
        }
        
        handleWarrantyRowActions(event) {
            
            const actionName = event.detail.action.name;
            const row = event.detail.row;
            
            let rowQuantityValue = event.detail.row.Quantity;
            console.log('The Row Quantity: '+rowQuantityValue);
        
            this.rowQuantity = rowQuantityValue;
            console.log('Row QTY Set: '+this.rowQuantity);
        
            console.log('Delete ActionName: '+ actionName);
            console.log('Delete Row: '+ JSON.stringify(row));
            switch (actionName) {
                case 'edit':
                    this.editWarrantyCurrentRecord(row);
                    break;
                case 'delete':
                    this.deleteManualRow(row);
                    break;
                case 'show_details':
                    this.showRowDetails(row);
                    break;
                default:
            }
        }
        
         // view the current record details
         viewCurrentRecord(currentRow) {
            this.warrantyEdit = true;
            this.isEditForm = false;
            this.record = currentRow;
        }
        
        // closing modal box
        closeWarrantyModal() {
            this.warrantyEdit = false;
        }
        
        //CLOSE EDIT MODAL
        closeEditModal() {
            this.editProductModal = false;
        }
        
        editWarrantyCurrentRecord(currentRow) {
            // open modal box
            this.errorMessage = "";
            this.warrantyEdit = true;
            this.isEditForm = true;
            this.currentRecordOrder = currentRow.GE_LGT_EM_Order_Number__c;
            if(currentRow.Installed_Qty__c > 0){
                this.editLabel = "Update"
            } else {
                this.editLabel = "Add to Claim"
            }
        
            // assign record id to the record edit form
            this.currentRecordId = currentRow.Id;
            this.reqAction = currentRow.Requested_Action_Override__c;
            this.numInstalled = currentRow.Installed_Qty__c;
                console.log('Row Installed Qty: '+this.numInstalled);
            this.numFailed = currentRow.No_Of_Products_Failed__c;
                console.log('Row Number Failed: '+this.numFailed);
            /*this.hoursUsed = currentRow.No_of_Hours_Used__c;
                console.log('Row Hours Used: '+this.hoursUsed);
            this.hoursPerStart = currentRow.Hours_per_Start__c;
                console.log('Row Hours Per Start: '+this.hoursPerStart);*/
            this.dateInstalled = currentRow.Date_Installed__c;
                console.log('Row Date Installed: '+this.dateInstalled);
            this.comments = currentRow.Comment__c;
                console.log('Row Comments: '+this.comments);
            this.warCode = currentRow.Warranty_Code__c;
                console.log('Row Warranty Code: '+this.warCode);
            this.warSubCode = currentRow.Warranty_Sub_Code__c;
                console.log('Row Warranty Sub Code: '+this.warSubCode);
            /*this.priceAgrmtPrice = currentRow.Price_Agreement_Price__c;
                console.log('Row Price Agreement Price: '+this.priceAgrmtPrice);*/
        
        }
        
        
         // handleing record edit form submit
         handleWarrantySubmit(event) {
            console.log('HANDLE SUBMIT FUNCTION EXECUTED...');
            this.isLoading = true;
            //this.numFailed = this.template.querySelector('.nf').value;
                //console.log('Number Failed: '+this.numFailed);
            this.numInstalled = this.template.querySelector('.iq').value;
                console.log('Number Installed: '+this.numInstalled);

            /*this.hoursUsed = this.template.querySelector('.hu').value;
                console.log('Hours Used: '+this.hoursUsed);
            this.hoursPerStart = this.template.querySelector('.hs').value;
                console.log('Hours Per Start: '+this.hoursPerStart);*/
            this.dateInstalled = this.template.querySelector('.di').value;
                console.log('Date Installed'+this.dateInstalled);
            this.comments = this.template.querySelector('.cm').value;
                console.log('Comments: '+this.comments);
            this.warCode = this.template.querySelector('.wc').value;
                console.log('Warranty Code: '+this.warCode);
            this.warSubCode = this.template.querySelector('.wsc').value;
                console.log('Warranty Sub Code: '+this.warSubCode);
            this.reqAction = this.template.querySelector('.ra').value;
                console.log('Requested Action: '+this.reqAction);
            /*this.priceAgrmtPrice = this.template.querySelector('.pa').value;
                console.log('Price Agreement Price: '+this.priceAgrmtPrice);*/
        
            
            
            let installedQty = this.numInstalled;
            console.log('Installed Qty Entered: '+installedQty);
            let failedQty = this.numFailed;
            this.setNumberFailed = this.numFailed;
            console.log('Failed Qty Entered: '+failedQty);
            console.log('Quantity Imported: '+this.rowQuantity);
           if (failedQty > this.rowQuantity){
            this.isLoading = false;
               this.errorMessage = "ERROR: Number of Failed Products cannot be greater than Order Quantity";
               console.log('Error: '+this.errorMessage);
               this.cartLabel = "Add to Claim";
               event.preventDefault();
               //this.ShowToastMsg('# of Filed Products cannot be greater than Installed Qty');
           }else if (failedQty > installedQty){
            this.isLoading = false;
            this.errorMessage = "ERROR: Number of Failed Products cannot be greater than Installed Quantity";
            console.log('Error: '+this.errorMessage);
            this.cartLabel = "Add to Claim";
            event.preventDefault();
            //this.ShowToastMsg('# of Filed Products cannot be greater than Installed Qty');
            } else if(installedQty > this.rowQuantity){
                this.isLoading = false;
                this.errorMessage = "ERROR: Installed Quantity cannot be greater than Order Quantity";
                console.log('Error: '+this.errorMessage);
                this.cartLabel = "Add to Claim";
                event.preventDefault();
           }else {
            this.errorMessage = "";
            console.log('No Errors in Form');
            this.cartLabel = "Adding to Claim...";
            // prevending default type sumbit of record edit form
            //event.preventDefault();
        
            //querying the record edit form and submiting fields to form
            console.log('Inbuilt Form Data Check: ' + JSON.stringify(event.detail.fields));
            const fields = event.detail.fields;
            fields.No_Of_Products_Failed__c= this.numFailed;
            fields.Installed_Qty__c = this.numInstalled;
            //fields.No_of_Hours_Used__c = this.hoursUsed;
            //fields.Hours_per_Start__c = this.hoursPerStart;
            fields.Date_Installed__c = this.dateInstalled;
            fields.Comments__c = this.comments;
            fields.Warranty_Code__c = this.warCode;
            fields.Warranty_Sub_Code__c = this.warSubCode;
            fields.Requested_Action_Override__c= this.reqAction;
            //fields.Price_Agreement_Price__c = this.priceAgrmtPrice;
            fields.Id=this.currentRecordId;
            this.template.querySelector('lightning-record-edit-form').submit(fields);
            console.log('After Form Update Data Check: ' + JSON.stringify(event.detail.fields));
           }
        }
         
         
        
        // refreshing the datatable after record edit form success
        async handleWarrantySuccess() {
            console.log('HANDLE WARRANTY SUCCESS FUNCTION EXECUTED...');
            //let reqOver = this.template.querySelector('.dm').value;
            console.log('Success for Requested Action: '+this.reqAction);
            console.log('Success for Failed Products: '+this.setNumberFailed);
            console.log('Success for Installed Qty: '+this.numInstalled);
            console.log('Success for Date Installed: '+this.dateInstalled);
            console.log('Success for Code: '+this.warCode);
            console.log('Success for Sub Code: '+this.warSubCode);
            let tempId = this.currentRecordId;
            let reqOver = this.template.querySelector('.ra').value;
            let comments = this.template.querySelector('.cm').value;
        
            let updateInvLine = {'sobjectType': 'GE_LGT_EM_InvoiceLineItem__c'};
            updateInvLine.Id = tempId;
            updateInvLine.Installed_Qty__c = this.numInstalled;
            updateInvLine.No_Of_Products_Failed__c = this.numFailed;
            updateInvLine.Date_Installed__c = this.dateInstalled;
            updateInvLine.Comment__c = comments;
            updateInvLine.Requested_Action_Override__c = reqOver;
                await updateInvItem({data : updateInvLine})
                .then(result => {
                    console.log('Item Modified');
                })
            this.linesToUpdate.push(tempId);
            console.log('Lines to Update ARRAY: '+this.linesToUpdate);
        
            await findInvLineRecords({searchKey: this.searchKey, objectName: this.objectApiName, filterField: this.filterFieldName}) 
                    .then(result => {
                    
                    if(result){
                    this.hasLines = true;
                    
                    if(this.caseType == "Credit" || this.caseType === 'Overage' || this.caseType === 'Shortage' || this.caseType === 'Lost/Damaged' || this.caseType === 'Warranty'){
                        console.log('JSON RESULTS: '+JSON.stringify(result));
                        this.tempList = result.map(item=>{
                            const tempNumber = item.GE_LGT_EM_Order_Number__c;
                        let newNumber = tempNumber.replace(/^0+/, "");
                            //console.log('Material Supply Chain Status: '+item.GE_LGT_EM_Material__r.GE_LGT_EM_Distribution_Chain_Status__c);
                            //let chainStatus = item.GE_LGT_EM_Material__r.GE_LGT_EM_Distribution_Chain_Status__c;
                            //let cellColor = item.Available_for_Return__c == 0  ? "slds-text-color_error":"slds-text-color_default"
                            let buttonColor = item.Available_for_Return__c > 0 ? "brand":"brand-inverse"
                            let textColor = item.Available_for_Return__c == 0 ? "slds-text-color_error":"slds-text-color_default"
                            let iconName = item.Available_for_Return__c == 0 ? "utility:lock":"utility:new"
                            let rowIcon = item.Available_for_Return__c == 0 ? "utility:lock":""
                            let iconTitle = item.Available_for_Return__c == 0 ? "Return Depleted":""
                            let actionDisabled = item.Available_for_Return__c == 0 ? true:false
                            return {...item, 
                                "actionDisabled":actionDisabled,
                                "iconName":iconName,
                                "textColor":textColor,
                                //"cellColor":cellColor,
                                'buttonColor':buttonColor,
                                'rowIcon': rowIcon,
                                'iconTitle':iconTitle,
                                'newNumber':newNumber
                            }
                        });
                    } else if (this.caseType === 'Return' || this.caseType === 'Return/Replace'){
                        console.log('JSON RESULTS: '+JSON.stringify(result));
                        this.tempList = result.map(item=>{
                            const tempNumber = item.GE_LGT_EM_Order_Number__c;
                        let newNumber = tempNumber.replace(/^0+/, "");
                            console.log('Material Supply Chain Status: '+item.GE_LGT_EM_Material__r.GE_LGT_EM_Distribution_Chain_Status__c);
                            //let chainStatus = item.GE_LGT_EM_Material__r.GE_LGT_EM_Distribution_Chain_Status__c;
                            //let cellColor = item.Available_for_Return__c == 0  ? "slds-text-color_error":"slds-text-color_default"
                        let buttonColor = (item.Available_for_Return__c > 0 && item.GE_LGT_EM_Material__r.GE_LGT_EM_Distribution_Chain_Status__c == '02') ? "brand":"brand-inverse"
                        let textColor = (item.Available_for_Return__c == 0 || item.GE_LGT_EM_Material__r.GE_LGT_EM_Distribution_Chain_Status__c != '02' ) ? "slds-text-color_error":"slds-text-color_default"
                        let iconName = (item.Available_for_Return__c == 0 || item.GE_LGT_EM_Material__r.GE_LGT_EM_Distribution_Chain_Status__c != '02' ) ? "utility:lock":"utility:new"
                        let rowIcon = (item.Available_for_Return__c == 0 || item.GE_LGT_EM_Material__r.GE_LGT_EM_Distribution_Chain_Status__c != '02' ) ? "utility:lock":""
                        let iconTitle = (item.Available_for_Return__c == 0 || item.GE_LGT_EM_Material__r.GE_LGT_EM_Distribution_Chain_Status__c != '02' )? "Return Depleted":""
                        let actionDisabled = (item.Available_for_Return__c == 0 || item.GE_LGT_EM_Material__r.GE_LGT_EM_Distribution_Chain_Status__c != '02' ) ? true:false
                       
                            return {...item, 
                                "actionDisabled":actionDisabled,
                                "iconName":iconName,
                                "textColor":textColor,
                                //"cellColor":cellColor,
                                'buttonColor':buttonColor,
                                'rowIcon': rowIcon,
                                'iconTitle':iconTitle,
                                'newNumber':newNumber
                            }
                        });
                    }
    
                    //this.tempList.push(clone);
                  this.invLines = this.tempList;
                    
        
                    this.totalRecountCount = result.length;
                    this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize); //here it is 5
                        
                        //initital data to be displayed ----------->
                        //slice will take 0th element and ends with 5, but it doesn't include 5th element
                        //so 0 to 4th rows will be display in the table
                        
                        
                            this.data = this.invLines.slice(0,this.pageSize);
                            var inputData = {
                                totalPages:this.totalPage
                            };
                            //this.template.querySelector("c-paginator").setButtons(inputData);
                            if(this.totalRecountCount < this.pageSize){
                                this.endingRecord = this.totalRecountCount;
                            } else {
                            this.endingRecord = this.pageSize;
                            }
                        this.error = undefined;
                                window.console.log(JSON.stringify(result, null, '\t'));
                                window.console.log(result.id);
                                result.forEach(function (item, key) {
                        window.console.log('Key: '+key); 
                        window.console.log('Item: '+item); 
                    });
        
        
                    }
                console.log(JSON.stringify("Lines Returned:  "+ JSON.stringify(this.invLines)));
                this.isLoading = false;
                this.dispatchEvent(
                    new CustomEvent('modifylines', {
                        detail: {
                           lineId  : this.linesToUpdate
                        }
                    }));
                });
                this.warrantyEdit = false;
               this.handleWarrantyClick(); 
        }
        
        async handleWarrantyClick( event ){
            console.log('HANDLE CLICK FUNCTION EXECUTED....');
            //const updatedFields = event.detail.draftValues;
        
            await getInvLineNewList({transId: this.currentRecordId}) 
               .then(result => {
                   this.linesItemNewList = result;
                   console.log(result);
                   console.log('Value passed from Apex for currentrow: ' + JSON.stringify(this.linesItemNewList));
               });
           
            //var selRows = this.template.querySelector('lightning-datatable');
            var selected = this.linesItemNewList;
            console.log('Values for EDIT: '+ JSON.stringify(selected));
            //this.storedLines = selected;
            console.log('Stored Lines: '+ JSON.stringify(this.storedLines));
            console.log('Order Number before Conversion: '+this.currentRecordOrder);
            this.oldTempNumber = this.oldOrderNumber;
            const tempNumber = this.currentRecordOrder;
            let newNumber = tempNumber.replace(/^0+/, "");
            this.oldOrderNumber = newNumber;
            console.log('Order Number after Conversion '+newNumber);
            
            console.log('COMPARING ORDER NUMBERS: OLD = '+this.oldTempNumber+ ' <--> NEW = '+newNumber);
        
            if(newNumber != this.oldTempNumber || newNumber != undefined){
                await getOrderId({orderNumber: newNumber})
                .then(result=>{
                    if(result != ''){
                    this.orderId = result[0].Id;
                    let orderAgent = result[0].Agent_Account__c;
                    console.log('ORDER AGENT ID: '+result[0].Agent_Account__c);
                    this.dispatchEvent(
                        new CustomEvent('orderretrieved', {
                            detail: {
                                orderId : this.orderId,
                                orderAgent : orderAgent
                            }
                        }));
                    } else {
                        this.orderId = '';
                    }
                })
            }
            console.log('SENDING DISTRIBUTOR ID FOR RETURN ORDER ITEM: '+this.selectedDistributorID);
            var newselval = selected.map(row => { return { "SFDC_Invoice__c": row.GE_LGT_EM_InvoiceHeaderNumber__c,"order__c": this.orderId,"SKU__c": row.SKU__c, "Product_SKU__c":row.GE_LGT_EM_Material_Description__c,"PO__c": row.GE_LGT_EM_Customer_PO_Number__c, "Quantity__c": row.GE_LGT_EM_Invoiced_Quantity__c, "UnitPrice__c": row.GE_LGT_EM_Invoiced_Price__c,
                "Product_Name__c":row.Product_Name__c,"Quick_Configure__c":row.Quick_Configure__c,"Quick_Stock__c":row.Quick_Stock__c, "Type__c": "Warranty", "Request_Action__c": this.headerAction, "UnitOfMeasure__c": row.GE_LGT_EM_Sales_Unit__c,
                "Shipment_Date__c":row.Shipment_Date__c,"Installed_Qty__c": row.Installed_Qty__c,"No_Of_Products_Failed__c": row.No_Of_Products_Failed__c,"Date_Installed__c": row.Date_Installed__c, "Material__c": row.GE_LGT_EM_Material__c,
                "Requested_Action_Override__c":row.Requested_Action_Override__c,"Invoice_Line__c":row.Id, "Transaction_ID__c": this.transactionID, "Warranty_Code__c":row.Warranty_Code__c, "Warranty_Sub_Code__c":row.Warranty_Sub_Code__c, "No_of_Hours_Used__c":row.No_of_Hours_Used__c, "Hours_per_Start__c":row.Hours_per_Start__c, 
                "Price_Agreement_Price__c":row.Price_Agreement_Price__c, "Comments__c":row.Comment__c,"Unique_ID__c": this.transactionID+'_'+row.GE_LGT_EM_SAP_Invoice_Number__c+'_'+row.GE_LGT_EM_SAP_LineItemNumber__c+'_'+row.SKU__c,"Distributor_Name__c":row.Distributor_Name__c, "Distributor_Id__c": this.selectedDistributorID}});
        
            
            
            this.valuetopass = selected;
            console.log('value to pass check:' + JSON.stringify(this.valuetopass));
            
            console.log('value to pass check:' + JSON.stringify(newselval));
            await updateReturnItemList({data: newselval})
            .then(result => {
                
                console.log(JSON.stringify("Apex update result: "+ result));
                this.flagIndi= true;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Records added to the cart successfully',
                        variant: 'success'
                    })
                );
                this.fetchReturnItems();
        });
        
         }
        
        //------- MANUAL PRODUCT ENTRY FUNCTIONS -------
        
        handleManualRAction(event){
            this.actionReason = event.target.value;
            console.log('Action Reason :' +this.actionReason)
            /*if(this.actionReason == "Credit"){   
                this.paPrice = true;         
            } else {
                this.paPrice = false;
            }*/
        }
        
        handlePick(event){
            this.warrantyReason = event.target.value;
            console.log('Warranty Reason :' +this.warrantyReason)
            if(this.warrantyReason == "Control"){   
                console.log('warSubOptions: ')  ;
                this.warSubCode=this.warSubOptionsControl;  
                console.log('warSubOptions After: ' + JSON.stringify(this.warSubCode))  ;         
            }
            else if(this.warrantyReason == "Electrical"){   
                console.log('warSubOptions: ')  ;
                this.warSubCode=this.warSubOptionsElectrical;  
                console.log('warSubOptions After: ' + JSON.stringify(this.warSubCode))  ;         
            }
            else if(this.warrantyReason == "Light Output"){   
                console.log('warSubOptions: ')  ;
                this.warSubCode=this.warSubOptionsLightOutput;  
                console.log('warSubOptions After: ' + JSON.stringify(this.warSubCode))  ;         
            }
            else if(this.warrantyReason == "Mechanical"){   
                console.log('warSubOptions: ')  ;
                this.warSubCode=this.warSubOptionsMechanical;  
                console.log('warSubOptions After: ' + JSON.stringify(this.warSubCode))  ;         
            }
            else if(this.warrantyReason == "Packaging"){   
                console.log('warSubOptions: ')  ;
                this.warSubCode=this.warSubOptionsPackaging;  
                console.log('warSubOptions After: ' + JSON.stringify(this.warSubCode))  ;         
            }
            else{
                this.warSubCode=this.warSubOptionsSafety;  
            }
        }
        
        openNoCatModal(){
            this.addLabel = "Add to Claim";
            this.comments = '';
            this.noCatModal = true;
            this.noCatInput = false;
            this.value = '';
            this.numInstalled = null;
            this.numFailed = null;
            this.PO = '';
            this.shipmentDate = '';
            this.materialID = '';
            this.NoCAT = '';
            this.selectedMaterial = null;
            this.selectedMaterialDescription = null;
            this.selectedMaterialNumber = null;
        }
        
        
        onNoCatChange(){
            this.NoCAT = this.template.querySelector(".nc").value;
        }
        
        onPaPriceChange(){
            this.priceAgrmtPrice = this.template.querySelector(".pa").value;
        }
        
        closeNoCatModal(event){
            this.noCatModal = false;
            this.noCatInput = false;
        }
        
        closeEditModal() {
            this.editProductModal = false;
        }
        
        editManualCurrentRecord(currentRow) {
            this.errorMessage = '';
            console.log('LOADING CURRENT ROW RECORD AND SETTING VALUES...');
            // open modal box
            this.editLabel = "Update";
            this.isEditForm = true;
            this.editProductModal = true;
            // assign record id to the record edit form
            this.currentRecordId = currentRow.Id;
            this.reqAction = currentRow.Requested_Action_Override__c;
                console.log('Row Requested Action: '+this.reqAction);
            this.numInstalled = currentRow.Installed_Qty__c;
                console.log('Row Installed Qty: '+this.numInstalled);
            this.numFailed = currentRow.No_Of_Products_Failed__c;
                console.log('Row Number Failed: '+this.numFailed);
            /*this.hoursUsed = currentRow.No_of_Hours_Used__c;
                console.log('Row Hours Used: '+this.hoursUsed);
            this.hoursPerStart = currentRow.Hours_per_Start__c;
                console.log('Row Hours Per Start: '+this.hoursPerStart);*/
            this.dateInstalled = currentRow.Date_Installed__c;
                console.log('Row Date Installed: '+this.dateInstalled);
            this.comments = currentRow.Comments__c;
                console.log('Row Comments: '+this.comments);
            this.warCode = currentRow.Warranty_Code__c;
                console.log('Row Warranty Code: '+this.warCode);
            this.warSubCode = currentRow.Warranty_Sub_Code__c;
                console.log('Row Warranty Sub Code: '+this.warSubCode);
            /*this.priceAgrmtPrice = currentRow.Price_Agreement_Price__c;
                console.log('Row Price Agreement Price: '+this.priceAgrmtPrice);*/
            this.materialID = currentRow.Material__c;
                console.log('Row Material ID: '+this.materialID);
            if(currentRow.NoCAT__c != ''){
                this.handleNoCatChecked(e);
                this.NoCAT = currentRow.NoCAT__c;
                    console.log('Row No CAT: '+this.NoCAT);
            }
            
            
        }
        
        handleLoad(event) {
            if (!this.loadedForm) {
                let fields = Object.values(event.detail.records)[0].fields;
                
                console.log('Record ID SET: '+this.currentRecordId);
                this.returnOrderItemUpdate = {
                    Id: this.currentRecordId,
                    ...Object.keys(fields)
                        .filter((field) => !!this.template.querySelector(`[data-field=${field}]`))
                        .reduce((total, field) => {
                            total[field] = fields[field].value;
                            return total;
                        }, {})
                };
                this.loadedForm = true;
            }
        }
        
        handleFieldChange(e){
            this.returnOrderItemUpdate[e.currentTarget.dataset.field] = e.target.value; 
        }
        
        handleManualValueChange(e){
            this.errorMessage = '';
            this.numInstalled = e.detail.value;
        }
        
        handleManualFailedValueChange(e){
            this.errorMessage = '';
            var failed = e.detail.value;
            if (failed < 100){
                this.numFailed = "0"+failed;
            } else{
            this.numFailed = failed;
            }
            console.log('Failed Converted: '+this.numFailed);
        }
        
        handleMaterialChange(event){
            this.materialID = event.target.value;
            console.log('Material ID: '+this.materialID);
        
        }
        
        handleMaterialSelected(event){
        
            this.materialID = event.detail.selectedMaterialID;
            this.materialNumber = event.detail.selectedMaterialNumber;
            this.materialDescription = event.detail.selectedMaterialDescription;
            this.selectedMaterial = this.materialNumber + ' - ' + this.materialDescription; 
        
            console.log('Selected Material ID: '+this.materialID);
            console.log('Selected Material Description: '+this.materialDescription);
            console.log('Selected Material Number: '+this.selectedMaterialNumber);
            console.log('Concat Material: '+this.selectedMaterial);
        
        

        }
        
        handleNoCatChecked(event){
            console.log('NoCat Input ON-CLICK is: '+this.noCatInput);
            if(this.noCatInput == false){
                this.noCatInput = true;
                this.materialID = '';
                this.materialDescription = '';
            } else if (this.noCatInput == true){
                this.noCatInput = false;
                this.NoCAT = " ";
            }
            console.log('NoCat Input AFTER-CLICK is: '+this.noCatInput);
        }
        
        async handleSaveForm(event){
            console.log('HANDLE SAVE FORM FUNCTION EXECUTED...');
            this.editLabel = "Updating...";
            this.isAdding = true;
            var installedQty = this.numInstalled;
            console.log('Installed Qty Entered: '+installedQty);
            var failedQty = this.numFailed;
            console.log('Failed Qty Entered: '+failedQty);
            console.log('Quantity Imported: '+this.rowQuantity);
            if (failedQty > installedQty ){
                this.errorMessage = "ERROR: Failed Quantity cannot be greater than Installed Quantity";
                console.log('Error: '+this.errorMessage);
                this.editLabel = "Update";
            
            } else {
            let nReturnItem = {'sobjectType': 'Return_Order_Item__c'};
                console.log('NoCat upon EDIT: '+this.NoCAT);
                nReturnItem.NoCAT__c = this.NoCAT;
                //nReturnItem.Price_Agreement_Price__c = this.priceAgrmtPrice;
                //nReturnItem.Hours_per_Start__c = this.hoursPerStart;
                //nReturnItem.No_of_Hours_Used__c = this.hoursUsed;
                nReturnItem.Comments__c = this.comments;
                nReturnItem.Distributor_Id__c = this.selectedDistributorID;
                nReturnItem.Warranty_Code__c = this.template.querySelector(".wc").value;
                nReturnItem.Warranty_Sub_Code__c = this.template.querySelector(".wsc").value;
                nReturnItem.Transaction_ID__c = this.transactionId;
                nReturnItem.SKU__c = this.materialNumber;
                nReturnItem.Product_SKU__c = this.materialDescription;
                nReturnItem.Requested_Action_Override__c = this.template.querySelector(".ra").value;
                nReturnItem.No_Of_Products_Failed__c = this.template.querySelector(".mnf").value;
                nReturnItem.Date_Installed__c = this.template.querySelector(".di").value;
                nReturnItem.Installed_Qty__c = this.template.querySelector(".miq").value;
                nReturnItem.PO__c = this.template.querySelector(".po").value;
                nReturnItem.Shipment_Date__c = this.template.querySelector(".sd").value;
                nReturnItem.Transaction_ID__c = this.transactionId;
                nReturnItem.Id = this.currentRecordId;
        
                //updReturnOrderItems
                console.log(JSON.stringify("Check for Update Data Entry: "+ JSON.stringify(nReturnItem)))
                await updReturnOrderItems({data: nReturnItem})
                .then(result => {
                    this.returnID = result;
                    this.editProductModal=false;
                });
                //this.fetchReturnItems(); COMMENTED OUT 6-14
            }
        }
        
        handleManualSubmit(event) {
            console.log('HANDLE SUBMIT FUNCTION EXECUTED...');
            this.editLabel = "Updating...";
            // prevending default type sumbit of record edit form
            //event.preventDefault();
        
            // querying the record edit form and submiting fields to form
            console.log('Inbuilt Form Data Check: ' + JSON.stringify(event.detail.fields));
            //this.template.querySelector('lightning-record-edit-form').submit(event.detail.fields);
            const recordInputs = event.detail.fields.slice().map(draft=>{
                const fields = Object.assign({}, draft)
                return {fields}
            })
            console.log("recordInputs", recordInputs)
        
            const promises = recordInputs.map(recordInput => updateRecord(recordInput))
            Promise.all(promises).then(result=>{
                this.ShowToastMsg('Success', 'Item Updated')
                this.editProductModal = false;
              // this.draftValues=[];   
              // console.log('Before Refresh: '+ JSON.stringify(this.orderItemList));
              // console.log('Check for Refresh: '+ this.selectedOrder);
        
            // showing success message
        }).catch(error=>{
            this.ShowToastMsg('Error Updating Records', error.body.message, error)
        });
            }
        
        
        /*async handleSuccess() {
            this.editProductModal = false;
                 
         }*/
        
        async handleManualSave(event){
            console.log('HANDLE MANUAL SAVE FUNCTION EXECUTED...');
            this.addLabel = "Adding...";
            this.isAdding = true;
            
            this.reqAction = this.template.querySelector(".ra").value;
                console.log('Requested Action: '+this.reqAction);
            this.dateInstalled = this.template.querySelector(".di").value;
                console.log('Date Installed: '+this.dateInstalled);
            /*this.numInstalled = this.template.querySelector(".iq").value;
                console.log('Number Installed: '+this.numInstalled);
            this.numFailed = this.template.querySelector(".nf").value;
                console.log('Number Failed: '+this.numFailed);*/
            this.PO = this.template.querySelector(".po").value;
                console.log('PO# Entered: '+this.PO);
            this.shipmentDate = this.template.querySelector(".sd").value;
                console.log('Shipment Date: '+this.shipmentDate);
            this.warCode = this.template.querySelector(".wc").value;
                console.log('Warranty Code: '+this.warCode);
            this.warSubCode = this.template.querySelector(".wsc").value;
                console.log('Warranty Sub Code: '+this.warSubCode);
            this.comments = this.template.querySelector(".cm").value;
                console.log('Comments: '+this.comments);
            /*this.hoursUsed = this.template.querySelector(".hu").value;
                console.log('Hours Used: '+this.hoursUsed);
            this.hoursPerStart = this.template.querySelector(".hs").value;
                console.log('Hours Per Start: '+this.hoursPerStart);*/
            
            
            //let transaction = this.transactionId;
            console.log('Material ID: '+this.materialID);
        
        
            let matName = this.materialID;
            let noCatName = this.NoCAT;
            var fqty = this.numFailed;
            var iqty = this.numInstalled;
            if (!matName && !noCatName){
                this.addLabel = "Add to Claim";
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'ERROR',
                        message: 'Material or No Cat# are required',
                        variant: 'error'
                    })
                );
                this.isAdding = false;
            } else {
                console.log('Failed: '+this.numFailed+' '+'QTY: '+this.numInstalled);
                const allValid = [...this.template.querySelectorAll('.validValue')]
                .reduce((validSoFar, inputCmp) => {
                            inputCmp.reportValidity();
                            return validSoFar && inputCmp.checkValidity();
                }, true);
                    if (allValid) {
                        
                        if (fqty > iqty){
                            this.isAdding = false;
                            this.errorMessage = "ERROR: Number of Failed Products cannot be greater than Installed Quantity";
                            console.log('Error: '+this.errorMessage);
                            this.addLabel = "Add to Claim";
                            
                            //this.ShowToastMsg('# of Filed Products cannot be greater than Installed Qty');
                        }else{
                
                        let nReturnItem = {'sobjectType': 'Return_Order_Item__c'};
                            nReturnItem.Material__c = this.materialID;
                            nReturnItem.NoCAT__c = this.NoCAT;
                            console.log('NoCAT# Entered: '+this.NoCAT);

                            if(this.materialID != null || this.materialID != ' '){
                                nReturnItem.Type__c = 'Warranty - Product Search';
                            } else {
                                nReturnItem.Type__c = "Warranty - Manual Entry";
                            }

                            nReturnItem.Product_SKU__c = this.materialDescription;
                            nReturnItem.Distributor_Id__c = this.selectedDistributorID;
                            console.log('Material# Entered: '+this.materialDescription);
                            nReturnItem.SKU__c = this.materialNumber;
                            nReturnItem.Transaction_ID__c = this.transactionID;
                            nReturnItem.Requested_Action_Override__c = this.reqAction;
                            nReturnItem.No_Of_Products_Failed__c = this.numFailed;
                            nReturnItem.Date_Installed__c = this.dateInstalled;
                            nReturnItem.Installed_Qty__c = this.numInstalled;
                            nReturnItem.Comments__c = this.comments;
                            nReturnItem.Warranty_Code__c = this.warCode;
                            nReturnItem.Warranty_Sub_Code__c = this.warSubCode;
                            //nReturnItem.No_of_Hours_Used__c = this.hoursUsed;
                            nReturnItem.PO__c = this.PO;
                            //nReturnItem.Hours_per_Start__c = this.hoursPerStart;
                            //nReturnItem.Price_Agreement_Price__c = this.priceAgrmtPrice;
                            /*if(this.noCatInput = true){
                             nReturnItem.Unique_ID__c = transaction + '_' + this.NoCAT;
                            } else{
                                nReturnItem.Unique_ID__c = transaction + '_' + this.materialDescription;
                            }*/
                            nReturnItem.Shipment_Date__c = this.shipmentDate;
                            
                            await createReturnItem({accounts: nReturnItem})
                            .then(result => {
                                this.returnID = result;
                                this.noCatModal = false;
                                this.materialID = '';
                                this.noCatInput = false;
                                this.editProductModal = false;
                                this.NoCAT = '';
                                this.comments = '';
                                this.materialNumber = '';
                        
                            });
                            
                        this.isAdding = false;
                        this.fetchReturnItems(); 
                         
                
                        console.log('ROI ID: '+this.returnID);
                        console.log('Transaction ID: '+this.transactionID);
                        }
                    } else {
                        this.addLabel = "Add to Claim";
                        this.isLoading = false;
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'ERROR',
                                message: 'Please fill out all Required Fields',
                                variant: 'error'
                            })
                        );
                    }
            }
        }
        
        
        async handleMaterialMasterSelect(event) {
        
            const index = +event.currentTarget.dataset.index;
            let selectedMaterial = event.detail.selectedMaterial;
            console.log(index, event.detail.selectedMaterial)
        
            if (selectedMaterial != null) {
                this.orderItems[index].materialMaster = null;
                this.orderItems[index].materialMaster = selectedMaterial;
                this.materialDescription = selectedMaterial.GE_LGT_EM_MaterialDescription__c;
                this.materialNumber  = selectedMaterial.GE_LGT_EM_SAP_MaterialNumber__c;
                console.log('Material Number: '+this.materialNumber);
                console.log('Material Description: '+this.materialDescription);
            }
           
            this.materialID = event.detail.selectedMaterial.Id;
            console.log('SELECTED MATERIAL FROM MATERIAL LOOKUP LWC: '+this.materialID);
            
        
            this.orderItems[index].materialName = selectedMaterial.GE_LGT_EM_SAP_MaterialNumber__c + ' - ' + selectedMaterial.GE_LGT_EM_MaterialDescription__c;
            console.log('Concat Material: '+this.orderItems[index].materialName);
            this.orderItems = [...this.orderItems];
            
            
        }
        
        handleMaterialMasterReset(event) {
            this.materialID = '';
        }
            
        
        
         deleteManualRow(row) {
        
            console.log('value getting passed for deletion: '+ JSON.stringify(row));
            var selRow = [row];
            for (var i =0; i< selRow.length ;i++) {
                console.log(selRow[i].Transaction_ID__c);
                var newRow = selRow[i].Transaction_ID__c;
             }
            console.log('value getting passed for deletion: '+ JSON.stringify(selRow));
            console.log('New Value Passed for Trax ID: '+ newRow);
            deleteReturnItemList({data: selRow})
            .then(result => {
                
                console.log(JSON.stringify("Apex update result: "+ result));
        
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Selected record has been deleted successfully',
                        variant: 'success'
                    })
                );
               
                this.fetchReturnItems();
            
        });
        }
        
            //----- END MANUAL PRODUCT ENTRY FUNCTIONS

//------------------------------------------------------------------------------------------ END OF WARRANTY -------------------------------------------------------------------------------------------------------


//ON COMPONENT LOAD FUNCTIONS

renderedCallback(){ 
    if(this.isCssLoaded) return
    this.isCssLoaded = true
    loadStyle(this, COLORS).then(()=>{
        console.log("Loaded Successfully")
    }).catch(error=>{ 
        console.error("Error in loading the colors")
    })
}

 async connectedCallback(){
            this.userType = localStorage.getItem("User Type");
            console.log('User Type in Invoice Search: '+this.userType);
            if(this.userType == "Agent"){
                this.notDistributor = true;
                this.searchDisabled = true;
                this.setRequired = true;
            } else {
                this.notDistributor = false;
                this.searchDisabled = false;
                this.setRequired = false;
            }

            console.log('Distributor Number Passed for DEFAULT: '+this.filterFieldName);
            console.log('Order Number passed for DEFAULT: '+this.orderNumber);
            console.log('Case Type sent from Parent Component: '+this.caseType);
            console.log('Preselected Order: '+this.selectedOrder);
            console.log('Preselected Account: '+this.preSelectedAccount);
            console.log('Sold To Passed from Order: '+this.selectedDistributorID);
            console.log('Order ID passed from Parent: '+this.orderID);


            if(this.caseType == "Overage"){
                this.isOverage = true;
            }

            if(this.caseType == "Warranty"){
                this.isWarranty = true;
            }

            if(this.caseType == "Lost/Damaged"){
                this.isLostDamaged = true;
            }


            if(this.preSelectedAccount != null || this.preSelectedAccount != ''){
                this.searchDisabled = false;
                //this.searchButtonDisabled = false;
                 //this.manualDisabled = false;
            } else if (this.preSelectedAccount == null || this.preSelectedAccount === undefined) {
                this.searchDisabled = true;
                //this.searchButtonDisabled = true;
                 
            }

            if(this.orderNumber === undefined){
                this.hasLines = false;
                this.searchButtonDisabled = true;
                 
     
            } else if(this.orderNumber != null || this.orderNumber != ''){
                 console.log('ORDER NUMBER: '+this.orderNumber);
                 this.selectedOrder = this.orderNumber;
                 this.searchButtonDisabled = false;
                 this.manualDisabled = false;
                 this.handleChangeDefaulted();
                 
             } else {

            //let soldToNum = localStorage.getItem('DistributorAccount');
            let type = localStorage.getItem('User Type');

            /*if (type == "Distributor" || type == "Customer"){
                console.log('Inside TYPE IF STATEMENT...');
                this.notDistributor = false;
                this.searchDisabled = false;
            
            } else {
                console.log('Inside ELSE STATEMENT...');
                this.notDistributor = true;
                this.searchDisabled = true;
            }*/

            if(this.filterFieldName != null || this.filterFieldName != ''){
                console.log('Inside FIlter Field Name IF STATEMENT...');
                console.log('Filter Field Name: '+this.filterFieldName);
                this.noSoldTo = false;
                this.accountSearchDisabled = false;
                //this.searchButtonDisabled = false;
                //this.searchDisabled = false;
            }

    
        /*const id = 'id' + performance.now();
        this.transactionID = id;
        console.log('Generated ID: '+ id); */
    }
    
    }


    async handleChangeDefaulted(event){
        //this.caseType = this.caseType + ' - From Order';
        console.log('New Case Type Attribute: '+this.caseType);
        let orderLength = this.orderNumber;
        console.log('DEFAULT ORDER SIZE: '+orderLength.length);
        if(orderLength.length > 2){
            this.searchButtonDisabled = false;
        }
        
        this.searchKey = this.orderNumber;
        
        this.isLoading = true;
        console.log('Search Key: '+this.searchKey);
        console.log('Sending Sold To Number: '+this.filterFieldName);
        await findInvLineRecords({searchKey: this.searchKey, objectName: this.objectApiName, filterField: this.filterFieldName})
        .then(result => {
            this.tempList = [];
            if(result){
                this.hasLines = true;
                /* this.tempList = result.map(item=>{
                    let depleted = item.Available_for_Return__c = 0 ? "slds-text-color_error" : "slds-text-color_default"
                    return {...item, "depleted":depleted} 
                })*/
                    if(this.caseType == "Credit" || this.caseType === 'Overage' || this.caseType === 'Shortage' || this.caseType === 'Lost/Damaged' || this.caseType === 'Warranty'){
                        console.log('JSON RESULTS: '+JSON.stringify(result));
                        this.tempList = result.map(item=>{
                            const tempNumber = item.GE_LGT_EM_Order_Number__c;
                        let newNumber = tempNumber.replace(/^0+/, "");
                            //console.log('Material Supply Chain Status: '+item.GE_LGT_EM_Material__r.GE_LGT_EM_Distribution_Chain_Status__c);
                            //let chainStatus = item.GE_LGT_EM_Material__r.GE_LGT_EM_Distribution_Chain_Status__c;
                            //let cellColor = item.Available_for_Return__c == 0  ? "slds-text-color_error":"slds-text-color_default"
                            let buttonColor = item.Available_for_Return__c > 0 ? "brand":"brand-inverse"
                            let textColor = item.Available_for_Return__c == 0 ? "slds-text-color_error":"slds-text-color_default"
                            let iconName = item.Available_for_Return__c == 0 ? "utility:lock":"utility:new"
                            let rowIcon = item.Available_for_Return__c == 0 ? "utility:lock":""
                            let iconTitle = item.Available_for_Return__c == 0 ? "Return Depleted":""
                            let actionDisabled = item.Available_for_Return__c == 0 ? true:false
                            return {...item, 
                                "actionDisabled":actionDisabled,
                                "iconName":iconName,
                                "textColor":textColor,
                                //"cellColor":cellColor,
                                'buttonColor':buttonColor,
                                'rowIcon': rowIcon,
                                'iconTitle':iconTitle,
                                'newNumber':newNumber
                            }
                        });
                    } else if (this.caseType === 'Return' || this.caseType === 'Return/Replace'){
                        console.log('JSON RESULTS: '+JSON.stringify(result));
                        this.tempList = result.map(item=>{
                            const tempNumber = item.GE_LGT_EM_Order_Number__c;
                        let newNumber = tempNumber.replace(/^0+/, "");
                            console.log('Material Supply Chain Status: '+item.GE_LGT_EM_Material__r.GE_LGT_EM_Distribution_Chain_Status__c);
                            //let chainStatus = item.GE_LGT_EM_Material__r.GE_LGT_EM_Distribution_Chain_Status__c;
                            //let cellColor = item.Available_for_Return__c == 0  ? "slds-text-color_error":"slds-text-color_default"
                    let buttonColor = (item.Available_for_Return__c > 0 && item.GE_LGT_EM_Material__r.GE_LGT_EM_Distribution_Chain_Status__c == '02') ? "brand":"brand-inverse"
                        let textColor = (item.Available_for_Return__c == 0 || item.GE_LGT_EM_Material__r.GE_LGT_EM_Distribution_Chain_Status__c != '02' ) ? "slds-text-color_error":"slds-text-color_default"
                        let iconName = (item.Available_for_Return__c == 0 || item.GE_LGT_EM_Material__r.GE_LGT_EM_Distribution_Chain_Status__c != '02' ) ? "utility:lock":"utility:new"
                        let rowIcon = (item.Available_for_Return__c == 0 || item.GE_LGT_EM_Material__r.GE_LGT_EM_Distribution_Chain_Status__c != '02' ) ? "utility:lock":""
                        let iconTitle = (item.Available_for_Return__c == 0 || item.GE_LGT_EM_Material__r.GE_LGT_EM_Distribution_Chain_Status__c != '02' )? "Return Depleted":""
                        let actionDisabled = (item.Available_for_Return__c == 0 || item.GE_LGT_EM_Material__r.GE_LGT_EM_Distribution_Chain_Status__c != '02' ) ? true:false
                    

       
                            return {...item, 
                                "actionDisabled":actionDisabled,
                                "iconName":iconName,
                                "textColor":textColor,
                                //"cellColor":cellColor,
                                'buttonColor':buttonColor,
                                'rowIcon': rowIcon,
                                'iconTitle':iconTitle,
                                'newNumber':newNumber
                            }
                        });
                    }
                
                
                    /*if(this.caseType !== 'Return' || this.caseType !== 'Overage'){
                        for (const items of result){
                        const clone = Object.assign({}, items);
                        console.log('JSON of Items: '+JSON.stringify(items));
                            if(items.Available_for_Return__c == 0){
                                console.log('Record Available for Return: '+items.Available_for_Return__c);
                                clone.actionDisabled = true;
                                clone.cellColor = 'slds-text-color_error slds-text-title_bold';
                
                                
                            } else if (items.Available_for_Return__c > 0){
                                clone.buttonColor = 'brand';
                            }
            
                        this.tempList.push(clone);
                        
                        } 
                    }*/ 
                    
    
                    //this.tempList.push(clone);
                    this.isLoading = false;

            this.invLines = this.tempList;
    
              this.totalRecountCount = result.length;
              this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize); //here it is 5
                  
                  //initital data to be displayed ----------->
                  //slice will take 0th element and ends with 5, but it doesn't include 5th element
                  //so 0 to 4th rows will be display in the table
                  
                  
                    this.data = this.invLines.slice(0,this.pageSize);
                    var inputData = {
                        totalPages:this.totalPage
                    };
                    //this.template.querySelector("c-paginator").setButtons(inputData);
                    if(this.totalRecountCount < this.pageSize){
                        this.endingRecord = this.totalRecountCount;
                    } else {
                    this.endingRecord = this.pageSize;
                    }
    
    
    
    
                  //this.columns = columns;
                  this.error = undefined;
              window.console.log(JSON.stringify(result, null, '\t'));
              window.console.log(result.id);
              result.forEach(function (item, key) {
                  window.console.log('Key: '+key); 
                  window.console.log('Item: '+item); 
              });
    
    
              }
          console.log(JSON.stringify("Lines Returned:  "+ JSON.stringify(this.invLines)));
          this.isLoading = false;
          });
    }



    

   @api setDefaultButtons(){
       console.log('Setting Defaulted Buttons...');
       this.searchButtonDisabled = false;
       this.manualDisabled = false;
   }

   @api setOrderSoldTo(soldTo){
       this.selectedDistributorID = soldTo;
   }
   @api setManualButtons(){
    
    this.manualDisabled = false;
    }

    @api setDistributorButtons(){
        this.searchButtonDisabled = false;
        this.manualDisabled = false;
    }

    @api setSoldToAccount(soldTo){
        console.log('SETTING THE SOLD TO FROM THE ORDER PASSED FROM OVERAGE LWC....'+soldTo);
        this.selectedDistributorID = soldTo;
    }

 

    handleRAction(event){
        this.actionReason = event.target.value;
        console.log('Action Reason :' +this.actionReason)
        /*if(this.actionReason == "Return and Credit" && this.siteAddress === false){   
            this.popAddress = true;         
        } else {
            this.popAddress = false;
        }*/
    }

   
    

// closing modal box
    closeModal1() {
        this.bShowModal1 = false;
    }





 


showWarranty(event){
    this.warrantyEntry = true;
    this.isOrderIdAvailable = false;
} 



orderProto = {
    get isNoAvail() {
        return result.Available_for_Return__c == 0;
    }
}

ShowToastMsg(title, message, variant){
    this.dispatchEvent(
        new ShowToastEvent({
            title:title,
            message:message,
            variant:variant||'success'
        })
    )
    }



    clearLines(){
        this.searchKey = '';
        this.hasLines = false;
        this.invLines = [];
    }

    @api changeAccount(){
        this.accountSearchDisabled = false;
        this.searchButtonDisabled;
        this.preSelectedAccount = null;
        this.template.querySelector("c-sold-to-lookup-l-w-c").resetSoldTo();
        this.searchKey = '';
        this.hasLines = false;
        this.searchDisabled = true;
        this.invLines = [];
    }


    //------------------------WARRANTY CLAIM FUNCTIONS START-------------------------------------------------
//-------------------------END WARRANTY CLAIM FUNCTIONS----------------------------------------------------

    
    //--------- CODE BLOCK FOR PAGINATION ON PARENT COMPONENT ---------->
//clicking on previous button this method will be called
previousHandler() {
    if (this.page > 1) {
        this.page = this.page - 1; //decrease page by 1
        this.displayRecordPerPage(this.page);
        var inputData = {
            totalPages:this.totalPage,
            currentPage:this.page
        };
        this.template.querySelector("c-paginator").setButtons(inputData);
    
    }
}

//clicking on next button this method will be called
nextHandler() {
    if((this.page<this.totalPage) && this.page !== this.totalPage){
        this.page = this.page + 1; //increase page by 1
        this.displayRecordPerPage(this.page);
        var inputData = {
            totalPages:this.totalPage,
            currentPage:this.page
        };
        this.template.querySelector("c-paginator").setButtons(inputData);
                
    }             
}

//this method displays records page by page
displayRecordPerPage(page){

    /*let's say for 2nd page, it will be => "Displaying 6 to 10 of 23 records. Page 2 of 5"
    page = 2; pageSize = 5; startingRecord = 5, endingRecord = 10
    so, slice(5,10) will give 5th to 9th records.
    */
    this.startingRecord = ((page -1) * this.pageSize) ;
    this.endingRecord = (this.pageSize * page);

    this.endingRecord = (this.endingRecord > this.totalRecountCount) 
                        ? this.totalRecountCount : this.endingRecord; 

    this.data = this.invLines.slice(this.startingRecord, this.endingRecord);

    //increment by 1 to display the startingRecord count, 
    //so for 2nd page, it will show "Displaying 6 to 10 of 23 records. Page 2 of 5"
    this.startingRecord = this.startingRecord + 1;
}  


}