import { LightningElement, track, api } from 'lwc';
import getproductList from '@salesforce/apex/CCProductController.getproductList';
import getproductRefList from '@salesforce/apex/CCProductController.getproductRefList';
import updateReturnItemList from '@salesforce/apex/CCProductController.updateReturnItemList';
import getReturnProdList from '@salesforce/apex/CCProductController.getReturnProdList';
import { refreshApex } from '@salesforce/apex';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CCProductDataTable extends LightningElement() {
@track searchProducts = true;
@track productColumns = [{
        label: 'Catalog #',
        fieldName: 'MaterialDescription__c',
        iconName: 'utility:products',
        type: 'Text',
        sortable: true
    },
    {
        label: 'SKU #',
        fieldName: 'ccrz__SKU__c',
        type: 'Text',
        sortable: true
    },
    {
        label: 'Product Description',
        fieldName: 'ccrz__ShortDescRT__c',
        iconName: 'utility:textbox',
        type: 'Text',
        sortable: true
    },
   /* {
        label: 'Quantity Per Unit',
        fieldName: 'ccrz__Quantityperunit__c',
        type: 'Number',
        sortable: true
    },*/
    {
        label: 'Select Quantity',
        fieldName: 'Quantity_Selected__c',
        iconName: 'utility:number_input',
        type: 'Text',
        editable: true,
        sortable: true,
        cellAttributes : {
            class: 'slds-color__background_gray-7'
            
        }
    }];
    
    //--------END COLUMNS FOR CART SCREEN
    @track cartColumns = [{
        label: 'Catalog #',
        fieldName: 'Product_SKU__c',
        iconName: 'utility:products',
        type: 'Text',
        sortable: true
    },
    {
        label: 'SKU #',
        fieldName: 'SKU__c',
        type: 'Text',
        sortable: true
    },
    {
        label: 'Product Description',
        fieldName: 'Product_Description__c',
        iconName: 'utility:textbox',
        type: 'Text',
        sortable: true
    },
    {
        label: 'Selected Quantity',
        fieldName: 'Selected_Qty__c',
        iconName: 'utility:number_input',
        type: 'Text',
        editable: true,
        sortable: true
    }];
    

// COLUMNS FOR THE VIEW CART MODAL


    @api cartCount = 0;
    @track isProductIdAvailable = false;
    @track error;
    @track productList=[];
    @track selectedProduct;
    @track flagIndi=false;
    @api valuetopass;
    draftValues = [];
    @api transactionID;
    @api storedLines = [];
    @track bShowModal = false;
    @track currentRow;
    @track warrantyEntry = false;
    @track manualLines = [];
    @track paramString=[];
    @track isLoading = false;

    //@api skuVal;
    

    connectedCallback(){
        /*const id = 'id' + performance.now();
        this.transactionID = id;
        console.log('Generated ID: '+ id);*/

        this.sfdcOrgURL = window.location.href;
        if(this.sfdcOrgURL.includes('id=')==true){
            this.paramString = this.sfdcOrgURL.split('id=')[1];
            if(this.paramString.length > 0){
                console.log('paramString@@@@@@@@@@'+this.paramString);
                this.handleChangeNew();
            } 
        }




    }

    async handleChange(event) {
        console.log("You selected an product: " + event.detail.value[0]);
        this.selectedProduct = event.detail.value[0];
        console.log("The Result from : "+JSON.stringify(this.selectedProduct) );
        console.log("Type of" +typeof(this.selectedProduct));
       
    
        await getproductList({prodId: this.selectedProduct})
        .then(result => {
            console.log("The Result from APEX is: "+JSON.stringify(result) );
            
            this.productList = result;
            console.log("The Result from APEX2 is: "+JSON.stringify(this.productList) );
            this.isProductIdAvailable = true;
            //this.error = undefined;        
            
            
           
        }).catch(error => {
            console.log("The error SENT TO APEX is: " +JSON.stringify(error));
            this.error = error;
            //this.data  = undefined;
        });
    }
    async handleChangeNew(event) {
        this.selectedProduct = this.paramString;

        console.log("The Result from : "+JSON.stringify(this.selectedProduct) );
        console.log("Type of" +typeof(this.selectedProduct));
       
    
        await getproductList({prodId: this.selectedProduct})
        .then(result => {
            console.log("The Result from APEX is: "+JSON.stringify(result) );
            
            this.productList = result;
            console.log("The Result from APEX2 is: "+JSON.stringify(this.productList) );
            this.isProductIdAvailable = true;
            //this.error = undefined;        
            
            
           
        }).catch(error => {
            console.log("The error SENT TO APEX is: " +JSON.stringify(error));
            this.error = error;
            //this.data  = undefined;
        });
    }


    /*async  handleClick(event){
        
       
        var selRows = this.template.querySelector('lightning-datatable');
        var selected = selRows.getSelectedRows();

        var newskuval = selected.map(row => { return { "ccrz__SKU__c": row.ccrz__SKU__c}});    
        var newmatval = selected.map(row => { return { "MaterialDescription__c": row.MaterialDescription__c}});  
        var newperval = selected.map(row => { return { "ccrz__Quantityperunit__c": row.ccrz__Quantityperunit__c}});  
        var newqtyval = selected.map(row => { return { "Quantity_Selected__c": row.Quantity_Selected__c}});  

       this.valuetopass = selected;

        console.log('BEFORE PASSING THE EVENT' + JSON.stringify(this.valuetopass));

        const selectedEvent = new CustomEvent('productevent', {detail: this.valuetopass});

        this.dispatchEvent(selectedEvent);


        this.valuetopass = selected;
        var prod =   JSON.stringify(this.valuetopass);

        //console.log('value to pass check:' + JSON.stringify(selected));
        //console.log('value for sku:' + JSON.stringify(newskuval));
        //console.log('value for desc:' + JSON.stringify(newmatval));
        //console.log('value for quatityunit:' + JSON.stringify(newperval));
        //console.log('value to QuantitySelected:' + JSON.stringify(newqtyval));
        

    
            this.flagIndi= true;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Records added to the cart successfully',
                    variant: 'success'
                })
            );

            

        

        //this.template.querySelector("c-new-spec-reg-child-l-w-c").setProdValues(newskuval);
  
     }*/

     async handleSave(event){
         this.isLoading = true;
        console.log(event.detail.draftValues)
        const recordInputs = event.detail.draftValues.slice().map(draft=>{
            const fields = Object.assign({}, draft)
            return {fields}
        })
        console.log("recordInputs", recordInputs)

        const promises = recordInputs.map(recordInput => updateRecord(recordInput))
       await Promise.all(promises).then(result=>{
           this.ShowToastMsg('Success', 'Product Details Updated')
           this.draftValues=[];   
           console.log('Before Refresh: '+ JSON.stringify(this.productList));
           console.log('Check for Refresh: '+ this.selectedProduct);
           //return refreshApex(this.productList);

           
        }).catch(error=>{
            this.ShowToastMsg('Error Updating Records', error.body.message, error)
        });
     this.handleSuccess();
    }

    async handleSuccess() {
        await getproductRefList({prodId: this.selectedProduct})
                .then(result => {
                    this.productList = result;
                    console.log(result);
                    console.log('After refresh datatable data: ' + JSON.stringify(this.productList));
                    this.ShowToastMsg('Success', 'Product Details Updated')
                    
                });
            this.handleClick(); 
     }
     

    ShowToastMsg(title, message, variant){
        this.dispatchEvent(
            new ShowToastEvent({
                title:title,
                message:message,
                variant:variant||'success'
            })
        )
    }

    async handleClick(event){
        //const updatedFields = event.detail.draftValues;
       // var selRows = this.template.querySelector('lightning-datatable');
        var selected = this.productList;
        console.log('Stored Lines: '+ JSON.stringify(this.storedLines));
        var newSelVal = selected.map(row => { return { "Product_SKU__c": row.MaterialDescription__c, "Product_Description__c" :row.ccrz__ShortDescRT__c, "SKU__c":row.ccrz__SKU__c, "Type__c":"New Spec Registration",
                    "Selected_Qty__c":row.Quantity_Selected__c,"CC_Product_Id__c":row.Id, "Transaction_ID__c": this.transactionID, "Unique_ID__c": this.transactionID+'_'+row.MaterialDescription__c }});
        
        this.valuetopass = selected;
        console.log('value to pass check:' + JSON.stringify(this.valuetopass));
                                            
        console.log('value to pass check:' + JSON.stringify(newSelVal));
        await updateReturnItemList({data: newSelVal})
        .then(result => {
            console.log(JSON.stringify("Apex update result: "+ result));
            this.flagIndi= true;
            this.isLoading = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Records added to the card successfully',
                    variant: 'success'
                })
            );
            this.fetchReturnItems();
        });
    
    }
    fetchReturnItems(){
        getReturnProdList({transId : this.transactionID})
           .then(result =>{
               this.storedLines = result;
               this.cartCount = this.storedLines.length;
           this.dispatchEvent(
               new CustomEvent('lineupdate', {
                   detail: {
                       lines : this.storedLines
                   }
               }));
       });
    }

    showCart(event) {
        this.bShowModal = true; // display modal window
    }

    // to close modal window set 'bShowModal' tarck value as false
    closeModal() {
        this.bShowModal = false;
    } 

    // POTENTIAL FUTURE - SAVE CART FUNCTION
    saveCart(){
        localStorage.setItem('localStr',JSON.stringify(this.storedLines));
        var retrieveData = JSON.parse(localStorage.getItem('localStr'));
        console.log('Data in Saved Cart: '+JSON.stringify(retrieveData));
    }

    showWarranty(event){
        
        this.warrantyEntry = true;
        this.isProductIdAvailable = false;
        this.searchProducts = false;
    }

    showProduct(event){
        this.warrantyEntry = false;
        this.searchProducts = true;
   
    }

    setManualLines(event){
        this.manualLines = event.detail.manuallines;
        this.cartCount = this.manualLines.length; 
        console.log("Manual Lines Sending to Parent: "+JSON.stringify(this.manualLines));
        this.dispatchEvent(
            new CustomEvent('lineupdate', {
                detail: {
                    lines : this.manualLines
                }
            }));
    }

}