import { LightningElement, api, wire, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import UserType from '@salesforce/schema/User.User_Type__c';
import getReleaseNotes from '@salesforce/apex/releaseNotesClass.getReleaseNotes';
import getNoteItems from '@salesforce/apex/releaseNotesClass.getNoteItems';

import connectLogo from '@salesforce/contentAssetUrl/MicrosoftTeamsimage_1png';
const options = {
    typeAttributes :{
    year: 'numeric', month: 'numeric', day: 'numeric',
    //hour: 'numeric', minute: 'numeric',
    type: 'date-local',
    hour12: true
    
    }
    
  };


export default class ReleaseNotesLWC extends LightningElement {

    @track user_Type;
    @track recordId;
    @track error;
    @track type = false;
    @api releaseType;
    @api isCurrent;
    @api active;
    @track tempList = [];
    @track noteItems = [];
    @track data;
    connectLogo = connectLogo;
    @track isLoading = false;

    @track columns =[/*{
        label: 'Type',
        fieldName: 'Type__c',
        type: 'text',
        initialWidth: 175
        
        //sortable: true
    },*/
    {
      label: 'Connect Module',
      fieldName: 'Module__c',
      type: 'text',
      initialWidth: 150,
      wrapText: true
      //sortable: true
      },
      {
          label: 'Sub Module',
          fieldName: 'Sub_Module__c',
          type: 'text',
          initialWidth: 200,
          wrapText: true
          //sortable: true
      },
    {
        label: 'Description',
        fieldName: 'Description__c',
        type: 'text',
        //sortable: true
    }];


    @wire(getRecord, {
        recordId: USER_ID,
        fields: [UserType]
    }) wireuser({
        error,data
    }) {
        if (error) {
        this.error = error;
        console.log('ERROR: '+JSON.stringify(this.error));
        } else if (data) {
         
            this.getRelease();
        }
    }

    
    handleSelected(event){
        var disID = event.target.name;
        if (disID !== undefined) {
            console.log('SECTION ID: '+JSON.stringify(disID));
            this.isLoading = true;
            getNoteItems({noteId : disID})
            .then(result => {
                this.noteItems = result;
                this.isLoading = false;
            });
        }
        
    }
    
   getRelease(){
        getReleaseNotes({ active: this.active, isCurrent: this.isCurrent, releaseType: this.releaseType})
       .then(result => {
        if(result){
            console.log('Retrieved Release Notes: '+JSON.stringify(result));
            //this.data = result;
            this.templist = [];
            for (const notes of result){
                const clone = Object.assign({}, notes);
                
            
                let dt = new Date( notes.Release_Date__c );
                let fdate = new Intl.DateTimeFormat( 'en-US', options ).format( dt );
                if(notes.Category__c !== "Upcoming"){
                    clone.releaseName = fdate + ' | ' + notes.Release_Version__c;
                } else {
                    clone.releaseName = 'TBD';
                    this.type = true;
                }
                if(notes.Current_Version__c == true){
                    console.log('CURRENT VERSION TO PARENT: '+notes.Release_Version__c);
                    this.dispatchEvent(
                        new CustomEvent('setversion', {
                            detail: {
                                version : notes.Release_Version__c
                                
                            }
                        }));
                }
                clone.disID = notes.Id;
                console.log('Pushing ID to Array...'+ clone.disID);
              
                this.templist.push(clone);
            }
                  
             

                this.data = this.templist;
                getNoteItems({noteId : this.data[0].disID})
                    .then(result => {
                        this.noteItems = result;
                    })
               
                console.log('data: '+JSON.stringify(this.data));
        }
        //this.hyperlink = this.shipmentRecord[0].CCL_Order_Apheresis__r.CCL_Apheresis_Collection_Center__r.Name;
      })
      .catch(error => {
        this.error = error;
      });
    }

}