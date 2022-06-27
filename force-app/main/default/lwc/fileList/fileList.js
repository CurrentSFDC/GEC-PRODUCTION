import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { deleteRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class FilesList extends NavigationMixin(LightningElement) {

    @api files;
    @track originalMessage;
    @track isDialogVisible = false;

    @track columns = [
        { label: 'File Name', fieldName: 'Title', type: 'text' },
        { label: 'Type', fieldName: 'FileType', type: 'text' },
        { label: 'Size', fieldName: 'ContentSize', type: 'number' },
        { type: 'button-icon', typeAttributes: { name: 'openConfirmation', iconName: 'utility:delete', iconClass: 'slds-icon-text-error' }, fixedWidth: 50 }
    ];

    filePreview(event) {
        // Naviagation Service to the show preview
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'filePreview'
            },
            state: {
                // assigning ContentDocumentId to show the preview of file
                selectedRecordId: event.detail.row.Id
            }
        })
    }

    handleDelete(event) {
        console.log('Executing Delete on File......');
        if (event.detail) {
            if (event.detail.action.name === 'openConfirmation') {
                console.log('Delete button on Table clicked!');
                //it can be set dynamically based on your logic
                this.originalMessage = event.detail.row.Id;
                console.log('Row Marked for Deletion: '+ event.detail.row.Id);
                //shows the component
                this.isDialogVisible = true;
            }
        }
    }

    confirmDelete(event){
        if(event.target){
            if (event.target.name === 'confirmModal') {
                console.log('Event Target Name: ' + event.target.name);
                console.log('Delete button on Modal clicked!');
                if (event.detail !== 1) {
                    if (event.detail.status === 'confirm') {
                        console.log('Event Updated: ' + event.detail.status);
                        //delete content document
                        let contentDocumentId = event.detail.originalMessage;
                        console.log('This record is about to be Deleted: '+ contentDocumentId);
                        deleteRecord(contentDocumentId)
                            .then(() => {
                                this.dispatchEvent(
                                    new ShowToastEvent({
                                        title: 'Success',
                                        message: 'File deleted',
                                        variant: 'success'
                                    })
                                );
                                this.dispatchEvent(
                                    new CustomEvent('filedelete', {
                                        detail: {
                                            contId : contentDocumentId
                                        }
                                    }));
                                
                                console.log('Event Dispatched: ');
                            })
                            .catch(error => {
                                this.dispatchEvent(
                                    new ShowToastEvent({
                                        title: 'Error deleting file',
                                        message: error.body.message,
                                        variant: 'error'
                                    })
                                );
                            });
                    }
                }

                //hides the component
                this.isDialogVisible = false;
            }
        }
    }
}