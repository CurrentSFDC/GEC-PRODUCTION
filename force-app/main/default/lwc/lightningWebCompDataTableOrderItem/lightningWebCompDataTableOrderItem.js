import { LightningElement, track, wire, api } from 'lwc';
import getOrderItemList from '@salesforce/apex/OrderProductController.getOrderItemList';
import getOrderItemRefList from '@salesforce/apex/OrderProductController.getOrderItemRefList';
import { refreshApex } from '@salesforce/apex';
import NAME_FIELD from '@salesforce/schema/User.Name';
import USER_ID from '@salesforce/user/Id';
import { getRecord } from 'lightning/uiRecordApi';
import { updateRecord, deleteRecord } from 'lightning/uiRecordApi';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import getReturnList from '@salesforce/apex/OrderProductController.getReturnList';
//import updateOrderItemList from '@salesforce/apex/OrderProductController.updateOrderItemList';
import updateReturnItemList from '@salesforce/apex/OrderProductController.updateReturnItemList';
import orderListData from '@salesforce/apex/OrderProductController.orderListData';
import updDisName from '@salesforce/apex/OrderProductController.updDisName';
//import { getOrderId} from 'lightning/uiRecordApi';
import {FlowNavigationNextEvent} from 'lightning/flowSupport';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import DISPUTED_QTY_FIELD from '@salesforce/schema/OrderItem.Disputed_Qty__c';
import QUANTITY_FIELD from '@salesforce/schema/OrderItem.Quantity';
import REQUESTED_ACTION_OVERRIDE_FIELD_FIELD from '@salesforce/schema/OrderItem.Requested_Action_Override__c';
import ID_FIELD from '@salesforce/schema/OrderItem.Id';

const actions = [
    { label: 'Edit', name: 'edit'},
    { label: 'Delete', name: 'delete'}
];

export default class LightningWebCompDataTableOrderItem extends LightningElement(FlowNavigationNextEvent) {

    @api headerAction;

    // COLUMNS FOR ORDER LINE ITEM SELECTION SCREEN
@track columns = [{
        label: 'Catalog #',
        fieldName: 'SKU_Description_Cat_Logic__c',
        iconName: 'utility:products',
        type: 'Text',
        //sortable: true
    },
    {
        label: 'SKU #',
        fieldName: 'SKU__c',
        type: 'Text',
        //sortable: true,
        cellAttributes: { alignment: 'center' }
    },
    {
        label: 'PO#',
        fieldName: 'PO__c',
        type: 'Text',
        //sortable: true,
        cellAttributes: { alignment: 'center' }
    },
    {
        label: 'Qty',
        fieldName: 'Quantity',
        type: 'Text',
        iconName: 'utility:number_input',
        //sortable: true,
        hideDefaultActions: true,
        cellAttributes: { alignment: 'center' }
    },
    {
        label: 'Unit Price',
        fieldName: 'UnitPrice',
        iconName: 'utility:money',
        type: 'currency',
        //sortable: true
    },
    /*{
        label: 'Distributor Name',
        fieldName: 'Distributor_Name__c',
        type: 'Text',
        sortable: true,
        cellAttributes: { alignment: 'center' }
    },*/
    {
        label: 'UOM',
        fieldName: 'UnitOfMeasure__c',
        iconName: 'utility:slider',
        type: 'text',
        //sortable: true,
        cellAttributes: { alignment: 'center' }
    },
    {
        label: 'QuickStock',
        fieldName: 'Quick_Stock__c',
        type: 'boolean',
        //sortable: true,
        cellAttributes: { alignment: 'center' }
    },
    {
        label: 'Shipment Date',
        fieldName: 'Shipment_Date__c',
        type: 'date',
        //sortable: true,
        hideDefaultActions: true,
        iconName: 'utility:date_input',
        cellAttributes: { alignment: 'center' }
    },
    {
        label: 'Return Qty',
        fieldName: 'Disputed_Qty__c',
        iconName: 'utility:number_input',
        type: 'number',
        //editable: true,
        sortable: true
    },

    {
        label: 'Action',
        fieldName: 'Requested_Action_Override__c',
        iconName: 'utility:button_choice',
        wrapText: true,
        type: 'picklist',
       // editable: true,
       // sortable: true,
        typeAttributes: {
            placeholder: 'Choose Action', options: [
                { label: 'Return', value: 'Return' },
                { label: 'Replacement', value: 'Replacement' },
                { label: 'Return and Replacement', value: 'Return and Replacement' },
            ] // list of all picklist options
            , value: { fieldName: 'Return' }
            , context: { fieldName: 'Id' } }// default value for picklist
            
    },
    
    {
        type: 'button-icon',
        initialWidth: 34,
        typeAttributes:{
            label: 'Edit',
            name: 'edit',
            rowActions: actions,
            title: 'edit',
            iconName: 'utility:new',
            class: 'buttonIcon',
            variant: 'brand',
            disabled: {fieldName: 'actionDisabled'},
            
        },
        cellAttributes:{
            disabled: {fieldName: 'actionDisabled'}
        }
        
        /*type: 'action',
        typeAttributes: { rowActions: actions },
        cellAttributes: { iconName: 'utility:edit' }*/
    },

    ]; 
    //--------END COLUMNS FOR ORDER LINE ITEM SELECTION SCREEN

    
    // COLUMNS FOR THE VIEW CART MODAL
            @track cartColumns = [{
                label: 'Catalog #',
                fieldName: 'Product_SKU__c',
                iconName: 'utility:products',
                type: 'Text',
                sortable: true
            },
            {
                label: 'SKU #',
                fieldName: 'SKU__c',
                type: 'Text',
                sortable: true,
                cellAttributes: { alignment: 'center' }
            },
            {
                label: 'PO#',
                fieldName: 'PO__c',
                type: 'Number',
                sortable: true,
                cellAttributes: { alignment: 'center' }
            },
            {
                label: 'Qty',
                fieldName: 'Quantity__c',
                type: 'Number',
                sortable: true,
                cellAttributes: { alignment: 'center' }
            },
            {
                label: 'Unit Price',
                fieldName: 'UnitPrice__c',
                iconName: 'utility:money',
                type: 'currency',
                sortable: true
            },
            /*{
                label: 'Distributor Name',
                fieldName: 'Distributor_Name__c',
                type: 'Text',
                sortable: true,
                cellAttributes: { alignment: 'center' }
            },*/
            {
                label: 'UOM',
                fieldName: 'UnitOfMeasure__c',
                iconName: 'utility:slider',
                type: 'text',
                //sortable: true,
                cellAttributes: { alignment: 'center' }
            },
            {
                label: 'Quick Stock',
                fieldName: 'Quick_Stock__c',
                type: 'boolean',
                sortable: true,
                cellAttributes: { alignment: 'center' }
            },
            {
                label: 'Shipment Date',
                fieldName: 'Shipment_Date__c',
                iconName: 'utility:date_input',
                type: 'date',
                sortable: true,
                cellAttributes: { alignment: 'center' }
            },
            {
                label: 'Return Qty',
                fieldName: 'Return_Qty__c',
                type: 'number',
                sortable: true
            },
            {
                label: 'Req. Action Override',
                fieldName: 'Requested_Action_Override__c',
                iconName: 'utility:button_choice',
                type: 'picklist',
                //editable: true,
                sortable: true,
                typeAttributes: {
                    placeholder: 'Choose Action', options: [
                        { label: 'Return', value: 'Return' },
                        { label: 'Replace', value: 'Replace' },
                        { label: 'Return & Replace', value: 'Return & Replace' },
                    ] // list of all picklist options
                    , value: { fieldName: 'Return' } // default value for picklist
                    , context: { fieldName: 'Id' }}
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
    //--------END COLUMNS FOR THE VIEW CART MODAL
    
     @track cartLabel;
     @track tempList = [];    
     @api cartCount = 0;
     @api transactionID;
     @track bShowModal = false;
     @track bShowModal1 = false;
     @track currentRecordId;
     @track currentRecordDtl;
     @track isEditForm = false;
     @api storedLines;
     @api getorder;
     @track isOrderIdAvailable = false;
     @track flagIndi = false;
     //@track orderId='';
     draftValues = [];
     @track error;
     @track orderItemList=[];
     @track orderItemNewList;
     @api selectedOrder;
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
     @track isLoading = false;
     @track transactionTotal = 0.00;
     @track clear;
     //@api value1; //using this field to pass on the review page


     @wire(getRecord, {
        recordId: USER_ID,
        fields: [NAME_FIELD]
    }) wireuser({
        error,
        data
    }) {
        if (error) {
        this.error = error ; 
        } else if (data) {
            this.reqName = data.fields.Name.value;

            console.log("Param Check Outside" + this.paramString);

            
            if(this.paramString.length()>0){
            console.log("Param String Check" +this.paramString);

            var inputord=this.paramString;
            this.template.querySelector("c-order-search-custom").setConfirmValues(inputord);
            }
              
            
        }
    }
    
    connectedCallback(){
        /*const id = 'id' + performance.now();
        this.transactionID = id;
        console.log('Generated ID: '+ id); */

         //Code change for order id default
         this.sfdcOrgURL = window.location.href;
         if(this.sfdcOrgURL.includes('id=')==true){
             this.paramString = this.sfdcOrgURL.split('id=')[1];

             if(this.paramString.length > 0){
               // var inputord=this.paramString;
               // console.log("The Param Value"+ inputord);
               // this.template.querySelector("c-order-search-custom").setConfirmValues(inputord);
                this.handleChangeNew();
            } 

             
         }
    } 

    confirmchange(event){
        this.distLines = event.detail.selectedRecordId;
        this.distAccName=event.detail.selectedValue;
        console.log('The lines passed to child for Ordering: '+this.distLines);
        this.disAccount = this.distLines;
        if(this.distAccName==null){
            this.disName=[];
        }
        else{
        this.disName = this.distAccName;
        }
        console.log('The lines passed to child for Delivery: '+this.disAccount);
        console.log('The lines passed to child for Delivery: '+this.disName);
    
    }

     /*handleChange(event) {
        // Creates the event
        const selectedEvent = new CustomEvent('valueselected', {
            detail: event.detail.value
        });
        //dispatching the custom event
        this.dispatchEvent(selectedEvent);
    }*/

   /* selectedOrder ='';

    @wire(getOrderItemList, {orderId: '$selectedOrder'})
    wiredOrderItems({ error, data }) {
       if (data) {
           console.log('The ORDER ID SENT TO APEX is:'+this.orderId);
           this.orderItemList  = data;
           this.isOrderIdAvailable = true;
           this.error = undefined;
       } else if (error) {
           console.log('The ORDER ID SENT TO APEX is:'+this.orderId);
           this.error = error;
           this.data  = undefined;
       }
   }

   handleChange(event) {
        console.log("You selected an order: " + event.target.value);
        //this.selectedOrder = event.detail.value[0];
       // this.selectedOrder = selectedOrder;
       const selectedOrder = event.target.value;
       console.log("You selected an order to pass: " + selectedOrder);
        this.selectedOrder = selectedOrder;

   } */

   cartActions(event){
        const actionName = event.detail.action.name;
        const row = event.detail.row;

        console.log('Delete ActionName: '+ actionName);
        console.log('Delete Row: '+ JSON.stringify(row));
        switch (actionName) {
            case 'delete':
                this.deleteCurrentRecord(row);
                break;
            default:
        }
   }

   deleteCurrentRecord(currentRow){
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
   }

   clearCart(event){
    for(var i = 0, len = this.storedLines.length; i < len; i++){
        deleteRecord (this.storedLines[i].Id)
        .then(() => {
            
            
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
   }

   handleRowActions(event) {
    this.cartLabel = "Add to Request";
    const actionName = event.detail.action.name;
    const row = event.detail.row;

    let rowQuantityValue = event.detail.row.Quantity;
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
            this.editCurrentRecord(row);
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

// closing modal box
closeModal1() {
    this.bShowModal1 = false;
}

editCurrentRecord(currentRow) {
    // open modal box
    this.bShowModal1 = true;
    this.isEditForm = true;

    // assign record id to the record edit form
    this.errorMessage = "";
    this.currentRecordId = currentRow.Id;
}

 // handleing record edit form submit
 handleSubmit(event) {
     this.isLoading = true;
     let returnQty = this.template.querySelector('.dq').value;
     console.log('Return Qty: '+returnQty);
     console.log('Row Quantity: '+this.rowQuantity);
     console.log('Available for Return: '+this.rowAvailForReturn);

     if(this.rowReturnTotal = 0 && returnQty > this.rowQuantity){
         this.isLoading = false;
        event.preventDefault();
        this.errorMessage = "ERROR: Dispute Quantity cannot be more than the Order Quantity:  "+this.rowQuantity;
        this.cartLabel = "Add to Request";

     }else if (this.rowAvailForReturn > 0 && returnQty > this.rowAvailForReturn){
         this.isLoading = false;
        event.preventDefault();
        this.errorMessage = "ERROR: Dispute Quantity cannot be more than Available for Return of "+this.rowAvailForReturn;
        this.cartLabel = "Add to Request";
     }else if (this.rowAvailForReturn == 0 && returnQty > 0) {
         this.isLoading = false;
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

 }
 
 

// refreshing the datatable after record edit form success
async handleSuccess() {
   await getOrderItemRefList({orderId: this.selectedOrder}) 
           .then(result => {
               this.orderItemList = result;
               console.log(result);
               console.log('After refresh datatable data: ' + JSON.stringify(this.orderItemList));
               this.ShowToastMsg('Success', 'Order Details Updated')
                // closing modal
                this.bShowModal1 = false;
           });
       this.handleClick(); 
}



    async handleChange(event) {
        //console.log("You selected an order: " + event.detail.value[0]);
        //this.selectedOrder = event.detail.value[0];
        this.selectedOrder =  event.detail.selectedRecordId;

        console.log("You selected Order: " + this.selectedOrder);
            //this.selectedOrder = event.detail.data.selectedId;

        //console.log("Type of" +typeof(selectedOrder));
        console.log('Value for Distributor Name: '+this.disName);
        if(this.disName.length >0){
        await updDisName({orderId: this.selectedOrder, disName: this.disName})
        .then(result => {
            console.log(JSON.stringify("The Result from APEX is: "+ JSON.stringify(result)));
        });
        }
        

        await getOrderItemList({orderId: this.selectedOrder})
        .then(result => {
            console.log(JSON.stringify("The Result from APEX is: "+ JSON.stringify(result)));
            


            //this.orderItemList  = result;

            this.tempList = [];
            if(result){
            for (const orders of result){
                const clone = Object.assign({}, orders);
                console.log('JSON of Orders: '+JSON.stringify(orders));
                if(clone.Available_for_Return__c == 0){
                    console.log('Record Available for Return: '+clone.Available_for_Return__c);
                    clone.actionDisabled = true;
                }

                this.tempList.push(clone);
            }
        }
            this.orderItemList = this.tempList;
            console.log(JSON.stringify("The Result from APEX is: "+ JSON.stringify(this.orderItemList)));
            this.isOrderIdAvailable = true;
            console.log('Is Order Available: '+this.isOrderIdAvailable);
            this.dispatchEvent(
                new CustomEvent('orderaccount', {
                    detail: {
                        account : result[0].Order.Agent_Account__c
                    }
                }));
           
            //this.error = undefined;          
    
        }).catch(error => {
            console.log("The error SENT TO APEX is: " +JSON.stringify(error));
            this.error = error;
            //this.data  = undefined;
        });
        
        //this.template.querySelector('c-confirmation-details').displayValues(this.selectedOrder);
    } 

    async handleChangeNew(event) {
        this.selectedOrder = this.paramString;
  
        await getOrderItemList({orderId: this.selectedOrder})
        .then(result => {
            console.log(JSON.stringify("The Result from APEX is: "+ JSON.stringify(result)));
            //this.orderItemList  = result;
            this.tempList = [];
            if(result){
            for (const orders of result){
                const clone = Object.assign({}, orders);
                console.log('JSON of Orders: '+JSON.stringify(orders));
                if(clone.Available_for_Return__c == 0){
                    console.log('Record Available for Return: '+clone.Available_for_Return__c);
                    clone.actionDisabled = true;
                }

                this.tempList.push(clone);
            }
        }
            this.orderItemList = this.tempList;
            console.log(JSON.stringify("The Result from APEX is: "+ JSON.stringify(this.orderItemList)));
            this.isOrderIdAvailable = true;
                
    
        }).catch(error => {
            console.log("The error SENT TO APEX is: " +JSON.stringify(error));
            this.error = error;
            
        }); 
    }




     //Save button action code 
     /*async handleSave(event) {
        const updatedFields = event.detail.draftValues;
        
        // Prepare the record IDs for getRecordNotifyChange()
        const notifyChangeIds = updatedFields.map(row => { return { "recordId": row.Id } });
    
       // Pass edited fields to the updateOrder details Apex controller
        await updateOrderItemList({data: updatedFields})
        .then(result => {
            console.log(JSON.stringify("Apex update result: "+ result));
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Order updated',
                    variant: 'success'
                })
            );
    
        // Refresh LDS cache and wires
        getRecordNotifyChange(notifyChangeIds);
    
        // Display fresh data in the datatable
        refreshApex(this.orderitem).then(() => {
            // Clear all draft values in the datatable
            this.draftValues = [];
          });
    
        
       }).catch(error => {
           this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error updating or refreshing records',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        });
    }*/

    //Selection of records code

    /*handleSelect( event ) {

        const selRows = event.detail.selectedRows;
        console.log( 'Selected Rows are ' + JSON.stringify ( selRows ) );
      
        this.selectedRows = selRows;

    }*/

    clearResults(event){
        this.clear = event.detail.clear;
        console.log('CLEAR: '+this.clear);
        if(this.clear == "true"){
            this.orderItemList = [];
            this.isOrderIdAvailable = false;
        }
    }

    handleSave(event){
        console.log(event.detail.draftValues)
        const recordInputs = event.detail.draftValues.slice().map(draft=>{
            const fields = Object.assign({}, draft)
            return {fields}
        })
        console.log("recordInputs", recordInputs)

        const promises = recordInputs.map(recordInput => updateRecord(recordInput))
        Promise.all(promises).then(result=>{
            this.ShowToastMsg('Success', 'Order Details Updated')
           this.draftValues=[];   
           console.log('Before Refresh: '+ JSON.stringify(this.orderItemList));
           console.log('Check for Refresh: '+ this.selectedOrder);
           //return refreshApex(this.orderItemList);

           getOrderItemRefList({orderId: this.selectedOrder}) 
           .then(result => {
               this.orderItemList = result;
               console.log(result);
               console.log('After refresh datatable data: ' + JSON.stringify(this.orderItemList));
           });
           
          

        }).catch(error=>{
            this.ShowToastMsg('Error Updating Records', error.body.message, error)
        });
        //this.handleClick();
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


        var newselval = selected.map(row => { return { "Order__c": row.OrderId, "Product_SKU__c": row.SKU_Description_Cat_Logic__c, "PO__c": row.PO__c, "Quantity__c": row.Quantity, "UnitPrice__c": row.UnitPrice,
            "Product_Name__c":row.Product_Name__c,"Quick_Configure__c":row.Quick_Configure__c,"Quick_Stock__c":row.Quick_Stock__c, "SKU__c":row.SKU__c, "Type__c":"Return/Replace", "UnitOfMeasure__c": row.UnitOfMeasure__c,
            "Shipment_Date__c":row.Shipment_Date__c,"Return_Qty__c": row.Disputed_Qty__c,"Requested_Action_Override__c":row.Requested_Action_Override__c, "Distributor_Name__c": row.Distributor_Name__c, "Request_Action__c": this.headerAction,
            "Order_Product_Id__c":row.Id, "Transaction_ID__c": this.transactionID, "Unique_ID__c": this.transactionID+'_'+row.SKU__c, "Distributor_Name__c":row.Distributor_Name__c, "Distributor_Id__c":this.distLines
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
     fetchReturnItems(){
        getReturnList({transId : this.transactionID})
            .then(result =>{
                this.storedLines = result;
                this.cartCount = this.storedLines.length;
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
            
        });
     }


    showWarranty(event){
        this.warrantyEntry = true;
        this.isOrderIdAvailable = false;
    } 

    showCart(event) {
        this.bShowModal = true; // display modal window
    }

    // to close modal window set 'bShowModal' tarck value as false
    closeModal() {
        this.bShowModal = false;
    } 

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

    orderProto = {
        get isNoAvail() {
            return result.Available_for_Return__c == 0;
        }
    }

}