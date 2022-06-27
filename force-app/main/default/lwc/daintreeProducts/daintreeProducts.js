import {LightningElement,api,wire,track} from 'lwc';
import getAccountData from '@salesforce/apex/DaintreeProducts.getSortedOrders';
import getOrderData from '@salesforce/apex/DaintreeProducts.getAllOrders';
import { getRecord } from 'lightning/uiRecordApi';
import ORDER_NUMBER_FIELD from '@salesforce/schema/Order.OrderNumber';

// USED FOR COLUMNS IN THE MODAL - ORDER PRODUCTS DATA TABLE
const columns = [
    {
        label: 'ORDER LINE #',
        fieldName: 'Order_Line_Number__c', 
        //initialWidth: 20,
        type: 'text',
        sortable: true
    },
    {
        label: 'SKU',
        fieldName: 'SKU__c', 
        //initialWidth: 20,
        type: 'text',
        sortable: true
    },
    {
        label: 'DESCRIPTION',
        fieldName: 'SKU_Description_Cat_Logic__c', 
        //initialWidth: 20,
        type: 'text',
        sortable: true
    },
    {
        label: 'QUANTITY',
        fieldName: 'Quantity', 
        //initialWidth: 20,
        type: 'number',
        sortable: true,
        cellAttributes:{
            alignment: 'left'
        }
    },
    {
        label: 'UNIT PRICE',
        fieldName: 'UnitPrice', 
        //initialWidth: 20,
        type: 'currency',
        sortable: true,
        cellAttributes:{
            alignment: 'left'
        }
        
    },
    {
        label: 'TOTAL PRICE',
        fieldName: 'TotalPrice', 
        //initialWidth: 20,
        type: 'currency',
        sortable: true,
        cellAttributes:{
            alignment: 'left'
        }
    }
 ];
 

export default class AccordionEx extends LightningElement {
@track multiple = true;
@api recordId;
@track accounts ;
@track data = [];
@track orderID;
@track trackers;
@track record = [];
@track bShowModal = false;
@track currentRecordId;

//------USED FOR MODAL DATA TABLE
@track page = 1; //this is initialize for 1st page
@track orderlines = [];
@track startingRecord = 1; //start record position per page
@track endingRecord = 0; //end record position per page
@track pageSize = 5; //default value we are assigning
@track totalRecountCount = 0; //total record count received from all retrieved records
@track totalPage = 0; //total number of page is needed to display all records

@track columns;

// USED TO GET THE CSM TRACKER RECORDS AND DATA POINTS --> APEX CLASS: DaintreeProducts  METHOD: getSortedOrders
@wire(getAccountData, {assetRecId: '$recordId'}) 
wiredAccountss({
    error,
    data
}) {
    if (data) {
        this.accounts = data;
        window.console.log(JSON.stringify(data, null, '\t'));
        window.console.log(data.id);
        data.forEach(function (item, key) {
            window.console.log('Key: '+key); 
            window.console.log('Item: '+item); 
        });
        
    } else if (error) {
        this.error = error;
    }
}

// USED TO GET ORDER LINE DATA BASED ON CSM TRACKER ORDER FIELD --> APEX CLASS DaintreeProducts  METHOD: getAllOrders
@wire(getOrderData, {orderId: '$orderID'}) 

wiredOrder({
    error,
    data
}) {
    if (data) {
        window.console.log('The ORDER ID SENT TO APEX is:'+this.orderId);
        this.orderlines = data;
        this.totalRecountCount = data.length;
        this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize); //here it is 5
            
            //initital data to be displayed ----------->
            //slice will take 0th element and ends with 5, but it doesn't include 5th element
            //so 0 to 4th rows will be display in the table
            this.data = this.orderlines.slice(0,this.pageSize); 
            this.endingRecord = this.pageSize;
            this.columns = columns;
            this.error = undefined;
        window.console.log(JSON.stringify(data, null, '\t'));
        window.console.log(data.id);
        data.forEach(function (item, key) {
            window.console.log('Key: '+key); 
            window.console.log('Item: '+item); 
        });
        
    } else if (error) {
        this.error = error;
        this.data = undefined;
    }
}
@wire(getRecord, { recordId: '$orderID', fields: [ORDER_NUMBER_FIELD] })
record;

get orderNumber() {
    return this.record.data.fields.OrderNumber.value;
}

// Row Action event to show the details of the record
handleClick(event) {
    const orderID = event.target.value;
    window.console.log('The ORDER ID is:'+orderID);
    this.orderID = orderID;
    //this.record = orderID;
    this.bShowModal = true; // display modal window
}

// to close modal window set 'bShowModal' tarck value as false
closeModal() {
    this.bShowModal = false;
} 


//--------- CODE BLOCK FOR PAGINATION ON PARENT COMPONENT ---------->
//clicking on previous button this method will be called
previousHandler() {
    if (this.page > 1) {
        this.page = this.page - 1; //decrease page by 1
        this.displayRecordPerPage(this.page);
    }
}

//clicking on next button this method will be called
nextHandler() {
    if((this.page<this.totalPage) && this.page !== this.totalPage){
        this.page = this.page + 1; //increase page by 1
        this.displayRecordPerPage(this.page);            
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

    this.data = this.orderlines.slice(this.startingRecord, this.endingRecord);

    //increment by 1 to display the startingRecord count, 
    //so for 2nd page, it will show "Displaying 6 to 10 of 23 records. Page 2 of 5"
    this.startingRecord = this.startingRecord + 1;
}    




}