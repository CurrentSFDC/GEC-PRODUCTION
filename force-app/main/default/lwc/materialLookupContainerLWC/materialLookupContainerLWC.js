import { LightningElement, track, api, wire } from 'lwc';
import createReturnItem from '@salesforce/apex/ReturnOrderItemController.createReturnOrderItems';
import getReturnList from '@salesforce/apex/OrderProductController.getReturnList';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord, deleteRecord } from 'lightning/uiRecordApi';
const actions = [
    { label: 'Edit', name: 'edit'},
    { label: 'Delete', name: 'delete'}
];

export default class MaterialLookupContainerLWC extends LightningElement {
    
//RECEIVING ATTRIBUTES FROM PARENT COMPONENT
@api prodFamilies;
@api transactionID;
@api selectedDistributorID;
@api caseType;
@track addToRequest = true;

// COLUMNS AND CART 
@api columns;
@api cartColumns;
@track isRemoving = false;
@track cartModal = false;
@track cartCount = 0;
@track deleteModal = false;
@track deleteFromRow = false;
@track deleteClearAll = false;

showCart(){
    this.cartModal = true;
}

closeCartModal(){
    this.cartModal = false;
}


//--- CART ACTIONS ------
cartActions(event){
    const actionName = event.detail.action.name;
    const row = event.detail.row;

    console.log('Delete ActionName: '+ actionName);
    console.log('Delete Row: '+ JSON.stringify(row));
    switch (actionName) {
        case 'delete':
            //this.deleteCurrentRecord(row);
            this.showDeleteModal(row);
            this.deleteFromRow = true;
            this.deleteClearAll = false;
            break;
        default:
    }
}

showDeleteModal(currentRow){
   console.log('Row passed: '+JSON.stringify(currentRow));
   this.deleteModal = true;
   this.returnItemId = currentRow.Id;
   console.log('Return Item to Delete: '+this.returnItemId);
   this.currentSKU = currentRow.SKU__c;
  
}

closeDeleteModal(){
   this.deleteModal = false;
}

popDeleteModal(){
this.deleteClearAll = true;
this.deleteModal = true;
this.deleteFromRow = false;
}

async  deleteCurrentRecord(currentRow){
 this.deleteModal = false;
 this.isRemoving = true;
   console.log('Invoice Line to be Updated: '+this.invoiceID);
 
 await  deleteRecord (this.returnItemId)
    .then(() => {
        
        });
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Line has been removed from Cart',
                variant: 'success'
            })
        );          
             this.fetchReturnItems();
    
}

async clearCart(event){
    this.deleteModal = false;
    this.isRemoving = true;  
    for(var i = 0, len = this.storedLines.length; i < len; i++){
    await deleteRecord (this.storedLines[i].Id)
        .then(() => {

                this.fetchReturnItems();

        })
    
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Cart has been Cleared',
                variant: 'success'
            })
        );
    }
}

@api clearSessionCart(){
    console.log('EXECUTING CLEAR SESSION CART...');
    this.sessionCartDelete();
}

async sessionCartDelete(){
    let listSize = this.storedLines.length;
    if(listSize > 0){
    for(var i = 0, len = this.storedLines.length; i < len; i++){
        await deleteRecord (this.storedLines[i].Id)
            .then(() => {
                var baseURL = window.location.origin;
                console.log('Base URL: '+baseURL);
                this.sfdcOrgURL = baseURL+'/Agents/s/';
                console.log('New URL: '+this.sfdcOrgURL);
                window.open(this.sfdcOrgURL, "_self");  
                    
    
            })
        
            
        }
    }
}



//MANUAL ENTRY VARIABLES
@track addProductModal = false;

showManualEntry(){
    this.addProductModal = true;
}

closeProductModal(){
    this.addProductModal = false;
}

async addManualProduct(){
   
        this.isLoading=true;     
       

        let nReturnItem = {'sobjectType': 'Return_Order_Item__c'};
            nReturnItem.Product_SKU__c = this.template.querySelector(".di").value;
            nReturnItem.Transaction_ID__c = this.transactionID;
            nReturnItem.Quantity__c = this.template.querySelector(".mqty").value;
            nReturnItem.Comments__c = this.template.querySelector(".po").value;
            nReturnItem.Type__c = this.caseType + ' - Manual Entry'; 
            await createReturnItem({accounts: nReturnItem})
            .then(result => {
                this.returnID = result;
                //this.materialID = '';
                this.noCatInput = false;
            });
                    
                this.fetchReturnItems();
                this.addProductModal = false; 
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Item added to the Cart Successfully',
                        variant: 'success'
                    })
                );
}






//SEARCH PRODUCT VARIABLES AND FUNCTIONS
@track openAddModal = false;
@track materialID;
@track materialDescription;
@track materialNumber;
@track selectedMaterial;
@track comments;
@api storedLines;
@track cartCount;
@track cartLabel = "Add to Request";
@track isLoading = false;

addModal(){
    this.openAddModal = true;
}

closeAddModal(){
    this.openAddModal = false;
    this.selectedMaterial = '';
    this.materialID = '';
    this.materialDescription = '';
    this.materialNumber = '';
}

handleMaterialMasterReset(event) {
    this.addToRequest = true;
    this.materialID = '';
}

handleMaterialSelected(event){

    this.materialID = event.detail.selectedMaterialID;
    this.materialNumber = event.detail.selectedMaterialNumber;
    this.materialDescription = event.detail.selectedMaterialDescription;
    this.selectedMaterial = this.materialNumber + ' - ' + this.materialDescription; 

    console.log('Selected Material ID: '+this.materialID);
    console.log('Selected Material Description: '+this.materialDescription);
    console.log('Selected Material Number: '+this.selectedMaterialNumber);
    console.log('Concat Material: '+this.selectedMaterial);

    this.addToRequest = false;
    /*this.materialID = event.target.value;
    console.log('Selected ID: ' +this.materialID);
    getMaterialDes({matId: this.materialID})
    .then(result => {
    this.materialDescription = result[0].GE_LGT_EM_MaterialDescription__c;
    this.materialNumber = result[0].GE_LGT_EM_SAP_MaterialNumber__c

    console.log(JSON.stringify("The Result for Material Number: "+ JSON.stringify(this.materialDescription)));
    console.log(JSON.stringify("The Result for Material Number: "+ JSON.stringify(this.materialNumber)));
    });*/
}


// INSERT RETURN ORDER ITEM ENTRY IN BACKEND TABLE
async createItem(){
    this.isLoading = true;
   let nReturnItem = {'sobjectType': 'Return_Order_Item__c'};
                    nReturnItem.Material__c = this.materialID;
                    nReturnItem.Product_SKU__c = this.materialDescription;
                    nReturnItem.Distributor_Id__c = this.selectedDistributorID;
                    console.log('Material# Entered: '+this.materialDescription);
                    nReturnItem.SKU__c = this.materialNumber;
                    nReturnItem.Quantity__c = this.template.querySelector(".qty").value;      
                    nReturnItem.Transaction_ID__c = this.transactionID;
                    nReturnItem.Comments__c = this.template.querySelector('.com').value;
                    nReturnItem.Type__c = this.caseType + ' - Product Search';
                    await createReturnItem({accounts: nReturnItem})
                    .then(result => {
                        this.selectedMaterial = '';
                        this.materialID = '';
                        this.materialDescription = '';
                        this.materialNumber = '';
                
                    });
                    
                this.fetchReturnItems();
                this.openAddModal = false; 
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Item added to the Cart Successfully',
                        variant: 'success'
                    })
                );
}

fetchReturnItems(){
    getReturnList({transId : this.transactionID})
        .then(result =>{
            this.storedLines = result;
            this.cartCount = this.storedLines.length;
          
 
            console.log('RESULT: '+result.length);
     
            if(this.storedLines.length == 0){
                
               
                this.storedLines = '';
             
            }
           
        this.dispatchEvent(
            new CustomEvent('lineupdate', {
                detail: {
                    lines : this.storedLines
                }
            }));
        this.dispatchEvent(
            new CustomEvent('cartcount', {
                detail: {
                    totalItems : this.cartCount
                }
            }));
        
    });
    this.isLoading = false;
    this.isRemoving = false;
 }











}