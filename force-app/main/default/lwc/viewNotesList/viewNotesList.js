import {
    LightningElement,
    track,
    wire,
    api
} from 'lwc';

import getAllNotes from '@salesforce/apex/CaseNotes.getAllNotes';
import {refreshApex} from '@salesforce/apex';

// importing to show toast notifictions
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

export default class DatatableEx12 extends LightningElement {
    @track actions = [{
        label: 'View',
        type: 'button-icon',
        name: 'View',
        
        initialWidth: 75,
        typeAttributes: {
            
            iconName: 'action:preview',
            title: 'View Note Detials',
            variant: 'border-filled',
            alternativeText: 'View'
        }
        },
        {
            label: 'Edit',
            type: 'button-icon',
            name: 'Edit',
            initialWidth: 75,
            typeAttributes: {
                iconName: 'action:edit',
                title: 'Edit Note',
                variant: 'border-filled',
                alternativeText: 'Edit'
                
            }
        },
    ];
    @track columns = [
        {
            label: 'View',
            type: 'button-icon',
            initialWidth: 75,
            typeAttributes: {
                iconName: 'action:preview',
                title: 'Preview',
                variant: 'border-filled',
                alternativeText: 'View'
            }
        },
        {
            label: 'Subject',
            fieldName: 'Subject__c', //Change to OwnerId.Name
            //initialWidth: 20,
            type: 'text',
            sortable: true
        },
        
        //UNCOMMENT THIS FOR IF EDIT CAPABILITY IS REQUIRED
        /*{
            type: 'action',
            typeAttributes: {
                rowActions: this.actions,
        }
        },*/
        

        {
            label: 'Note Type', //TITLE FROM NOTES
            //initialWidth: 25,
            fieldName: 'Note_Type__c',
            type: 'text',
            sortable: true
        },
        /*{
            label: 'Preview',
            fieldName: 'TextPreview',
            //initialWidth: 35,
            type: 'text',
            sortable: true
        },*/
        {
            label: 'Note Preview', //CONTENT FROM NOTE
            fieldName: 'Note__c',
            //initialWidth: 35,
            type: 'text',
            sortable: true
        },
        {
            label: 'Created Date',
            fieldName: 'CreatedDate',
            //initialWidth: 20,
            type: 'date', 
            typeAttributes:{
            day: 'numeric',  
            month: 'short',  
            year: 'numeric',  
            hour: '2-digit',  
            minute: '2-digit',  
            second: '2-digit',  
            hour12: true},
            
            sortable: true
        },
        /*{
            label: 'Created By',
            fieldName: 'Created_By__c', //Change to OwnerId.Name
            //initialWidth: 20,
            type: 'text',
            sortable: true
        }*/
 
    ];
    @track error;
    @track notes ;
    @api recordId;
    @track isEditForm = false;
    @track record = [];
    refreshTable;
    @track bShowModal = false;
    @track currentRecordId;
    @wire(getAllNotes, { caseId: '$recordId' })
    wiredOpps(result) {
        this.refreshTable = result;
        if (result.data) {
            this.notes = result.data;
            this.error = undefined;
            //console.log(data);
            //console.log(JSON.stringify(data, null, '\t'));
        } else if (result.error) {
            this.error = result.error;
            this.notes = undefined;
        }
    }

    // Row Action event to show the details of the record
    handleRowActionReadOnly(event) {
        const row = event.detail.row;
        this.record = row;
        this.bShowModal = true; // display modal window
    }



    // Row Action event to show the details of the record
    handleRowAction(event) {
        let actionName = event.detail.action.name;
        window.console.log('actionName ====>' + actionName);

        let row = event.detail.row;
        // eslint-disable-next-line default-case
        switch(actionName){
            case 'View':
                this.viewCurrentRecord(row);
                break;
            case 'Edit':
                this.editCurrentRecord(row);
                break;
        }

    }

    // to view the record
    viewCurrentRecord(currentRow) {
        this.isEditForm = false;
        this.record = currentRow;
        this.bShowModal = true; // display modal window
    }

    editCurrentRecord(currentRow) {
        // open modal box
        this.bShowModal = true;
        this.isEditForm = true;

        // assign record id to the record edit form
        this.currentRecordId = currentRow.Id;
    }

    // handleing record edit form submit
    handleSubmit(event) {
        // prevending default type sumbit of record edit form
        event.preventDefault();

        // querying the record edit form and submiting fields to form
        this.template.querySelector('lightning-record-edit-form').submit(event.detail.fields);

        // closing modal
        this.bShowModal = false;

        // showing success message
        this.dispatchEvent(new ShowToastEvent({
            title: 'Success!!',
            message:  'Note updated Successfully!!.',
            variant: 'success'
        }),);

    }

    // refreshing the datatable after record edit form success
    handleSuccess() {
        return refreshApex(this.refreshTable);
    }



    // to close modal window set 'bShowModal' tarck value as false
    closeModal() {
        this.bShowModal = false;
    }
}










/* export default class Cssexample extends LightningElement {
    @track notes;
    @track errors;
    @api recordId;
    @wire(getAllNotes, { caseId: '$recordId' })
    wireAllAccs({
        error,
        data
    }) {
        if (data) {
            this.notes = data;
        } else {
            this.error = error;
        }
    }

     // Row Action event to show the details of the record
    handleRowAction(event) {
        const row = event.detail.row;
        this.record = row;
        this.bShowModal = true; // display modal window
    }

    // to close modal window set 'bShowModal' tarck value as false
    closeModal() {
        this.bShowModal = false;
    }

} */