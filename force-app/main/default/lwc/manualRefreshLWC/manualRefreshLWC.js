import { LightningElement, api, track, wire } from 'lwc';

import { updateRecord, deleteRecord, getRecord } from 'lightning/uiRecordApi';
import getRepCodes from "@salesforce/apex/relatedManualRefresh.getRepCodes";
import updateContact from "@salesforce/apex/relatedManualRefresh.updateContact";
import updateCDA from "@salesforce/apex/relatedManualRefresh.updateCDA";
import insertACR from "@salesforce/apex/relatedManualRefresh.insertACR";
import removeACR from "@salesforce/apex/relatedManualRefresh.removeACR";
import getAccount from "@salesforce/apex/relatedManualRefresh.getAccount";
import USER_ID from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';
import EMAIL_FIELD from '@salesforce/schema/User.Email';

const options = {
   
    year: 'numeric', month: 'numeric', day: 'numeric',
    //hour: 'numeric', minute: 'numeric',
    type: 'date-local',
    hour12: true
    
    
}
export default class ManualRefreshLWC extends LightningElement {

    @api recordId;
    @track data = [];
    @track executing = false;
    @track recordAmount;
    @track message = '';
    @track processed = 0;
    @track progressInterval;
    @track progress = 0;
    @track restoreDate;
    isProgressing = false;
    @track accountID;
    @track directID;
    @track showTable = false;
    @track reqEmail;
    @track reqName;
    @track userID;

     // COLUMNS FOR THE VIEW CART MODAL  GE_LGT_EM_InvoiceHeaderNumber__r.Name,  
     @track columns = [
        {
            label: 'Rep Code #',
            fieldName: 'Rep_Code__c',
            iconName: 'utility:form',
            type: 'Text',
            
        },
        {
            label: 'Is Direct',
            fieldName: 'Is_Direct__c',
            type: 'boolean',
            cellAttributes: { alignment: 'center' }
            
        },
        {
            label: 'Remapped',
            fieldName: 'Remapped__c',
            type: 'boolean',
            cellAttributes: { alignment: 'center' }
            
        }
    
        
        
        ];
//--------END COLUMNS FOR THE VIEW CART MODAL

/*@wire(getRepCodes, {recordId: '$recordId'})
    onLoad({data, error}) {
        if (data) {
            this.data = data;
            console.log('Retrieved Account Relations: '+JSON.stringify(this.data));
            this.progressInterval = 100 / (this.data.length + 1);
            console.log('Progress Interval Set: '+this.progressInterval);
        }
        if (error) {
            console.error(error);
        }
    }*/

   /* connectedCallback(){
        this.getRepCodes();
    }*/


    // GET CURRENT LOGGED IN COMMUNITY USER INFORMATION
    @wire(getRecord, {
        recordId: USER_ID,
        fields: [NAME_FIELD, EMAIL_FIELD]
    }) wireuser({
        error,
        data
    }) {
        if (error) {
        this.error = error ; 
        } else if (data) {
            this.userID = USER_ID;
            this.reqName = data.fields.Name.value;
            this.reqEmail = data.fields.Email.value;
   
            localStorage.setItem('Logged In User', this.reqName);

        
        
        
        }
        
    }


   async execute(){
        this.executing = true;
        this.isProgressing = true;
        //this.progressBar();
        this.message = 'Updating Contact to GE Current - External...';
        let con = {'sobjectType': 'Contact'};
            con.Id = this.recordId;
            con.AccountId = this.accountID;
        await updateContact({data : con})
            .then(result => {
                this.message = 'Contact Updated!!';
                //this.progressBar();
                console.log('Item Modified'); 
                if(result){
                     this.removeRelations();
                }
        })
        

            
           
        
    }
    
    async removeRelations(){
       await removeACR({contactId : this.recordId, accountId : this.accountID})
        .then(result => {
            this.message = "Exisitng Relationships Deleted";
            console.log('Existing Relationships Deleted...');

            if(result){
                this.reconnectRelations();
            }
        })
    }

    reconnectRelations(){
        var i;
                let list = this.data;
                console.log('LIST FOR PROCESSING: '+JSON.stringify(list));
                    for(i = 0; i < list.length; i++){
                    
                        /*if(i == list.length){
                            this.isProgressing = false;
                        }*/
                        console.log('I = '+ i);
                        this.processed = i +1;
                        
                        //this.progressBar();
                        let tempId = list[i].Id;
                        this.acrName = list[i].Rep_Code__c;
                        this.message = 'Processing '+ this.acrName + '...Please Wait...';
                        this.processStatus = 'Processing => ' + this.processed +' / '+this.data.length;
                        let acr = { 'sobjectType': 'AccountContactRelation' };
                            acr.AccountId = list[i].Direct_Account__c;
                            console.log('Setting Account: '+acr.AccountId);
                            acr.ContactId = list[i].Contact__c;
                            console.log('Setting Contact: '+acr.ContactId);
                            acr.B2B_Agent_flag__c = true;
                            acr.B2B_flag__c = true;
    
                        insertACR({data : acr})
                        .then(result => {
                            
                            console.log('Updating ID: '+tempId);
                            let cda = { 'sobjectType': 'Connect_Direct_Account__c' };
                            cda.Id = tempId;
                            cda.Remapped__c = true;
                            updateCDA({data : cda})
                                .then(result => { 
                                    this.getRepCodes();
                                }) 
                        })
                        
                        
                    
                    }
                    let con2 = {'sobjectType': 'Contact'};
                        con2.Id = this.recordId;
                        con2.AccountId = this.directID;
                        updateContact({data : con2})
                        .then(result => { });
                    this.message = 'Completed - Contact Relationships Successfully Refreshed';
                    this.processStatus = '';
                    //this.getRepCodes();
    }

   connectedCallback() {
        console.log('connectedCallback rendered------------'+this.recordId);
        console.log(this.recordId);
        

        getAccount({})
            .then(result => { 
                this.accountID = result;
                console.log('Returned Account: '+this.accountID);
            });
      
    }

    convertDate(){
        console.log('Executing Rep Code Retrieval....');
        var priorDate = this.template.querySelector('.rd').value;

       
        console.log('Entered Date: '+priorDate);

        let dt = new Date( priorDate );
        this.restoreDate = new Intl.DateTimeFormat( 'en-US', options ).format( dt );
        console.log('Converted Date: '+this.restoreDate);
       
        this.getRepCodes();
    }

    async  getRepCodes(){
        this.restoreDate = this.template.querySelector('.rd').value;
        console.log('Sending Date to APEX: '+this.restoreDate);
        console.log('Sending Contact ID to APEX: '+this.recordId);
       await getRepCodes({recordId: this.recordId, restoreDate: this.restoreDate})
        .then(result => {
            
            this.data = result;
            //this.recordAmount = this.data.length();
            var i;
            let list = this.data;
            for(i = 0; i < list.length; i++){
                if(list[i].Is_Direct__c == true){
                    this.directID = list[i].Direct_Account__c;
                    console.log('DIRECT ACCOUNT IS: '+this.directID);
                }
            }

            console.log('Results: '+JSON.stringify(this.data));
            this.showTable = true;
    
        }).catch(error => {
           console.log('APEX ERROR' + JSON.stringify(error));
           
        });
    }

    progressBar(){
        
        if(this.isProgressing === false){
            clearInterval(this._interval);
            this.message = 'Completed - Contact Relationships Successfully Refreshed';

        } else {
        
            this._interval = setInterval(() => {
                this.progress = this.progress === 100 ? 0 : this.progress + this.progressInterval;
                console.log('Current Progress % '+this.progress);
                this.processStatus = 'Processing => ' + this.processed +' / '+this.data.length;
               
            }, 300);
        } 
        
        }
        
    
 

    
}