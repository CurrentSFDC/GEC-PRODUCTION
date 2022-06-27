import { LightningElement , api, wire, track} from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
//FOR FETCHING THE PICKLIST VALUES
import CASE_OBJECT from '@salesforce/schema/Case';
import Job_State_FIELD from '@salesforce/schema/Case.Job_State__c';
import Influencer_State_FIELD from '@salesforce/schema/Case.Influencer_State__c';
import Influencer_Role_FIELD from '@salesforce/schema/Case.Influencer_Role__c';
//import getProdFamilies from '@salesforce/apex/LwcLookupControllerCust.getProductFamilies';
import getProdFamilies from '@salesforce/apex/StockBalancingReturnLwcController.getProductFamilies';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import createCaseRecord from '@salesforce/apex/connectCreateCase.connectCreateReturnCase';
import createCaseProduct from '@salesforce/apex/connectCreateCase.createCaseProduct';
import getCaseNumber from '@salesforce/apex/connectCreateCase.getCaseNumber';
import updateFiles from '@salesforce/apex/connectCreateCase.updateFiles';
import getRelatedFiles from '@salesforce/apex/FileUploadViewController.getRelatedFiles';
import updateOwnerId from '@salesforce/apex/connectCreateCase.updateOwnerId';
import getOwnerId from '@salesforce/apex/connectCreateCase.getOwnerId';
//FOR FETCHING INFLUENCER DATA
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
//import NAME_FIELD from '@salesforce/schema/User.Name';
//import CITY_FIELD from '@salesforce/schema/User.City';
import CONTACT_FIELD from '@salesforce/schema/User.ContactId';
import ACCOUNT_FIELD from '@salesforce/schema/User.AccountId';
import EMAIL_FIELD from '@salesforce/schema/User.Email';

const actions = [
    { label: 'Edit', name: 'edit'},
    { label: 'Delete', name: 'delete'}
];

export default class NewSpecRegistrationLWC extends LightningElement {
    @api CaseNumber;
    @api jobName;
    @api jobCity;
    @api jobState;
    //@api jobState11;
    @api influencer;
    @api influencerCity;
    @api influencerState;
    @api estimatedBiddingStartDate;
    @api estimatedBiddingEndDate;
    @api estimatedSalesPrice;
    @api comments;
    @api specifyingAgencyName;
    @api specifyingAgencyRole;
    @api myRecordId;
    @api caseProductInsert = [];
    @api files;
    @api caseNum;
    @api contactID;
    @api accountID;
    @api accountName;
    @api accName;

    @api delAgency;
    @api deliveryAgency=[];
    @api flexipageRegionWidth;
    @api orderLines;

    @track toggleSubmitLabel = "Submit";
    @track filesToInsert = [];
    @track lstAllFiles = [];
    @track jobstate11;
    @track jobstate1;
    @api influencerStateInput;
    @api jobStateInput;
    @api fileToDelete;
    @track currentStep;
    @track values;
    @track data;
    @api selectedAccount=[];
    @track otherVal=false;
    @track influencerRole1;
    @track influencerRole2;
    @track newOwnerId;
    @track caseNumberNew; 
    @track today;
    @track invalidStart = false;
    @track invalidEnd = false;
    @track isSpinner = false;
    @track transactionID;
    @track reqEmail;
    @track showNextButton = true;
    
    @track orderingAgency; //NAME
    @track orderingAgencyID; //ID
    @track orderAgencyAccount; //NUMBER

    @track specifyingAgency;
    @track specifyingAgencyID;
    @track specifyingAgencyAccount;

    @track deliveryAgency;
    @track deliveryAgencyID;
    @track deliveryAgencyAccount;

    @track customerSegmentation;

    @track prodFamilies = [];
    @api storedLines = [];

    @api prodLines = [];
    @track stepOneButton = false;
    @track showDelivery = false;
    @track caseType = "New Spec Registration";

    @track columns = [
        { label: 'Name', fieldName: 'Title', type: 'text' },
        { label: 'Type', fieldName: 'FileExtension', type: 'text' },
    ];

    // COLUMNS FOR THE VIEW CART MODAL
    @track cartColumns = [{
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

    
    // GET CURRENT LOGGED IN COMMUNITY USER INFORMATION
    @wire(getRecord, {
        recordId: USER_ID, 
        fields: [CONTACT_FIELD, ACCOUNT_FIELD, EMAIL_FIELD]
    }) wireuser({
        error,
        data
    }) {
        if (error) {
        this.error = error ; 
        } else if (data) {
            let internalUser = localStorage.getItem('internalName');
            if(internalUser != null){
                //this.reqName = localStorage.getItem('internalName');
                this.reqEmail = localStorage.getItem('internalUserName');
                //this.reqPhone = localStorage.getItem('internalUserPhone');
            } else {
                //this.influencer = data.fields.Name.value;
                //this.influencerCity = data.fields.City.value;
                //this.influencerState = data.fields.State.value;
                this.contactID = data.fields.ContactId.value;
                this.accountID = data.fields.AccountId.value;
                this.reqEmail = data.fields.Email.value;
            }

            //this.selectedAccount = this.accountID;

            console.log("Check for this.selectedAccount"+this.accountID);
            //var inputacc = this.accountID;
            //this.template.querySelector("c-lwc-lookup-demo").setConfirmValues(inputacc);

            this.setAccountfromSelector();

           
        }
    }
//--------------------------------------------------

// OLD FUNCTION ------ SETTING ACCOUNT NAME FIELD FROM THE ACCOUNT SELECTOR WHEN CASE IS INITIATIED
/*setAccountfromSelector(){
    let storedUserType = localStorage.getItem('User Type');
    if(storedUserType == "Agent"){

        let retrieveData = localStorage.getItem('AgentID');
        //let disAccountName = sessionStorage.getItem('DistributorName');
        //let disAccountSegment = sessionStorage.getItem('DistributorSegment');
        //let disID = sessionStorage.getItem('DistributorID');
        if(retrieveData != null){
            console.log('Setting Account From Selector: '+JSON.stringify(retrieveData));
             this.selectedAccount = retrieveData;
            var inputacc = retrieveData;
            console.log('Sending Account ID to Account Search: '+inputacc);
            this.template.querySelector("c-lwc-lookup-demo").setConfirmValues(inputacc);
            console.log('Setting Account Number from Local Storage: '+inputacc);
        }
        
    } else {
        let retrieveData = localStorage.getItem('DistributorID');
        //let disAccountName = sessionStorage.getItem('DistributorName');
        //let disAccountSegment = sessionStorage.getItem('DistributorSegment');
        //let disID = sessionStorage.getItem('DistributorID');
        if(retrieveData != null){
            console.log('Setting Account From Selector: '+JSON.stringify(retrieveData));
            this.selectedAccount = retrieveData;
            var inputacc = retrieveData;
            console.log('Sending Account ID to Account Search: '+inputacc);
            this.template.querySelector("c-lwc-lookup-demo").setConfirmValues(inputacc);
            console.log('Setting Account Number from Local Storage: '+inputacc);
        }
    }
}*/
//--------------------------------------------------------------------------

// SETTING ACCOUNT NAME FIELD FROM THE ACCOUNT SELECTOR WHEN CASE IS INITIATIED
async setAccountfromSelector(){
    let storedUserType = localStorage.getItem('User Type');
    //this.template.querySelector("c-invoice-item-search").setVisibility(storedUserType);
    this.userType = storedUserType;
    if(storedUserType == "Agent"){
        this.notDistributor = true;
        this.preSelectedAccount = localStorage.getItem('AgentName') + ' - ' + localStorage.getItem('AgentNumber') + ' - ' + localStorage.getItem('AgentSegment');
        this.selectorAccount = localStorage.getItem('AgentNumber');
        this.specifyingAgencyID =  localStorage.getItem('AgentID');
        /*setTimeout(() => {  
            getAccountManagerName({AccountId: this.specifyingAgencyID})
                  .then(result => {
                  this.agencyManager = result;
                  console.log("Account Manager is "+ this.agencyManager);
                  }); 
           }, 1000);*/
        this.specifyingAgency = localStorage.getItem('AgentName');
        console.log('Setting Account Lookup LWC - Preselected: '+this.selectorAccount);
        console.log('Setting Account Lookup LWC - Preselected ID: '+this.specifyingAgencyID);
        
        this.showDistroField = true; 
        let retrieveData = localStorage.getItem('AgentID');
        let agentNum = localStorage.getItem('AgentNumber');
        
        await getProdFamilies({soldToAccId: null, agentAccId: this.specifyingAgencyID})
            .then(result => {
            console.log('New Spec Reg - Product Families Returned: '+ JSON.stringify(result));
            this.prodFamilies = result;
            console.log('getProdFamilies:' + result);
            })
            .catch(error => {
                console.log(error);
                this.error = error;
            });
        
    } 
    
}

//NEW FUNCTIONS:

// HANDLE ACCOUNT SELECTED FROM ACCOUNT LOOKUP LWC
async handleAccountSelected(event){
       
    this.specifyingAgencyAccount = event.detail.selectedAccount;
    this.specifyingAgencyID = event.detail.selectedAccountId;
    this.specifyingAgency = event.detail.selectedAccountName;
    console.log('Spec Account Selected from AccountLookupLWC: '+this.specifyingAgencyAccount);
    console.log('Spec Account NAME Selected from AccountLookupLWC: '+this.specifyingAgency);
    console.log('Sending Account ID for Product Families: '+this.orderingAgencyID);
               await getProdFamilies({soldToAccId: null, agentAccId: this.specifyingAgencyID})
               .then(result => {
            console.log('New Spec Reg - Product Families Returned: '+ JSON.stringify(result));
               this.prodFamilies = result;
               console.log('getProdFamilies:' + result);
               })
               .catch(error => {
                   console.log(error);
                   this.error = error;
               });
    
         
}
//-----------------------------------------------------

// HANDLE ORDERING AGENCY ACCOUNT SELECTED FROM ACCOUNT LOOKUP LWC
async handleOrderingAccountSelected(event){
       
    this.orderingAgencyAccount = event.detail.selectedAccount;
    this.orderingAgencyID = event.detail.selectedAccountId;
    this.orderingAgency = event.detail.selectedAccountName;
    this.customerSegmentation = event.detail.selectedCustomerSegmentation;
    this.preSelectedDelivery = this.orderingAgency + ' - ' + this.orderingAgencyAccount + ' - ' + this.customerSegmentation; 
    this.showDelivery = true;
    this.deliveryAgency = this.orderingAgency;
    this.deliveryAgencyID = this.orderingAgencyID;
    console.log('Ordering Account Selected from AccountLookupLWC: '+this.orderingAgencyAccount);
    console.log('Ordering Account NAME Selected from AccountLookupLWC: '+this.orderingAgency);
    /*console.log('Sending Account ID for Product Families: '+this.orderingAgencyID);
               await getProdFamilies({soldToAccId: null, agentAccId: this.orderingAgencyID})
               .then(result => {
            console.log('New Spec Reg - Product Families Returned: '+ JSON.stringify(result));
               this.prodFamilies = result;
               console.log('getProdFamilies:' + result);
               })
               .catch(error => {
                   console.log(error);
                   this.error = error;
               });*/
}
//-----------------------------------------------------

// HANDLE DELIVERY AGENCY ACCOUNT SELECTED FROM ACCOUNT LOOKUP LWC
async handleDeliveryAccountSelected(event){
       
    this.deliveryAgencyAccount = event.detail.selectedAccount;
    this.deliveryAgencyID = event.detail.selectedAccountId;
    this.deliveryAgency = event.detail.selectedAccountName;
    
    console.log('Delivery Account Selected from AccountLookupLWC: '+this.deliveryAgencyAccount);
    console.log('Delivery Account NAME Selected from AccountLookupLWC: '+this.deliveryAgency);
}
//-----------------------------------------------------

clearOrderingResults(event){
    this.clear = event.detail.clear;
    console.log('CLEARING ACCOUNT.....');
    console.log('CLEAR: '+this.clear);
    if(this.clear === "true"){
        this.searchKey = '';
        this.showDelivery = false;
        this.preSelectedDelivery = null;
        this.selectorAccount = null;
      
    }
}
//--------------------------------------------------------------------------

clearResults(event){
    this.clear = event.detail.clear;
    console.log('CLEARING ACCOUNT.....');
    console.log('CLEAR: '+this.clear);
    if(this.clear === "true"){
        this.searchKey = '';
        this.clearSoldTo = true;
        this.preSelectedAccount = null;
        this.selectorAccount = null;
       
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

//--------------------------------------------------------------------------

    @wire(getObjectInfo, { objectApiName: CASE_OBJECT })
    objectInfo;
    //FOR Picklist values for Job State
    @wire(getPicklistValues, { recordTypeId: '0123j000000X8ys', fieldApiName: Job_State_FIELD})
    PicklistValues;
    //For Picklist Values for Influence State
    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: Influencer_State_FIELD})
    InfluencerPicklistValues;
    //For Picklist Values of Influence Roles
    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: Influencer_Role_FIELD})
    RolePicklistValues;

    connectedCallback(){
        this.setTimer();
        const id = 'id' + performance.now();
        this.transactionID = id;
        console.log('Generated ID: '+ id);

        console.log('Setting the Transcation ID: '+this.transactionID);

        var today = new Date();
        var dd = String(today.getDate()).padStart(2, '0');
        var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
        var yyyy = today.getFullYear();

        this.today = dd + '/' + mm + '/' + yyyy;
        console.log('Todays Date: '+this.today);

        // window.onbeforeunload = function (e){
        //     return confirm('Are you sure you want to leave the page?');
        // };
        
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

                var baseURL = window.location.origin;
                console.log('Base URL: '+baseURL);
                this.sfdcOrgURL = baseURL+'/Agents/s/';
                console.log('New URL: '+this.sfdcOrgURL);
                window.open(this.sfdcOrgURL, "_self");  
            }  
              
        //console.log('Timer Status: '+parentThis.timeVal);
        //console.log('Timer Countdown: '+this.delayTimer);
        
        
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

    validateStart(){
        var today = new Date();        
        var dd = today.getDate();
        var mm = today.getMonth() + 1; //January is 0!
        var yyyy = today.getFullYear();
     // if date is less then 10, then append 0 before date   
        if(dd < 10){
            dd = '0' + dd;
        } 
    // if month is less then 10, then append 0 before date    
        if(mm < 10){
            mm = '0' + mm;
        }
        
     var todayFormattedDate = yyyy+'-'+mm+'-'+dd;
     var startDate = this.template.querySelector('.ln').value;
     console.log('Date Entered: '+startDate);
        if( startDate < todayFormattedDate){
            this.invalidStart = true;
        }else{
            this.invalidStart = false;
        }
        this.duedatemapStart();
    }

    duedatemapStart(){
        var startDate12 = this.template.querySelector('.ln').value;
       // this.duedate1=startDate12;
        
        var year = startDate12.substring(0, 4);
        var month = startDate12.substring(5, 7);
        var day = startDate12.substring(8, 10);
        var todayFormattedDate1 = month+'/'+day+'/'+year;
        this.estimatedBiddingStartDate= todayFormattedDate1;
     console.log('Date Entered Test11: '+this.estimatedBiddingStartDate);
    }


    validateEnd(){
        var today = new Date();        
        var dd = today.getDate();
        var mm = today.getMonth() + 1; //January is 0!
        var yyyy = today.getFullYear();
     // if date is less then 10, then append 0 before date   
        if(dd < 10){
            dd = '0' + dd;
        } 
    // if month is less then 10, then append 0 before date    
        if(mm < 10){
            mm = '0' + mm;
        }
        
     var todayFormattedDate = yyyy+'-'+mm+'-'+dd;
     var endDate = this.template.querySelector('.km').value;
     console.log('Date Entered: '+endDate);
        if(endDate < todayFormattedDate){
            this.invalidEnd = true;
        }else{
            this.invalidEnd = false;
        }
        this.duedatemapEnd();
    }

    duedatemapEnd(){
        var startDate12 = this.template.querySelector('.km').value;
       // this.duedate1=startDate12;
        
        var year = startDate12.substring(0, 4);
        var month = startDate12.substring(5, 7);
        var day = startDate12.substring(8, 10);
        var todayFormattedDate1 = month+'/'+day+'/'+year;
        this.estimatedBiddingEndDate= todayFormattedDate1;
     console.log('Date Entered Test11: '+this.estimatedBiddingEndDate);
    }

    confirmchange(event){
        this.orderLines = event.detail.selectedRecordId;
        this.orderingAgency=event.detail.selectedRecordId;
        console.log('The lines passed to child for Ordering: '+this.orderLines);
        this.delAgency = this.orderingAgency;
        console.log('The lines passed to child for Delivery: '+this.delAgency);
    
    }

    confirmchangeNew(event){
        this.delAgency=event.detail.selectedRecordId;
        console.log('The lines passed to child for Delivery: '+this.delAgency);
    }
   
    /*accountID(event){
        this.delAgency = event.detail.recordId;
        console.log('Selected SOLD-TO ID: '+ this.delAgency);
        //this.soldToName = event.detail.fieldValue;
        //console.log('Selected SOLD TO NAME: '+this.soldToName);
    }*/


    async handleChange(event) {
        //this.jobState = event.target.value;
        console.log("You selected an Account: " + event.detail.selectedRecordId);
        //console.log('Order Agency: '+this.orderingAgency);
        //console.log('Job Name: '+this.jobName);
        this.selectedAccount = event.detail.selectedRecordId;
        this.deliveryAgency = this.selectedAccount;
       console.log('deliveryAgency: '+this.deliveryAgency);       
        
    }

    
    async handlePick(event) {
        //this.jobState = event.target.value;
        //console.log('Job State: '+this.jobState);
        this.influencerRole = event.target.value;
        console.log('influencerRole: '+this.influencerRole);
        //console.log('Influencer Role: '+this.influencerRole);
        if(this.influencerRole =='Other'){
            console.log('Role is Other:' +this.influencerRole);
            this.otherVal = true;                        
        }
        else if(this.influencerRole == 'Architect' || this.influencerRole == 'Designer' || this.influencerRole == 'Contractor' || this.influencerRole == 'Engineer'){
            this.otherVal = false;
        }
        
    }

  /*  async handleState(event){
        this.influencerState = event.detail.selectedRecordId;
        console.log('Influencer Sate: '+this.influencerState);
    }*/
    

    //FILES ACCEPTED FORMAT FOR CHOOSING FILES
    get acceptedFormats() {
        return ['.pdf','.png','.jpg','.jpeg','.doc','.docx', '.xls','.xlsx','.ppt','.pptx','.odt', '.rtf'];
    }

    get message() {
        return ['Formats: '+'pdf','png','jpg','jpeg','doc','docx', 'xls','xlsx','ppt','pptx','odt', 'rtf' + ' Max File Size: 10 MB'];
    }


    // DATA PASSED FROM c/cCProductDataTable CHILD COMPONENT AND SETS THIS.PRODLINES ARRAY
    confirmUpdate(event){
            this.prodLines = event.detail.lines;
            console.log('The lines passed to Parent: '+JSON.stringify(this.prodLines));
            if(this.prodLines.length > 0){
                this.showNextButton = false;
            } else {
                this.showNextButton = true;
            }
    }


    //USED FOR WHEN FILES ARE DELETED FROM THE FILES TABLE
    handleActionFinished(event) {
        console.log('Post-Delete Action Fired...');
        this.fileToDelete = event.detail.contId;
        console.log('The File SET for deletion: ' + this.fileToDelete);

        const index = this.filesToInsert.indexOf(this.fileToDelete);
        this.filesToInsert.splice(index, 1);

        console.log('Files in the list AFTER Delete: '+ this.filesToInsert)

        
        console.log('File List Array Values: '+ this.files);
            getRelatedFiles({newFiles: this.filesToInsert})
            
            .then(result => {
                this.files = result;
                console.log(result);
                console.log('Files Returned from Apex: ' + JSON.stringify(this.files));
            })
            .catch(error => {
                console.log(error);
                this.error = error;
                console.log('Apex failed...');
            }); 
        
    }
    handleJobstatelookupchange(event) {
        this.jobState1 = event.detail;
        //console.log(JSON.stringify(this.mainData));
        console.log('Dispatched Job state data...'+this.jobState1);

    }

    handleInvoiceDataChange1(event) {
        this.jobState11 = event.detail;
        //console.log(JSON.stringify(this.mainData));
        console.log('Dispatched data...'+this.jobState11);

    }
        
    //USED FOR WHEN FILES ARE UPLOADED INTO THE SYSTEM USING THE UPLOAD FEATURE    
    async handleUploadFinished(event) {
        // Get the list of uploaded files
        const lstUploadedFiles = event.detail.files;
        //alert(event.detail.files[0].documentId);
        lstUploadedFiles.forEach(fileIterator => this.filesToInsert.push(fileIterator.documentId));
        console.log('Uploaded Files: ' + this.lstAllFiles);
        //this.filesToInsert = this.lstAllFiles;
        console.log('Files to Insert: ' + this.filesToInsert);
        console.log('Executing Apex Call...')
        console.log('Passing File IDs to Apex: ' + this.filesToInsert);

        getRelatedFiles({newFiles: this.filesToInsert})
            
            .then(result => {
                this.files = result;
                console.log(result);
                console.log('Files Returned from Apex: ' + JSON.stringify(result));
            })
            .catch(error => {
                console.log(error);
                this.error = error;
                console.log('Apex failed...');
            }); 

    }
    //USED FOR TAKING THE INPUT FROM USER
    async handleSave(event){
        //console.log(JSON.stringify("The Result is: "));
       

        this.toggleSubmitLabel = "Submitting...";
        this.isSpinner = true;
        let nCase = { 'sobjectType': 'Case' };
        nCase.RecordTypeId = '0123j000000X8ys';
        nCase.OwnerId = this.newOwnerId;
        nCase.ContactId = this.contactID;
        nCase.Origin = 'Connect';
        nCase.AccountId = this.specifyingAgencyID;
        nCase.eLight_Form_Type__c = 'New Spec Registration';
        nCase.Connect_ID__c = this.transactionID;
        nCase.Job_Name__c = this.jobName;        
        nCase.Job_City__c = this.jobCity;
        nCase.Job_State__c = this.jobState1;
        nCase.Influencer__c = this.influencer;
        nCase.SuppliedEmail = this.reqEmail;
        nCase.Requestor_Email__c = this.reqEmail;
        nCase.Influencer_City__c = this.influencerCity;
        nCase.Influencer_Role__c = this.influencerRole;
        nCase.Influencer_State__c = this.jobState11;
        nCase.Specifying_Agency_s_Role__c = this.specifyingAgencyRole; 
        nCase.Spec_Reg_Agency__c = this.specifyingAgencyID;
        nCase.Delivery_Agency__c = this.deliveryAgencyID;
        nCase.Ordering_Agency__c = this.orderingAgencyID;   
        nCase.Estimated_bidding_ordering_End_Date__c = this.estimatedBiddingEndDate;
        nCase.Estimated_bidding_ordering_Start_Date__c = this.estimatedBiddingStartDate;
        nCase.Estimated_Job_Value__c = this.estimatedSalesPrice;
        nCase.Description = this.comments;
        nCase.Type = 'Sales Support';
        nCase.GE_NAS_Sub_Type__c = 'New Specification Registration';
        nCase.Subject = 'New Specification Registration Case';
        console.log(JSON.stringify("Output of the Result is: "+ JSON.stringify(nCase)));        

        

        await createCaseRecord({newCase: nCase})
        .then(result => {
            //console.log(JSON.stringify("Output of the Result is:113223 "));
            this.CaseNumber = result;
            console.log(JSON.stringify("The Result is: "+ JSON.stringify(this.CaseNumber)));             
            console.log('Sending Files to UPDATE: '+ this.filesToInsert);
                    //CALLS APEX TO LINK UPLOADED FILES TO CASE
            updateFiles({passFiles: this.filesToInsert, CaseId: this.CaseNumber});
            console.log('Passing Product Lines to Create Case Products: '+ JSON.stringify(this.storedLines));
                let tempHold = JSON.stringify(this.storedLines);
                console.log('Temp Hold Values: '+ tempHold);
                var linesList = JSON.parse(tempHold);
                console.log("Lines in the List: "+ JSON.stringify(linesList));
                console.log('Length of Lines List: '+ linesList.length );
                
                var j;
                for(j = 0; j < linesList.length; j++){
                    console.log('Order Line Length' + this.storedLines.length);
                    console.log('J = '+ j);
                    let nCaseProduct = {'sobjecttype': 'Shipment_Detail__c'};
                    console.log('Prod Line check' + this.storedLines.length);
                        nCaseProduct.GE_NAS_Case_Number__c = this.CaseNumber;
                        nCaseProduct.GE_NAS_Type_of_Problem1__c = 'Sales Support';                                                
                        nCaseProduct.GE_NAS_Product_Code__c = linesList[j].Product_SKU__c; 
                        nCaseProduct.Unique_ID__c = linesList[j].Transaction_ID__c;
                        nCaseProduct.GE_NAS_Comments__c = linesList[j].Comments__c; 
                        nCaseProduct.Order_Qty__c = linesList[j].Quantity__c;                                   
                        //nCaseProduct.GE_NAS_Quantity_Ordered__c = linesList[j].Selected_Qty__c;                    
                        this.caseProductInsert.push(nCaseProduct);
                    //console.log('Case Products to Insert: '+ JSON.stringify(this.caseProductInsert));    
                }
                createCaseProduct({newCaseProduct : this.caseProductInsert}); 
                console.log(result);   
            this.goToStepFive();
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
                    this.goToStepFive();
                }
            })
            .catch(error => {
                console.log(error);
                this.error = error;
                this.isSpinner = false;
            });    
    }


    // FOLLOWING METHODS ARE FOR PROGRESSING THROUGH THE SCREENS
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
            this.template.querySelectorAll('lightning-input-field').forEach(element => {
                element.reportValidity();
            });            
    }

    goBackToStepTwo() {
        this.currentStep = '2';

        this.template.querySelector('div.stepThree').classList.add('slds-hide');
        this.template
            .querySelector('div.stepTwo')
            .classList.remove('slds-hide');
    }

    goToStepThree() {
        this.currentStep = '3';
        
        this.template.querySelector('div.stepTwo').classList.add('slds-hide');
        this.template
            .querySelector('div.stepThree')
            .classList.remove('slds-hide');
    }

    goBackToStepThree() {
        this.currentStep = '3';

        this.template.querySelector('div.stepFour').classList.add('slds-hide');
        this.template
            .querySelector('div.stepThree')
            .classList.remove('slds-hide');
    }


    async goTostepFour(event) {
        this.currentStep = '4';
        
        this.template.querySelector('div.stepThree').classList.add('slds-hide');
        this.template
            .querySelector('div.stepFour')
            .classList.remove('slds-hide');

        this.jobName = this.template.querySelector(".rn").value;
        console.log('Job Name: '+this.jobName);
        this.jobCity = this.template.querySelector(".em").value;
        console.log('Job City: '+this.jobCity);
        //this.jobState = this.template.querySelector(".aa").value;
       // console.log('Job State: '+this.jobState);
        this.influencerStateInput = this.jobState11;
        console.log('influ State*: '+this.influencerStateInput);
        this.jobStateInput = this.jobState1;
        console.log('Job State*: '+this.jobStateInput);

        this.influencer = this.template.querySelector(".lq").value;
        console.log('Influencer: '+this.influencer);
        this.influencerCity = this.template.querySelector(".gm").value;
        console.log('Influencer City: '+this.influencerCity);
        console.log('Influencer Role for below: '+this.influencerRole);
        if(this.influencerRole =='Other'){
        this.influencerRole = this.template.querySelector(".cd").value;
        console.log('Influencer Role1: '+this.influencerRole);    
        }
        else if(this.influencerRole == 'Architect' || this.influencerRole == 'Designer' || this.influencerRole == 'General Contractor'){
            this.influencerRole = this.template.querySelector(".cc").value;
            console.log('Influencer Role2: '+this.influencerRole);                  
        }
       // this.influencerState = this.template.querySelector(".bb").value;
       // console.log('Influencer State: '+this.influencerState);
        this.specifyingAgencyRole = this.template.querySelector(".lm").value;
        //console.log('Influencer State: '+this.specifyingAgencyRole);
        //this.specifyingAgency = this.selectedAccount;
        //console.log('Influencer State: '+this.specifyingAgencyRole);
        //this.orderingAgency;        
        //this.orderingAgency = this.template.querySelector(".mo").value;
        console.log('Order Agency: '+this.orderingAgency);
        //this.deliveryAgency = this.delAgency;
        console.log('Delivery Agency: '+this.deliveryAgency);
        //this.estimatedBiddingStartDate = this.template.querySelector(".ln").value;
        //this.estimatedBiddingEndDate = this.template.querySelector(".km").value;        
        this.estimatedSalesPrice = this.template.querySelector(".pn").value;  
        console.log('Estimated Job Value: '+this.estimatedSalesPrice)      ;
        this.comments = this.template.querySelector(".qm").value;      
        this.accountName =   this.selectedAccount;
        console.log('accountName: '+this.accountName);

        //this.delAgency =   this.template.querySelector(".qr").value;   

        var inputData={
            AccountID:this.accountName,
            OrderingAgency:this.orderingAgency,
            DeliveryAgency:this.deliveryAgency,
            JobName:this.jobName,
            JobCity:this.jobCity,
            //JobState:this.jobState,
            SpecifyingAgencyRole:this.specifyingAgencyRole,
            Comments:this.comments,
            EstimatedBiddingStartDate:this.estimatedBiddingStartDate,
            EstimatedBiddingEndDate:this.estimatedBiddingEndDate,
            Influencer:this.influencer,
            InfluencerCity:this.influencerCity,
            InfluencerRole:this.influencerRole,
           // InfluencerState:this.influencerState,
            EstimatedSalesPrice:this.estimatedSalesPrice,
            InfluencerStateInput:this.influencerStateInput,
            JobStateInput:this.jobStateInput

        };
        this.template.querySelector("c-new-spec-reg-child-l-w-c").setConfirmValues(inputData);
        this.getCaseOwner();
    }

    async getCaseOwner(){
        await getOwnerId({Spec_Reg_Agency: this.specifyingAgencyID})
        .then(result => {
            this.newOwnerId =result;
            console.log("The Result for new manager: "+ JSON.stringify(this.newOwnerId));   
        }
        )
    }

    goToStepFive(){
        this.currentStep = '5';
        //console.log(JSON.stringify("The step is: " + JSON.stringify(currentStep)));
        
            this.template.querySelector('div.stepFour').classList.add('slds-hide');
            this.template
                .querySelector('div.stepFive')
                .classList.remove('slds-hide');
    }

    handleValidation(){

        let acctName = this.selectedAccount;
        if (!acctName){
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

    handleValid(){

        let jbNm = this.template.querySelector('.rn').value;
        if (!jbNm){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'ERROR',
                    message: 'Please fill out all Required Fields',
                    variant: 'error'
                })
            );
        } else {

            const allValid = [...this.template.querySelectorAll('.validVal')]
            .reduce((validSoFar, inputCmp) => {
                        inputCmp.reportValidity();
                        return validSoFar && inputCmp.checkValidity();
            }, true);
                if (allValid) {
                    this.stepOneButton = false;
                    this.goToStepThree();
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

    handleVal(){

        let exVal = this.template.querySelector('.pn').value;
        if (!exVal){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'ERROR',
                    message: 'Please fill out all Required Fields',
                    variant: 'error'
                })
            );
        } else {

            const allValid = [...this.template.querySelectorAll('.validV')]
            .reduce((validSoFar, inputCmp) => {
                        inputCmp.reportValidity();
                        return validSoFar && inputCmp.checkValidity();
            }, true);
                if (allValid) {
                    this.stepOneButton = false;
                    this.goTostepFour();
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