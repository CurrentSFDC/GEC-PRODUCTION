import { LightningElement, track, api , wire} from 'lwc';
//USED FOR GETTING ACCOUNT NAME OF THE LOGGED IN USER
import getAccName from '@salesforce/apex/connectCreateCase.getAccountName';
import getLDRQueueId from '@salesforce/apex/connectCreateCase.getLDRQueueId';
//USED FOR GETTING MANAGER OF THE AGENCY
import getAccountManagerName from '@salesforce/apex/connectCreateCase.getAccountManagerName'
//FETCHING FILE UPLOAD FROM APEX CLASSES
import updateFiles from '@salesforce/apex/connectCreateCase.updateFiles';
import getRelatedFiles from '@salesforce/apex/FileUploadViewController.getRelatedFiles';
import accountSelected from '@salesforce/messageChannel/selectedAccount__c';
// USED FOR GETTING THE USER DATA - WITHOUT APEX CALL
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';
import EMAIL_FIELD from '@salesforce/schema/User.Email';
import PHONE_FIELD from '@salesforce/schema/User.Phone';
import CONTACT_FIELD from '@salesforce/schema/User.ContactId';
import ACCOUNT_FIELD from '@salesforce/schema/User.AccountId';
import CURRENCY_FIELD from '@salesforce/schema/User.DefaultCurrencyIsoCode';
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
//FOR FETCHING THE PICKLIST VALUE AND RESPECTIVE OBJECTs
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
//FOR FETCHING THE PICKLIST VALUES
import CASE_OBJECT from '@salesforce/schema/Case';
import APPLICATION_TYPE_FIELD from '@salesforce/schema/Case.Application_Type__c';
import DESIRED_SERVICES_FIELD from '@salesforce/schema/Case.Connect_Desired_Services__c';
import APPROXIMATE_VALUE_FIELD from '@salesforce/schema/Case.Connect_Approximate_Values__c';
import getAgentId from '@salesforce/apex/connectCreateCase.getAgentId';

const actions = [
    { label: 'Edit', name: 'edit'},
    { label: 'Delete', name: 'delete'}
];



export default class LightingDesignLwc extends LightningElement {
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
        iconName: 'utiilty:textbox',
        type: 'Text',
        sortable: true
    }
    
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
    /*{
        label: 'Product Description',
        fieldName: 'Material_Description__c',
        iconName: 'utility:textbox',
        type: 'Text',
        sortable: true
    },*/
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


    @track currentStep; // variable for moving cursor on UI
    @track toggleSubmitLabel = "Submit";
    @track reqName; // REQUESTOR NAME FORM FIELD --> STEP 1
    @track reqEmail; // REQUESTTOR EMAIL FORM FIELD --> STEP 1
    @track reqPhone; // REQUESTOR PHONE FORM FIELD --> STEP 1 
    @track agencyName; //STORING AGENCY NAME FIELD  
    @track accName;    
    @track sfdcOrgURL; // TO POPULATE THE CURRENT PAGE LINK
    @track agencyManager; //STORING MANAGER ID OF AGENCY
    @track soldToAccount;//STORING DISTRIBUTOR ACCOUNT
    @track subject;
    @track date;
    @track stepOneButton = false;        
    @track caseNumberNew;//CASE NUMBER
    @track currentStep;// TO MOVE THE STEPS
    @track bShowModal1 = false;
    @track bShowModal = false;
    @track isSpinner = false;
    @track isLoading = false;
    @track currentRecordId;
    @track isEditForm = false;
    @track flagIndi = false;
    @track valCheck = false;
    @track newRow;
    @track cartLabel;
    @track isProductIdAvailable = false;
    @track error;    
    @track productList=[];    
    @track otherVal=false;
    @track otherValue=false;    
    @api conName;
    @track conEmail;
    @track conPhn;
    @track jobName;
    @track jobNames;
    @track specRegNo;
    @track dueDate=[];
    @track specAgency;  
    @track accountName; 
    @track specReg; 
    @track filesToInsert = []; 
    @track lstAllFiles = []; // ARRAY OF FILES TO BE INSERTED INTO THE DATABASE 
    @api fileToDelete; // SELECTED FILES TO BE DELETED FROM THE FILEUPLOADVIEWER COMPONENT

    @track addressStreet;
    @track addressCity;
    @track addressState;
    @track addressPostalCode;
    @track addressCountry;

    @api CaseNumber;
    @api storedLines=[];
    @api cartCount = 0;
    @api recordId;   
    @api selectedProduct;  
    @api valuetopass; 
    @api caseProductInsert = [];
    @api updatedId;
    @api transactionID;
    @api applicationType;
    @api desiredService;
    @api approxValues;
    @api files;
    @track paramString=[];
    @track productManualEntry = false;
    @track manualLines = []; 
    @track prodDesc;
    @track agentNumber='DEFAULT';
    @track disAccount='DEFAULT';
    @track disName=[];
    @track acctName;
    @track date1;
    @track caseAccountId;

    @track preSelectedAccount;
    @track selectedDistributorID;
    @track selectedSoldToAccountName;
    @track selectedAccountName; // SELECTED ACCOUNT NAME FROM SELECTOR OR OVERRIDE FROM LOOKUP
    @track selectedAccountID; // SELECTED ACCOUNT ID FROM SELECTOR OR OVERRIDE FROM LOOKUP
    @track selectorAccount;
    @track caseType = "Lighting Application";
    @track notDistributor = true;
    @track invalidStart = false;
    @track formattedCurrencyCode;
    @track comments;
    @track caseContactEmail;

    draftValues = [];
    value = [];

    @track prodFamilies = [];

    @api 
    get type() {
    return this._type;
    }
        
    set type(value) {
    this._type = value;
    this.connectedCallback();
    }

    countryOptions = [
        { label: 'United States', value: 'US' },
        { label: 'Canada', value: 'CA' },
    ];

    get countryOptions(){
        return this.countryOptions;
    }

 // GET CURRENT LOGGED IN COMMUNITY USER INFORMATION
 @wire(getRecord, {
    recordId: USER_ID,
    fields: [NAME_FIELD, EMAIL_FIELD, PHONE_FIELD, CONTACT_FIELD, ACCOUNT_FIELD, CURRENCY_FIELD]
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
                //this.setAccountfromSelector();
            } else {
                this.reqEmail = data.fields.Email.value;
                this.reqName = data.fields.Name.value;
                this.reqPhone = data.fields.Phone.value;
               
                console.log("Check for agencyName on load" + this.agencyName);
            }
            this.caseContactEmail = data.fields.Email.value;
            this.contactID = data.fields.ContactId.value;
            this.agencyName = data.fields.AccountId.value;
            this.CurrencyISOcode =data.fields.DefaultCurrencyIsoCode.value; 
            this.convertPhone(this.reqPhone);

            if(this.CurrencyISOcode == "USD"){
                this.CurrencyISOcodecheck=true;
                this.formattedCurrencyCode = "US"
            } else if(this.CurrencyISOcode == "CAD"){
                this.formattedCurrencyCode = "CA";
            }
        
        /*getAccountManagerName({AccountId: this.agencyName})
        .then(result => {
        this.agencyManager = result;
        console.log("Account Manager is "+ this.agencyManager);
        }); */

       /* getAgentId({AccountId: this.agencyName})
            .then(result => {
            this.agentNumber = result;
            if(this.agentNumber == 'N'){
                this.showDistroField = false;
                this.disAccount='DEFAULT_DIS';
                }
                else {
                    this.showDistroField = true;   
                }
            console.log(JSON.stringify("Agent Id "+ JSON.stringify(this.agentNumber)))
            });*/
        

        //var inputacc=this.agencyName;
        //this.template.querySelector("c-account-search-custom").setConfirmValues(inputacc);
        this.setAccountfromSelector();

        }
    }
//--------------------------------------------------

// SETTING ACCOUNT NAME FIELD FROM THE ACCOUNT SELECTOR WHEN CASE IS INITIATIED
/*--- OLD FUNCTION--- setAccountfromSelector(){
    let storedUserType = localStorage.getItem('User Type');
    if(storedUserType == "Agent"){

        let retrieveData = localStorage.getItem('AgentID');
        //let disAccountName = sessionStorage.getItem('DistributorName');
        //let disAccountSegment = sessionStorage.getItem('DistributorSegment');
        //let disID = sessionStorage.getItem('DistributorID');
        if(retrieveData != null){
            console.log('Setting Account From Selector: '+JSON.stringify(retrieveData));
            this.agencyName = retrieveData;

            getAccountManagerName({AccountId: this.agencyName})
            .then(result => {
            this.agencyManager = result;
            console.log("Account Manager is "+ this.agencyManager);
            }); 
            this.caseAccountId = retrieveData;
            var inputacc = retrieveData;
            console.log('Sending Account ID to Account Search: '+inputacc);
            this.template.querySelector("c-account-search-custom").setConfirmValues(inputacc);
            console.log('Setting Account Number from Local Storage: '+inputacc);

            getAgentId({AccountId: this.agencyName})
            .then(result => {
            this.agentNumber = result;
            if(this.agentNumber == 'N'){
                this.showDistroField = false;
                this.disAccount='DEFAULT_DIS';
                }
                else {
                    this.showDistroField = true;   
                }
            console.log(JSON.stringify("Agent Id "+ JSON.stringify(this.agentNumber)))
            });
        }
        
    } else {
        let retrieveData = localStorage.getItem('DistributorID');
        //let disAccountName = sessionStorage.getItem('DistributorName');
        //let disAccountSegment = sessionStorage.getItem('DistributorSegment');
        //let disID = sessionStorage.getItem('DistributorID');
        if(retrieveData != null){
            console.log('Setting Account From Selector: '+JSON.stringify(retrieveData));
            this.agencyName = retrieveData;
            this.caseAccountId = retrieveData;
            var inputacc = retrieveData;
            console.log('Sending Account ID to Account Search: '+inputacc);
            this.template.querySelector("c-account-search-custom").setConfirmValues(inputacc);
            console.log('Setting Account Number from Local Storage: '+inputacc);
        }
    }
}
*/

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
        this.notDistributor = false;
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
            this.template.querySelector("c-account-search-custom").setConfirmValues(inputacc);
            console.log('Setting Account Number from Local Storage: '+inputacc);
        }
    }
    
}


//--------------------------------------------------------------------------

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


//FOR FETCHING THE CURRENT DATE AND TRANSACTION ID
    async connectedCallback(){
        this.setTimer();
        var today = new Date();
        var date = today.getFullYear()+'-'+(today.getMonth()+1)+'-'+today.getDate();
        var time = today.getHours() + ":" + today.getMinutes() + ":" + today.getSeconds();
        const id = 'id' + performance.now()+'-'+date+'-'+time;
        this.transactionID = id;
        console.log('Generated ID: '+ id);

        console.log('Setting the Transcation ID: '+this.transactionID);

        /*var today = new Date();
        this.date=today.toISOString();
        console.log(today.toISOString());*/

        let URL = window.location.href;
        if(URL.includes('?requestURL=')==true){
            let urlSplit = URL.split('?requestURL=')[1];
            this.sfdcOrgURL = decodeURIComponent(urlSplit);
            console.log('Request URL: '+this.sfdcOrgURL);
        } else {
            this.sfdcOrgURL = window.location.href;
        }



        var today = new Date();
        var MyDate= new Date();
        var MyDateString;
        //MyDate.setDate(MyDate.getDate() + 20);
        var dd = String(today.getDate()).padStart(1, '0');
        var mm = String(today.getMonth() + 1).padStart(1, '0'); //January is 0!
        var yyyy = String(today.getFullYear());
        this.date = mm + '/' + dd + '/' + yyyy; 
        MyDateString =  MyDate.getFullYear() + '-' + ('0' + (MyDate.getMonth()+1)).slice(-2) + '-'+ ('0' + MyDate.getDate()).slice(-2);

        this.date1 =    MyDateString;
        console.log('Todays Date final: '+this.date1);


        
               
      /*  let paramURL = window.location.href;
        if(paramURL.includes('id=')==true){
            this.paramString = paramURL.split('id=')[1];
            if(this.paramString.length > 0){
                console.log('paramString@@@@@@@@@@'+this.paramString);
                this.handleChangeNew();
            }
        }*/
       


    
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
              
        //console.log('Timer Status: '+parentThis.timeVal);
       // console.log('Timer Countdown: '+this.delayTimer);
        
        
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
    


   
//FILES ACCEPTED FORMAT FOR CHOOSING FILES
get acceptedFormats() {
    return ['.pdf','.png','.jpg','.jpeg','.doc','.docx', '.xls','.xlsx','.ppt','.pptx','.odt', '.rtf'];
}

get message() {
    return ['Formats: '+'pdf','png','jpg','jpeg','doc','docx', 'xls','xlsx','ppt','pptx','odt', 'rtf' + ' Max File Size: 30 MB'];
}

get valueOptions(){
   if(this.CurrencyISOcode == "USD"){
    return [ 
        { label: 'Under $20,000', value: 'Under $20,000'},
        { label: '$20,000 - $50,000', value: '$20,000 - $50,000'},
        { label: '$50,000 - $100,000', value: '$50,000 - $100,000'},
        { label: '$100,000 - $250,000', value: '$100,000 - $250,000'},
        { label: 'Over $250,000', value: 'Over $250,000'},
    ]
   } else {
    return [ 
        { label: 'Under '+this.formattedCurrencyCode+'$20,000', value: 'Under '+this.formattedCurrencyCode+'$20,000'},
        { label: this.formattedCurrencyCode+'$20,000 - '+this.formattedCurrencyCode+'$50,000', value: this.formattedCurrencyCode+'$20,000 - '+this.formattedCurrencyCode+'$50,000'},
        { label: this.formattedCurrencyCode+'$50,000 - '+ this.formattedCurrencyCode+'$100,000', value: this.formattedCurrencyCode+'$50,000 - '+ this.formattedCurrencyCode+'$100,000'},
        { label: this.formattedCurrencyCode+'$100,000 - '+this.formattedCurrencyCode+'$250,000', value: this.formattedCurrencyCode+'$100,000 - '+this.formattedCurrencyCode+'$250,000'},
        { label: 'Over ' +this.formattedCurrencyCode+ '$250,000', value: 'Over ' +this.formattedCurrencyCode+ '$250,000'},
    ]
   }
}

//----------------------------------------------------
//FOR FETCHING PICKLIST FIELD APPLICATION TYPE FROM CASE OBJECT
    @wire(getObjectInfo, { objectApiName: CASE_OBJECT })
    objectInfo;
    //FOR Picklist values for Job State
    @wire(getPicklistValues, { recordTypeId: '0123j000000X8ys', fieldApiName: APPLICATION_TYPE_FIELD})
    PicklistValues;
    @wire(getPicklistValues, { recordTypeId: '0123j000000X8ys', fieldApiName: DESIRED_SERVICES_FIELD})
    SerPicklistValues;
    @wire(getPicklistValues, { recordTypeId: '0123j000000X8ys', fieldApiName: APPROXIMATE_VALUE_FIELD})
    AppPicklistValues;

//-------------------------------------------------------------

//GETTING AGENCY NAME and MANAGER IN UI WITH LOGGED IN USER
    async handleChangeAct(event){
        
   //  this.agencyName = event.target.value;    
        this.agencyName =event.detail.selectedRecordId
        console.log('Agency Name is: '+ this.agencyName);
    
    
        await getAccName({id_dtl: this.agencyName})
        .then(result => {
        this.accName = result;
        console.log(JSON.stringify("Account Name Selected "+ JSON.stringify(this.accName)))
        }); 

        await getAccountManagerName({AccountId: this.agencyName})
        .then(result => {
        this.agencyManager = result;
        console.log(JSON.stringify("Account Manager is "+ JSON.stringify(this.agencyManager)))
        }); 

        await getAgentId({AccountId: this.agencyName})
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
//-----------------------------------------------------------------------
// GETTING THE DITRIBUTOR NAME
    async handleChangeAcc(event){
        this.soldToAccount = event.target.value;
        console.log('Distributor Account is: '+this.soldToAccount)
        await getAccName({id_dtl: this.soldToAccount})
        .then(result => {
        this.acctName = result;
        console.log(JSON.stringify("Distributor Account Name Selected "+ JSON.stringify(this.acctName)))
        }); 
    }


  //-------------------------------------------------------------------------------
//Distributor LWC Call Data

    confirmchange(event){
    this.orderLines = event.detail.selectedRecordId;
    this.orderingAgency=event.detail.selectedValue;
    console.log('The lines passed to child for Ordering: '+this.orderLines);
    this.disAccount = this.orderLines;
    this.soldToAccount = this.orderLines;
    if(this.orderingAgency==null){
        this.disName=[];
    }
    else{
    this.disName = this.orderingAgency;
    }
    console.log('The lines passed to child for Delivery: '+this.disAccount);
    console.log('The lines passed to child for Delivery: '+this.disName);

}  
//----------------------------------------------------------------------------
//Getting the current url
    /*renderedCallback() {
        this.sfdcOrgURL = window.location.href;
    }*/
//-----------------------------------------------------------------------------
//FOR FETCHING THE CURRENT DATE
    /*connectedCallback(){
    var today = new Date();
    this.date=today.toISOString();
    console.log(today.toISOString())
    //var last=new Date(new Date().getFullYear(), 11, 32);
    //this.date1=last.toISOString();
    }*/
//FOR FETCHING ADDRESS
    handleAddressChange(event){
        this.addressStreet = event.target.street;
        this.addressCity = event.target.city;
        this.addressState = event.target.province;
        this.addressPostalCode = event.target.postalCode;
        this.addressCountry = event.target.country;
    }


//-----------------------------------------------------------------------------
//FOR PICKING THE VALUE OF APPLICATION TYPE
    async handlePick(event) {
        this.applicationType = event.target.value;
        console.log('Application Type is: '+this.applicationType);
        if(this.applicationType =='Other'){
            console.log('Application Type is Other:' +this.applicationType);
            this.otherVal = true;                        
        }
       // else if(this.applicationType == 'Garage' || this.applicationType == 'Roadway' || this.applicationType == 'Parking Lot' || this.applicationType == 'Indoor'){
        //    this.otherVal = false;
       // }
       else{
        this.otherVal = false;
       }
        
    }

//------------------------------------------------------------------------------
//FOR PICKING THE VALUE OF DESIRED SERVICES
async handlePrick(event) {
    this.desiredService = event.target.value;
    console.log('Desired Service is: '+this.desiredService);
    if(this.desiredService =='Other'){
        console.log('Desired Service is Other:' +this.desiredService);
        this.otherValue = true;                        
    }
    //else if(this.desiredService == 'Lighting Layout' || this.desiredService == 'Fixture / SKU Recommendation' || this.desiredService == 'Layout Review' || this.desiredService == 'Spec Review / Product Info'){
    //    this.otherValue = false;
    //}
    else{
        this.otherValue = false;
    }
    
}
//-------------------------------------------------------------------------
//Event For Due Date Field

handleDueDate(event){
    this.dueDate=[];
    console.log("inside the date event");
    var dateCheck= event.target.value;
    console.log("dateCheck" +dateCheck);
    if(dateCheck.length!=0){
    
    var dateChng = new Date(dateCheck);
    console.log("dateChng" +dateChng);
    this.dueDate = dateChng.getMonth() + 1 + '/' + dateChng.getDate() + '/' + dateChng.getFullYear();;
    console.log('Selected Date: '+this.dueDate);
    }
    
   
}

//------------------------------------------------------------------------------

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
     async handleChangeNew(){
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
        this.cartLabel = "Adding to Request...";
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
        var newSelVal = selected.map(row => { return { "Product_SKU__c": row.MaterialDescription__c, "Product_Description__c" :row.ccrz__ShortDescRT__c, "SKU__c":row.ccrz__SKU__c, "Type__c":"Lighting Application",
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
        this.warrantyEntry = true;
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

//---------------------------------------------------------------------
//CODE FOR SELECTION OF ORDERING AGENCY
    async confirmchangeNew(event){
        this.specAgency=event.detail.selectedRecordId;
        console.log('The lines passed to child for Delivery: '+this.specAgency);

        await getAccName({id_dtl: this.specAgency})
        .then(result => {
        this.accountName = result;
        console.log(JSON.stringify("Distributor Account Name Selected "+ JSON.stringify(this.accountName)))
        }); 
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

//_--------------------------------------------------------------------
 //USED FOR TAKING THE INPUT FROM USER
 async handleSave(event){
    //console.log(JSON.stringify("The Result is: "));
   console.log("The Result for OwnerId: "+ JSON.stringify(this.agencyName));
    await getLDRQueueId()
    .then(result => {
        this.newOwnerId =result;
        console.log("The Result for new manager: "+ JSON.stringify(this.newOwnerId));   
    }
    )

    this.toggleSubmitLabel = "Submitting...";
    this.isSpinner = true;
    let nCase = { 'sobjectType': 'Case' };
    nCase.RecordTypeId = '0123j000000X8yo';
    nCase.OwnerId = this.newOwnerId;
    nCase.ContactId = this.contactID;
    nCase.AccountId = this.caseAccountId;
    nCase.Origin = 'Connect';
    nCase.eLight_Form_Type__c = 'Lighting Application';
    nCase.Connect_ID__c = this.transactionID;
    nCase.Job_Name__c = this.jobName;        
    nCase.eLight_Requestor_Name__c = this.reqName;
    nCase.Requestor_Email__c = this.reqEmail;
    nCase.eLight_Requestor_Phone__c = this.reqPhone;
    nCase.Site_Contact_Name__c = this.conName;
    nCase.Site_Contact_Email__c = this.conEmail;
    nCase.Site_Contact_Phone__c = this.conPhn;
    nCase.Application_Type__c = this.applicationType; 
    nCase.Spec_Reg_Agency__c = this.specifyAgency;
    nCase.Spec_Reg_Number__c = this.specRegNo;
    nCase.Connect_Desired_Services__c = this.desiredService;
    nCase.GE_LGT_Actual_Due_Date__c = this.dueDate;   
    nCase.Connect_Approximate_Values__c = this.approxValues;
    nCase.SuppliedEmail = this.caseContactEmail;    
   // nCase.Estimated_Job_Value__c = this.estimatedSalesPrice;

   if(this.selectedDistributorID != null || this.selectedDistributorID != ''){
    nCase.Sold_To_Account__c = this.selectedDistributorID;
}
    nCase.eLight_Comments__c = this.comments;
    nCase.Type = 'Sales Support';
    nCase.GE_NAS_Sub_Type__c = 'Lighting Application';
    nCase.Subject =  this.subject +'- PreSales';
    nCase.eLight_Address_2__c = this.addressStreet + "\n" + this.addressCity + ', ' + this.addressState + ' ' + this.addressPostalCode + "\n" + this.addressCountry;
    console.log(JSON.stringify("Output of the Result is: "+ JSON.stringify(nCase)));        

    

    await createCaseRecord({newCase: nCase})
    .then(result => {
        //console.log(JSON.stringify("Output of the Result is:113223 "));
        this.CaseNumber = result;
        console.log(JSON.stringify("The Result is: "+ JSON.stringify(this.CaseNumber)));             
        console.log('Sending Files to UPDATE: '+ this.filesToInsert);
        //Apex call to get the case number 
        
                //CALLS APEX TO LINK UPLOADED FILES TO CASE
        updateFiles({passFiles: this.filesToInsert, CaseId: this.CaseNumber});
        //Apex call to update Owner
        //updateOwnerId({CaseId: this.CaseNumber});              
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
                nCaseProduct.Unique_ID__c = linesList[j].Transaction_ID__c;                                                             
                console.log('State of Material Field: '+linesList[j].Material__c);
                if (linesList[j].Material__c != null){
                    nCaseProduct.Material_Number__c = linesList[j].Material__c;
                } else {
                    nCaseProduct.No_Cat_Number__c = linesList[j].Product_SKU__c;
                    nCaseProduct.No_Cat__c = true; 
                }                 
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
                this.goToStepFive();
            }
        })
        .catch(error => {
            console.log(error);
            this.error = error;
            this.isSpinner = false;
        });    
}

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
 var startDate = this.template.querySelector('.kd').value;
 console.log('Date Entered: '+startDate);
    if( startDate < todayFormattedDate){
        this.invalidStart = true;
    }else{
        this.invalidStart = false;
    }
    this.duedatemap();
}


duedatemap(){
    var startDate12 = this.template.querySelector('.kd').value;
   // this.duedate1=startDate12;
    
    var year = startDate12.substring(0, 4);
    var month = startDate12.substring(5, 7);
    var day = startDate12.substring(8, 10);
    var todayFormattedDate1 = month+'/'+day+'/'+year;
    this.dueDate= todayFormattedDate1;
 console.log('Date Entered Test11: '+this.dueDate);
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
        /*this.currentStep = '3';
        
        this.template.querySelector('div.stepTwo').classList.add('slds-hide');
        this.template
            .querySelector('div.stepThree')
            .classList.remove('slds-hide');*/

            const allValid = [...this.template.querySelectorAll('.validVal')]
            .reduce((validSoFar, inputCmp) => {
                        inputCmp.reportValidity();
                        return validSoFar && inputCmp.checkValidity();
            }, true);
                if (allValid) {
                     this.currentStep = '3';
					 this.template.querySelector('div.stepTwo').classList.add('slds-hide');
					 this.template
					.querySelector('div.stepThree')
					.classList.remove('slds-hide');
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

    goBackToStepThree() {
        this.currentStep = '3';

        this.template.querySelector('div.stepFour').classList.add('slds-hide');
        this.template
            .querySelector('div.stepThree')
            .classList.remove('slds-hide');
    }

    async goTostepFour(event) {
        const allValid = [...this.template.querySelectorAll('.validValues')]
        .reduce((validSoFar, inputCmp) => {
                    inputCmp.reportValidity();
                    return validSoFar && inputCmp.checkValidity();
        }, true);
            if (allValid) {
                  this.currentStep = '4';
    
    this.template.querySelector('div.stepThree').classList.add('slds-hide');
    this.template
        .querySelector('div.stepFour')
        .classList.remove('slds-hide');

        await getAccName({id_dtl: this.agencyName})
        .then(result => {
        this.accName = result;
        console.log(JSON.stringify(" Account Name Selected "+ JSON.stringify(this.accName)))
        });

            

        /*await getAccName({id_dtl: this.specAgency})
        .then(result => {
        this.accountName = result;
        console.log(JSON.stringify("Specifying Account Name Selected "+ JSON.stringify(this.accountName)))
        }); */

    this.reqName = this.template.querySelector(".rn").value;
    console.log('Requestor Name: '+this.reqName);
    this.reqEmail = this.template.querySelector(".em").value;
    console.log('Requestor Email: '+this.reqEmail);
    this.reqPhone = this.template.querySelector(".rp").value;
    console.log('Requestor Phone: '+this.reqPhone);
    //this.agencyName = this.template.querySelector(".sta").value;
    //console.log('Agency Name: '+this.agencyName);
    
   // this.soldToAccount = this.template.querySelector(".stb").value;
    console.log('Distributor Account is: '+this.soldToAccount);
    this.applicationType = this.template.querySelector(".ff").value;
    this.desiredService = this.template.querySelector(".kk").value;
   /* if(this.applicationType =='Other'){
    this.applicationType = this.template.querySelector(".ff").value;
    this.desiredService = this.template.querySelector(".kk").value;
    console.log('Other Application Type: '+this.applicationType);    
    }
        else if(this.applicationType == 'Garage' || this.applicationType == 'Roadway' || this.applicationType == 'Parking Lot' || this.applicationType == 'Indoor'){
            this.applicationType = this.template.querySelector(".ff").value;
            console.log('Application Type is: '+this.applicationType);                  
        }
    if(this.desiredService =='Other'){
        this.desiredService = this.template.querySelector(".pd").value;
        console.log('Other Desired Services: '+this.desiredService);    
        }
        else if(this.desiredService == 'Lighting Layout' || this.desiredService == 'Fixture / SKU Recommendation' || this.desiredService == 'Layout Review' || this.desiredService == 'Spec Review / Product Info'){
            this.desiredService = this.template.querySelector(".kk").value;
            console.log('Desired Service is: '+this.desiredService);                  
        }*/
    this.jobName = this.template.querySelector(".ln").value;
    console.log('Job Name: '+this.jobName);
    this.conName = this.template.querySelector(".eun").value;
    console.log('Contact Name: '+this.conName);
    this.conEmail = this.template.querySelector(".eum").value;
    console.log('Contact Email: '+this.conEmail);            
    this.conPhn = this.template.querySelector(".eup").value;
    console.log('contact Phone: '+this.conPhn);
    
    if(this.notDistributor == true){
        this.approxValues = this.template.querySelector(".pp").value; 
        console.log('Approx Values: '+this.approxValues);   
        this.agencyManager = this.template.querySelector(".stq").value;
        console.log('Agency Manager is: '+this.agencyManager);  
    }
        
    this.jobNames = this.template.querySelector(".ln").value; 
    console.log('Job Names: '+this.jobNames);
    this.specRegNo = this.template.querySelector(".speregno").value; 
    console.log('Spec Reg Number: '+this.specRegNo);

    console.log("Review Page Due Date" + this.dueDate);
    //var dueDate = this.template.querySelector(".kd").value; 
    if(this.dueDate.length==0){
   
        var twoWeeksTime = new Date(Date.now() + 12096e5);
        //var formattedDate = twoWeeksTime.getDate() + '/' + (twoWeeksTime.getMonth()+1) + '/' + twoWeeksTime.getFullYear();
        var mm1 = String((twoWeeksTime.getMonth()+1)).padStart(1, '0');
        var dd1= String(twoWeeksTime.getDate()).padStart(2, '0');
        var yyyy1= twoWeeksTime.getFullYear();
        this.dueDate = mm1 + '/' + dd1 + '/' + yyyy1;
    } 
    var dDate = this.dueDate;
    console.log('Due Date1: '+ dDate) ;
 
    
    //this.dueDate = this.template.querySelector(".kd").value; 
    console.log('Due Date: '+this.dueDate);
    this.subject = this.template.querySelector('.fd').value;
    console.log('Subject is'+this.subject);
    this.specReg=this.accountName;
    console.log('Spec Registration Agency: '+this.accountName) 
    this.comments = this.template.querySelector('.pc').value;
    
    console.log('Street: '+this.endUserAddressStreet);
    console.log('City: '+this.EndUserAddressCity);
    console.log('State: '+this.EndUserAddressState);
    console.log('Postal Code: '+this.EndUserAddressPostalCode);
    console.log('Country: '+this.EndUserAddressCountry);

    await getAccName({id_dtl: this.soldToAccount})
    .then(result => {
    this.acctName = result;
    console.log(JSON.stringify("Distributor Account Name Selected "+ JSON.stringify(this.acctName)))
    }); 
   
    
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

    goToStepFive(){
        this.currentStep = '5';
        //console.log(JSON.stringify("The step is: " + JSON.stringify(currentStep)));
        
            this.template.querySelector('div.stepFour').classList.add('slds-hide');
            this.template
                .querySelector('div.stepFive')
                .classList.remove('slds-hide');
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

    //Require Validation-------------------
    handleValidation(){

        let acName = this.agencyName;
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

    handlePhoneChange(event){
        const myValue = this.template.querySelector(".rp");
        console.log('Phone Number being entered: '+myValue);

        const formattedNumber = this.formatPhoneNumber(myValue.value);        
        this.reqPhone = formattedNumber;
    }

    handleContactPhoneChange(event){
        const myValue = this.template.querySelector(".eup");
        console.log('Phone Number being entered: '+myValue);

        const formattedNumber = this.formatPhoneNumber(myValue.value);        
        this.conPhn = formattedNumber;
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