import { LightningElement, track, wire, api } from "lwc";  
 import findRecords from "@salesforce/apex/LwcLookupControllerCust.findRecords";  
 export default class customLookup extends LightningElement {  
  @track recordsList;  
  @track searchKey = "";  
  @api selectedValue;  
  @api selectedRecordId;  
  @api objectApiName;
  @api filterFieldName;
  @api filterFieldVal;  
  @api iconName;  
  @api lookupLabel; 
  @api orderagency; 
  @track message;  
    
  onLeave(event) {  
   setTimeout(() => {  
    this.searchKey = "";  
    this.recordsList = null;  
   }, 300);  
  }  
    
  onRecordSelection(event) {  
   this.selectedRecordId = event.target.dataset.key;  
   this.selectedValue = event.target.dataset.name; 
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
   findRecords({ searchKey: this.searchKey, objectName : this.objectApiName, filterField: this.filterFieldName , filterFieldValue: this.filterFieldVal})  
    .then((result) => {  
     if (result.length===0) {  
       this.recordsList = [];  
       this.message = "No Records Found";  
      } else {  
       this.recordsList = result;  
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
   const passEventr = new CustomEvent('recordselection', {  
     detail: { selectedRecordId: this.selectedRecordId, selectedValue: this.selectedValue }  
    });  
    this.dispatchEvent(passEventr);  
  }  
 }