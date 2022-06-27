import {LightningElement, track, wire, api} from 'lwc';
import getRelatedAccounts from '@salesforce/apex/B2BCommerceAccountSelector.getRelatedAccounts';
import getAgentAccounts from '@salesforce/apex/B2BCommerceAccountSelector.getAgentAccounts';
import getSoldToAccounts from '@salesforce/apex/B2BCommerceAccountSelector.getSoldToAccounts';
import getAccountName from '@salesforce/apex/B2BCommerceAccountSelector.getAccountName';
import accountSelected from '@salesforce/messageChannel/selectedAccount__c';
import {getRecord} from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import CONTACT_FIELD from '@salesforce/schema/User.ContactId';
import ACCOUNT_FIELD from '@salesforce/schema/User.AccountId';
import UserType from '@salesforce/schema/User.User_Type__c';


import {publish, MessageContext} from 'lightning/messageService';

const actions = [
    {label: 'Select', name: 'select'},
];

export default class B2BCommerceAccountSelector extends LightningElement {

    @track accountModalColumns = [{
        label: 'Account Name',
        fieldName: 'Name',
        type: 'text',
    },
        {
            label: 'Segmentation',
            fieldName: 'Customer_Segmentation__c',
            type: 'text',
            //cellAttributes: { alignment: 'center' }
        },
        {
            label: 'Account #',
            fieldName: 'GE_LGT_EM_SAP_Customer_Number__c',
            type: 'text',
            //cellAttributes: { alignment: 'center' }
        },
        {
            label: 'Address',
            fieldName: 'ShippingAddress',
            type: 'text',
            initialWidth: 100
            //cellAttributes: { alignment: 'center' }
        },
        {
            type: 'button',
            initialWidth: 90,
            typeAttributes: {
                label: 'Select',
                name: 'select',
                rowActions: actions,
                variant: 'brand'
            }
        }
    ];

    @track selectAccountModal = false;
    @track selectedID;
    @api accountId;
    @track contactID;
    @track accountsList = [];
    @track message;
    @track recordId;
    @track error;
    @track value = '';
    @track accounts = [];
    @track searchable = [];
    @track isAgent = false;
    @track selectedAgentAccount;
    @track accountAgentNumber;
    @track customerAgentSegment;
    @track selectedAccount;
    @track accountNumber;
    @track customerSegment;
    @track UserType;
    @track portalUser;
    @track soldToList = [];
    currentStep = '1';

    @wire(MessageContext)
    messageContext;

    // GET CURRENT LOGGED IN COMMUNITY USER INFORMATION
    @wire(getRecord, {
        recordId: USER_ID,
        fields: [CONTACT_FIELD, ACCOUNT_FIELD, UserType]
    }) wireuser({
                    error,
                    data
                }) {
        if (error) {
            console.error(error);
        } else if (data) {
            this.contactID = data.fields.ContactId.value;
            this.accountId = data.fields.AccountId.value;
            this.selectedID = this.accountId;
            this.UserType = data.fields.User_Type__c.value
            this.getAccountName();
            this.showAccountModal();
        }
    }

    async getAccountName() {
        await getAccountName({accountId: this.accountId})
            .then(result => {
                this.accountAgentNumber = result[0].GE_LGT_EM_SAP_Customer_Number__c;
                this.customerAgentSegment = result[0].Customer_Segmentation__c;
                this.selectedAgentAccount = result[0].Name;
            });
    }

    @wire(getRelatedAccounts, {contactId: '$contactID', userType: '$UserType'})
    wiredRelatedAccounts({error, data}) {
        if (data) {
            this.accounts = [];
            for (const account of data) {
                const clone = Object.assign({}, account);
                Object.setPrototypeOf(clone, this.accountProto);
                this.accounts.push(clone);
            }
            this.searchable = this.accounts;
            console.log(`Related accounts`, JSON.parse(JSON.stringify(this.accounts)));
            this.error = undefined;
        } else if (error) {
            this.message = "No Data";
        }
    };

    connectedCallback() {
        this.selectedID = this.accountId;
        console.log(`this.accountId`, this.accountId);
    }

    showAccountModal() {
        if (this.UserType === "Agent") {
            this.isAgent = true;
        } else {
            this.isAgent = false;
            this.searchable = this.accounts;
        }
        this.selectAccountModal = true;
        this.searchable = this.accounts;
    }

    closeModal(event) {
        this.selectAccountModal = false;
    }

    setSelectedAgent(event) {
        const row = this.searchable[event.target.value];
        this.selectedID = row.Id;
        this.selectedAgentAccount = row.Name;
        this.customerAgentSegment = row.Customer_Segmentation__c;
        this.accountAgentNumber = row.GE_LGT_EM_SAP_Customer_Number__c;
        this.getSoldToAccounts();
        this.goToStepTwo();
    }

    getSoldToAccounts() {
        getSoldToAccounts({accountId: this.accountAgentNumber})
            .then(result => {
                this.soldToList = [];
                if(result){
                    for (const account of result) {
                        const clone = Object.assign({}, account);
                        Object.setPrototypeOf(clone, this.accountProto);
                        this.soldToList.push(clone);
                    }
                }
                console.log('SOLD TO ACCOUNTS RETURNED: ' + JSON.stringify(this.soldToList));
            })
            .catch(error => {
                console.error(error);
                this.error = error;
            });
    }

    handleAccountSelect(event) {
        const accountId = event.currentTarget.dataset.accountId;
        console.log(`accountId`, accountId);
        window.postMessage({accountId: accountId}, window.location.origin);
        this.selectAccountModal = false;
    }

    searchDataTable(event) {
        const searchString = event.target.value.toUpperCase();
        const allRecords = this.accounts;
        const searchResults = [];
        let i;

        for (i = 0; i < allRecords.length; i++) {
            if ((allRecords[i].Name) && (allRecords[i].Name.toUpperCase().includes(searchString)) ||
                (allRecords[i].GE_LGT_EM_SAP_Customer_Number__c) && (allRecords[i].GE_LGT_EM_SAP_Customer_Number__c.toUpperCase().includes(searchString)) ||
                (allRecords[i].ShippingCity) && (allRecords[i].ShippingCity.toUpperCase().includes(searchString)) ||
                (allRecords[i].ShippingState) && (allRecords[i].ShippingState.toUpperCase().includes(searchString))) {
                searchResults.push(allRecords[i]);
            }
        }
        this.searchable = searchResults;
    }

    handleKeyChange(event) {
        this.searchKey = event.target.value;
        return refreshApex(this.result);
    }

    goBackToStepOne() {
        this.currentStep = '1';
        this.template.querySelector('div.stepTwo').classList.add('slds-hide');
        this.template
            .querySelector('div.stepOne')
            .classList.remove('slds-hide');
    }

    goToStepTwo() {
        this.currentStep = '2';
        this.template.querySelector('div.stepOne').classList.add('slds-hide');
        this.template
            .querySelector('div.stepTwo')
            .classList.remove('slds-hide');
    }

    accountProto = {
        get isLBAgent() {
            return this.Customer_Segmentation__c === 'LB';
        }
    }
}