import { LightningElement } from 'lwc';
import warranty from '@salesforce/contentAssetUrl/geciconwarrantyWT';

export default class CaseCreationWarrantyClaimWidget extends LightningElement {

    warranty = warranty;

    openWarranty(event){
        var baseURL = window.location.origin
            this.sfdcOrgURL = baseURL+'/s/warranty-claim'
            window.open(this.sfdcOrgURL,'_top')
            console.log(("please check the Link: "+this.sfdcOrgURL))
    }
}