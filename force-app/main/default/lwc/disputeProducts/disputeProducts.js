import { LightningElement, api, track, wire } from 'lwc';
import disputeProducts from '@salesforce/apex/connectCreateCase.getDisputeProducts';

import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ID_FIELD from '@salesforce/schema/Shipment_Detail__c.Id';
import APPROVED_FIELD from '@salesforce/schema/Shipment_Detail__c.Approved__c';
import APPROVAL_STATUS_FIELD from '@salesforce/schema/Shipment_Detail__c.In_Approval_Process__c';
import PENDING_APPROVAL__FIELD from '@salesforce/schema/Shipment_Detail__c.Pending_Approval__c';
// import { refreshApex } from '@salesforce/apex';

const actions = [
    { label: 'Approve', name: 'approve'},
    { label: 'Reject', name: 'reject'},
    { label: 'Edit', name: 'edit'}
];

export default class DisputeProducts extends LightningElement {
    @api recordId;
    products
    @track currentRecordId;
    data;
    @track isLoading = false;
    @track handleAction = "";
    @track isWarranty = false;

    @track columns = [
        {
            label: 'Approved',
            initialWidth: 85,
            fieldName: 'Approved__c',
            type: 'boolean',
            sortable: true,
            cellAttributes: {
                alignment: 'center'
            }
        },
        {
            label: 'No Cat?',
            initialWidth: 85,
            fieldName: 'No_Cat__c',
            type: 'boolean',
            sortable: true,
            cellAttributes: {
                alignment: 'center'
            }
        },
        
            {
                label: 'Catalog #',
                fieldName: 'Material_Description__c',
                type: 'Text',
                sortable: true
            },
            {
                label: 'SKU #',
                fieldName: 'SAP_Material__c',
                type: 'Text',
                sortable: true
            },
            {
                label: 'Alternate SKU #',
                fieldName: 'Non_Finished_Good_SKU__c',
                type: 'Text',
                sortable: true
            },
            {
                label: 'No CAT#',
                fieldName: 'No_Cat_Number__c',
                type: 'Text',
                sortable: true
            },
            {
                label: 'PO #',
                fieldName: 'PO__c',
                type: 'Text',
                sortable: true
            },
            {
                label: 'Dispute Qty',
                fieldName: 'Discrepancy_Qty__c',
                type: 'number',
                sortable: true,
                cellAttributes: {
                    alignment: 'center'
                }
            },
            {
                label: 'Unit Price',
                fieldName: 'Invoiced_Price__c',
                type: 'currency',
                sortable: true,
                cellAttributes: {
                    alignment: 'center'
                }
            },
            {
                label: 'UOM',
                fieldName: 'GE_NAS_Unit_of_Measure__c',
                type: 'Text',
                sortable: true,
                cellAttributes: {
                    alignment: 'center'
                }
            },
            {
                label: 'QuickStock',
                fieldName: 'QuickStock__c',
                type: 'boolean',
                sortable: true,
                cellAttributes: {
                    alignment: 'center'
                }
            },
            {
                label: 'Total',
                fieldName: 'Discrepancy_Total__c',
                type: 'currency',
                sortable: true,
                cellAttributes: {
                    alignment: 'center'
                }
            },
            {
                type: 'button',
                initialWidth: 100,
                cellAttributes: {
                    alignment: 'center',
                    class: {
                        fieldName: 'approveButtonVisibility'
                    }
                },
                typeAttributes:{
                    label: 'Approve',
                    variant: 'success',
                    name: 'approve',
                    rowActions: actions,
                    title: 'approve',
                    
                    iconClass: 'slds-icon-text-error',
                }
            },
            {
                type: 'button',
                initialWidth: 85,
                cellAttributes: {
                    alignment: 'center',
                    class: {
                        fieldName: 'rejectButtonVisibility'
                    }
                },
                typeAttributes:{
                    label: 'Reject',
                    name: 'reject',
                    variant: 'destructive',
                    rowActions: actions,
                    title: 'reject',
                 
                    iconClass: 'slds-icon-text-error',
                                    
                }
            },
            /*{
                type: 'button',
                initialWidth: 85,
                cellAttributes: {
                    alignment: 'center',
                    class: {
                        fieldName: 'editButtonVisibility'
                    }
                },
                typeAttributes:{
                    label: 'Edit',
                    name: 'edit',
                    variant: 'brand-outline',
                    rowActions: actions,
                    title: 'edit',
                 
                    //iconClass: 'slds-icon-text-error',
                                    
                }
            }*/
        
    ];
   

   
   
   /* @wire(disputeProducts, {disId :'$recordId'} )
    wiredResult(result) { 
        const { data, error } = result;
        this._tempDisList = result;
        if (data) {
            this.products = data;
        }
        if(error) {
            console.error(error)
        }
    }*/

    /*@wire(disputeProducts,{disId: this.disputeId})
    wiredDisputes(result) {

        this.products = result;
        if (result.data) {
            this.data = result.data;
         
        }
    }*/

    connectedCallback(){
        this.getDisputesProducts()
        // disputeProducts({disId: this.recordId})
        // .then(result=>{
        //     this.products = result;
        // });

        //this.disputeId = this.recordId;
    }

    async getDisputesProducts() {
        try {
            this.isLoading = true;
            this.products = [];
           await disputeProducts({disId: this.recordId})
            .then(result=>{
                for (const productData of result) {
                    let clone = Object.assign({}, productData);
                    console.log('isWarranty Attribute: '+this.isWarranty);
                    if(result[0].GE_NAS_Type_of_Problem__c === 'Warranty - Replace' || result[0].GE_NAS_Type_of_Problem__c === 'Warranty - Return'){
                        this.isWarranty = true;
                        console.log('Warranty Product Case....');
                        console.log('isWarranty Attribute - in IF Statement: '+this.isWarranty);
                    } else {
                        this.isWarranty = false;
                    }
                    Object.setPrototypeOf(clone, this.productsProto);
                    this.products.push(clone);
                }
                this.products = [...this.products];
                this.isLoading = false;
            });
        } catch(error) {
            console.log("Error: ", error);
        }
    }

    productsProto = {
        
        //WARRANTY HIDDEN - OLD CODE
        /*get approveButtonVisibility() {
            if (this.Approved__c == false && this.In_Approval_Process__c == false && this.is_Warranty__c !== true) {
                return "";
            } else if (this.Approved__c == false && this.In_Approval_Process__c == false && this.is_Warranty__c == true){
                console.log('Hiding Approval Button...');
                return "slds-hidden";
            } else if (this.Approved__c == true && this.In_Approval_Process__c == false && this.is_Warranty__c !== true) {
                return "slds-hidden";
            } else if (this.In_Approval_Process__c == true || this.is_Warranty__c == true) {
                return "slds-hidden";
            }
        },
        get rejectButtonVisibility() {
            if (this.Approved__c == false && this.In_Approval_Process__c == false) {
                return "slds-hidden";
            } else if (this.Approved__c == true && this.In_Approval_Process__c == false && this.is_Warranty__c !== true) {
                return "";
            } else if (this.In_Approval_Process__c == true) {
                return "slds-hidden";
            }
        },
        get editButtonVisibility() {
            if (this.Approved__c == false && this.In_Approval_Process__c == false) {
                return "";
            } else if (this.Approved__c == true && this.In_Approval_Process__c == false) {
                return "slds-hidden";
            } else if (this.In_Approval_Process__c == true) {
                return "slds-hidden";
            }
        }*/

        //ENABLE FOR WARRANTY - NEW CODE
        get approveButtonVisibility() {
            if (this.Approved__c == false && this.In_Approval_Process__c == false) {
                return "";
            } else if (this.Approved__c == true && this.In_Approval_Process__c == false) {
                return "slds-hidden";
            } 
        },
        get rejectButtonVisibility() {
            if (this.Approved__c == false && this.In_Approval_Process__c == false) {
                return "slds-hidden";
            } else if (this.Approved__c == true && this.In_Approval_Process__c == false) {
                return "";
            } else if (this.In_Approval_Process__c == true) {
                return "slds-hidden";
            }
        },
        get editButtonVisibility() {
            if (this.Approved__c == false && this.In_Approval_Process__c == false) {
                return "";
            } else if (this.Approved__c == true && this.In_Approval_Process__c == false) {
                return "slds-hidden";
            } else if (this.In_Approval_Process__c == true) {
                return "slds-hidden";
            }
        }
    }

    handleActions(event){
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        this.handleAction = actionName;

        this.isLoading = true;

        console.log('ActionName: '+ actionName);
        console.log('Row: '+ JSON.stringify(row));
        switch (actionName) {
            case 'approve':
                this.approveCurrentRecord(row);
                break;
            case 'reject':
                this.rejectCurrentRecord(row);
                break;
            case 'edit':
                this.editCurrentRecord(row);
                break;
            default:
        }
   }

   approveCurrentRecord(currentRow){
    this.currentRecordId = currentRow.Id
    const fields = {};
    fields[ID_FIELD.fieldApiName] = this.currentRecordId;
    fields[APPROVED_FIELD.fieldApiName] = true;
    fields[PENDING_APPROVAL__FIELD.fieldApiName] = 1;

    const recordInput = { fields };

            updateRecord(recordInput)
                .then(() => {
                    
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Record Approved',
                            variant: 'success'
                        })
                    );

                    // Display fresh data in the form
                    console.log('Executing Refresh....');
                    this.fetchUpdates();
                    //return refreshApex(this.products);
                })
                .catch(error => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error creating record',
                            //message: error.body.message,
                            variant: 'error'
                        })
                    );
                });
                
    }

    rejectCurrentRecord(currentRow){
        this.currentRecordId = currentRow.Id
        const fields = {};
        fields[ID_FIELD.fieldApiName] = this.currentRecordId;
        fields[APPROVED_FIELD.fieldApiName] = false;
        fields[PENDING_APPROVAL__FIELD.fieldApiName] = 0;
    
        const recordInput = { fields };
    
                updateRecord(recordInput)
                    .then(() => {
                        
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Success',
                                message: 'Record Rejected',
                                variant: 'success'
                            })
                        );
                        // Display fresh data in the form
                        console.log('Executing Refresh....');
                        this.fetchUpdates();
                        //return refreshApex(this.products);
                        
                    })
                    .catch(error => {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error creating record',
                                //message: error.body.message,
                                variant: 'error'
                            })
                        );
                    });
                  
        }

    editCurrentRecord(currentRow){

    }
   
    fetchUpdates(){
        console.log('Calling Apex to Refreshing...');
        // disputeProducts({disId: this.recordId})
        // .then(result=>{
        //     this.products = result;
        // });

        // Update Product Data By Sameer Mahadik On(9-21-2021)
        let results = [];
        for (const product of this.products) {
            if (product.Id == this.currentRecordId) {
                if (this.handleAction == "approve") {
                    product.Approved__c = true;
                } else if (this.handleAction == "reject") {
                    product.Approved__c = false;
                } else {
                    // Set product.Approved__c value for edit action here 
                }
            }
            let clone = Object.assign({}, product);
            Object.setPrototypeOf(clone, this.productsProto);
            results.push(clone);
        }
        this.products = results;
        this.isLoading = false;
    }

}