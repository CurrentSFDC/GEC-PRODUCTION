import { LightningElement, track, api, wire } from 'lwc';  
import findRecords from "@salesforce/apex/LwcLookupControllerCust.findDistRecords"; 
//import CommunityAccountSelector from '../communityAccountSelector/communityAccountSelector';

export default class distributorSearchCustom extends LightningElement {  
    @track recordsList;  
    @track recordsListNew;
    @track searchKey = "";  
    @track searchKeyNew = ""; 
    @api selectedValue;  
    @api selectedValueNew; 
    @api selectedRecordId;  
    @api selectedRecordIdNew; 
    @api disMandatory;
    @api objectApiName;
    @api filterFieldName;
    @api filterFieldVal;  
    @api iconName;  
    @api lookupLabel; 
    @api orderagency; 
    @track message;  

    @api setConfirmValues(inputacc){
      this.filterFieldVal=inputacc;
      console.log("this.filterFieldVal"+this.filterFieldVal);
      console.log('Setting Agent ID from Account Search CMP: '+this.filterFieldVal);
      

  }
      
    onLeave(event) {  
     setTimeout(() => {  
      this.searchKey = "";  
      this.recordsList = null;  
     }, 18000);  
    }  

    onLeaveNew(event) {  
        setTimeout(() => {  
         this.searchKeyNew = "";  
         this.recordsListNew = null;  
        }, 300);  
       } 
      
    onRecordSelection(event) {  
     this.selectedRecordId = event.target.dataset.key;  
     this.selectedValue = event.target.dataset.name; 
     this.selectedValueNew = event.target.dataset.name;
     console.log("Selected Record" + this.selectedRecordId);
     console.log("Selected value" + this.selectedValue);
     this.searchKey = "";  
     this.onSeletedRecordUpdate();  
    }  

    

     
     
    handleKeyChange(event) {  
     const searchKey = event.target.value;  
     this.searchKey = searchKey;
     console.log('Setting Agent ID from Account Search CMP: '+this.filterFieldVal);  
     this.getLookupResult();  
    }  


     
    removeRecordOnLookup(event) {  
     this.searchKey = "";  
     this.selectedValue = null;  

     this.selectedRecordId = null; 
  
     this.recordsList = null; 

     this.onSeletedRecordUpdate();  
   }  

 
     
   handleChange1(event){
    this.orderagency = event;
               this.dispatchEvent(
                  new CustomEvent('ordagensel', {
                      detail: {
                          lines : this.orderagency
                      }
                  })); 
   console.log('deliveryAgencyEvent ID in custom lookup: '+ this.orderagency);
  }
  
   
  
  
    getLookupResult() {  
      //console.log("this.filterFieldName" + this.filterFieldName);
      //console.log("this.filterFieldVal" + this.filterFieldVal);
     //console.log("this.objectApiName" + this.objectApiName);
     //console.log("this.searchKey" + this.searchKey);
     findRecords({ searchKey: this.searchKey, objectName : this.objectApiName, filterField: this.filterFieldName , filterFieldValue: this.filterFieldVal})  
      .then((result) => {  
       if (result.length===0) {  
         console.log("Inside nothing");
         this.recordsList = [];  
         this.message = "No Records Found";  
        } else {  
          console.log("Inside else check");
         this.recordsList = result;  
         console.log("this.recordsList" + JSON.stringify(this.recordsList));
         this.message = "";  
        }  
        this.error = undefined;  
      })  
      .catch((error) => {  
       this.error = error;  
       this.recordsList = undefined;  
      });  
    }  

   
     
    onSeletedRecordUpdate(){  
        console.log("Inside the event call for 1");
        
        this.dispatchEvent ( 
            new CustomEvent('recordselection', {  
       detail: {selectedRecordId: this.selectedRecordId, selectedValue:this.selectedValue}
      }));  
  
    }  


}