import { LightningElement, track, api, wire } from 'lwc';


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

const actions = [
    { label: 'Edit', name: 'edit'},
    { label: 'Delete', name: 'delete'}
];

export default class TestOrderSearch extends LightningElement {

    @track cartLabel;
    @track sfdcOrgURL;
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
        label: 'Inv. Price',
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
        label: 'QuickConfigure',
        fieldName: 'Quick_Configure__c',
        type: 'boolean',
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

            //console.log("Param Check Outside" + this.paramString);

            
           /* if(this.paramString.length > 0){
            console.log("Param String Check" +this.paramString);

            var inputord=this.paramString;
            this.template.querySelector("c-test-order-lookup").setConfirmValues(inputord);
            }*/
              
            
        }
    }

    /*connectedCallback(){
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
    }*/

    clearResults(event){
        this.clear = event.detail.clear;
        console.log('CLEAR: '+this.clear);
        if(this.clear === "true"){
            this.isOrderIdAvailable = false;
            this.orderItemList = [];
        }
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




    async handleChange(event) {
        //console.log("You selected an order: " + event.detail.value[0]);
        //this.selectedOrder = event.detail.value[0];
        this.isLoading = true;
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
        this.isLoading = false;
        //this.template.querySelector('c-confirmation-details').displayValues(this.selectedOrder);
    } 
}