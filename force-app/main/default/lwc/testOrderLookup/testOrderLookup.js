import { LightningElement,wire,api} from 'lwc';
import findOrders from "@salesforce/apex/LwcLookupControllerCust.findOrders"; 

export default class TestOrderLookup extends LightningElement {
    @api label;
    @api disabled;
    @api placeHolder;
    @api required;
    @api selectedAccount;
    @api selectedOrder;
    @api orderNumber;
    @api errorMessage;
    @api messageWhenInvalidAccount = 'Invalid Account';
    @api type = "soldto";
    @api objectApiName = '';
    @api filterFieldName;
    @api filterFieldVal='DEFAULT'; 
    @api userType;
    @api distributorID;
  


    searchText;
    accounts;
    options;
    isSearching = false;

    @api reportValidity() {
        return this.template.querySelector('c-test-lookup').reportValidity();
    }

    @api resetSoldTo(resetST){
        this.selectedAccount = null;
    }

    @api changeAccount(){
        this.orderNumber = '';
        this.searchText = '';
        this.selectedAccount = null;
        this.preSelectedAccount = null;
   
    }


    connectedCallback() {
        console.log('Order # Passed from Order Search LWC Component: '+this.orderNumber);
        console.log('orderNumber Attribute: '+this.orderNumber);

    }

    renderedCallback() {
    }

    get selectedValue() {
        
        if(this.orderNumber != null || this.orderNumber != ''){
            return this.orderNumber;
        }    

        
        if (this.selectedOrder != null) {
            //console.log(this.selectedAccount.GE_Order_NO__c + ' - ' + this.selectedAccount.Customer_PO_Number__c);
            //return this.selectedAccount.GE_Order_NO__c + ' - ' + this.selectedAccount.Customer_PO_Number__c;
            return this.selectedOrder;
        }
        return '';
    }


    async handleAccountChange(event) {
        try {
            this.searchText = event.detail.value.trim();
            
            //console.log(`handleAccountChange searchText`, this.searchText);
            console.log(this.type);
            let type = this.userType;
            if (this.searchText != null && this.searchText.length >= 3) {
                this.isSearching = true;
                //let agentAccount = localStorage.getItem('AgentNumber');
                let records;
                    console.log('Object Name: '+this.objectApiName);
                    console.log('Search Text: '+this.searchText);
                    console.log('Filter Field: '+this.filterFieldName);
                    console.log('EXECUTING APEX CALL TO GET ORDERS');
                    records = await findOrders({portalUser: type, searchKey: this.searchText, objectName : this.objectApiName, filterFieldName: this.filterFieldName, distributorID: this.distributorID});
                
        
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
                        this.options.push(records[i].GE_Order_NO__c + ' - ' + records[i].Customer_PO_Number__c);
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
            console.log('INDEX: '+index);
            this.selectedAccount = this.accounts[index];
            this.selectedOrder = this.selectedAccount.GE_Order_NO__c + ' - ' + this.selectedAccount.Customer_PO_Number__c;
            console.log('Selected Order: '+this.selectedOrder);
            console.log(`this.selectedAccount`,JSON.parse(JSON.stringify(this.selectedAccount)));
            this.dispatchEvent(new CustomEvent('orderselection', {
                detail: {
                    selectedRecordId: this.selectedAccount.Id,
                    orderNumber:this.selectedAccount.GE_Order_NO__c,
                    orderPO:this.selectedAccount.Customer_PO_Number__c
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
            this.selectedOrder = null;
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
}