import { LightningElement, track, wire, api } from 'lwc';
//import DisFx_Webinar from '@salesforce/resourceUrl/DisFx_Webinar';
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import UserType from '@salesforce/schema/User.User_Type__c';
import MANAGE_CONTENT_FIELD from '@salesforce/schema/User.Manage_Community_Content__c';
import fetchCommunityContentData from '@salesforce/apex/communityOpenClass.fetchCommunityContentData';

export default class NewProductIntroduction extends LightningElement {
    @track user_Type;
    @track recordId;
    @track error;
    @track manageContent;
    @track communityContentRecords;
    @track hyperlink;
    @api listingType = ' ';
    @track personaType = 'All';

    //DisFx_Webinar_image = DisFx_Webinar;

    @wire(getRecord, {
        recordId: USER_ID,
        fields: [UserType, MANAGE_CONTENT_FIELD]
    }) wireuser({
        error,data
    }) {
        if (error) {
        this.error = error;
        console.log('ERROR: '+JSON.stringify(this.error));
        } else if (data) {
            this.user_Type = data.fields.User_Type__c.value;
            this.manageContent = data.fields.Manage_Community_Content__c.value;
            console.log('user_Type: '+this.user_Type);
            if(this.user_Type == '' && this.manageContent == true){
                this.user_Type = 'All';
            }
            this.getCommunityContentData();
        }
    }

    getCommunityContentData()
    {
        fetchCommunityContentData({ userType: this.user_Type, listingType: this.listingType})
       .then(result => {
        this.communityContentRecords = result;
        console.log('communityContentRecords: '+JSON.stringify(this.communityContentRecords));
        //this.hyperlink = this.shipmentRecord[0].CCL_Order_Apheresis__r.CCL_Apheresis_Collection_Center__r.Name;
      })
      .catch(error => {
        this.error = error;
      });
    }

    onClickHandle(event){
        let commID = event.target.id;
        let explodeId = commID.split('-');
        commID = explodeId[0];
        console.log('Content ID Clicked: '+commID);
        let newURL = '/s/content?communityContentId=' + commID;
        window.open(newURL, '_self');
    }
}