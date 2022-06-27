import { LightningElement, track, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';

import NAME_FIELD from '@salesforce/schema/User.Name';
import EMAIL_FIELD from '@salesforce/schema/User.Email';
import CONTACT_FIELD from '@salesforce/schema/User.ContactId';


export default class ProductPageButton extends NavigationMixin (LightningElement) {

    @track selectedItemValue;
    @track sfdcOrgURL;
    @api recordId;
    @api contactID;
    @api reqEmail;
    @api reqName;
    @api prodId;
    
    

    handleOnselect(event) {
        this.selectedItemValue = event.detail.value;
        
        
    }
    async redirectPricingRequest(event){
        
        console.log('The Prod ID: '+this.productName);
       // window.open('https://dev-gecurrent.cs92.force.com/Agents/s/pricing-request','_top')
       var baseURL = window.location.origin
       this.sfdcOrgURL = baseURL+'/Agents/s/pricing-request'+'?id='+ this.prodId;
       window.open(this.sfdcOrgURL, "_self");
       /*this[NavigationMixin.Navigate]({
           "type": "standard__webPage",
           "attributes": {
               //Here customLabelExampleAura is name of lightning aura component
               //This aura component should implement lightning:isUrlAddressable
               //"componentName": "c__expediteOrderProdLWC"
              "url": this.sfdcOrgURL
             
           }
       });*/



        //creating the custom event
        //const nextEvent = new CustomEvent('Change Request');
       // nextEvent.handleUpdate();
       
        //firing the event
       this.dispatchEvent(nextEvent);
       //this.handleUpdate();
        
      
    }
    async redirectNewSpec(){
        var baseURL = window.location.origin
       this.sfdcOrgURL = baseURL+'/Agents/s/new-spec-registration'+'?id='+this.prodId;
       console.log(("please check the Link: "+this.sfdcOrgURL))
       window.open(this.sfdcOrgURL, "_self");
       /*this[NavigationMixin.Navigate]({
           "type": "standard__webPage",
           "attributes": {
               //Here customLabelExampleAura is name of lightning aura component
               //This aura component should implement lightning:isUrlAddressable
               //"componentName": "c__expediteOrderProdLWC"
              "url": this.sfdcOrgURL
             
           }
       });*/

    }
    async redirectMarketing(){
        var baseURL = window.location.origin
       this.sfdcOrgURL = baseURL+'/Agents/s/marketing-collateral'+'?id='+this.prodId;
       console.log(("please check the Link: "+this.sfdcOrgURL))
       window.open(this.sfdcOrgURL, "_self");
       /*this[NavigationMixin.Navigate]({
           "type": "standard__webPage",
           "attributes": {
               //Here customLabelExampleAura is name of lightning aura component
               //This aura component should implement lightning:isUrlAddressable
               //"componentName": "c__expediteOrderProdLWC"
              "url": this.sfdcOrgURL
             
           }
       });*/

    }
    async redirectWhen(){
        console.log('The Product ID: '+this.prodId);
       var requestURL = window.location.href;
       var baseURL = window.location.origin
       this.sfdcOrgURL = baseURL+'/Agents/s/where-can-i-get'+'?id='+this.prodId+'?requestURL='+requestURL;
       console.log(("please check the Link: "+this.sfdcOrgURL))
       window.open(this.sfdcOrgURL, "_self");
       /*this[NavigationMixin.Navigate]({
           "type": "standard__webPage",
           "attributes": {
               //Here customLabelExampleAura is name of lightning aura component
               //This aura component should implement lightning:isUrlAddressable
               //"componentName": "c__expediteOrderProdLWC"
              "url": this.sfdcOrgURL
             
           }
       });*/



    }
    async redirectLightning(){
        var requestURL = window.location.href;
        var baseURL = window.location.origin
       this.sfdcOrgURL = baseURL+'/Agents/s/lighting-design'+'?id='+this.prodId+'?requestURL='+requestURL;
       console.log(("please check the Link: "+this.sfdcOrgURL))
       window.open(this.sfdcOrgURL, "_self");
       /*this[NavigationMixin.Navigate]({
           "type": "standard__webPage",
           "attributes": {
               //Here customLabelExampleAura is name of lightning aura component
               //This aura component should implement lightning:isUrlAddressable
               //"componentName": "c__expediteOrderProdLWC"
              "url": this.sfdcOrgURL
             
           }
       });*/

    }
}