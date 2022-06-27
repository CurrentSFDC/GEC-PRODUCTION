import {LightningElement, track, api, wire} from 'lwc';

import getOpenCases from '@salesforce/apex/communityOpenClass.getOpenCases';
import {
    subscribe,
    unsubscribe,
    APPLICATION_SCOPE,
    MessageContext
} from 'lightning/messageService';
import recordSelected from '@salesforce/messageChannel/selectedAccount__c';
import serviceRequest from '@salesforce/contentAssetUrl/geciconservicerequestsWT';

export default class CommunityOpenCases extends LightningElement {

    serviceRequest = serviceRequest;

    @track caseItems = [];
    @track caseItemsMessage;
    @track selectedID;
    @track userType;
    @track distributorID;
    @track distributorName;
    @track distributorNumber;
    @track agentNumber;
    @track isLoading = true;
    @track buttonLabel;

    @track caseColumns = [{
        label: 'Case #',
        fieldName: 'recordLink',
        type: 'url',
        typeAttributes: {label: {fieldName: "CaseNumber"}, tooltip: "Name", target: "_self"},
        cellAttributes: {alignment: 'right'}
    },
        {
            label: 'Date Opened',
            fieldName: 'CreatedDate',
            type: 'date',
            cellAttributes: {alignment: 'right'}
        },
        /*{
            label: 'Opened By',
            fieldName: 'Contact.Name',
            type: 'date',
            cellAttributes: { alignment: 'center' }
        },*/
        {
            label: 'Type',
            fieldName: 'GE_NAS_Sub_Type__c',
            type: 'Text',
            cellAttributes: {alignment: 'left'}
        },
        {
            label: 'Status',
            fieldName: 'Status',
            type: 'Text',
            cellAttributes: {alignment: 'left'}
        }
    ];


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
        /*if (message.recordId == null) {
            return;
        }*/
        this.isLoading = true;
        console.log('HANDLING MESSAGE INSIDE THE OPEN CASES WIDGET...');
        this.selectedID = message.recordId;
        this.userType = message.userType;
        this.distributorID = message.distributorID;
        this.distributorName = message.distributorName;
        this.distributorNumber = message.distributorNumber;
        this.agentNumber = message.agentNumber;
        console.log('Open Cases - Agent Account ID passed from Component: '+this.selectedID);
        console.log('Open Cases - Agent Account Number passed from Component: '+this.agentNumber);
        console.log('Open Cases - Distributor Account ID passed from Component: '+this.distributorID); // ID OF THE DISTRIBUTOR
        console.log('Open Cases - Distributor Account Name passed from Component: '+this.distributorName); // NAME OF THE DISTRIBUTOR
        console.log('Open Cases - Distributor Account Number passed from Component: '+this.distributorNumber); // SAP CUSTOMER NUMBER OF THE DISTRIBUTOR
        
        await getOpenCases({accountId: this.selectedID, distributorId : this.distributorID, userType : this.userType}) 
            .then(result => {
                if (result.length > 0) {
                    this.buttonLabel = "View All";
                    var tempCaseList = [];
                    for (var i = 0; i < result.length; i++) {
                        let tempRecord = Object.assign({}, result[i]);
                        //tempRecord.recordLink = "/Agents/s/case" + "/" + tempRecord.Id + "/detail"; //STAGE
                        tempRecord.recordLink = "/s/case" + "/" + tempRecord.Id + "/detail"; //PROUDCTION
                        tempCaseList.push(tempRecord);
                    }
                    this.isLoading = false;
                    this.caseItems = tempCaseList;
                    this.caseItemsMessage = '';
                    console.log('Cases Returned: '+JSON.stringify(this.caseItems));
                } else {
                    this.isLoading = false;
                    this.caseItemsMessage = "No Open Cases Found.";
                    this.buttonLabel = "View History";
                }
            }).catch(error => {
            console.error(error);
            this.isLoading = false;
            this.caseItemsMessage = "No Open Cases Found.";
            this.buttonLabel = "View History";
        });

    }

    renderedCallback() {
        this.subscribeToMessageChannel();
        const style = document.createElement('style');
        style.innerText = `c-community-open-cases .slds-card__header {
            background-color: #5f82b6;
            width: 100%;
            align: center;
            color: white;
            font-family: 'Segoe UI';
            padding: 10px;
        }`;
        this.template.querySelector('lightning-card').appendChild(style);

        const styleHeader = document.createElement('style');
        styleHeader.innerText = `c-community-open-cases .slds-text-heading_small {
            width: 100%;
            margin: 0;
            font-family: 'Segoe UI';
            font-weight: bold;
            font-size: 18px;
            padding: 0;
        }`;
        this.template.querySelector('lightning-card').appendChild(styleHeader);
    }

    // Standard lifecycle hooks used to subscribe and unsubsubscribe to the message channel
    async connectedCallback() {
        console.log('OPEN CASES - Subscribing to Message Channel...');
        

        this.userType = localStorage.getItem('User Type');
        this.selectedID = localStorage.getItem('AgentID');
        this.distributorID = localStorage.getItem('DistributorID');
        this.distributorName = localStorage.getItem('DistributorName')
        this.distributorNumber = localStorage.getItem('DistributorAccount');
        this.agentNumber = localStorage.getItem('AgentNumber');

        console.log('Open Cases CC - Agent Account ID passed from Component: '+this.selectedID);
        console.log('Open Cases CC - Agent Account Number passed from Component: '+this.agentNumber);
        console.log('Open Cases CC - Distributor Account ID passed from Component: '+this.distributorID); // ID OF THE DISTRIBUTOR
        console.log('Open Cases CC - Distributor Account Name passed from Component: '+this.distributorName); // NAME OF THE DISTRIBUTOR
        console.log('Open Cases CC - Distributor Account Number passed from Component: '+this.distributorNumber); // SAP CUSTOMER NUMBER OF THE DISTRIBUTOR

            await getOpenCases({accountId: this.selectedID, distributorId : this.distributorID, userType : this.userType}) 
            .then(result => {
                if (result.length > 0) {
                    this.buttonLabel = "View All";
                    var tempCaseList = [];
                    for (var i = 0; i < result.length; i++) {
                        let tempRecord = Object.assign({}, result[i]);
                        //tempRecord.recordLink = "/Agents/s/case" + "/" + tempRecord.Id + "/detail"; //STAGE
                        tempRecord.recordLink = "/s/case" + "/" + tempRecord.Id + "/detail"; //PROUDCTION
                        tempCaseList.push(tempRecord);
                    }
                    this.isLoading = false;
                    this.caseItems = tempCaseList;
                    this.caseItemsMessage = '';
                    console.log('Cases Returned: '+JSON.stringify(this.caseItems));
                } else {
                    this.isLoading = false;
                    this.caseItemsMessage = "No Open Cases Found.";
                    this.buttonLabel = "View History";
                }
            }).catch(error => {
            console.error(error);
            this.isLoading = false;
            this.caseItemsMessage = "No Open Cases Found.";
            this.buttonLabel = "View History";
        });
        this.subscribeToMessageChannel();
    }

    disconnectedCallback() {
        //this.unsubscribeToMessageChannel();
    }

    viewAllcaseItems(evt) {
        //var url = '/Agents/s/cases' // STAGE
        var url = '/s/cases?id=' + this.selectedID; // PRODUCTION
        window.open(url, '_self');
    }

}