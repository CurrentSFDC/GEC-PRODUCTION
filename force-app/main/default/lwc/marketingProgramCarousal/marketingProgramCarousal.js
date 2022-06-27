import {LightningElement, track, wire, api} from 'lwc';
import {getRecord} from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import UserType from '@salesforce/schema/User.User_Type__c';
import fetchCommunityContentData from '@salesforce/apex/communityOpenClass.fetchCommunityContentData';

export default class MarketingProgramCarousal extends LightningElement {

    @track user_Type;
    @track recordId;
    @track error;
    @track communityContentRecords;
    @track hyperlink;
    @api listingType = ' ';
    //api personaType = 'All';
    @track items = [];

    //DisFx_Webinar_image = DisFx_Webinar;

    @wire(getRecord, {
        recordId: USER_ID,
        fields: [UserType]
    }) wireuser({error, data}) {
        if (error) {
            this.error = error;
        } else if (data) {

            this.user_Type = data.fields.User_Type__c.value;
            this.getCommunityContentData();
        }
    }

    /*async connectedCallback(){


        await fetchCommunityContentData({ userType: this.user_Type, listingType: this.listingType})
       .then(result => {

        this.communityContentRecords = result;
        this.setCarouselData();
      })
      .catch(error => {
        this.error = error;
      });
    }*/

   getCommunityContentData() {
        fetchCommunityContentData({userType: this.user_Type, listingType: this.listingType})
            .then(result => {
                this.communityContentRecords = result;
                this.setCarouselData();
            })
            .catch(error => {
                this.error = error;
            });
    }

    setCarouselData() {
        this.communityContentRecords.forEach(element => {
            if (element.Content_Type__c !== 'Video') {
                let data1 = {
                    image: element.IMG_URL__c,
                    header: element.Title__c,
                    description: element.Description__c,
                    href: '/Agents/s/content?communityContentId=' + element.Id
                };
                this.items.push(data1);
            } else {
                let data2 = {
                    video: element.Image_URL__c,
                    header: element.Title__c,
                    description: element.Description__c,
                    href: ''
                };
                this.items.push(data2);
            }
        });
        // this.items = this.items.reverse();
    }

    options = {autoScroll: true, autoScrollTime: 10};
    // items = [
    //     {
    //         image: 'https://gecurrent--cmtydev--c.documentforce.com/sfc/servlet.shepherd/version/renditionDownload?rendition=ORIGINAL_Png&versionId=068c0000001Xfof&operationContext=CHATTER&contentId=05Tc0000007BUdm',
    //         header: 'Learn About Current\'\s ProLine Contractor Program',
    //         description: 'We are Always on — a Current Professional is always available to provide you with a solution.',
    //         href: 'https://cmtydev-gecurrent.cs14.force.com/Agents/s/test'
    //     },
    //     {
    //         image: 'https://gecurrent--cmtydev--c.documentforce.com/sfc/servlet.shepherd/version/renditionDownload?rendition=ORIGINAL_Png&versionId=068c0000001Xfou&operationContext=CHATTER&contentId=05Tc0000007BUe1',
    //         header: 'QuickStock',
    //         description: 'Current\'\s program to deliver selected products within two business days.',
    //         href: 'https://cmtydev-gecurrent.cs14.force.com/Agents/s/test'
    //     },
    //     {
    //         image: 'https://gecurrent--cmtydev--c.documentforce.com/sfc/servlet.shepherd/version/renditionDownload?rendition=ORIGINAL_Png&versionId=068c0000001Xfok&operationContext=CHATTER&contentId=05Tc0000007BUdr',
    //         header: 'QuickConfigure',
    //         description: 'Current\'\s program to ship selected products quickly.',
    //         href: 'https://cmtydev-gecurrent.cs14.force.com/Agents/s/test'
    //     },
    //     {
    //         image: 'https://gecurrent--cmtydev--c.documentforce.com/sfc/servlet.shepherd/version/renditionDownload?rendition=ORIGINAL_Png&versionId=068c0000001Xfok&operationContext=CHATTER&contentId=05Tc0000007BUdr',
    //         header: 'Understand what the QuickShip program can do for you.',
    //         description: 'Understand Current\'\s QuickShip offering',
    //         href: 'https://cmtydev-gecurrent.cs14.force.com/Agents/s/test'
    //     },
    //     {
    //         image: 'https://gecurrent--cmtydev--c.documentforce.com/sfc/servlet.shepherd/version/renditionDownload?rendition=ORIGINAL_Png&versionId=068c0000001Xfoz&operationContext=CHATTER&contentId=05Tc0000007BUe6',
    //         header: 'Current\'\s program to Support Distributors',
    //         description: 'Understand Voltage\'\s benefits and the program\'\s qualification criteria',
    //         href: 'https://cmtydev-gecurrent.cs14.force.com/Agents/s/test'
    //     },
    //     {
    //         video: 'SLaWOkc3bC8',
    //         header: 'Carousel Video 1',
    //         description: 'Demo video for carousel.',
    //     },
    // ];

}