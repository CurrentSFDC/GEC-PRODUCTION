import { LightningElement, api, track } from 'lwc';
import getAccName from '@salesforce/apex/connectCreateCase.getAccountName';

export default class WarrantyClaimChildLWC extends LightningElement {

    @api Account;
    @track accountName;
    @api requestorName;
    @api requestorEmail;
    @api requestorPhone;
    @api returnReason;
    @api secondaryReason;
    @api requestedAction;
    @api comments;
    @api warrantyColumns;
    @api SiteName;

    @track endUserAddressStreet;
    @track endUserAddressCity;
    @track endUserAddressState;
    @track endUserAddressPostalCode;
    @track endUserAddressCountry;

    @track endUserName;
    @track endUserEmail;
    @track endUserPhone;

    @track orderItemList = [];
    @track val;
    @track isOrderIdAvailable = false;

    @track columns = [{
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
        sortable: true
    },
    {
        label: 'NoCAT #',
        fieldName: 'NoCAT__c',
        type: 'Text',
        sortable: true
    },
    {
        label: 'PO #',
        fieldName: 'PO__c',
        type: 'Text',
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
        label: 'Qty',
        fieldName: 'Quantity',
        iconName: 'utility:number_input',
        type: 'number',
        sortable: true
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
        label: 'Date Installed',
        fieldName: 'Date_Installed__c',
        iconName: 'utility:date_input',
        type: 'date',
        sortable: true,
        cellAttributes: { alignment: 'center' }
    },
    {
        label: 'Installed',
        fieldName: 'Installed_Qty__c',
        iconName: 'utility:number_input',
        type: 'number',
        sortable: true,
        cellAttributes: { alignment: 'center' }
    },
    {
        label: 'Failed',
        fieldName: 'No_Of_Products_Failed__c',
        iconName: 'utility:number_input',
        type: 'number',
        sortable: true,
        cellAttributes: { alignment: 'center' }
    },

    {
        label: 'Action Override',
        fieldName: 'Requested_Action_Override__c',
        iconName: 'utility:button_choice',
        type: 'Text',
        cellAttributes: { alignment: 'center' },
        sortable: true,
    },

    ]; 


    @track mapMarker =[];
    mapOptions = {
                'disableDefaultUI': true, // when true disables Map|Satellite, +|- zoom buttons
                'draggable': false, // when false prevents panning by dragging on the map
    };
    
    // Comment duplicate mapOptions object By Sameer on (4/22/2021)
    /*mapOptions = {
          'disableDefaultUI': true, // when true disables Map|Satellite, +|- zoom buttons
          'draggable': false, // when false prevents panning by dragging on the map
        };*/

    @api setConfirmValues(inputData){
        this.Account=inputData.Account;
        getAccName({id_dtl: this.Account})
            .then(result => {
            this.accountName = result;
            console.log(JSON.stringify("The Result for Case Number: "+ JSON.stringify(this.accountName)))
        });
        this.requestorName=inputData.RequestorName;
        this.comments=inputData.Comments;
        this.requestorEmail=inputData.RequestorEmail;
        this.requestorPhone=inputData.RequestorPhone;
        this.returnReason=inputData.ReturnReason;
        this.requestedAction=inputData.RequestedAction;
        this.secondaryReason=inputData.SecondaryReason;
        this.endUserEmail=inputData.EndUserEmail;
        this.endUserName=inputData.EndUserName;
        this.endUserPhone=inputData.EndUserPhone;
        this.endUserAddressStreet=inputData.EndUserAddressStreet;
        this.endUserAddressCity=inputData.EndUserAddressCity;
        this.endUserAddressState=inputData.EndUserAddressState;
        this.endUserAddressPostalCode=inputData.EndUserAddressPostalCode;
        this.endUserAddressCountry=inputData.EndUserAddressCountry;
        this.SiteName=inputData.SiteName;

        // this.mapMarker = [...this.mapMarker ,
        // {
        //     location: {
        //         City: this.endUserAddressCity,
        //         State: this.endUserAddressState,
        //     }
        // }]
        
        // Update mapMarker object for double location added in map & comment above object By Sameer on (4/22/2021)
        this.mapMarker = [
        {
            location: {
                City: this.endUserAddressCity,
                Country: this.endUserAddressCountry,
                PostalCode: this.endUserAddressPostalCode,
                State: this.endUserAddressState,
                Street: this.endUserAddressStreet
            }
        }]
    };

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


}