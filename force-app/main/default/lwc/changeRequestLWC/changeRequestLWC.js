import { LightningElement, api, track, wire } from 'lwc';
// USED FOR GETTING THE USER DATA - WITHOUT APEX CALL
import { getRecord } from 'lightning/uiRecordApi';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import USER_ID from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';
import EMAIL_FIELD from '@salesforce/schema/User.Email';
import PHONE_FIELD from '@salesforce/schema/User.Phone';
import CONTACT_FIELD from '@salesforce/schema/User.ContactId';
import ACCOUNT_FIELD from '@salesforce/schema/User.AccountId';
import updateOrdLines from '@salesforce/apex/connectCreateCase.updateOrdLines';
import getOrderItemList from '@salesforce/apex/ChangeRequestOrderController.getChangeRequestOItem';
import updateReturnItemList from '@salesforce/apex/ChangeRequestOrderController.updReturnItemList';
import orderListData from '@salesforce/apex/ChangeRequestOrderController.getChangeReqUpdItem';
import getChangeReqRefList from '@salesforce/apex/ChangeRequestOrderController.getChangeReqRefList';
import getChangeReqCartItem from '@salesforce/apex/ChangeRequestOrderController.getChangeReqCartItem';
import getOrderDetails from '@salesforce/apex/OrderProductController.getOrderDetails';
import getCSOwnerId from '@salesforce/apex/connectCreateCase.getCSOwnerId';
import getOwnerId from '@salesforce/apex/connectCreateCase.getOwnerId';
import createCaseRecord from '@salesforce/apex/connectCreateCase.connectCreateReturnCase';
import createCaseProduct from '@salesforce/apex/connectCreateCase.createCaseProduct';
import getCaseNumber from '@salesforce/apex/connectCreateCase.getCaseNumber';
import getAccName from '@salesforce/apex/connectCreateCase.getAccountName';
import getAgentId from '@salesforce/apex/connectCreateCase.getAgentId';
import updDisName from '@salesforce/apex/ChangeRequestOrderController.updDisName';
//FETCHING FILE UPLOAD FROM APEX CLASSES
import updateFiles from '@salesforce/apex/connectCreateCase.updateFiles';
import getRelatedFiles from '@salesforce/apex/FileUploadViewController.getRelatedFiles';




const actions = [
    { label: 'Edit', name: 'edit'},
];

export default class ChangeRequestLWC extends LightningElement {

    // COLUMNS FOR ORDER LINE ITEM SELECTION SCREEN

    @track columns2 = [
    {
        label: 'PO#',
        fieldName: 'PO__c',
        type: 'Text',
        sortable: true,
        cellAttributes: { alignment: 'right' }
    },   
    {
        label: 'Order Line #',
        fieldName: 'Order_Line_Number__c',
        type: 'Text',
        sortable: true,
        cellAttributes: { alignment: 'left' }
    },
    {
        label: 'Catalog #',
        fieldName: 'SKU_Description_Cat_Logic__c',
        type: 'Text',
        iconName: 'utility:products',
        sortable: true,
        cellAttributes: { alignment: 'right' }
    },
    {
        label: 'SKU #',
        fieldName: 'SKU__c',
        type: 'Text',
        sortable: true,
        cellAttributes: { alignment: 'left' }
    }, 
    {
        label: 'Qty',
        fieldName: 'Quantity',
        iconName: 'utility:number_input',
        type: 'Text',
        sortable: true,
        cellAttributes: { alignment: 'left' }
    },
    {
        label: 'UOM',
        fieldName: 'UnitOfMeasure__c',
        type: 'Text',
        sortable: true,
        cellAttributes: { alignment: 'right' }
    },
    {
        label: 'Price',
        fieldName: 'UnitPrice',
        iconName: 'utility:money',
        type: 'currency',
        sortable: true,
        cellAttributes: { alignment: 'left' }
    },
    /*{
        label: 'Distributor Name',
        fieldName: 'Distributor_Name__c',
        type: 'Text',
        sortable: true,
        cellAttributes: { alignment: 'center' }
    },*/
    {
        label: 'Category of Change',
        fieldName: 'Category_Of_Change__c',
        iconName: 'utility:button_choice',
        type: 'Text',
        sortable: true,
        cellAttributes: { alignment: 'right' }
    },
    {
        label: 'Requested New Ship Date',
        fieldName: 'New_Shipment_Date__c',
        iconName: 'utility:date_input',
        type: 'date-local',
        sortable: true,
        cellAttributes: { alignment: 'left' },
        typeAttributes: {
            day: "numeric",
            month: "numeric",
            year: "numeric"
        }
    },
    {
        label: 'Change Text/Comment',
        fieldName: 'Reason_for_Change__c',
        iconName: 'utility:textbox',
        type: 'Text',
        sortable: true,
        wrapText: true,
        cellAttributes: { alignment: 'right'}
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
        
        /*type: 'action',
        typeAttributes: { rowActions: actions },
        cellAttributes: { iconName: 'utility:edit' }*/
    },

    ]; 

    @track columns1 = [{
        label: 'PO#',
        fieldName: 'PO__c',
        type: 'Text',
        sortable: true,
        cellAttributes: { alignment: 'right' }
    },{
        label: 'Order Line #',
        fieldName: 'Order_Line_Number__c',
        type: 'Text',
        sortable: true,
        cellAttributes: { alignment: 'left' }
    },
    {
        label: 'Catalog #',
        fieldName: 'SKU_Description_Cat_Logic__c',
        iconName: 'utility:products',
        type: 'Text',
        sortable: true,
        cellAttributes: { alignment: 'right' }
    },
    {
        label: 'SKU #',
        fieldName: 'SKU__c',
        type: 'Text',
        sortable: true,
        cellAttributes: { alignment: 'left' }
    },    
    {
        label: 'Qty',
        fieldName: 'Quantity',
        iconName: 'utility:number_input',
        type: 'Text',
        sortable: true,
        cellAttributes: { alignment: 'left' }
    },
    {
        label: 'UOM',
        fieldName: 'UnitOfMeasure__c',
        type: 'Text',
        sortable: true,
        cellAttributes: { alignment: 'right' }
    },
    {
        label: 'Price',
        fieldName: 'UnitPrice',
        iconName: 'utility:money',
        type: 'currency',
        sortable: true,
        cellAttributes: { alignment: 'left' }
    },
    /*{
        label: 'Distributor Name',
        fieldName: 'Distributor_Name__c',
        type: 'Text',
        sortable: true,
        cellAttributes: { alignment: 'center' }
    },*/
    {
        label: 'Category of Change',
        fieldName: 'Category_Of_Change__c',
        iconName: 'utility:button_choice',
        type: 'Text',
        sortable: true,
        cellAttributes: { alignment: 'right' }
    },
    {
        label: 'Requested New Ship Date',
        fieldName: 'New_Shipment_Date__c',
        iconName: 'utility:date_input',
        type: 'date-local',
        sortable: true,
        cellAttributes: { alignment: 'left'},
        typeAttributes: {
            day: "numeric",
            month: "numeric",
            year: "numeric"
        }
    },
    {
        label: 'Change Text/Comment',
        fieldName: 'Reason_for_Change__c',
        iconName: 'utility:textbox',
        type: 'Text',
        sortable: true,
        wrapText: true,
        cellAttributes: { alignment: 'right' }
    },
   
        /*type: 'action',
        typeAttributes: { rowActions: actions },
        cellAttributes: { iconName: 'utility:edit' }*/
    

    ]; 

     //--------END COLUMNS FOR ORDER LINE ITEM SELECTION SCREEN

     // COLUMNS FOR THE VIEW CART MODAL
     @track cartColumns = [  {
        label: 'PO#',
        fieldName: 'PO__c',
        type: 'Text',
        sortable: true,
        cellAttributes: { alignment: 'right' }
    },{
        label: 'Order Line #',
        fieldName: 'Order_Line_Number__c',
        type: 'Text',
        sortable: true,
        cellAttributes: { alignment: 'left' }
    },
    {
        label: 'Catalog #',
        fieldName: 'Product_SKU__c',
        iconName: 'utility:products',
        type: 'Text',
        sortable: true,
        cellAttributes: { alignment: 'right' }
    },
    {
        label: 'SKU #',
        fieldName: 'SKU__c',
        type: 'Text',
        sortable: true,
        cellAttributes: { alignment: 'left' }
    },     
    {
        label: 'Qty',
        fieldName: 'Quantity__c',
        iconName: 'utility:number_input',
        type: 'Text',
        sortable: true,
        cellAttributes: { alignment: 'left' }
    },
    {
        label: 'UOM',
        fieldName: 'UnitOfMeasure__c',
        type: 'Text',
        sortable: true,
        cellAttributes: { alignment: 'right' }
    },
    {
        label: 'Price',
        fieldName: 'UnitPrice__c',
        iconName: 'utility:money',
        type: 'currency',
        sortable: true,
        cellAttributes: { alignment: 'left' }
    },
    /*{
        label: 'Distributor Name',
        fieldName: 'Distributor_Name__c',
        type: 'Text',
        sortable: true,
        cellAttributes: { alignment: 'center' }
    },*/
    {
        label: 'Category of Change',
        fieldName: 'Category_Of_Change__c',
        iconName: 'utility:button_choice',
        type: 'Text',
        sortable: true,
        cellAttributes: { alignment: 'right'}
    },
    {
        label: 'Requested New Ship Date',
        fieldName: 'New_Shipment_Date__c',
        iconName: 'utility:date_input',
        type: 'date-local',
        sortable: true,
        cellAttributes: { alignment: 'left'},
        typeAttributes: {
            day: "numeric",
            month: "numeric",
            year: "numeric"
        }
    },
    {
        label: 'Change Text/Comment',
        fieldName: 'Reason_for_Change__c',
        iconName: 'utility:textbox',
        type: 'Text',
        sortable: true,
        wrapText: true,
        cellAttributes: { alignment: 'right'}
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

     // COLUMNS FOR THE REVIEW PAGE
     @track reviewColumns = [  {
        label: 'PO#',
        fieldName: 'PO__c',
        type: 'Text',
        sortable: true,
        cellAttributes: { alignment: 'right' }
    },{
        label: 'Order Line #',
        fieldName: 'Order_Line_Number__c',
        type: 'Text',
        sortable: true,
        cellAttributes: { alignment: 'left' }
    },
    {
        label: 'Catalog #',
        fieldName: 'Product_SKU__c',
        iconName: 'utility:products',
        type: 'Text',
        sortable: true,
        cellAttributes: { alignment: 'right' }
    },
    {
        label: 'SKU #',
        fieldName: 'SKU__c',
        type: 'Text',
        sortable: true,
        cellAttributes: { alignment: 'left' }
    },     
    {
        label: 'Qty',
        fieldName: 'Quantity__c',
        iconName: 'utility:number_input',
        type: 'Text',
        sortable: true,
        cellAttributes: { alignment: 'left' }
    },
    {
        label: 'UOM',
        fieldName: 'UnitOfMeasure__c',
        type: 'Text',
        sortable: true,
        cellAttributes: { alignment: 'right' }
    },
    {
        label: 'Price',
        fieldName: 'UnitPrice__c',
        iconName: 'utility:money',
        type: 'currency',
        sortable: true,
        cellAttributes: { alignment: 'left' }
    },
    /*{
        label: 'Distributor Name',
        fieldName: 'Distributor_Name__c',
        type: 'Text',
        sortable: true,
        cellAttributes: { alignment: 'center' }
    },*/
    {
        label: 'Category of Change',
        fieldName: 'Category_Of_Change__c',
        iconName: 'utility:button_choice',
        type: 'Text',
        sortable: true,
        cellAttributes: { alignment: 'right'}
    },
    {
        label: 'Requested New Ship Date',
        fieldName: 'New_Shipment_Date__c',
        iconName: 'utility:date_input',
        type: 'date-local',
        sortable: true,
        cellAttributes: { alignment: 'left'},
        typeAttributes: {
            day: "numeric",
            month: "numeric",
            year: "numeric"
        }
    },
    {
        label: 'Change Text/Comment',
        fieldName: 'Reason_for_Change__c',
        iconName: 'utility:textbox',
        type: 'Text',
        sortable: true,
        wrapText: true,
        cellAttributes: { alignment: 'right'}
    },
 
    ]; 

    @api soldToAccount=[];
    @api soldToName;
    @api caseProductInsert = [];
    @api reqEmail;
    @api reqPhone;
    @api reqBoxValue;
    @api cartCount = 0;
    @api transactionID;
    @api storedLines;
    @api getorder;
    @api selectedOrder;
    @api valuetopass;
    @api contactID;
    @api accountID;
    @api newShipDate;
    @api reasonForChange;
    @track showOrderSelection = false;
    @track isSpinner = false;
    @track isLoading = false;
    @track currentStep; // SETS THE CURRENT STEP

    //TO GET THE ORDER NO.
    //@api orderNumber;
    @api orderId;
    @api defOrderNew;  
    @api orderLines = [];
    @api orderingAgency=[];


    @track agencyName='Agency Name';
    @track reqName;
    @track orderItemList;
    @track isOrderIdAvailable;
    @track bShowModal = false;
    @track bShowModal1 = false;
    @track currentRecordId;
    @track currentRecordDtl;
    @track isEditForm = false;
    @track cartLabel; 
    @track flagIndi = false;
    @track orderItemNewList;
    @track rowQuantity;
    @track rowAvailForReturn;
    @track rowReturnTotal;
    @track errorMessage;
    @track catChange;
    @track catChangeEdit;
    @track accName;
    @track reqName;
    @track reqEmail;
    @track reqPhone;
    @track caseNumberNew;
    @track valCheck=false;
    @track dateCheck=false;
    @track commentBox=false;
    @track columns;
    @track catchn = 0;
    @track editShipDate=false;
    @track editReasonChange=false;
    @track orderNumber;
    @track toggleSubmitLabel = "Submit";
    @track paramString=[];
    @track isEditForm = false;
    @track filesToInsert = []; 
    @track lstAllFiles = []; // ARRAY OF FILES TO BE INSERTED INTO THE DATABASE 
    @track distributorID;
    @track showDistroField = false;  
    @track agentNumber='DEFAULT';  
    @track disAccount='DEFAULT';
    @track disName=[];
    @track orderValue;
    @track showNextButton= true;
    @track orderPO;
    value = [];
    @track caseSoldTo;
    @track selectorAccount;
    @track caseType = "Change";
    @track selectedAccountID;
    @track selectedAccountName;
    @track userType;
    @track isAdding = false;
    @track preSelectedOrder;
    @track ordLinesToUpdate = [];   
    @track orderAgent;
    @track setAccountID;
    @track caseOwnerId;
    @track caseContactEmail;


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
               
            }
            this.caseContactEmail = data.fields.Email.value;
            this.contactID = data.fields.ContactId.value;
            this.soldToAccount = data.fields.AccountId.value;
            this.showDistroField = false; 
            this.convertPhone(this.reqPhone);
            console.log("Contact Id Check" + this.contactID);

    

           /* getAgentId({AccountId: this.soldToAccount})
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
           // var inputacc=this.soldToAccount;
            //this.template.querySelector("c-account-search-custom").setConfirmValues(inputacc);
            this.setAccountfromSelector();
            
            /*if(this.paramString.length>0){
            console.log("Param String Check" +this.paramString);

            var inputord=this.paramString;
            //this.template.querySelector("c-order-search-custom").setConfirmValues(inputord);
            }*/
              
            
        }
    }
        //--------------------------------------------------

        setAccountfromSelector(){
            let storedUserType = localStorage.getItem('User Type');
            console.log('STORED USER TYPE: '+storedUserType);
            //this.template.querySelector("c-order-search-l-w-c").setVisibility(storedUserType);
            this.userType = storedUserType;
            if(storedUserType == "Agent"){
                this.preSelectedAccount = localStorage.getItem('AgentName') + ' - ' + localStorage.getItem('AgentNumber') + ' - ' + localStorage.getItem('AgentSegment');
                this.selectorAccount = localStorage.getItem('AgentNumber');
                this.selectedAccountID =  localStorage.getItem('AgentID');
                this.selectedAccountName = localStorage.getItem('AgentName');
                console.log('Setting Account Lookup LWC - Preselected: '+this.selectorAccount);
                console.log('Setting Account Lookup LWC - Preselected ID: '+this.selectedAccountID);
                
                this.showDistroField = true; 
                let retrieveData = localStorage.getItem('AgentID');
                let agentNum = localStorage.getItem('AgentNumber');
                //this.template.querySelector("c-order-search-l-w-c").setVisibility(storedUserType);
                

                let distributorData = localStorage.getItem('DistributorID');
                if (distributorData != null){
                    this.preSelectedSoldTo = localStorage.getItem('DistributorName') + ' - ' + localStorage.getItem('DistributorAccount') + ' - ' + localStorage.getItem('DistributorSegment');
                    this.distributorNumber = localStorage.getItem('DistributorAccount');
                    this.selectedDistributorID = localStorage.getItem('DistributorID');
                    this.selectedSoldToAccountName = localStorage.getItem('DistributorName');
                    this.caseSoldTo = localStorage.getItem('DistributorID');
                    console.log('PRE SELECTED SOLD TO: '+this.preSelectedSoldTo);
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
                //let disAccountName = sessionStorage.getItem('DistributorName');
                //let disAccountSegment = sessionStorage.getItem('DistributorSegment');
                //let disID = sessionStorage.getItem('DistributorID');
                if(retrieveData != null){
                    console.log('Setting Account From Selector: '+JSON.stringify(retrieveData));
                    this.soldToAccount = retrieveData;
                    var inputacc = retrieveData;
                    /*console.log('Sending Account ID to Account Search: '+inputacc);
                    this.template.querySelector("c-account-search-custom").setConfirmValues(inputacc);
                    console.log('Setting Account Number from Local Storage: '+inputacc);*/
                }
            }
        }

        appendLines(event){
        
            this.ordLinesToUpdate = event.detail.lineId;
            console.log('Order Lines to Modiify: '+JSON.stringify(this.ordLinesToUpdate));
        }

        connectedCallback(){
            window.addEventListener("beforeunload", this.beforeUnloadHandler.bind(this));
            this.setTimer();
            var today = new Date();
            var date = today.getFullYear()+'-'+(today.getMonth()+1)+'-'+today.getDate();
            var time = today.getHours() + ":" + today.getMinutes() + ":" + today.getSeconds();
            const id = 'id' + performance.now()+'-'+date+'-'+time;
            this.transactionID = id;
            console.log('Generated ID: '+ id);

            console.log('Setting the Transcation ID: '+this.transactionID);
          

            //Code change for order id default
            this.sfdcOrgURL = window.location.href;
            if(this.sfdcOrgURL.includes('id=')==true){
                this.paramString = this.sfdcOrgURL.split('id=')[1];
                if(this.paramString.length > 0){
                    this.value='By Entire Order';
                    this.valCheck=true;
                    this.columns=this.columns1;
                    this.showNextButton = false;
                    this.orderID = this.paramString;
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
    this.delayTimer = 900000; //15 MINUTES
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
                this.template.querySelector("c-order-search-l-w-c").clearSessionCart();

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


        get acceptedFormats() {
            return ['.pdf','.png','.jpg','.jpeg','.doc','.docx', '.xls','.xlsx','.ppt','.pptx','.odt', '.rtf'];
        }

        get message() {
            return ['Formats: '+'pdf','png','jpg','jpeg','doc','docx', 'xls','xlsx','ppt','pptx','odt', 'rtf' + ' Max File Size: 10 MB'];
        }
        

      //Code for CheckBox
    
      get options() {
        return [
            { label: 'By Entire Order', value: 'By Entire Order' }, 
            { label: 'By Line Item', value: 'By Line Item' },
        ];
    }

    get RAoptions() {
        return [
            { label: 'Extend Shipping Date', value: 'Extend Shipping Date' }, 
            { label: 'Other', value: 'Other' },
        ];
    }

    get selectedValues() {
        return this.value.join(',');
    }

    // HANDLE ACCOUNT SELECTED FROM ACCOUNT LOOKUP LWC
handleAccountSelected(event){
       
    this.selectorAccount = event.detail.selectedAccount;
    if(this.userType == "Agent"){
        this.selectedAccountID = event.detail.selectedAccountId;
    } else {
        this.selectedDistributorID = event.detail.selectedAccountId;
    }
    this.selectedAccountName = event.detail.selectedAccountName;
    console.log('Account Selected from AccountLookupLWC: '+this.selectorAccount);
}
//-----------------------------------------------------

// HANDLE SOLD TO ACCOUNT SELECTED IN THE SOLD TO LOOKUP LWC
setCaseSoldTo(event){
    this.selectedDistributorID = event.detail.soldto;
    this.selectedSoldToAccountName = event.detail.soldToName;
    this.searchDisabled = false;
    console.log('Account Selected from OrderSearchLWC: '+this.selectedDistributorID);
    console.log('Account Name Selected from OrderSearchLWC: '+this.selectedSoldToAccountName);
}
//--------------------------------------------------------

// HANDLES CLEAR FOR SOLD TO ACCOUNT SELECTION (LWC)
changeAccount(){
    
    this.preSelectedAccount = null;
    this.selectedDistributorID = null;
    this.searchKey = '';
   
}
//------------------------------------------------------

// HANDLES THE SELECTED ORDER FROM THE testOrderLookupLWC CHILD COMPONENT
orderSelected(event){
    this.orderNumber = event.detail.orderNum;
    this.orderPO = event.detail.orderPO;
    this.orderAgent = event.detail.orderAgent;
    console.log('Change Request Order Number: '+this.orderNumber);
    console.log('Change Request PO: '+this.orderPO);
    console.log('AGENT ACCOUNT FOR QUEUE ASSIGNMENT: '+this.orderAgent);
               
}

 // DATA PASSED FROM c/lightningWebCompDataTableOrderItem CHILD COMPONENT AND SETS THIS.STOREDLINES ARRAY
 confirmUpdate(event){
    this.storedLines = event.detail.lines;
    if(this.storedLines.length > 0){
        this.showNextButton = false;
    } else {
        //this.showNextButton = true;
        console.log('CONFIRM UPDATE TRUE...');
    }
    console.log('The lines passed to Parent: '+JSON.stringify(this.storedLines));
}

updateCartCount(event){
    this.cartCount = event.detail.totalItems;

    if(this.cartCount > 0 && this.value === 'By Line Item'){
        this.showNextButton = false;
    } else if(this.cartCout == 0 && this.value === 'By Line Item'){
        this.showNextButton = true;
    }
}

    /*confirmchange(event){
        this.orderLines = event.detail.selectedRecordId;
        this.orderingAgency=event.detail.selectedValue;
        console.log('The lines passed to child for Ordering: '+this.orderLines);
        this.disAccount = this.orderLines;
        if(this.orderingAgency==null){
            this.disName=[];
        }
        else{
        this.disName = this.orderingAgency;
        }
        console.log('The lines passed to child for Delivery: '+this.disAccount);
        console.log('The lines passed to child for Delivery: '+this.disName);
    
    }*/

   
    

    handleCheckChange(e) {
        this.value = e.detail.value;
        const storeVal = this.value;
        this.showOrderSelection = true;
        console.log('Value from the Checkbox: '+ storeVal);

        if (storeVal=='By Entire Order'){
            console.log('Inside If');
            this.valCheck=true;
            this.columns=this.columns1;
            this.showNextButton = false;
            console.log('Inside If'+this.columns);

        } else{
            if(this.cartCount == 0){
                this.showNextButton = true;
            }
            console.log('Inside else');
            this.valCheck=false;
            this.dateCheck=false;
            this.commentBox=false
            this.catChange=[];
            this.storedLines=[];
            this.columns=this.columns2;
            console.log('Inside else'+ this.catChange);
        }
    }

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
    

    //--- Check Box code ends here----//

    async handleChangeAcc(event){
        this.soldToAccount = event.target.selectedRecordId;
        this.showDistroField=false;
       // this.soldToName = event.target.dataset.name;
        console.log('Sold To Account ID: '+ this.soldToAccount);
       // console.log('Sold To Account Name: '+ this.soldToName);
     
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

    async handleChangeCat(event){
        this.catChange = event.target.value;
        this.catchn = this.catChange.length;
        console.log('Category of Change Value '+ this.catChange);
        if (this.catChange=='Extend Shipping Date'){
            this.dateCheck=true;
            this.commentBox=false;
           // this.reasonForChange=Null;
        }
        else if (this.catChange=='Other'){
            this.dateCheck=false;
            this.commentBox=true;
          //  this.newShipDate=Null;
        }

    }
    
    async handleComments(event){
        this.reasonForChange = event.target.value;
    }  

    async clearLoading(event){
        this.isAdding = event.detail.isadding;

        if (this.isAdding == false){
            this.goToStepThree();
        }

    }




    handleChangeEdit(event){
        console.log('editReasonChange '+ this.editReasonChange);
        this.catChangeEdit = event.target.value;
        console.log('Category of Change Value '+ this.catChangeEdit);
       
        if (this.catChangeEdit=='Extend Shipping Date'){
            this.editShipDate=true;
            this.editReasonChange=false;
            
        }
        else if(this.catChangeEdit=='Increase Quantity'||this.catChangeEdit=='Decrease Quantity'||this.catChangeEdit=='Request Price Change'||this.catChangeEdit=='Other'){
            this.editReasonChange=true;
            this.editShipDate=false;
        }

    }



    async handleChange(event) {
        //console.log("Type of" +typeof(selectedOrder));
        console.log('Check the length: '+ this.value.length);
        if(this.value.length == 0){
         this.dispatchEvent(
             new ShowToastEvent({
                 title: 'ERROR',
                 message: 'Please select the Request to Change field and search the Order again',
                 variant: 'error'
             })
         );
 
        }
        else{
            
   //console.log("You selected an order: " + event.detail.value[0]);
        this.selectedOrder = event.detail.selectedRecordId;
        if(this.value==='By Entire Order' && this.selectedOrder.length>0){
            this.showNextButton = false;
        }
        else{
            //this.showNextButton = true;
            console.log('HANDLE CHANGE TRUE...');

        }
        console.log('The lines passed to child for Delivery: '+this.selectedOrder);
        console.log('Value for Distributor Name: '+this.disName);
        if(this.disName.length >0){
        await updDisName({orderId: this.selectedOrder, disName: this.disName})
        .then(result => {
            console.log(JSON.stringify("The Result from APEX is: "+ JSON.stringify(result)));
        });
        }
        await getOrderItemList({orderId: this.selectedOrder})
        .then(result => {
            console.log(JSON.stringify("The Result from APEX is: "+ JSON.stringify(result)));
            this.orderItemList  = result;
            this.orderPO = result[0].Order.Customer_PO_Number__c;
            console.log(JSON.stringify("The Result from APEX is: "+ JSON.stringify(this.orderItemList)));
            this.isOrderIdAvailable = true;
                   
    
        }).catch(error => {
            console.log("The error SENT TO APEX is: " +JSON.stringify(error));
            this.error = error;
           
        });
        var newData = this.orderItemList;
        console.log("The error SENT TO APEX is: " +JSON.stringify(newData));
        for (var i =0; i< newData.length ;i++) {
            this.orderNumber= newData[i].Order.GE_Order_NO__c;
            console.log("Order Number" + this.orderNumber);
        }
    }
    }

    handleChangeNew(event) {
       
        this.selectedOrder = this.paramString;
        getOrderDetails({orderId: this.selectedOrder})
        .then(result => {
            
                this.orderNumber= result[0].GE_Order_NO__c;
                this.orderID = result[0].Id;
                this.orderPO = result[0].Customer_PO_Number__c;
                this.caseSoldTo = result[0].Sold_To__c;
                this.selectedSoldToAccountName = result[0].Sold_To__r.Name;
                this.preSelectedSoldTo = result[0].Sold_To__r.Name + ' - ' + result[0].Sold_To__r.GE_LGT_EM_SAP_Customer_Number__c + ' - ' + result[0].Sold_To__r.Customer_Segmentation__c;
                this.preSelectedOrder = result[0].GE_Order_NO__c + ' - ' + result[0].Customer_PO_Number__c;
                console.log("Order Number: " + this.orderNumber);
                console.log("Order Sold To: " + this.caseSoldTo);
                console.log("Order PO: " + this.orderPO);
                console.log("PreSelected Sold To: " + this.preSelectedSoldTo);
                console.log('ORDER AGENT ACCOUNT ID: '+result[0].Agent_Account__c);
                if(result[0].Agent_Account__c != null){
                    this.orderAgent = result[0].Agent_Account__c;
                } else {
                    this.orderAgent = null;
                }
            
            console.log('Order Number Returned: '+this.orderNumber);
            this.showOrderSelection = true;
            console.log(JSON.stringify("The Result from APEX is: "+ JSON.stringify(result)));
            this.orderItemList  = result;
            console.log(JSON.stringify("The Result from APEX is: "+ JSON.stringify(this.orderItemList)));
            this.isOrderIdAvailable = true;
                   
    
        }).catch(error => {
            console.log("The error SENT TO APEX is: " +error);
            this.error = error;
           
        });
        /*var newData = this.orderItemList;
        console.log("The error SENT TO APEX is: " +JSON.stringify(newData));
        for (var i =0; i< newData.length ;i++) {
            this.orderNumber= newData[i].Order.GE_Order_NO__c;
            console.log("Order Number" + this.orderNumber);
        }*/
    
    }
    
    handleRowActions(event) {
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
   
    this.bShowModal1 = true;
    this.isEditForm = true;
    this.editReasonChange=false;
    this.editShipDate=false;
    console.log('Inside Edit: '+ this.bShowModal1);
    console.log('Inside Edit: '+ this.isEditForm );

    // assign record id to the record edit form
    this.currentRecordId = currentRow.Id;
    this.checkForEditRow = currentRow.Category_Of_Change__c;
    if (this.checkForEditRow=='Extend Shipping Date'){
        this.editShipDate=true;
        this.editReasonChange=false;
    }
    else if(this.checkForEditRow=='Increase Quantity'||this.checkForEditRow=='Decrease Quantity'||this.checkForEditRow=='Request Price Change'||this.checkForEditRow=='Other'){
        this.editReasonChange=true;
        this.editShipDate=false;
    }
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
    const fields = event.detail.fields;
    fields.Distributor_Name__c = this.disAccount;
    this.template.querySelector('lightning-record-edit-form').submit(fields);
    const newfield = event.detail.fields;
    console.log('New Field Check : ' + JSON.stringify(newfield));

    // querying the record edit form and submiting fields to form
    console.log('Inbuilt Form Data Check: ' + JSON.stringify(event.detail.fields));
    //this.template.querySelector('lightning-record-edit-form').submit(event.detail.fields);
    const recordInputs = event.detail.fields.slice().map(newfield=>{
        const fields = Object.assign({}, newfield)
        return {fields}
    })
    console.log("recordInputs", recordInputs)

    const promises = recordInputs.map(recordInput => updateRecord(recordInput))
    Promise.all(promises).then(result=>{
        this.ShowToastMsg('Success', 'Order Details Updated')
      // this.draftValues=[];   
      // console.log('Before Refresh: '+ JSON.stringify(this.orderItemList));
      // console.log('Check for Refresh: '+ this.selectedOrder);

    // showing success message
}).catch(error=>{
    this.ShowToastMsg('Error Updating Records', error.body.message, error)
});
    }

 
 

// refreshing the datatable after record edit form success
async handleSuccess() {
   await getChangeReqRefList({orderId: this.selectedOrder}) 
           .then(result => {
               this.orderItemList = result;
               console.log(result);
               console.log('After refresh datatable data: ' + JSON.stringify(this.orderItemList));
               this.ShowToastMsg('Success', 'Order Details Updated')
                // closing modal
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

        //const updatedFields = event.detail.draftValues;

        await orderListData({transId: this.currentRecordId}) 
           .then(result => {
               this.orderItemNewList = result;
               console.log(result);
               console.log('Value passed from Apex for currentrow: ' + JSON.stringify(this.orderItemNewList));
           });
       //var selRows = this.template.querySelector('lightning-datatable');
        var selected = this.orderItemNewList;
        console.log('Edit Row: '+ JSON.stringify(selected));
        //console.log('Values for EDIT: '+this.draftValues);
        //this.storedLines = selected;
        console.log('Stored Lines: '+ JSON.stringify(this.storedLines));
        var newselval = selected.map(row => { return { "SKU__c": row.SKU__c, "PO__c": row.PO__c, "Quantity__c": row.Quantity, "UnitPrice__c": row.UnitPrice,
            "Order_Line_Number__c":row.Order_Line_Number__c,"Category_Of_Change__c":row.Category_Of_Change__c,"New_Shipment_Date__c":row.New_Shipment_Date__c,"Reason_for_Change__c":row.Reason_for_Change__c, "Type__c": "Change Request", "Product_SKU__c": row.SKU_Description_Cat_Logic__c,
            "Order_Product_Id__c":row.Id, "Transaction_ID__c": this.transactionID, "Unique_ID__c": this.transactionID+'_'+row.SKU__c, "Distributor_Name__c": row.Distributor_Name__c, "Distributor_Id__c":this.orderLines, "UnitOfMeasure__c": row.UnitOfMeasure__c}});

        
        
        this.valuetopass = selected;
        console.log('value to pass check:' + JSON.stringify(this.valuetopass));
        
        console.log('value to pass check:' + JSON.stringify(newselval));
        await updateReturnItemList({data: newselval})
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
        getChangeReqCartItem({transId : this.transactionID})
            .then(result =>{
                this.storedLines = result;
                this.cartCount = this.storedLines.length;
                if((this.value==='By Line Item' && this.cartCount >0) || (this.value==='By Entire Order' && this.cartCount >0) ){
                    this.showNextButton = false;
                }
                else{
                    //this.showNextButton = true;
                    console.log('FETCH-RETURNS TRUE...');
        
                }
                
            this.dispatchEvent(
                new CustomEvent('lineupdate', {
                    detail: {
                        lines : this.storedLines
                    }
                }));
            this.dispatchEvent(
                new CustomEvent('cartcount', {
                    detail: {
                        totalItems : this.cartCount
                    }
                }));
        });
     }


    showWarranty(event){
        this.warrantyEntry = true;
        this.isOrderIdAvailable = false;
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

    goBackToStepTwo() {
        
        this.currentStep = '2';

        this.template.querySelector('div.stepThree').classList.add('slds-hide');
        this.template
            .querySelector('div.stepTwo')
            .classList.remove('slds-hide');
    }

   async handleValidation() {

    let acctName = this.selectorAccount;
    let reqsName = this.template.querySelector(".rn").value;
    let reqsPhone = this.template.querySelector(".rp").value;
    let reqsEmail = this.template.querySelector('.em').value;
    //let reqsBox = this.template.querySelector(".cb").value;
    //let reqChange = this.catchn;
    
    
    console.log('Phone value'+ reqsPhone);
    //console.log('CheckBox value'+ reqsBox);
    //console.log('Length value'+ reqChange);
    if(!acctName || !reqsName || !reqsPhone || !reqsEmail){

        this.dispatchEvent(
            new ShowToastEvent({
                title: 'ERROR',
                message: 'Please fill out all Required Fields',
                variant: 'error'
            })
        );

    } 
    /*
    else if(reqChange==0 && reqsBox=='By Entire Order') {

        this.dispatchEvent(
            new ShowToastEvent({
                title: 'ERROR',
                message: 'Please fill out all Required Fields',
                variant: 'error'
            })
        );

    }
    else if (reqChange>1 && reqsBox=='By Entire Order' && this.catChange=='Extend Shipping Date'){
        let reqNewChangeDate = this.template.querySelector(".on").value;
       
        if(!reqNewChangeDate){
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'ERROR',
                message: 'Please fill out all Required Fields',
                variant: 'error'
            })
        );
        }
        else{
            this.goToStepTwo();
        }
    }
    else if (reqChange>1 && reqsBox=='By Entire Order' && this.catChange=='Other'){
        let comBx = this.template.querySelector(".pn").value;
       
        if(!comBx){
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'ERROR',
                message: 'Please fill out all Required Fields',
                variant: 'error'
            })
        );
        }*/
        
    
}

    
goToStepTwo() {
    
   console.log('Checking Step 1 Inputs....');
    let acctName = this.selectorAccount;
    let reqsName = this.template.querySelector(".rn").value;
    let reqsPhone = this.template.querySelector(".rp").value;
    let reqsEmail = this.template.querySelector('.em').value;
    //let reqsBox = this.template.querySelector(".cb").value;
    //let reqChange = this.catchn;
    
    
    console.log('Phone value'+ reqsPhone);
    //console.log('CheckBox value'+ reqsBox);
    //console.log('Length value'+ reqChange);
    if(!acctName || !reqsName || !reqsPhone || !reqsEmail){
        this.currentStep = '1';
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'ERROR',
                message: 'Please fill out all Required Fields',
                variant: 'error'
            })
        );

    } else {

        this.currentStep = '2';
        console.log('CURRENT STEP: '+this.currentStep);
            
            this.template.querySelector('div.stepOne').classList.add('slds-hide');
            this.template
                .querySelector('div.stepTwo')
                .classList.remove('slds-hide');
            
        }
}

    goToStepFour(){

        this.currentStep = '4';
        
        this.template.querySelector('div.stepThree').classList.add('slds-hide');
        this.template
            .querySelector('div.stepFour')
            .classList.remove('slds-hide');

            updateOrdLines({lines : this.ordLinesToUpdate})
            .then(result => {
               console.log('ORDER LINES RESET....'+result);
            });

    }

    handleStepThreeValidation(){
            console.log('VALIDATING INPUTS....');
            var tempValue = this.template.querySelector(".cb").value;
            console.log('CheckBox value: '+tempValue);

            
            
           
            
            if(tempValue != "By Line Item"){
                console.log('BY ENTIRE ORDER VALIDATION...');
                this.catChange = this.template.querySelector('.mn').value;
                if(!this.catChange){
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'ERROR',
                            message: 'Please fill out all Required Fields',
                            variant: 'error'
                        })
                    );
                } else {

                    if(this.catChange == 'Extend Shipping Date'){
                        this.newShipDate = this.template.querySelector('.on').value;
                        if(!this.newShipDate){

                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'ERROR',
                                    message: 'Please fill out all Required Fields',
                                    variant: 'error'
                                })
                            );
                        }
                        else {
                            this.isAdding = true;

                            var inputData={
                                category:this.catChange,
                                comments:this.reasonForChange,
                                newShipDate:this.newShipDate,
                                orderChoice:this.value
                            };
                            this.template.querySelector("c-order-search-l-w-c").setConfirmValues(inputData);
                        }
                    } else if(this.catChange == 'Other'){
                        this.reasonForChange = this.template.querySelector('.pn').value;
                        if(!this.reasonForChange){

                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'ERROR',
                                    message: 'Please fill out all Required Fields',
                                    variant: 'error'
                                })
                            );
                        } else {
                            

                            this.isAdding = true;

                            var inputData={
                                category:this.catChange,
                                comments:this.reasonForChange,
                                newShipDate:this.newShipDate,
                                orderChoice:this.value
                            };
                            this.template.querySelector("c-order-search-l-w-c").setConfirmValues(inputData);
                        }
                    } else {
                        this.isAdding = true;

                            var inputData={
                                category:this.catChange,
                                comments:this.reasonForChange,
                                newShipDate:this.newShipDate,
                                orderChoice:this.value
                            };
                            this.template.querySelector("c-order-search-l-w-c").setConfirmValues(inputData);
                    }
                }
           } else {
               console.log('BY LINE ITEM...GOING TO STEP 3');
                this.goToStepThree();
            }  

    }

    goToStepThree(){
        
        //console.log(JSON.stringify("The step is: " + JSON.stringify(currentStep)));
        this.currentStep = '3';
        this.reqName = this.template.querySelector(".rn").value;
        console.log('Requestor Name '+this.reqName);
        this.reqEmail = this.template.querySelector(".em").value;
        console.log('Requestor Email '+this.reqEmail);
        this.reqPhone = this.template.querySelector(".rp").value;
        console.log('Requestor Phone'+this.reqPhone);
        this.reqBoxValue = this.template.querySelector(".cb").value;
        console.log('CheckBox value'+this.reqBoxValue);

        this.template.querySelector('div.stepTwo').classList.add('slds-hide');
        this.template
        .querySelector('div.stepThree')
        .classList.remove('slds-hide');
        
       
        this.getCaseOwner();
       
       
        /*if(this.cartCount == 0 && this.value === 'By Entire Order'){
                this.template.querySelectorAll('lightning-input-field').forEach(element => {
                    element.reportValidity();
                });    
                console.log(JSON.stringify("Move to the next screen Data check: "+ JSON.stringify(this.storedLines)));
                this.reqName = this.template.querySelector(".rn").value;
                console.log('Requestor Name '+this.reqName);
                this.reqEmail = this.template.querySelector(".em").value;
                console.log('Requestor Email '+this.reqEmail);
                this.reqPhone = this.template.querySelector(".rp").value;
                console.log('Requestor Phone'+this.reqPhone);
                this.reqBoxValue = this.template.querySelector(".cb").value;
                console.log('CheckBox value'+this.reqBoxValue);

                this.isAdding = true;

                var inputData={
                    category:this.catChange,
                    comments:this.reasonForChange,
                    newShipDate:this.newShipDate,
                    orderChoice:this.value
                };
                this.template.querySelector("c-order-search-l-w-c").setConfirmValues(inputData);
            } else {

                this.reqName = this.template.querySelector(".rn").value;
                console.log('Requestor Name '+this.reqName);
                this.reqEmail = this.template.querySelector(".em").value;
                console.log('Requestor Email '+this.reqEmail);
                this.reqPhone = this.template.querySelector(".rp").value;
                console.log('Requestor Phone'+this.reqPhone);
                this.reqBoxValue = this.template.querySelector(".cb").value;
                console.log('CheckBox value'+this.reqBoxValue);

                this.template.querySelector('div.stepTwo').classList.add('slds-hide');
                this.template
                .querySelector('div.stepThree')
                .classList.remove('slds-hide');

            }*/
        
                
            //this.accName = this.template.querySelector(".sta").value;
            //console.log('Account Name '+this.accName);
            //this.catChange = this.template.querySelector(".mn").value;
            //console.log('Category of Change '+this.catChange);
           
           /* await getAccName({id_dtl: this.soldToAccount})
            .then(result => {
            this.accName = result;
            console.log(JSON.stringify("Account Name Selected "+ JSON.stringify(this.accName)))
            });*/ 
            
    
    
    
          /*  console.log('Cat check before If'+this.catChange);
            if(this.reqBoxValue=='By Entire Order' && this.catChange=='Extend Shipping Date'){
               // this.catChange = this.template.querySelector(".mn").value;
               // if(this.catChange.length>0){
                this.newShipDate = this.template.querySelector(".on").value;
                console.log('CheckBox value'+this.newShipDate);
                
                console.log('Data check for selectedorder inside '+ JSON.stringify(this.orderItemList));
                var selectedNew = this.orderItemList;
               console.log('Data check for entire order check: '+ JSON.stringify(selectedNew));
                var newselvals = selectedNew.map(row => { return { "SKU__c": row.SKU__c, "PO__c": row.PO__c, "Quantity__c": row.Quantity, "UnitPrice__c": row.UnitPrice,
                    "Order_Line_Number__c":row.Order_Line_Number__c,"Category_Of_Change__c":this.catChange,"New_Shipment_Date__c":this.newShipDate, "Type__c": "Change Request", "Product_SKU__c": row.SKU_Description_Cat_Logic__c,
                    "Order_Product_Id__c":row.Id, "Transaction_ID__c": this.transactionID+'_'+this.catChange, "Unique_ID__c": this.transactionID+'_'+row.SKU__c+'_'+this.catChange,"Distributor_Name__c":row.Distributor_Name__c,"Distributor_Id__c":this.orderLines}});
    
                
                console.log('value to pass check:' + JSON.stringify(newselvals));
              await  updateReturnItemList({data: newselvals})
                .then(result => {
                    //this.storedLines = result;
                    console.log(JSON.stringify("Apex update result: "+ result));
            });
    
               await getChangeReqCartItem({transId : this.transactionID+'_'+this.catChange})
                    .then(result =>{
                        this.storedLines = result;
                });
           // }
    
            }
            else if(this.reqBoxValue=='By Entire Order' && this.catChange=='Other') {
                this.reasonForChange = this.template.querySelector(".pn").value;
                console.log('CheckBox value'+this.reqBoxValue);
    
                console.log('Data check for selectedorder inside '+ JSON.stringify(this.orderItemList));
                var selectedNew = this.orderItemList;
               console.log('Data check for entire order check: '+ JSON.stringify(selectedNew));
                var newselvals = selectedNew.map(row => { return { "SKU__c": row.SKU__c, "PO__c": row.PO__c, "Quantity__c": row.Quantity, "UnitPrice__c": row.UnitPrice,
                    "Order_Line_Number__c":row.Order_Line_Number__c,"Category_Of_Change__c":this.catChange,"Reason_for_Change__c":this.reasonForChange, "Product_SKU__c": row.SKU_Description_Cat_Logic__c,
                    "Order_Product_Id__c":row.Id, "Transaction_ID__c": this.transactionID+'_'+this.catChange, "Unique_ID__c": this.transactionID+'_'+row.SKU__c+'_'+this.catChange,"Distributor_Name__c":row.Distributor_Name__c,"Distributor_Id__c":this.orderLines }});
    
                
                console.log('value to pass check:' + JSON.stringify(newselvals));
              await  updateReturnItemList({data: newselvals})
                .then(result => {
                    //this.storedLines = result;
                    console.log(JSON.stringify("Apex update result: "+ result));
            });
    
               await getChangeReqCartItem({transId : this.transactionID+'_'+this.catChange})
                    .then(result =>{
                        this.storedLines = result;
                });
    
            }*/
    }


    async getCaseOwner(){
        console.log('PASSING USER TYPE: '+this.userType);
        
        if(this.userType == "Agent"){
            this.setAccountID = this.soldToAccount;
            console.log('PASSING ACCOUNT ID: '+this.setAccountID);
            await getCSOwnerId({accountId : this.setAccountID, userType : this.userType})
            .then(result=>{
                    if(result){
                        this.caseOwnerId = result;
                        console.log('SETTING CASE QUEUE BASED ON AGENT....'+this.caseOwnerId);
                    } 
                })
        } else {
            if(this.orderAgent != null){
                this.setAccountID = this.orderAgent;
                console.log('PASSING ACCOUNT ID: '+this.setAccountID);
                await getCSOwnerId({accountId : this.setAccountID, userType : this.userType})
                .then(result=>{
                        if(result){
                            this.caseOwnerId = result;
                            console.log('SETTING CASE QUEUE BASED ON ORDER AGENT....'+this.caseOwnerId);
                        } 
                    })
            } else {
                
                await getCSOwnerId({accountId : null, distributorId : this.selectedAccountID, userType : this.userType})
                .then(result=>{
                        if(result){
                            this.caseOwnerId = result;
                            console.log('SETTING CASE QUEUE BASED ON ORDER AGENT....'+this.caseOwnerId);
                        } 
                    })
            }
        }
    }


    //Case Submission Code starts here

    //USED FOR TAKING THE INPUT FROM USER
    async handleSave(event){
        //console.log(JSON.stringify("The Result is: "));
       
        
       /*await getCSOwnerId({AccountId: this.soldToAccount})
       .then(result => {
       this.newOwnerId = result;
       console.log(JSON.stringify("New Account ID: "+ JSON.stringify(this.newOwnerId)))
       })*/

        this.toggleSubmitLabel = "Submitting...";
        this.isSpinner = true;
        let nCase = { 'sobjectType': 'Case' };
        nCase.RecordTypeId = '0123j000000X8ys';
        nCase.OwnerId = this.caseOwnerId;
        nCase.ContactId = this.contactID;
        nCase.Origin = 'Connect';
        nCase.eLight_Form_Type__c = 'Change Request';
        nCase.Connect_ID__c = this.transactionID;
        nCase.AccountId = this.soldToAccount;

        if(this.userType == "Agent"){
            nCase.Sold_To_Account__c = this.selectedDistributorID;
            console.log('Setting Case Sold To: '+this.selectedDistributorID);
        }
        /*if(this.caseSoldTo == null && this.disAccount != null){
        
            nCase.Sold_To_Account__c = this.disAccount;
        } else if(this.caseSoldTo != null && this.disAccount == "DEFAULT"){
            nCase.Sold_To_Account__c = this.caseSoldTo;
        }*/
        
        console.log('Setting Case Sold To: '+this.caseSoldTo);
        nCase.Requestor_Email__c = this.reqEmail;
        nCase.eLight_Requestor_Name__c = this.reqName;
        nCase.GE_NAS_Purchase_Order__c = this.orderPO;
        nCase.eLight_Requestor_Phone__c = this.reqPhone;
        nCase.SuppliedEmail = this.caseContactEmail;
        nCase.GE_NAS_Confirmation__c = this.orderNumber;
        nCase.Order_Name__c = this.selectedOrder;
        nCase.Type = 'Acct/Order Mgmnt';
        nCase.GE_NAS_Sub_Type__c = 'Change Request';
        nCase.Subject = 'Change Request Case';
        console.log(JSON.stringify("Output of the Result is: "+ JSON.stringify(nCase)));        

        

        await createCaseRecord({newCase: nCase})
        .then(result => {
            //console.log(JSON.stringify("Output of the Result is:113223 "));
            this.CaseNumber = result;
            console.log(JSON.stringify("The Result is: "+ JSON.stringify(this.CaseNumber)));             
            //updateOwnerId({CaseId: this.CaseNumber}); 
            console.log('Sending Files to UPDATE: '+ this.filesToInsert);
            //Apex call to get the case number 
            
                    //CALLS APEX TO LINK UPLOADED FILES TO CASE
            updateFiles({passFiles: this.filesToInsert, CaseId: this.CaseNumber});
                                     
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
                    nCaseProduct.GE_NAS_Type_of_Problem1__c = linesList[j].Category_Of_Change__c;                                                
                    nCaseProduct.GE_NAS_Product_Code__c = linesList[j].Product_SKU__c; 
                    nCaseProduct.Requested_Delivery_Date__c =  linesList[j].New_Shipment_Date__c;
                    nCaseProduct.GE_NAS_Comments__c =    linesList[j].Reason_for_Change__c;
                    nCaseProduct.Unique_ID__c = linesList[j].Transaction_ID__c;               
                    nCaseProduct.Distributor_Name__c = linesList[j].Distributor_Name__c;
                    nCaseProduct.Distributor_ID__c = linesList[j].Distributor_Id__c;
                    nCaseProduct.GE_NAS_Unit_of_Measure__c=linesList[j].UnitOfMeasure__c;
                    nCaseProduct.Order_Qty__c = linesList[j].Quantity__c;
                    nCaseProduct.Invoiced_Price__c = linesList[j].UnitPrice__c;   
                                 
                    this.caseProductInsert.push(nCaseProduct);
                //console.log('Case Products to Insert: '+ JSON.stringify(this.caseProductInsert));    
            }
            console.log('Case Products to Insert: '+ JSON.stringify(this.caseProductInsert));  
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

    goHome(event){
        var baseURL = window.location.origin;
        console.log('Base URL: '+baseURL);
        this.sfdcOrgURL = baseURL+'/Agents/s/';
        console.log('New URL: '+this.sfdcOrgURL);
        window.open(this.sfdcOrgURL, "_self");
    }

    goToCase(event){
        var baseURL = window.location.origin;
        console.log('Base URL: '+baseURL);
        this.sfdcOrgURL = baseURL+'/Agents/s/case/'+this.CaseNumber+'/detail';
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

    beforeUnloadHandler(event){
        console.log("beforeUnloadHandler called");
        updateInvoiceLines({lines : this.invLinesToUpdate})
                .then(result => {
                   console.log('INVOICE LINES RESET....'+result);
        });
       this.template.querySelector("c-invoice-item-search").clearSessionCart();
     
        //return "";
    }

    disconnectedCallback() {
        window.removeEventListener("beforeunload", this.beforeUnloadHandler);
    console.log("disconnectedCallback executed");
        
        
    }

}