import { LightningElement, track, api, wire } from 'lwc';
//FETCHING FILE UPLOAD FROM APEX CLASSES
import updateFiles from '@salesforce/apex/connectCreateCase.updateFiles';
import getRelatedFiles from '@salesforce/apex/FileUploadViewController.getRelatedFiles';
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
//USED TO FETCH CASE NUMBER OF THE CASE CREATED
import getCaseNumber from '@salesforce/apex/connectCreateCase.getCaseNumber';
//USED TO FETCH QUEUE TO ASSIGN THE CASE
import getDCSQueueId from '@salesforce/apex/connectCreateCase.getDCSQueueId';


export default class ConnectPlatformSupportLWC extends LightningElement {

    @track toggleSubmitLabel = "Submit";
    @track reqName; // REQUESTOR NAME FORM FIELD --> STEP 1
    @track reqEmail; // REQUESTTOR EMAIL FORM FIELD --> STEP 1
    @track reqPhone; // REQUESTOR PHONE FORM FIELD --> STEP 1
    @track contactID; //CONTACT INFORMATION FOR THE LOOGED IN USER
    @track accountID; // ACCOUNT INFORMATION FOR THE LOGGED IN USER
    @track questions=false; // USED FOR PICKING THE VALUES FROM QUESTION CATEGORY PICKLIST
    @track isSpinner = false;
    @track quest;
    @track caseNumberNew;//CASE NUMBER
    @track currentStep;// TO MOVE THE STEPS
    @track sfdcOrgURL;
    @track newQueueId; // STORING QUEUEID
    @track subCatOption;
    @track filesToInsert = []; 
    @track lstAllFiles = []; // ARRAY OF FILES TO BE INSERTED INTO THE DATABASE 
    @track values; // Set value to question category
    @track subValues; //Set value to question sub category

    @api transactionID; // DISPLAYS THE ID FOR THIS TRANSACTION --> USED IN BOTH FRONT AND BACKEND
    @api CaseNumber; // THE CASE ID THAT IS RETURNED AFTER SUBMIT
    @api agencyName; // ACCOUNT ID SELECTED FROM THE ACCOUNT LOOKUP FIELD --> STEP 1
    @api questionCat; //QUESTION CATEGORY PICKLIST 
    @api soldToAccount;
    @api quesSubCategory;
    @api files; // TEMPORARILY STORES THE FILES UPLOADED IN THE FILEUPLOADVIEWER COMPONENT
    @api fileToDelete; // SELECTED FILES TO BE DELETED FROM THE FILEUPLOADVIEWER COMPONENT
    @api updatedId;
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
            this.convertPhone(this.reqPhone);
            
            //var inputacc=this.soldToAccount;
            //this.template.querySelector("c-account-search-custom").setConfirmValues(inputacc);
            this.setAccountfromSelector();
        }
    }
//--------------------------------------------------

setAccountfromSelector(){
    let storedUserType = localStorage.getItem('User Type');
    if(storedUserType == "Agent"){

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
}
//Getting the current url
/*renderedCallback() {
    this.sfdcOrgURL = window.location.href;
}*/

get acceptedFormats() {
    return ['.pdf','.png','.jpg','.jpeg','.doc','.csv','.docx', '.xls','.xlsx','.ppt','.pptx','.odt', '.rtf'];
}

connectedCallback(){

    var today = new Date();
        var date = today.getFullYear()+'-'+(today.getMonth()+1)+'-'+today.getDate();
        var time = today.getHours() + ":" + today.getMinutes() + ":" + today.getSeconds();
        const id = 'id' + performance.now()+'-'+date+'-'+time;
        this.transactionID = id;
        console.log('Generated ID: '+ id);

        console.log('Setting the Transcation ID: '+this.transactionID);

    let URL = window.location.href;

    if(URL.includes('?requestURL=')==true){

        let urlSplit = URL.split('?requestURL=')[1];

        this.sfdcOrgURL = decodeURIComponent(urlSplit);

        console.log('Request URL: '+this.sfdcOrgURL);

    } else if(URL.includes('?type=')==true) {

        this.sfdcOrgURL = URL;

        this.getUrlParams();

    } else {

        this.sfdcOrgURL = window.location.href;

    }

}

getUrlParams() {
    var urlParams = new URLSearchParams(window.location.search);
    var param = urlParams.get("type");
    if (param == "upload_error") {
       this.values = "Product, Price, and Availability";
       this.subValues = "Bulk Upload Error"
       this.questions = true;
       this.subCatOption=this.subCatOption2;
    }
}

//FOLLOWING WIRE IS FOR CHOSSING THE PICKLIST VALUE FROM QUESTION CATEGORY 
/*@wire(getObjectInfo, { objectApiName: CASE_OBJECT })
    objectInfo;
    //FOR Picklist values for Job State
    @wire(getPicklistValues, { recordTypeId: '0123j000000X8ys', fieldApiName: QUESTION_CAT_FIELD})
    PicklistValues;*/

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


get questionCatOption(){
    return[
        {label: 'Security, Visibility, and User Accounts', value: 'Security, Visibility, and User Accounts'},
        {label: 'Product, Price, and Availability', value: 'Product, Price, and Availability'},
        {label: 'Order Lookup', value: 'Order Lookup'},
        {label: 'Training and Tools', value: 'Training and Tools'},
        {label: 'Other', value: 'Other'},
    ];
}

@track subCatOption1 = [
        {label: 'Add new Branch Location to User', value: 'Add new Branch Location to User'},
        {label: 'Remove Branch Location from User', value: 'Remove Branch Location from User'},
        {label: 'Move User from one Branch to Another', value: 'Move User from one Branch to Another'},
        {label: 'Create New User', value: 'Create New User'},
        {label: 'Deactivate / Disable User', value: 'Deactivate / Disable User'},
        {label: 'Change Default Branch for User', value: 'Change Default Branch for User'},
        {label: 'Grant access to Price (Cost) Information', value: 'Grant access to Price (Cost) Information'},
        {label: 'Revoke access from Price (Cost) Information', value: 'Revoke access from Price (Cost) Information'},
        {label: 'Grant access to Commission Information', value: 'Grant access to Commission Information'},
        {label: 'Revoke access from Commission Information', value: 'Revoke access from Commission Information'},
        {label: 'Other', value: 'Other'},
    ];

@track subCatOption2 = [
        {label: 'Why am I getting zero for a product', value: 'Why am I getting zero for a product'},
        {label: 'I can\'\t find a product I should be able to sell', value: 'I can\'\t find a product I should be able to sell'},
        {label: 'I want to extend or modify my price agreement', value: 'I want to extend or modify my price agreement'},
        {label: 'My customer is not assigned to a price agreement & I think they should', value: 'My customer is not assigned to a price agreement & I think they should'},
        {label: 'I\'\m getting an error on price agreement submission', value: 'I\'\m getting an error on price agreement submission'},
        {label: 'I want to access my price agreement letter', value: 'I want to access my price agreement letter'},
        {label: 'Bulk Upload Error', value: 'Bulk Upload Error'},
        {label: 'Other', value: 'Other'},
    ];

@track subCatOption3 = [
        {label: 'I can\'\t find my order', value: 'I can\'\t find my order'},
        {label: 'How do I request a change or order', value: 'How do I request a change or order'},
        {label: 'My shipping tracking is unavailable', value: 'My shipping tracking is unavailable'},
        {label: 'How can I get a Bill of Lading/Packing List', value: 'How can I get a Bill of Lading/Packing List'},
        {label: 'My invoice does not look correct', value: 'My invoice does not look correct'},
        {label: 'I\'\m getting an error on order submission', value: 'I\'\m getting an error on order submission'},
        {label: 'Other', value: 'Other'},
    ];

@track subCatOption4 =[ 
        {label: 'How do I take a virtual training class', value: 'How do I take a virtual training class'},
        {label: 'How do I register for a webinar', value: 'How do I register for a webinar'},
        {label: 'How do I get to the engineering tools', value: 'How do I get to the engineering tools'},
        {label: 'How do I access my pricing sheets', value: 'How do I access my pricing sheets'},
        {label: 'Other', value: 'Other'},
    ];

@track subCatOption5 = [
    {label: 'Other', value: 'Other'},
    ];
    
//----------------------------------------------------------------------


//----------------------------------------------------------

handlePick(event) {
    this.questionCat = event.target.value;
    console.log('Question Category: '+this.questionCat);

    if(this.questionCat == "Security, Visibility, and User Accounts"){   
        console.log('subCatOption: ')  ;
        this.subCatOption=this.subCatOption1;  
        console.log('subCatOption After: ' + this.subCatOption)  ;         
    }
    else if(this.questionCat == "Product, Price, and Availability"){
        console.log('subCatOption: ')  ;
        this.subCatOption=this.subCatOption2;  
        console.log('subCatOption After: ' + this.subCatOption)  ;   
    }
    else if(this.questionCat == "Order Lookup"){
        console.log('subCatOption: ')  ;
        this.subCatOption=this.subCatOption3;  
        console.log('subCatOption After: ' + this.subCatOption)  ;   
    }
    else if(this.questionCat == "Training and Tools"){
        console.log('subCatOption: ')  ;
        this.subCatOption=this.subCatOption4;  
        console.log('subCatOption After: ' + this.subCatOption)  ;   
    }
    else{
        this.subCatOption=this.subCatOption5;  
    }
    

    if(this.questionCat == 'Security, Visibility, and User Accounts' || 
        this.questionCat == 'Product, Price, and Availability' || 
        this.questionCat == 'Order Lookup' || 
        this.questionCat == 'Training and Tools' || 
        this.questionCat == 'Other'){
            this.questions = true;
    }
}

//---------------------------------------------------------------

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

//-------------------------------------------------------

handleChange(event){
    this.agencyName = event.target.value;
    //this.soldToName = event.target.dataset.name;
    console.log('Agency Name is: '+ this.agencyName);
    //console.log('Sold To Account Name: '+ this.soldToName);
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
                
                    await getAccName({id_dtl: this.soldToAccount})
                    .then(result => {
                    this.accName = result;
                    console.log(JSON.stringify("Account Name Selected "+ JSON.stringify(this.accName)))
                    }); 
                    this.reqName = this.template.querySelector(".rn").value;
                    console.log('Requestor Name '+this.reqName);
                    this.reqEmail = this.template.querySelector(".em").value;
                    console.log('Requestor Email '+this.reqEmail);
                    this.reqPhone = this.template.querySelector(".rp").value;
                    console.log('Requestor Phone'+this.reqPhone);
                    this.quest = this.template.querySelector(".cd").value;
                    console.log('Questions'+this.quest);
                    this.questionCat = this.template.querySelector(".aba").value;
                    console.log('Question Category'+this.questionCat);
                    this.quesSubCategory = this.template.querySelector(".asa").value;
                    console.log('Question Sub Category'+this.quesSubCategory);

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
    await getDCSQueueId()
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
    nCase.eLight_Form_Type__c = 'Connect Platform Support';
    nCase.AccountId = this.soldToAccount;
    nCase.Requestor_Email__c = this.reqEmail;
    nCase.eLight_Requestor_Phone__c = this.reqPhone;
    nCase.eLight_Requestor_Name__c = this.reqName;
    nCase.SuppliedEmail = this.caseContactEmail;
    nCase.Question_Category__c = this.questionCat;
    nCase.Question_Sub_Category__c = this.quesSubCategory;
    nCase.Questions__c = this.quest;
    nCase.Type = 'Web Assistance';
    nCase.GE_NAS_Sub_Type__c = 'Connect Platform Support';
    nCase.Subject = 'Connect Platform Support - Case';
    console.log(JSON.stringify("Output of the Result is: "+ JSON.stringify(nCase)));        

    

    await createCaseRecord({newCase: nCase})
    .then(result => {
        //console.log(JSON.stringify("Output of the Result is:113223 "));
        this.CaseNumber = result;
        console.log(JSON.stringify("The Result is: "+ JSON.stringify(this.CaseNumber)));             
        console.log('Sending Files to UPDATE: '+ this.filesToInsert);
        //CALLS APEX TO LINK UPLOADED FILES TO CASE
        updateFiles({passFiles: this.filesToInsert, CaseId: this.CaseNumber});

        console.log(result);
        t
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