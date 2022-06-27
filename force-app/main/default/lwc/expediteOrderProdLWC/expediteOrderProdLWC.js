import { LightningElement, api, track, wire} from 'lwc';
//USED FOR FETCHING DATATABLE RECORDS AND ORDER DATA
import getExpOItemList from '@salesforce/apex/ExpediteOrderProdController.getExpOItemList';
//FETCHING FILE UPLOAD FROM APEX CLASSES
import updateFiles from '@salesforce/apex/connectCreateCase.updateFiles';
import getRelatedFiles from '@salesforce/apex/FileUploadViewController.getRelatedFiles';
//USED FOR CREATION CASE AND CASE PRODUCT RECORDS
import createCaseRecord from '@salesforce/apex/connectCreateCase.connectCreateReturnCase';
import createCaseProduct from '@salesforce/apex/connectCreateCase.createCaseProduct';
//USED FOR GETTING CASE NUMBER AND OWNERID OF ACCOUNT 
import getCaseNumber from '@salesforce/apex/connectCreateCase.getCaseNumber';
import getCSOwnerId from '@salesforce/apex/connectCreateCase.getCSOwnerId';
//USED FOR UPDATING & REFRESHING DATA
import getExpOItemRefList from '@salesforce/apex/ExpediteOrderProdController.getExpOItemRefList';
import getExpOItemNewList from '@salesforce/apex/ExpediteOrderProdController.getExpOItemNewList';
import updateExpReturnItemList from '@salesforce/apex/ExpediteOrderProdController.updateExpReturnItemList';
import getReturnList from '@salesforce/apex/ExpediteOrderProdController.getReturnList';
import getAgentId from '@salesforce/apex/connectCreateCase.getAgentId';
import updDisName from '@salesforce/apex/ExpediteOrderProdController.updDisName';
import getAccName from '@salesforce/apex/connectCreateCase.getAccountName';
//
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

// USED FOR GETTING THE USER DATA - WITHOUT APEX CALL
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';
import EMAIL_FIELD from '@salesforce/schema/User.Email';
import PHONE_FIELD from '@salesforce/schema/User.Phone';
import CONTACT_FIELD from '@salesforce/schema/User.ContactId';
import ACCOUNT_FIELD from '@salesforce/schema/User.AccountId';
import USER_TYPE_FIELD from '@salesforce/schema/User.User_Type__c';
//TO GET THE ORDER NO.
//import orderDefValue from '@salesforce/apex/DefOrder.orderDefValue';


const actions = [
    { label: 'edit', name: 'edit' },
];

export default class ExpediteOrderProdLWC extends LightningElement {
// COLUMNS FOR ORDER LINE ITEM SELECTION SCREEN
@track columns1 = [{
    label: 'Order Line #',
    fieldName: 'Order_Line_Number__c',
    type: 'Text',
    sortable: true
},
{
    label: 'Catalog #',
    fieldName: 'SKU_Description_Cat_Logic__c',
    iconName: 'utility:products',
    type: 'Text',
    sortable: true,
    cellAttributes: { alignment: 'left' }
},
{
    label: 'SKU #',
    fieldName: 'SKU__c',
    type: 'Text',
    sortable: true,
    cellAttributes: { alignment: 'center' }
},
{
    label: 'PO#',
    fieldName: 'PO__c',
    type: 'Text',
    sortable: true,
    cellAttributes: { alignment: 'center' }
},
{
    label: 'Qty',
    fieldName: 'Quantity',
    iconName: 'utility:number_input',
    type: 'Text',
    sortable: true,
    cellAttributes: { alignment: 'right' }
},
{
    label: 'Price',
    fieldName: 'UnitPrice',
    iconName: 'utility:money',
    type: 'currency',
    sortable: true
},
/*{
    label: 'Distributor Name',
    fieldName: 'Distributor_Name__c',
    type: 'Text',
    sortable: true,
    cellAttributes: { alignment: 'center' }
},*/
{
    label: 'Requested Delivery Date',
    fieldName: 'Requested_Delivery_Date__c',
    iconName: 'utility:date_input',
    type: 'Date',
    sortable: true,
    cellAttributes: { alignment: 'center' }
},
{
    label: 'Expected Shipment Date',
    fieldName: 'Expected_Shipment_Date__c',
    iconName: 'utility:date_input',
    type: 'Date',
    sortable: true,
    cellAttributes: { alignment: 'center' }
},
{
    label: 'Shipment From',
    fieldName: 'Ship_From__c',
    type: 'text',
    sortable: true
},
{
    label: 'Requested New Ship Date',
    fieldName: 'New_Requested_Delivery_Date__c',
    iconName: 'utility:date_input',
    type: 'date-local',    
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
    
}   
];

@track columns2 = [{
    label: 'Order Line #',
    fieldName: 'Order_Line_Number__c',
    type: 'Text',
    sortable: true
},
{
    label: 'Catalog #',
    fieldName: 'SKU_Description_Cat_Logic__c',
    iconName: 'utility:products',
    type: 'Text',
    sortable: true,
    cellAttributes: { alignment: 'left' }
},
{
    label: 'SKU #',
    fieldName: 'SKU__c',
    type: 'Text',
    sortable: true,
    cellAttributes: { alignment: 'center' }
},
{
    label: 'PO#',
    fieldName: 'PO__c',
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
    cellAttributes: { alignment: 'right' }
},
{
    label: 'Price',
    fieldName: 'UnitPrice',
    iconName: 'utility:money',
    type: 'currency',
    sortable: true
},
/*{
    label: 'Distributor Name',
    fieldName: 'Distributor_Name__c',
    type: 'Text',
    sortable: true,
    cellAttributes: { alignment: 'center' }
},*/
{
    label: 'Requested Delivery Date',
    fieldName: 'RequestedDeliveryDate__c',
    iconName: 'utility:date_input',
    type: 'Date',
    sortable: true,
    cellAttributes: { alignment: 'center' }
},
{
    label: 'Expected Shipment Date',
    fieldName: 'Expected_Shipment_Date__c',
    iconName: 'utility:date_input',
    type: 'Date',
    sortable: true,
    cellAttributes: { alignment: 'center' }
},
{
    label: 'Shipment From',
    fieldName: 'Ship_From__c',
    type: 'text',
    sortable: true
},
{
    label: 'Requested New Ship Date',
    fieldName: 'New_Requested_Delivery_Date__c',
    iconName: 'utility:date_input',
    type: 'date-local',    
    sortable: true
}, 
];

// COLUMNS FOR THE VIEW CART MODAL
@track cartColumns = [{
    label: 'Order Line #',
    fieldName: 'Order_Line_Number__c',
    type: 'Text',
    sortable: true,    
},
{
    label: 'Catalog #',
    fieldName: 'Product_SKU__c',
    iconName: 'utility:products',
    type: 'Text',
    sortable: true,
    cellAttributes: { alignment: 'left' }
},
{
    label: 'SKU #',
    fieldName: 'SKU__c',
    type: 'Text',
    sortable: true,
    cellAttributes: { alignment: 'center' }
},
{
    label: 'PO#',
    fieldName: 'PO__c',
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
    cellAttributes: { alignment: 'right' }
},
{
    label: 'Price',
    fieldName: 'UnitPrice__c',
    iconName: 'utility:money',
    type: 'currency',
    sortable: true
},
/*{
    label: 'Distributor Name',
    fieldName: 'Distributor_Name__c',
    type: 'Text',
    sortable: true,
    cellAttributes: { alignment: 'center' }
},*/
{
    label: 'Requested Delivery Date',
    fieldName: 'Requested_Delivery_Date__c',
    iconName: 'utility:date_input',
    type: 'Date',
    sortable: true,
    cellAttributes: { alignment: 'center' }
},
{
    label: 'Expected Shipment Date',
    fieldName: 'Expected_Shipment_Date__c',
    iconName: 'utility:date_input',
    type: 'Date',
    sortable: true,
    cellAttributes: { alignment: 'center' }
},
{
    label: 'Shipment From',
    fieldName: 'Ship_From__c',
    type: 'Date',
    sortable: true
},
{
    label: 'Requested New Ship Date',
    fieldName: 'New_Requested_Delivery_Date__c',
    iconName: 'utility:date_input',    
    type: 'date-local',
    sortable: true
},        
];
//--------END COLUMNS FOR THE VIEW CART MODAL-----------------------------

@track isOrderItemAvailable = false;    
@track error;
@track oItemList;
@track selectedorder;
@track bShowModal1 = false;
@track bShowModal = false;
@track currentRecordId;
@track isEditForm = false;
@track flagIndi = false;
@track valCheck = false;
@track newRow;
@track reqDeliveryDate;
@track cartLabel; 
@track expShipDate;
@track shipDate;
@track accountName;
@track soldToName;
@track currentStep;
@track accntId;
@track shipCompFlg;
@track toggleSubmitLabel = "Submit";
@track reqName; // REQUESTOR NAME FORM FIELD --> STEP 1
@track reqEmail; // REQUESTTOR EMAIL FORM FIELD --> STEP 1
@track reqPhone; // REQUESTOR PHONE FORM FIELD --> STEP 1
@track expReason;//USER INPUT FOR EXPEDITE REASON--> STEP 2
@track newShpNotBfrDt; //USER INPUT FOR SHIP NOT BFR DT --> STEP 2
@track shpCmpltFlg; //USER INPUT FOR SHIP COMPLETE FLG --> STEP 2
@track newOwnerId; // FOR ASSIGNING THE CASE
@track caseNumberNew; // FOR GETTING CASE NUMBER CREATED
@track isSpinner = false;
@track currentRecordId;
@track columns;
@track stepOneButton = false;
@track sfdcOrgURL;
@track paramString=[];
@track orderFlag= 'N';
@track lenSelcOrder=0;
@track distributorID;
@track showDistroField = false;  
@track agentNumber='DEFAULT';  
@track disAccount='DEFAULT';
@track disName=[];
@track orderValue;
@track showNextButton = true;

draftValues = [];
@api ordLines;
@api CaseNumber;
@api storedLines;
@api transactionID;
@api cartCount = 0;
@api recordId;
@api getorder;
@api selectedOrder;
@api caseProductInsert = [];
@api contactID;
@api valuetopass;    
@api files; // TEMPORARILY STORES THE FILES UPLOADED IN THE FILEUPLOADVIEWER COMPONENT
@track filesToInsert = []; 
@track lstAllFiles = []; // ARRAY OF FILES TO BE INSERTED INTO THE DATABASE 
@api fileToDelete; // SELECTED FILES TO BE DELETED FROM THE FILEUPLOADVIEWER COMPONENT
@api updatedId;
@api orderItemNewList;
@api soldToAccount=[];
@api orderLines;
//TO GET THE ORDER NO.
@api orderNumber;
@api orderId;
@track passedOrder;
@api defOrderNew;
@track receivedMessage = '';
@track subscription = null;
@track isLoading = false;
@track userType;
@track accountID;
@track orderPO;
@track orderShipFrom;
@track orderExpectedDate;
@track isYes = false;

//@api context;

value = [];

/*@api 
get type() {
return this._type;
}
     
set type(value) {
this._type = value;
this.connectedCallback();
}*/

connectedCallback(){
    const id = 'id' + performance.now();
    this.transactionID = id;
    console.log('Generated ID: '+ id);

    this.sfdcOrgURL = window.location.href;
    if(this.sfdcOrgURL.includes('id=')==true){
    this.paramString = this.sfdcOrgURL.split('id=')[1]; 
    console.log("URL Check2:" + this.paramString);
    console.log("URL Check:" + this.sfdcOrgURL);
    }



}

// GET CURRENT LOGGED IN COMMUNITY USER INFORMATION
@wire(getRecord, {
    recordId: USER_ID,
    fields: [NAME_FIELD, EMAIL_FIELD, PHONE_FIELD, CONTACT_FIELD, ACCOUNT_FIELD, USER_TYPE_FIELD]
}) wireuser({
    error,
    data
}) {
    if (error) {
    this.error = error ; 
    } else if (data) {
        this.reqEmail = data.fields.Email.value;
        this.reqName = data.fields.Name.value;
        this.reqPhone = data.fields.Phone.value;
        this.contactID = data.fields.ContactId.value;
        this.soldToAccount = data.fields.AccountId.value;
        this.showDistroField = false;
        this.userType = data.fields.User_Type__c.value;
        this.convertPhone(this.reqPhone);

        getAgentId({AccountId: this.soldToAccount})
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

            //var inputacc=this.soldToAccount;
            //this.template.querySelector("c-account-search-custom").setConfirmValues(inputacc);
            this.setAccountfromSelector();
            
            if(this.paramString.length>0){
                console.log("Param String Check" +this.paramString);
    
                var inputord=this.paramString;
                this.template.querySelector("c-order-search-custom").setConfirmValues(inputord);
                }
    }
}
//--------------------------------------------------

// SETTING ACCOUNT NAME FIELD FROM THE ACCOUNT SELECTOR WHEN CASE IS INITIATIED
setAccountfromSelector(){
    let storedUserType = localStorage.getItem('User Type');
    if(storedUserType == "Agent"){

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
            // this.template.querySelector("c-distributor-search-custom").setConfirmValues(agentNum);
            console.log('Setting Account Number from Local Storage: '+inputacc);

            getAgentId({AccountId: this.soldToAccount})
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
            this.soldToAccount = retrieveData;
            var inputacc = retrieveData;
            console.log('Sending Account ID to Account Search: '+inputacc);
            this.template.querySelector("c-account-search-custom").setConfirmValues(inputacc);
            console.log('Setting Account Number from Local Storage: '+inputacc);
        }
    }
}
//--------------------------------------------------------------------------

get acceptedFormats() {
    return ['.pdf','.png','.jpg','.jpeg','.doc','.docx', '.xls','.xlsx','.ppt','.pptx','.odt', '.rtf'];
}

/*connectedCallback(){
    const id = 'id' + performance.now();
    this.transactionID = id;
    console.log('Generated ID: '+ id);

    var setType = this._type;
    if(setType == "Warranty"){
        this.isWarranty = true;
    }  
    console.log('Calling the Handle Sub: ');
    this.subscribeToMessageChannel();
} */


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

confirmchange(event){
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

}

async handleChange(event) {

   // console.log("You selected an order: " + event.detail.value[0]);
    //this.selectedOrder = event.detail.value[0];
    //console.log("Type of" +typeof(selectedOrder));
    this.selectedOrder = event.detail.selectedRecordId;
        console.log('The lines passed to child for Delivery: '+this.selectedOrder);

    

    await getExpOItemList({orderId: this.selectedOrder})
    .then(result => {
        console.log(JSON.stringify("The Result from APEX is: "+ JSON.stringify(result)));
        this.oItemList  = result;
        console.log(JSON.stringify("The Result from APEX is: "+ JSON.stringify(this.oItemList)));
        this.isOrderItemAvailable = true;
       
                       

    }).catch(error => {
        console.log("The error SENT TO APEX is: " +JSON.stringify(error));
        this.error = error;        
    });

    var selRow = this.oItemList;
    console.log('New value setting check' +JSON.stringify(selRow));
    for (var i =0; i< selRow.length ;i++) {
        console.log('Selected ROW: '+selRow[i].Order.GE_Order_NO__c);
         this.newRow = selRow[i].Order.GE_Order_NO__c;
         this.reqDeliveryDate = selRow[i].Order.Order_Req_Delivery_Date__c;
         this.shipDate = selRow[i].Order.Order_Ship_From__c;
         this.expShipDate = selRow[i].Order.Order_Expected_Ship_Date__c;
         this.accountName = selRow[i].Order.Account.Name;
         this.orderPO = selRow[i].Order.Customer_PO_Number__c;
         //this.soldToName = selRow[i].Order.Sold_To__r.Name;
         this.accntId = selRow[i].Order.Agent_Account__c;
         //this.shipCompFlg = selRow[i].Order.Ship_Complete__c;
         this.shipCompFlg = 'Yes';

         console.log('Ship Complete flag value' +this.shipCompFlg);
         
     }
     if(this.shipCompFlg == 'Yes'){
         this.columns=this.columns2;
     }
     else{
         this.columns=this.columns1;
     }

     // MATT MODIFIED THIS CODE FOR NEW VALIDATION REQUIREMENTS  -- DO NOT UNCOMMENT
     /*if(this.shipCompFlg == 'Yes'){
        this.showNextButton = false;
     }     
     else{
        this.showNextButton = true; 
     }*/
     console.log('OrderNumber' + this.newRow);
     console.log('AccountName' + this.accountName);
     console.log('Ship Flag' + this.shipCompFlg);
     
     
} 

async handleChangeNew() {

    
    this.selectedOrder = this.paramString;
    console.log("You selected an order: " +  this.selectedOrder);
    //console.log("Type of" +typeof(selectedOrder));

    

    await getExpOItemList({orderId: this.selectedOrder})
    .then(result => {
        console.log(JSON.stringify("The Result from APEX is: "+ JSON.stringify(result)));
        this.oItemList  = result;
        console.log(JSON.stringify("The Result from APEX is: "+ JSON.stringify(this.oItemList)));
        this.isOrderItemAvailable = true;
       
                       

    }).catch(error => {
        console.log("The error SENT TO APEX is: " +JSON.stringify(error));
        this.error = error;        
    });

    var selRow = this.oItemList;
    console.log('New value setting check' +JSON.stringify(selRow));
    for (var i =0; i< selRow.length ;i++) {
        console.log(selRow[i].Order.OrderNumber);
         this.newRow = selRow[i].Order.GE_Order_NO__c;
         this.orderPO = selRow[i].Order.Customer_PO_Number__c;
         this.reqDeliveryDate = selRow[i].Order.Order_Req_Delivery_Date__c;
         this.shipDate = selRow[i].Order.Order_Ship_From__c;
         this.expShipDate = selRow[i].Order.Order_Expected_Ship_Date__c;
         this.accountName = selRow[i].Order.Account.Name;
         //this.soldToName = selRow[i].Order.Sold_To__r.Name;
         this.accntId = selRow[i].Order.Agent_Account__c;
         this.shipCompFlg = selRow[i].Order.Ship_Complete__c;
         
     }
     if(this.shipCompFlg == 'Yes'){
         this.columns=this.columns2;
     }
     else{
         this.columns=this.columns1;
     }
     console.log('OrderNumber' + this.newRow);
     console.log('AccountName' + this.accountName);
     console.log('Ship Flag' + this.shipCompFlg);
     
} 

get options() {
    return [
        { label: 'Yes', value: 'Yes' }, 
        { label: 'No', value: 'No'},
    ];
}

/*get selectedValues() {
    return this.value.join(',');
}*/

handleCheckChange(e) {
    this.value = e.detail.value;
    const storeVal = this.value;
    console.log('Value from the Checkbox: '+ storeVal);

    if (storeVal== 'Yes'){
        this.showNextButton = false;
        this.isYes = true;
        console.log('Field Required: '+this.isYes);
        console.log('Inside If');
        this.valCheck=true;        
        console.log('Value from the new requestded Date: '+ this.newReqDelDate);
        this.columns=this.columns2;

    } else if(storeVal == 'No'){
        this.showNextButton = true;        
        console.log('Inside else');
        this.isYes = false;
        this.valCheck=true; 
        console.log('Inside else'+ this.valcheck);
        this.storedLines=[];
        this.columns=this.columns1;      
        //this.storedLines=[];
        //console.log('Inside else'+ this.catChange);
    }
}

get makerequired() {
    if (this.isYes == true) {
        return true;
    } else {
        return false;
    }
    return ;
}

handleRowActions(event) {
    this.cartLabel = "Add to Request";
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
      // this.draftValues=[];   
      // console.log('Before Refresh: '+ JSON.stringify(this.orderItemList));
      // console.log('Check for Refresh: '+ this.selectedOrder);

    // showing success message
}).catch(error=>{
    this.ShowToastMsg('Error Updating Records', error.body.message, error)
});
    }


/*async handleUpdate(event){
    console.log(event.detail.draftValues)
    const recordInputs = event.detail.draftValues.slice().map(draft=>{
        const fields = Object.assign({}, draft)
        return {fields}
    })
    console.log("recordInputs", recordInputs)

    this.updatedId=event.detail.draftValues[0].Id; 
    console.log('Handle Click ID check: '+ this.updatedId); 

    const promises = recordInputs.map(recordInput => updateRecord(recordInput))
   await Promise.all(promises).then(result=>{
       this.ShowToastMsg('Success', 'Order Item Req Date Updated')
       this.draftValues=[];   
       console.log('Before Refresh: '+ JSON.stringify(this.oItemList));
       console.log('Check for Refresh: '+ this.selectedOrder);
       //return refreshApex(this.productList);

       
    }).catch(error=>{
        this.ShowToastMsg('Error Updating Records', error.body.message, error)
    });
 this.handleSuccess();
}*/

async handleSuccess() {
    console.log("Order Id inside handle Success:" +this.selectedOrder);
    await getExpOItemRefList({orderId: this.selectedOrder})
            .then(result => {
                this.oItemList = result;
                console.log(result);
                console.log('After refresh datatable data: ' + JSON.stringify(this.oItemList));
                this.ShowToastMsg('Success', 'New Requested Delivery Date Updated')
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
  await getExpOItemNewList({transId: this.currentRecordId}) 
           .then(result => {
               this.orderItemNewList = result;
               console.log(result);
               console.log('Value passed from Apex for currentrow: ' + JSON.stringify(this.orderItemNewList));
           });
    
    var selected = this.orderItemNewList;
    console.log('Selected Lines: '+ JSON.stringify(selected));
    //this.storedLines = selected;
    console.log('Stored Lines: '+ JSON.stringify(this.storedLines));
    var newselval = selected.map(row => { return { "Order_Product_Id__c" : this.currentRecordId, "UnitOfMeasure__c": row.UnitOfMeasure__c, "Order_Line_Number__c": row.Order_Line_Number__c, "Product_SKU__c": row.SKU_Description_Cat_Logic__c, "Quantity__c": row.Quantity, "UnitPrice__c": row.UnitPrice,
        "PO__c":row.PO__c,"Requested_Delivery_Date__c":row.Requested_Delivery_Date__c,"Expected_Shipment_Date__c":row.Expected_Shipment_Date__c, "SKU__c": row.SKU__c, "Type__c": "Expedite Request",
        "Ship_From__c":row.Ship_From__c, "New_Requested_Delivery_Date__c":row.New_Requested_Delivery_Date__c,"Transaction_ID__c": this.transactionID, "Unique_ID__c": this.transactionID+'_'+row.SKU__c,"Distributor_Name__c":row.Distributor_Name__c,"Distributor_Id__c":this.orderLines}});

    
    
    this.valuetopass = selected;
    console.log('value to pass check:' + JSON.stringify(this.valuetopass));
    
    console.log('value to pass check:' + JSON.stringify(newselval));
    await updateExpReturnItemList({data: newselval})
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
    getReturnList({transId : this.transactionID})
        .then(result =>{
            this.storedLines = result;
            this.cartCount = this.storedLines.length;
            if(this.cartCount > 0){
                this.showNextButton = false;
            }
            else{
                this.showNextButton = true;
    
            }
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
    this.isOrderItemAvailable = false;
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

async handleSave(event){
    console.log('User Type: '+this.userType);
    //console.log(JSON.stringify("The Result is: "));
    if(this.userType == "Agent"){
        this.accountID = this.accntId;
        console.log('AGENT - Account ID Being Sent: '+this.accountID);
    } else{
        this.accountID = this.soldToAccount;
        console.log('DISTRIBUTOR - Account ID Being Sent: '+this.accountID);
    }
    await getCSOwnerId({AccountId: this.accountID})
    .then(result => {
        this.newOwnerId =result;
        console.log("The Result for new Owner: "+ JSON.stringify(this.newOwnerId));   
    }
    )


    this.toggleSubmitLabel = "Submitting...";
    this.isSpinner = true;
    let nCase = { 'sobjectType': 'Case' };
    nCase.RecordTypeId = '0123j000000X8ys';
    nCase.OwnerId = this.newOwnerId; 
    nCase.ContactId = this.contactID;   
    nCase.Origin = 'Connect';
    nCase.eLight_Form_Type__c = 'Expedite';        
    nCase.Order_Name__c = this.selectedOrder;
    nCase.GE_NAS_Purchase_Order__c = this.orderPO;
    nCase.Expedite_Reason__c = this.expReason;
    nCase.Connect_ID__c = this.transactionID;
    nCase.eLight_Requestor_Name__c = this.reqName;
    nCase.Requested_Delivery_date__c = this.newShpNotBfrDt;
    nCase.Requestor_Email__c = this.reqEmail;
    nCase.SuppliedEmail = this.reqEmail;
    //Case.GE_NAS_Ship_Date__c = this.shipDate;
    nCase.eLight_Requestor_Phone__c = this.reqPhone;
    nCase.Ship_Complete_Override__c = this.shpCmpltFlg;
    nCase.Order_Expected_Ship_Date__c = this.expShipDate;
    nCase.Order_Ship_From__c = this.shipDate;
    nCase.GE_NAS_Confirmation__c = this.newRow;
    nCase.AccountId = this.soldToAccount;
    if(this.disAccount != "DEFAULT"){
        nCase.Sold_To_Account__c = this.disAccount;
    }
    nCase.Type = 'Acct/Order Mgmnt';
    nCase.GE_NAS_Sub_Type__c = 'Expedite';
    nCase.Subject = 'Expedite Request' 
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
            console.log("Lines in the List: "+ linesList);
            console.log('Length of Lines List: '+JSON.stringify(linesList.length) );
            
            var j;
            for(j = 0; j < linesList.length; j++){
                console.log('Order Line Length' + this.storedLines.length);
                console.log('J = '+ j);
                let nCaseProduct = {'sobjecttype': 'Shipment_Detail__c'};
                console.log('Prod Line check' + this.storedLines.length);
                    nCaseProduct.GE_NAS_Case_Number__c = this.CaseNumber;
                    nCaseProduct.GE_NAS_Type_of_Problem1__c = 'Acct/Order Mgmnt';                                                
                    nCaseProduct.GE_NAS_Product_Code__c = linesList[j].Product_SKU__c;                    
                    nCaseProduct.Requested_Delivery_Date__c = linesList[j].New_Requested_Delivery_Date__c; 
                    nCaseProduct.Unique_ID__c = linesList[j].Transaction_ID__c;
                    nCaseProduct.Distributor_Name__c = linesList[j].Distributor_Name__c;
                    nCaseProduct.Distributor_ID__c = linesList[j].Distributor_Id__c;
                    nCaseProduct.Order_Qty__c = linesList[j].Quantity__c;
                    nCaseProduct.GE_NAS_Unit_of_Measure__c = linesList[j].UnitOfMeasure__c;                                  
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
            this.goToStepFour();
        }
    })
    .catch(error => {
        console.log(error);
        this.error = error;
        this.isSpinner = false;
    });
}


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

        this.sfdcOrgURL = window.location.href;
        if(this.sfdcOrgURL.includes('id=')==true){
        this.paramString = this.sfdcOrgURL.split('id=')[1]; 
        console.log("URL Check2:" + this.paramString);
        console.log("URL Check:" + this.sfdcOrgURL);
        if(this.paramString.length>0){
            console.log("Inside the Param call");
            this.orderFlag='Y';
            this.handleChangeNew();    
        }
        
        }
}

goBackToStepTwo() {
    
    this.currentStep = '2';

    this.template.querySelector('div.stepThree').classList.add('slds-hide');
    this.template
    
    .querySelector('div.stepTwo')
        .classList.remove('slds-hide');
        
}

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

    console.log('Requestor Name: '+this.reqName);
    this.reqName = this.template.querySelector(".rn").value;
    console.log('Requestor Email: '+this.reqEmail);
    this.reqEmail = this.template.querySelector(".em").value;
    console.log('Requestor Phone: '+this.reqPhone);
    this.reqPhone = this.template.querySelector(".rp").value;
    console.log('Reason for Expedite: '+this.expReason);
    this.expReason = this.template.querySelector(".pn").value;    
    console.log('New Ship Not Before Date: '+this.newShpNotBfrDt);
    this.newShpNotBfrDt = this.template.querySelector(".on").value;
    console.log('Ship Complete Flag: '+this.shpCmpltFlg);
    this.shpCmpltFlg = this.template.querySelector(".cb").value;

    console.log('Requested Date'+this.newShpNotBfrDt);
        if(this.shpCmpltFlg=='Yes' && this.shipCompFlg == 'Yes' &&  this.newShpNotBfrDt.length>0){           
            console.log('Data check for selectedorder inside '+ JSON.stringify(this.oItemList));
            var selectedNew = this.oItemList;
            
           console.log('Data check for entire order check: '+ JSON.stringify(selectedNew));
            var newselvals = selectedNew.map(row => { return { "Order_Product_Id__c" : this.currentRecordId,"UnitOfMeasure__c" : row.UnitOfMeasure__c, "Order_Line_Number__c": row.Order_Line_Number__c, "SKU__c": row.SKU__c, "Quantity__c": row.Quantity, "UnitPrice__c": row.UnitPrice,
            "PO__c":row.PO__c,"Requested_Delivery_Date__c":row.Requested_Delivery_Date__c,"Expected_Shipment_Date__c":row.Expected_Shipment_Date__c, "Type__c": "Expedite Request", "Product_SKU__c": row.SKU_Description_Cat_Logic__c,
            "Ship_From__c":row.Ship_From__c,"New_Requested_Delivery_Date__c":this.newShpNotBfrDt,
            "Order_Product_Id__c":row.Id, "Transaction_ID__c": this.transactionID+'_'+this.newShpNotBfrDt, "Unique_ID__c": this.transactionID+'_'+row.Order_Line_Number__c+'_'+row.SKU__c,"Distributor_Name__c":row.Distributor_Name__c,"Distributor_Id__c":this.orderLines }});

            
            console.log('value to pass check:' + JSON.stringify(newselvals));
          await  updateExpReturnItemList({data: newselvals})
            .then(result => {
                //this.storedLines = result;
                console.log(JSON.stringify("Apex update result: "+ result));
        });

           await getReturnList({transId : this.transactionID+'_'+this.newShpNotBfrDt})
                .then(result =>{
                    this.storedLines = result;
            });
       // }

        }

        if(this.shpCmpltFlg=='No' && this.shipCompFlg == 'No'){           
            console.log('Data check for selectedorder inside '+ JSON.stringify(this.oItemList));
            var selectedNew = this.oItemList;
           console.log('Data check for entire order check: '+ JSON.stringify(selectedNew));
            var newselvals = selectedNew.map(row => { return {"Order_Product_Id__c" : this.currentRecordId,"UnitOfMeasure__c" : row.UnitOfMeasure__c, "Order_Line_Number__c": row.Order_Line_Number__c, "SKU__c": row.SKU__c, "Quantity__c": row.Quantity, "UnitPrice__c": row.UnitPrice,
            "PO__c":row.PO__c,"Requested_Delivery_Date__c":row.Requested_Delivery_Date__c,"Expected_Shipment_Date__c":row.Expected_Shipment_Date__c, "Type__c": "Expedite Request", "Product_SKU__c": row.SKU_Description_Cat_Logic__c,
            "Ship_From__c":row.Ship_From__c,"New_Requested_Delivery_Date__c":this.newShpNotBfrDt,
            "Order_Product_Id__c":row.Id, "Transaction_ID__c": this.transactionID+'_'+this.newShpNotBfrDt, "Unique_ID__c": this.transactionID+'_'+row.Order_Line_Number__c+'_'+row.SKU__c,"Distributor_Name__c":row.Distributor_Name__c,"Distributor_Id__c":this.orderLines }});

            
            console.log('value to pass check:' + JSON.stringify(newselvals));
          await  updateExpReturnItemList({data: newselvals})
            .then(result => {
                //this.storedLines = result;
                console.log(JSON.stringify("Apex update result: "+ result));
        });

           await getReturnList({transId : this.transactionID+'_'+this.newShpNotBfrDt})
                .then(result =>{
                    this.storedLines = result;
            });

        }

        if(this.shpCmpltFlg=='Yes' && this.shipCompFlg == 'No'){           
            console.log('Data check for selectedorder inside '+ JSON.stringify(this.oItemList));
            var selectedNew = this.oItemList;
            
           console.log('Data check for entire order check: '+ JSON.stringify(selectedNew));
            var newselvals = selectedNew.map(row => { return { "Order_Product_Id__c" : this.currentRecordId,"UnitOfMeasure__c" : row.UnitOfMeasure__c, "Order_Line_Number__c": row.Order_Line_Number__c, "SKU__c": row.SKU__c, "Quantity__c": row.Quantity, "UnitPrice__c": row.UnitPrice,
            "PO__c":row.PO__c,"Requested_Delivery_Date__c":row.Requested_Delivery_Date__c,"Expected_Shipment_Date__c":row.Expected_Shipment_Date__c, "Type__c": "Expedite Request", "Product_SKU__c": row.SKU_Description_Cat_Logic__c,
            "Ship_From__c":row.Ship_From__c,"New_Requested_Delivery_Date__c":this.newShpNotBfrDt,
            "Order_Product_Id__c":row.Id, "Transaction_ID__c": this.transactionID+'_'+this.newShpNotBfrDt, "Unique_ID__c": this.transactionID+'_'+row.Order_Line_Number__c+'_'+row.SKU__c,"Distributor_Name__c":row.Distributor_Name__c,"Distributor_Id__c":this.orderLines }});

            
            console.log('value to pass check:' + JSON.stringify(newselvals));
          await  updateExpReturnItemList({data: newselvals})
            .then(result => {
                //this.storedLines = result;
                console.log(JSON.stringify("Apex update result: "+ result));
        });

           await getReturnList({transId : this.transactionID+'_'+this.newShpNotBfrDt})
                .then(result =>{
                    this.storedLines = result;
            });
       // }

        }
}

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

//VALIDATION FOR REQUIRED FIELDS

handleValidation(){

    let acctName = this.template.querySelector('.rn').value;
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
// FOR VALIDATION IN REQUIRED FIELDS
handleValid(){






    let expReas = this.template.querySelector(".pn").value;    
    //let reqDate = this.template.querySelector(".on").value;
    //let shpFlg = this.template.querySelector(".cb").value;
    console.log('Field Required: '+this.isYes);
    this.shpCmpltFlg = this.template.querySelector(".cb").value;
    console.log("this.shipCompFlg" +this.shipCompFlg);
    console.log("this.shpCmpltFlg" +this.shpCmpltFlg);
    //console.log("shpFlg" + shpFlg);
    if (!expReas || this.shpCmpltFlg.length==0){
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'ERROR',
                message: 'Please fill out all Required Fields',
                variant: 'error'
            })
        );
    }
   
    // IF THE SHIP COMPLETE DROPDOWN == YES
    else if(this.isYes == true){
        console.log('VALIDATION 1: PASS');
        const allValid = [...this.template.querySelectorAll('.validVal')]
        .reduce((validSoFar, inputCmp) => {
                    inputCmp.reportValidity();
                    return validSoFar && inputCmp.checkValidity();
        }, true);
        console.log("Value check for all Valid Val values:"+allValid)
            if (allValid) {
                this.stepOneButton = false;
                this.goToStepThree();
            } else {
                console.log('VALIDATION 1: FAIL');
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'ERROR',
                        message: 'Please fill out all Required Fields',
                        variant: 'error'
                    })
                );
            }
    }

    // IF THE SHIP COMPLETE DROP DOWN == NO
    else if(this.isYes == false) {
        console.log('VALIDATION 2: PASS');
        const allValid = [...this.template.querySelectorAll('.validValue')]
        .reduce((validSoFar, inputCmp) => {
                    inputCmp.reportValidity();
                    return validSoFar && inputCmp.checkValidity();
        }, true);
        console.log("Value check for all Valid Val values:"+allValid)
            if (allValid) {
                this.stepOneButton = false;
                this.goToStepThree();
            } else {
                console.log('VALIDATION 2: FAIL');
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'ERROR',
                        message: 'Please fill out all Required Fields',
                        variant: 'error'
                    })
                );
            }
    } 
    /*else if( this.shipCompFlg == 'No' && this.shpCmpltFlg =='Yes'){
        console.log('VALIDATION 3: PASS');
        const allValid = [...this.template.querySelectorAll('.validVal')]
        .reduce((validSoFar, inputCmp) => {
                    inputCmp.reportValidity();
                    return validSoFar && inputCmp.checkValidity();
        }, true);
        console.log("Value check for all Valid Val values:"+allValid)
            if (allValid) {
                this.stepOneButton = false;
                this.goToStepThree();
            } else {
                console.log('VALIDATION 3: FAIL');
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'ERROR',
                        message: 'Please fill out all Required Fields',
                        variant: 'error'
                    })
                );
            }
    }*/

   else if(this.shipCompFlg == 'No' && this.shpCmpltFlg =='No') {
        console.log('VALIDATION 4: PASS');
        const allValid = [...this.template.querySelectorAll('.validValue')]
        .reduce((validSoFar, inputCmp) => {
                    inputCmp.reportValidity();
                    return validSoFar && inputCmp.checkValidity();
        }, true);
        console.log("Value check for all Valid Val values:"+allValid)
            if (allValid) {
                this.stepOneButton = false;
                this.goToStepThree();
            } else {
                console.log('VALIDATION 4: FAIL');
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