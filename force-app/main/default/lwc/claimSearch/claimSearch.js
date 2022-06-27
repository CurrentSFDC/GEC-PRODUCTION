import { LightningElement, track } from 'lwc';
import searchClaims from "@salesforce/apex/ClaimSearchController.searchClaims";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ClaimSearch extends LightningElement {
    @track soldToAccount;
    @track materialMaster;
    @track claimSearchRequest = {};
    @track claimResults;
    @track currency;

    isWorking = false;

    connectedCallback(){
        this.claimSearchRequest = {
            dateFrom: '',
            dateTo: '',
            soldToNumber: '',
            salesOrg: '',
            division: '',
            distributionChannel: '',
            materialNumber: '',
            referenceNumber: '',
            claimNumber: ''
        };
    }

    startSearch(){
        console.log(`this.claimSearchRequest`,JSON.parse(JSON.stringify(this.claimSearchRequest)));
        if (this.validateInputs() === false) {
            return;
        }
        this.isWorking = true;
        searchClaims({request : this.claimSearchRequest})
        .then(result => {
            console.log(result);

            if(result.message === 'OK'){
                this.claimResults = JSON.parse(JSON.stringify(result.claims));
            }
            else{
                this.claimResults = [];
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Warning',
                        message: result.message,
                        variant: 'warning',
                    }),
                );
            }

            this.isWorking = false;
        })
        .catch(error => {
            console.log(JSON.stringify(error));
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: error.body.message,
                    variant: 'error',
                }),
            );
            this.isWorking = false;
        })

    }

    handleFieldChange(event){
        this.claimSearchRequest[event.target.name] = event.target.value;
    }

    handleSoldToAccountLookupSelect(event){
        this.soldToAccount = event.detail.selectedAccount;
        this.claimSearchRequest.soldToNumber = this.soldToAccount.GE_LGT_EM_SAP_Customer_Number__c;
        this.claimSearchRequest.salesOrg = this.soldToAccount.GE_LGT_EM_Sales_Org__c;
        this.claimSearchRequest.division = this.soldToAccount.GE_LGT_EM_Division__c;
        this.claimSearchRequest.distributionChannel = this.soldToAccount.GE_LGT_EM_Distribution_Channel__c;
        this.currency = this.soldToAccount.CurrencyIsoCode;
    }

    handleSoldToAccountLookupReset(event){
        this.soldToAccount = null;
        this.claimSearchRequest.soldToNumber = '';
        this.claimSearchRequest.salesOrg = '';
        this.claimSearchRequest.division = '';
        this.claimSearchRequest.distributionChannel = '';
        this.currency = '';
    }

    handleMaterialMasterSelect(event){
        this.materialMaster = event.detail.selectedMaterial;
        this.claimSearchRequest.materialNumber = this.materialMaster.GE_LGT_EM_SAP_MaterialNumber__c;
    }

    handleMaterialMasterReset(event){
        this.materialMaster = undefined;
        this.claimSearchRequest.materialNumber = '';
    }

    validateInputs(){
        if(this.soldToAccount == null || this.claimSearchRequest.dateFrom == null || this.claimSearchRequest.dateFrom === '' ||
            this.claimSearchRequest.dateTo == null || this.claimSearchRequest.dateTo === ''){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please fill all required fields!',
                    variant: 'Error',
                }),
            );
            return false;
        }
        let dateFrom = new Date(this.claimSearchRequest.dateFrom);
        let dateTo = new Date(this.claimSearchRequest.dateTo);

        var differenceInDays = (dateTo.getTime() - dateFrom.getTime()) / (1000 * 3600 * 24);
        if (differenceInDays > 90 || differenceInDays < 0) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please select a date range not longer than 90 days.',
                    variant: 'Error',
                }),
            );
            return false;
        }
    }
}