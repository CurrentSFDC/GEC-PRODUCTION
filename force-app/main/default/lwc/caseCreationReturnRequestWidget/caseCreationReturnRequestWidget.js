import { LightningElement, track, wire } from 'lwc';
import returnImage from '@salesforce/contentAssetUrl/geciconreturnsWT';
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import UserType from '@salesforce/schema/User.User_Type__c';

export default class CaseCreationReturnRequestWidget extends LightningElement {

    returnImage = returnImage;
    @track isAgent = false;

    @wire(getRecord, {
        recordId: USER_ID,
        fields: [UserType]
            }) wireuser({
                    error,
                    data
            }) {
                    if (error) {
                        console.log("Error In Return Request: ", error);
                    } else if (data) {
                        if (data.fields.User_Type__c.value == "Agent") {
                            this.isAgent = true;
                        } 
                    }
            }

    openReturn(event){
        var baseURL = window.location.origin
            this.sfdcOrgURL = baseURL+'/s/return-replace'
            window.open(this.sfdcOrgURL,'_top')
            console.log(("please check the Link for return: "+this.sfdcOrgURL))
    }
    openSAR(event){
        var baseURL = window.location.origin
            this.sfdcOrgURL = baseURL+'/s/stock-balancing-return'
            window.open(this.sfdcOrgURL,'_top')
            console.log(("please check the Link for stock Accomodation Return: "+this.sfdcOrgURL))
    }
}