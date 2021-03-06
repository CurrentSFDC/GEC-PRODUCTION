import { api, LightningElement, track, wire } from 'lwc';
import getContentDetails from '@salesforce/apex/FileUploadViewController.getContentDetails';
import deleteContentDocument from '@salesforce/apex/FileUploadViewController.deleteContentDocument';
import { NavigationMixin } from 'lightning/navigation';

const columns = [
    { label: 'Title',       fieldName: 'Title', wrapText : true,  initialWidth: 575,
        cellAttributes: { 
            iconName: { fieldName: 'icon' }, iconPosition: 'left' 
        }
    },
    { label: 'Created By',  fieldName: 'CREATED_BY',  initialWidth: 300,
        cellAttributes: { 
            iconName: 'standard:user', iconPosition: 'left' 
        }
    },
    { label: 'File Size',   fieldName: 'Size',  initialWidth: 150 },
    /*{ label: 'Preview', type:  'button', typeAttributes: { 
            label: 'Preview',  name: 'Preview',  variant: 'brand-outline',
            iconName: 'utility:preview', iconPosition: 'right'
        } 
    },*/
    { label: 'Download', type:  'button',  initialWidth: 150, typeAttributes: { 
            label: 'Download', name: 'Download', variant: 'brand', iconName: 'action:download', 
            iconPosition: 'right' 
        } 
    },
    { label: 'Delete', type:  'button',  initialWidth: 150, typeAttributes: { 
            label: 'Delete',   name: 'Delete',   variant: 'destructive',iconName: 'utility:delete', 
            iconPosition: 'right' 
        } 
    } 
];

export default class CommunityCaseFiles extends NavigationMixin(LightningElement) {

    @api caseStatus;
    @track caseOpen = true;
    @api title;
    @api showDetails;
    @api showFileUpload;
    @api showsync = false;
    @api recordId;
    @api usedInCommunity;
    @api showFilters = false;
    @api accept = '.doc,.docx,.jpeg,.jpg,.odt,.pdf,.png,.ppt,.pptx,.rtf,.xls,.xlsx';

    @track dataList;
    @track columnsList = columns;
    isLoading = false;

    wiredFilesResult;

  async  connectedCallback() {
        this.handleSync();
        this.showFileUpload = true;
        this.usedInCommunity = true;
        if (this.caseStatus == 'Closed'){
            this.caseOpen = false;
        } else {
            this.caseOpen = true;
        }
    }

    getBaseUrl(){
        let baseUrl = 'https://'+location.host+'/';
        return baseUrl;
    }

    handleRowAction(event){

        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch (actionName) {
            case 'Preview':
                this.previewFile(row);
                break;
            case 'Download':
                this.downloadFile(row);
                break;
            case 'Delete':
                this.handleDeleteFiles(row);
                break;
            default:
        }

    }

    previewFile(file){
        
        if(!this.usedInCommunity){
            
            this[NavigationMixin.Navigate]({
                type: 'standard__namedPage',
                attributes: {
                    pageName: 'filePreview'
                },
                state : {
                    selectedRecordId: file.ContentDocumentId
                }
            });
        } else if(this.usedInCommunity){
            
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: file.fileUrl
                }
            }, false );
        }
        
    }

    downloadFile(file){
        this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: file.downloadUrl
                }
            }, false 
        );
    }

    handleDeleteFiles(row){

        this.isLoading = true;

        deleteContentDocument({
            recordId : row.ContentDocumentId
        })
        .then(result => {
            this.dataList  = this.dataList.filter(item => {
                return item.ContentDocumentId !== row.ContentDocumentId ;
            });
        })
        .catch(error => {
            console.error('**** error **** \n ',error)
        })
        .finally(()=>{
            this.isLoading = false;
        });
    }

    handleSync(){
        let imageExtensions = ['png','jpg','gif'];
        let supportedIconExtensions = ['ai','attachment','audio','box_notes','csv','eps','excel','exe',
                        'flash','folder','gdoc','gdocs','gform','gpres','gsheet','html','image','keynote','library_folder',
                        'link','mp4','overlay','pack','pages','pdf','ppt','psd','quip_doc','quip_sheet','quip_slide',
                        'rtf','slide','stypi','txt','unknown','video','visio','webex','word','xml','zip'];

        this.isLoading = true;
        getContentDetails({
            recordId : this.recordId
        })
        .then(result => {
            // let parsedData = JSON.parse(result);
            // let stringifiedData = JSON.stringify(parsedData);
            // let finalData = JSON.parse(stringifiedData);
            let finalData = result;
            let baseUrl = this.getBaseUrl();
            finalData.forEach(file => {
                file.downloadUrl = baseUrl+'sfc/servlet.shepherd/document/download/'+file.ContentDocumentId;
                file.fileUrl     = baseUrl+'sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId='+file.Id;
                file.CREATED_BY  = file.ContentDocument.CreatedBy.Name;
                file.Size        = this.formatBytes(file.ContentDocument.ContentSize, 2);

                let fileType = file.ContentDocument.FileType.toLowerCase();
                if(imageExtensions.includes(fileType)){
                    file.icon = 'doctype:image';
                }else{
                    if(supportedIconExtensions.includes(fileType)){
                        file.icon = 'doctype:' + fileType;
                    }
                }
            });
            this.dataList = finalData;
        })
        .catch(error => {
            console.error('**** error **** \n ',error)
        })
        .finally(()=>{
            this.isLoading = false;
        });
    }

    handleUploadFinished(){
        this.handleSync();
        //eval("$A.get('e.force:refreshView').fire();");
    }
    formatBytes(bytes,decimals) {
        if(bytes == 0) return '0 Bytes';
        var k = 1024,
            dm = decimals || 2,
            sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'],
            i = Math.floor(Math.log(bytes) / Math.log(k));
        return parseFloat((bytes / Math.pow(k, i)).toFixed(dm)) + ' ' + sizes[i];
    }

    handleSearch(event){
        let value = event.target.value;
        let name  = event.target.name;
        if( name === 'Title' ){
            this.dataList = this.dataList.filter( file => {
                return file.Title.toLowerCase().includes(value.toLowerCase());
            });
        } else if( name === 'Created By' ){
            this.dataList = this.dataList.filter( file => {
                return file.CREATED_BY.toLowerCase().includes(value.toLowerCase());
            });
        }
    }
}