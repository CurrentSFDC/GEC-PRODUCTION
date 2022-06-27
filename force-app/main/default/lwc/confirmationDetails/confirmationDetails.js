import { LightningElement, api, track, wire } from 'lwc';
import getReturnOrderItemList from '@salesforce/apex/OrderProductController.getReturnOrderItemList';


export default class ConfirmationDetails extends LightningElement {

    @track productColumns = [{
        label: 'Catalog #',
        fieldName: 'Product_SKU__c',
        type: 'Text',
        sortable: true
    },
    {
        label: 'Product Description',
        fieldName: 'Product_Description__c',
        type: 'Text',
        sortable: true
    },
    /* {
        label: 'Quantity Per Unit',
        fieldName: 'ccrz__Quantityperunit__c',
        type: 'Number',
        sortable: true
    },*/
    {
        label: 'Selected Quantity',
        fieldName: 'Selected_Qty__c',
        type: 'Text',
        sortable: true
    }];
    
    
    //@api item;    
    @track productList=[];
    @track error;
    @track val;
    @track data;
    @track isProductIdAvailable = false;
    
    @api 
    get item() {
        return this._item;
    }
    
    set item(value) {
        this._item = value;
        this.connectedCallback();
    }
    connectedCallback() {

    var val= this._item;
    console.log("Value passed from Parent Comp: " + JSON.stringify(val));
   // window.sessionStorage.setItem('newvalue', val);
  //  var data = window.sessionStorage.getItem('newvalue');
   // console.log("The child data "+ JSON.stringify(data));
    this.productList = val;
    this.isProductIdAvailable = true;
}
   /* getReturnOrderItemList({orderId: data})
        .then(result => {
            console.log("The Result from APEX for Return: "+ JSON.stringify(result));
            this.orderItemList  = result;
            this.isOrderIdAvailable = true;
            //this.error = undefined;          
    
        }).catch(error => {
            console.log("The error SENT TO APEX is: " +JSON.stringify(error));
            this.error = error;
            //this.data  = undefined;
        });
}*/

}