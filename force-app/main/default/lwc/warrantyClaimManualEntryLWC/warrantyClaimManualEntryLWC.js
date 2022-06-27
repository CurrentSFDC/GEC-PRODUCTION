import { LightningElement, track, api,wire } from 'lwc';

import createReturnItem from '@salesforce/apex/ReturnOrderItemController.createReturnOrderItems';
import updReturnOrderItems from '@salesforce/apex/ReturnOrderItemController.updReturnOrderItems';
import getMaterialDes from '@salesforce/apex/ReturnOrderItemController.getMaterial';
import getReturnList from '@salesforce/apex/OrderProductController.getReturnList';
import deleteReturnItemList from '@salesforce/apex/OrderProductController.delReturnItems';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord } from 'lightning/uiRecordApi';


const actions = [
    { label: 'Delete', name: 'delete' },
    { label: 'Edit', name: 'edit' },
];

export default class WarrantyClaimManualEntryLWC extends LightningElement {
    @api columnList;
    @api title;
    //@track columns;
    @track objectAPIName;
    @track pickListvalues;

    @track warSubOptions;
    @track materialID;
    @track materialDescription;
    @track reqAction;
    @track numFailed = 0;
    @track numInstalled = 0;
    @track dateInstalled;
    @track PO;
    @track shipmentDate;
    @track NoCAT = " ";
    @track warCode;
    @track warSubCode;
    @track hoursUsed;
    @track comments;
    @track hoursPerStart;
    @track warrantyReason;
    @track priceAgrmtPrice = "";
    @track errorMessage;

    @track isEditForm = false;
    @track paPrice = false;
    draftValues = [];
    @api valuetopass;
    @track currentRecordId;
    @track showReturnItems = false;
    @api returnID;
    @api transactionId;
    @track noCatInput = false;
    @track returnLines;
    @track addProductModal = false;
    @track editProductModal = false;
    @track editLabel = "Update"
    

    @track returnOrderItemUpdate = {};
    @track isLoading=false;

    get RAoptions() {
        return [
            { label: 'Credit', value: 'Credit' },
            { label: 'Replacement', value: 'Replacement' },
            { label: 'Analysis Only', value: 'Analysis Only' },
        ];
    }

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
    
    @track columns = [{
        label: 'Catalog #',
        fieldName: 'SKU_Description_Cat_Logic__c',
        iconName: 'utility:products',
        type: 'Text',
        sortable: true,
        cellAttributes: { alignment: 'center' }
    },
    /*{
        label: 'Description',
        fieldName: 'Material_Description__c',
        type: 'Text',
        sortable: true,
        cellAttributes: { alignment: 'center' }
    },*/
    {
        label: 'NoCAT #',
        fieldName: 'NoCAT__c',
        type: 'Text',
        sortable: true,
        cellAttributes: { alignment: 'center' }
    },
    {
        label: 'Shipment Date',
        fieldName: 'Shipment_Date__c',
        iconName: 'utility:date_input',
        type: 'date',
        sortable: true,
        cellAttributes: { alignment: 'center' },
        typeAttributes: {
            day: "numeric",
            month: "numeric",
            year: "numeric"
        }
    },
    {
        label: 'Date Installed',
        fieldName: 'Date_Installed__c',
        iconName: 'utility:date_input',
        type: 'date',
        sortable: true,
        cellAttributes: { alignment: 'center' },
        typeAttributes: {
            day: "numeric",
            month: "numeric",
            year: "numeric"
        }
    },
    {
        label: 'Installed',
        fieldName: 'Installed_Qty__c',
        iconName: 'utility:number_input',
        type: 'Number',
        sortable: true,
        hideDefaultActions: true,
        cellAttributes: { alignment: 'center' }
    },
    {
        label: 'Failed',
        fieldName: 'No_Of_Products_Failed__c',
        iconName: 'utility:number_input',
        type: 'Number',
        sortable: true,
        cellAttributes: { alignment: 'center' }
    },
    {
        label: 'Requested Action',
        fieldName: 'Requested_Action_Override__c',
        iconName: 'utility:button_choice',
        wrapText: true,
        type: 'Text',
        cellAttributes: { alignment: 'center' }
    },
    {
        label: 'Line Comments',
        fieldName: 'Comments__c',
        iconName: 'utility:textbox',
        wrapText: true,
        type: 'Text',
        cellAttributes: { alignment: 'center' }
    },
    {
        type: 'button-icon',
        initialWidth: 34,
        iconName: 'utility:edit',
        typeAttributes:{
            label: 'Edit',
            name: 'edit',
            rowActions: actions,
            title: 'edit',
            iconName: 'utility:edit',
            variant: 'brand'
        }},
        {
        type: 'button-icon',
        iconName: 'utility:delete',
        initialWidth: 34,
        typeAttributes:{
            label: 'Delete',
            name: 'delete',
            rowActions: actions,
            title: 'delete',
            iconName: 'utility:delete',
            variant: 'brand'
        }
    }
   

    ]; 


//-----------------------------------------------------------------------------------------------------------------------
    //------- MANUAL PRODUCT ENTRY FUNCTIONS -------

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

    addProduct(event){
        this.addLabel = "Add to Claim";
        this.addProductModal = true;
        this.noCatInput = false;
        this.value = '';
        this.numInstalled = 0;
        this.numFailed = 0;
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

    closeAddModal(event){
        this.addProductModal = false;
        this.noCatInput = false;
    }

    closeEditModal() {
        this.editProductModal = false;
    }
    
    editCurrentRecord(currentRow) {
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

    handleValueChange(e){
        this.errorMessage = '';
        this.numInstalled = e.detail.value;
    }

    handleFailedValueChange(e){
        this.errorMessage = '';
        let failed = e.detail.value;
        if (failed < 10){
            this.numFailed = "0"+failed;
        } else{
        this.numFailed = e.detail.value;
        }
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
        this.materialDescription = result;
        console.log(JSON.stringify("The Result for Material Number: "+ JSON.stringify(this.materialDescription)))
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
            this.errorMessage = "ERROR: Installed Quantity cannot be greater than Order Quantity";
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
            nReturnItem.No_Of_Products_Failed__c = this.template.querySelector(".nf").value;
            nReturnItem.Date_Installed__c = this.template.querySelector(".di").value;
            nReturnItem.Installed_Qty__c = this.template.querySelector(".iq").value;
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
            this.fetchReturnItems();
        }
    }

    handleSubmit(event) {
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


    async handleSuccess() {
        this.editProductModal = false;
             
     }

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
        
        
        let transaction = this.transactionId;
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
       
                        this.errorMessage = "ERROR: Number of Failed Products cannot be greater than Installed Quantity";
                        console.log('Error: '+this.errorMessage);
                        this.addLabel = "Add to Claim";
                        
                        //this.ShowToastMsg('# of Filed Products cannot be greater than Installed Qty');
                    }else{
            
                    let nReturnItem = {'sobjectType': 'Return_Order_Item__c'};
                        nReturnItem.Material__c = this.materialID;
                        nReturnItem.NoCAT__c = this.NoCAT;
                        console.log('NoCAT# Entered: '+this.NoCAT);
                        nReturnItem.SKU__c = this.materialDescription;
                        console.log('Material# Entered: '+this.materialDescription);
                        nReturnItem.Transaction_ID__c = transaction;
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
                        nReturnItem.Type__c = "Warranty";
                        await createReturnItem({accounts: nReturnItem})
                        .then(result => {
                            this.returnID = result;
                            this.addProductModal = false;
                            this.materialID = '';
                            this.noCatInput = false;
                            this.editProductModal = false;
                            this.NoCAT = '';
                    
                        });
            
                    
                    this.fetchReturnItems();
                     
            
                    console.log('ROI ID: '+this.returnID);
                    console.log('Transaction ID: '+this.transactionId);
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

    handleRowAction(event) {
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
        
     }
//----- END MANUAL PRODUCT ENTRY FUNCTIONS

handleValidation(){

    let matName = this.template.querySelector('.mat').value;
    let noCatName = this.template.querySelector('.nc').value;
    if (!matName && !noCatName){
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'ERROR',
                message: 'Material or No Cat# are required',
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
}