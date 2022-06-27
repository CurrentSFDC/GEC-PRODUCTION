import { LightningElement, track, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getOrderStatus from '@salesforce/apex/connectCreateCase.getOrderStatus';
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';
import EMAIL_FIELD from '@salesforce/schema/User.Email';
import CONTACT_FIELD from '@salesforce/schema/User.ContactId';

export default class ButtonMenuOnselect extends NavigationMixin (LightningElement) {
    @track selectedItemValue;
    @track sfdcOrgURL;
    @track chnExp=false;
    @track reqShort=false;
    @api recordId;
    @api orderStatus;
    @api orderNumber;
    @api orderSoldTo;
   // @api ordLines;
    @api contactID;
    @api reqEmail;
    @api reqName;
    //@api context;
   // @api orderNumber;
    @api orderId;
   
   // @api defOrderNew;

     //@wire(CONTACT_FIELD) od;

    // GET CURRENT LOGGED IN COMMUNITY USER INFORMATION
    /*@wire(getRecord, {
        recordId: USER_ID,
        fields: [NAME_FIELD, EMAIL_FIELD, CONTACT_FIELD ]
    }) wireuser({
        error,
        data
    }) {
        if (error) {
        this.error = error ; 
        } else if (data) {
            this.reqEmail = data.fields.Email.value;
            this.reqName = data.fields.Name.value;
            this.contactID = data.fields.ContactId.value;
           // this.orderNumber = data.orderDefValue.orderNumber.value;
           // this.orderId = data.fields.orderId.value;
            
        }
    }*/
   


   async handleUpdate(event){
    console.log('The Order ID: '+this.orderId);
      
               var baseURL = window.location.origin;
        
               this.sfdcOrgURL = baseURL+'/s/expedite'+'?id='+ this.orderId;
               
            
               this[NavigationMixin.Navigate]({
                "type": "standard__webPage",
                "attributes": {
                    //Here customLabelExampleAura is name of lightning aura component
                    //This aura component should implement lightning:isUrlAddressable
                    //"componentName": "c__expediteOrderProdLWC"
                    "url": this.sfdcOrgURL
                }
            });
            
            
         }

    
        


    handleOnselect(event) {
        this.selectedItemValue = event.detail.value;
        
       console.log('Check') ;

       getOrderStatus({orderId: this.orderId})
       .then(result => {
        this.orderStatus =result;
        console.log("The Result for new manager: "+ JSON.stringify(this.orderStatus)); 

        if(this.orderStatus !=='Complete'){
            this.chnExp = true;
        }

        /*else if(this.orderStatus=='Complete'){
            this.reqShort=true;
        }*/
       });  
    }
    
    //Getting the current url
   /* renderedCallback() {
      //  this.sfdcOrgURL = window.location.href;
      //  console.log(("please check the Link: "+this.sfdcOrgURL))


    }*/
    async saveChangeRequest(event){   

        console.log('The Order ID: '+this.orderId);
        console.log('Order Status is: '+this.orderStatus);
        var baseURL = window.location.origin;
        console.log('Base URL: '+baseURL);
        this.sfdcOrgURL = baseURL+'/s/change-request'+'?id='+ this.orderId;
        console.log('New URL: '+this.sfdcOrgURL);
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
    async saveExpedite(event) {

        console.log('The Order ID: '+this.orderId);
        var baseURL = window.location.origin
        console.log('BASE URL: '+baseURL);
        this.sfdcOrgURL = baseURL+'/s/expedite'+'?id='+ this.orderId;
        console.log('NEW URL: '+this.sfdcOrgURL);
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
    async saveReturnReplace(event) {
    
        console.log('The Order ID: '+this.orderId);
        var baseURL = window.location.origin
        console.log('BASE URL: '+baseURL);
        this.sfdcOrgURL = baseURL+'/s/return-replace'+'?id='+this.orderId;
        console.log('NEW URL: '+this.sfdcOrgURL);
        window.open(this.sfdcOrgURL, "_self");
        /*this[NavigationMixin.Navigate]({
            "type": "standard__webPage",
            "attributes": {
                //Here customLabelExampleAura is name of lightning aura component
                //This aura component should implement lightning:isUrlAddressable
                //"componentName": "c__expediteOrderProdLWC"
                "url": this.sfdcOrgURL
            }
        },true);*/


    }
    async saveWarrantyClaim(event) {
      
        console.log('The Order ID: '+this.orderId);
        var baseURL = window.location.origin
        this.sfdcOrgURL = baseURL+'/s/warranty-claim'+'?id='+ this.orderId;
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
    async saveOverage(event) {
        console.log('The Order ID: '+this.orderId);
        var baseURL = window.location.origin
        this.sfdcOrgURL = baseURL+'/s/shipping-discrepancy'+'?id='+ this.orderId + '/'+'Overage';
        console.log(this.sfdcOrgURL);
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
    async saveShortage(event) {
        console.log('The Order ID: '+this.orderId);
        var baseURL = window.location.origin
        this.sfdcOrgURL = baseURL+'/s/shipping-discrepancy'+'?id='+ this.orderId + '/'+'Shortage';
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
    async saveLostDamage(event) {
        console.log('The Order ID: '+this.orderId);
        var baseURL = window.location.origin
        this.sfdcOrgURL = baseURL+'/s/shipping-discrepancy'+'?id='+ this.orderId + '/'+'Lost';
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