import {LightningElement, track, api, wire} from 'lwc';
import getOpenReturns from '@salesforce/apex/communityOpenClass.getOpenReturns';
import {
    subscribe,
    unsubscribe,
    APPLICATION_SCOPE,
    MessageContext
} from 'lightning/messageService';
import recordSelected from '@salesforce/messageChannel/selectedAccount__c';
import openReturn from '@salesforce/contentAssetUrl/geciconreturnsWT';

export default class CommunityOpenItemsSecond extends LightningElement {

    openReturn = openReturn;

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

    @track returnOrderItems = [];
    @track message = 'No Data Found.';
    @track selectedID;
    @track distributorID;
    @track isLoading = true;
    @track buttonLabel;

    @wire(MessageContext)
    messageContext;

    // Encapsulate logic for Lightning message service subscribe and unsubsubscribe
    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                recordSelected,
                (message) => this.handleMessage(message),
                {scope: APPLICATION_SCOPE}
            );
        }
    }

    // Handler for message received by component
    async handleMessage(message) {
        /*if (message.recordId == null) {
            return;
        }*/
        this.isLoading = true;
        this.selectedID = message.recordId;
        this.userType = message.userType;
        this.distributorID = message.distributorID;
        console.log('Open Returns - Agent Account ID passed from Component: '+this.selectedID);
        console.log('Open Returns - Distributor Account ID passed from Component: '+this.distributorID);
        console.log('Open Returns - User Type passed from Component: '+this.userType);
       await getOpenReturns({accountId: this.selectedID, distributorId : this.distributorID, userType : this.userType})
            .then(result => {
                var tempCaseList = [];
                if (result.length > 0) {
                    this.buttonLabel = "View All";
                    for (var i = 0; i < result.length; i++) {
                        let tempRecord = Object.assign({}, result[i]);
                        //tempRecord.recordLink = "/Agents/s/order" + "/" + tempRecord.Id + "/detail"; // STAGE
                        tempRecord.recordLink = "/s/order" + "/" + tempRecord.Id + "/detail"; // PRODUCTION
                        tempCaseList.push(tempRecord);
                    }
                    this.isLoading = false;
                    this.returnOrderItems = tempCaseList;
                    this.message = "";
                    console.log('Returns Returned: '+JSON.stringify(this.returnOrderItems));
                } else {
                    this.isLoading = false;
                    this.message = "No Open Returns Found.";
                    this.buttonLabel = "View History";
                }
            }).catch(error => {
            console.error(error);
            this.isLoading = false;
            this.message = "No Open Returns Found.";
            this.buttonLabel = "View History";
            //this.data  = undefined;
        });
    }

    viewAllreturnOrderItems(evt) {
        //var url = '/Agents/s/returns' //STAGE
        var url = '/s/open-returns?id=' + this.selectedID; //PRODUCTION
        window.open(url, '_self');
    }

    // Standard lifecycle hooks used to subscribe and unsubsubscribe to the message channel
    async connectedCallback() {
        console.log('OPEN RETURNS - Subscribing to Message Channel...');

        this.userType = localStorage.getItem('User Type');
        this.selectedID = localStorage.getItem('AgentID');
        this.distributorID = localStorage.getItem('DistributorID');
        this.distributorName = localStorage.getItem('DistributorName')
        this.distributorNumber = localStorage.getItem('DistributorAccount');
        this.agentNumber = localStorage.getItem('AgentNumber');

        console.log('Open Returns CC - Agent Account ID passed from Component: '+this.selectedID);
        console.log('Open Returns CC - Agent Account Number passed from Component: '+this.agentNumber);
        console.log('Open Returns CC - Distributor Account ID passed from Component: '+this.distributorID); // ID OF THE DISTRIBUTOR
        console.log('Open Returns CC - Distributor Account Name passed from Component: '+this.distributorName); // NAME OF THE DISTRIBUTOR
        console.log('Open Returns CC - Distributor Account Number passed from Component: '+this.distributorNumber); // SAP CUSTOMER NUMBER OF THE DISTRIBUTOR

        await getOpenReturns({accountId: this.selectedID, distributorId : this.distributorID, userType : this.userType})
            .then(result => {
                var tempCaseList = [];
                if (result.length > 0) {
                    this.buttonLabel = "View All";
                    for (var i = 0; i < result.length; i++) {
                        let tempRecord = Object.assign({}, result[i]);
                        //tempRecord.recordLink = "/Agents/s/order" + "/" + tempRecord.Id + "/detail"; // STAGE
                        tempRecord.recordLink = "/s/order" + "/" + tempRecord.Id + "/detail"; // PRODUCTION
                        tempCaseList.push(tempRecord);
                    }
                    this.isLoading = false;
                    this.returnOrderItems = tempCaseList;
                    this.message = "";
                    console.log('Returns Returned: '+JSON.stringify(this.returnOrderItems));
                } else {
                    this.isLoading = false;
                    this.message = "No Open Returns Found.";
                    this.buttonLabel = "View History";
                }
            }).catch(error => {
            console.error(error);
            this.isLoading = false;
            this.message = "No Open Returns Found.";
            this.buttonLabel = "View History";
            //this.data  = undefined;
        });


        this.subscribeToMessageChannel();
    }

    disconnectedCallback() {
        //this.unsubscribeToMessageChannel();
    }

    renderedCallback() {
        const style = document.createElement('style');
        style.innerText = `c-community-open-items-second .slds-card__header {
            background-color: #5f82b6;
            width: 100%;
            align: center;
            color: white;
            font-family: 'Segoe UI';
            padding: 10px;
        }`;
        this.template.querySelector('lightning-card').appendChild(style);

        const styleHeader = document.createElement('style');
        styleHeader.innerText = `c-community-open-items-second .slds-text-heading_small {
            width: 100%;
            margin: 0;
            font-family: 'Segoe UI';
            font-weight: bold;
            font-size: 18px;
            padding: 0;
        }`;
        this.template.querySelector('lightning-card').appendChild(styleHeader);
    }

}