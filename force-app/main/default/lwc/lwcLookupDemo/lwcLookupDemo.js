import { LightningElement, track, api, wire } from 'lwc';  
import findRecords from "@salesforce/apex/LwcLookupControllerCust.findRecords"; 
import findAccRecords from "@salesforce/apex/LwcLookupControllerCust.findAccSpecRecords"; 
import getAccName from '@salesforce/apex/connectCreateCase.getAccountName';

export default class LwcLookupDemo extends LightningElement {  
    @track recordsList;  
    @track recordsListNew;
    @track recordsListSpec;
    @track searchKey = "";  
    @track searchKeyNew = ""; 
    @track searchKeySpec = ""; 
    @api selectedValue;  
    @api selectedValueNew; 
    @api selectedValueSpec;
    @api selectedRecordId;  
    @api selectedRecordIdNew; 
    @api selectedRecordIdSpec;
    @api objectApiName;
    @api filterFieldName;
    @api filterFieldVal;  
    @api iconName;  
    @api lookupLabel; 
    @api orderagency; 
    @track message;  
    @api defaultAccValue;
    @api filterFieldValSpec;


    @api setConfirmValues(inputacc){
      this.defaultAccValue=inputacc;
      console.log("this.defaultAccValue"+this.defaultAccValue);
      getAccName({id_dtl: this.defaultAccValue})
      .then(result => {
          this.selectedValueSpec = result;
      console.log(JSON.stringify("Account Name Selected "+ JSON.stringify(this.selectedValueSpec)))
      });

  }
      
    onLeave(event) {  
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

    onLeaveSpec(event) {  
        setTimeout(() => {  
         this.searchKeySpec = "";  
         this.recordsListSpec = null;  
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


    onRecordSelectionNew(event) {  
        this.selectedRecordIdNew = event.target.dataset.key;  
        this.selectedValueNew = event.target.dataset.name; 
        console.log("Selected Record" + this.selectedRecordIdNew);
        console.log("Selected value" + this.selectedValueNew);
        this.searchKeyNew = "";  
        this.onSeletedRecordUpdateNew();  
       } 

       onRecordSelectionSpec(event) {  
        this.selectedRecordIdSpec = event.target.dataset.key;  
        this.selectedValueSpec = event.target.dataset.name; 
        console.log("Selected Record" + this.selectedRecordIdSpec);
        console.log("Selected value" + this.selectedValueSpec);
        this.searchKeySpec = "";  
        this.onSeletedRecordUpdateSpec();  
       }
  
     
     
    handleKeyChange(event) {  
     const searchKey = event.target.value;  
     this.searchKey = searchKey;  
     this.getLookupResult();  
    }  

    handleKeyChangeNew(event) {  
        const searchKeyNew = event.target.value;  
        this.searchKeyNew = searchKeyNew;  
        this.getLookupResultNew();  
       } 
       
       
       handleKeyChangeSpec(event) {  
         console.log("Inside hanlde Spec");
        const searchKeySpec = event.target.value;  
        this.searchKeySpec = searchKeySpec; 
        console.log("this.searchKeySpec"+this.searchKeySpec);
        this.getLookupResultSpec();  
       }
     
    removeRecordOnLookup(event) {  
     this.searchKey = "";  
     this.selectedValue = null;  

     this.selectedRecordId = null; 
  
     this.recordsList = null; 

     this.onSeletedRecordUpdate();  
   }  

   removeRecordOnLookupNew(event) {  
    this.searchKeyNew = "";  
    this.selectedValueNew = null;  
    this.selectedRecordIdNew = null;  
    this.recordsListNew = null; 
    this.onSeletedRecordUpdateNew();  
  } 

  removeRecordOnLookupSpec(event) {  
    this.searchKeySpec = "";  
    this.selectedValueSpec = null;  
    this.selectedRecordIdSpec = null;  
    this.recordsListSpec = null; 
    this.onSeletedRecordUpdateSpec();  
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

    getLookupResultNew() {  
        findRecords({ searchKey: this.searchKeyNew, objectName : this.objectApiName, filterField: this.filterFieldName , filterFieldValue: this.filterFieldVal})  
         .then((result) => {  
          if (result.length===0) {  
            this.recordsListNew = [];  
            this.message = "No Records Found";  
           } else {  
            this.recordsListNew = result;  
            this.message = "";  
           }  
           this.error = undefined;  
         })  
         .catch((error) => {  
          this.error = error;  
          this.recordsListNew = undefined;  
         });  
       }


       getLookupResultSpec() {  
         console.log("this.searchKeySpec:"+this.searchKeySpec);
         console.log("this.filterFieldValSpec:"+this.filterFieldValSpec);
        findAccRecords({ searchKey: this.searchKeySpec, objectName : this.objectApiName, filterField: this.filterFieldName , filterFieldValue: this.filterFieldValSpec})  
         .then((result) => {  
          if (result.length===0) {  
            this.recordsListSpec = [];  
            this.message = "No Records Found";  
           } else {  
            this.recordsListSpec = result;  
            this.message = "";  
           }  
           this.error = undefined;  
         })  
         .catch((error) => {  
          this.error = error;  
          this.recordsListSpec = undefined;  
         });  
       }
     
    onSeletedRecordUpdate(){  
        console.log("Inside the event call for 1")
        this.dispatchEvent ( 
            new CustomEvent('recordselection', {  
       detail: {selectedRecordId: this.selectedRecordId}
      }));  
  
    }  

    onSeletedRecordUpdateNew(){  
        console.log("Inside the event call for 2")
       
        this.dispatchEvent ( 
            new CustomEvent('recordselectionnew', {  
       detail: {selectedRecordId: this.selectedRecordIdNew}
      }));  
       } 

       onSeletedRecordUpdateSpec(){  
        console.log("Inside the event call for 3")
       
        this.dispatchEvent ( 
            new CustomEvent('recordselectionSpec', {  
       detail: {selectedRecordId: this.selectedRecordIdSpec}
      }));  
       } 
}