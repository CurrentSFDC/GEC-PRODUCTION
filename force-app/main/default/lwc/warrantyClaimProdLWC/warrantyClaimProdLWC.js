import { LightningElement, track, wire, api } from 'lwc';
import getOrderItemList from '@salesforce/apex/OrderProductController.getOrderItemList';
import getOrderItemRefList from '@salesforce/apex/OrderProductController.getOrderItemRefList';
import updateOrderItemList from '@salesforce/apex/OrderProductController.updateOrderItemList';
import NAME_FIELD from '@salesforce/schema/User.Name';
import USER_ID from '@salesforce/user/Id';
import { getRecord } from 'lightning/uiRecordApi';

//--- CLASSES USED FOR MANUAL PRODUCT ENTRY ----
import createReturnItem from '@salesforce/apex/ReturnOrderItemController.createReturnOrderItems';
import updReturnOrderItems from '@salesforce/apex/ReturnOrderItemController.updReturnOrderItems';
import getMaterialDes from '@salesforce/apex/ReturnOrderItemController.getMaterial';
import getReturnList from '@salesforce/apex/OrderProductController.getReturnList';
import deleteReturnItemList from '@salesforce/apex/OrderProductController.delReturnItems';
// - END CLASSES USED FOR MANUAL PRODUCT ENTRY

import { refreshApex } from '@salesforce/apex';
import { updateRecord , deleteRecord } from 'lightning/uiRecordApi';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import orderListData from '@salesforce/apex/OrderProductController.orderListData';
//import updateOrderItemList from '@salesforce/apex/OrderProductController.updateOrderItemList';
import updateReturnItemList from '@salesforce/apex/OrderProductController.updateReturnItemList';
//import { getOrderId} from 'lightning/uiRecordApi';
import {FlowNavigationNextEvent} from 'lightning/flowSupport';
import updDisName from '@salesforce/apex/OrderProductController.updDisName';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import DISPUTED_QTY_FIELD from '@salesforce/schema/OrderItem.Disputed_Qty__c';
import QUANTITY_FIELD from '@salesforce/schema/OrderItem.Quantity';
import REQUESTED_ACTION_OVERRIDE_FIELD_FIELD from '@salesforce/schema/OrderItem.Requested_Action_Override__c';
import ID_FIELD from '@salesforce/schema/OrderItem.Id';

const actions = [
    { label: 'Delete', name: 'delete' },
    { label: 'Edit', name: 'edit' },
];



export default class WarrantClaimProdLWC extends LightningElement(FlowNavigationNextEvent) {
    // COLUMNS FOR ORDER LINE ITEM SELECTION SCREEN
@track columns = [{
        label: 'Catalog #',
        fieldName: 'SKU_Description_Cat_Logic__c',
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
        label: 'PO #',
        fieldName: 'PO__c',
        type: 'Text',
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
        label: 'Qty',
        fieldName: 'Quantity',
        iconName: 'utility:number_input',
        type: 'number',
        sortable: true
    },
    {
        label: 'Shipment Date',
        fieldName: 'Shipment_Date__c',
        iconName: 'utility:date_input',
        type: 'date',
        sortable: true,
        cellAttributes: { alignment: 'center' }
    },
    {
        label: 'Date Installed',
        fieldName: 'Date_Installed__c',
        iconName: 'utility:date_input',
        type: 'date',
        sortable: true,
        cellAttributes: { alignment: 'center' }
    },
    {
        label: 'Installed',
        fieldName: 'Installed_Qty__c',
        iconName: 'utility:number_input',
        type: 'number',
        sortable: true,
        cellAttributes: { alignment: 'center' }
    },
    {
        label: 'Failed',
        fieldName: 'No_Of_Products_Failed__c',
        iconName: 'utility:number_input',
        type: 'number',
        sortable: true,
        cellAttributes: { alignment: 'center' }
    },

    {
        label: 'Action Override',
        fieldName: 'Requested_Action_Override__c',
        iconName: 'utility:button_choice',
        type: 'Text',
        cellAttributes: { alignment: 'center' },
        sortable: true,
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
    },

    ]; 
    //--------END COLUMNS FOR ORDER LINE ITEM SELECTION SCREEN

    
    // COLUMNS FOR THE VIEW CART MODAL --------
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
                label: 'NoCAT #',
                fieldName: 'NoCAT__c',
                type: 'Text',
                sortable: true,
                cellAttributes: { alignment: 'center' }
            },
            {
                label: 'PO #',
                fieldName: 'PO__c',
                type: 'Text',
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
                label: 'Qty',
                fieldName: 'Quantity',
                iconName: 'utility:number_input',
                type: 'number',
                sortable: true
            },
            {
                label: 'Shipment Date',
                fieldName: 'Shipment_Date__c',
                iconName: 'utility:date_input',
                type: 'date',
                sortable: true,
                cellAttributes: { alignment: 'center' }
            },
            {
                label: 'Date Installed',
                fieldName: 'Date_Installed__c',
                iconName: 'utility:date_input',
                type: 'date',
                sortable: true,
                cellAttributes: { alignment: 'center' }
            },
            {
                label: 'Installed',
                fieldName: 'Installed_Qty__c',
                iconName: 'utility:number_input',
                type: 'number',
                sortable: true,
                cellAttributes: { alignment: 'center' }
            },
            {
                label: 'Failed',
                fieldName: 'No_Of_Products_Failed__c',
                iconName: 'utility:number_input',
                type: 'number',
                sortable: true,
                cellAttributes: { alignment: 'center' }
            },
        
            {
                label: 'Action Override',
                fieldName: 'Requested_Action_Override__c',
                iconName: 'utility:button_choice',
                type: 'Text',
                cellAttributes: { alignment: 'center' },
                sortable: true,
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
                                   
                },
                
            },
            ]; 
    //--------END COLUMNS FOR THE VIEW CART MODAL -------



    get warOptions() {
        return [
            { label: 'Control', value: 'Control' },
            { label: 'Electrical', value: 'Electrical' },
            { label: 'Light Output', value: 'Light Output' },
            { label: 'Mechanical', value: 'Mechanical' },
            { label: 'Packaging', value: 'Packaging' },
            { label: 'Safety', value: 'Safety' },
        ];
    }

    @track warSubOptionsControl =
        [
            { label: 'Dimming Issue', value: 'Dimming Issue' },
            { label: 'Network Connection Error', value: 'Network Connection Error'},
            { label: 'Sensor Failure', value: 'Sensor Failure' },
        ];
    

    @track warSubOptionsElectrical =
        [
            { label: 'Connector Failure', value: 'Connector Failure' },
            { label: 'Failed Driver', value: 'Failed Driver' },
            { label: 'Failed on Initial Energize', value: 'Failed on Initial Energize' },
            { label: 'Inoperative', value: 'Inoperative' },
            { label: 'Intermittent Operation', value: 'Intermittent Operation' },
            { label: 'LED Failure', value: 'LED Failure' },
            { label: 'Pinched Wire', value: 'Pinched Wire' },
            { label: 'Surge Protector Failed', value: 'Surge Protector Failed' },
            { label: 'Transformer Failure', value: 'Transformer Failure' },
            { label: 'Wiring Error', value: 'Wiring Error' },
        ];
    

    @track warSubOptionsLightOutput =
        [
            { label: 'Color Objection', value: 'Color Objection' },
            { label: 'Color Shift', value: 'Color Shift'},
            { label: 'Flicker', value: 'Flicker' },
            { label: 'Low Light Levels', value: 'Low Light Levels' },
        ];
    

    @track warSubOptionsMechanical =
        [
            { label: 'Assembly Defect', value: 'Color Objection' },
            { label: 'Component - Missing', value: 'Component - Missing'},
            { label: 'Component - Loose', value: 'Component - Loose' },
            { label: 'Finish/Paint Issue', value: 'Finish/Paint Issue' },
            { label: 'Lens/Diffuser - Loose', value: 'Lens/Diffuser - Loose' },
            { label: 'Other Cosmetic Issue', value: 'Other Cosmetic Issue' },
            { label: 'Water Entry', value: 'Water Entry' },
        ];

    @track warSubOptionsPackaging =
        [
            { label: 'Label Incorrect', value: 'Label Incorrect' },
            { label: 'Packaging Quality', value: 'Packaging Quality'},
            { label: 'Wrong Part in Carton', value: 'Wrong Part in Carton' },
        ];

    @track warSubOptionsSafety =
        [
            { label: 'Burnt/Overheated', value: 'Burnt/Overheated' },
            { label: 'Fallen Component/Fixture', value: ''},
            { label: 'Shock', value: 'Wrong Part in Carton' },
        ];

    @track searchOrders = true;
    @track failedQty;
    @track errorMessage = '';
     @track rowQuantity;
     @track cartLabel; 
     @track editLabel;   
     @api cartCount = 0;
     @api transactionID;

     @track reqAction;
     @track numFailed;
     @track numInstalled;
     @track dateInstalled;
     @track PO;
     @track shipmentDate;
     @track hoursUsed;
     @track hoursPerStart
     @track comments;
     @track warSubOptions;
     @track warrantyReason;
     @track priceAgrmtPrice;

     @track materialID;
     @track materialDescription;
     @track bShowModal = false;
     @track bShowModal1 = false;
     @track paPrice = false;
     @track currentRecordId;
     @track isEditForm = false;
     @api storedLines=[];
     @api recordId;
     @api getorder;
     @track warrantyEntry = false;
     @track isWarranty = false;
     @track isOrderIdAvailable = false;
     @track flagIndi = false;
     @track searchLabel = "Search Orders";
     //@track orderId='';
     draftValues = [];
     @track error;
     @track orderItemList;
     @track orderItemNewList;
     @api selectedOrder;
     @api valuetopass;
     @track manualLines = [];
     @track paramString;
     @api agentNumber;
     @api showDistroField=false;
     @track distLines;
     @track distAccName;
     @api soldToAccount;
     @track disAccount;
     @track disName=[];

     @track noCatModal = false;
     @track NoCAT = " ";
     @track isLoading = false;
     @track noCatInput = false;

     get RAoptions() {
        return [
            { label: 'Credit', value: 'Credit' },
            { label: 'Replacement', value: 'Replacement' },
            { label: 'Analysis Only', value: 'Analysis Only' },
        ];
    }
     //@api value1; //using this field to pass on the review page


        @api returnID;


        @wire(getRecord, {
            recordId: USER_ID,
            fields: [NAME_FIELD]
        }) wireuser({
            error,
            data
        }) {
            if (error) {
            this.error = error ; 
            } else if (data) {
                this.reqName = data.fields.Name.value;
    
                console.log("Param Check Outside" + this.paramString);
    
                
                if(this.paramString.length>0){
                console.log("Param String Check" +this.paramString);
    
                var inputord=this.paramString;
                this.template.querySelector("c-order-search-custom").setConfirmValues(inputord);
                }
                  
                
            }
        }

    

    connectedCallback(){
        /*const id = 'id' + performance.now();
        this.transactionID = id;
        console.log('Generated ID: '+ id);*/

        //Code change for order id default
        this.sfdcOrgURL = window.location.href;
        if(this.sfdcOrgURL.includes('id=')==true){
            this.paramString = this.sfdcOrgURL.split('id=')[1];
            if(this.paramString.length > 0){
                this.handleChangeNew();
            } 
        }
    } 

    cartActions(event){
        const actionName = event.detail.action.name;
        const row = event.detail.row;

        console.log('Delete ActionName: '+ actionName);
        console.log('Delete Row: '+ JSON.stringify(row));
        switch (actionName) {
            case 'delete':
                this.deleteCurrentRecord(row);
                break;
            default:
        }
   }

   deleteCurrentRecord(currentRow){
       var currentRecordId = currentRow.Id;
       deleteRecord (currentRecordId)
        .then(() => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Line has been deleted from the cart',
                    variant: 'success'
                })
            );
                    this.fetchReturnItems();
        })
   }

handleValueChange(e){
    this.errorMessage = '';
    this.numInstalled = e.detail.value;
}

handleFailedValueChange(e){
    this.errorMessage = '';
    var failed = e.detail.value;
    if (failed < 10){
        this.numFailed = "0"+failed;
    } else{
    this.numFailed = failed;
    }
    console.log('Failed Converted: '+this.numFailed);
}

    confirmchange(event){
        this.distLines = event.detail.selectedRecordId;
        this.distAccName=event.detail.selectedValue;
        console.log('The lines passed to child for Ordering: '+this.distLines);
        this.disAccount = this.distLines;
        if(this.distAccName==null){
            this.disName=[];
        }
        else{
        this.disName = this.distAccName;
        }
        console.log('The lines passed to child for Delivery: '+this.disAccount);
        console.log('The lines passed to child for Delivery: '+this.disName);
    
    }


    handleRAction(event){
        this.actionReason = event.target.value;
        console.log('Action Reason :' +this.actionReason)
        if(this.actionReason == "Credit"){   
            this.paPrice = true;         
        } else {
            this.paPrice = false;
        }
    }

    handlePick(event){
        this.warrantyReason = event.target.value;
        console.log('Warranty Reason :' +this.warrantyReason)
        if(this.warrantyReason == "Control"){   
            console.log('warSubOptions: ')  ;
            this.warSubOptions=this.warSubOptionsControl;  
            console.log('warSubOptions After: ' + this.warSubOptions)  ;         
        }
        else if(this.warrantyReason == "Electrical"){   
            console.log('warSubOptions: ')  ;
            this.warSubOptions=this.warSubOptionsElectrical;  
            console.log('warSubOptions After: ' + this.warSubOptions)  ;         
        }
        else if(this.warrantyReason == "Light Output"){   
            console.log('warSubOptions: ')  ;
            this.warSubOptions=this.warSubOptionsLightOutput;  
            console.log('warSubOptions After: ' + this.warSubOptions)  ;         
        }
        else if(this.warrantyReason == "Mechanical"){   
            console.log('warSubOptions: ')  ;
            this.warSubOptions=this.warSubOptionsMechanical;  
            console.log('warSubOptions After: ' + this.warSubOptions)  ;         
        }
        else if(this.warrantyReason == "Packaging"){   
            console.log('warSubOptions: ')  ;
            this.warSubOptions=this.warSubOptionsPackaging;  
            console.log('warSubOptions After: ' + this.warSubOptions)  ;         
        }
        else{
            this.warSubOptions=this.warSubOptionsSafety;  
        }
    }


   handleRowActions(event) {
    
    const actionName = event.detail.action.name;
    const row = event.detail.row;
    
    let rowQuantityValue = event.detail.row.Quantity;
    console.log('The Row Quantity: '+rowQuantityValue);

    this.rowQuantity = rowQuantityValue;
    console.log('Row QTY Set: '+this.rowQuantity);

    console.log('Delete ActionName: '+ actionName);
    console.log('Delete Row: '+ JSON.stringify(row));
    switch (actionName) {
        case 'edit':
            this.editCurrentRecord(row);
            break;
        case 'delete':
            this.deleteManualRow(row);
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
    this.errorMessage = "";
    this.bShowModal1 = true;
    this.isEditForm = true;
    if(currentRow.Installed_Qty__c > 0){
        this.editLabel = "Update"
    } else {
        this.editLabel = "Add to Claim"
    }

    // assign record id to the record edit form
    this.currentRecordId = currentRow.Id;
    this.reqAction = currentRow.Requested_Action_Override__c;
    this.numInstalled = currentRow.Installed_Qty__c;
        console.log('Row Installed Qty: '+this.numInstalled);
    this.numFailed = currentRow.No_Of_Products_Failed__c;
        console.log('Row Number Failed: '+this.numFailed);
    /*this.hoursUsed = currentRow.No_of_Hours_Used__c;
        console.log('Row Hours Used: '+this.hoursUsed);
    this.hoursPerStart = currentRow.Hours_per_Start__c;
        console.log('Row Hours Per Start: '+this.hoursPerStart);*/
    this.dateInstalled = currentRow.Date_Installed__c;
        console.log('Row Date Installed: '+this.dateInstalled);
    this.comments = currentRow.Comments__c;
        console.log('Row Comments: '+this.comments);
    this.warCode = currentRow.Warranty_Code__c;
        console.log('Row Warranty Code: '+this.warCode);
    this.warSubCode = currentRow.Warranty_Sub_Code__c;
        console.log('Row Warranty Sub Code: '+this.warSubCode);
    /*this.priceAgrmtPrice = currentRow.Price_Agreement_Price__c;
        console.log('Row Price Agreement Price: '+this.priceAgrmtPrice);*/

}


 // handleing record edit form submit
 handleSubmit(event) {
    console.log('HANDLE SUBMIT FUNCTION EXECUTED...');
    this.isLoading = true;
    //this.numFailed = this.template.querySelector('.nf').value;
        //console.log('Number Failed: '+this.numFailed);
    this.numInstalled = this.template.querySelector('.iq').value;
        console.log('Number Installed: '+this.numInstalled);
    /*this.hoursUsed = this.template.querySelector('.hu').value;
        console.log('Hours Used: '+this.hoursUsed);
    this.hoursPerStart = this.template.querySelector('.hs').value;
        console.log('Hours Per Start: '+this.hoursPerStart);*/
    this.dateInstalled = this.template.querySelector('.di').value;
        console.log('Date Installed'+this.dateInstalled);
    this.comments = this.template.querySelector('.cm').value;
        console.log('Comments: '+this.comments);
    this.warCode = this.template.querySelector('.wc').value;
        console.log('Warranty Code: '+this.warCode);
    this.warSubCode = this.template.querySelector('.wsc').value;
        console.log('Warranty Sub Code: '+this.warSubCode);
    this.reqAction = this.template.querySelector('.ra').value;
        console.log('Requested Action: '+this.reqAction);
    /*this.priceAgrmtPrice = this.template.querySelector('.pa').value;
        console.log('Price Agreement Price: '+this.priceAgrmtPrice);*/

    
    
    let installedQty = this.numInstalled;
    console.log('Installed Qty Entered: '+installedQty);
    let failedQty = this.numFailed;
    console.log('Failed Qty Entered: '+failedQty);
    console.log('Quantity Imported: '+this.rowQuantity);
   if (failedQty > this.rowQuantity){
    this.isLoading = false;
       this.errorMessage = "ERROR: Number of Failed Products cannot be greater than Order Quantity";
       console.log('Error: '+this.errorMessage);
       this.cartLabel = "Add to Claim";
       event.preventDefault();
       //this.ShowToastMsg('# of Filed Products cannot be greater than Installed Qty');
   }else if (failedQty > installedQty){
    this.isLoading = false;
    this.errorMessage = "ERROR: Number of Failed Products cannot be greater than Installed Quantity";
    console.log('Error: '+this.errorMessage);
    this.cartLabel = "Add to Claim";
    event.preventDefault();
    //this.ShowToastMsg('# of Filed Products cannot be greater than Installed Qty');
    } else if(installedQty > this.rowQuantity){
        this.isLoading = false;
        this.errorMessage = "ERROR: Installed Quantity cannot be greater than Order Quantity";
        console.log('Error: '+this.errorMessage);
        this.cartLabel = "Add to Claim";
        event.preventDefault();
   }else {
    this.errorMessage = "";
    console.log('No Errors in Form');
    this.cartLabel = "Adding to Claim...";
    // prevending default type sumbit of record edit form
    //event.preventDefault();

    // querying the record edit form and submiting fields to form
    console.log('Inbuilt Form Data Check: ' + JSON.stringify(event.detail.fields));
    const fields = event.detail.fields;
    fields.No_Of_Products_Failed__c= this.numFailed;
    fields.Installed_Qty__c = this.numInstalled;
    //fields.No_of_Hours_Used__c = this.hoursUsed;
    //fields.Hours_per_Start__c = this.hoursPerStart;
    fields.Date_Installed__c = this.dateInstalled;
    fields.Comments__c = this.comments;
    fields.Warranty_Code__c = this.warCode;
    fields.Warranty_Sub_Code__c = this.warSubCode;
    fields.Requested_Action_Override__c= this.reqAction;
    //fields.Price_Agreement_Price__c = this.priceAgrmtPrice;
    fields.Id=this.currentRecordId;
    this.template.querySelector('lightning-record-edit-form').submit(fields);
    console.log('After Form Update Data Check: ' + JSON.stringify(event.detail.fields));
   }
}
 
 

// refreshing the datatable after record edit form success
async handleSuccess() {
    console.log('HANDLE SUCCESS FUNCTION EXECUTED...');
    //let reqOver = this.template.querySelector('.dm').value;
    console.log('Success for Requested Action: '+this.reqAction);
    let nOrderDtl= {'sobjectType': 'OrderItem'};
    nOrderDtl.Id = this.currentRecordId;
    nOrderDtl.Requested_Action_Override__c=this.reqAction;
    nOrderDtl.No_Of_Products_Failed__c = this.numFailed;
    nOrderDtl.Installed_Qty__c = this.numInstalled;
    //nOrderDtl.No_of_Hours_Used__c = this.hoursUsed;
    //nOrderDtl.Hours_per_Start__c = this.hoursPerStart;
    nOrderDtl.Date_Installed__c = this.dateInstalled;
    nOrderDtl.Comments__c = this.comments;
    nOrderDtl.Warranty_Code__c = this.warCode;
    nOrderDtl.Warranty_Sub_Code__c = this.warSubCode;
    //nOrderDtl.Price_Agreement_Price__c = this.priceAgrmtPrice;
    await updateOrderItemList({data: nOrderDtl})
    .then(result => {
        this.returnID = result;
    });
   await getOrderItemRefList({orderId: this.selectedOrder}) 
           .then(result => {
               this.orderItemList = result;
               console.log(result);
               console.log('After refresh datatable data: ' + JSON.stringify(this.orderItemList));
               //this.ShowToastMsg('Success', 'Order Details Updated')
                // closing modal
                this.bShowModal1 = false;
           });
       this.handleClick(); 
}



    async handleChange(event) {
        this.warrantyEntry = false;
        //console.log("You selected an order: " + event.detail.value[0]);
        //this.selectedOrder = event.detail.value[0];
        //console.log("Type of" +typeof(selectedOrder));
        this.selectedOrder =  event.detail.selectedRecordId;

        console.log("You selected Order: " + this.selectedOrder);

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
            console.log(JSON.stringify("The Result from APEX is: "+ JSON.stringify(this.orderItemList)));
            this.isOrderIdAvailable = true;
           
            //this.error = undefined;          
    
        }).catch(error => {
            console.log("The error SENT TO APEX is: " +JSON.stringify(error));
            this.error = error;
            //this.data  = undefined;
        });
        
        //this.template.querySelector('c-confirmation-details').displayValues(this.selectedOrder);
    } 

    async handleChangeNew(event) {
        this.warrantyEntry = false;
        this.selectedOrder = this.paramString;
        //console.log("Type of" +typeof(selectedOrder));

        

        await getOrderItemList({orderId: this.selectedOrder})
        .then(result => {
            console.log(JSON.stringify("The Result from APEX is: "+ JSON.stringify(result)));
            this.orderItemList  = result;
            console.log(JSON.stringify("The Result from APEX is: "+ JSON.stringify(this.orderItemList)));
            this.isOrderIdAvailable = true;
           
            //this.error = undefined;          
    
        }).catch(error => {
            console.log("The error SENT TO APEX is: " +JSON.stringify(error));
            this.error = error;
            //this.data  = undefined;
        });
        
        //this.template.querySelector('c-confirmation-details').displayValues(this.selectedOrder);
    } 




     //Save button action code 
     /*async handleSave(event) {
        const updatedFields = event.detail.draftValues;
        
        // Prepare the record IDs for getRecordNotifyChange()
        const notifyChangeIds = updatedFields.map(row => { return { "recordId": row.Id } });
    
       // Pass edited fields to the updateOrder details Apex controller
        await updateOrderItemList({data: updatedFields})
        .then(result => {
            console.log(JSON.stringify("Apex update result: "+ result));
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Order updated',
                    variant: 'success'
                })
            );
    
        // Refresh LDS cache and wires
        getRecordNotifyChange(notifyChangeIds);
    
        // Display fresh data in the datatable
        refreshApex(this.orderitem).then(() => {
            // Clear all draft values in the datatable
            this.draftValues = [];
          });
    
        
       }).catch(error => {
           this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error updating or refreshing records',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        });
    }*/

    //Selection of records code

    /*handleSelect( event ) {

        const selRows = event.detail.selectedRows;
        console.log( 'Selected Rows are ' + JSON.stringify ( selRows ) );
      
        this.selectedRows = selRows;

    }*/


    handleSave(event){
        console.log(event.detail.draftValues)
        const recordInputs = event.detail.draftValues.slice().map(draft=>{
            const fields = Object.assign({}, draft)
            return {fields}
        })
        console.log("recordInputs", recordInputs)

        const promises = recordInputs.map(recordInput => updateRecord(recordInput))
        Promise.all(promises).then(result=>{
            this.ShowToastMsg('Success', 'Order Details Updated')
           this.draftValues=[];   
           console.log('Before Refresh: '+ JSON.stringify(this.orderItemList));
           console.log('Check for Refresh: '+ this.selectedOrder);
           //return refreshApex(this.orderItemList);

           getOrderItemRefList({orderId: this.selectedOrder}) 
           .then(result => {
               this.orderItemList = result;
               console.log(result);
               console.log('After refresh datatable data: ' + JSON.stringify(this.orderItemList));
           });
           
          

        }).catch(error=>{
            this.ShowToastMsg('Error Updating Records', error.body.message, error)
        });
        //this.handleClick();
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
        console.log('HANDLE CLICK FUNCTION EXECUTED....');
        //const updatedFields = event.detail.draftValues;

        await orderListData({transId: this.currentRecordId}) 
           .then(result => {
               this.orderItemNewList = result;
               console.log(result);
               console.log('After refresh datatable data: ' + JSON.stringify(this.orderItemNewList));
           });
       
        //var selRows = this.template.querySelector('lightning-datatable');
        var selected = this.orderItemNewList;
        console.log('Values for EDIT: '+ JSON.stringify(selected));
        //this.storedLines = selected;
        console.log('Stored Lines: '+ JSON.stringify(this.storedLines));
        var newselval = selected.map(row => { return { "order__c":row.OrderId,"SKU__c": row.SKU__c, "Product_SKU__c":row.SKU_Description_Cat_Logic__c,"PO__c": row.PO__c, "Quantity__c": row.Quantity, "UnitPrice__c": row.UnitPrice,
            "Product_Name__c":row.Product_Name__c,"Quick_Configure__c":row.Quick_Configure__c,"Quick_Stock__c":row.Quick_Stock__c, "Type__c": "Warranty",
            "Shipment_Date__c":row.Shipment_Date__c,"Installed_Qty__c": row.Installed_Qty__c,"No_Of_Products_Failed__c": row.No_Of_Products_Failed__c,"Date_Installed__c": row.Date_Installed__c,
            "Requested_Action_Override__c":row.Requested_Action_Override__c,"Order_Product_Id__c":row.Id, "Transaction_ID__c": this.transactionID, "Warranty_Code__c":row.Warranty_Code__c, "Warranty_Sub_Code__c":row.Warranty_Sub_Code__c, "No_of_Hours_Used__c":row.No_of_Hours_Used__c, "Hours_per_Start__c":row.Hours_per_Start__c, 
            "Price_Agreement_Price__c":row.Price_Agreement_Price__c, "Comments__c":row.Comments__c,"Unique_ID__c": this.transactionID+'_'+row.SKU__c,"Distributor_Name__c":row.Distributor_Name__c}});

        
        
        this.valuetopass = selected;
        console.log('value to pass check:' + JSON.stringify(this.valuetopass));
        
        console.log('value to pass check:' + JSON.stringify(newselval));
        await updateReturnItemList({data: newselval})
        .then(result => {
            
            console.log(JSON.stringify("Apex update result: "+ result));
            this.flagIndi= true;
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

     deleteManualRow(row) {

        console.log('value getting passed for deletion: '+ JSON.stringify(row));
        var selRow = [row];
        for (var i =0; i< selRow.length ;i++) {
            console.log(selRow[i].Transaction_ID__c);
            var newRow = selRow[i].Transaction_ID__c;
         }
        console.log('value getting passed for deletion: '+ JSON.stringify(selRow));
        console.log('New Value Passed for Trax ID: '+ newRow);
        deleteReturnItemList({data: selRow})
        .then(result => {
            
            console.log(JSON.stringify("Apex update result: "+ result));
    
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Selected record has been deleted successfully',
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
                this.isLoading = false;
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

    setManualLines(event){
        this.manualLines = event.detail.manuallines;
        console.log("Manual Lines Sending to Parent: "+JSON.stringify(this.manualLines));
        this.dispatchEvent(
            new CustomEvent('lineupdate', {
                detail: {
                    lines : this.manualLines
                }
            }));

    }

    showOrder(event){
         this.warrantyEntry = false;
         this.searchOrders = true;
         this.searchLabel = "Search Orders";
         
    
     }


    showWarranty(event){
        this.warrantyEntry = true;
        this.isOrderIdAvailable = false;
        this.searchOrders = false;
        this.searchLabel = "Manual Entry";
    } 

    showCart(event) {
        this.bShowModal = true; // display modal window
    }

    // to close modal window set 'bShowModal' tarck value as false
    closeModal() {
        this.bShowModal = false;
        /*getOrderItemList({orderId: this.selectedOrder})
        .then(result => {
            console.log(JSON.stringify("The Result from APEX is: "+ JSON.stringify(result)));
            this.orderItemList  = result;
            console.log(JSON.stringify("The Result from APEX is: "+ JSON.stringify(this.orderItemList)));
            this.isOrderIdAvailable = true;
           
            //this.error = undefined;          
    
        }).catch(error => {
            console.log("The error SENT TO APEX is: " +JSON.stringify(error));
            this.error = error;
            //this.data  = undefined;
        }); */
    } 

    // POTENTIAL FUTURE - SAVE CART FUNCTION
    saveCart(){
        localStorage.setItem('localStr',JSON.stringify(this.storedLines));
        var retrieveData = JSON.parse(localStorage.getItem('localStr'));
        console.log('Data in Saved Cart: '+JSON.stringify(retrieveData));
    }


    //-----------------------------------------------------------------------------------------------------------------------
    //------- MANUAL PRODUCT ENTRY FUNCTIONS -------

    handleManualRAction(event){
        this.actionReason = event.target.value;
        console.log('Action Reason :' +this.actionReason)
        if(this.actionReason == "Credit"){   
            this.paPrice = true;         
        } else {
            this.paPrice = false;
        }
    }
    
    handleManualPick(event){
        this.warrantyReason = event.target.value;
        console.log('Warranty Reason :' +this.warrantyReason)
        if(this.warrantyReason == "Control"){   
            console.log('warSubOptions: ')  ;
            this.warSubOptions=this.warSubOptionsControl;  
            console.log('warSubOptions After: ' + this.warSubOptions)  ;         
        }
        else if(this.warrantyReason == "Electrical"){   
            console.log('warSubOptions: ')  ;
            this.warSubOptions=this.warSubOptionsElectrical;  
            console.log('warSubOptions After: ' + this.warSubOptions)  ;         
        }
        else if(this.warrantyReason == "Light Output"){   
            console.log('warSubOptions: ')  ;
            this.warSubOptions=this.warSubOptionsLightOutput;  
            console.log('warSubOptions After: ' + this.warSubOptions)  ;         
        }
        else if(this.warrantyReason == "Mechanical"){   
            console.log('warSubOptions: ')  ;
            this.warSubOptions=this.warSubOptionsMechanical;  
            console.log('warSubOptions After: ' + this.warSubOptions)  ;         
        }
        else if(this.warrantyReason == "Packaging"){   
            console.log('warSubOptions: ')  ;
            this.warSubOptions=this.warSubOptionsPackaging;  
            console.log('warSubOptions After: ' + this.warSubOptions)  ;         
        }
        else{
            this.warSubOptions=this.warSubOptionsSafety;  
        }
    }

    openNoCatModal(){
        this.addLabel = "Add to Claim";
        this.noCatModal = true;
        this.noCatInput = false;
        this.value = '';
        this.numInstalled = null;
        this.numFailed = null;
        this.PO = '';
        this.shipmentDate = '';
        this.materialID = '';
        this.NoCAT = '';
    }

 
    onNoCatChange(){
        this.NoCAT = this.template.querySelector(".nc").value;
    }

    onPaPriceChange(){
        this.priceAgrmtPrice = this.template.querySelector(".pa").value;
    }

    closeNoCatModal(event){
        this.noCatModal = false;
        this.noCatInput = false;
    }

    closeEditModal() {
        this.editProductModal = false;
    }
    
    editManualCurrentRecord(currentRow) {
        this.errorMessage = '';
        console.log('LOADING CURRENT ROW RECORD AND SETTING VALUES...');
        // open modal box
        this.editLabel = "Update";
        this.isEditForm = true;
        this.editProductModal = true;
        // assign record id to the record edit form
        this.currentRecordId = currentRow.Id;
        this.reqAction = currentRow.Requested_Action_Override__c;
            console.log('Row Requested Action: '+this.reqAction);
        this.numInstalled = currentRow.Installed_Qty__c;
            console.log('Row Installed Qty: '+this.numInstalled);
        this.numFailed = currentRow.No_Of_Products_Failed__c;
            console.log('Row Number Failed: '+this.numFailed);
        /*this.hoursUsed = currentRow.No_of_Hours_Used__c;
            console.log('Row Hours Used: '+this.hoursUsed);
        this.hoursPerStart = currentRow.Hours_per_Start__c;
            console.log('Row Hours Per Start: '+this.hoursPerStart);*/
        this.dateInstalled = currentRow.Date_Installed__c;
            console.log('Row Date Installed: '+this.dateInstalled);
        this.comments = currentRow.Comments__c;
            console.log('Row Comments: '+this.comments);
        this.warCode = currentRow.Warranty_Code__c;
            console.log('Row Warranty Code: '+this.warCode);
        this.warSubCode = currentRow.Warranty_Sub_Code__c;
            console.log('Row Warranty Sub Code: '+this.warSubCode);
        /*this.priceAgrmtPrice = currentRow.Price_Agreement_Price__c;
            console.log('Row Price Agreement Price: '+this.priceAgrmtPrice);*/
        this.materialID = currentRow.Material__c;
            console.log('Row Material ID: '+this.materialID);
        if(currentRow.NoCAT__c != ''){
            this.handleNoCatChecked(e);
            this.NoCAT = currentRow.NoCAT__c;
                console.log('Row No CAT: '+this.NoCAT);
        }
        
        
    }

    handleLoad(event) {
        if (!this.loadedForm) {
            let fields = Object.values(event.detail.records)[0].fields;
            
            console.log('Record ID SET: '+this.currentRecordId);
            this.returnOrderItemUpdate = {
                Id: this.currentRecordId,
                ...Object.keys(fields)
                    .filter((field) => !!this.template.querySelector(`[data-field=${field}]`))
                    .reduce((total, field) => {
                        total[field] = fields[field].value;
                        return total;
                    }, {})
            };
            this.loadedForm = true;
        }
    }

    handleFieldChange(e){
        this.returnOrderItemUpdate[e.currentTarget.dataset.field] = e.target.value; 
    }

    handleManualValueChange(e){
        this.errorMessage = '';
        this.numInstalled = e.detail.value;
    }

    handleManualFailedValueChange(e){
        this.errorMessage = '';
        var failed = e.detail.value;
        if (failed < 10){
            this.numFailed = "0"+failed;
        } else{
        this.numFailed = failed;
        }
        console.log('Failed Converted: '+this.numFailed);
    }

    handleMaterialChange(event){
        this.materialID = event.target.value;
        console.log('Material ID: '+this.materialID);

    }

    handleMaterialSelected(event){
        this.materialID = event.target.value;
        console.log('Selected ID: ' +this.materialID);
        getMaterialDes({matId: this.materialID})
        .then(result => {
        this.materialDescription = result[0].GE_LGT_EM_MaterialDescription__c;
        this.materialNumber = result[0].GE_LGT_EM_SAP_MaterialNumber__c

        console.log(JSON.stringify("The Result for Material Number: "+ JSON.stringify(this.materialDescription)));
        console.log(JSON.stringify("The Result for Material Number: "+ JSON.stringify(this.materialNumber)));
        });
    }

    handleNoCatChecked(event){
        console.log('NoCat Input ON-CLICK is: '+this.noCatInput);
        if(this.noCatInput == false){
            this.noCatInput = true;
            this.materialID = '';
            this.materialDescription = '';
        } else if (this.noCatInput == true){
            this.noCatInput = false;
            this.NoCAT = " ";
        }
        console.log('NoCat Input AFTER-CLICK is: '+this.noCatInput);
    }

    async handleSaveForm(event){
        console.log('HANDLE SAVE FORM FUNCTION EXECUTED...');
        this.editLabel = "Updating...";
        this.isLoading = true;
        var installedQty = this.numInstalled;
        console.log('Installed Qty Entered: '+installedQty);
        var failedQty = this.numFailed;
        console.log('Failed Qty Entered: '+failedQty);
        console.log('Quantity Imported: '+this.rowQuantity);
        if (failedQty > installedQty ){
            this.errorMessage = "ERROR: Failed Quantity cannot be greater than Installed Quantity";
            console.log('Error: '+this.errorMessage);
            this.editLabel = "Update";
        
        } else {
        let nReturnItem = {'sobjectType': 'Return_Order_Item__c'};
            console.log('NoCat upon EDIT: '+this.NoCAT);
            nReturnItem.NoCAT__c = this.NoCAT;
            //nReturnItem.Price_Agreement_Price__c = this.priceAgrmtPrice;
            //nReturnItem.Hours_per_Start__c = this.hoursPerStart;
            //nReturnItem.No_of_Hours_Used__c = this.hoursUsed;
            nReturnItem.Comments__c = this.comments;
            nReturnItem.Warranty_Code__c = this.template.querySelector(".wc").value;
            nReturnItem.Warranty_Sub_Code__c = this.template.querySelector(".wsc").value;
            nReturnItem.Transaction_ID__c = this.transactionId;
            nReturnItem.Requested_Action_Override__c = this.template.querySelector(".ra").value;
            nReturnItem.No_Of_Products_Failed__c = this.template.querySelector(".mnf").value;
            nReturnItem.Date_Installed__c = this.template.querySelector(".di").value;
            nReturnItem.Installed_Qty__c = this.template.querySelector(".miq").value;
            nReturnItem.PO__c = this.template.querySelector(".po").value;
            nReturnItem.Shipment_Date__c = this.template.querySelector(".sd").value;
            nReturnItem.Transaction_ID__c = this.transactionId;
            nReturnItem.Id = this.currentRecordId;

            //updReturnOrderItems
            console.log(JSON.stringify("Check for Update Data Entry: "+ JSON.stringify(nReturnItem)))
            await updReturnOrderItems({data: nReturnItem})
            .then(result => {
                this.returnID = result;
                this.editProductModal=false;
            });
            //this.fetchReturnItems(); COMMENTED OUT 6-14
        }
    }

    handleManualSubmit(event) {
        console.log('HANDLE SUBMIT FUNCTION EXECUTED...');
        this.editLabel = "Updating...";
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
            this.ShowToastMsg('Success', 'Item Updated')
            this.editProductModal = false;
          // this.draftValues=[];   
          // console.log('Before Refresh: '+ JSON.stringify(this.orderItemList));
          // console.log('Check for Refresh: '+ this.selectedOrder);
    
        // showing success message
    }).catch(error=>{
        this.ShowToastMsg('Error Updating Records', error.body.message, error)
    });
        }


    /*async handleSuccess() {
        this.editProductModal = false;
             
     }*/

    async handleManualSave(event){
        console.log('HANDLE MANUAL SAVE FUNCTION EXECUTED...');
        this.addLabel = "Adding...";
        this.isLoading = true;
        
        this.reqAction = this.template.querySelector(".ra").value;
            console.log('Requested Action: '+this.reqAction);
        this.dateInstalled = this.template.querySelector(".di").value;
            console.log('Date Installed: '+this.dateInstalled);
        /*this.numInstalled = this.template.querySelector(".iq").value;
            console.log('Number Installed: '+this.numInstalled);
        this.numFailed = this.template.querySelector(".nf").value;
            console.log('Number Failed: '+this.numFailed);*/
        this.PO = this.template.querySelector(".po").value;
            console.log('PO# Entered: '+this.PO);
        this.shipmentDate = this.template.querySelector(".sd").value;
            console.log('Shipment Date: '+this.shipmentDate);
        this.warCode = this.template.querySelector(".wc").value;
            console.log('Warranty Code: '+this.warCode);
        this.warSubCode = this.template.querySelector(".wsc").value;
            console.log('Warranty Sub Code: '+this.warSubCode);
        this.comments = this.template.querySelector(".cm").value;
            console.log('Comments: '+this.comments);
        /*this.hoursUsed = this.template.querySelector(".hu").value;
            console.log('Hours Used: '+this.hoursUsed);
        this.hoursPerStart = this.template.querySelector(".hs").value;
            console.log('Hours Per Start: '+this.hoursPerStart);*/
        
        
        //let transaction = this.transactionId;
        console.log('Material ID: '+this.materialID);


        let matName = this.materialID;
        let noCatName = this.NoCAT;
        var fqty = this.numFailed;
        var iqty = this.numInstalled;
        if (!matName && !noCatName){
            this.addLabel = "Add to Claim";
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'ERROR',
                    message: 'Material or No Cat# are required',
                    variant: 'error'
                })
            );
        } else {
            console.log('Failed: '+this.numFailed+' '+'QTY: '+this.numInstalled);
            const allValid = [...this.template.querySelectorAll('.validValue')]
            .reduce((validSoFar, inputCmp) => {
                        inputCmp.reportValidity();
                        return validSoFar && inputCmp.checkValidity();
            }, true);
                if (allValid) {
                    
                    if (fqty > iqty){
                        this.isLoading = false;
                        this.errorMessage = "ERROR: Number of Failed Products cannot be greater than Installed Quantity";
                        console.log('Error: '+this.errorMessage);
                        this.addLabel = "Add to Claim";
                        
                        //this.ShowToastMsg('# of Filed Products cannot be greater than Installed Qty');
                    }else{
            
                    let nReturnItem = {'sobjectType': 'Return_Order_Item__c'};
                        nReturnItem.Material__c = this.materialID;
                        nReturnItem.NoCAT__c = this.NoCAT;
                        console.log('NoCAT# Entered: '+this.NoCAT);
                        nReturnItem.Product_SKU__c = this.materialDescription;
                        console.log('Material# Entered: '+this.materialDescription);
                        nReturnItem.SKU__c = this.materialNumber;
                        nReturnItem.Transaction_ID__c = this.transactionID;
                        nReturnItem.Requested_Action_Override__c = this.reqAction;
                        nReturnItem.No_Of_Products_Failed__c = this.numFailed;
                        nReturnItem.Date_Installed__c = this.dateInstalled;
                        nReturnItem.Installed_Qty__c = this.numInstalled;
                        nReturnItem.Comments__c = this.comments;
                        nReturnItem.Warranty_Code__c = this.warCode;
                        nReturnItem.Warranty_Sub_Code__c = this.warSubCode;
                        //nReturnItem.No_of_Hours_Used__c = this.hoursUsed;
                        nReturnItem.PO__c = this.PO;
                        //nReturnItem.Hours_per_Start__c = this.hoursPerStart;
                        //nReturnItem.Price_Agreement_Price__c = this.priceAgrmtPrice;
                        /*if(this.noCatInput = true){
                         nReturnItem.Unique_ID__c = transaction + '_' + this.NoCAT;
                        } else{
                            nReturnItem.Unique_ID__c = transaction + '_' + this.materialDescription;
                        }*/
                        nReturnItem.Shipment_Date__c = this.shipmentDate;
                        nReturnItem.Type__c = "Warranty - Manual Entry";
                        await createReturnItem({accounts: nReturnItem})
                        .then(result => {
                            this.returnID = result;
                            this.noCatModal = false;
                            this.materialID = '';
                            this.noCatInput = false;
                            this.editProductModal = false;
                            this.NoCAT = '';
                    
                        });
            
                    
                    this.fetchReturnItems(); 
                     
            
                    console.log('ROI ID: '+this.returnID);
                    console.log('Transaction ID: '+this.transactionID);
                    }
                } else {
                    this.addLabel = "Add to Claim";
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

   /* handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        console.log('Delete ActionName: '+ actionName);
        console.log('Delete Row: '+ JSON.stringify(row));
        switch (actionName) {
            case 'edit':
                this.editCurrentRecord(row);
                break;
            case 'delete':
                this.deleteManualRow(row);
                break;
            case 'show_details':
                this.showRowDetails(row);
                break;
            default:
        }
    } */


     deleteManualRow(row) {

        console.log('value getting passed for deletion: '+ JSON.stringify(row));
        var selRow = [row];
        for (var i =0; i< selRow.length ;i++) {
            console.log(selRow[i].Transaction_ID__c);
            var newRow = selRow[i].Transaction_ID__c;
         }
        console.log('value getting passed for deletion: '+ JSON.stringify(selRow));
        console.log('New Value Passed for Trax ID: '+ newRow);
        deleteReturnItemList({data: selRow})
        .then(result => {
            
            console.log(JSON.stringify("Apex update result: "+ result));
    
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Selected record has been deleted successfully',
                    variant: 'success'
                })
            );
           
            this.fetchReturnItems();
        
    });
    }

    /*fetchReturnItems(){
        let transaction = this.transactionId;
        getReturnList({transId : transaction})
            .then(result =>{
                this.returnLines = result;
                this.showReturnItems = true;
                this.isLoading = false;
                this.cartCount = this.returnLines.length;
                this.dispatchEvent(
                    new CustomEvent('manuallineupdate', {
                        detail: {
                            manuallines : this.returnLines
                        }
                    }));
                    this.dispatchEvent(
                        new CustomEvent('cartcount', {
                            detail: {
                                totalItems : this.cartCount
                            }
                        }));
            
        });
        
     }*/
//----- END MANUAL PRODUCT ENTRY FUNCTIONS

    }