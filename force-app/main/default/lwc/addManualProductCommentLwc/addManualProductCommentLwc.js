import { LightningElement, track, api } from 'lwc';
import createReturnItem from '@salesforce/apex/ReturnOrderItemController.createReturnOrderItems';
import getReturnProdList from '@salesforce/apex/CCProductController.getCollateralReturnProdList';


const actions = [
    { label: 'Delete', name: 'delete' },
    { label: 'Edit', name: 'edit' },
];

export default class AddManualProductCommentLwc extends LightningElement {
    @api columnList;
    @api title;
    //@track columns;
    @track objectAPIName;    
   // @track rows = [{ uuid: this.createUUID()}];        
    @track selectQty;
    @track catalogNo;    
    @track isEditForm = false;
    draftValues = [];
    @api valuetopass;
    @track currentRecordId;
    @track showReturnItems = false;
    @api returnID;
    @api transactionId;
    @track returnLines;
    @track addProductModal = false;
    @track editProductModal = false;
    @track returnOrderItemUpdate = {};
    @track isLoading=false;

    @track columns = [{
        label: 'Catalog #',
        fieldName: 'Product_SKU__c',
        type: 'Text',
        sortable: true,
        cellAttributes: { alignment: 'left' }
    },    
    {
        label: 'Product Description',
        fieldName: 'Product_Description__c',
        type: 'Text',
        sortable: true,
        cellAttributes: { alignment: 'center' }
    },
    {
        label: 'Comments',
        fieldName: 'Comments__c',
        type: 'Text',
        editable: true,
        sortable: true,
        cellAttributes: { alignment: 'left' }
    },
   /* {
        type: 'button-icon',
        initialWidth: 34,
        typeAttributes:{
            label: 'Edit',
            name: 'edit',
            rowActions: actions,
            title: 'edit',
            iconName: 'utility:edit',
            variant: 'brand'
        }
    },
        {
        type: 'button-icon',
        initialWidth: 34,
        typeAttributes:{
            label: 'Delete',
            name: 'delete',
            rowActions: actions,
            title: 'delete',
            iconName: 'utility:delete',
            variant: 'brand'
        }
    }*/
   

    ]; 

    @api
    retrieveRecords() {
        let rows = Array.from(this.template.querySelectorAll("tr.inputRows") );
        var records=[];
        rows.map(row => {
            let texts = Array.from(row.querySelectorAll(".fields"));
            if(texts)
            {
                var textVal=this.fieldValues(texts);
                records=[...records,textVal];
            }
        });
        return records;
    }
    fieldValues(cells)
    {
        return cells.reduce((record, cell) => {
            let inputVal = cell.inputValue();
            if(inputVal.value!=undefined)
            {
                record[inputVal.field] = inputVal.value;
            }
            return record;
        }, {});
    }
    removeRow(event) {
        this.rows.splice(event.target.value, 1);
    }
    
    /*addRow() {
        this.rows.push({ uuid: this.createUUID()});
    }*/

//-----------------------------------------------------------------------------------------------------------------------
    addProduct(event){
        this.addProductModal = true;
    }


    closeModal(event){
        this.addProductModal = false;
    }

    closeManualEditModal() {
        this.bShowModal = false;
    }

    closeEditModal() {
        this.editProductModal = false;
    }

    editCurrentRecord(currentRow) {
        // open modal box
        this.currentRecordId = currentRow.Id;
        this.editProductModal = true;
        this.isEditForm = true;
        this.numInstalled = currentRow.selectQty;
        this.numFailed = currentRow.catalogNo;        
        if(currentRow.NoCAT__c != ''){
            this.handleChecked();
            //this.NoCAT = currentRow.NoCAT__c;
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



    handleSubmit(event) {
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
            this.ShowToastMsg('Success', 'Order Details Updated')
          // this.draftValues=[];   
          // console.log('Before Refresh: '+ JSON.stringify(this.orderItemList));
          // console.log('Check for Refresh: '+ this.selectedOrder);
    
        // showing success message
    }).catch(error=>{
        this.ShowToastMsg('Error Updating Records', error.body.message, error)
    });
        }
    
    async handleSave(event){    
        this.isLoading=true;     
        this.catalogNo = this.template.querySelector(".di").value;
            console.log('Catalog No: '+this.catalogNo);
        this.selectQty = this.template.querySelector(".po").value;
            console.log('Quantity Entered: '+this.selectQty);
            
        let transaction = this.transactionId;
       // console.log('Material ID: '+this.materialID);

        let nReturnItem = {'sobjectType': 'Return_Order_Item__c'};
            nReturnItem.Product_SKU__c = this.catalogNo;
            //nReturnItem.NoCAT__c = this.NoCAT;
            console.log('NoCAT# Entered: '+this.NoCAT);
            nReturnItem.Transaction_ID__c = transaction;
            nReturnItem.Comments__c = this.selectQty;
            console.log('Return Items: '+JSON.stringify(nReturnItem)) ;           
            await createReturnItem({accounts: nReturnItem})
            .then(result => {
                this.returnID = result;
                this.addProductModal = false;
                //this.materialID = '';
                this.noCatInput = false;
            });

        
        this.fetchReturnItems();
         

        console.log('ROW ID: '+this.returnID);
        console.log('Transaction ID: '+this.transactionId);
    }

    fetchReturnItems(){
        let transaction = this.transactionId;
        console.log('transcation Id for fetchreturn' +transaction);
        getReturnProdList({transId : transaction})
            .then(result =>{
                this.returnLines = result;
                console.log('Result Id for fetchreturn:' +JSON.stringify(this.returnLines));
                this.showReturnItems = true;
                this.isLoading=false; 
                this.dispatchEvent(
                    new CustomEvent('manuallineupdate', {
                        detail: {
                            manuallines : this.returnLines
                        }
                    }));
        });
        
     }

     handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        console.log('Delete ActionName: '+ actionName);
        console.log('Delete Row: '+ JSON.stringify(row));
        switch (actionName) {
            case 'delete':
                this.deleteRow(row);
                break;
            case 'show_details':
                this.showRowDetails(row);
                break;
            default:
        }
    }


     deleteRow(row) {

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

}