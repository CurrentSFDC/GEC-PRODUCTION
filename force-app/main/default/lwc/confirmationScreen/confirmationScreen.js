import { LightningElement, api, track, wire } from 'lwc';
import getReturnOrderItemList from '@salesforce/apex/OrderProductController.getReturnOrderItemList';
import deleteReturnItemList from '@salesforce/apex/OrderProductController.delReturnItems';
import displayUpdatedList from '@salesforce/apex/OrderProductController.displayUpdatedList';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


const actions = [
    { label: 'Delete', name: 'delete' },
];

export default class ConfirmationDetails extends LightningElement {

@api columns;

@track ordercolumns = [
    {
        label: 'Invoice #',
        fieldName: 'Invoice__c',
        iconName: 'utility:form',
        type: 'Text',
        sortable: true 
    },
    {
        label: 'PO#',
        fieldName: 'PO__c',
        type: 'Text',
        sortable: true 
    },
    {
        label: 'Catalog #',
        fieldName: 'Product_SKU__c',
        type: 'Text',
        iconName: 'utility:products',
        sortable: true 
    },
    {
        label: 'SKU #',
        fieldName: 'SKU__c',
        type: 'Text',
        iconName: 'utility:products',
        sortable: true 
    },
    {
        label: 'Order Qty',
        fieldName: 'Quantity__c',
        type: 'Number',
        iconName: 'utility:number_input',
        sortable: true,
        cellAttributes: { alignment: 'center' }
    },
    {
        label: 'Unit Price',
        fieldName: 'UnitPrice__c',
        type: 'currency',
        iconName: 'utility:money',
        sortable: true
    },
    /*{
        label: 'Distributor Name',
        fieldName: 'Distributor_Name__c',
        type: 'Text',
        sortable: true,
        cellAttributes: { alignment: 'center' }
    },*/
    /*{
        label: 'Product Name',
        fieldName: 'Product_Name__c',
        type: 'formula(Text)',
        sortable: true
    }, */
    {
        label: 'UOM',
        fieldName: 'UnitOfMeasure__c',
        iconName: 'utility:slider',
        type: 'text',
        sortable: true,
        cellAttributes: { alignment: 'center' }
    },
    {
        label: 'QuickStock',
        fieldName: 'Quick_Stock__c',
        type: 'boolean',
        sortable: true,
        cellAttributes: { alignment: 'center' }
    },
    {
        label: 'Shipment Date',
        fieldName: 'Shipment_Date__c',
        type: 'date',
        sortable: true,
        cellAttributes: { alignment: 'center' }
    },
    {
        label: 'Return Qty',
        fieldName: 'Return_Qty__c',
        iconName: 'utility:number_input',
        type: 'Text',
        sortable: true
    },
    {
        label: 'Action',
        fieldName: 'Requested_Action_Override__c',
        type: 'picklist',
        //editable: true,
        sortable: true,
        typeAttributes: {
            placeholder: 'Choose Action', options: [
                { label: 'Return', value: 'Return' },
                { label: 'Replace', value: 'Replace' },
                { label: 'Return & Replace', value: 'Return & Replace' },
            ] // list of all picklist options
            , value: { fieldName: 'Requested_Action_Override__c' } // default value for picklist
            , context: { fieldName: 'Id' }}},

          /*  {
                type: 'button-icon',
                initialWidth: 34,
                typeAttributes:{
                    label: 'Delete',
                    name: 'delete',
                    rowActions: actions,
                    title: 'delete',
                    iconName: 'utility:delete',
                    variant: 'brand'
                }
            }*/

            /*{
                type: 'action',
                typeAttributes: { rowActions: actions },
            },*/
    
    ];



//@api item;
@track orderItemList = [];
@track productList=[];
@track error;
@track val;
@track data;
@track isOrderIdAvailable=false;
@track isProductIdAvailable = false;

@api 
get item() {
    return this._item;
}

set item(value) {
    this._item = value;
    this.connectedCallback();
}


/*@api 
get prditem() {
    return this._prditem;
}

set prditem(value) {
    this._prditems = value;
    this.connectedCallback();
}*/

connectedCallback() {

   var val= this._item;
    console.log("Lines Passed to Confirmation Screen: " + JSON.stringify(val));
   // window.sessionStorage.setItem('newvalue', val);
  //  var data = window.sessionStorage.getItem('newvalue');
   // console.log("The child data "+ JSON.stringify(data));
    this.orderItemList = val;
    this.isOrderIdAvailable = true;

    /*var prdval = this._prditem;
    console.log("Lines Passed to Confirmation Screen for Product: " + JSON.stringify(prdVal));
    this.productList = prdval;
    this.isProductIdAvailable = true;*/

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


handleRowAction(event) {
    const actionName = event.detail.action.name;
    const row = event.detail.row;
    console.log('Delete ActionName: '+ actionName);
    console.log('Delete Row: '+ JSON.stringify(row));
    switch (actionName) {
        case 'delete':
            this.deleteRow(row);
            break;
        case 'show_details':
            this.showRowDetails(row);
            break;
        default:
    }
}

deleteRow(row) {

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
       
        displayUpdatedList({transId: newRow})
        .then(result => {
        
        console.log(JSON.stringify("Apex update result: "+ result));
        this.orderItemList = result;
        this.isOrderIdAvailable = true;
        });
    
});
}

}