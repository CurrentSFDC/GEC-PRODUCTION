import { LightningElement,wire,track,api } from 'lwc';
import createAssetFile from '@salesforce/apex/FileUploadViewController.createAssetFile';
//import uploadFile from '@salesforce/apex/FileUploadViewController.uploadFile';
import createContentVersion from '@salesforce/apex/FileUploadViewController.createContentVersion';
import getDocumentID from '@salesforce/apex/FileUploadViewController.getDocumentID';
import createDistribution from '@salesforce/apex/FileUploadViewController.createDistribution';
import getCommSalesKits from '@salesforce/apex/CommunityContentController.getCommSalesKits';
import getCommMedia from '@salesforce/apex/CommunityContentController.getCommMedia';

import { createRecord } from 'lightning/uiRecordApi';
import { updateRecord } from 'lightning/uiRecordApi';
import { deleteRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';


import COMMUNITY_CONTENT_OBJECT from '@salesforce/schema/Community_Content__c';
import LISTING_TYPE_FIELD from '@salesforce/schema/Community_Content__c.Listing_Type__c';
import CONTENT_TYPE_FIELD from '@salesforce/schema/Community_Content__c.Content_Type__c';
import PERSONA_TYPE_FIELD from '@salesforce/schema/Community_Content__c.Persona__c';
import DISPLAY_DATE_FIELD from '@salesforce/schema/Community_Content__c.Display_Date__c';
import HYPERLINK_SYSTEM_FIELD from '@salesforce/schema/Community_Content__c.Hyperlink_System_Name__c';
import OPEN_HYPERLINK_FIELD from '@salesforce/schema/Community_Content__c.Open_Hyperlink_In__c';
import NAME_FIELD from '@salesforce/schema/Community_Content__c.Name';
import TITLE_FIELD from '@salesforce/schema/Community_Content__c.Title__c';
import DESCRIPTION_FIELD from '@salesforce/schema/Community_Content__c.Description__c';
import IMG_URL_FIELD from '@salesforce/schema/Community_Content__c.IMG_URL__c';
import IMAGE_ALT_TEXT_FIELD from '@salesforce/schema/Community_Content__c.Image_Alternate_Text__c';
import LISTING_START_FIELD from '@salesforce/schema/Community_Content__c.Listing_Start_Date__c';
import LISTING_END_FIELD from '@salesforce/schema/Community_Content__c.Listing_End_Date__c';
import HEADER_ONE_FIELD from '@salesforce/schema/Community_Content__c.Subtitle_1_Header__c';
import DESCRIPTION_ONE_FIELD from '@salesforce/schema/Community_Content__c.Subtitle_1_Description__c';
import HEADER_TWO_FIELD from '@salesforce/schema/Community_Content__c.Subtitle_2_Header__c';
import DESCRIPTION_TWO_FIELD from '@salesforce/schema/Community_Content__c.Subtitle_2_Description__c';
import ACCORDION_HEADER_FIELD from '@salesforce/schema/Community_Content__c.Accordion_Header__c';
import CALL_TO_ACTION_FIELD from '@salesforce/schema/Community_Content__c.Call_To_Action__c';
import HYPERLINK_FIELD from '@salesforce/schema/Community_Content__c.Hyperlink__c';
import ALERT_BAR_MESSAGE_FIELD from '@salesforce/schema/Community_Content__c.Alert_Bar_Message__c';
import SHOW_ALERT_FIELD from '@salesforce/schema/Community_Content__c.Show_Alert_Bar__c';
import LINK_MASK_FIELD from '@salesforce/schema/Community_Content__c.Hyperlink_Mask__c';
import ID_FIELD from '@salesforce/schema/Community_Content__c.Id';

//IMPORT THE COMMUNITY CONTENT SALES KIT OBJECT
import COMMUNITY_CONTENT_SALES_KIT_OBJECT from '@salesforce/schema/Community_Content_Sales_Kit__c';
import SK_NAME_FIELD from '@salesforce/schema/Community_Content_Sales_Kit__c.Name';
import TYPE_FIELD from '@salesforce/schema/Community_Content_Sales_Kit__c.Type__c';
import PORTAL_USER_FIELD from '@salesforce/schema/Community_Content_Sales_Kit__c.Portal_User_Type__c';
import CONTENT_ID_FIELD from '@salesforce/schema/Community_Content_Sales_Kit__c.Content_Id__c';
import COMMUNITY_CONTENT_FIELD from '@salesforce/schema/Community_Content_Sales_Kit__c.Community_Content__c';
import FILE_URL_FIELD from '@salesforce/schema/Community_Content_Sales_Kit__c.File_URL__c';

//IMPORT THE COMMUNITY CONTENT MEDIA OBJECT
import COMMUNITY_CONTENT_MEDIA_OBJECT from '@salesforce/schema/Community_Content_Media__c';
import MEDIA_NAME_FIELD from '@salesforce/schema/Community_Content_Media__c.Name';
import MEDIA_TYPE_FIELD from '@salesforce/schema/Community_Content_Media__c.Type__c';
import URL_FIELD from '@salesforce/schema/Community_Content_Media__c.URL__c';
import CONTENT_URL_FIELD from '@salesforce/schema/Community_Content_Media__c.Content_URL__c';
import MEDIA_ID_FIELD from '@salesforce/schema/Community_Content_Media__c.Media_Id__c';
import COMM_CONTENT_FIELD from '@salesforce/schema/Community_Content_Media__c.Community_Content__c';


const actions = [
    { label: 'Edit', name: 'edit'},
];

export default class ManageCommunityContent extends LightningElement {

    //COMMUNITY CONTENT OBJECT VARIABLES
    @track commTitle;
    @track commDescription;
    @track listingType;
    @track userType;
    @track contentType;
    @track commDisplayDate;
    @track commListingStart;
    @track commListingEnd;
    @track hyperlinkSystem;
    @track hyperOpenIn;
    @track commImageURL;
    @track commImageAlt;
    @track commSubHeadOne;
    @track commSubDesOne;
    @track commSubHeadTwo;
    @track commSubDesTwo;
    @track commAccHeader;
    @track commHyperName;
    @track commHyperURL;
    @track callToAction;
    @track imageUploaded = false;
    @track showAlertBar = false;
    @track alertMessage;
    @track alertFields = false;
    @track commContentID = " "; // ID of the record created from the createContent method
    @track contentID; // ID of the Content Document created in the Upload Function (Step 1)


    //COMMUNITY CONTENT SALES KIT OBJECT VARIABLES
    @track portalType;
    @track type;
    @track salesKitConID; //ID of the Content Document through Upload Function in Add Sales Kits
    @track skName;
    @track salesKits = []; // List of records returned from Apex after Sales Kit insertion
    @track salesKitID; //ID of the Sales Kit record created from createSalesKit method
    @track fileURL;

    //COMMUNITY CONTENT MEDA OBJECT VARIBALES
    @track mediaName;
    @track mediaURL;
    @track mediaType;
    @track mediaConID; // ID of the Content Document through the Upload Function in Add Media
    @track commMedia = []; //  List of records return from Apex after Media Insertion
    @track mediaID; //ID of the Media record created from createMedia method
    @track conID; //Content Version ID for the Media uploaded

    // VARIABLES FOR THE FILE UPLOAD FUNCTION
    @track files = []; // TEMPORARILY STORES THE FILES UPLOADED IN THE FILEUPLOADVIEWER COMPONENT
    @track filesToInsert = []; 
    @track lstAllFiles = [];
    @track contentVersionID;
    @track fileData;
    @track imageMessage;
    @track recFormat;
    @track showUpload = false;
    @track showNextButton = true;
    @track isImage = true;
    @track uploadTitle = "Image Upload";
    @track detailMessage = ' ';
    @track showDetailMessage = false;
    
    @track showDates = false;
    @track showFunctions = false;
    @track showTraining = false;
    @track communityPage = false;
    @track addSalesKitModal = false;
    @track addMediaModal = false;
    @track isYouTube = false;
    @track isVimeo = false;
    @track mediaImage = false;
    @track disableMediaID = false;
    MAX_FILE_SIZE = 5300000;

    @track currentStep;

    @wire(getObjectInfo, { objectApiName: COMMUNITY_CONTENT_OBJECT })
    objectInfo;
    //For Picklist Values of Influence Roles
    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: LISTING_TYPE_FIELD})
    ListingPicklistValues;

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: CONTENT_TYPE_FIELD})
    ContentPicklistValues;

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: PERSONA_TYPE_FIELD})
    PersonaPicklistValues;

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: HYPERLINK_SYSTEM_FIELD})
    HyperLinkPicklistValues;

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: OPEN_HYPERLINK_FIELD})
    OpenInPicklistValues;

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: CALL_TO_ACTION_FIELD})
    CallToActionPicklistValues;
//---------------------------------------------------------------------------------------------------
    @wire(getObjectInfo, { objectApiName: COMMUNITY_CONTENT_SALES_KIT_OBJECT })
    skobjectInfo;

    @wire(getPicklistValues, { recordTypeId: '$skobjectInfo.data.defaultRecordTypeId', fieldApiName: PORTAL_USER_FIELD})
    PortalPicklistValues;

    @wire(getPicklistValues, { recordTypeId: '$skobjectInfo.data.defaultRecordTypeId', fieldApiName: TYPE_FIELD})
    TypePicklistValues;
//----------------------------------------------------------------------------------------------------
   
    @wire(getObjectInfo, { objectApiName: COMMUNITY_CONTENT_MEDIA_OBJECT })
    mediaobjectInfo;

    @wire(getPicklistValues, { recordTypeId: '$mediaobjectInfo.data.defaultRecordTypeId', fieldApiName: MEDIA_TYPE_FIELD})
    MediaTypePicklistValues;
//----------------------------------------------------------------------------------------------------


formats = ['list' ];

    appliedFormats = {
       
        list: true,
  
     };

     @track skColumns = [{
        label: 'Name',
        fieldName: 'Name',
        type: 'Text',
        sortable: true
    },
    {
        label: 'User Type',
        fieldName: 'Portal_User_Type__c',
        type: 'Text',
        sortable: true,
        cellAttributes: { alignment: 'center' }
    },
    {
        label: 'Type',
        fieldName: 'Type__c',
        type: 'Text',
        sortable: true,
        hideDefaultActions: true,
        cellAttributes: { alignment: 'center' }
    },
    {
        label: 'Content ID',
        fieldName: 'Content_Id__c',
        type: 'text',
        sortable: true
    },
            
   {
        type: 'button-icon',
        initialWidth: 34,
        typeAttributes:{
            label: 'Delete',
            name: 'delete',
            
            title: 'delete',
            iconName: 'utility:delete',
            variant: 'brand'
        },
        
      
    },

    ]; 

    @track mediaColumns = [{
        label: 'Name',
        fieldName: 'Name',
        type: 'Text',
        sortable: true
    },
    {
        label: 'Type',
        fieldName: 'Type__c',
        type: 'Text',
        sortable: true,
        cellAttributes: { alignment: 'center' }
    },
    {
        label: 'URL',
        fieldName: 'URL__c',
        type: 'Text',
        sortable: true,
        hideDefaultActions: true,
        cellAttributes: { alignment: 'center' }
    },
    {
        label: 'Media ID',
        fieldName: 'Media_Id__c',
        type: 'text',
        sortable: true
    },
            
    {
        type: 'button-icon',
        initialWidth: 34,
        typeAttributes:{
            label: 'Delete',
            name: 'delete',
            title: 'delete',
            iconName: 'utility:delete',
            variant: 'brand'
        },
        
      
    },

    ];


    setFormat() {
        const editor = this.template.querySelector('lightning-input-rich-text');
        editor.setFormat(this.appliedFormats);
    }

    goBackToStepOne(event) {
        this.currentStep = '1';
        this.template.querySelector('div.stepTwo').classList.add('slds-hide');
        this.template
            .querySelector('div.stepOne')
            .classList.remove('slds-hide');    
    }

    goToStepTwo(event) {
        this.currentStep = '2';
        this.template.querySelector('div.stepOne').classList.add('slds-hide');
        this.template.querySelector('div.stepTwo').classList.remove('slds-hide');
    }

    goBackToStepTwo(event) {
        this.currentStep = '2';
        this.template.querySelector('div.stepThree').classList.add('slds-hide');
        this.template.querySelector('div.stepTwo').classList.remove('slds-hide');
    }

    goToStepThree(event) {
        //this.commSubHeadOne = this.template.querySelector('.sho').value;

        this.currentStep = '3';
        this.template.querySelector('div.stepTwo').classList.add('slds-hide');
        this.template
            .querySelector('div.stepThree')
            .classList.remove('slds-hide');
    }

    goToStepFour(){
        this.currentStep = '4';
        
            this.template.querySelector('div.stepThree').classList.add('slds-hide');
            this.template
                .querySelector('div.stepFour')
                .classList.remove('slds-hide');
    }

    handlePick(event){
        this.listingType = event.target.value;
        if(this.listingType == "Trainings" || this.listingType == "Webinars" || this.listingType == "News" || this.listingType == "Marketing & Promotions"){
            this.showDates = true;
            this.showFunctions = true;
            this.alertFields = false;
            this.showUpload = true;
            this.recFormat = "PNG";
            this.imageMessage = "750px X 500px";
        } else if (this.listingType == "Feature Carousel" || this.listingType == "Marketing Promotions Carousel" || this.listingType == "New Product Introduction"){
            this.showDates = true;
            this.showFunctions = true;
            this.alertFields = false;
            this.showUpload = true;
            this.recFormat = "PNG";
            this.imageMessage = "896px X 233px";
        } else if (this.listingType == "Alert Bar"){
            this.showDates = false;
            this.showFunctions = false;
            this.alertFields = false;
            this.alertFields = true;
            this.showUpload = false;
            this.imageMessage = false;
        } else if(this.listingType == "Tools"){
            this.showDates = true;
            this.showFunctions = true;
            this.alertFields = false;
            //this.showNextButton = false;
            this.showUpload = true;
        } else if(this.listingType == "Connect Training Library"){
            this.showDates = true;
            this.showTraining = true;
            this.showFunctions = false;
            this.showUpload = true;
            this.alertFields = false;
            this.showNextButton = false;
        }
    }

    handlePersonaPick(event){
        this.userType = event.target.value;
    }

    handleContentPick(event){
        this.contentType = event.target.value;
    }

    handleHyperlinkPick(event){
        this.hyperlinkSystem = event.target.value;

        if(this.hyperlinkSystem == "SFDC: Community Page"){
            this.communityPage = true;
            this.showFunctions = true;
            window.alert("Note: Pictures for the Community Detail Page will be added on the next page under Media");
            this.detailMessage = "Pictures for the Community Detail Page will be added on the next page under Media";
            this.showDetailMessage = true;
        } else if (this.listingType == "Alert Bar"){
            this.alertFields = true;
            this.showFunctions = false;
            this.communityPage = false;
            this.showDates = false;
        } else if(this.hyperlinkSystem == "Document") {
            this.alertFields = false;
            this.communityPage = false;
            this.showFunctions = true;
            this.showDates = true;
            this.isImage = false;
            this.uploadTitle = "Document Upload";
            this.showDetailMessage = true;
        } else {
            this.alertFields = false;
            this.communityPage = false;
            this.showFunctions = true;
            this.showDates = true;
            this.isImage = true;
            this.uploadTitle = "Image Upload";
            this.showDetailMessage = false;
        }
    }

    handleHyperInPick(event){
        this.hyperOpenIn = event.target.value;
    }

    handlePortalPick(event){
        this.portalType = event.target.value;
    }

    handleTypePick(event){
        this.type = event.target.value;
    }

    handleMediaTypePick(event){
        this.mediaType = event.target.value;

        if(this.mediaType == "Local Image"){
            this.mediaImage = true;
            this.isYouTube = false;
            this.isVimeo = false;
        } else if(this.mediaType == "Youtube Link"){
            this.isYouTube = true;
            this.isVimeo = false;
            this.mediaImage = false;
        } else if (this.mediaType == "Image Link"){
            this.mediaImage = false;
            this.isVimeo = false;
            this.isYouTube = false;
            this.disableMediaID = true;
        } else if (this.mediaType == "Vimeo Link"){
            this.isVimeo = true;
            this.mediaImage = false;
            this.isYouTube = false;
            this.disableMediaID = true;
        }
    }

    handleCallPick(event){
        this.callToAction = event.target.value;
    }

    handleChecked(event){
        if(this.showAlertBar == false){
            this.showAlertBar = true;
        }else if(this.showAlertBar == true) {
            this.showAlertBar = false;
        }
    }

    addSalesKit(event){
        this.addSalesKitModal = true;
        this.salesKitConID = '';
        this.fileURL = '';
       
    }

    closeSalesKitModal(event){
        this.addSalesKitModal = false;
    }
    
    addMedia(event){
        this.addMediaModal = true;
        this.mediaURL = '';
        this.mediaConID = '';
    }

    closeMediaModal(event){
        this.addMediaModal = false;
    }


    createContent(event){

        const allValid = [...this.template.querySelectorAll('.validVal')]
            .reduce((validSoFar, inputCmp) => {
                        inputCmp.reportValidity();
                        return validSoFar && inputCmp.checkValidity();
            }, true);
                if (allValid) {
                    console.log('Community Content ID: '+this.commContentID);
                        if(this.commContentID == " "){

                        this.commTitle = this.template.querySelector('.ctle').value;
                        console.log('Title: '+this.commTitle);

                        const fields = {};
                        fields[NAME_FIELD.fieldApiName] = this.commTitle;
                        fields[TITLE_FIELD.fieldApiName] = this.commTitle;
                        const recordInput = { apiName: COMMUNITY_CONTENT_OBJECT.objectApiName, fields };
                        createRecord(recordInput)
                            .then(result => {
                                this.commContentID = result.id;
                                console.log('Community Content ID: '+this.commContentID);
                                this.goToStepTwo();
                            })
                        }else {
                            console.log('Show Next Button: '+this.showNextButton);
                            this.goToStepTwo();
                        }
        
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

    updateContent(event) {
        
        console.log('CONTENT CREATION EXECUTED.....');
        console.log('Listing Type: '+this.listingType);
        console.log('Hyperlink System: '+this.hyperlinkSystem);

        if (this.listingType == "Alert Bar"){
            console.log('Entering ALERT BAR BRANCH');
            this.alertMessage = this.template.querySelector('.alert').value;
            console.log('Alert Message: '+this.alertMessage);
            console.log('Show Alert Bar: '+this.showAlertBar);

            this.commDescription = this.template.querySelector('.des').value;
            console.log('Description: '+this.commDescription);

            this.commTitle = this.template.querySelector('.ctle').value;
            console.log('Title: '+this.commTitle);

            const fields = {};
            fields[ID_FIELD.fieldApiName] = this.commContentID;
            fields[NAME_FIELD.fieldApiName] = this.commTitle;
            fields[TITLE_FIELD.fieldApiName] = this.commTitle;
            fields[SHOW_ALERT_FIELD.fieldApiName] = this.showAlertBar;
            fields[ALERT_BAR_MESSAGE_FIELD.fieldApiName] = this.alertMessage;
            fields[DESCRIPTION_FIELD.fieldApiName] = this.commDescription; 
            fields[LISTING_TYPE_FIELD.fieldApiName] = this.listingType;
            const recordInput = { fields };
            updateRecord(recordInput)
                .then(() => {
                    //this.commContentID = result.id;
                    console.log('Community Content ID: '+this.commContentID);
                    
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Content created Successfully',
                            variant: 'success',
                        }),
                    );
                    this.goToStepFour();
                    
                })
                .catch(error => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error creating record',
                            message: error.body.message,
                            variant: 'error',
                        }),
                    );
                });

        } else if (this.listingType == "Connect Training Library"){
            console.log('Entering CONNECT TRAINING LIBRARY BRANCH');
           

            this.commTitle = this.template.querySelector('.ctle').value;
            console.log('Title: '+this.commTitle);
            this.commDescription = this.template.querySelector('.des').value;
            console.log('Description: '+this.commDescription);

            this.contentType = this.template.querySelector('.ct').value;
            console.log('Content Type: '+this.contentType);
            this.commDisplayDate = this.template.querySelector('.dd').value;
            console.log('Display Date: '+this.commDisplayDate);
            this.commListingStart = this.template.querySelector('.ls').value;
            console.log('Start Date: '+this.commListingStart);
            this.commListingEnd = this.template.querySelector('.le').value;
            console.log('End Date: '+this.commListingEnd);
            console.log('Open HyperLink In: '+this.hyperOpenIn);
            this.callToAction = this.template.querySelector('.cta').value;
            console.log('Call to Action: '+this.callToAction);
            this.commHyperURL = this.template.querySelector('.hurl').value;

            const fields = {};
            fields[ID_FIELD.fieldApiName] = this.commContentID;
                    fields[NAME_FIELD.fieldApiName] = this.commTitle;
                    fields[TITLE_FIELD.fieldApiName] = this.commTitle;
                    fields[DESCRIPTION_FIELD.fieldApiName] = this.commDescription; 
                    fields[LISTING_TYPE_FIELD.fieldApiName] = this.listingType;
                    fields[CONTENT_TYPE_FIELD.fieldApiName] = this.contentType;
                    fields[IMG_URL_FIELD.fieldApiName] = this.commImageURL;
                    fields[DISPLAY_DATE_FIELD.fieldApiName] = this.commDisplayDate;
                    fields[LISTING_START_FIELD.fieldApiName] = this.commListingStart;
                    fields[LISTING_END_FIELD.fieldApiName] = this.commListingEnd;
                    fields[PERSONA_TYPE_FIELD.fieldApiName] = this.userType;
                    fields[OPEN_HYPERLINK_FIELD.fieldApiName] = this.hyperOpenIn;
                    fields[HYPERLINK_FIELD.fieldApiName] = this.commHyperURL;
                    fields[CALL_TO_ACTION_FIELD.fieldApiName] = this.callToAction;
            const recordInput = { fields };
            updateRecord(recordInput)
                .then(() => {
                    //this.commContentID = result.id;
                    console.log('Community Content ID: '+this.commContentID);
                    
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Content created Successfully',
                            variant: 'success',
                        }),
                    );
                    this.goToStepFour();
                    
                })
                .catch(error => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error creating record',
                            message: error.body.message,
                            variant: 'error',
                        }),
                    );
                });
        
        } else  {
            console.log('ENTERING THE ELSE BRANCH');
            this.commTitle = this.template.querySelector('.ctle').value;
            console.log('Title: '+this.commTitle);
            this.commDescription = this.template.querySelector('.des').value;
            console.log('Description: '+this.commDescription);

            this.contentType = this.template.querySelector('.ct').value;
            console.log('Content Type: '+this.contentType);
            this.commDisplayDate = this.template.querySelector('.dd').value;
            console.log('Display Date: '+this.commDisplayDate);
            this.commListingStart = this.template.querySelector('.ls').value;
            console.log('Start Date: '+this.commListingStart);
            this.commListingEnd = this.template.querySelector('.le').value;
            console.log('End Date: '+this.commListingEnd);

            console.log('Image URL: '+this.commImageURL);
            this.commImageAlt = this.template.querySelector('.iat').value;
            console.log('Image Alternate Text: '+this.commImageAlt);

            console.log('HyperLink System Name: '+this.hyperlinkSystem)
            console.log('Open HyperLink In: '+this.hyperOpenIn);
            this.callToAction = this.template.querySelector('.cta').value;
            console.log('Call to Action: '+this.callToAction);
            this.commHyperURL = this.template.querySelector('.hurl').value;
            

            

                if (this.hyperlinkSystem == "SFDC: Community Page"){
                    console.log('COMMUNITY PAGE...');
                    this.commSubHeadOne = this.template.querySelector('.sho').value;
                    this.commSubDesOne = this.template.querySelector('.shdo').value;
                    this.commSubHeadTwo = this.template.querySelector('.sht').value;
                    this.commSubDesTwo = this.template.querySelector('.shdt').value;
                    this.commAccHeader = this.template.querySelector('.ah').value;
                    this.commHyperName = this.template.querySelector('.hn').value;
                    

                    const fields = {};
                    fields[ID_FIELD.fieldApiName] = this.commContentID;
                    fields[NAME_FIELD.fieldApiName] = this.commTitle;
                    fields[TITLE_FIELD.fieldApiName] = this.commTitle;
                    fields[DESCRIPTION_FIELD.fieldApiName] = this.commDescription; 
                    fields[LISTING_TYPE_FIELD.fieldApiName] = this.listingType;
                    fields[CONTENT_TYPE_FIELD.fieldApiName] = this.contentType;
                    fields[IMG_URL_FIELD.fieldApiName] = this.commImageURL;
                    fields[IMAGE_ALT_TEXT_FIELD.fieldApiName] = this.commImageAlt;
                    fields[DISPLAY_DATE_FIELD.fieldApiName] = this.commDisplayDate;
                    fields[LISTING_START_FIELD.fieldApiName] = this.commListingStart;
                    fields[LISTING_END_FIELD.fieldApiName] = this.commListingEnd;
                    fields[PERSONA_TYPE_FIELD.fieldApiName] = this.userType;
                    fields[HEADER_ONE_FIELD.fieldApiName] = this.commSubHeadOne;
                    fields[DESCRIPTION_ONE_FIELD.fieldApiName] = this.commSubDesOne;
                    fields[HEADER_TWO_FIELD.fieldApiName] = this.commSubHeadTwo;
                    fields[DESCRIPTION_TWO_FIELD.fieldApiName] = this.commSubDesTwo;
                    fields[ACCORDION_HEADER_FIELD.fieldApiName] = this.commAccHeader;
                    fields[HYPERLINK_SYSTEM_FIELD.fieldApiName] = this.hyperlinkSystem;
                    fields[OPEN_HYPERLINK_FIELD.fieldApiName] = this.hyperOpenIn;
                    fields[HYPERLINK_FIELD.fieldApiName] = this.commHyperURL;
                    fields[LINK_MASK_FIELD.fieldApiName] - this.commHyperName;
                    fields[CALL_TO_ACTION_FIELD.fieldApiName] = this.callToAction;

                    console.log('Executing UPDATE...');
                        const recordInput = { fields };
                        updateRecord(recordInput)
                            .then(() => {
                                //this.commContentID = result.id;
                                console.log('Community Content ID: '+this.commContentID);
                                this.dispatchEvent(
                                    new ShowToastEvent({
                                        title: 'Success',
                                        message: 'Content created Successfully',
                                        variant: 'success',
                                    }),
                                );
                                this.goToStepFour();
                                
                            })
                            .catch(error => {
                                this.dispatchEvent(
                                    new ShowToastEvent({
                                        title: 'Error creating record',
                                        message: error.body.message,
                                        variant: 'error',
                                    }),
                                );
                            });

                } else if (this.hyperlinkSystem == "Document"){
                    console.log('Entering ELSE Statement 2');
                    
                    //this.commHyperURL = this.template.querySelector('.hurl').value;
                
                    const fields = {};
                    fields[ID_FIELD.fieldApiName] = this.commContentID;
                    fields[NAME_FIELD.fieldApiName] = this.commTitle;
                    fields[TITLE_FIELD.fieldApiName] = this.commTitle;
                    fields[DESCRIPTION_FIELD.fieldApiName] = this.commDescription; 
                    fields[LISTING_TYPE_FIELD.fieldApiName] = this.listingType;
                    fields[CONTENT_TYPE_FIELD.fieldApiName] = this.contentType;
                    fields[DISPLAY_DATE_FIELD.fieldApiName] = this.commDisplayDate;
                    fields[LISTING_START_FIELD.fieldApiName] = this.commListingStart;
                    fields[LISTING_END_FIELD.fieldApiName] = this.commListingEnd;
                    fields[PERSONA_TYPE_FIELD.fieldApiName] = this.userType;
                    fields[HYPERLINK_SYSTEM_FIELD.fieldApiName] = this.hyperlinkSystem;
                    fields[OPEN_HYPERLINK_FIELD.fieldApiName] = this.hyperOpenIn;
                    fields[HYPERLINK_FIELD.fieldApiName] = this.commHyperURL;
                    fields[CALL_TO_ACTION_FIELD.fieldApiName] = this.callToAction;
                    fields[IMG_URL_FIELD.fieldApiName] = this.commImageURL;
                    //fields[IMAGE_ALT_TEXT_FIELD.fieldApiName] = this.commImageAlt;

                    console.log('Executing UPDATE...');
                    const recordInput = { fields };
                    updateRecord(recordInput)
                        .then(() => {
                            //this.commContentID = result.id;
                            console.log('Community Content ID: '+this.commContentID);
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Success',
                                    message: 'Content created Successfully',
                                    variant: 'success',
                                }),
                            );
                            this.goToStepFour();
                            
                        })
                        .catch(error => {
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Error creating record',
                                    message: error.body.message,
                                    variant: 'error',
                                }),
                            );
                        });
                
                } else {
                    {
                        console.log('Entering ELSE Statement 2');
                        
                        //this.commHyperURL = this.template.querySelector('.hurl').value;
                    
                        const fields = {};
                        fields[ID_FIELD.fieldApiName] = this.commContentID;
                        fields[NAME_FIELD.fieldApiName] = this.commTitle;
                        fields[TITLE_FIELD.fieldApiName] = this.commTitle;
                        fields[DESCRIPTION_FIELD.fieldApiName] = this.commDescription; 
                        fields[LISTING_TYPE_FIELD.fieldApiName] = this.listingType;
                        fields[CONTENT_TYPE_FIELD.fieldApiName] = this.contentType;
                        fields[DISPLAY_DATE_FIELD.fieldApiName] = this.commDisplayDate;
                        fields[LISTING_START_FIELD.fieldApiName] = this.commListingStart;
                        fields[LISTING_END_FIELD.fieldApiName] = this.commListingEnd;
                        fields[PERSONA_TYPE_FIELD.fieldApiName] = this.userType;
                        fields[HYPERLINK_SYSTEM_FIELD.fieldApiName] = this.hyperlinkSystem;
                        fields[OPEN_HYPERLINK_FIELD.fieldApiName] = this.hyperOpenIn;
                        fields[HYPERLINK_FIELD.fieldApiName] = this.commHyperURL;
                        fields[CALL_TO_ACTION_FIELD.fieldApiName] = this.callToAction;
                        fields[IMG_URL_FIELD.fieldApiName] = this.commImageURL;
                        fields[IMAGE_ALT_TEXT_FIELD.fieldApiName] = this.commImageAlt;
    
                        console.log('Executing UPDATE...');
                        const recordInput = { fields };
                        updateRecord(recordInput)
                            .then(() => {
                                //this.commContentID = result.id;
                                console.log('Community Content ID: '+this.commContentID);
                                this.dispatchEvent(
                                    new ShowToastEvent({
                                        title: 'Success',
                                        message: 'Content created Successfully',
                                        variant: 'success',
                                    }),
                                );
                                this.goToStepFour();
                                
                            })
                            .catch(error => {
                                this.dispatchEvent(
                                    new ShowToastEvent({
                                        title: 'Error creating record',
                                        message: error.body.message,
                                        variant: 'error',
                                    }),
                                );
                            });
                    
                    }
                }
        }
    }

    openfileUpload(event) {
        
        const file = event.target.files[0]
        if (file.size > this.MAX_FILE_SIZE){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'ERROR',
                    message: 'File to Large',
                    variant: 'error',
                }),
               
            );
        } else {
            //console.log('FILE ID: '+this.filesToInsert);
            var reader = new FileReader()
            reader.onload = () => {
                var base64 = reader.result.split(',')[1]
                this.fileData = {
                    'filename': file.name,
                    'base64': base64,
                    'documentId': file.Id
                }
                console.log(this.fileData)
            }
            reader.readAsDataURL(file)
        }
    }
    
    handleClick(event){
        const {base64, filename} = this.fileData
        createContentVersion({ base64, filename}).then(result=>{
            this.fileData = null
            let tmpItems = JSON.stringify(result);
            let newItems = JSON.parse(tmpItems);
            this.contentVersionID = newItems.Id;
            console.log('Content Version Id: '+this.contentVersionID);
            let title = `${filename} uploaded successfully!!`
            
               getDocumentID({conVerId: this.contentVersionID}).then(result=>{
                    let tmpId = JSON.stringify(result);
                    let newId = JSON.parse(tmpId);
                    this.contentID = newId.ContentDocumentId;
                    this.fileExtension = newId.FileExtension;

                    if(this.hyperlinkSystem == "Document"){
                        //this.commImageURL = "https://gecurrent--stage--c.documentforce.com/sfc/dist/version/renditionDownload?rendition=ORIGINAL_Png&versionId=0682F000000s1AdQAI&operationContext=DELIVERY&contentId=0692F000000rqTuQAI&page0&d=/a/2F0000000wrz/D3yKxpZKLOPWcq09Z1KnDUnXo_0DEuekNK2EP32exJE&oid=00D2F000000FWJD";
                        this.commImageURL = 'https://gecurrent--c.documentforce.com/sfc/dist/version/renditionDownload?rendition=ORIGINAL_Png&versionId='+this.contentVersionID+'&operationContext=DELIVERY&contentId='+this.contentID+'&page0&d=/a/'+tempURL+'&oid=00D3j000000hC5C';

                    }

                    console.log('FILE ID: '+this.contentID);
                    //this.commImageURL = 'https://gecurrent--stage--c.documentforce.com/sfc/servlet.shepherd/version/renditionDownload?rendition=ORIGINAL_Png&versionId='+this.contentVersionID+'&operationContext=CHATTER&contentId='+this.contentID;
                    //console.log('IMAGE URL: '+this.commImageURL);
            }) 
            this.createDistributionURL();
            
            this.toast(title)
        })
    }

    createDistributionURL(){
        createDistribution({conVerId: this.contentVersionID}).then(result=>{
            let tmpId = JSON.stringify(result);
            let newId = JSON.parse(tmpId);
            console.log('returned document url: '+newId[0].DistributionPublicUrl);
            this.distroURL = newId[0].DistributionPublicUrl;
            var baseURL = window.location.origin;
            console.log('BaseURL: '+baseURL);
            if(this.distroURL.includes('a/')==true){
                var tempURL = this.distroURL.split('a/')[1];
                console.log('Modified Distro URL: '+tempURL);
            }
            if(this.hyperlinkSystem == "Document"){
                //this.commImageURL = 'https://gecurrent--stage--c.documentforce.com/sfc/dist/version/renditionDownload?rendition=SVGZ&versionId='+this.contentVersionID+'&operationContext=DELIVERY&contentId='+this.contentID+'&page0&d=/a/'+tempURL+'&oid=00D2F000000FWJD';
                this.commHyperURL = this.distroURL;
                //this.commImageURL = 'https://gecurrent--c.documentforce.com/sfc/dist/version/renditionDownload?rendition=ORIGINAL_Png&versionId='+this.contentVersionID+'&operationContext=DELIVERY&contentId='+this.contentID+'&page0&d=/a/'+tempURL+'&oid=00D3j000000hC5C';
    
            } else {
              //this.commImageURL = 'https://gecurrent--stage--c.documentforce.com/sfc/dist/version/renditionDownload?rendition=ORIGINAL_Png&versionId='+this.contentVersionID+'&operationContext=DELIVERY&contentId='+this.contentID+'&page0&d=/a/'+tempURL+'&oid=00D2F000000FWJD';
                this.commImageURL = 'https://gecurrent--c.documentforce.com/sfc/dist/version/renditionDownload?rendition=ORIGINAL_Png&versionId='+this.contentVersionID+'&operationContext=DELIVERY&contentId='+this.contentID+'&page0&d=/a/'+tempURL+'&oid=00D3j000000hC5C';
    
            }
            //this.imageUploaded = true;
            this.showNextButton = false;
    })
}

    toast(title){
        const toastEvent = new ShowToastEvent({
            title, 
            variant:"success"
        })
        this.dispatchEvent(toastEvent)
    }

    handleSalesKitClick(event){
        const {base64, filename} = this.fileData
        createContentVersion({ base64, filename}).then(result=>{
            this.fileData = null
            let tmpItems = JSON.stringify(result);
            let newItems = JSON.parse(tmpItems);
            let conID = newItems.Id;
            console.log('Content Version Id: '+conID);
            let title = `${filename} uploaded successfully!!`
                getDocumentID({conVerId: conID}).then(result=>{
                    let tmpId = JSON.stringify(result);
                    let newId = JSON.parse(tmpId);
                    this.salesKitConID = newId.ContentDocumentId;
                    console.log('FILE ID: '+this.salesKitConID);
                    
                    createDistribution({conVerId: conID}).then(result=>{
                        let tmpId = JSON.stringify(result);
                        let newId = JSON.parse(tmpId);
                        console.log('returned document url: '+newId[0].DistributionPublicUrl);
                        this.distroURL = newId[0].DistributionPublicUrl;
                        var baseURL = window.location.origin;
                        console.log('BaseURL: '+baseURL);
                        if(this.distroURL.includes('a/')==true){
                            var tempURL = this.distroURL.split('a/')[1];
                            console.log('Modified Distro URL: '+tempURL);
                        }
            
                        this.fileURL = this.distroURL;   
                    }) 
                    
            })
            this.toast(title)
        })
    }

    createSalesKit(){
        this.skName = this.template.querySelector('.na').value;
        console.log('Name: '+this.skName);

        const fields = {};
        fields[SK_NAME_FIELD.fieldApiName] = this.skName;
        fields[TYPE_FIELD.fieldApiName] = this.type;
        fields[PORTAL_USER_FIELD.fieldApiName] = this.portalType;
        fields[CONTENT_ID_FIELD.fieldApiName] = this.salesKitConID;
        fields[COMMUNITY_CONTENT_FIELD.fieldApiName] = this.commContentID;
        fields[FILE_URL_FIELD.fieldApiName] = this.fileURL;
        const recordInput = { apiName: COMMUNITY_CONTENT_SALES_KIT_OBJECT.objectApiName, fields };
        createRecord(recordInput)
            .then(result => {
                this.salesKitID = result.id;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Sales Kit created Successfully',
                        variant: 'success',
                    }),
                   
                );
                this.getCommSalesKits(); 
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error creating record',
                        message: error.body.message,
                        variant: 'error',
                    }),
                );
            });

            this.addSalesKitModal = false;    
    }



    async getCommSalesKits(){
       await getCommSalesKits({ contentId: this.commContentID}).then(result=>{
            console.log('Passing Community Content ID: '+this.commContentID);
            this.salesKits = result;
            console.log('Sales Kits Returned: '+JSON.stringify(result));
        })
    }

    handleMediaClick(event){
        const {base64, filename} = this.fileData
        createContentVersion({ base64, filename}).then(result=>{
            this.fileData = null
            let tmpItems = JSON.stringify(result);
            let newItems = JSON.parse(tmpItems);
            this.conID = newItems.Id;
            console.log('Content Version Id: '+this.conID);
            let title = `${filename} uploaded successfully!!`
                getDocumentID({conVerId: this.conID}).then(result=>{
                    let tmpId = JSON.stringify(result);
                    let newId = JSON.parse(tmpId);
                    this.mediaConID = newId.ContentDocumentId;
                    console.log('FILE ID: '+this.mediaConID); 
                    createDistribution({conVerId: this.conID}).then(result=>{
                        let tmpId = JSON.stringify(result);
                        let newId = JSON.parse(tmpId);
                        console.log('returned document url: '+newId[0].DistributionPublicUrl);
                        this.distroURL = newId[0].DistributionPublicUrl;
                        var baseURL = window.location.origin;
                        console.log('BaseURL: '+baseURL);
                        if(this.distroURL.includes('a/')==true){
                            var tempURL = this.distroURL.split('a/')[1];
                            console.log('Modified Distro URL: '+tempURL);
                        }
                        //this.mediaURL = 'https://gecurrent--stage--c.documentforce.com/sfc/dist/version/renditionDownload?rendition=ORIGINAL_Png&versionId='+this.conID+'&operationContext=DELIVERY&contentId='+this.mediaConID+'&page0&d=/a/'+tempURL+'&oid=00D2F000000FWJD';
                        
                        this.mediaURL = 'https://gecurrent--c.documentforce.com/sfc/dist/version/renditionDownload?rendition=ORIGINAL_Png&versionId='+this.conID+'&operationContext=DELIVERY&contentId='+this.mediaConID+'&page0&d=/a/'+tempURL+'&oid=00D3j000000hC5C';

                        //this.commImageURL = 'https://gecurrent--c.documentforce.com/sfc/dist/version/renditionDownload?rendition=ORIGINAL_Png&versionId='+this.conID+'&operationContext=DELIVERY&contentId='+this.mediaConID+'&page0&d=/a/'+tempURL+'&oid=00D3j000000hC5C';
            
                            //this.mediaURL = this.distroURL;   
                    }) 
            })   
            this.toast(title)
        })
    }

    
    createMedia(){
        this.mediaName = this.template.querySelector('.mna').value;
        console.log('Name: '+this.mediaName);

        this.mediaURL = this.template.querySelector('.mur').value;
        console.log('URL: '+this.mediaURL);

        this.mediaConID = this.template.querySelector('.cid').value;
        console.log('Media ID: '+this.mediaConID);

        const fields = {};
        fields[MEDIA_NAME_FIELD.fieldApiName] = this.mediaName;
        fields[MEDIA_TYPE_FIELD.fieldApiName] = this.mediaType;
        if (this.mediaType == "Youtube Link"){
            fields[MEDIA_ID_FIELD.fieldApiName] = this.mediaConID;
        }
        fields[COMM_CONTENT_FIELD.fieldApiName] = this.commContentID;
        fields[CONTENT_URL_FIELD.fieldApiName] = this.mediaURL;
        const recordInput = { apiName: COMMUNITY_CONTENT_MEDIA_OBJECT.objectApiName, fields };
        createRecord(recordInput)
            .then(result => {
                this.mediaID = result.id;
                console.log('Media ID: '+this.mediaID);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Media created Successfully',
                        variant: 'success',
                    }),
                   
                );
                this.getCommMedia();
                
            })
            
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error creating record',
                        message: error.body.message,
                        variant: 'error',
                    }),
                );
            });

            this.addMediaModal = false;
            
             
    }

    getCommMedia(){
        let commID = this.commContentID;
        console.log('Passing Community Content ID: '+this.commContentID);
       getCommMedia({ contentId: commID}).then(result=>{
            
            this.commMedia = result;
            console.log('Media Returned: '+JSON.stringify(result));
        })
    }

    goHome(event){
        var baseURL = window.location.origin;
        console.log('Base URL: '+baseURL);
        this.sfdcOrgURL = baseURL+'/s/';
        console.log('New URL: '+this.sfdcOrgURL);
        window.open(this.sfdcOrgURL, "_self");
    }

    createNew(event){
        var baseURL = window.location.origin;
        console.log('Base URL: '+baseURL);
        this.sfdcOrgURL = baseURL+'/s/manage-comm-content';
        console.log('New URL: '+this.sfdcOrgURL);
        window.open(this.sfdcOrgURL, "_self");
    }

    // USED TO DELETE FILES FROM THE FILES UPLOAD TABLE
    handleDelete(event) {
        console.log('Executing Delete on File......');
        const row = event.detail.row;
        console.log('ROW ID Selected: '+row.Id);
        let contentDocumentId = row.Id;
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
                    const index = this.salesKits.indexOf(contentDocumentId);
                    this.salesKits.splice(index, 1);
                    if(this.salesKits.length > 0){
                        this.salesKits = true;
                    } else{
                        this.salesKits = false;
                    }
                })
                this.getCommSalesKits();
            }


}