import { LightningElement, track } from 'lwc';
import adjustment from '@salesforce/contentAssetUrl/geciconadjustmentsWT';
import USER_ID from '@salesforce/user/Id';

import getUserPerMissionSet from '@salesforce/apex/communityOpenClass.getUserPerMissionSet';

import getUserProfile from '@salesforce/apex/communityOpenClass.getUserProfile';
export default class CaseCreationAdjustmentWidget extends LightningElement {

    adjustment = adjustment;
    @track showCreateClaimback = false;

    connectedCallback() {

        this.getUserPermissions();
    
    }

    getUserPermissions() {

        var permissionSets = [];
    
        getUserPerMissionSet({UserId: USER_ID})
    
        .then(result => {
    
            permissionSets = result;
    
            getUserProfile({UserId: USER_ID})
    
            .then(result1 => {
    
                if (result1 == "Distributor Read Only B2B Storefront Registered Users" &&
    
                    permissionSets.includes("Distributor_Case_Management") ||
    
                    result1 == "Distributor B2B Storefront Registered Users") {
    
                        this.showCreateClaimback = true;
    
                }
    
            });
    
        });
    
    }
    
    openCredit(event){
        var baseURL = window.location.origin
            this.sfdcOrgURL = baseURL+'/s/adjustments'
            window.open(this.sfdcOrgURL,'_top')
            console.log(("please check the Link: "+this.sfdcOrgURL))
    }
    openClaimback(event){
        var baseURL = window.location.origin
            this.sfdcOrgURL = baseURL+'/s/claim-back'
            window.open(this.sfdcOrgURL,'_top')
            console.log(("please check the Link: "+this.sfdcOrgURL))
    }

    openRebill(event){
        var baseURL = window.location.origin
            this.sfdcOrgURL = baseURL+'/s/adjustments'
            window.open(this.sfdcOrgURL,'_top')
            console.log(("please check the Link: "+this.sfdcOrgURL))
    }
}