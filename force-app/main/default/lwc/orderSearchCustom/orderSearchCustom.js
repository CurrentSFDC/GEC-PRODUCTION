import { LightningElement, track, api, wire } from 'lwc';  
import findRecords from "@salesforce/apex/LwcLookupControllerCust.findOrderRecords"; 
import findRecordsNEW from "@salesforce/apex/LwcLookupControllerCust.findOrderRecordsNEW"; 
import getOrdDtl from "@salesforce/apex/LwcLookupControllerCust.getOrdDtl"; 
//import CommunityAccountSelector from '../communityAccountSelector/communityAccountSelector';

export default class orderSearchCustom extends LightningElement {  
    @track recordsList;  
    @track recordsListNew;
    @track searchKey = "";  
    @track searchKeyNew = ""; 
    @api selectedValue;  
    @api selectedValueNew; 
    @api selectedRecordId;  
    @api selectedRecordIdNew; 
    @api objectApiName = 'order';
    @api filterFieldName;
    @api filterFieldVal='DEFAULT';  
    @api iconName;  
    @api lookupLabel; 
    @api orderagency; 
    @track message;

    @track searchText;  
    @track options = [];
    @track selectedAccount;
    @track accounts;

    @api setConfirmValues(inputord){
      this.defaultAccValue=inputord;
      console.log("this.defaultAccValue"+this.defaultAccValue);
      getOrdDtl({ordId: this.defaultAccValue})
      .then(result => {
          this.selectedValue = result;
      console.log(JSON.stringify("Account Name Selected "+ JSON.stringify(this.selectedValue)))
      });

  }
      
    onLeave(event) { 
      console.log('ON LEAVE'); 
     setTimeout(() => {  
      this.searchKey = "";  
      this.recordsList = null;  
     }, 300);  
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
      console.log("this.filterFieldName" + this.filterFieldName);
      console.log("this.filterFieldVal" + this.filterFieldVal);
     // console.log("this.objectApiName" + this.objectApiName);
     // console.log("this.searchKey" + this.searchKey);
     if(this.filterFieldVal==null){
      this.filterFieldVal='DEFAULT';
     }
     console.log('Search Text: '+this.searchText);
     console.log('Object API: '+this.objectApiName);
     console.log('Filter Field: '+this.filterFieldName);
     console.log('Filter Field Value: '+this.filterFieldVal);
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
        console.log("Inside the event call for 1")
        this.dispatchEvent ( 
            new CustomEvent('orderselection', {  
       detail: {selectedRecordId: this.selectedRecordId}
      }));
      
      this.dispatchEvent ( 
        new CustomEvent('clearselection', {  
      detail: {clear: 'true'}
      }));  
  
    }  

}