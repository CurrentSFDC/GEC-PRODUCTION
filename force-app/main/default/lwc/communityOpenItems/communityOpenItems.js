import { LightningElement, track, wire, api} from "lwc";

import getRelatedAccounts from '@salesforce/apex/communityOpenClass.getRelatedAccounts';
import getOpenCases from '@salesforce/apex/communityOpenClass.getOpenCases';
import getOpenOrders from '@salesforce/apex/communityOpenClass.getOpenOrders';
import getPriceAgreements from '@salesforce/apex/communityOpenClass.getPriceAgreements';
import accountSelected from '@salesforce/messageChannel/selectedAccount__c';
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import CONTACT_FIELD from '@salesforce/schema/User.ContactId';
import ACCOUNT_FIELD from '@salesforce/schema/User.AccountId';

import { publish, MessageContext } from 'lightning/messageService';

export default class CommunityOpenItems extends LightningElement {
    @api flexipageRegionWidth;
    @track orderColumns = [{
        label: 'Order #',
        fieldName: 'recordLink',
        type: 'url',
        typeAttributes: { label: { fieldName: "GE_Order_NO__c" }, tooltip:"Name", target: "_blank" }, 
        cellAttributes: { alignment: 'center' }
    },
    {
        label: 'Order Date',
        fieldName: 'EffectiveDate',
        type: 'Text',
        sortable: true,
        cellAttributes: { alignment: 'center' }
    },
    {
        label: 'PO #',
        fieldName: 'Customer_PO_Number__c',
        type: 'Text',
        sortable: true,
        cellAttributes: { alignment: 'center' }
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
        fieldName: 'TotalAmount',
        type: 'currency',
        sortable: true,
        cellAttributes: { alignment: 'center' }
    }
    ]; 

    @track paColumns = [/*{
        label: 'Agreement #',
        fieldName: 'recordLink',
        type: 'url',
        typeAttributes: { label: { fieldName: "Agreement_No__c" }, tooltip:"Agreement #", target: "_blank" }, 
        cellAttributes: { alignment: 'center' }
    },*/
    {
        label: 'Agreement #',
        fieldName: 'Agreement_No__c',
        type: 'Text',
        sortable: true,
        cellAttributes: { alignment: 'center' }
    },
    /*{
        label: 'Type',
        fieldName: 'Agreement_Type__c',
        type: 'Text',
        sortable: true,
        cellAttributes: { alignment: 'center' }
    },*/
    {
        label: 'Total',
        fieldName: 'Agreement_Subtotal__c',
        type: 'currency',
        sortable: true,
        cellAttributes: { alignment: 'center' }
    },
    /*{
        label: 'Valid From',
        fieldName: 'Valid_From__c',
        type: 'date',
        sortable: true,
        cellAttributes: { alignment: 'center' }
    },*/
    {
        label: 'Valid To',
        fieldName: 'Expiration_Date__c',
        type: 'date',
        sortable: true,
        cellAttributes: { alignment: 'center' }
    }
    ]; 

    @track caseColumns = [{
        label: 'Case #',
        fieldName: 'recordLink',
        type: 'url',
        typeAttributes: { label: { fieldName: "CaseNumber" }, tooltip:"Name", target: "_blank" }, 
        cellAttributes: { alignment: 'center' }
    },
    {
        label: 'Date Opened',
        fieldName: 'CreatedDate',
        type: 'date',
        cellAttributes: { alignment: 'center' }
    },
    /*{
        label: 'Opened By',
        fieldName: 'Contact.Name',
        type: 'date',
        cellAttributes: { alignment: 'center' }
    },*/
    {
        label: 'Classification',
        fieldName: 'GE_NAS_Sub_Type__c',
        type: 'Text',
        cellAttributes: { alignment: 'center' }
    },
    {
        label: 'Status',
        fieldName: 'Status',
        type: 'Text',
        cellAttributes: { alignment: 'center' }
    }
    ]; 

    @track orderItems = [];
    @track orderItemsMessage;
    @track paItems = [];
    @track paItemsMessage;
    @track paItemsViewAll;
    @track caseItems = [];
    @track caseItemsMessage;
    @track caseItemsViewAll;
    @track selectedID;
    @track accountID;
    @track contactID;
    @track accountsList = [];
    @track message;
    @track recordId;
    @track error;
    @track value = '';

    get options(){
        return this.accountsList;
    }

    @wire(MessageContext)
    messageContext;

    // GET CURRENT LOGGED IN COMMUNITY USER INFORMATION
    @wire(getRecord, {
        recordId: USER_ID,
        fields: [CONTACT_FIELD, ACCOUNT_FIELD]
    }) wireuser({
        error,
        data
    }) {
        if (error) {
        this.error = "NO DATA" ; 
        console.log('ERROR: '+this.error);
        } else if (data) {
            this.contactID = data.fields.ContactId.value;
            console.log('Setting Contact ID: '+this.contactID);
            this.accountID = data.fields.AccountId.value;
            this.selectedID = data.fields.AccountId.value;
            this.fetchOpenItems();
            
        }
    }

    fetchAccounts(){
        getRelatedAccounts({contactId: '$contactID'})
                .then(result => {
                    var i;
                    for(i = 0; i < result.length; i++){
                    this.accountsList = [...this.accountsList, {value: result[i].AccountId, label: result[i].Account.Name}];
                    console.log('List Returned from Apex: '+JSON.stringify(this.accountsList));
                }})
    }

    //GET LIST OF RELATED ACCOUNTS
    @wire(getRelatedAccounts, {contactId: '$contactID'})
    wiredRelatedAccounts({error, data}){
        var i;
        if(data){
            for(i = 0; i < data.length; i++){
                console.log('id= '+data[i].AccountId);
                this.accountsList = [...this.accountsList, {value: data[i].AccountId, label: data[i].Account.Name}];
                console.log('List Returned from Apex: '+JSON.stringify(this.accountsList));
            }
            this.error = undefined;
        } else if (error){
            this.message = "No Data";
        }
    };

    /*connectedCallback(){
        this.selectedID = this.accountID;
        console.log('Setting User Account ID: '+this.selectedID);
        
        this.fetchOpenItems();
    }*/

    
    handleAccountChange(event){
        this.selectedID = event.detail.value;
        console.log('Selected Account ID: '+this.selectedID);

        const payload = { recordId: this.selectedID };

        publish(this.messageContext, accountSelected, payload);
        this.fetchOpenItems();
    }

    viewAllOrderItems(evt){

        var baseURL = window.location.origin
        console.log('BASE URL: '+baseURL);
        this.sfdcOrgURL = baseURL+'/Agents/s/open-orders';
        console.log('NEW URL: '+this.sfdcOrgURL);

        
    
        //var url = '/Agents/s/order/related/'+ this.selectedID+'/AgentOrders__r';
        window.open(this.sfdcOrgURL);
    }

    viewAllpaItems(evt){

        var baseURL = window.location.origin
        console.log('BASE URL: '+baseURL);
        this.sfdcOrgURL = baseURL+'/Agents/s/price-agreements';
        console.log('NEW URL: '+this.sfdcOrgURL);

        
    
        //var url = '/Agents/s/order/related/'+ this.selectedID+'/AgentOrders__r';
        window.open(this.sfdcOrgURL);

        //var url = '/Agents/s/SAP_Price_Agreement__c/related/'+ this.selectedID+'/SAP_Price_Agreements__r';
        //window.open(url);
    }

    viewAllcaseItems(evt){
        var url = '/Agents/s/Case/related/'+ this.selectedID+'/Cases';
        window.open(url);
    }

    fetchOpenItems(){
        console.log('Selected ID: '+this.selectedID);
        getOpenCases({accountId: this.selectedID}) 
           .then(result => {
            if(result.length > 0){
                var tempCaseList = [];
                for(var i = 0; i < result.length; i++){
                    let tempRecord = Object.assign({}, result[i]);
                    tempRecord.recordLink = "/Agents/s/case"+"/" + tempRecord.Id + "/detail";
                    tempCaseList.push(tempRecord);
                }
                this.caseItems = tempCaseList;
                this.caseItemsMessage = '';
                console.log(result);
            }else{
                this.caseItemsMessage = "No Data Found.";
            }
            console.log('After refresh datatable OpenCases data: ' + JSON.stringify(this.caseItems));
           }).catch(error => {
            console.log("The error SENT TO APEX is: " +JSON.stringify(error));
            this.caseItemsMessage = "No Data Found.";
        });

        getOpenOrders({accountId: this.selectedID}) 
           .then(result => {
               if(result.length > 0){
                    var tempOrderList = [];
                    for(var i = 0; i < result.length; i++){
                        let tempRecord = Object.assign({}, result[i]);
                        tempRecord.recordLink = "/Agents/s/order"+"/" + tempRecord.Id + "/detail";
                        tempOrderList.push(tempRecord);
                    }
                    this.orderItems = tempOrderList;
                    this.orderItemsMessage = '';
                    console.log(result);
                }else{
                    this.orderItemsMessage = 'No Data Found.';
                }
               console.log('After refresh datatable Orders data: ' + JSON.stringify(this.orderItems));
           }).catch(error => {
            console.log("The error SENT TO APEX is: " +JSON.stringify(error));
            this.orderItemsMessage = "No Data Found.";
        });


           getPriceAgreements({accountId: this.selectedID}) 
           .then(result => {
            if(result.length > 0){
               var tempPaList = [];
               for(var i = 0; i < result.length; i++){
                   let tempRecord = Object.assign({}, result[i]);
                   tempRecord.recordLink = "/Agents/s/SAP_Price_Agreement__c"+"/" + tempRecord.Id + "/detail";
                   tempPaList.push(tempRecord);
               }
               this.paItems = tempPaList;
               this.paItemsMessage = '';
               console.log(result);
            }else{
                this.paItemsMessage = 'No Data Found.';
            }
            console.log('After refresh datatable PriceAgreements data: ' + JSON.stringify(this.paItems));
           }).catch(error => {
            console.log("The error SENT TO APEX is: " +JSON.stringify(error));
            this.paItemsMessage = "No Data Found.";
        });
    }

    renderedCallback() {
        const style = document.createElement('style');
        style.innerText = `c-community-open-items .slds-card__header {
        background-color: #5f82b6;
        height: 60px;
        text-align: center;
        color: white;
        }`;
        this.template.querySelector('lightning-card').appendChild(style);
    }

}