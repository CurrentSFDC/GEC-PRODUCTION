import { LightningElement, track, api, wire } from 'lwc';
//FETCHING FILE UPLOAD FROM APEX CLASSES
import updateFiles from '@salesforce/apex/connectCreateCase.updateFiles';
import getRelatedFiles from '@salesforce/apex/FileUploadViewController.getRelatedFiles';
//FETCHING ACCOUNT NAME AND CASE NUMBER FROM CONNECTCASECREATION APEX CLASS
import getCaseNumber from '@salesforce/apex/connectCreateCase.getCaseNumber';
import getAccName from '@salesforce/apex/connectCreateCase.getAccountName';
//USED FOR CREATION OF CASE AND CASE PRODUCT
import createCaseRecord from '@salesforce/apex/connectCreateCase.connectCreateReturnCase';
import getProdFamilies from '@salesforce/apex/StockBalancingReturnLwcController.getProductFamilies';
import createCaseProduct from '@salesforce/apex/connectCreateCase.createCaseProduct';
import getPricingQueueId from '@salesforce/apex/connectCreateCase.getPricingQueueId';
import getCSOwnerId from '@salesforce/apex/connectCreateCase.getCSOwnerId';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
// USED FOR GETTING THE USER DATA - WITHOUT APEX CALL
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';
import CONTACT_FIELD from '@salesforce/schema/User.ContactId';
import ACCOUNT_FIELD from '@salesforce/schema/User.AccountId';
import EMAIL_FIELD from '@salesforce/schema/User.Email';
import PHONE_FIELD from '@salesforce/schema/User.Phone';

const actions = [
    { label: 'Edit', name: 'edit'},
    { label: 'Delete', name: 'delete'}
];

export default class PricingRequestLwc extends LightningElement {

    @track currentStep; // VARIABLE FOR MOVING PATH
    @track reqName; // AGENT NAME FORM FIELD --> STEP 1   
    @track caseNumberNew; // FOR GETTING CASE NUMBER CREATED  
    @track lstAllFiles = []; // ARRAY OF FILES TO BE INSERTED INTO THE DATABASE 
    @track comments; //VARIABLE TO STORE COMMENTS
    @track filesToInsert = [];  
    @track subject = 'PreSales' ; 
    @track jobName; //VARIABLE FOR STORING JOB NAME ENTERED IN STEP 2
    @track estimatedVal; //VARIABLE FOR STORING ESTIMATED VALUE ENETERED IN STEP 2
    @track toggleSubmitLabel = "Submit";    
    @track accName;   
    @track stepOneButton = false;  
    @track isSpinner = false;
    @track values;
    @track reqEmail;
    @track reqPhone;
    @track showNextButton = true;
    @track newQueueId;


    @api CaseNumber; //VARIABLE FOR CASE ID
    @api contactID; //VARIABLE FOR STORING CONTACT ID
    @api accountID; //VARIABLE FOR STORING ACCOUNT ID
    @api transactionID; //VARIABLE FOR STORING THE TRANSCATION ID
    @api files; // TEMPORARILY STORES THE FILES UPLOADED IN THE FILEUPLOADVIEWER COMPONENT
    @api fileToDelete; // SELECTED FILES TO BE DELETED FROM THE FILEUPLOADVIEWER COMPONENT
    @api storedLines = [];
    @track prodFamilies = [];
    @api caseProductInsert = [];
    @api soldToAccount=[];
    @track caseAccountId;
    value = [];
    @track selectedDistributorID;
    @track preSelectedAccount;
    @track selectorAccount;
    @track selectedAccountName; // SELECTED ACCOUNT NAME FROM SELECTOR OR OVERRIDE FROM LOOKUP
    @track selectedAccountID; // SELECTED ACCOUNT ID FROM SELECTOR OR OVERRIDE FROM LOOKUP
    @track selectedSoldToAccountName; //SELECTED SOLD TO ACCOUNT FROM INVOICE SEARCH LWC
    @track notDistributor = false;
    @track caseType = "Pricing Inquiry";
    @track caseContactEmail;
    
    
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

    connectedCallback(){
        this.setTimer();
        var today = new Date();
        var date = today.getFullYear()+'-'+(today.getMonth()+1)+'-'+today.getDate();
        var time = today.getHours() + ":" + today.getMinutes() + ":" + today.getSeconds();
        const id = 'id' + performance.now()+'-'+date+'-'+time;
        this.transactionID = id;
        console.log('Generated ID: '+ id);

        console.log('Setting the Transcation ID: '+this.transactionID);
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
                window.open(this.sfdcOrgURL, "_self"); */ 
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

// GET CURRENT LOGGED IN COMMUNITY USER INFORMATION
    @wire(getRecord, {
        recordId: USER_ID,
        fields: [NAME_FIELD, CONTACT_FIELD, ACCOUNT_FIELD, EMAIL_FIELD, PHONE_FIELD]
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
                this.setAccountfromSelector();
            } else {

                this.reqName = data.fields.Name.value;            
                this.reqEmail = data.fields.Email.value;
                this.reqPhone = data.fields.Phone.value;  
                this.convertPhone(this.reqPhone);
                
            }
            this.caseContactEmail = data.fields.Email.value;
            this.contactID = data.fields.ContactId.value;
            this.soldToAccount = data.fields.AccountId.value;
            this.setAccountfromSelector();

            //var inputacc=this.soldToAccount;
            //this.template.querySelector("c-account-search-custom").setConfirmValues(inputacc);
            
        }
    }
//--------------------------------------------------

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
            //this.template.querySelector("c-account-search-custom").setConfirmValues(inputacc);
            //this.template.querySelector("c-distributor-search-custom").setConfirmValues(agentNum);
            console.log('Setting Account Number from Local Storage: '+inputacc);
        }
        
    } else {
        //this.getProdFamilies();
        this.preSelectedAccount = localStorage.getItem('DistributorName') + ' - ' + localStorage.getItem('DistributorAccount') + ' - ' + localStorage.getItem('DistributorSegment');
        this.selectorAccount = localStorage.getItem('DistributorAccount');
        this.distributorNumber = this.selectorAccount;
        //this.selectedAccountID = localStorage.getItem('DistributorID');
        this.selectedDistributorID = localStorage.getItem('DistributorID');
        //this.caseSoldTo = localStorage.getItem('DistributorID');
        this.selectedAccountName = localStorage.getItem('DistributorName');
        console.log('Setting Account Lookup LWC - Preselected: '+this.selectorAccount);
        console.log('Setting Account Lookup LWC - Preselected ID: '+this.selectedAccountID);

        let retrieveData = localStorage.getItem('DistributorID');
       

        getProdFamilies({soldToAccId: this.selectedDistributorID, agentAccountId: null})
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
            //this.template.querySelector("c-account-search-custom").setConfirmValues(inputacc);
            console.log('Setting Account Number from Local Storage: '+inputacc);
        }
    }
    
}


//OLD
/*async setAccountfromSelector(){
    let storedUserType = localStorage.getItem('User Type');
    if(storedUserType == "Agent"){
        this.notDistributor = true;
        this.preSelectedAccount = localStorage.getItem('AgentName') + ' - ' + localStorage.getItem('AgentNumber') + ' - ' + localStorage.getItem('AgentSegment');
            this.selectorAccount = localStorage.getItem('AgentNumber');
            this.selectedAccountID =  localStorage.getItem('AgentID');
            console.log('Setting Account Lookup LWC - Preselected: '+this.selectorAccount);
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
        let retrieveData = localStorage.getItem('AgentID');
        //let disAccountName = sessionStorage.getItem('DistributorName');
        //let disAccountSegment = sessionStorage.getItem('DistributorSegment');
        //let disID = sessionStorage.getItem('DistributorID');
        if(retrieveData != null){
            console.log('Setting Account From Selector: '+JSON.stringify(retrieveData));
            this.soldToAccount = retrieveData;
            this.caseAccountId = retrieveData;
            var inputacc = retrieveData;
            console.log('Sending Account ID to Account Search: '+inputacc);
            this.template.querySelector("c-account-search-custom").setConfirmValues(inputacc);
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
            this.caseAccountId = retrieveData;
            var inputacc = retrieveData;
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
            console.log('Sending Account ID to Account Search: '+inputacc);
            this.template.querySelector("c-account-search-custom").setConfirmValues(inputacc);
            console.log('Setting Account Number from Local Storage: '+inputacc);
        }
    }
}*/



//FILES ACCEPTED FORMAT FOR CHOOSING FILES
get acceptedFormats() {
    return ['.pdf','.png','.jpg','.jpeg','.doc','.docx', '.xls','.xlsx','.ppt','.pptx','.odt', '.rtf'];
}

get message() {
    return ['Formats: '+'pdf','png','jpg','jpeg','doc','docx', 'xls','xlsx','ppt','pptx','odt', 'rtf' + ' Max File Size: 10 MB'];
}

//--------------------------------------------------

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

// DATA PASSED FROM c/cCProductDataTable CHILD COMPONENT AND SETS THIS.STOREDLINES ARRAY
/*confirmUpdate(event){
    this.storedLines = event.detail.lines;
    console.log('The lines passed to Parent: '+JSON.stringify(this.storedLines));
    if(this.storedLines.length > 0){
        this.showNextButton = false;
    } else {
        this.showNextButton = true;
    }
}*/
//----------------------------------------------------------------------

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
                console.log('Files Returned from Apex: ' + result);
            })
            .catch(error => {
                console.log(error);
                this.error = error;
                console.log('Apex failed...');
            }); 
        
        }
//-------------------------------------------------------------------------
//USED FOR WHEN FILES ARE UPLOADED INTO THE SYSTEM USING THE UPLOAD FEATURE    
    handleUploadFinished(event) {
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
                console.log('Files Returned from Apex: ' + result);
            })
            .catch(error => {
                console.log(error);
                this.error = error;
                console.log('Apex failed...');
            }); 

    }
//---------------------------------------------------------------------------------
// SECTION FOR HANDLING ACCOUNT
   /* async handleChange(event) {        
        //this.soldToAccount = event.target.value;
        this.soldToAccount = event.detail.selectedRecordId;
        console.log('Sold To Account ID: '+ this.soldToAccount);

        await getAccName({id_dtl: this.soldToAccount})
        .then(result => {
        this.accName = result;
        console.log(JSON.stringify("Account Name Selected "+ JSON.stringify(this.accName)))
        }); 

    }*/
// -----------------------------------------------------------------------------
// OPTION FOR THE CHECKBOXES
    /*get options() {
        return [
            { label: 'Extended Warranty', value: 'Extended Warranty' }, 
            { label: 'Commission Change', value: 'Commission Change' },
        ];
    }
//----------------------------------------------------------------------------
// SELECTION OF THE CHECKBOX VALUES
    get selectedValues() {
        return this.value.join(',');
    }*/
//-----------------------------------------------------------------------------
// CHECKING NAD GETTING THE VALUES FOR CHECKBOXES
    /*handleCheckChange(e) {
        this.value = e.detail.value;
        const storeVal = this.value;
        console.log('Value from the Checkbox: '+ storeVal);

        if (storeVal=='Extended Warranty'){
            console.log('Inside If');
            this.valCheck=true;

        } else{
            console.log('Inside else');
            this.valCheck=false;       
            //this.storedLines=[];
            //console.log('Inside else'+ this.catChange);
        }
    }*/
//----------------------------------------------------------------------------
//FOR MOVING BACK INTO STEP 1
    goBackToStepOne() {
        this.currentStep = '1';

        this.template.querySelector('div.stepTwo').classList.add('slds-hide');
        this.template
            .querySelector('div.stepOne')
            .classList.remove('slds-hide');
    }
//-----------------------------------------------------------------------------------
//FOR MOVING INTO STEP 2
    goToStepTwo() {
        this.currentStep = '2';
        
        this.template.querySelector('div.stepOne').classList.add('slds-hide');
        this.template
            .querySelector('div.stepTwo')
            .classList.remove('slds-hide');
                
    }

//---------------------------------------------------------------------------------
//FOR MOVING BACK TO STEP 2
    goBackToStepTwo() {
        this.currentStep = '2';

        this.template.querySelector('div.stepThree').classList.add('slds-hide');
        this.template
            .querySelector('div.stepTwo')
            .classList.remove('slds-hide');
    }
//---------------------------------------------------------------------------------
//FOR MOVING TO STEP 3 AND GETTING VALUES OF VARIABLES TO SHOW IN REVIEW SCREEN
    async goToStepThree(){
        this.currentStep = '3';
        //console.log(JSON.stringify("The step is: " + JSON.stringify(currentStep)));
        
            this.template.querySelector('div.stepTwo').classList.add('slds-hide');
            this.template
                .querySelector('div.stepThree')
                .classList.remove('slds-hide');

                this.template.querySelectorAll('lightning-input-field').forEach(element => {
                    element.reportValidity();
                });    
                console.log(JSON.stringify("Move to the next screen Data check: "+ JSON.stringify(this.storedLines)));  

        await getAccName({id_dtl: this.soldToAccount})
        .then(result => {
        this.accName = result;
        console.log(JSON.stringify("Account Name Selected "+ JSON.stringify(this.accName)))
        }); 

        console.log('Agent : '+this.reqName);
        this.reqName = this.template.querySelector(".rn").value;
        console.log('Agency: '+this.soldToAccount);
        //this.soldToAccount = this.template.querySelector(".mn").value;
        console.log('Comments: '+this.comments);
        this.comments = this.template.querySelector(".pc").value;
        console.log('Subject is: '+this.subject);
        this.subject = this.template.querySelector(".fd").value +' - PreSales';    
        this.jobName = this.template.querySelector('.rp').value;
        console.log('Job Name is: '+this.jobName);
        this.estimatedVal = this.template.querySelector('.ls').value;
        console.log('Estimated Values is: '+this.estimatedVal);
    }

//---------------------------------------------------------------------------------
// FOR MOVING BACK TO STEP 3 and GOING TO STEP 4

goBackToStepThree() {
    this.currentStep = '3';

    this.template.querySelector('div.stepFour').classList.add('slds-hide');
    this.template
        .querySelector('div.stepThree')
        .classList.remove('slds-hide');
}

goToStepFour(){
    this.currentStep = '4';
    //console.log(JSON.stringify("The step is: " + JSON.stringify(currentStep)));
    
        this.template.querySelector('div.stepThree').classList.add('slds-hide');
        this.template
            .querySelector('div.stepFour')
            .classList.remove('slds-hide');
}
//----------------------------------------------------------------------------------



// FOR SAVING DATA AND CREATING CASE AND CASE PRODUCT
async handleSave(event){
    console.log("The Result of  is: "+this.transactionID); 
    console.log("Contact is: "+this.contactID)   ;
    console.log("The Result of Account is: "+this.soldToAccount); 

    await getCSOwnerId({accountId: this.soldToAccount, userType: this.userType})
    .then(result => {
        this.newQueueId =result;
        console.log("The Result for new Owner: "+ JSON.stringify(this.newQueueId));   
    }
    )

    this.toggleSubmitLabel = "Submitting...";
    this.isSpinner = true;
    let nCase = { 'sobjectType': 'Case' };
    nCase.RecordTypeId = '0123j000000X8ys';
    nCase.OwnerId = this.newQueueId; 
    nCase.ContactId = this.contactID;   
    nCase.Origin = 'Connect';            
    nCase.Job_Name__c = this.jobName;
    nCase.Connect_ID__c = this.transactionID;
    nCase.Estimated_Job_Value__c = this.estimatedVal;
    nCase.eLight_Comments__c = this.comments;  
    nCase.eLight_Form_Type__c = 'Pricing'; 
    nCase.SuppliedEmail = this.caseContactEmail;
    nCase.eLight_Requestor_Name__c = this.reqName;
    nCase.Requestor_Email__c = this.reqEmail;
    nCase.eLight_Requestor_Phone__c = this.reqPhone; 
    //Case.GE_NAS_Ship_Date__c = this.shipDate;    
    nCase.AccountId = this.soldToAccount;

    if(this.selectedDistributorID != null || this.selectedDistributorID != ''){
        nCase.Sold_To_Account__c = this.selectedDistributorID;
    }

    nCase.Type = 'Pricing';
    nCase.GE_NAS_Sub_Type__c = 'Pricing Inquiry';
    nCase.Subject = this.subject;
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
                    nCaseProduct.GE_NAS_Type_of_Problem1__c = 'Pricing';
                    console.log('State of Material Field: '+linesList[j].Material__c);
                    if (linesList[j].Material__c != null){
                        nCaseProduct.Material_Number__c = linesList[j].Material__c;
                    } else {
                        nCaseProduct.No_Cat_Number__c = linesList[j].Product_SKU__c;
                        nCaseProduct.No_Cat__c = true; 
                    }                                         
                    
                    nCaseProduct.Unique_ID__c = linesList[j].Transaction_ID__c;
                    nCaseProduct.GE_NAS_Comments__c = linesList[j].Comments__c; 
                    nCaseProduct.Order_Qty__c = linesList[j].Quantity__c;                                   
                    //nCaseProduct.GE_NAS_Quantity_Ordered__c = linesList[j].Selected_Qty__c;                    
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
            this.goToStepFour();
        }
    })
    .catch(error => {
        console.log(error);
        this.error = error;
        this.isSpinner = false;
    });
}


//----------------------------------------------------------------------------------

//Require Validation-------------------
handleValidation(){

    let jbName = this.template.querySelector('.rp').value;
    if (!jbName){
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