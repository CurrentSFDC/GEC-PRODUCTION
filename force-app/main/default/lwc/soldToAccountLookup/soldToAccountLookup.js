/**
 * Created by andra on 2021. 04. 20..
 */

import {LightningElement, api, wire} from 'lwc';
import getSoldToAccounts from '@salesforce/apex/SoldToAccountLookupController.getSoldToAccounts';
import getSoldToAccountByHeadId from '@salesforce/apex/SoldToAccountLookupController.getSoldToAccountByHeadId';
import getSoldToAccount from '@salesforce/apex/SoldToAccountLookupController.getSoldToAccount';

import {
    subscribe,
    unsubscribe,
    APPLICATION_SCOPE,
    MessageContext
} from 'lightning/messageService';
import recordSelected from '@salesforce/messageChannel/selectedAccount__c';

export default class SoldToAccountLookup extends LightningElement {

    @api label;
    @api disabled;
    @api placeHolder;
    @api required;
    @api selectedAccount;
    @api errorMessage;
    @api messageWhenInvalidAccount = 'Invalid Account';
    @api type = "soldto";
    @api accountId;

    searchText;
    accounts;
    options;
    isLoading = false;

    @api reportValidity() {
        return this.template.querySelector('c-lookup').reportValidity();
    }

    @wire(getSoldToAccountByHeadId, {headAccountId: localStorage.getItem('DistributorID')})
    wiredSoldToAccountByHeadId({error, data}){
        if(data){
            this.selectedAccount = data;
            if(this.selectedAccount != null){
            this.dispatchEvent(new CustomEvent('accountselect', {
                detail: {
                    selectedAccount: this.selectedAccount
                }
               }))
            }
        } else if (error){
            console.error(error);
        }
    };

    connectedCallback() {

    }

    get selectedValue() {
        console.log('HEADID: ' + localStorage.getItem('DistributorID'));


        if (this.selectedAccount != null) {
            console.log('this.selectedAccount.Name ',this.selectedAccount.Name + ' ' + this.selectedAccount.Customer_Integration_Key__c);
            return this.selectedAccount.Name + ' - ' + this.selectedAccount.GE_LGT_EM_SAP_Customer_Number__c;
        }
        return '';
    }


    async handleAccountChange(event) {
        console.log('handleAccountChange ',event.detail.value);
        try {
            this.searchText = event.detail.value.trim();
            //console.log(`handleAccountChange searchText`, this.searchText);
            console.log(this.type);
            if (this.searchText != null && this.searchText.length >= 3) {
                this.isLoading = true;
                let records;
                if (this.type.toLowerCase() === 'soldto') {
                    records = await getSoldToAccounts({searchText: this.searchText, accountId: this.accountId});
                }
                //console.log(`searchText`,this.searchText,event.detail.value.trim());
                if(this.searchText !== event.detail.value.trim()){
                    return;
                }
                this.options = null;
                //console.log(`records`, records);
                if (records != null && records.length > 0) {
                    this.options = [];
                    this.accounts = records;
                    for (let i = 0; i < records.length; i++) {
                        this.options.push(records[i].Name + ' - ' + records[i].GE_LGT_EM_SAP_Customer_Number__c);
                    }
                    this.options = [...this.options];
                }
            } else if (this.options != null) {
                this.options = null;
            }
        } catch (error) {
            console.error(error);
        }
        finally {
            this.isLoading = false;
        }
    }

    handleAccountSelect(event) {
        console.log('handleAccountSelect run');
        try {
            const index = event.detail.index;
            this.selectedAccount = this.accounts[index];
            //console.log(`this.selectedAccount`,JSON.parse(JSON.stringify(this.selectedAccount)));
            this.dispatchEvent(new CustomEvent('accountselect', {
                detail: {
                    selectedAccount: this.accounts[index]
                }
            }))
        } catch (error) {
            console.error(error);
        }
    }

    handleAccountReset(event) {
        try {
            this.selectedAccount = null;
        } catch (error) {
            console.error(error);
        }
    }

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

        renderedCallback() {
            this.subscribeToMessageChannel();
        }

        async handleMessage(message) {
            getSoldToAccount({accountId: message.distributorID}).then(result=>{
            this.selectedAccount = result;
            if(this.selectedAccount != null){
                console.log('this.selectedAccount ',this.selectedAccount);

            this.dispatchEvent(new CustomEvent('accountselect', {
                detail: {
                    selectedAccount: this.selectedAccount
                }
               }));
               }
            }).catch(error=>{});
        }
}