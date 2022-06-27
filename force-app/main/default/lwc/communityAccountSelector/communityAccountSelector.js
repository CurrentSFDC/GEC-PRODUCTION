import {LightningElement, track, wire, api} from 'lwc';
import getRelatedAccounts from '@salesforce/apex/communityOpenClass.getRelatedAccounts';
import connectLogins from '@salesforce/apex/communityOpenClass.connectLogins';
import updateContactInfo from '@salesforce/apex/communityOpenClass.updateContactInfo';
import getAgentAccounts from '@salesforce/apex/communityOpenClass.getAgentAccounts';
import getSoldToAccounts from '@salesforce/apex/communityOpenClass.getSoldToAccounts';
import getAccountName from '@salesforce/apex/communityOpenClass.getAccountName';
import accountSelected from '@salesforce/messageChannel/selectedAccount__c';
import loggedInAsUserCheck from '@salesforce/apex/communityOpenClass.loggedInAsUserCheck';
import {getRecord} from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import CONTACT_FIELD from '@salesforce/schema/User.ContactId';
import ACCOUNT_FIELD from '@salesforce/schema/User.AccountId';
import PROFILE_FIELD from '@salesforce/schema/User.ProfileId';
import NAME_FIELD from '@salesforce/schema/User.Name';
import UserType from '@salesforce/schema/User.User_Type__c';
import PROFILE_PHOTO from '@salesforce/schema/User.FullPhotoUrl';
import CURRENCY_FIELD from '@salesforce/schema/User.DefaultCurrencyIsoCode';

import {refreshApex} from '@salesforce/apex';
import fetchAlertBar from '@salesforce/apex/communityOpenClass.fetchAlertBar';
import logo from '@salesforce/contentAssetUrl/CurrentlogoRGB500x125jpg';

import {publish, MessageContext} from 'lightning/messageService';

const actions = [
    {label: 'Select', name: 'select'},

];

export default class CommunityAccountSelector extends LightningElement {

    @track accountModalColumns = [{
        label: 'Account Name',
        fieldName: 'Name',
        type: 'text',
        cellAttributes: {
            class: {
                fieldName: 'format'
            },

        }
    },
        {
            label: 'Segmentation',
            fieldName: 'segment',
            type: 'text',
            //cellAttributes: { alignment: 'center' }
        },
        {
            label: 'Account #',
            fieldName: 'GE_LGT_EM_SAP_Customer_Number__c',
            type: 'text',
            initialWidth: 100,
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
            initialWidth: 20,
            typeAttributes: {
                label: 'Select Agent Only',
                name: 'select',
                rowActions: actions,
                variant: 'brand'
            }
        },
        {
            type: 'button',
            initialWidth: 20,
            typeAttributes: {
                label: 'Select Customer Account',
                name: 'select',
                rowActions: actions,
                variant: 'brand'
            }
        }
    ];

    @api flexipageRegionWidth;
    @track selectAccountModal = false;
    @track selectedID;
    @track selectedAgentID;
    @api accountID;
    @track contactID;
    @track accountsList = [];
    @track message;
    @track recordId;
    @track error;
    @track value = '';
    @track accounts = [];
    @track searchable = [];
    @track isAgent = false;
    @track showFooter = false;
    @track selectedAgentAccount;
    @track accountAgentNumber;
    @track customerAgentSegment;
    @track selectedAccount;
    @track accountNumber;
    @track customerSegment;
    @track UserType;
    @track portalUser;
    @track soldToList = [];
    @track distributorAccounts = [];
    @track persistDistributor;
    @api retrieveData;
    @track profileID;
    @track mobile = false;
    @track directAccount;
    @track impersonate = false;

    // ALERT BAR-MODAL POPUP VARAIBLES
    @track error;
    @track AlertActive = false;
    @track communityContentRecords;
    @track hyperlink;
    @track listingType = 'Alert Bar';
    @track companyLogo = logo;
    @track message;
    @track showAlertBar = false;
    hasRender = false;

    @wire(MessageContext)
    messageContext;




    // GET CURRENT LOGGED IN COMMUNITY USER INFORMATION
    @wire(getRecord, {

        recordId: USER_ID,
        fields: [CONTACT_FIELD, ACCOUNT_FIELD, UserType, PROFILE_FIELD, PROFILE_PHOTO, NAME_FIELD,CURRENCY_FIELD]
    }) wireuser({
                    error,
                    data
                }) {
        if (error) {
            this.error = "NO DATA";
            console.log('ERROR: ' + this.error);
        } else if (data) {
            console.log('LOAD STEP 1 - WIRE METHOD...');
            this.contactID = data.fields.ContactId.value;
            console.log('Setting Contact ID: ' + this.contactID);
            let contactid = localStorage.getItem('ContactID');
            localStorage.setItem('userID', USER_ID);
            localStorage.setItem('userPhoto', data.fields.FullPhotoUrl.value);
            localStorage.setItem('contactName', data.fields.Name.value);
            localStorage.setItem('currencyCode',data.fields.DefaultCurrencyIsoCode.value); 

            console.log('LOAD STEP 1.A - COMPARING USER TO LOCAL STORAGE: '+contactid+' <=> '+this.contactID);
            if(contactid = null || contactid != this.contactID){
                console.log('CONTACTS ARE DIFFERENT...CLEARING LOCAL STORAGE...')
                localStorage.clear();
                console.log('LOCAL STORAGE CLEARED!');
                    localStorage.setItem('ContactID', this.contactID);
                    this.accountID = data.fields.AccountId.value;
                    console.log('Account Id Returned: ' + this.accountID);
                    //this.selectedAgentID = this.accountID;
                    this.profileID = data.fields.ProfileId.value;
                    this.UserType = data.fields.User_Type__c.value;
                        /*if(this.impersonate == false){
                            this.getConnectLogins();
                        } */
                    console.log('User Type: ' + this.UserType);
                    localStorage.setItem("User Type" , this.UserType);
                    localStorage.setItem('disableAlertBar', "NO");
                    if (this.profileID != '00e3j000001D2YyAAK') {
                        if (this.UserType == "Agent") {
                            this.isAgent = true;
                            this.selectedAgentID = this.accountID;
                            localStorage.setItem('AgentID', this.selectedAgentID);
                            console.log('Assigning Agent ID to Local Storage...');
                            //this.getAccountName();
                            //this.searchable = this.accounts;
                        } else {
                            this.isAgent = false;
                            this.selectedID = this.accountID;
                            localStorage.setItem('DistributorID', this.selectedID);
                            console.log('Assigning Distributor ID to Local Storage...');
                            //this.getAccountName();
                            //this.soldToList = this.accounts;
                        }
                        this.getAccountName();
                        this.getAlertBar();
                    }
                } else {
                    console.log('SAME USER LOGGED IN...PROCEEDING...');

                    localStorage.setItem('ContactID', this.contactID);
                    this.accountID = data.fields.AccountId.value;
                    console.log('Account Id Returned: ' + this.accountID);
                    //this.selectedAgentID = this.accountID;
                    this.profileID = data.fields.ProfileId.value;
                    this.UserType = data.fields.User_Type__c.value;
                    /*if(this.impersonate == false){
                        this.getConnectLogins();
                     }*/
                    console.log('User Type: ' + this.UserType);
                    localStorage.setItem("User Type" , this.UserType);
                    localStorage.setItem('disableAlertBar', "YES");
                    if (this.profileID != '00e3j000001D2YyAAK') {
                        if (this.UserType == "Agent") {
                            this.isAgent = true;
                            this.selectedAgentID = this.accountID;
                            //localStorage.setItem('AgentID', this.selectedAgentID);
                            //console.log('Assigning Agent ID to Local Storage...');
                            //this.getAccountName();
                            //this.searchable = this.accounts;
                        } else {
                            this.isAgent = false;
                            this.selectedID = this.accountID;
                            //localStorage.setItem('DistributorID', this.selectedID);
                            //this.getAccountName();
                            //this.soldToList = this.accounts;
                        }
                        this.getAccountName();
                        this.getAlertBar();
                    }
                }
        }
    }

    getConnectLogins(){
     
        connectLogins({contactId : this.contactID})
        .then(result => {
            
                console.log('REGISTERED LOGIN FOUND: '+JSON.stringify(result));
                if(result.length > 0){
                    //this.impersonate = true;
                    //localStorage.setItem('Impersonate', true);
                    let internalName = result[0].Delegated_User__r.Name;
                    let internalUserName = result[0].Delegated_User__r.Username;
                    let internalUserPhone = result[0].Delegated_User__r.Phone;
                    let internalUserFirstName = result[0].Delegated_User__r.FirstName;
                    let internalUserLastName = result[0].Delegated_User__r.LastName;
                    localStorage.setItem('internalName', internalName);
                    localStorage.setItem('internalUserName', internalUserName);
                    localStorage.setItem('internalUserPhone', internalUserPhone);
                    localStorage.setItem('internalUserFirstName', internalUserFirstName);
                    localStorage.setItem('internalUserLastName', internalUserLastName);
                } else {
                   // this.impersonate = false;
                }
            });
    

}

renderedCallback() {

    // Set focus on Search account field By Sameer Mahadik On (2-22-2022)

    if (!this.hasRender) {

        let inputs = this.template.querySelectorAll('.search-inputs lightning-input');

 

        for (const input of inputs) {

            if (input.type == 'search') {

                input.focus();

                this.hasRender = true;

            }

        }

    }

}

async handleLogout(){

let updateContact = {'sobjectType': 'Contact'};
updateContact.Id = this.contactID;
updateContact.Impersonate_Mode__c = false;

await updateContactInfo({data : updateContact})
.then(result => {
    console.log('Item Modified');
    window.close();
    //window.location.replace("https://stage-gecurrent.cs91.force.com/Agents/secur/logout.jsp?retUrl=https%3A%2F%2Fstage-gecurrent.cs91.force.com%2FAgents%2FCommunitiesLanding");
})
}

loggedInAsUserBool;

@wire( loggedInAsUserCheck )  
wiredData( value ) {

const { data, error } = value;

if ( data || data === false ) {
                    
    console.log( 'Data received from Apex ' + JSON.stringify( data ) );
    this.loggedInAsUserBool = data;
    if(this.loggedInAsUserBool == true){
        this.impersonate = true;
        this.getConnectLogins();
    } else {
        this.impersonate = false;
    }
   
    
    /*connectLogins({contactId : this.contactID})
        .then(result => {
            
                console.log('REGISTERED LOGIN FOUND: '+JSON.stringify(result));
                if(result.length > 0){
                    
                    //localStorage.setItem('Impersonate', true);
                    let internalName = result[0].Delegated_User__r.Name;
                    let internalUserName = result[0].Delegated_User__r.Username;
                    let internalUserPhone = result[0].Delegated_User__r.Phone;
                    localStorage.setItem('internalName', internalName);
                    localStorage.setItem('internalUserName', internalUserName);
                    localStorage.setItem('internalUserPhone', internalUserPhone);
                } else {
                   // this.impersonate = false;
                }
            });*/


} else if ( error ) {

    console.error( JSON.stringify( error ) );
    
}

}

   async getAccountName() {
    console.log('LOAD STEP 2 - GET ACCOUNT NAME METHOD...');
        await getAccountName({accountId: this.accountID})
            .then(result => {
                this.directAccount = result[0].GE_LGT_EM_SAP_Customer_Number__c;
                console.log('LOAD STEP 2.A - DIRECT ACCOUNT IS: '+this.directAccount);
                //this.selectedAccount = result[0].Name;
                if (this.UserType == "Agent") {
                    console.log('LOAD STEP 2.B - USER TYPE IS AGENT...');
                    let dataStored = localStorage.getItem('DataStored');
                    console.log('dataStored ',dataStored);
                    if (dataStored == null){
                        console.log('LOAD STEP 2.C - Local Storage IS NULL...');
                        this.accountAgentNumber = result[0].GE_LGT_EM_SAP_Customer_Number__c;
                        
                        if(result[0].Customer_Segmentation__c === "LB"){
                            this.customerAgentSegment  = "Lamp";
                            
                        } else if(result[0].Customer_Segmentation__c === "FD"){
                            this.customerAgentSegment  = "Fixture";
                           
                        }
                        //this.customerAgentSegment = result[0].Customer_Segmentation__c;
                        this.selectedAgentAccount = result[0].Name;


                        //this.getSoldToAccounts(); //ADDED FOR 2 STEP
                        console.log('Account Name: ' + JSON.stringify(this.selectedAgentAccount));
                        localStorage.setItem('DataStored', "YES");
                            
                        console.log('getAccountName - Setting Local Storage - Agent Number: ' + this.accountAgentNumber);
                        localStorage.setItem('AgentNumber', this.accountAgentNumber);
                            
                        console.log('getAccountName - Setting Local Storage - Agent Name: ' + this.selectedAgentAccount);
                        localStorage.setItem('AgentName', this.selectedAgentAccount);
                            
                        console.log('getAccountName - Setting Local Storage - Agent Segment: ' + this.customerAgentSegment);
                        localStorage.setItem('AgentSegment', this.customerAgentSegment);

                           
                        console.log('getAccountName - Setting Local Storage - Agent Account ID: ' + this.accountID);
                        localStorage.setItem('AgentID', this.accountID);
                            
                       this.updateSelector();
                    } else {
                       this.updateSelector();
                    }
                } else {
                    console.log('LOAD STEP 2.B - USER TYPE IS CUSTOMER...');
                    let dataStored = localStorage.getItem('DataStored');
                    if (dataStored == null){
                        console.log('LOAD STEP 2.C - Local Storage IS NULL...');
                        this.accountNumber = result[0].GE_LGT_EM_SAP_Customer_Number__c;

                        if(result[0].Customer_Segmentation__c === "LB"){
                            this.customerSegment  = "Lamp";
                            
                        } else if(result[0].Customer_Segmentation__c === "FD"){
                            this.customerSegment  = "Fixture";
                           
                        }
                        //this.customerSegment = result[0].Customer_Segmentation__c;
                        this.selectedAccount = result[0].Name;
                        //this.getSoldToAccounts(); //ADDED FOR 2 STEP
                        localStorage.setItem('DataStored', "YES");
                            
                        localStorage.setItem('DistributorAccount', this.accountNumber);
                            
                        console.log('getAccountName - Setting Local Storage - Distributor Number: ' + this.accountNumber);
                        localStorage.setItem('DistributorName', this.selectedAccount);

                        localStorage.setItem('DistributorType', result[0].GE_LGT_EM_Order_Block__c);
                        console.log('getAccountName - Setting Local Storage - Distributor Type: ' + result[0].GE_LGT_EM_Order_Block__c);
                            
                        console.log('getAccountName - Setting Local Storage - Distributor Name: ' + this.selectedAccount);
                        localStorage.setItem('DistributorSegment', this.customerSegment);
                            
                        console.log('getAccountName - Setting Local Storage - Distributor Segment: ' + this.customerSegment);
                        localStorage.setItem('DistributorID', this.accountID);
                           
                        console.log('getAccountName - Setting Local Storage - Distributor ID: ' + this.accountID);
                        console.log('Distributor Account Name: ' + JSON.stringify(this.selectedAccount));
                       this.updateSelector();
                    } else {
                       this.updateSelector();
                    }
                }
                //this.handleAccountChange();

            });
    }

    async updateSelector(){
        console.log('LOAD STEP 4 - UPDATING SELECTOR...');
        console.log(`localStorage`,localStorage);
            //console.log(`localStorage.getItem('qwe')`,localStorage.getItem('qwe'));

            let dataStored = localStorage.getItem('DataStored');
            //let effAccount = localStorage.getItem('effAccId');

            //IF SESSTION STORAGE HAS DATA --> AGENT AND DISTRIBUTOR DATA
            if (dataStored == "YES") {
                console.log('LOAD STEP 4.A - DATA STORED IS BEING RETRIEVED...');
                let agentID = localStorage.getItem('AgentID');
                let agentName = localStorage.getItem('AgentName');
                let agentNumber = localStorage.getItem('AgentNumber');
                let agentSegment = localStorage.getItem('AgentSegment');


                // FOR LOGGED IN AGENT - IF AGENT IS LB, THIS SETS VARIABLE TO TELL B2B TO POP THE ACCOUNT SELECTOR
                //let agentLength = this.accountAgentNumber.length;
                if (agentSegment == "Lamp"){
                    localStorage.setItem('PopSelector', "YES");
                } else {
                    localStorage.removeItem('PopSelector');
                }

                let retrieveData = localStorage.getItem('DistributorAccount');
                let disAccountName = localStorage.getItem('DistributorName');
                let disAccountSegment = localStorage.getItem('DistributorSegment');
                let disAccId = localStorage.getItem('DistributorID');

                //AGENT ACCOUNT NUMBER IS NOT NULL AND DISTRIBUTOR NUMBER IS NULL
                if (agentNumber != null && retrieveData == null) {
                    console.log('LOAD STEP 4.B - IN THE AGENT ONLY BRANCH...');
                    this.selectedAgentAccount = agentName;
                    this.selectedAgentID = agentID;
                    this.customerAgentSegment = agentSegment;
                    this.accountAgentNumber = agentNumber;

                    localStorage.removeItem('DistributorAccount');
                    localStorage.removeItem('DistributorName');
                    localStorage.removeItem('DistributorType');
                    localStorage.removeItem('DistributorSegment');
                    localStorage.removeItem('DistributorID');

                    // FOR LOGGED IN AGENT - IF AGENT IS LB, THIS SETS VARIABLE TO TELL B2B TO POP THE ACCOUNT SELECTOR
                    //let agentLength = this.accountAgentNumber.length;
                    if (agentSegment == "Lamp"){
                        localStorage.setItem('PopSelector', "YES");
                    } else {
                        localStorage.removeItem('PopSelector');
                    }

                    this.selectedAccount = ' ';
                    this.selectedID = ' ';
                    this.customerSegment = ' ';
                    this.accountNumber = ' ';
                    this.handleAccountChange();

                //BOTH AGENT AND DISTRIBUTOR NUMBERS ARE NOT NULL
                } else if (retrieveData != null && agentNumber != null) {
                    console.log('LOAD STEP 4.B - IN THE AGENT AND DISTRIBUTOR BRANCH...');
                    this.selectedAgentAccount = agentName;
                    console.log('UpdateSelector - Setting Agent Account Name ' + this.selectedAgentAccount);
                    this.selectedAgentID = agentID;
                    console.log('UpdateSelector - Setting Agent Account ID: ' + this.selectedAgentID);
                    this.customerAgentSegment = agentSegment;
                    console.log('UpdateSelector - Setting Agent Segment: ' + this.customerAgentSegment);
                    this.accountAgentNumber = agentNumber;
                    console.log('UpdateSelector - Setting Agent Account Number: ' + this.accountAgentNumber);



                    this.accountNumber = retrieveData;
                    console.log('UpdateSelector - Setting Distributor Account Number: ' + this.accountNumber);
                    this.customerSegment = disAccountSegment;
                    console.log('UpdateSelector - Setting Distributor Account Segment: ' + this.customerSegment);
                    this.selectedAccount = disAccountName;
                    console.log('UpdateSelector - Setting Distributor Account Segment: ' + this.customerSegment);
                    this.selectedID = disAccId;
                    console.log('UpdateSelector - Setting Distributor Account ID: ' + this.selectedID);

                    console.log('Setting Account Number from Local Storage: ' + this.accountNumber);
                    this.handleAccountChange();

                //AGENT NUMBER IS NULL AND DISTRIBUTOR IS NOT NULL
                } else if (retrieveData != null && agentNumber == null) {
                    console.log('LOAD STEP 4.B - IN THE DISTRIBUTOR ONLY BRANCH...');
                    this.accountNumber = retrieveData;
                    console.log('UpdateSelector - Setting Distributor Account Number: ' + this.accountNumber);
                    this.customerSegment = disAccountSegment;
                    console.log('UpdateSelector - Setting Distributor Account Segment: ' + this.customerSegment);
                    this.selectedAccount = disAccountName;
                    console.log('UpdateSelector - Setting Distributor Account name: ' + this.selectedAccount);
                    this.selectedID = disAccId;
                    console.log('UpdateSelector - Setting Distributor Account ID: ' + this.selectedID);

                    this.selectedAgentAccount = ' ';
                    this.selectedAgentID = ' ';
                    this.customerAgentSegment = ' ';
                    this.accountAgentNumber = ' ';
                    this.handleAccountChange();
                }

                //this.handleAccountChange();
            } else {
                console.log('LOAD STEP 4.A - NO DATA FOUND OR RETRIEVED...');
                /*this.accountNumber = retrieveData;
                this.customerSegment = disAccountSegment;
                this.selectedAccount = disAccountName;
                this.selectedID = disAccId;*/

                this.selectedAccount = ' ';
                this.selectedID = ' ';
                this.customerSegment = ' ';
                this.accountNumber = ' ';
                this.handleAccountChange();
            }
    }

@wire(getRelatedAccounts, {contactId: '$contactID', userType: '$UserType'})
wiredRelatedAccounts({error, data}) {
    var i;
    if (data) {
        console.log('LOAD STEP 3 - GET RELATED ACCOUNTS METHOD...');
        this.accounts = [];
        for (const account of data) {
            //let format = account.GE_LGT_EM_SAP_Customer_Number__c == this.accountAgentNumber ? "slds-text-color_error":"slds-text-color_success"
            //console.log('Account Variable: '+JSON.stringify(account));


            const clone = Object.assign({}, account);
            //Object.setPrototypeOf(clone, this.accountProto);
            if(account.GE_LGT_EM_SAP_Customer_Number__c == this.directAccount){
                //this.template.querySelector('[data-id="agentRows"]').classList.add('directAccount');
                console.log('Found the Direct Account...');

                clone.isDirect = true;

            } else {

                clone.isDirect = false;
            }
            console.log('Customer Name: '+account.Name);
            if(account.Customer_Segmentation__c === "LB"){
                clone.segment = "Lamp";
                console.log('Setting Segment: '+clone.segment);
            } else if(account.Customer_Segmentation__c === "FD"){
                clone.segment = "Fixture";
                console.log('Setting Segment: '+clone.segment);
            }

            this.accounts.push(clone);

        }
        //console.log('NEW ACCOUNT LIST: '+JSON.stringify(this.accounts));
        if (this.UserType == "Agent") {

            this.searchable = this.accounts;

        } else {
            this.soldToList = this.accounts;
            this.distributorAccounts = this.soldToList;

        }
        //this.searchable = this.accounts;
        console.log(`Related accounts`, JSON.parse(JSON.stringify(this.accounts)));
        console.log(`distributorAccounts`, JSON.parse(JSON.stringify(this.distributorAccounts)));

        this.error = undefined;
    } else if (error) {
        this.message = "No Data";
    }
};



    /*let alertBarStatus = localStorage.getItem('disableAlertBar');
    console.log('GETTING ATTRIBUTE FOR - disableAlertBar...');

    var siteURL = window.location.href;
    fetchAlertBar({listingType: this.listingType})
        .then(result => {
            this.communityContentRecords = result;
            this.message = result[0].Alert_Bar_Message__c;
            this.AlertActive = result[0].Show_Alert_Bar__c;
            if (this.AlertActive = true && siteURL == 'https://stage-gecurrent.cs91.force.com/Agents/s/login/SelfRegister') {
                this.showAlertBar = false;
            } else if(alertBarStatus == "YES"){
                this.showAlertBar = false;
            } else {
                this.showAlertBar = true;
            }
            //this.hyperlink = this.shipmentRecord[0].CCL_Order_Apheresis__r.CCL_Apheresis_Collection_Center__r.Name;
        })
        .catch(error => {
            this.error = error;
        });
}*/

getAlertBar(){
    let alertBarStatus = localStorage.getItem('disableAlertBar');
    console.log('GETTING ATTRIBUTE FOR - disableAlertBar...');

    var siteURL = window.location.href;
    fetchAlertBar({listingType: this.listingType, userType: this.UserType})
        .then(result => {
            this.communityContentRecords = result;
            this.message = result[0].Alert_Bar_Message__c;
            this.AlertActive = result[0].Show_Alert_Bar__c;
            if (this.AlertActive = true && siteURL == 'https:/myconnect.gecurrent.com/s/login/SelfRegister') {
                this.showAlertBar = false;
            } else if(alertBarStatus == "YES"){
                this.showAlertBar = false;
            } else {
                this.showAlertBar = true;
            }
            //this.hyperlink = this.shipmentRecord[0].CCL_Order_Apheresis__r.CCL_Apheresis_Collection_Center__r.Name;
        })
        .catch(error => {
            this.error = error;
        });
}

closeAlertBar() {
    localStorage.setItem('disableAlertBar', "YES")
    this.showAlertBar = false;
}




   async handleAccountChange() {
        console.log('LOAD STEP 5 - HANDLE ACCOUNT CHANGE METHOD...');


        console.log('Publishing Selected Agent Account ID: ' + this.selectedAgentID);
        console.log('Publishing Selected Agent Account Name: ' + this.selectedAgentAccount);
        console.log('Publishing Selected Agent Account Number: ' + this.accountAgentNumber);

        console.log('Publishing Selected Customer Account ID: ' + this.selectedID);
        console.log('Publishing Selected Customer Account Name: ' + this.selectedAccount);
        console.log('Publishing Selected Customer Account Number: ' + this.accountNumber);

        console.log('Publishing User Type: ' + this.UserType);

        const payload = {
            recordId: this.selectedAgentID,
            accountName: this.selectedAgentAccount,
            agentNumber: this.accountAgentNumber,
            userType: this.UserType,
            distributorID: this.selectedID,
            distributorName: this.selectedAccount,
            distributorNumber: this.accountNumber
        };

        publish(this.messageContext, accountSelected, payload);

    }

    showAccountModal(event) {
        this.currentStep = '1';
        this.selectAccountModal = true;
        this.searchable = this.accounts;

    }

    closeModal(event) {

        this.selectAccountModal = false;
        this.hasRender = false;
        //this.handleAccountChange();
    }

    /*setSelectedAccount(event){
        console.log('BUTTON EXECUTED');
        const row = event.detail.row;
        console.log('ROW ID Selected: '+row.Id);
        this.selectedID = row.Id;
        this.selectedAccount = row.Name;
        this.accountNumber = row.GE_LGT_EM_SAP_Customer_Number__c;
        this.selectAccountModal = false;
        this.handleAccountChange();

    }*/


    // SELECTING DISTRIBUTOR ACCOUNT - STEP 2 - DUPLICATED FUNCTION
    /*setSelectedAccount(event){
        console.log('DISTRIBUTOR SCREEN SELECT BUTTON EXECUTED');
        const row = this.searchable[event.target.value];
        console.log('ROW ID Selected Customer: '+this.searchable[event.target.value].Id);
        this.selectedID = row.Id;
        this.selectedAccount = row.Name;
        this.customerSegment = row.Customer_Segmentation__c;
        console.log('Selected Name: '+row.Name);
        this.accountNumber = row.GE_LGT_EM_SAP_Customer_Number__c;
        //this.getSoldToAccounts();
        this.selectAccountModal = false;
        //this.currentStep = '1';
        this.showFooter = false;
        this.handleAccountChange();

    }*/

    async custAccount() {
        this.accountAgentNumber = localStorage.getItem('AgentNumber');
        console.log('Agent Account Number: ' + this.accountAgentNumber);
        console.log('Inside the custAccount: ' + this.soldToList);


        await getSoldToAccounts({accountId: this.accountAgentNumber})
            .then(result => {
                console.log('FETCHING THE RESULTS OF AGENT ACCOUNT...')
                this.soldToList = [];
                this.distributorAccounts = [];
                if (result) {
                    for (const account of result) {
                        const clone = Object.assign({}, account);
                        Object.setPrototypeOf(clone, this.accountProto);

                        console.log('Customer Name: '+account.Name);
                        if(account.Customer_Segmentation__c === "LB"){
                            clone.segment = "Lamp";
                            console.log('Setting Segment: '+clone.segment);
                        } else if(account.Customer_Segmentation__c === "FD"){
                            clone.segment = "Fixture";
                            console.log('Setting Segment: '+clone.segment);
                        }


                        this.soldToList.push(clone);
                    }

                    // this.selectAccountModal = true;
                    // this.goToStepTwo();
                }
                console.log('SOLD TO ACCOUNTS RETURNED: ' + JSON.stringify(this.soldToList));
                //this.distributorAccounts = this.soldToList;
                this.selectAccountModal = true;
                this.distributorAccounts = this.soldToList;
                this.searchable = [];

                this.showFooter = true;
                console.log('SETTING DISTRIBUTOR ACCOUNTS: ' + JSON.stringify(this.distributorAccounts));
            })
            .catch(error => {
                console.error(error);
                this.error = error;
            });

        this.goToStepTwo();


        // this.selectAccountModal = true;
        //refreshApex(this.distributorAccounts);
        //this.getSoldToAccounts();


        //this.showFooter = true;
        //this.goToStepTwo();


    }

    //SELECTING AGENT ONLY
    setSelectedAgentOnly(event) {
        console.log('AGENT (ONLY) SCREEN SELECT BUTTON EXECUTED');
        const row = this.searchable[event.target.value];
        console.log('ROW ID Selected Agent: ' + this.searchable[event.target.value].Id);
        this.selectedAgentID = row.Id;
        this.selectedAgentAccount = row.Name;
        console.log('Selected Agent Name: ' + row.Name);
        //this.customerAgentSegment = row.Customer_Segmentation__c;
        this.customerAgentSegment = row.segment;
        console.log('Selected Agent Customer Segment: ' + row.Customer_Segmentation__c);
        this.accountAgentNumber = row.GE_LGT_EM_SAP_Customer_Number__c;
        this.selectedAccount = ' ';
        this.selectedID = ' ';
        this.customerSegment = ' ';
        this.accountNumber = ' ';
        this.handleAccountChange();
        this.selectAccountModal = false;
        this.hasRender = false;

        localStorage.setItem('DataStored', "YES");

        localStorage.setItem('AgentNumber', this.accountAgentNumber);
        localStorage.setItem('AgentName', this.selectedAgentAccount);
        localStorage.setItem('AgentSegment', this.customerAgentSegment);
        localStorage.setItem('AgentID', this.selectedAgentID);



        localStorage.removeItem('DistributorAccount');
        localStorage.removeItem('DistributorName');
        localStorage.removeItem('DistributorType');
        localStorage.removeItem('DistributorSegment');
        localStorage.removeItem('DistributorID');


        // FOR LOGGED IN AGENT - IF AGENT IS LB, THIS SETS VARIABLE TO TELL B2B TO POP THE ACCOUNT SELECTOR
        //let agentLength = this.accountAgentNumber.length;
        if (this.customerAgentSegment == "Lamp"){
            localStorage.setItem('PopSelector', "YES");
        } else {
            localStorage.removeItem('PopSelector');
        }

    }

    //SELECTING AGENT AND DISTRIBUTOR
    setSelectedAgent(event) {
        console.log('AGENT SCREEN SELECT BUTTON EXECUTED');
        const row = this.searchable[event.target.value];
        console.log('ROW ID Selected Agent: ' + this.searchable[event.target.value].Id);
        this.selectedAgentID = row.Id;
        this.selectedAgentAccount = row.Name;
        //this.customerAgentSegment = row.Customer_Segmentation__c;
        this.customerAgentSegment = row.segment;
        console.log('Selected Name: ' + row.Name);
        this.accountAgentNumber = row.GE_LGT_EM_SAP_Customer_Number__c;
        this.getSoldToAccounts();
        this.goToStepTwo();
        this.showFooter = true;
        localStorage.setItem('DataStored', "YES");
        localStorage.setItem('AgentNumber', this.accountAgentNumber);
        localStorage.setItem('AgentName', this.selectedAgentAccount);
        localStorage.setItem('AgentSegment', this.customerAgentSegment);
        localStorage.setItem('AgentID', this.selectedAgentID);


        //this.handleAccountChange();

    }

    // SELECTING DISTRIBUTOR ACCOUNT - STEP 2
    setSelectedDistributorAccount(event) {
        console.log('DISTRIBUTOR SCREEN SELECT BUTTON EXECUTED');
        const row = this.distributorAccounts[event.target.value];
        console.log('ROW ID Selected Customer: ' + this.distributorAccounts[event.target.value].Id);
        this.selectedID = row.Id;
        this.selectedAccount = row.Name;
        console.log('Selected Name: ' + row.Name);
        this.customerSegment = row.segment;
        console.log('Selected Account Number: ' + row.GE_LGT_EM_SAP_Customer_Number__c);
        this.accountNumber = row.GE_LGT_EM_SAP_Customer_Number__c;
        //this.getSoldToAccounts();
        this.handleAccountChange();
        this.selectAccountModal = false;
        this.hasRender = false;
        //this.currentStep = '1';
        this.showFooter = false;
        localStorage.setItem('DataStored', "YES");
        localStorage.setItem('DistributorAccount', this.accountNumber);
        localStorage.setItem('DistributorName', this.selectedAccount);
        localStorage.setItem('DistributorSegment', this.customerSegment);
        localStorage.setItem('DistributorID', this.selectedID);

      

        // FOR LOGGED IN DISTRIBUTOR - IF AGENT IS LB, THIS SETS VARIABLE TO TELL B2B TO POP THE ACCOUNT SELECTOR
        if(this.UserType != "Agent"){
            if (this.customerSegment == "Lamp"){
                localStorage.setItem('PopSelector', "YES");
            } else {
                localStorage.removeItem('PopSelector');
            }
        }
        //this.handleAccountChange();

    }

    //ADDED FOR 2 STEP
    async getSoldToAccounts() {
        await getSoldToAccounts({accountId: this.accountAgentNumber})
            .then(result => {
                this.soldToList = [];
                if (result) {
                    for (const account of result) {
                        const clone = Object.assign({}, account);
                        Object.setPrototypeOf(clone, this.accountProto);
                        console.log('Customer Name: '+account.Name);
                    if(account.Customer_Segmentation__c === "LB"){
                        clone.segment = "Lamp";
                        console.log('Setting Segment: '+clone.segment);
                    } else if(account.Customer_Segmentation__c === "FD"){
                        clone.segment = "Fixture";
                        console.log('Setting Segment: '+clone.segment);
                    }

                        this.soldToList.push(clone);
                    }
                }
                console.log('SOLD TO ACCOUNTS RETURNED: ' + JSON.stringify(this.soldToList));
                this.distributorAccounts = this.soldToList;
                console.log('SETTING DISTRIBUTOR ACCOUNTS: ' + JSON.stringify(this.distributorAccounts));
            })
            .catch(error => {
                console.error(error);
                this.error = error;
            });
    }

    searchDataTable(event) {
        if (this.currentStep == "1") {
            console.log('Searching...in Step 1..');
            if (this.UserType == "Agent") {
                var searchString = event.target.value.toUpperCase();
                console.log('Search Term: ' + searchString);
                var allRecords = this.accounts;
                var searchResults = [];
                var i;

                for (i = 0; i < allRecords.length; i++) {
                    if ((allRecords[i].Name) && (allRecords[i].Name.toUpperCase().includes(searchString)) ||
                        (allRecords[i].GE_LGT_EM_SAP_Customer_Number__c) && (allRecords[i].GE_LGT_EM_SAP_Customer_Number__c.toUpperCase().includes(searchString)) ||
                        (allRecords[i].ShippingCity) && (allRecords[i].ShippingCity.toUpperCase().includes(searchString)) ||
                        (allRecords[i].ShippingState) && (allRecords[i].ShippingState.toUpperCase().includes(searchString))) {
                        searchResults.push(allRecords[i]);
                    }
                }
                this.searchable = searchResults;
                console.log('Searchable Array: ' + JSON.stringify(this.searchable));

            } else {
                var searchString = event.target.value.toUpperCase();
                console.log('Search Term: ' + searchString);
                var allRecords = this.soldToList;
                var searchResults = [];
                var i;

                for (i = 0; i < allRecords.length; i++) {
                    if ((allRecords[i].Name) && (allRecords[i].Name.toUpperCase().includes(searchString)) ||
                        (allRecords[i].GE_LGT_EM_SAP_Customer_Number__c) && (allRecords[i].GE_LGT_EM_SAP_Customer_Number__c.toUpperCase().includes(searchString)) ||
                        (allRecords[i].ShippingCity) && (allRecords[i].ShippingCity.toUpperCase().includes(searchString)) ||
                        (allRecords[i].ShippingState) && (allRecords[i].ShippingState.toUpperCase().includes(searchString))) {
                        searchResults.push(allRecords[i]);
                    }
                }
                this.distributorAccounts = searchResults;
                console.log('Searchable Array: ' + JSON.stringify(this.soldToList));
            }

        } else if (this.currentStep == "2") {
            console.log('Searching...in Step 2..');
            var searchString = event.target.value.toUpperCase();
            console.log('Search Term: ' + searchString);
            var allRecords = this.soldToList;
            var searchResults = [];
            var i;

            for (i = 0; i < allRecords.length; i++) {
                if ((allRecords[i].Name) && (allRecords[i].Name.toUpperCase().includes(searchString)) ||
                    (allRecords[i].GE_LGT_EM_SAP_Customer_Number__c) && (allRecords[i].GE_LGT_EM_SAP_Customer_Number__c.toUpperCase().includes(searchString)) ||
                    (allRecords[i].ShippingCity) && (allRecords[i].ShippingCity.toUpperCase().includes(searchString)) ||
                    (allRecords[i].ShippingState) && (allRecords[i].ShippingState.toUpperCase().includes(searchString))) {
                    searchResults.push(allRecords[i]);
                }
            }
            this.distributorAccounts = searchResults;
            console.log('Searchable Array: ' + JSON.stringify(this.soldToList));

        }

    }


    handleKeyChange(event) {
        this.searchKey = event.target.value;
        return refreshApex(this.result);
    }

    goBackToStepOne() {

        this.currentStep = '1';
        this.searchable = this.accounts;
        this.template.querySelector('div.stepTwo').classList.add('slds-hide');
        this.template
            .querySelector('div.stepOne')
            .classList.remove('slds-hide');
        this.showFooter = false;

    }

    goToStepTwo() {

        this.currentStep = '2';
        //this.getSoldToAccounts();
        this.template.querySelector('div.stepOne').classList.add('slds-hide');
        this.template
            .querySelector('div.stepTwo')
            .classList.remove('slds-hide');


    }

    accountProto = {
        get isLBAgent() {
            return this.GE_LGT_EM_SAP_Customer_Number__c === this.accountAgentNumber;
        }
    }

    disconnectedCallback(){
      localStorage.clear();
    }

}