import { LightningElement, track, wire } from 'lwc';
//import DisFx_Webinar from '@salesforce/resourceUrl/DisFx_Webinar';
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import UserType from '@salesforce/schema/User.User_Type__c';
import fetchCommunityContentData from '@salesforce/apex/communityOpenClass.fetchCommunityContentData';

export default class FeatureCarousel extends LightningElement {
    @track user_Type;
    @track recordId;
    @track error;
    @track communityContentRecords;
    @track hyperlink;
    @track listingType = 'Feature Carousel';
    @track personaType = 'All';

    //DisFx_Webinar_image = DisFx_Webinar;

    @wire(getRecord, {
        recordId: USER_ID,
        fields: [UserType]
    }) wireuser({
        error,data
    }) {
        if (error) {
        this.error = error;
        console.log('ERROR: '+JSON.stringify(this.error));
        } else if (data) {
            this.user_Type = data.fields.User_Type__c.value;
            console.log('user_Type: '+this.user_Type);
            this.getCommunityContentData();
        }
    }

    getCommunityContentData()
    {
        fetchCommunityContentData({ userType: this.personaType, listingType: this.listingType})
       .then(result => {
        this.communityContentRecords = result;
        console.log('communityContentRecords: '+JSON.stringify(this.communityContentRecords));
        //this.hyperlink = this.shipmentRecord[0].CCL_Order_Apheresis__r.CCL_Apheresis_Collection_Center__r.Name;
      })
      .catch(error => {
        this.error = error;
      });
    }
}