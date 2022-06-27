import { LightningElement, track, wire } from 'lwc';
import salesSupport from '@salesforce/contentAssetUrl/geciconsalessupportWT';
import USER_ID from '@salesforce/user/Id';
import getUserType from '@salesforce/apex/communityOpenClass.getUserType';

export default class CaseCreationSalesSupportWidget extends LightningElement {

    @track isAgent = false;
    @track userType;

    salesSupport = salesSupport;

    connectedCallback() {

        getUserType({UserId: USER_ID})
         .then(result => {
            this.userType = result;
            if(this.userType == 'Agent') {
                this.isAgent = true;
            }
         })
         .catch(error => {
            console.log("getUserType Error : ", error);
            this.error = error ;
         });
    }

    openNewSpec(event){
        var baseURL = window.location.origin
        this.sfdcOrgURL = baseURL+'/s/new-spec-registration'
        window.open(this.sfdcOrgURL,'_top')
        console.log(("please check the Link: "+this.sfdcOrgURL))
    }

    openLDR(event) {
        var requestURL = window.location.href;
        var baseURL = window.location.origin
        this.sfdcOrgURL = baseURL+'/s/lighting-design'+'?requestURL='+requestURL;
        window.open(this.sfdcOrgURL,'_top')
        console.log(("please check the Link: "+this.sfdcOrgURL))
    }

    openMarketing(event) {
        var baseURL = window.location.origin
        this.sfdcOrgURL = baseURL+'/s/marketing-collateral'
        window.open(this.sfdcOrgURL,'_top')
        console.log(("please check the Link: "+this.sfdcOrgURL))
    }
    openTechSupport(event) {
        var baseURL = window.location.origin
        this.sfdcOrgURL = baseURL+'/s/technical-service'
        window.open(this.sfdcOrgURL,'_top')
        console.log(("please check the Link: "+this.sfdcOrgURL))
    }
}