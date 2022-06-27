import { LightningElement, track, api, wire } from 'lwc';
import getPDF from '@salesforce/apex/OrderAckPDFController.getPDF';
import prepEmail from '@salesforce/apex/OrderAckPDFController.prepEmail';
import getInvoicePDF from '@salesforce/apex/InvoicePDFController.getInvoicePDF';
import getRMAPDF from '@salesforce/apex/OrderRMAPDFController.getPDF';
import getDeliveryNotesPDF from '@salesforce/apex/DeliveryNotesPDFController.getPDF';
export default class TestPDFViewerLWC extends LightningElement {

@api number = '903356';
@api recordId;
@track pdfData;
@api type = 'Order';
@api label = 'Order Confirmation';
@api variant = 'brand';
@track isOrder;
@track isInvoice;

@track showPDFModal = false;
@track showEmailModal = false;
@track sendDisabled = false;
@track isSending = false;
@track isLoading = false;
@track emailSent = false;

async connectedCallback(){
    if(this.type == "Order" || this.type == "RMA"){
        this.isOrder = true;
    } else if(this.type == "Invoice" || this.type == "Packing List"){
        this.isInvoice = true;
    }
}

async showModal(){
    this.emailSent = false;
    this.showPDFModal = true;
}

async loadpdf(event){
    this.isLoading = true;
if(this.type == "Order"){

    await getPDF({ordNumber: this.number})
    .then(result =>{
        this.pdfData = result.base64Data;
        console.log('BASE64DATA RETURNED: '+this.pdfData);
        this.isLoading = false;
    })
} else if (this.type == "Invoice") {
    await getInvoicePDF({invNumber: this.number})
    .then(result =>{
        this.pdfData = result.base64Data;
        console.log('BASE64DATA RETURNED: '+this.pdfData);
        this.isLoading = false;
    })
} else if (this.type == "Packing List") {
    await getDeliveryNotesPDF({invNumber: this.number})
    .then(result =>{
        this.pdfData = result.base64Data;
        console.log('BASE64DATA RETURNED: '+this.pdfData);
        this.isLoading = false;
    })
}
else if (this.type == "RMA") {
    await getRMAPDF({ordNumber: this.number})
    .then(result =>{
        this.pdfData = result.base64Data;
        console.log('BASE64DATA RETURNED: '+this.pdfData);
        this.isLoading = false;
    })
}

    this.template.querySelector('iframe').contentWindow.postMessage(this.pdfData,window.location.origin);  
}

closeModal(){
    this.showPDFModal = false;
}

emailModal(){
    this.showEmailModal = true;
}

closeEmailModal(){
    this.showEmailModal = false;
}

async sendEmail(){
    this.emailSent = false;
    this.isSending = true;
    let email = this.template.querySelector('.em').value;
    let ccemail = this.template.querySelector('.aem').value;

    await prepEmail({emailAddress : email, ccAddresses : ccemail, orderId : this.recordId, orderNumber: this.number,  pdfData : this.pdfData, type: this.type})    .then( result => {
        console.log('Result: '+result);
        this.isSending = false;
    })
    .catch(error => {
        console.log('Error: '+JSON.stringify(error));
        this.isSending = false;
    }); 

}

async handleEmailValidation(){
    const allValid = [...this.template.querySelectorAll('.validVal')]
    .reduce((validSoFar, inputCmp) => {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
    }, true);
        if (allValid) {
            this.emailSent = false;
            this.isSending = true;
            let email = this.template.querySelector('.em').value;
            console.log('Email being Passed: '+email);
            let ccemail = this.template.querySelector('.aem').value;
            console.log('CC Email Addresses: '+ccemail);
            if (ccemail === undefined){
                ccemail = ',';
            }
            await prepEmail({emailAddress : email, ccAddresses : ccemail, orderId : this.recordId, orderNumber: this.number,  pdfData : this.pdfData, type: this.type})            .then( result => {
                console.log('Result: '+result);
                this.isSending = false;
                this.emailSent = true;
            })
            .catch(error => {
                console.log('Error: '+JSON.stringify(error));
                this.isSending = false;
            }); 
        } else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'ERROR',
                    message: 'Please fill out all Required Fields',
                    variant: 'error'
                })
            );
        }

       

   





}


}