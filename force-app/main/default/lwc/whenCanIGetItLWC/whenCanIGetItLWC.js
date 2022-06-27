import { LightningElement, track, api, wire } from 'lwc';
//FOR FETCHING THE PICKLIST VALUES FROM ORG
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
//FOR FETCHING THE OBJECT INFO FROM ORG
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
//FOR FETCHING THE PICKLIST VALUES
import CASE_OBJECT from '@salesforce/schema/Case';
import QUESTION_CAT_FIELD from '@salesforce/schema/Case.Question_Category__c';

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
//USED FOR CASE AND CASE PRODUCT CREATION
import createCaseRecord from '@salesforce/apex/connectCreateCase.connectCreateReturnCase';
import createCaseProduct from '@salesforce/apex/connectCreateCase.createCaseProduct';
//USED TO FETCH CASE NUMBER OF THE CASE CREATED
import getCaseNumber from '@salesforce/apex/connectCreateCase.getCaseNumber';
import getCSOwnerId from '@salesforce/apex/connectCreateCase.getCSOwnerId';
//USED TO FETCH THE DETAILS FROM PRODUCT DATA TABLE

import getproductList from '@salesforce/apex/ProductDataTableController.getproductList';
import getProdFamilies from '@salesforce/apex/StockBalancingReturnLwcController.getProductFamilies';
import getproductRefList from '@salesforce/apex/ProductDataTableController.getproductRefList';
import getProdItemNewList from '@salesforce/apex/ProductDataTableController.getProdItemNewList';
import updateReturnItemList from '@salesforce/apex/ProductDataTableController.updateReturnItemList';
import getReturnProdList from '@salesforce/apex/ProductDataTableController.getReturnProdList';
//FOR REFRESHING THE DATA
import { refreshApex } from '@salesforce/apex';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const actions = [
    { label: 'edit', name: 'edit' },
];

export default class WhenCanIGetItLWC extends LightningElement {
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
    @track paramString=[];

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

    @track toggleSubmitLabel = "Submit";
    @track reqName; // REQUESTOR NAME FORM FIELD --> STEP 1
    @track reqEmail; // REQUESTTOR EMAIL FORM FIELD --> STEP 1
    @track reqPhone; // REQUESTOR PHONE FORM FIELD --> STEP 1
    @track contactID; //CONTACT INFORMATION FOR THE LOOGED IN USER
    @track accountID; // ACCOUNT INFORMATION FOR THE LOGGED IN USER
    @track questions=false; // USED FOR PICKING THE VALUES FROM QUESTION CATEGORY PICKLIST
    @track quest;
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
    @track productManualEntry = false;
    @track productList=[];  
    @track stepOneButton = false;  
    @track manualLines = []; 
    @track isSpinner = false;
    @track isLoading = false;
    @track caseType = "When Can I Get It";

    @api soldToAccount=[];
    @api transactionID; // DISPLAYS THE ID FOR THIS TRANSACTION --> USED IN BOTH FRONT AND BACKEND
    @api CaseNumber; // THE CASE ID THAT IS RETURNED AFTER SUBMIT
    @api agencyName; // ACCOUNT ID SELECTED FROM THE ACCOUNT LOOKUP FIELD --> STEP 1
    @api questionCat; //QUESTION CATEGORY PICKLIST 
    @api storedLines = [];
    @api cartCount = 0;
    @api recordId;   
    @api selectedProduct;  
    @track isProductIdAvailable = false;
    @track error;
    @track productList=[];
    @track selectedProduct;   
    @api valuetopass; 
    @api caseProductInsert = [];
    @api updatedId;

    @track prodFamilies = [];
    draftValues = [];
    value = [];
    @track preSelectedAccount;
    @track selectedDistributorID;
    @track notDistributor = false;
    @track selectedAccountID;
    @track selectedAccountName;
    @track selectedSoldToAccountName;
    @track userType;

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
        console.log('Generated ID: @@@@@@@@@@@@@@@@@@@'+ id);
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
                this.contactID = data.fields.ContactId.value;
                this.accountID = data.fields.AccountId.value; 
                this.setAccountfromSelector();
            } else {
                this.reqEmail = data.fields.Email.value;
                this.reqName = data.fields.Name.value;
                this.reqPhone = data.fields.Phone.value;  
                this.contactID = data.fields.ContactId.value;
                this.accountID = data.fields.AccountId.value; 
                this.convertPhone(this.reqPhone); 
                this.setAccountfromSelector();
            }

            //this.soldToAccount = this.accountID;
            /*getAccName({id_dtl: this.soldToAccount})
            .then(result => {
             this.accName = result;
            console.log(JSON.stringify("Account Name Selected "+ JSON.stringify(this.accName)))
            }); */
            //var inputacc=this.soldToAccount;
            //this.template.querySelector("c-account-search-custom").setConfirmValues(inputacc);
            
        }
    }
//--------------------------------------------------

// SETTING ACCOUNT NAME FIELD FROM THE ACCOUNT SELECTOR WHEN CASE IS INITIATIED
async setAccountfromSelector(){
    let storedUserType = localStorage.getItem('User Type');
    this.userType = localStorage.getItem('User Type');
    if(storedUserType == "Agent"){
        this.notDistributor = true;
        this.preSelectedAccount = localStorage.getItem('AgentName') + ' - ' + localStorage.getItem('AgentNumber') + ' - ' + localStorage.getItem('AgentSegment');
            this.selectorAccount = localStorage.getItem('AgentNumber');
            this.selectedAccountID =  localStorage.getItem('AgentID');
            this.selectedAccountName = localStorage.getItem('AgentName');
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
            var inputacc = retrieveData;
            console.log('Sending Account ID to Account Search: '+inputacc);
            this.template.querySelector("c-account-search-custom").setConfirmValues(inputacc);
            console.log('Setting Account Number from Local Storage: '+inputacc);
        }
        
    } else {

        this.preSelectedAccount = localStorage.getItem('DistributorName') + ' - ' + localStorage.getItem('DistributorAccount') + ' - ' + localStorage.getItem('DistributorSegment');
        this.selectorAccount = localStorage.getItem('DistributorAccount');
        this.selectedAccountID = localStorage.getItem('DistributorID');
        this.selectedAccountName = localStorage.getItem('DistributorName');
        console.log('Setting Account Lookup LWC - Preselected: '+this.selectorAccount);

        let retrieveData = localStorage.getItem('DistributorID');
        //let disAccountName = sessionStorage.getItem('DistributorName');
        //let disAccountSegment = sessionStorage.getItem('DistributorSegment');
        //let disID = sessionStorage.getItem('DistributorID');
        if(retrieveData != null){
            console.log('Setting Account From Selector: '+JSON.stringify(retrieveData));
            this.soldToAccount = retrieveData;
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
}
//--------------------------------------------------------------------------

//Getting the current url
    /*renderedCallback() {
        this.sfdcOrgURL = window.location.href;
    }*/

    connectedCallback(){
        this.setTimer();
        var today = new Date();
        var date = today.getFullYear()+'-'+(today.getMonth()+1)+'-'+today.getDate();
        var time = today.getHours() + ":" + today.getMinutes() + ":" + today.getSeconds();
        const id = 'id' + performance.now()+'-'+date+'-'+time;
        this.transactionID = id;
        console.log('Generated ID: '+ id);

        console.log('Setting the Transcation ID: '+this.transactionID);

        var setType = this._type;
        if(setType == "Warranty"){
            this.isWarranty = true;
        } 
        
        let URL = window.location.href;
        if(URL.includes('?requestURL=')==true){
            let urlSplit = URL.split('?requestURL=')[1];
            this.sfdcOrgURL = decodeURIComponent(urlSplit);
            console.log('Request URL: '+this.sfdcOrgURL);
        } else {
            this.sfdcOrgURL = window.location.href;
        }

        let paramURL = window.location.href;
        if(paramURL.includes('id=')==true){
            this.paramString = paramURL.split('id=')[1];
            if(this.paramString.length > 0){
                console.log('paramString@@@@@@@@@@'+this.paramString);
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

                var baseURL = window.location.origin;
                console.log('Base URL: '+baseURL);
                this.sfdcOrgURL = baseURL+'/Agents/s/';
                console.log('New URL: '+this.sfdcOrgURL);
                window.open(this.sfdcOrgURL, "_self");  
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

    @wire(getObjectInfo, { objectApiName: CASE_OBJECT })
        objectInfo;
        //FOR Picklist values for Job State
        @wire(getPicklistValues, { recordTypeId: '0123j000000X8ys', fieldApiName: QUESTION_CAT_FIELD})
        PicklistValues;

//----------------------------------------------------------

/*async handlePick(event) {
    this.questionCat = event.target.value;
    console.log('Question Category: '+this.questionCat);

    if(this.questionCat == 'Security, Visibility, and User Accounts' || 
        this.questionCat == 'Product, Price, and Availability' || 
        this.questionCat == 'Order Lookup' || 
        this.questionCat == 'Training and Tools' || 
        this.questionCat == 'Other'){
            this.questions = true;
    }
}*/

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

// HANDLES CLEAR FOR SOLD TO ACCOUNT SELECTION (LWC)
changeAccount(){
    
    this.preSelectedAccount = null;
    this.selectedDistributorID = null;
    this.searchKey = '';
   
}
//------------------------------------------------------

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
}

//-------------------------------------------------------
async handleChangeAcc(event){
   // this.soldToAccount = event.target.value;
   this.soldToAccount = event.detail.selectedRecordId;
   // this.soldToName = event.target.dataset.name;
    console.log('Sold To Account ID: '+ this.soldToAccount);
   // console.log('Sold To Account Name: '+ this.soldToName);
 
   await getAccName({id_dtl: this.soldToAccount})
    .then(result => {
    this.accName = result;
    console.log(JSON.stringify("Account Name Selected "+ JSON.stringify(this.accName)))
    }); 


}

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
        console.log('Selected Product :'+this.selectedProduct);
        await getproductList({prodId: this.selectedProduct})
            .then(result => {
                console.log("The Result from APEX is: "+JSON.stringify(result) );
                
                this.productList = result;
                console.log("The Result from APEX2 is: "+JSON.stringify(this.productList) );
                this.isProductIdAvailable = true;
            }).catch(error => {
                console.log("The error SENT TO APEX is: " +JSON.stringify(error));
                this.error = error;
                //this.data  = undefined;
            });  
        


    }
//-------------------------------------------------------------------------
   /* handleRowActions(event) {
        this.cartLabel = "Add to Cart";
        const actionName = event.detail.action.name;
        const row = event.detail.row;


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
        
        }*/

    // handleing record edit form submit
    /*handleSubmit(event) {
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
        
    }*/

   /* async handleSuccess() {
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
    }*/
    
    /*async handleClick( event ){
    
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
        var newSelVal = selected.map(row => { return { "Product_SKU__c": row.MaterialDescription__c, "Product_Description__c" :row.ccrz__ShortDescRT__c, "SKU__c":row.ccrz__SKU__c, "Type__c":"When Can I Get It",
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
    }*/
    
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

    const allValid = [...this.template.querySelectorAll('.validValue')]
            .reduce((validSoFar, inputCmp) => {
                        inputCmp.reportValidity();
                        return validSoFar && inputCmp.checkValidity();
            }, true);
                if (allValid) {
                    this.currentStep = '2';
        
                    this.template.querySelector('div.stepOne').classList.add('slds-hide');
                    this.template
                        .querySelector('div.stepTwo')
                        .classList.remove('slds-hide');
                        this.template.querySelectorAll('lightning-input-field').forEach(element => {
                            element.reportValidity();
                        });    
                
                    /*await getAccName({id_dtl: this.accountID})
                    .then(result => {
                    this.accName = result;
                    console.log(JSON.stringify("Account Name Selected "+ JSON.stringify(this.accName)))
                    }); */
                    this.reqName = this.template.querySelector(".rn").value;
                    console.log('Requestor Name '+this.reqName);
                    this.reqEmail = this.template.querySelector(".em").value;
                    console.log('Requestor Email '+this.reqEmail);
                    this.reqPhone = this.template.querySelector(".rp").value;
                    console.log('Requestor Phone'+this.reqPhone);
                    this.subject = this.template.querySelector('.fd').value;
                    console.log('Subject is'+this.subject);
                    this.quest = this.template.querySelector(".cd").value;
                    console.log('Questions'+this.quest);

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

goToStepThree(){
    this.currentStep = '3';
    //console.log(JSON.stringify("The step is: " + JSON.stringify(currentStep)));
    
        this.template.querySelector('div.stepTwo').classList.add('slds-hide');
        this.template
            .querySelector('div.stepThree')
            .classList.remove('slds-hide');
}


//Case Submission Code starts here

//USED FOR TAKING THE INPUT FROM USER
async handleSave(event){
    //console.log(JSON.stringify("The Result is: "));
    await getCSOwnerId({accountId: this.selectedAccountID, userType: this.userType})
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
    nCase.Connect_ID__c = this.transactionID;
    nCase.eLight_Form_Type__c = 'When Can I Get It';
    nCase.AccountId = this.selectedAccountID;
    if(this.selectedDistributorID != null || this.selectedDistributorID != ''){
        nCase.Sold_To_Account__c = this.selectedDistributorID;
    }
    nCase.Requestor_Email__c = this.reqEmail;
    nCase.eLight_Requestor_Phone__c = this.reqPhone;
    nCase.SuppliedEmail = this.reqEmail;
    nCase.eLight_Requestor_Name__c = this.reqName;
    //nCase.Question_Category__c = this.questionCat;
    nCase.Questions__c = this.quest;
    nCase.Type = 'Product and Availability';
    nCase.GE_NAS_Sub_Type__c = 'When Can I Get It?';
    nCase.Subject = this.subject+' - PreSales';
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
                    nCaseProduct.GE_NAS_Type_of_Problem1__c = 'Product And Availability';                                                
                    
                    console.log('State of Material Field: '+linesList[j].Material__c);
                    if (linesList[j].Material__c != null){
                        nCaseProduct.Material_Number__c = linesList[j].Material__c;
                    } else {
                        nCaseProduct.No_Cat_Number__c = linesList[j].Product_SKU__c;
                        nCaseProduct.No_Cat__c = true; 
                    }  

                    nCaseProduct.GE_NAS_Comments__c = linesList[j].Comments__c;
                    nCaseProduct.Unique_ID__c = linesList[j].Transaction_ID__c;
                    nCaseProduct.Order_Qty__c = linesList[j].Quantity__c;                                  
                    this.caseProductInsert.push(nCaseProduct);
                //console.log('Case Products to Insert: '+ JSON.stringify(this.caseProductInsert));    
            }
                createCaseProduct({newCaseProduct : this.caseProductInsert});
               

    console.log(result);             
       
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
        });    
}

//VALIDATION FOR REQUIRED FIELDS

handleValidation(){

    let acctName = this.soldToAccount;
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
//---------------------------------------------------------------------------------------

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
    this.sfdcOrgURL = baseURL+'/s';
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