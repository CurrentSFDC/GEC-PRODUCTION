/**
 * Created by andra on 2021. 03. 25..
 */

import {LightningElement, wire, api, track} from 'lwc';
import {getRecord} from "lightning/uiRecordApi";
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {PLEASE_FILL_ALL_REQUIRED_FIELDS, SOMETHING_WENT_WRONG_PLEASE_TRY_AGAIN_LATER} from "c/constants";
import {fireErrorToast} from "c/toast";
import {isNoneOfThemNullOrEmptyString, validateInputs} from "c/util";
import getProductsFromFile from '@salesforce/apex/StockBalancingReturnLwcController.getProductListFromFile';

import STOCKBALANCINGTEMPLATE from '@salesforce/resourceUrl/StockBalancingTemplate';
import STOCKBALANCINGHELPTEMPLATE from '@salesforce/resourceUrl/StockBalancingTemplateHelp';

const orderItemTemplate = {materialMaster: null, transactionId: '', lineNumber: '000010', returnQuantity: '', uom: '', uomOptions: [], uomLabel: '', price: '', materialName: '', totalPrice: '', currency: '', validationComment: '', status: '', agent: '', quantityPerUnit: 1};

export default class StockBalancingReturnProdEntryManual extends LightningElement {

    templateURL = STOCKBALANCINGTEMPLATE;
    helpURL = STOCKBALANCINGHELPTEMPLATE;

    @track orderItems = [{...orderItemTemplate}];
    @api isStockBalancingReturnsFileUpload;
    @api isReturnNumberNotNull;
    @api remainingReturns;
    @api returnType;
    @api productFamilies;
    @api agentCodeOptions;

    get acceptedFormats() {
        return ['.csv'];
    }

    get isBottomAddProductNeeded(){
        if(this.orderItems.length >= 5){
            return true;
        } else{
            return false;
        }
    }

    handleFileUpload(event) {
        try {
            const uploadedFiles = event.detail.files;
            getProductsFromFile({idContentDocument : uploadedFiles[0].documentId})
            .then(result => {
                console.log('result ===> '+JSON.stringify(result));
                this.orderItems = JSON.parse(JSON.stringify(result));
                this.orderItems = [...this.orderItems];
                this.passItemListToParent(event);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Your file is uploaded',
                        variant: 'success',
                    }),
                );
            })
            .catch(error => {
                this.error = error;
                console.log(error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: JSON.stringify(error),
                        variant: 'error',
                    }),
                );
            })
        } catch (error) {
            console.error(error);
            fireErrorToast(this, 'File upload has failed!');
        }
        console.log(JSON.stringify(products));
    }

    handleMaterialMasterChange(event){
        const index = +event.currentTarget.dataset.index;
        console.log(index, event.detail.selectedMaterial);
        if(event.detail.selectedMaterial == null || event.detail.selectedMaterial == undefined){
            this.orderItems[index].validationComment = 'Please select a valid product'
        }
        this.orderItems = [...this.orderItems];
        this.passItemListToParent(event);
    }

    handleMaterialMasterSelect(event) {
        try {
            const index = +event.currentTarget.dataset.index;
            console.log(index, event.detail.selectedMaterial)
            let selectedMaterial = event.detail.selectedMaterial;
            if (selectedMaterial != null) {
                this.orderItems[index].materialMaster = null;
                this.orderItems[index].materialMaster = selectedMaterial;
                this.orderItems[index].validationComment = '';
                if (selectedMaterial.uomOptions != null) {
                    this.orderItems[index].uomOptions = selectedMaterial.uomOptions;
                    if(selectedMaterial.uomOptions.length == 1){
                        this.orderItems[index].uom = selectedMaterial.uomOptions[0].value;
                        this.orderItems[index].uomLabel = selectedMaterial.uomOptions[0].label;
                    }
                } else {
                    this.orderItems[index].uomOptions = [{"label":"Piece","value":"PC"}];
                    this.orderItems[index].uom = "PC";
                    this.orderItems[index].uomLabel = "Piece";
                }
                console.log(JSON.stringify(this.orderItems[index].uomOptions));
                this.orderItems[index].materialName = selectedMaterial.GE_LGT_EM_SAP_MaterialNumber__c + ' - ' + selectedMaterial.GE_LGT_EM_MaterialDescription__c;
                this.orderItems[index].quantityPerUnit = selectedMaterial.Quantity_per_Unit__c != null ? selectedMaterial.Quantity_per_Unit__c : 1;
                console.log('qtyperunit set to ' + this.orderItems[index].quantityPerUnit);
            }
            this.orderItems = [...this.orderItems];
        } catch (error) {
            console.error(error);
        }
        this.passItemListToParent();
    }

    passItemListToParent(event){
        const selectedEvent = new CustomEvent("returnitemschange", {
              detail: this.orderItems
              });

        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }

    handleMaterialMasterReset(event) {
        try {
            const index = +event.currentTarget.dataset.index;
            this.orderItems[index].materialMaster = null;
            this.orderItems[index].uom = '';
            this.orderItems[index].uomLabel = '';
            this.orderItems[index].returnQuantity = '';
            this.orderItems[index].uomOptions = [];
            this.orderItems[index].priceAndCurrency = '';
            this.orderItems[index].price = '';
            this.orderItems[index].currency = '';
            this.orderItems[index].totalPrice = '';
            this.orderItems[index].validationComment = '';
            this.orderItems[index].status = '';
            this.orderItems[index].quantityPerUnit = 1;
            this.orderItems[index].currencyIsoCode = 'USD';
            this.orderItems = [...this.orderItems];
            this.passItemListToParent();
        } catch (error) {
            console.error(error);
        }
    }

    handleAgentChange(event){
        try {
            const index = +event.currentTarget.dataset.index;
            this.orderItems[index].agent = event.detail.value;
            this.orderItems = [...this.orderItems];
            } catch (error) {
                console.error(error);
            }
            this.passItemListToParent();
    }

    handleQtyChange(event) {
        try {
            const index = +event.currentTarget.dataset.index;
            this.orderItems[index].returnQuantity = event.detail.value;
            this.orderItems = [...this.orderItems];
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Quantity has been adjusted to reflect full case quantity',
                    variant: 'success',
                }),
            );
        } catch (error) {
            console.error(error);
        }
        this.passItemListToParent();

    }

    validateQty(event) {
        try {
            const index = +event.currentTarget.dataset.index;
            if (parseInt(this.orderItems[index].returnQuantity) % parseInt(this.orderItems[index].quantityPerUnit) != 0) {
                this.orderItems[index].returnQuantity = '' + (parseInt(this.orderItems[index].returnQuantity) + (parseInt(this.orderItems[index].quantityPerUnit) - (parseInt(this.orderItems[index].returnQuantity) % parseInt(this.orderItems[index].quantityPerUnit))));
            }
        } catch (error) {
            console.error(error);
        }
        this.passItemListToParent();
    }

    handleUomChange(event) {
        try {
            const index = +event.currentTarget.dataset.index;
            var newUom = event.detail.value;
            this.orderItems[index].uom = newUom
            for(var uom of this.orderItems[index].uomOptions){
                if(uom.value == newUom){
                    this.orderItems[index].uomLabel = uom.label;
                }
            }
            this.orderItems = [...this.orderItems];
        } catch (error) {
            console.error(error);
        }
        this.passItemListToParent();
    }

    removeOrderItem(event) {
        try {
            const index = +event.currentTarget.dataset.index;
            this.orderItems.splice(index, 1);
            if (this.orderItems.length === 0) {
                this.orderItems = [{...orderItemTemplate}];
            } else {
                this.generateLineNumbersForOrderItems();
                this.orderItems = [...this.orderItems];
            }
        } catch (error) {
            console.error(error);
        }
        this.passItemListToParent();
    }

    generateLineNumbersForOrderItems() {
        if (this.orderItems != null) {
            for (let i = 0; i < this.orderItems.length; i++) {
                this.orderItems[i].lineNumber = (i + 1 + '0').padStart(6, '0');
            }
        }
    }

    addOrderItem() {
        let newOrderItem = {...orderItemTemplate};
        newOrderItem.lineNumber = (this.orderItems.length + 1 + '0').padStart(6, '0');
        newOrderItem.transactionId = 'id' + Date.now();
        this.orderItems = Object.assign([], this.orderItems);
        this.orderItems.push(newOrderItem);
        this.orderItems = [...this.orderItems];

    }
}