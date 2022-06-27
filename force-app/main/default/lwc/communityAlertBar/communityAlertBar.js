import {LightningElement, track, wire} from 'lwc';
import {getRecord} from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import UserType from '@salesforce/schema/User.User_Type__c';
import fetchAlertBar from '@salesforce/apex/communityOpenClass.fetchAlertBar';
import logo from '@salesforce/contentAssetUrl/CurrentlogoRGB500x125jpg';


export default class CommunityAlertBar extends LightningElement {

    @track error;
    @track AlertActive = false;
    @track communityContentRecords;
    @track hyperlink;
    @track listingType = 'Alert Bar';
    @track companyLogo = logo;
    //@track personaType = 'All';
    @track message;
    @track showAlertBar = false;

    /*@wire(fetchAlertBar, { userType: this.personaType, listingType: this.listingType}) wireuser({
        error,data
    }) {
        if (error) {
        this.error = error;

        } else if (data) {
            this.communityContentRecords = data;
             this.message = data[0].Alert_Bar_Message__c;

        if(data[0].Show_Alert_Bar__c = true){
            this.showAlertBar = true;
        }
        }
    }*/


   async connectedCallback() {
        let alertBarStatus = localStorage.getItem('disableAlertBar');
        console.log('GETTING ATTRIBUTE FOR - disableAlertBar...');

        var siteURL = window.location.href;
        fetchAlertBar({listingType: this.listingType})
            .then(result => {
                this.communityContentRecords = result;
                this.message = result[0].Alert_Bar_Message__c;
                this.AlertActive = result[0].Show_Alert_Bar__c;
                if (this.AlertActive = true && siteURL == 'https://stage-gecurrent.cs91.force.com/Agents/s/login/SelfRegister') {
                    this.showAlertBar = false;
                } else if(alertBarStatus == "YES"){
                    this.showAlertBar = false;
                } else {
                    this.showAlertBar = true;
                }
                //this.hyperlink = this.shipmentRecord[0].CCL_Order_Apheresis__r.CCL_Apheresis_Collection_Center__r.Name;
            })
            .catch(error => {
                this.error = error;
            });
    }

    closeAlertBar() {
        localStorage.setItem('disableAlertBar', "YES")
        this.showAlertBar = false;
    }


}