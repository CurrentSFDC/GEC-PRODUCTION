import { LightningElement, track, api, wire } from 'lwc';

// USED FOR GETTING THE USER DATA - WITHOUT APEX CALL
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';
import EMAIL_FIELD from '@salesforce/schema/User.Email';
import PHONE_FIELD from '@salesforce/schema/User.Phone';
import CONTACT_FIELD from '@salesforce/schema/User.ContactId';
import ACCOUNT_FIELD from '@salesforce/schema/User.AccountId';
//USED FOR SHOWING THE ACCOUNT NAME IN REVIEW SCREEN
import getAccName from '@salesforce/apex/connectCreateCase.getAccountName';
//USED FOR ROUTING TO THE PROPER QUEUE
import getMarketingQueueId from '@salesforce/apex/connectCreateCase.getMarketingQueueId';
//USED FOR CASE AND CASE PRODUCT CREATION
import createCaseRecord from '@salesforce/apex/connectCreateCase.connectCreateReturnCase';
import createCaseProduct from '@salesforce/apex/connectCreateCase.createCaseProduct';
//USED TO FETCH CASE NUMBER OF THE CASE CREATED
import getCaseNumber from '@salesforce/apex/connectCreateCase.getCaseNumber';
//USED TO FETCH THE DETAILS FROM PRODUCT DATA TABLE
import getProdFamilies from '@salesforce/apex/StockBalancingReturnLwcController.getProductFamilies';
import getproductList from '@salesforce/apex/ProductDataTableController.getproductList';
import getproductRefList from '@salesforce/apex/ProductDataTableController.getproductRefList';
import getProdItemNewList from '@salesforce/apex/ProductDataTableController.getProdItemNewList';
import updateReturnItemList from '@salesforce/apex/ProductDataTableController.updateReturnItemList';
import getReturnProdList from '@salesforce/apex/ProductDataTableController.getReturnProdList';
//FOR REFRESHING THE DATA
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAgentId from '@salesforce/apex/connectCreateCase.getAgentId';

const actions = [
    { label: 'Edit', name: 'edit'},
    { label: 'Delete', name: 'delete'}
];




export default class MarketingCollateralLwc extends LightningElement {
    @track searchProducts = true;
    @track productColumns = [{
        label: 'Catalog #',
        fieldName: 'MaterialDescription__c',
        iconName: 'utility:products',
        type: 'Text',
        sortable: true
    },
    {
        label: 'SKU #',
        fieldName: 'ccrz__SKU__c',
        type: 'Text',
        sortable: true
    },
    {
        label: 'Product Description',
        fieldName: 'ccrz__ShortDescRT__c',
        iconName: 'utility:textbox',
        type: 'Text',
        sortable: true
    },
    {
        label: 'Comments',
        fieldName: 'Comments__c',
        iconName: 'utility:textbox',
        type: 'Text',
        sortable: true
    },
    {
    
        type: 'button-icon',
        initialWidth: 34,
        typeAttributes:{
            label: 'Edit',
            name: 'edit',
            rowActions: actions,        
            title: 'edit',
            iconName: 'utility:new',
            variant: 'brand'
    },
}];

    @track columns2 = [{
        label: 'Catalog #',
        fieldName: 'Product_SKU__c',
        iconName: 'utility:products',
        type: 'Text',
        sortable: true
    },
    {
        label: 'SKU #',
        fieldName: 'SKU__c',
        type: 'Text',
        sortable: true
    },
    {
        label: 'Product Description',
        fieldName: 'Product_Description__c',
        iconName: 'utility:textbox',
        type: 'Text',
        sortable: true
    },
    {
        label: 'Comments',
        fieldName: 'Comments__c',
        iconName: 'utility:textbox',
        type: 'Text',
        sortable: true
    }
    
];

// COLUMNS FOR THE VIEW CART MODAL
    @track cartColumns = [{
        label: 'Catalog #',
        fieldName: 'Product_SKU__c',
        iconName: 'utility:textbox',
        type: 'Text',
        sortable: true
    },
    {
        label: 'SKU #',
        fieldName: 'SKU__c',
        type: 'Text',
        sortable: true
    },
    {
        label: 'Quantity',
        fieldName: 'Quantity__c',
        type: 'Text',
        sortable: true
    },
    {
        label: 'Comments',
        fieldName: 'Comments__c',
        iconName: 'utility:textbox',
        type: 'Text',
        sortable: true
    },
    {
        type: 'button-icon',
        initialWidth: 34,
        iconName: 'utility:delete',
        typeAttributes:{
            label: 'Delete',
            name: 'delete',
            rowActions: actions,
            title: 'delete',
            iconName: 'utility:delete',
            iconClass: 'slds-icon-text-error',
            variant: { fieldName: 'buttonColor'}                
        },
        
    },

    ];

    // COLUMNS FOR THE VIEW CART MODAL
    @track reviewColumns = [{
        label: 'Catalog #',
        fieldName: 'Product_SKU__c',
        iconName: 'utility:products',
        type: 'Text',
        sortable: true
    },
    {
        label: 'SKU #',
        fieldName: 'SKU__c',
        type: 'Text',
        sortable: true
    },
    {
        label: 'Quantity',
        fieldName: 'Quantity__c',
        type: 'Text',
        sortable: true
    },
    {
        label: 'Comments',
        fieldName: 'Comments__c',
        iconName: 'utility:textbox',
        type: 'Text',
        sortable: true
    },

    ];


    @track toggleSubmitLabel = "Submit";
    @track reqName; // REQUESTOR NAME FORM FIELD --> STEP 1
    @track reqEmail; // REQUESTTOR EMAIL FORM FIELD --> STEP 1
    @track reqPhone; // REQUESTOR PHONE FORM FIELD --> STEP 1
    @track contactID; //CONTACT INFORMATION FOR THE LOOGED IN USER
    @track accountID; // ACCOUNT INFORMATION FOR THE LOGGED IN USER
    @track materialOption; //DEPENDENT PICKLIST STORAGE
    @track quest; //QUESTION VARIABLE STORAGE
    @track jobName;//JOB NAME VARIABLE STORAGE
    @track estimatedValue;//ESTIMATED VALUE STORAGE
    @track newQueueId; // STORING QUEUEID
    @track caseNumberNew;//CASE NUMBER
    @track currentStep;// TO MOVE THE STEPS
    @track stepOneButton = false;    
    @track subject; 
    @track caseNumberNew;//CASE NUMBER
    @track currentStep;// TO MOVE THE STEPS
    @track bShowModal1 = false;
    @track bShowModal = false;
    @track currentRecordId;
    @track isEditForm = false;
    @track flagIndi = false;
    @track valCheck = false;
    @track newRow;
    @track cartLabel;
    @track isProductIdAvailable = false;
    @track error;    
    @track productList=[];  
    @track stepOneButton = false;        
    @track isProductIdAvailable = false;
    @track error;    
    @track productManualEntry = false;
    @track manualLines = [];
    @track paramString=[]; 
    @track isSpinner = false;
    @track isLoading = false;

    @api CaseNumber; // THE CASE ID THAT IS RETURNED AFTER SUBMIT
    @api soldToAccount=[]; // ACCOUNT ID SELECTED FROM THE ACCOUNT LOOKUP FIELD --> STEP 1
    @api agencyName;// DISTRIBUTOR NAME
    @api material;//MATERIAL PICKLIST
    @api materialCategory;//MATERIAL CATEGORY PICKLIST
    @api storedLines = []; 
    @api cartCount = 0;
    @api recordId;   
    @api selectedProduct;  
    @api valuetopass; 
    @api caseProductInsert = [];
    @api updatedId;
    @api transactionID;
    @track prodDesc;
    @track agentNumber='DEFAULT';
    @track disAccount='DEFAULT';
    @track disName=[];
    @track acctName;

    draftValues = [];
    value = [];

    @track preSelectedAccount;
    @track selectedDistributorID;
    @track selectedSoldToAccountName;
    @track selectedAccountName; // SELECTED ACCOUNT NAME FROM SELECTOR OR OVERRIDE FROM LOOKUP
    @track selectedAccountID; // SELECTED ACCOUNT ID FROM SELECTOR OR OVERRIDE FROM LOOKUP
    @track selectorAccount;
    @track notDistributor = false;
    @track caseType = "Marketing Collateral";

    @track prodFamilies = [];

    @api 
    get type() {
    return this._type;
    }
        
    set type(value) {
    this._type = value;
    this.connectedCallback();
    }

    connectedCallback(){
        const id = 'id' + performance.now();
        this.transactionID = id;
        console.log('Generated ID: '+ id);
    }
    

// GET CURRENT LOGGED IN COMMUNITY USER INFORMATION
    @wire(getRecord, {
        recordId: USER_ID,
        fields: [NAME_FIELD, EMAIL_FIELD, PHONE_FIELD, CONTACT_FIELD, ACCOUNT_FIELD]
    }) wireuser({
        error,
        data
    }) {
        if (error) {
        this.error = error ; 
        } else if (data) {
            let internalUser = localStorage.getItem('internalName');
            if(internalUser != null){
                this.reqName = localStorage.getItem('internalName');
                this.reqEmail = localStorage.getItem('internalUserName');
                this.reqPhone = localStorage.getItem('internalUserPhone');
            } else {
                this.reqEmail = data.fields.Email.value;
                this.reqName = data.fields.Name.value;
                this.reqPhone = data.fields.Phone.value;  
                this.contactID = data.fields.ContactId.value;
                this.soldToAccount = data.fields.AccountId.value;
                this.convertPhone(this.reqPhone);
            }
            
            /*getAgentId({AccountId: this.soldToAccount})
            .then(result => {
            //this.agentNumber = result;
            if(this.agentNumber == 'N'){
                this.showDistroField = false;
                this.disAccount='DEFAULT_DIS';
                }
                else {
                    this.showDistroField = true;   
                }
            console.log(JSON.stringify("Agent Id "+ JSON.stringify(this.agentNumber)))
            });*/
            
            //var inputacc=this.soldToAccount;
            //this.template.querySelector("c-account-search-custom").setConfirmValues(inputacc);
            this.setAccountfromSelector();

        }
    }
//----------------------------------------------------------------------

// SETTING ACCOUNT NAME FIELD FROM THE ACCOUNT SELECTOR WHEN CASE IS INITIATIED
async setAccountfromSelector(){
    let storedUserType = localStorage.getItem('User Type');
    //this.template.querySelector("c-invoice-item-search").setVisibility(storedUserType);
    this.userType = storedUserType;
    if(storedUserType == "Agent"){
        this.notDistributor = true;
        this.preSelectedAccount = localStorage.getItem('AgentName') + ' - ' + localStorage.getItem('AgentNumber') + ' - ' + localStorage.getItem('AgentSegment');
        this.selectorAccount = localStorage.getItem('AgentNumber');
        this.selectedAccountID =  localStorage.getItem('AgentID');
        setTimeout(() => {  
            getAccountManagerName({AccountId: this.selectedAccountID})
                  .then(result => {
                  this.agencyManager = result;
                  console.log("Account Manager is "+ this.agencyManager);
                  }); 
           }, 1000);
        this.selectedAccountName = localStorage.getItem('AgentName');
        console.log('Setting Account Lookup LWC - Preselected: '+this.selectorAccount);
        console.log('Setting Account Lookup LWC - Preselected ID: '+this.selectedAccountID);
        
        this.showDistroField = true; 
        let retrieveData = localStorage.getItem('AgentID');
        let agentNum = localStorage.getItem('AgentNumber');
        
        await getProdFamilies({soldToAccId: null, agentAccId: this.selectedAccountID})
            .then(result => {
            this.prodFamilies = result;
            console.log('getProdFamilies:' + result);
            })
            .catch(error => {
                console.log(error);
                this.error = error;
            });


        let distributorData = localStorage.getItem('DistributorID');
                if (distributorData != null){
                    this.preSelectedSoldTo = localStorage.getItem('DistributorName') + ' - ' + localStorage.getItem('DistributorAccount') + ' - ' + localStorage.getItem('DistributorSegment');
                    this.distributorNumber = localStorage.getItem('DistributorAccount');
                    this.selectedDistributorID = localStorage.getItem('DistributorID');
                    //this.caseSoldTo = localStorage.getItem('DistributorID');
                    console.log('PRE SELECTED SOLD TO: '+this.preSelectedSoldTo);

                    this.template.querySelector('c-invoice-item-search').setManualButtons();
                    console.log('Passing SOLD TO ACCOUNT to Get Prod Families: '+this.selectedDistributorID);

                    await getProdFamilies({soldToAccId: this.selectedDistributorID, agentAccId: null})
                        .then(result => {
                        this.prodFamilies = result;
                        console.log('getProdFamilies:' + result);
                        })
                        .catch(error => {
                            console.log(error);
                            this.error = error;
                    });
                }
        //let disAccountName = sessionStorage.getItem('DistributorName');
        //let disAccountSegment = sessionStorage.getItem('DistributorSegment');
        //let disID = sessionStorage.getItem('DistributorID');
        if(retrieveData != null){
            console.log('Setting Account From Selector: '+JSON.stringify(retrieveData));
            this.soldToAccount = retrieveData;
            var inputacc = retrieveData;
            console.log('Sending Account ID to Account Search: '+inputacc);
            //this.caseSoldTo = localStorage.getItem('DistributorID');
            this.template.querySelector("c-account-search-custom").setConfirmValues(inputacc);
            this.template.querySelector("c-distributor-search-custom").setConfirmValues(agentNum);
            console.log('Setting Account Number from Local Storage: '+inputacc);
        }
        
    } else {
        //this.getProdFamilies();
        this.preSelectedAccount = localStorage.getItem('DistributorName') + ' - ' + localStorage.getItem('DistributorAccount') + ' - ' + localStorage.getItem('DistributorSegment');
        this.selectorAccount = localStorage.getItem('DistributorAccount');
        this.distributorNumber = this.selectorAccount;
        this.selectedAccountID = localStorage.getItem('DistributorID');
        this.selectedDistributorID = localStorage.getItem('DistributorID');
        //this.caseSoldTo = localStorage.getItem('DistributorID');
        this.selectedAccountName = localStorage.getItem('DistributorName');
        console.log('Setting Account Lookup LWC - Preselected: '+this.selectorAccount);
        console.log('Setting Account Lookup LWC - Preselected ID: '+this.selectedAccountID);

        let retrieveData = localStorage.getItem('DistributorID');
        //this.template.querySelector('c-invoice-item-search').setDistributorButtons();

        await getProdFamilies({soldToAccId: this.selectedDistributorID, agentAccountId: null})
            .then(result => {
            this.prodFamilies = result;
            console.log('getProdFamilies:' + result);
            })
            .catch(error => {
                console.log(error);
                this.error = error;
        });
        //let disAccountName = sessionStorage.getItem('DistributorName');
        //let disAccountSegment = sessionStorage.getItem('DistributorSegment');
        //let disID = sessionStorage.getItem('DistributorID');
        if(retrieveData != null){
            console.log('Setting Account From Selector: '+JSON.stringify(retrieveData));
            this.soldToAccount = retrieveData;
            var inputacc = retrieveData;
            console.log('Sending Account ID to Account Search: '+inputacc);
            this.template.querySelector("c-account-search-custom").setConfirmValues(inputacc);
            console.log('Setting Account Number from Local Storage: '+inputacc);
        }
    }
    
}

// SETTING ACCOUNT NAME FIELD FROM THE ACCOUNT SELECTOR WHEN CASE IS INITIATIED --- OLD
/*setAccountfromSelector(){
    let storedUserType = localStorage.getItem('User Type');
    if(storedUserType == "Agent"){

        this.notDistributor = true;
        this.preSelectedAccount = localStorage.getItem('AgentName') + ' - ' + localStorage.getItem('AgentNumber') + ' - ' + localStorage.getItem('AgentSegment');
            this.selectorAccount = localStorage.getItem('AgentNumber');
            console.log('Setting Account Lookup LWC - Preselected: '+this.selectorAccount);


        let retrieveData = localStorage.getItem('AgentID');
        let agentNum = localStorage.getItem('AgentNumber');
        //let disAccountName = sessionStorage.getItem('DistributorName');
        //let disAccountSegment = sessionStorage.getItem('DistributorSegment');
        //let disID = sessionStorage.getItem('DistributorID');
        if(retrieveData != null){
            console.log('Setting Account From Selector: '+JSON.stringify(retrieveData));
            this.soldToAccount = retrieveData;
            var inputacc = retrieveData;
            console.log('Sending Account ID to Account Search: '+inputacc);
            this.template.querySelector("c-account-search-custom").setConfirmValues(inputacc);
            this.template.querySelector("c-distributor-search-custom").setConfirmValues(agentNum);
            console.log('Setting Account Number from Local Storage: '+inputacc);
        }
        
    } else {
        this.preSelectedAccount = localStorage.getItem('DistributorName') + ' - ' + localStorage.getItem('DistributorAccount') + ' - ' + localStorage.getItem('DistributorSegment');
        this.selectorAccount = localStorage.getItem('DistributorAccount');
        console.log('Setting Account Lookup LWC - Preselected: '+this.selectorAccount);

        let retrieveData = localStorage.getItem('DistributorID');
        //let disAccountName = sessionStorage.getItem('DistributorName');
        //let disAccountSegment = sessionStorage.getItem('DistributorSegment');
        //let disID = sessionStorage.getItem('DistributorID');
        if(retrieveData != null){
            console.log('Setting Account From Selector: '+JSON.stringify(retrieveData));
            this.soldToAccount = retrieveData;
            var inputacc = retrieveData;
            console.log('Sending Account ID to Account Search: '+inputacc);
            this.template.querySelector("c-account-search-custom").setConfirmValues(inputacc);
            console.log('Setting Account Number from Local Storage: '+inputacc);
        }
    }
}*/
//--------------------------------------------------------------------------

//GETTING THE ACCOUNT NAME
    async handleChangeAcc(event){
        this.soldToAccount = event.detail.selectedRecordId;    
        console.log('Sold To Account ID: '+ this.soldToAccount);    
        await getAccName({id_dtl: this.soldToAccount})
            .then(result => {
            this.accName = result;
            console.log(JSON.stringify("Account Name Selected "+ JSON.stringify(this.accName)))
            });
            
            await getAgentId({AccountId: this.soldToAccount})
            .then(result => {
            this.agentNumber = result;
            console.log(JSON.stringify("Agent Id "+ JSON.stringify(this.agentNumber)))
            });

            if(this.agentNumber == 'N'){
            this.showDistroField = false;
            this.disAccount='DEFAULT_DIS';
            }
            else{
                this.showDistroField = true; 
            }
            
    }

//---------------------------------------------------------------------------------
//GETTING DISTRIBUTOR NAME
    async handleChangeDis(event){
        this.agencyName = event.target.value;
        console.log('Distributor Account is: '+this.agencyName)
        await getAccName({id_dtl: this.agencyName})
        .then(result => {
        this.acctName = result;
        console.log(JSON.stringify("Distributor Account Name Selected "+ JSON.stringify(this.acctName)))
        }); 
    }

//-------------------------------------------------------------------------------
//Distributor LWC Call Data

// HANDLE ACCOUNT SELECTED FROM ACCOUNT LOOKUP LWC
async handleAccountSelected(event){
       
    this.selectorAccount = event.detail.selectedAccount;
    this.selectedAccountID = event.detail.selectedAccountId;
    this.selectedAccountName = event.detail.selectedAccountName;
    console.log('Account Selected from AccountLookupLWC: '+this.selectorAccount);
    console.log('Account NAME Selected from AccountLookupLWC: '+this.selectedAccountName);
    console.log('Sending Account ID for Product Families: '+this.selectedAccountID);
               await getProdFamilies({soldToAccId: null, agentAccId: this.selectedAccountID})
               .then(result => {
               this.prodFamilies = result;
               console.log('getProdFamilies:' + result);
               })
               .catch(error => {
                   console.log(error);
                   this.error = error;
               });
}
//-----------------------------------------------------

// HANDLE SOLD TO ACCOUNT SELECTED IN THE SOLD TO LOOKUP LWC
async handleSoldToSelected(event){
    this.selectedDistributorID = event.detail.selectedAccountId;
    this.selectedAccountID = event.detail.selectedAccountId;
    this.selectedSoldToAccountName = event.detail.selectedSoldToAccountName
    console.log('Sending Account ID for Product Families: '+this.selectedDistributorID);
               await getProdFamilies({soldToAccId: this.selectedDistributorID, agentAccId: null})
               .then(result => {
               this.prodFamilies = result;
               console.log('getProdFamilies:' + result);
               })
               .catch(error => {
                   console.log(error);
                   this.error = error;
               });
}
//--------------------------------------------------------


//------------------------------------------------------

clearResults(event){
    this.clear = event.detail.clear;
    console.log('CLEARING ACCOUNT.....');
    console.log('CLEAR: '+this.clear);
    if(this.clear === "true"){
        this.searchKey = '';
        this.clearSoldTo = true;
        this.preSelectedAccount = null;
        this.selectorAccount = null;
        this.template.querySelector("c-sold-to-lookup-l-w-c").resetSoldTo();
    }
}
//--------------------------------------------------------------------------

//SETS THE LINE DATA FOR THE REVIEW TABLE
setReviewLines(event){
    this.storedLines = event.detail.lines;
    if(this.storedLines.length > 0){
        this.showNextButton = false;
    } else {
        this.showNextButton = true;
    }
}

// HANDLES CLEAR FOR SOLD TO ACCOUNT SELECTION (LWC)
changeAccount(){
    
    this.preSelectedAccount = null;
    this.selectedDistributorID = null;
    this.searchKey = '';
   
}
//------------------------------------------------------

clearResults(event){
    this.clear = event.detail.clear;
    console.log('CLEARING ACCOUNT.....');
    console.log('CLEAR: '+this.clear);
    if(this.clear === "true"){
        this.searchKey = '';
        this.clearSoldTo = true;
        this.preSelectedAccount = null;
        this.selectorAccount = null;
        this.template.querySelector("c-sold-to-lookup-l-w-c").resetSoldTo();
    }
}

confirmchange(event){
    this.orderLines = event.detail.selectedRecordId;
    this.orderingAgency=event.detail.selectedValue;
    console.log('The lines passed to child for Ordering: '+this.orderLines);
    this.disAccount = this.orderLines;
    this.agencyName = this.orderLines;
    if(this.orderingAgency==null){
        this.disName=[];
    }
    else{
    this.disName = this.orderingAgency;
    }
    console.log('The lines passed to child for Delivery: '+this.disAccount);
    console.log('The lines passed to child for Delivery: '+this.disName);

}

//---------------------------------------------------------------------------------
//MATERIAL AND CATEGORY SELECTION
    get matCatOption(){
        return[
            {label: 'Documents', value: 'Documents'},
            {label: 'Support Materials', value: 'Support Materials'},
            {label: 'Video / Photography Content', value: 'Video / Photography Content'},
            {label: 'Customer Support', value: 'Customer Support'},
            {label: 'Internal Training & Promotion', value: 'Internal Training & Promotion'},
            {label: 'Other', value: 'Other'},
        ];
    }

    @track materialOption1 = [
        {label: 'Product SpotLight Brochure', value: 'Product SpotLight Brochure'},
        {label: 'Product Spec Sheet', value: 'Product Spec Sheet'},
        {label: 'Product Install Guide', value: 'Product Install Guide'},
        {label: 'Product Family Brochure', value: 'Product Family Brochure'},        
        ];

    @track materialOption2 = [
        {label: 'IES Files', value: 'IES Files'},
        {label: 'Delistment Notice', value: 'Delistment Notice'},
        {label: 'BIM/RIVET Files', value: 'BIM/RIVET Files'},
        ];

    @track materialOption3 = [
        {label: 'Fast Track Video or Product Overview Video', value: 'Fast Track Video or Product Overview Video'},
        {label: 'Installation Video', value: 'Installation Video'},
        {label: 'Product & Application ', value: 'Product & Application '},
        {label: '360 Product Images', value: '360 Product Images'},
        ];

    @track materialOption4 =[ 
        {label: 'Co-branded Request', value: 'Co-branded Request'},
        {label: 'Help with Web', value: 'Help with Web'},
        {label: 'Co-branded social media posts', value: 'Co-branded social media posts'},
        {label: 'Press Release ', value: 'Press Release '},
        {label: 'Merchandising Support', value: 'Merchandising Support'},
        ];

    @track materialOption5 = [
        {label: 'New Promotion Request', value: 'New Promotion Request'},
        {label: 'Monthly Staying Current Webinar', value: 'Monthly Staying Current Webinar'},
        {label: 'Monthly Agent Webinar', value: 'Monthly Agent Webinar'},
        {label: 'Continued Education Training (AIA)', value: 'Continued Education Training (AIA)'},
        {label: 'Ondemand training question', value: 'Ondemand training question'},
        {label: 'Sales Training Slide Deck including Product Overview Slide', value: 'Sales Training Slide Deck including Product Overview Slide'},
        {labe: 'Interchange Guide', value: 'Interchange Guide'},
        ];

    @track materialOption6 = [
        {label: 'Other', value: 'Other'},
        ];


//--------------------------------------------------------------------------------
//DEPENDENT PICKLIST CHOOSING FACILITY

handlePick(event) {
    this.materialCategory = event.target.value;
    console.log('Material Category is: '+this.materialCategory);

        if(this.materialCategory == "Documents"){   
            console.log('materialOption: ')  ;
            this.materialOption=this.materialOption1;  
            console.log('materialOption6 After: ' + this.materialOption)  ;         
        }
        else if(this.materialCategory == "Support Materials"){
            console.log('materialOption: ')  ;
            this.materialOption=this.materialOption2;  
            console.log('materialOption After: ' + this.materialOption)  ;   
        }
        else if(this.materialCategory == "Video / Photography Content"){
            console.log('materialOption: ')  ;
            this.materialOption=this.materialOption3;  
            console.log('materialOption After: ' + this.materialOption)  ;   
        }
        else if(this.materialCategory == "Customer Support"){
            console.log('materialOption: ')  ;
            this.materialOption=this.materialOption4;  
            console.log('materialOption After: ' + this.materialOption)  ;   
        }
        else if(this.materialCategory == "Internal Training & Promotion"){
            console.log('materialOption: ')  ;
            this.materialOption=this.materialOption5;  
            console.log('materialOption After: ' + this.materialOption)  ;   
        }
        else{
            this.materialOption=this.materialOption6;  
        }
    }   

    connectedCallback(){
        this.setTimer();
        const id = 'id' + performance.now();
        this.transactionID = id;
        console.log('Generated ID: '+ id);

        //Code change for order id default
        this.sfdcOrgURL = window.location.href;
        if(this.sfdcOrgURL.includes('id=')==true){
            this.paramString = this.sfdcOrgURL.split('id=')[1];
            if(this.paramString.length > 0){
                this.value='By Line Item';
                this.columns=this.columns2;
                console.log('Prod ID from URL: '+ this.paramString);
                this.handleChangeNew();
            } 
        }
    } 

    //------------------- SESSION TIME OUT FUNCTIONS --------------------------------------------
@track delayTimer;
@track sessionModal = false;
@track timeVal = '00:00:00';

setTimer(){
    console.log('Creating Session Timer...');
    this.timerActive = true;
    this.delayTimer = 600000;
    var parentThis = this;
    console.log('Setting Timer to: '+this.delayTimer);

    // Run timer code in every 100 milliseconds
    this._interval = setInterval(() => {  

       // Time calculations for hours, minutes, seconds and milliseconds
     var hours = Math.floor((this.delayTimer % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
     var minutes = Math.floor((this.delayTimer % (1000 * 60 * 60)) / (1000 * 60));
     var seconds = Math.floor((this.delayTimer % ((1000 * 60)) / 1000) - 1);
     var milliseconds = Math.floor((this.delayTimer % (1000)));

    var hDisplay = hours > 0 ? (hours < 10 ? "0" + hours + ":" : hours + ":") : "00:";
    var mDisplay = minutes > 0 ? (minutes < 10 ? "0" + minutes + ":" : minutes + ":") : "00:";
    var sDisplay = seconds > 0 ? (seconds < 10 ? "0" + seconds : seconds) : "00";

       
        // Output the result in the timeVal variable
        parentThis.timeVal = hDisplay + mDisplay + sDisplay;

        
       this.delayTimer = this.delayTimer - 1000;

        
            if ( this.delayTimer === 60000 ) {  
                this.showSessionModal();  
            }  
            if ( this.delayTimer === 0 ) {  
                clearInterval(this._interval);
                this.template.querySelector("c-material-lookup-container-l-w-c").clearSessionCart();

                /*var baseURL = window.location.origin;
                console.log('Base URL: '+baseURL);
                this.sfdcOrgURL = baseURL+'/Agents/s/';
                console.log('New URL: '+this.sfdcOrgURL);
                window.open(this.sfdcOrgURL, "_self");  */
            }  
              
        console.log('Timer Status: '+parentThis.timeVal);
        console.log('Timer Countdown: '+this.delayTimer);
        
        
    }, 1000);
}

resetTimeout(){
        this.sessionModal = false;
        clearInterval(this._interval);
        this.setTimer();   
}

showSessionModal(){
    //this.setTimer();
    this.sessionModal = true;
    /*window.setTimeout(
        this.clearCart()
    , 180000);*/
}

//------------------- END SESSION TIMER FUNCTIONS --------------------------------------

//---------------------------------------------------------------------------------
//SELECTING PRODUCT DATA FROM PRODUCT DATATABLE
    async handleChange(event){
        console.log("You selected an product: " + event.detail.value[0]);
            this.selectedProduct = event.detail.value[0];
            console.log("The Result from : "+JSON.stringify(this.selectedProduct) );
            console.log("Type of" +typeof(this.selectedProduct));
        
        
            await getproductList({prodId: this.selectedProduct})
            .then(result => {
                console.log("The Result from APEX is: "+JSON.stringify(result) );
                
                this.productList = result;
                console.log("The Result from APEX2 is: "+JSON.stringify(this.productList) );
                this.isProductIdAvailable = true;
                //this.error = undefined;        
                
                
            
            }).catch(error => {
                console.log("The error SENT TO APEX is: " +JSON.stringify(error));
                this.error = error;
                //this.data  = undefined;
            });  
    }

    async handleChangeNew(event){
       // console.log("You selected an product: " + event.detail.value[0]);
            this.selectedProduct = this.paramString;
            console.log("The Result from : "+JSON.stringify(this.selectedProduct) );
            console.log("Type of" +typeof(this.selectedProduct));
        
        
            await getproductList({prodId: this.selectedProduct})
            .then(result => {
                console.log("The Result from APEX is: "+JSON.stringify(result) );
                
                this.productList = result;
                console.log("The Result from APEX2 is: "+JSON.stringify(this.productList) );
                this.isProductIdAvailable = true;
                //this.error = undefined;        
                
                
            
            }).catch(error => {
                console.log("The error SENT TO APEX is: " +JSON.stringify(error));
                this.error = error;
                //this.data  = undefined;
            });  
    }

    //-------------------------------------------------------------------------
    handleRowActions(event) {
        this.cartLabel = "Add to Request";
        const actionName = event.detail.action.name;
        const row = event.detail.row;

        this.prodDesc = event.detail.row.ccrz__ShortDescRT__c;

        console.log('Edit Row Prod Dtl: '+ this.prodDesc);


        console.log('Edit ActionName: '+ actionName);
        console.log('Edit Row: '+ JSON.stringify(row));
        switch (actionName) {
            case 'edit':
                this.editCurrentRecord(row);
                break;
            case 'show_details':
                this.showRowDetails(row);
                break;
            default:
        }
    }

        // view the current record details
        viewCurrentRecord(currentRow) {
            this.bShowModal1 = true;
            this.isEditForm = false;
            this.record = currentRow;
        }
        
        // closing modal box
        closeModal1() {
            this.bShowModal1 = false;
        }
        
        editCurrentRecord(currentRow) {
            // open modal box
            
            console.log('ship complete flg: '+ this.shipCompFlg);
            this.bShowModal1 = true;
            this.isEditForm = true;        
            console.log('Inside Edit: '+ this.bShowModal1);
            console.log('Inside Edit: '+ this.isEditForm );
        
            // assign record id to the record edit form
            this.currentRecordId = currentRow.Id;
        
        }

    // handleing record edit form submit
    handleSubmit(event) {
        let returnQty = this.template.querySelector('.dq').value;
        console.log('Return Qty: '+returnQty);   
        this.errorMessage = ""; 
        this.cartLabel = "Adding to Cart...";
        this.isLoading = true;
        // prevending default type sumbit of record edit form
        //event.preventDefault();

        // querying the record edit form and submiting fields to form
        console.log('Inbuilt Form Data Check: ' + JSON.stringify(event.detail.fields));
        //this.template.querySelector('lightning-record-edit-form').submit(event.detail.fields);
        const recordInputs = event.detail.fields.slice().map(draft=>{
            const fields = Object.assign({}, draft)
            return {fields}
        })
        console.log("recordInputs", recordInputs)

        const promises = recordInputs.map(recordInput => updateRecord(recordInput))
        Promise.all(promises).then(result=>{
            this.ShowToastMsg('Success', 'Order Details Updated')
        
    }).catch(error=>{
        this.ShowToastMsg('Error Updating Records', error.body.message, error)
    });
        
    }

    async handleSuccess() {
        await getproductRefList({prodId: this.selectedProduct})
                .then(result => {
                    this.productList = result;
                    console.log(result);
                    console.log('After refresh datatable data: ' + JSON.stringify(this.productList));
                    this.ShowToastMsg('Success', 'Product Date Updated')
                    this.bShowModal1 = false;
                    
                });
            this.handleClick(); 
    }
    

    ShowToastMsg(title, message, variant){
        this.dispatchEvent(
            new ShowToastEvent({
                title:title,
                message:message,
                variant:variant||'success'
            })
        )
    }

    async handleClick( event ){

    //  var updatedFields = event.detail.draftValues[0].Id;
    console.log('Before passing the Row ID: '+ this.updatedId);
    await getProdItemNewList({transId: this.currentRecordId}) 
            .then(result => {
                this.productList = result;
                console.log(result);
                console.log('Value passed from Apex for currentrow: ' + JSON.stringify(this.productList));
            });
        
        var selected = this.productList;
        console.log('Selected Lines: '+ JSON.stringify(selected));
        this.storedLines = selected;
        console.log('Stored Lines: '+ JSON.stringify(this.storedLines));
        var newSelVal = selected.map(row => { return { "Product_SKU__c": row.MaterialDescription__c, "Product_Description__c" :row.ccrz__ShortDescRT__c, "SKU__c": row.ccrz__SKU__c, "Type": "Marketing Collateral",
                    "Comments__c":row.Comments__c,"CC_Product_Id__c":row.Id, "Transaction_ID__c": this.transactionID, "Unique_ID__c": this.transactionID+'_'+row.MaterialDescription__c }});
        
        
        
        this.valuetopass = selected;
        console.log('value to pass check:' + JSON.stringify(this.valuetopass));
        
        console.log('value to pass check:' + JSON.stringify(newSelVal));
        await updateReturnItemList({data: newSelVal})
        .then(result => {
            
            console.log(JSON.stringify("Apex update result: "+ result));
            this.flagIndi= true;
            this.isLoading = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Records added to the cart successfully',
                    variant: 'success'
                })
            );
            this.fetchReturnItems();
    });

    }
    fetchReturnItems(){
        getReturnProdList({transId : this.transactionID})
            .then(result =>{
                this.storedLines = result;
                this.cartCount = this.storedLines.length;
            this.dispatchEvent(
                new CustomEvent('lineupdate', {
                    detail: {
                        lines : this.storedLines
                    }
                }));
        });
    }

    showWarranty(event){
        this.productManualEntry = true;
        this.isProductIdAvailable = false;
    }


    showCart(event) {
        this.bShowModal = true; // display modal window
    }

    // to close modal window set 'bShowModal' tarck value as false
    closeModal() {
        this.bShowModal = false;
    } 

    // POTENTIAL FUTURE - SAVE CART FUNCTION
    saveCart(){
        localStorage.setItem('localStr',JSON.stringify(this.storedLines));
        var retrieveData = JSON.parse(localStorage.getItem('localStr'));
        console.log('Data in Saved Cart: '+JSON.stringify(retrieveData));
    }

// FOLLOWING METHODS ARE FOR PROGRESSING THROUGH THE SCREENS
goBackToStepOne() {
    
    this.currentStep = '1';

    this.template.querySelector('div.stepTwo').classList.add('slds-hide');
    this.template
        .querySelector('div.stepOne')
        .classList.remove('slds-hide');
    
}

async goToStepTwo() {

        this.currentStep = '2';
        
        this.template.querySelector('div.stepOne').classList.add('slds-hide');
        this.template
            .querySelector('div.stepTwo')
            .classList.remove('slds-hide');
            this.template.querySelectorAll('lightning-input-field').forEach(element => {
                element.reportValidity();
            });    
    
        await getAccName({id_dtl: this.soldToAccount})
        .then(result => {
        this.accName = result;
        console.log(JSON.stringify("Account Name Selected "+ JSON.stringify(this.accName)))
        }); 
       
        console.log('Sending Account ID to fetch Queue: '+this.selectedAccountID);
        
                await getMarketingQueueId({accountId : this.selectedAccountID, userType : this.userType})
                .then(result => {
                this.newQueueId =result;
                console.log("The Result for new Owner: "+ JSON.stringify(this.newQueueId));   
            })
         
        
        this.reqName = this.template.querySelector(".rn").value;
        console.log('Requestor Name '+this.reqName);
        this.reqEmail = this.template.querySelector(".em").value;
        console.log('Requestor Email '+this.reqEmail);
        this.reqPhone = this.template.querySelector(".rp").value;
        console.log('Requestor Phone'+this.reqPhone);
        this.quest = this.template.querySelector(".cd").value;
        console.log('Questions'+this.quest);
        this.materialCategory = this.template.querySelector(".aba").value;
        console.log('Material Category'+this.materialCategory);
        this.material = this.template.querySelector(".asa").value;
        console.log('Material is'+this.material);
        this.jobName = this.template.querySelector(".lp").value;
        console.log('Job Name is'+this.jobName);
        this.estimatedValue = this.template.querySelector(".ls").value;
        console.log('Estimated Value is'+this.estimatedValue);
        this.subject = this.template.querySelector(".fd").value;
        console.log('Subject is : '+this.subject);

    if(this.agencyName !== undefined) {    
        await getAccName({id_dtl: this.agencyName})
            .then(result => {
            this.acctName = result;
            console.log(JSON.stringify("Distributor Account Name Selected "+ JSON.stringify(this.acctName)))
            });
    }
}

goBackToStepTwo() {
    this.currentStep = '2';

    this.template.querySelector('div.stepThree').classList.add('slds-hide');
    this.template
        .querySelector('div.stepTwo')
        .classList.remove('slds-hide');
}

goToStepThree(){
    this.currentStep = '3';    
    
        this.template.querySelector('div.stepTwo').classList.add('slds-hide');
        this.template
            .querySelector('div.stepThree')
            .classList.remove('slds-hide');
}


//Case Submission Code starts here

//USED FOR TAKING THE INPUT FROM USER
async handleSave(event){
    //console.log(JSON.stringify("The Result is: "));
    
    console.log('Subject is: '+this.subject);
    this.toggleSubmitLabel = "Submitting...";
    this.isSpinner = true;
    let nCase = { 'sobjectType': 'Case' };
    nCase.RecordTypeId = '0123j000000X8ys';
    nCase.OwnerId = this.newQueueId;
    nCase.ContactId = this.contactID;
    nCase.Origin = 'Connect';
    nCase.eLight_Form_Type__c = 'Marketing Collateral';
    nCase.AccountId = this.soldToAccount;
    if(this.selectedDistributorID != null || this.selectedDistributorID != ''){
        nCase.Sold_To_Account__c = this.selectedDistributorID;
    }
    //nCase.Sold_To_Account__c = this.agencyName;
    nCase.eLight_Requestor_Name__c = this.reqName;
    nCase.Requestor_Email__c = this.reqEmail;
    nCase.eLight_Requestor_Phone__c = this.reqPhone;
    nCase.SuppliedEmail = this.reqEmail;
    nCase.Material_Category__c = this.materialCategory;
    nCase.Material__c = this.material;
    nCase.Questions__c = this.quest;
    nCase.Estimated_Job_Value__c = this.estimatedValue;
    nCase.Job_Name__c = this.jobName;
    nCase.Type = 'Sales Support';
    nCase.GE_NAS_Sub_Type__c = 'Marketing Collateral';
    nCase.Subject =  this.subject +'- PreSales';
    console.log(JSON.stringify("Output of the Result is: "+ JSON.stringify(nCase)));        

    

    await createCaseRecord({newCase: nCase})
    .then(result => {
        //console.log(JSON.stringify("Output of the Result is:113223 "));
        this.CaseNumber = result;
        console.log(JSON.stringify("The Result is: "+ JSON.stringify(this.CaseNumber))); 
        console.log('Passing Product Lines to Create Case Products: '+ JSON.stringify(this.storedLines));
        let tempHold = JSON.stringify(this.storedLines);
            console.log('Temp Hold Values: '+ tempHold);
            var linesList = JSON.parse(tempHold);
            console.log("Lines in the List: "+ linesList);
            console.log('Length of Lines List: '+JSON.stringify(linesList.length) );
            
            var j;
            for(j = 0; j < linesList.length; j++){
                console.log('Prod Line Length' + this.storedLines.length);
                console.log('J = '+ j);
                let nCaseProduct = {'sobjecttype': 'Shipment_Detail__c'};
                console.log('Prod Line check' + this.storedLines.length);
                    nCaseProduct.GE_NAS_Case_Number__c = this.CaseNumber;
                    nCaseProduct.GE_NAS_Type_of_Problem1__c = 'Sales Support';                                                
                    nCaseProduct.GE_NAS_Product_Code__c = linesList[j].Product_SKU__c;  
                    console.log('Product Code is' +JSON.stringify(linesList[j].SKU__c));                                  
                    nCaseProduct.Unique_ID__c = linesList[j].Transaction_ID__c;
                    nCaseProduct.GE_NAS_Comments__c = linesList[j].Comments__c;
                    nCaseProduct.Order_Qty__c = linesList[j].Quantity__c;                                                     
                    this.caseProductInsert.push(nCaseProduct);
                //console.log('Case Products to Insert: '+ JSON.stringify(this.caseProductInsert));    
            }
                createCaseProduct({newCaseProduct : this.caseProductInsert});            
       
        console.log(result);
        
    })

        .catch(error => {
            console.log(error);
            this.error = error;
        }); 

      await  getCaseNumber({CaseId: this.CaseNumber})
        .then(result => {
            this.caseNumberNew = result;
            console.log(JSON.stringify("The Result for Case Number: "+ JSON.stringify(this.caseNumberNew)))
            if (this.caseNumberNew != ' '){
                this.isSpinner = false;
                this.goToStepThree();
            }
        })
        .catch(error => {
            console.log(error);
            this.error = error;
            this.isSpinner = false;
        });    
    }

//VALIDATIONS

//Require Validation-------------------
    handleValidation(){

        let acName = this.soldToAccount;
        if (!acName){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'ERROR',
                    message: 'Please fill out all Required Fields',
                    variant: 'error'
                })
            );
        } else {

            const allValid = [...this.template.querySelectorAll('.validValue')]
            .reduce((validSoFar, inputCmp) => {
                        inputCmp.reportValidity();
                        return validSoFar && inputCmp.checkValidity();
            }, true);
                if (allValid) {
                    this.stepOneButton = false;
                    this.goToStepTwo();
                } else {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'ERROR',
                            message: 'Please fill out all Required Fields',
                            variant: 'error'
                        })
                    );
                }
        }
    }
//------------------------------------------------------------------------

    showManualEntry(event){
            
        this.productManualEntry = true;
        this.isProductIdAvailable = false;
        this.searchProducts = false;
    }

    showProduct(event){
        this.productManualEntry = false;
        this.searchProducts = true;

    }

    setManualLines(event){
        this.manualLines = event.detail.manuallines;
        this.storedLines = this.manualLines;
        this.cartCount = this.storedLines.length;
        console.log("Manual Lines Sending to Parent: "+JSON.stringify(this.manualLines));
        this.dispatchEvent(
            new CustomEvent('lineupdate', {
                detail: {
                    lines : this.manualLines
                }
            }));
    }

    goHome(event){
        var baseURL = window.location.origin;
        console.log('Base URL: '+baseURL);
        this.sfdcOrgURL = baseURL+'/s/';
        console.log('New URL: '+this.sfdcOrgURL);
        window.open(this.sfdcOrgURL, "_self");
    }

    goToCase(event){
        var baseURL = window.location.origin;
        console.log('Base URL: '+baseURL);
        this.sfdcOrgURL = baseURL+'/s/case/'+this.CaseNumber+'/detail';
        console.log('New URL: '+this.sfdcOrgURL);
        window.open(this.sfdcOrgURL, "_self");
    }

    handlePhoneChange(event){
        const myValue = this.template.querySelector(".rp");
        console.log('Phone Number being entered: '+myValue);

        const formattedNumber = this.formatPhoneNumber(myValue.value);        
        this.reqPhone = formattedNumber;
    }

    convertPhone(phone){
        var cleaned = ('' + phone).replace(/\D/g, '');
        var match = cleaned.match(/^(\d{3})(\d{3})(\d{4})$/);
        if (match) {
          this.reqPhone = '(' + match[1] + ') ' + match[2] + '-' + match[3];
        }
        return null;
    }

    formatPhoneNumber(value){
        // if input value is falsy eg if the user deletes the input, then just return
            if (!value) return value;

            // clean the input for any non-digit values.
            const phoneNumber = value.replace(/[^\d]/g, "");

            // phoneNumberLength is used to know when to apply our formatting for the phone number
            const phoneNumberLength = phoneNumber.length;

            // we need to return the value with no formatting if its less then four digits
            // this is to avoid weird behavior that occurs if you  format the area code to early
            if (phoneNumberLength < 4) return phoneNumber;

            // if phoneNumberLength is greater than 4 and less the 7 we start to return
            // the formatted number
            if (phoneNumberLength < 7) {
                return `(${phoneNumber.slice(0, 3)}) ${phoneNumber.slice(3)}`;
            }

            // finally, if the phoneNumberLength is greater then seven, we add the last
            // bit of formatting and return it.
            return `(${phoneNumber.slice(0, 3)}) ${phoneNumber.slice(
                3,
                6
            )}-${phoneNumber.slice(6, 9)}`;
    }
    

}