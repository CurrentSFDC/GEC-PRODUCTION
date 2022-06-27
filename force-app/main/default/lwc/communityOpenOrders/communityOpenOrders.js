import {LightningElement, wire, track, api} from 'lwc';
import getOpenOrders from '@salesforce/apex/communityOpenClass.getOpenOrders';

import {
    subscribe,
    unsubscribe,
    APPLICATION_SCOPE,
    MessageContext
} from 'lightning/messageService';
import recordSelected from '@salesforce/messageChannel/selectedAccount__c';
import openOrder from '@salesforce/contentAssetUrl/geciconordersWT';

export default class CommunityOpenOrders extends LightningElement {

    opendOrder = openOrder;
    @track selectedID;
    @track userType;
    @track distributorID;
    @track distributorName;
    @track distributorNumber;
    @track agentNumber;
    @track isLoading = true;
    

    @track orderColumns = [{
        label: 'Order #',
        fieldName: 'recordLink',
        type: 'url',
        typeAttributes: {label: {fieldName: "GE_Order_NO__c"}, tooltip: "Name", target: "_self"},
        cellAttributes: {alignment: 'right'}
    },
        {
            label: 'Order Date',
            fieldName: 'EffectiveDate',
            type: 'date-local',
            //sortable: true,
            cellAttributes: {alignment: 'right'}
        },
        {
            label: 'PO #',
            fieldName: 'Customer_PO_Number__c',
            type: 'Text',
            //sortable: true,
            cellAttributes: {alignment: 'left'}
        },
        /*{
            label: 'Current Order #',
            fieldName: 'GE_Order_NO__c',
            type: 'Text',
            sortable: true,
            cellAttributes: { alignment: 'center' }
        },*/
        {

            label: 'Order Amount',

            fieldName: 'Grand_Total__c',

            type: 'currency',

            //sortable: true,

            typeAttributes: { currencyCode: { fieldName: 'CurrencyIsoCode' } },

            cellAttributes: {alignment: 'right'}

        }
    ];

    @track orderItems = [];
    @track orderItemsMessage;
    @track message = 'No Data Found.';
    @track buttonLabel;

    @wire(MessageContext)
    messageContext;

    // Encapsulate logic for Lightning message service subscribe and unsubsubscribe
   async subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                recordSelected,
                (message) => this.handleMessage(message),
                {scope: APPLICATION_SCOPE}
            );
        }
    }

    async handleMessage(message) {
        this.isLoading = true;
        console.log('HANDLING MESSAGE IN OPEN ORDERS WIDGET....');
        this.selectedID = message.recordId;
        this.userType = message.userType;
        this.distributorID = message.distributorID;
        this.distributorName = message.distributorName;
        this.distributorNumber = message.distributorNumber;
        this.agentNumber = message.agentNumber;
        console.log('Open Orders - Agent Account ID passed from Component: '+this.selectedID);
        console.log('Open Orders - Agent Account Number passed from Component: '+this.agentNumber);
        console.log('Open Orders - Distributor Account ID passed from Component: '+this.distributorID); // ID OF THE DISTRIBUTOR
        console.log('Open Orders - Distributor Account Name passed from Component: '+this.distributorName); // NAME OF THE DISTRIBUTOR
        console.log('Open Orders - Distributor Account Number passed from Component: '+this.distributorNumber); // SAP CUSTOMER NUMBER OF THE DISTRIBUTOR
        await getOpenOrders({accountId: this.selectedID, distributorId : this.distributorID, userType : this.userType}) 
            .then(result => {
                if (result.length > 0) {
                    this.buttonLabel = "View All";
                    var tempOrderList = [];
                    for (var i = 0; i < result.length; i++) {
                        let tempRecord = Object.assign({}, result[i]);
                        //tempRecord.recordLink = "/Agents/s/order" + "/" + tempRecord.Id; // STAGE
                        tempRecord.recordLink = "/s/order" + "/" + tempRecord.Id; // PRODUCTION
                        tempOrderList.push(tempRecord);
                    }
                    this.isLoading = false;
                    this.orderItems = tempOrderList;
                    this.orderItemsMessage = '';
                    console.log('Orders Returned: '+JSON.stringify(this.orderItems));
                } else {
                    
                    this.isLoading = false;
                    this.orderItemsMessage = 'No Open Orders Found.';
                    this.buttonLabel = "View History";
                }
            }).catch(error => {
            console.error(error);
            this.isLoading = false;
            this.orderItemsMessage = "No Open Orders Found.";
            this.buttonLabel = "View History";
        });

    }

    renderedCallback() {
        this.subscribeToMessageChannel();
        const style = document.createElement('style');
        style.innerText = `c-community-open-orders .slds-card__header {
            background-color: #5f82b6;
            width: 100%;
            align: center;
            color: white;
            font-family: 'Segoe UI';
            padding: 10px;
        }`;
        this.template.querySelector('lightning-card').appendChild(style);

        const styleHeader = document.createElement('style');
        styleHeader.innerText = `c-community-open-orders .slds-text-heading_small {
            width: 100%;
            font-family: 'Segoe UI';
            font-weight: bold;
            font-size: 18px;
            margin: 0;
            padding: 0;
        }`;
        this.template.querySelector('lightning-card').appendChild(styleHeader);
    }

    // Standard lifecycle hooks used to subscribe and unsubsubscribe to the message channel
    async connectedCallback() {
        this.isLoading = true;
        console.log('OPEN ORDERS - Subscribing to Message Channel...');
        //this.subscribeToMessageChannel();

        this.userType = localStorage.getItem('User Type');
        this.selectedID = localStorage.getItem('AgentID');
        this.distributorID = localStorage.getItem('DistributorID');
        this.distributorName = localStorage.getItem('DistributorName')
        this.distributorNumber = localStorage.getItem('DistributorAccount');
        this.agentNumber = localStorage.getItem('AgentNumber');

        console.log('Open Orders CC - Agent Account ID passed from Component: '+this.selectedID);
        console.log('Open Orders CC - Agent Account Number passed from Component: '+this.agentNumber);
        console.log('Open Orders CC - Distributor Account ID passed from Component: '+this.distributorID); // ID OF THE DISTRIBUTOR
        console.log('Open Orders CC - Distributor Account Name passed from Component: '+this.distributorName); // NAME OF THE DISTRIBUTOR
        console.log('Open Orders CC - Distributor Account Number passed from Component: '+this.distributorNumber); // SAP CUSTOMER NUMBER OF THE DISTRIBUTOR

        
        getOpenOrders({accountId: this.selectedID, distributorId : this.distributorID, userType : this.userType}) 
       
            .then(result => {
                console.log('Executed APEX - getOpenOrders in Connected Callback....');
                if (result.length > 0) {
                    this.buttonLabel = "View All";
                    var tempOrderList = [];
                    for (var i = 0; i < result.length; i++) {
                        let tempRecord = Object.assign({}, result[i]);
                        //tempRecord.recordLink = "/Agents/s/order" + "/" + tempRecord.Id; // STAGE
                        tempRecord.recordLink = "/s/order" + "/" + tempRecord.Id; // PRODUCTION
                        tempOrderList.push(tempRecord);
                    }
                    this.isLoading = false;
                    this.orderItems = tempOrderList;
                    this.orderItemsMessage = '';
                    console.log('Orders Returned: '+JSON.stringify(this.orderItems));
                } else {
                    
                    this.isLoading = false;
                    this.orderItemsMessage = 'No Open Orders Found.';
                    this.buttonLabel = "View History";
                }
            }).catch(error => {
            console.error(error);
            this.isLoading = false;
            this.orderItemsMessage = "No Open Orders Found.";
            this.buttonLabel = "View History";
        });
        this.subscribeToMessageChannel();
    }

    disconnectedCallback() {
        //this.unsubscribeToMessageChannel();
    }

    viewAllOrderItems(evt) {
        var baseURL = window.location.origin
        //this.sfdcOrgURL = baseURL + '/Agents/s/orders' // STAGE
        this.sfdcOrgURL = baseURL + '/s/open-orders' + '?id=' + this.selectedID; // PRODUCTION
        window.open(this.sfdcOrgURL, '_self');

        //var url = '/Agents/s/order/related/'+ this.selectedID+'/AgentOrders__r';
        //window.open(url);
    }

}