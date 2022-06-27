import { LightningElement } from 'lwc';
import changeOrder from '@salesforce/contentAssetUrl/geciconaccoutorderchangeWT';

export default class CaseCreationOrderChangeWidget extends LightningElement {

    changeImage = changeOrder;

    openExpedite(event){
        var baseURL = window.location.origin
        this.sfdcOrgURL = baseURL+'/s/expedite'
        window.open(this.sfdcOrgURL,'_top')
        console.log(("please check the Link: "+this.sfdcOrgURL))
    }

    openChangeRequest(event){
        var baseURL = window.location.origin
            this.sfdcOrgURL = baseURL+'/s/change-request'
            window.open(this.sfdcOrgURL,'_top')
            console.log(("please check the Link: "+this.sfdcOrgURL))
    }
}