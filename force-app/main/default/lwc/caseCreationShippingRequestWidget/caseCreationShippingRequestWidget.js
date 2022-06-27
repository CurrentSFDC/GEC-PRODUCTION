import { LightningElement } from 'lwc';
import shippingIssue from '@salesforce/contentAssetUrl/geciconshippingissuesWTpng';

export default class CaseCreationShippingRequestWidget extends LightningElement {

    shippingIssue = shippingIssue; 

    openOverage(event){
        var baseURL = window.location.origin
            this.sfdcOrgURL = baseURL+'/s/shipping-discrepancy'+'?type=Overage'
            window.open(this.sfdcOrgURL,'_top')
            console.log(("please check the Link: "+this.sfdcOrgURL))
    }

    openShortage(event){
        var baseURL = window.location.origin
            this.sfdcOrgURL = baseURL+'/s/shipping-discrepancy'+'?type=Shortage'
            window.open(this.sfdcOrgURL,'_top')
            console.log(("please check the Link: "+this.sfdcOrgURL))
    }

    openLostDamaged(event){
        var baseURL = window.location.origin
            this.sfdcOrgURL = baseURL+'/s/shipping-discrepancy'+'?type=Lost'
            window.open(this.sfdcOrgURL,'_top')
            console.log(("please check the Link: "+this.sfdcOrgURL))
    }
}