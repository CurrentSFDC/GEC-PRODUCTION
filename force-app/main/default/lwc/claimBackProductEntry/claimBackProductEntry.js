/**
 * Created by andra on 2021. 03. 25..
 */

import { LightningElement, wire, api, track } from 'lwc';
import processInvoiceFile from "@salesforce/apex/ClaimBackController.processInvoiceFile";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import CLAIMBACKTEMPLATE from '@salesforce/resourceUrl/ClaimbackTemplate';
import CLAIMBACKTEMPLATEHELP from '@salesforce/resourceUrl/ClaimbackTemplateHelp';

export default class ClaimBackProdEntryManual extends LightningElement {

    templateURL = CLAIMBACKTEMPLATE;
    helpURL = CLAIMBACKTEMPLATEHELP;

    @api soldToAccountId;
    @api returnType;
    @api productFamilies;
    @api priceAgreementNumbers;
    @api invoicesfromparent;
    @api accountCurrency;

    @track invoices;
    @track currentEndCustomerAccountNum;

    modalMessage;

    get acceptedFormats() {
        return ['.csv'];
    }

    get shipmentOptions() {
        return [
            { label: 'Regular', value: 'regular' },
            { label: 'Drop Ship', value: 'dropship' },
        ];
    }

    get paNumbers() {
        let returnData = [];
        for (let p of this.priceAgreementNumbers) {
            returnData.push({ label: p.Agreement_No__c, value: p.Agreement_No__c });
        }
        return returnData;
    }

    get paNumbersForFileUpload() {
        let returnData = '';
                for (let p of this.priceAgreementNumbers) {
                    returnData = returnData + p.Agreement_No__c + '-';
                }
                return returnData;
    }

    get displayAccountCurrency() {
        return this.accountCurrency == 'CAD' ? 'CA$' : '$';
    }

    connectedCallback() {
        console.log(JSON.stringify(this.invoicesfromparent));
        if(!this.invoicesfromparent){
            this.invoices = [this.getDefaultInvoice('1')];
        }
        else{
            this.invoices = [];
            for(var i of this.invoicesfromparent){
                let tempInvoice = {};
                for(var iparam in i){
                    if(iparam === 'products'){
                        tempInvoice.products = [];
                        for(var p of i.products){
                            let tempProduct = {};
                            for(var pparam in p){
                                if(pparam === 'materialMaster'){
                                    tempProduct.materialMaster = Object.assign({}, p.materialMaster);
                                }
                                else{
                                    tempProduct[pparam] = p[pparam];
                                }
                            }
                            tempInvoice.products.push(tempProduct);
                        }
                    }
                    else if(iparam === 'endCustomerAccountNumInfo'){
                        tempInvoice.endCustomerAccountNumInfo = Object.assign({}, i[iparam]);
                    }
                    else{
                        tempInvoice[iparam] = i[iparam];
                    }
                }
                this.invoices.push(tempInvoice);
            }
            this.invoices = [...this.invoices];
        }
        console.log('Connected Callback', JSON.stringify(this.invoices));
        console.log('PA Numbers', JSON.stringify(this.priceAgreementNumbers));
        this.currentEndCustomerAccountNum = {
            invoiceId : 0,
            ecaAccountNumber : '',
            ecaname : '',
            ecaAddress1 : '',
            ecaAddress2 : '',
            ecaPostalCode : '',
            ecaCity : '',
            ecaCountry : '',
            ecaState : ''
        };
    }

    @api reportValidity(){
        let allValid = [...this.template.querySelectorAll('.validationinput')]
        .reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            console.log(inputCmp.name, inputCmp.checkValidity());
            return validSoFar && inputCmp.checkValidity();
        }, true);

        let materialLookupComponent = [...this.template.querySelectorAll('c-material-lookup')]
        .reduce((validSoFar, inputCmp) => {
            console.log('Material lookup', inputCmp.reportValidity());
            return inputCmp.reportValidity() && validSoFar;
        }, true);

        return allValid && materialLookupComponent;
    }

    handleFileUpload(event) {
        //try {
            const files = event.detail.files[0];
            console.log(JSON.stringify(files));
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Information',
                    message: 'Processing of your file has been started, please wait...',
                    variant: 'info',
                }),
            );
            processInvoiceFile({contentDocumentId : files.documentId, paNumbers: this.paNumbersForFileUpload})
            .then(result => {
                console.log(JSON.stringify(result));
                this.invoices = JSON.parse(JSON.stringify(result));
                console.log(JSON.stringify(this.invoices));
                if (JSON.stringify(this.invoices).includes('Invalid Catalog Number:')) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Warning',
                            message: 'Your file is uploaded, but contains invalid catalog numbers! Please review them before proceeding!',
                            variant: 'warning',
                        }),
                    );
                } else if (JSON.stringify(this.invoices).includes('badPaNo')) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Warning',
                            message: 'Your file is uploaded, but contains invalid Price Agreement numbers! Please review them before proceeding!',
                            variant: 'warning',
                        }),
                    );
                } else {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Your file is uploaded',
                            variant: 'success',
                        }),
                    );
                }
                this.passItemListToParent();
            })
            .catch(error => {
                this.error = error;
                console.log(JSON.stringify(error));
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error.body.message,
                        variant: 'error',
                    }),
                );
            })
        /*} catch (error) {
            console.error(error);
            fireErrorToast(this, 'File upload has failed!');
        }*/
    }

    openModal(event) {
        event.preventDefault();
        event.stopPropagation();
        this.currentEndCustomerAccountNum.invoiceId = event.target.dataset.invoiceid;
        for(var invoice of this.invoices){
            if(invoice.invoiceId === this.currentEndCustomerAccountNum.invoiceId){
                for(var customerAccountNumParam in invoice.endCustomerAccountNumInfo){
                    this.currentEndCustomerAccountNum[customerAccountNumParam] = invoice.endCustomerAccountNumInfo[customerAccountNumParam];
                }
                break;
            }
        }
        this.template.querySelector("[data-id='modalSection']").classList.add("slds-fade-in-open");
        this.template.querySelector("[data-id='modalBackdrop']").classList.add("slds-backdrop_open");
        console.log(this.template.querySelector("[data-id='ecaAccountNumber']"));
        this.template.querySelector("[data-id='ecaAccountNumber']").focus();
    }

    closeModal(){
        this.template.querySelector("[data-id='modalSection']").classList.remove("slds-fade-in-open");
        this.template.querySelector("[data-id='modalBackdrop']").classList.remove("slds-backdrop_open");
    }

    onEndCustomerAccountNumChange(event){
        this.currentEndCustomerAccountNum[event.target.name] = event.target.value;
    }

    saveEndCustomerAccountNum(event){
        if(!this.currentEndCustomerAccountNum.ecaAccountNumber || !this.currentEndCustomerAccountNum.ecaname){
            this.modalMessage = 'Please fill out all required fields to save';
            return;
        }
        for(var invoice of this.invoices){
            if(invoice.invoiceId === this.currentEndCustomerAccountNum.invoiceId){
                invoice.endCustomerAccountNum = '';
                for(var customerAccountNumParam in invoice.endCustomerAccountNumInfo){
                    if(this.currentEndCustomerAccountNum[customerAccountNumParam]) invoice.endCustomerAccountNum += this.currentEndCustomerAccountNum[customerAccountNumParam] + '--';
                    invoice.endCustomerAccountNumInfo[customerAccountNumParam] = this.currentEndCustomerAccountNum[customerAccountNumParam];
                }
                //let domId = 'eca' + invoice.invoiceId;
                //this.template.querySelector("[data-domid=" + domId + "]").value = invoice.endCustomerAccountNum;
                
                break;
            }
        }

        this.passItemListToParent();

        this.closeModal();
    }

    clearCurrentEndCustomerAccountNum(){
        this.currentEndCustomerAccountNum = JSON.parse(JSON.stringify({
            invoiceId : "0",
            accountNumber : '',
            ecaname : '',
            address1 : '',
            address2 : '',
            postalCode : '',
            city : '',
            country : '',
            state : ''
        }));
    }

    addInvoice(event){
        let invoiceId = this.invoices.length + 1;
        this.invoices.push(this.getDefaultInvoice(invoiceId));
        this.invoices = [...this.invoices];
        this.passItemListToParent();
    }

    removeInvoice(event){
        let invoiceId = Number(event.target.value);
        for(var i = 0; i < this.invoices.length; i++){
            if(Number(this.invoices[i].invoiceId) == invoiceId){
                this.invoices.splice(i, 1);
                break;
            }
        }

        for(var i = 0; i < this.invoices.length; i++){
            if(Number(this.invoices[i].invoiceId) > invoiceId){
                this.invoices[i].invoiceId = (Number(this.invoices[i].invoiceId) - 1) + "";
            }
        }
        this.invoices = [...this.invoices];   
        this.passItemListToParent();
    }

    addProduct(event) {
        let invoiceId = event.target.value;
        for(let i of this.invoices){
            if(i.invoiceId === invoiceId){
                i.products.push(this.getDefaultProduct((i.products.length + 1) + ""));
                break;
            }
        }

        this.invoices = [...this.invoices];
        this.passItemListToParent();
    }

    removeProduct(event){
        let invoiceId = event.target.dataset.invoiceid;
        let productId = event.target.value;

        for(let invoice of this.invoices){
            if(invoice.invoiceId === invoiceId){
                console.log('products', invoice.products);
                for(var i = 0; i < invoice.products.length; i++){
                    if(Number(productId) == Number(invoice.products[i].productId)){
                        console.log('removing', i, invoice.products[i].productId);
                        invoice.products.splice(i, 1);
                        break;
                    }
                }

                for(var i = 0; i < invoice.products.length; i++){
                    if(Number(productId) < Number(invoice.products[i].productId)){
                        console.log('shifting', i, invoice.products[i].productId);
                        invoice.products[i].productId = (Number(invoice.products[i].productId) - 1) + "";
                    }
                }
                if (invoice.products.length == 0) {
                    this.addProduct(event);
                }

                console.log('products', invoice.products);
                break;
            }
        }

        this.invoices = [...this.invoices];
        this.passItemListToParent();
    }

    handleInvoiceFieldChange(event){
        for(var i of this.invoices){
            if(i.invoiceId === event.target.dataset.invoiceid){
                i[event.target.name] = event.target.value;
            }
        }
        this.passItemListToParent();
    }

    handleProductFieldChange(event){
        let invoiceId = event.target.dataset.invoiceid;
        let productId = event.target.dataset.productid;
        for(var i of this.invoices){
            if(i.invoiceId === invoiceId){
                for(var prod of i.products){
                    if(prod.productId === productId){
                        var changedFieldName = event.target.name;
                        if (changedFieldName === 'priceAgreementNumber' && prod[changedFieldName] == 'badPaNo') {
                            prod['validationWarning'] = '';
                        }
                        prod[changedFieldName] = event.target.value;
                        if(
                            (changedFieldName === 'gecPrice' || changedFieldName === 'priceAgreementPrice' || changedFieldName === 'quantity') && 
                            prod['gecPrice'] && prod['priceAgreementPrice'] && prod['quantity']){
                            prod['creditPerUnit'] = (parseFloat(prod['gecPrice']) - parseFloat(prod['priceAgreementPrice'])) * prod['quantity'];
                            prod['creditPerUnit'] = (Math.round(prod['creditPerUnit'] * 100) / 100).toFixed(2);
                        }
                        break;
                    }
                }
                break;
            }
        }
        this.invoices = [...this.invoices];
        this.passItemListToParent();
    }

    handleShipmentTypeChange(event){
        console.log(JSON.stringify(this.invoices));
        console.log(event.target.dataset.invoiceid);
        for(var i of this.invoices){
            if(i.invoiceId === event.target.dataset.invoiceid){
                i['shipmentType'] = event.detail.value;
                i['shipmentTypeLabel'] = event.detail.value === 'regular' ? 'Regular' : 'Drop Ship';
                i['gecInvoiceNumRequired'] = event.detail.value === 'dropship';
            }
        }
        this.passItemListToParent();
    }

    handleMaterialMasterChange(event){
        this.passItemListToParent(event);
    }

    handleMaterialMasterSelect(event) {
        console.log('handle material master select');
        let invoiceId = event.target.dataset.invoiceid;
        let selectedMaterial = event.detail.selectedMaterial;
        for(var invoice of this.invoices){
            if(invoice.invoiceId === invoiceId){
                let productId = event.target.dataset.productid;
                for(var product of invoice.products){
                    if(product.productId === productId){
                        product.materialMaster = selectedMaterial;
                        product.materialName = selectedMaterial.GE_LGT_EM_SAP_MaterialNumber__c + ' - ' + selectedMaterial.GE_LGT_EM_MaterialDescription__c;
                        product.qtyPerUnit = selectedMaterial.Quantity_per_Unit__c != null ? selectedMaterial.Quantity_per_Unit__c : 1;
                        product.currencyIsoCode = selectedMaterial.CurrencyIsoCode != null ? selectedMaterial.CurrencyIsoCode : 'USD';
                        product['validationWarning'] = '';
                        console.log('product', product.materialName);
                        break;
                    }
                }
                break;
            }
        }
        this.invoices = [...this.invoices];
        this.passItemListToParent();
    }

    getDefaultInvoice(invoiceId){
        let invoiceObject = {};
        invoiceObject['invoiceId'] = invoiceId + "";
        invoiceObject['endCustomerAccountNumDomId'] = "eca" + invoiceId;
        invoiceObject['gecInvoiceNumRequired'] = false;
        invoiceObject['invoiceNumber'] = '';
        invoiceObject['invoiceDate'] = '';
        invoiceObject['shipmentType'] = 'regular';
        invoiceObject['shipmentTypeLabel'] = 'Regular';
        invoiceObject['gecInvoice'] = '';
        invoiceObject['jobName'] = '';
        invoiceObject['creditRequestReferenceNum'] = '';
        invoiceObject['endCustomerAccountNum'] = '';
        invoiceObject['endCustomerAccountNumInfo'] = {
            ecaAccountNumber : '',
            ecaname : '',
            ecaAddress1 : '',
            ecaAddress2 : '',
            ecaPostalCode : '',
            ecaCity : '',
            ecaCountry : '',
            ecaState : ''
        };
        let product = this.getDefaultProduct('1');
        invoiceObject['products'] = [product];
        return invoiceObject;
    }

    getDefaultProduct(productId){
        let product = {};
        product['productId'] = productId;
        product['materialMaster'] = undefined;
        product['materialName'] = '';
        product['quantity'] = '';
        product['priceAgreementNumber'] = '';
        product['gecPrice'] = '';
        product['priceAgreementPrice'] = '';
        product['creditPerUnit'] = '';
        product['qtyPerUnit'] = '1';
        product['currencyIsoCode'] = 'USD';
        product['validationWarning'] = '';
        return product;
    }

    passItemListToParent(){
        console.log('Passing Event');
        const selectedEvent = new CustomEvent("invoicedatachange", {
            detail: this.invoices
        });
 
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
        console.log('Event Passed');
    }

    validateQty(event) {
            try {
                let invoiceId = event.target.dataset.invoiceid;
                let productId = event.target.dataset.productid;
                for(var i of this.invoices){
                    if(i.invoiceId === invoiceId){
                        for(var prod of i.products){
                            if(prod.productId === productId){
                                if (parseInt(prod['quantity']) % parseInt(prod['qtyPerUnit']) != 0) {
                                    prod['quantity'] = parseInt(prod['quantity']) + (parseInt(prod['qtyPerUnit']) - (parseInt(prod['quantity']) % parseInt(prod['qtyPerUnit'])));
                                }
                                prod['creditPerUnit'] = (prod['gecPrice'] - prod['priceAgreementPrice']) * prod['quantity'];
                                prod['creditPerUnit'] = prod['creditPerUnit'] + "";
                                break;
                            }
                        }
                        break;
                    }
                }
                this.invoices = [...this.invoices];
            } catch (error) {
                console.error(error);
            }
            this.passItemListToParent();
        }

}