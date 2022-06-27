import { LightningElement, track, api, wire } from 'lwc';
import getInventoryAvailabilityForComm from '@salesforce/apex/InventoryController.getInventoryAvailabilityForComm';

export default class CommunityInventoryView extends LightningElement {
    @api sku;
    @api product;
    @track inventoryIsEmpty = false;
    @track totalQuantity = 0;
    @track inventoryList = [];
    @track currentDate = new Date();

    connectedCallback() {
        console.log("SKU: ", this.sku);
    }

    async getInventory(event) {
        var sku = event.target.title;
        var agentId = localStorage.getItem("AgentID");
        var custId = localStorage.getItem("DistributorID") !== null ? localStorage.getItem("DistributorID") : "";
        console.log("sku ",sku);
        
        var loadingEvent = new CustomEvent("isloading", {
            detail: true
        });
        this.dispatchEvent(loadingEvent);
        
        var result = await getInventoryAvailabilityForComm({sku: sku, agentID: agentId, CustID: custId});
        this.inventoryList = [];
        var inventoryData = [];
        if (result !== null) {
            var inventoryData = result.inventoryMap[0];

            if (inventoryData.length > 0) {

                inventoryData.forEach(item => {

                    if (item.isDisplay) {
                        this.inventoryList.push(item);
                    }
                });

                if (this.inventoryList.length > 0) {
                    var lastInvElem = this.inventoryList.slice(-1);
                    this.totalQuantity = lastInvElem[0].totalQuantity;
                } else {
                    this.inventoryIsEmpty = true;
                }

                this.template.querySelector('.inventory-modal').classList.add('slds-fade-in-open');
                this.template.querySelector('.slds-backdrop').classList.add('slds-backdrop_open');
            }

            console.log("result ", result);
            console.log("Inventory List: ", JSON.stringify(this.inventoryList));
        }
        
        loadingEvent = new CustomEvent("isloading", {
            detail: false
        });
        this.dispatchEvent(loadingEvent);
    }

    closeModal() {
        this.template.querySelector('.inventory-modal').classList.remove('slds-fade-in-open');
        this.template.querySelector('.slds-backdrop').classList.remove('slds-backdrop_open');
    }
}