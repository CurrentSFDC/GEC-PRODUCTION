import { LightningElement, track, api, wire } from 'lwc';
import findRecordsNEW from "@salesforce/apex/LwcLookupControllerCust.findOrderRecordsNEW"; 
import { getRecord } from 'lightning/uiRecordApi';
import { updateRecord } from 'lightning/uiRecordApi';
import { deleteRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getInvLineNewList from "@salesforce/apex/LwcLookupControllerCust.getInvLineNewList";
import getOrderId from "@salesforce/apex/OrderProductController.getOrderId";
import updateOrdLines from '@salesforce/apex/connectCreateCase.updateOrdLines';
import getOrderItemList from '@salesforce/apex/OrderProductController.getOrderItemList'
import orderListData from '@salesforce/apex/ChangeRequestOrderController.getChangeReqUpdItem';
import getChangeReqRefList from '@salesforce/apex/ChangeRequestOrderController.getChangeReqRefList';
import getChangeReqCartItem from '@salesforce/apex/ChangeRequestOrderController.getChangeReqCartItem';
import createReturnItems from '@salesforce/apex/connectCreateCase.createReturnItems';
import getOrderItemRefList from '@salesforce/apex/OrderProductController.getOrderItemRefList';
import getProdFamilies from '@salesforce/apex/StockBalancingReturnLwcController.getProductFamilies';

//--- CLASSES USED FOR MANUAL PRODUCT ENTRY ----
import createReturnItem from '@salesforce/apex/ReturnOrderItemController.createReturnOrderItems';
import updReturnOrderItems from '@salesforce/apex/ReturnOrderItemController.updReturnOrderItems';
import getMaterialDes from '@salesforce/apex/ReturnOrderItemController.getMaterial';
//import getReturnList from '@salesforce/apex/OrderProductController.getReturnList';
import deleteReturnItemList from '@salesforce/apex/OrderProductController.delReturnItems';
// - END CLASSES USED FOR MANUAL PRODUCT ENTRY



import getReturnList from '@salesforce/apex/OrderProductController.getReturnList';
import updateOrderItemList from '@salesforce/apex/OrderProductController.updateOrderItemList';
import updateReturnItemList from '@salesforce/apex/OrderProductController.updateReturnItemList';

//import { getOrderId} from 'lightning/uiRecordApi';
import {FlowNavigationNextEvent} from 'lightning/flowSupport';

const orderItemTemplate = {materialMaster: null, materialName: ''};

const actions = [
    { label: 'Edit', name: 'edit'},
    { label: 'Delete', name: 'delete'}
];

// COLUMNS FOR ORDER LINE ITEM SELECTION SCREEN



export default class OrderSearchLWC extends LightningElement {

    //------USED FOR PAGINATION
    @track page = 1; //this is initialize for 1st page
    @track data = [];
    @track startingRecord = 1; //start record position per page
    @track endingRecord = 0; //end record position per page
    @track pageSize = 5; //default value we are assigning
    @track totalRecountCount = 0; //total record count received from all retrieved records
    @track totalPage = 0; //total number of page is needed to display all records

    @track recordsList;  
    @track recordsListNew;
    @track searchKey = "";  
    @track searchKeyNew = ""; 
    @api selectedValue;  
    @api selectedValueNew; 
    @api selectedRecordId;  
    @api selectedRecordIdNew; 
    @api objectApiName = '';
    @api filterFieldName;
    @api filterFieldVal='DEFAULT';  
    @api iconName;  
    @api lookupLabel; 
    @api orderagency; 
    @track message;
    @api selectorNumber;
    @api distributorID;

    @track invLines = [];
    @track linesToUpdate = [];
    @track hasLines = false;
    @track searchText;  
    @track options = [];
    @track selectedAccount;
    @track accounts;
    @track noSoldTo = false;
    @track searchDisabled = false;
    @track accountSearchDisabled = false;
    @api preSelectedAccount;
    @api selectedDistributorID;
    @track currentRecordOrder;
    @track oldTempNumber;
    @track oldOrderNumber;

     @track cartLabel;
     @track tempList = [];    
     @api cartCount = 0;
     @api transactionID;
     @api headerAction;
     @track bShowModal = false;
     @track bShowModal1 = false;
     @track currentRecordId;
     @track currentRecordDtl;
     @api storedLines;
     @api getorder;
     @track isOrderIdAvailable = false;
     @track flagIndi = false;
     //@track orderId='';
     draftValues = [];
     @track error;
     @track orderItemList=[];
     @track linesItemNewList;
     @track selectedOrder;
     @api valuetopass;
     @track rowQuantity;
     @track rowAvailForReturn;
     @track rowReturnTotal;
     @track errorMessage;
     @track paramString;
     @api agentNumber;
     @api showDistroField= false;
     @track distLines;
     @track distAccName;
     @api soldToAccount;
     @track disAccount;
     @track disName=[];
     @track isSpinner = false;
    @track isLoading = false;
     @track transactionTotal = 0.00;
     @track clear;
     @track notDistributor = true;
     @api prodFamilies;

    

    //COMMON ATTRIBUTES
    @api popOptions
    @api caseType;
    @track changeType;
    @track expediteType;
    @api columns;
    @api userType;
    @api selectorAccountID;
    @api orderNumber;
    @api orderID; 
    @track selectedSoldToAccountName;
    @api cartColumns;
    @track setRequired;
    @track deleteModal = false;
    @track returnItemId;
    @track deleteFromRow = false;
    @track deleteClearAll = false;
    @track isRemoving = false;
    @track isAdding = false;

    //CHANGE REQUEST ATTRIBUTES
    @track isEditForm = false;
    @track catChangeEdit;
    @track editShipDate=false;
    @track editReasonChange=false;
    @track bShowModal1 = false;
    @track checkForEditRow;
    @track entireOrder = false;
    @api category;
    @api comments;
    @api newShipDate;
    @api orderChoice;
    
   
    @api setConfirmValues(inputData){
        this.category=inputData.category;
        this.comments=inputData.comments;
        this.newShipDate=inputData.newShipDate;

        console.log('Category in Order Search: '+ this.category);
        console.log('Comments in Order Search: '+ this.comments);
        console.log('New Ship Date in Order Search: '+ this.newShipDate);
        console.log('Order Choice in Order Search: '+this.orderChoice);

        this.addEntireOrder();

    };

    @api setVisibility(type){
        console.log('PASSED USER TYPE: '+type);
        if(type === "Agent"){
            this.notDistributor = true;
            this.searchDisabled = true;
            this.setRequired = true;
        } else {
            this.notDistributor = false;
            this.searchDisabled = false;
            this.setRequired = false;
        }
    };

    // CHANGE REQUEST CART COLUMNS
     @track changeColumns = [{
        label: 'Order Line #',
        fieldName: 'Order_Line_Number__c',
        type: 'Text',
        sortable: true,
        cellAttributes: { alignment: 'right' }
    },
    {
        label: 'Catalog #',
        fieldName: 'SKU_Description_Cat_Logic__c',
        type: 'Text',
        iconName: 'utility:products',
        sortable: true,
        cellAttributes: { alignment: 'left' }
    },
    {
        label: 'SKU #',
        fieldName: 'SKU__c',
        type: 'Text',
        sortable: true,
        cellAttributes: { alignment: 'left' }
    },
    {
        label: 'PO#',
        fieldName: 'PO__c',
        type: 'Text',
        sortable: true,
        cellAttributes: { alignment: 'left' }
    },    
    {
        label: 'Qty',
        fieldName: 'Quantity',
        iconName: 'utility:number_input',
        type: 'Text',
        sortable: true,
        cellAttributes: { alignment: 'right' }
    },
    {
        label: 'Price',
        fieldName: 'UnitPrice',
        iconName: 'utility:money',
        type: 'currency',
        sortable: true,
        cellAttributes: { alignment: 'right' }
    },
    /*{
        label: 'Distributor Name',
        fieldName: 'Distributor_Name__c',
        type: 'Text',
        sortable: true,
        cellAttributes: { alignment: 'center' }
    },*/
    {
        label: 'Category of Change',
        fieldName: 'Category_Of_Change__c',
        iconName: 'utility:button_choice',
        type: 'Text',
        sortable: true,
        cellAttributes: { alignment: 'center' }
    },
    {
        label: 'Requested New Ship Date',
        fieldName: 'New_Shipment_Date__c',
        iconName: 'utility:date_input',
        type: 'Date',
        sortable: true,
    },
    {
        label: 'Change Text/Comment',
        fieldName: 'Reason_for_Change__c',
        iconName: 'utility:textbox',
        type: 'Text',
        sortable: true,
    },
    {
        type: 'button-icon',
        initialWidth: 34,
        iconName: 'utility:delete',
        typeAttributes:{
            label: 'Delete',
            name: 'delete',
            rowActions: actions,
            title: 'delete',
            iconName: 'utility:delete',
            iconClass: 'slds-icon-text-error',
                           
        },
        
    },
    
    ]; 
    // END CHANGE REQUEST COLUMNS
    
    
    //USED FOR CLEARING CART ON END OF SESSION TIME AND/OR WHEN NAVIGATING AWAY FROM PAGE
    @api clearSessionCart(){
        console.log('EXECUTING CLEAR SESSION CART...');
        console.log('Order Lines to be Cleared: '+JSON.stringify(this.linesToUpdate))
        this.sessionCartDelete();
    }

    async sessionCartDelete(){
        if(this.storedLines.length > 0){
            for(var i = 0, len = this.storedLines.length; i < len; i++){
            await deleteRecord (this.storedLines[i].Id)
             .then(() => {
     
                     this.fetchReturnItems();
     
             })
         }
         console.log('Passing Order Lines to Reset: '+JSON.stringify(this.linesToUpdate));
         updateOrdLines({lines : this.linesToUpdate})
         .then(result => {
            
         console.log('ORDER LINES RESET....'+result);

         var baseURL = window.location.origin;
                console.log('Base URL: '+baseURL);
                this.sfdcOrgURL = baseURL+'/s/';
                console.log('New URL: '+this.sfdcOrgURL);
                window.open(this.sfdcOrgURL, "_self"); 
         });
        } else {
            console.log('NO LINES TO RESET... E.T. IS PHONING HOME');

            var baseURL = window.location.origin;
                   console.log('Base URL: '+baseURL);
                   this.sfdcOrgURL = baseURL+'/s/';
                   console.log('New URL: '+this.sfdcOrgURL);
                   window.open(this.sfdcOrgURL, "_self"); 
        }

      
    }

    

async connectedCallback(){


        console.log('Account ID Passed from Change/Expedite Request Component: '+this.filterFieldName);
        console.log('Order # Passed from Change/Expedite Request Component: '+this.orderNumber);
        console.log('Order ID Passed from Change Request Component: '+this.orderID);
        console.log('Order ID Passed from Warranty Component: '+this.orderID);
        console.log('Case Type in Order Search: '+this.caseType); 

        console.log('Passing SELECTOR ID to Get Prod Families: '+this.selectorAccountID);
        getProdFamilies({soldToAccId: null, agentAccId: this.selectorAccountID})
        .then(result => {
        this.prodFamilies = result;
        console.log('getProdFamilies:' + result);
        })
        .catch(error => {
            console.log(error);
            this.error = error;
        });

        if(this.userType === "Agent"){
            this.notDistributor = true;
            if(this.preSelectedAccount != '' || this.preSelectedAccount != null){
                this.searchDisabled = false;
            } else {
                this.searchDisabled = true;
            }
            
            this.setRequired = true;
        } else {
            this.notDistributor = false;
            this.searchDisabled = false;
            this.setRequired = false;
        }

        if(this.caseType == "Expedite"){
            this.expediteType = true;
        } else if (this.caseType == "Change"){
            this.changeType = true;
        } else if (this.caseType == "Warranty"){
            this.isWarranty = true;
                console.log('Agent Account ID: '+this.selectorAccountID);
                console.log('Sold To Account ID: '+this.selectedDistributorID);
                /*getProdFamilies({soldToAccId: this.selectedDistributorID, agentAccId: this.selectorAccountID})
                    .then(result => {
                    this.prodFamilies = result;
                    console.log('getProdFamilies:' + result);
                    })
                    .catch(error => {
                        console.log(error);
                        this.error = error;
                    });*/
            
        }   
       if(this.orderID === undefined){
           this.hasLines = false;

       } else if(this.orderID != null || this.orderID != ''){
            console.log('ORDER ID: '+this.orderID);
            this.selectedOrder = this.orderID;
            this.handleChangeDefaulted();
            
        } else {
        
        
        

        let soldToNum = localStorage.getItem('DistributorAccount');
        let type = localStorage.getItem('User Type');
        console.log('Passed User Type: '+this.userType);

       /* if (type == "Distributor" || type == "Customer"){
            this.notDistributor = false;
            this.searchDisabled = false;
        
        } else {
            this.notDistributor = true;
            this.searchDisabled = true;
        }*/

        console.log('Sold To From GAS: '+soldToNum);
        if(soldToNum == null || soldToNum == ''){
            this.noSoldTo = true;
            this.searchDisabled = true;
            
        } else {
            this.preSelectedAccount = localStorage.getItem('DistributorName') + ' - ' + localStorage.getItem('DistributorAccount') + ' - ' + localStorage.getItem('DistributorSegment');
            this.noSoldTo = false;
            this.filterFieldName = soldToNum;
            this.searchDisabled = false;
            this.accountSearchDisabled = true;
        }
        const id = 'id' + performance.now();
        this.transactionID = id;
        console.log('Generated ID: '+ id); 
    }
    }

    handleSoldToSelected(event){
        
        this.filterFieldName = event.detail.selectedAccount;
        this.selectedDistributorID = event.detail.selectedAccountId;
        this.selectedSoldToAccountName = event.detail.selectedSoldToAccountName;
        console.log('SOLD TO SELECTED: '+this.selectedDistributorID);
        this.searchDisabled = false;
        this.dispatchEvent(
            new CustomEvent('soldtoselected', {
                detail: {
                    soldto : this.selectedDistributorID,
                    soldToName: this.selectedSoldToAccountName
                }
            }));
        
            if(this.caseType == "Warranty"){
                console.log('Agent Account ID: '+this.selectorAccountID);
                console.log('Sold To Account ID: '+this.selectedDistributorID);
                getProdFamilies({soldToAccId: this.selectedDistributorID, agentAccId: this.selectorAccountID})
                    .then(result => {
                    this.prodFamilies = result;
                    console.log('getProdFamilies:' + result);
                    })
                    .catch(error => {
                        console.log(error);
                        this.error = error;
                    });
            }
    }

    handleKey(event){
        if(event.which == 13){
            this.searchOrders();
        }
    }

    // IF CLICKING ON SEARCH BUTTON TO SEARCH ORDERS - NON TYPE AHEAD FUNCTION
   /* async searchOrders(event){
        this.searchKey = this.template.querySelector('.sk').value;
        this.isLoading = true;
        let type = this.userType;
        console.log('Search Key: '+this.searchKey);
        console.log('Sending Account ID: '+this.filterFieldName);
      await findRecordsNEW({portalUser: type, searchKey: this.searchKey, objectName: this.objectApiName, filterField: this.filterFieldName, distributorID: this.distributorID})
      .then(result => {
      
        if(result){
          this.hasLines = true;
        
         this.invLines = result;

          this.totalRecountCount = result.length;
          this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize); //here it is 5
              
              //initital data to be displayed ----------->
              //slice will take 0th element and ends with 5, but it doesn't include 5th element
              //so 0 to 4th rows will be display in the table
              
              
                this.data = this.invLines.slice(0,this.pageSize);
                if(this.totalRecountCount < this.pageSize){
                    this.endingRecord = this.totalRecountCount;
                } else {
                this.endingRecord = this.pageSize;
                }
              this.columns = columns;
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
    }*/


//------------------ CART ACTIONS ------------------------------

    showCart(event) {
        this.bShowModal = true; // display modal window
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
        this.orderLineID = currentRow.Order_Product_Id__c;
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


    async deleteCurrentRecord(currentRow){
        this.deleteModal = false;
        this.isRemoving = true;
          console.log('Order Line to be Updated: '+this.orderLineID);
        
        await  deleteRecord (this.returnItemId)
           .then(() => {
            updateOrdLines({lines : this.orderLineID})
               .then(result => {
                   this.getUpdatedLines();
               console.log('ORDER LINES RESET....'+result);
               });
               this.dispatchEvent(
                   new ShowToastEvent({
                       title: 'Success',
                       message: 'Line has been removed from Cart',
                       variant: 'success'
                   })
               );          
                    this.fetchReturnItems();
           })
      }

   // OLD DELETE FUNCTION   
   /*deleteCurrentRecord(currentRow){
       var currentRecordId = currentRow.Id;
       const deduction = (currentRow.Return_Qty__c * currentRow.UnitPrice__c);
       deleteRecord (currentRecordId)
        .then(() => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Line has been deleted from the cart',
                    variant: 'success'
                })
            );
            
                    this.fetchReturnItems(deduction);
            
        })
   }*/

   async clearCart(event){
    this.deleteModal = false;
    this.isRemoving = true;   
    for(var i = 0, len = this.storedLines.length; i < len; i++){
       await deleteRecord (this.storedLines[i].Id)
        .then(() => {

                this.fetchReturnItems();

        })
        await updateOrdLines({lines : this.linesToUpdate})
                .then(result => {
                    this.getUpdatedLines();
                console.log('ORDER LINES RESET....'+result);
                });
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Cart has been Cleared',
                variant: 'success'
            })
        );
        
    }
   }
   
   // OLD CLEAR CART FUNCTION
   /*clearCart(event){
    for(var i = 0, len = this.storedLines.length; i < len; i++){
        deleteRecord (this.storedLines[i].Id)
        .then(() => {
            updateOrdLines({lines : this.linesToUpdate})
                .then(result => {
                    this.fetchUpdatedLines();
                console.log('INVOICE LINES RESET....'+result);
                });
            
                this.fetchReturnItems();

            
        })
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Line has been deleted from the cart',
                variant: 'success'
            })
        );
    }
   }*/

   // POTENTIAL FUTURE - SAVE CART FUNCTION
    saveCart(){
    /*localStorage.setItem('localStr',JSON.stringify(this.storedLines));
    var retrieveData = JSON.parse(localStorage.getItem('localStr'));
    console.log('Data in Saved Cart: '+JSON.stringify(retrieveData));*/

    var savedCart = {
        'Name': this.orderId +' - '+this.transactionID,
        'Lines': this.storedLines
    };
    
    

    localStorage.setItem('Saved Cart', JSON.stringify(savedCart));
    console.log('SAVED CART: '+savedCart);

    }

    async getUpdatedLines(event) { 
        //console.log("You selected an order: " + event.detail.value[0]);
     
          
     
             console.log('Order Number to be Retrieved for Refresh: '+this.selectedOrder);
             
           
             await getOrderItemRefList({orderId: this.selectedOrder})
             .then(result => {
           
                 if(result){
                   this.hasLines = true;
                 
                  this.invLines = result;
                  
         
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
               });
            
         }    
//----------------END CART FUNCTIONS--------------------------------------------


// to close modal window set 'bShowModal' tarck value as false
closeModal() {
    this.bShowModal = false;
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

    clearResults(event){
        this.clear = event.detail.clear;
        console.log('CLEAR: '+this.clear);
        if(this.clear === "true"){
            this.searchKey = '';
            this.hasLines = false;
            this.searchDisabled = true;
            this.invLines = [];
            this.template.querySelector("c-test-order-lookup").changeAccount();
        }
    }

    clearOrderResults(event){
        this.clear = event.detail.clear;
        console.log('CLEAR: '+this.clear);
        if(this.clear === "true"){
            this.template.querySelector("c-test-order-lookup").changeAccount();
        }
    }
    
    clearLines(){
        this.searchKey = '';
        this.hasLines = false;
        this.invLines = [];
    }

    changeAccount(){
        this.accountSearchDisabled = false;
        this.preSelectedAccount = null;
        let resetST = null;
        this.template.querySelector("c-sold-to-lookup-l-w-c").resetSoldTo(resetST);
        this.searchKey = '';
        this.hasLines = false;
        this.searchDisabled = true;
        this.invLines = [];
    }

// --- GET ORDER LINES BASED ON SELECTED ORDER -----
async handleChange(event) { 
   //console.log("You selected an order: " + event.detail.value[0]);

        this.selectedOrder = event.detail.selectedRecordId;
        let orderNumber = event.detail.orderNumber;
        let orderPO = event.detail.orderPO;
        let orderAgent = event.detail.orderAgent;
        this.concatOrder = orderNumber + ' - ' + orderPO;
        console.log('Concated Order: '+this.concatOrder);

        console.log('Order Number Selected: '+orderNumber);
        console.log('Order PO Selected: '+orderPO);
      
        await getOrderItemList({orderId: this.selectedOrder})
        .then(result => {
      
            if(result){
              this.hasLines = true;
            
             this.invLines = result;
             
    
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
          });
          this.dispatchEvent(
            new CustomEvent('orderselected', {
                detail: {
                    orderNum : orderNumber,
                    orderPO : orderPO,
                    orderAgent : orderAgent
                }
            }));
    }    

    // --- GET ORDER LINES BASED ON DEFAULTED ORDER FROM ORDER DETAIL PAGE -----
async handleChangeDefaulted(event) { 
    //console.log("You selected an order: " + event.detail.value[0]);
 
         await getOrderItemList({orderId: this.selectedOrder})
         .then(result => {
       
             if(result){
                 if(this.orderID != null || this.orderID != ''){
                    this.hasLines = true;
                 } else 
                 {
                     this.hasLines = false;
                 }
              this.invLines = result;

     
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
           });
     }    



// view the current record details
 viewCurrentRecord(currentRow) {
    this.bShowModal1 = true;
    this.isEditForm = false;
    this.record = currentRow;
}

// closing modal box
closeModal1() {
    this.bShowModal1 = false;
}


handleRowActions(event) {
    this.cartLabel = "Add to Request";
    const actionName = event.detail.action.name;
    const row = event.detail.row;


    console.log('Edit ActionName: '+ actionName);
    console.log('Edit Row: '+ JSON.stringify(row));
    switch (actionName) {
        case 'edit':
            if (this.caseType == "Change"){
                this.editCurrentRecord(row);
            }
            if (this.caseType == "Warranty"){
                let rowQuantityValue = event.detail.row.Quantity;
                console.log('Warranty - The Row Quantity: '+rowQuantityValue);

                this.rowQuantity = rowQuantityValue;
                console.log('Warranty - Row QTY Set: '+this.rowQuantity);
                this.editWarrantyCurrentRecord(row);
            }

            break;
        case 'show_details':
            this.showRowDetails(row);
            break;
        default:
    }
}

//--------------------------START CHANGE REQUEST FUNCTIONS -------------------------------------
editCurrentRecord(currentRow) {
    // open modal box
   
    this.bShowModal1 = true;
    this.isEditForm = true;
    this.editReasonChange=false;
    this.editShipDate=false;
    console.log('Modal Open: '+ this.bShowModal1);
    console.log('Inside Edit: '+ this.isEditForm );

    // assign record id to the record edit form
    this.currentRecordId = currentRow.Id;
    console.log('Editing Order Item: '+this.currentRecordId);
    //this.checkForEditRow = currentRow.Category_Of_Change__c;
    /*if (this.checkForEditRow=='Extend Shipping Date'){
        this.editShipDate=true;
        this.editReasonChange=false;
    }
    else if(this.checkForEditRow=='Increase Quantity'||this.checkForEditRow=='Decrease Quantity'||this.checkForEditRow=='Request Price Change'||this.checkForEditRow=='Other'){
        this.editReasonChange=true;
        this.editShipDate=false;
    }*/
}

handleChangeEdit(event){
    console.log('editReasonChange '+ this.editReasonChange);
    this.catChangeEdit = event.target.value;
    console.log('Category of Change Value '+ this.catChangeEdit);
   
    if (this.catChangeEdit=='Extend Shipping Date'){
        this.editShipDate=true;
        this.editReasonChange=false;
        
    }
    else if(this.catChangeEdit=='Increase Quantity'||this.catChangeEdit=='Decrease Quantity'||this.catChangeEdit=='Request Price Change'||this.catChangeEdit=='Other'){
        this.editReasonChange=true;
        this.editShipDate=false;
    }

}

// refreshing the datatable after record edit form success
async handleSuccess() {
    let tempId = this.currentRecordId;
    this.linesToUpdate.push(tempId);
    console.log('Lines to Update ARRAY: '+this.linesToUpdate);
    await getChangeReqRefList({orderId: this.selectedOrder}) 

    .then(result => {
      
        if(result){
          this.hasLines = true;
        
         this.invLines = result;

          this.totalRecountCount = result.length;
          this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize); //here it is 5
              
              //initital data to be displayed ----------->
              //slice will take 0th element and ends with 5, but it doesn't include 5th element
              //so 0 to 4th rows will be display in the table
              
              
                this.data = this.invLines.slice(0,this.pageSize);
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
      this.ShowToastMsg('Success', 'Order Details Updated')
      // closing modal
      this.bShowModal1 = false;
      });
      this.dispatchEvent(
        new CustomEvent('modifylines', {
            detail: {
               lineId  : this.linesToUpdate
            }
        }));  
        this.handleClick(); 
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

async addEntireOrder(){
    console.log('EXECUTING ADDING ENTIRE ORDER.....');
    this.entireOrder = true;
    let tempArray = [];

    let tempHold = JSON.stringify(this.invLines);
    console.log('Temp Hold Values: '+ tempHold);
    var linesList = JSON.parse(tempHold);
    console.log("Lines in the List: "+ JSON.stringify(linesList));

    for(var i = 0; i < linesList.length; i++){
        let returnOrderItem = {'sobjecttype': 'Return_Order_Item__c'};
        returnOrderItem.SKU__c = linesList[i].SKU__c;
        returnOrderItem.PO__c = linesList[i].PO__c;
        returnOrderItem.Quantity__c = linesList[i].Quantity;
        returnOrderItem.UnitPrice__c = linesList[i].UnitPrice;
        returnOrderItem.Order_Line_Number__c = linesList[i].Order_Line_Number__c;
        returnOrderItem.Category_Of_Change__c = this.category
        returnOrderItem.New_Shipment_Date__c = this.newShipDate;
        returnOrderItem.Reason_for_Change__c = this.comments;
        returnOrderItem.Type__c = 'Change Request - Entire Order';
        returnOrderItem.Order_Product_Id__c = linesList[i].Id;
        returnOrderItem.Transaction_ID__c = this.transactionID;
        returnOrderItem.Unique_ID__c = this.transactionID+ '_' +linesList[i].Order_Line_Number__c+ '_' +linesList[i].SKU__c; 
        returnOrderItem.Distributor_Name__c = linesList[i].Distributor_Name__c;
        returnOrderItem.UnitOfMeasure__c = linesList[i].UnitOfMeasure__c;
        returnOrderItem.Product_SKU__c = linesList[i].SKU_Description_Cat_Logic__c;



        tempArray.push(returnOrderItem);
    }

    console.log('ARRAY for Return Order Items Creation: '+JSON.stringify(tempArray));
    await createReturnItems({newRI : tempArray}); 

    this.fetchReturnItems();
}

     async handleClick( event ){

        //const updatedFields = event.detail.draftValues;

        await orderListData({transId: this.currentRecordId}) 
           .then(result => {
               this.orderItemNewList = result;
               console.log(result);
               console.log('Value passed from Apex for currentrow: ' + JSON.stringify(this.orderItemNewList));
           });
       //var selRows = this.template.querySelector('lightning-datatable');
        var selected = this.orderItemNewList;
        console.log('Edit Row: '+ JSON.stringify(selected));
        //console.log('Values for EDIT: '+this.draftValues);
        //this.storedLines = selected;
        console.log('Stored Lines: '+ JSON.stringify(this.storedLines));
        var newselval = selected.map(row => { return { "SKU__c": row.SKU__c, "PO__c": row.PO__c, "Quantity__c": row.Quantity, "UnitPrice__c": row.UnitPrice,
            "Order_Line_Number__c":row.Order_Line_Number__c,"Category_Of_Change__c":row.Category_Of_Change__c,"New_Shipment_Date__c":row.New_Shipment_Date__c,"Reason_for_Change__c":row.Reason_for_Change__c, "Type__c": "Change Request", "Product_SKU__c": row.SKU_Description_Cat_Logic__c,
            "Order_Product_Id__c":row.Id, "Transaction_ID__c": this.transactionID, "Unique_ID__c": this.transactionID+'_'+row.Order_Line_Number__c+'_'+row.SKU__c, "Distributor_Name__c": row.Distributor_Name__c, "Distributor_Id__c":this.orderLines, "UnitOfMeasure__c": row.UnitOfMeasure__c}});

        
        
        this.valuetopass = selected;
        console.log('value to pass check:' + JSON.stringify(this.valuetopass));
        
        console.log('value to pass check:' + JSON.stringify(newselval));
        await updateReturnItemList({data: newselval})
        .then(result => {
            
            console.log(JSON.stringify("Apex update result: "+ result));
            this.flagIndi= true;
            this.isLoading = false;
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

     // handleing record edit form submit
handleSubmit(event) {
    this.isAdding = true;
    let returnQty = this.template.querySelector('.dq').value;
    let category = this.template.querySelector('.cc').value;
    console.log('Return Qty: '+returnQty);
    this.errorMessage = "";
    this.cartLabel = "Adding to Cart...";
    this.isLoading = true;
    // prevending default type sumbit of record edit form
    //event.preventDefault();
    const fields = event.detail.fields;
    fields.Distributor_Name__c = this.disAccount;
    fields.Reason_for_Change__c = category;
    this.template.querySelector('lightning-record-edit-form').submit(fields);
    const newfield = event.detail.fields;
    console.log('New Field Check : ' + JSON.stringify(newfield));

    // querying the record edit form and submiting fields to form
    console.log('Inbuilt Form Data Check: ' + JSON.stringify(event.detail.fields));
    //this.template.querySelector('lightning-record-edit-form').submit(event.detail.fields);
    const recordInputs = event.detail.fields.slice().map(newfield=>{
        const fields = Object.assign({}, newfield)
        return {fields}
    })
    console.log("recordInputs", recordInputs)

    const promises = recordInputs.map(recordInput => updateRecord(recordInput))
    Promise.all(promises).then(result=>{
        this.ShowToastMsg('Success', 'Order Details Updated')
      // this.draftValues=[];   
      // console.log('Before Refresh: '+ JSON.stringify(this.orderItemList));
      // console.log('Check for Refresh: '+ this.selectedOrder);

    // showing success message
}).catch(error=>{
    this.ShowToastMsg('Error Updating Records', error.body.message, error)
});
    }
//------------------------END CHANGE REQUEST CODE FUNCTIONS---------------------------------------------



fetchReturnItems(){
    getChangeReqCartItem({transId : this.transactionID})
        .then(result =>{
            this.storedLines = result;
            this.cartCount = this.storedLines.length;
            if(this.entireOrder == true){
                this.dispatchEvent(
                    new CustomEvent('orderadded', {
                        detail: {
                            isadding : false
                        }
                    }));
                this.entireOrder = false;
            }
            /*if(this.value==='By Line Item' && this.cartCount >0){
                this.showNextButton = false;
            }
            else{
                this.showNextButton = true;
                console.log('FETCH RETURN ITEMS TRUE...');
    
            }*/
            
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
        
    });
    this.isRemoving = false;
    this.isAdding = false;
 }



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