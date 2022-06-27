import { LightningElement,wire,api, track} from 'lwc';
import findRecordsNEW from "@salesforce/apex/LwcLookupControllerCust.findSoldToRecords"; 

export default class SoldToLookupLWC extends LightningElement {
    @api label;
    @api disabled;
    @api placeHolder;
    @api required;
    @api selectedAccount;
    @api errorMessage;
    @api messageWhenInvalidAccount = 'Invalid Account';
    @api type = "soldto";
    @api objectApiName = '';
    @api filterFieldName = '';
    @api filterFieldVal='DEFAULT'; 
    @api preSelectedAccount;
    @api selectorNumber;
    @api caseType;
    @track changeButton = false;

    searchText;
    accounts;
    options;
    isSearching = false;

    @api reportValidity() {
        return this.template.querySelector('c-sold-to-lookup').reportValidity();
    }

    @api resetSoldTo(){
        this.selectedAccount = null;
        this.preSelectedAccount = null;
    }


    connectedCallback() {

    }

    renderedCallback() {
    }

    get selectedValue() {
    
        if(this.preSelectedAccount != null){
            return this.preSelectedAccount;
        }

        console.log('Selected Account Passed from Order Search LWC: '+JSON.stringify(this.selectedAccount));
        if (this.preSelectedAccount == null && this.selectedAccount != null) {
            console.log(this.selectedAccount.Name + ' - ' + this.selectedAccount.GE_LGT_EM_SAP_Customer_Number__c + ' - ' + this.selectedAccount.Customer_Segmentation__c);
            return this.selectedAccount.Name + ' - ' + this.selectedAccount.GE_LGT_EM_SAP_Customer_Number__c + ' - ' + this.selectedAccount.Customer_Segmentation__c;
        }
        return '';
    }


    async handleAccountChange(event) {
        try {
            this.searchText = event.detail.value.trim();
            //console.log(`handleAccountChange searchText`, this.searchText);
            console.log(this.type);
            if (this.searchText != null && this.searchText.length >= 2) {
                this.isSearching = true;
                //let agentAccount = localStorage.getItem('AgentNumber');
                let records;
                    console.log('Object Name: '+this.objectApiName);
                    console.log('Search Text: '+this.searchText);
                    console.log('Filter Field: '+this.selectorNumber);
                if(localStorage.getItem('AgentNumber') != null || localStorage.getItem('AgentNumber') != ''){
                    console.log('EXECUTING APEX CALL TO GET ACCOUNTS...');
                    records = await findRecordsNEW({searchKey: this.searchText, objectName : this.objectApiName, filterFieldName: this.selectorNumber});
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
                        this.options.push(records[i].Name + ' - ' + records[i].GE_LGT_EM_SAP_Customer_Number__c + ' - ' + records[i].Customer_Segmentation__c);
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
            this.isSearching = false;
        }
    }

    handleAccountSelect(event) {
        console.log('handleAccountSelect run');
        try {
            const index = event.detail.index;
            this.selectedAccount = this.accounts[index];
            console.log(`this.selectedAccount`,JSON.parse(JSON.stringify(this.selectedAccount)));
            this.dispatchEvent(new CustomEvent('accountselect', {
                detail: {
                    selectedAccount: this.selectedAccount.GE_LGT_EM_SAP_Customer_Number__c,
                    selectedAccountId: this.selectedAccount.Id,
                    selectedSoldToAccountName: this.selectedAccount.Name
                }
            }))

           
        } catch (error) {
            console.error(error);
        }
    }

    handleAccountReset(event) {
        try {
            this.selectedAccount = null;
            this.preSelectedAccount = null;
            console.log('Selected Account: '+this.selectedAccount);
            this.dispatchEvent(new CustomEvent('clearselection', {
                detail: {
                    clear: 'true'
                }
            }))
        } catch (error) {
            console.error(error);
        }
    } 

    @api disableChangeButton(disableChange){
        let disable = disableChange;
        if(this.caseType === "Warranty"){
            if (disable == true){
            this.changeButton = true;
            } else{
                this.changeButton = false;
            }
        }
    }

    @api disableSearchField(disableChange){
        let accSearch = disableChange;
        this.template.querySelector('c-sold-to-lookup').disableSearchField(accSearch);
    }

}