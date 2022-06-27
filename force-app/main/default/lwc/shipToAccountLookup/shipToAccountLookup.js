/**
 * Created by andra on 2021. 04. 20..
 */

import {LightningElement, api} from 'lwc';
import getShipToAccounts from '@salesforce/apex/ShipToAccountLookupController.getShipToAccounts';

export default class ShipToAccountLookup extends LightningElement {

    @api label;
    @api disabled;
    @api placeHolder;
    @api required;
    @api selectedAccount;
    @api errorMessage;
    @api messageWhenInvalidAccount = 'Invalid Account';
    @api type = "shipto";
    @api soldToAccountId;

    searchText;
    accounts;
    options;
    isLoading = false;

    @api reportValidity() {
        return this.template.querySelector('c-lookup').reportValidity();
    }

    connectedCallback() {

    }

    renderedCallback() {
    }

    get selectedValue() {
        if (this.selectedAccount != null) {
            return this.selectedAccount.Name + ' ' + this.selectedAccount.Customer_Integration_Key__c;
            console.log(this.selectedAccount.Name + ' ' + this.selectedAccount.Customer_Integration_Key__c);
        }
        return '';
    }


    async handleAccountChange(event) {
        try {
            this.searchText = event.detail.value.trim();
            //console.log(`handleAccountChange searchText`, this.searchText);
            console.log(this.type);
            console.log(this.soldToAccountId);
            if (this.searchText != null && this.searchText.length >= 3) {
                this.isLoading = true;
                let records;
                 if (this.type.toLowerCase() === 'shipto') {
                    records = await getShipToAccounts({soldToAccountId: this.soldToAccountId, searchText: this.searchText});
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
                        this.options.push(records[i].Name + ' - ' + records[i].Customer_Integration_Key__c);
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
}