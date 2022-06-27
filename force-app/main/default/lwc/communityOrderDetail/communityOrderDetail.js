import { LightningElement, track, wire } from 'lwc';
import getOrder from '@salesforce/apex/OrderController.getOrder';
import getDetails from '@salesforce/apex/OrderController.getDetails';
import getPDF from '@salesforce/apex/AgreementPDFController.getPDF';
import getTrackingDetails from '@salesforce/apex/AfterShipController.getTrackingDetails';
import {downloadFromBase64String} from "c/downloader";
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import USER_EMAIL from '@salesforce/schema/User.Email';
import {fireErrorToast} from "c/toast";

const orderHeaderObject = {
    GE_Order_NO__c: "",
    BlockDescription__c: "",
    CreditStatus__c: "",
    CurrencyIsoCode:"",
    Customer_PO_Number__c: "",
    GBSTK__c: "",
    Id: "",
    Incomplete__c: "",
    OrderSourceCode__c: "",
    SURCHARGES__c: 0,
    TotalAmount: 0,
    TotalCommission__c: 0,
    TotalCommission_per: "",
    Type: "",
    ShippingAddress_C: "",
    EffectiveDate: "",
    Order_Req_Delivery_Date__c: "",
    GE_Opportunity_Id__c: "",
    Sold_To__r: {},
    Agent_Account__r: {},
    ShippingAddress: {},
    Sold_To__r: {}
};

const trackingDataObject = {
    checkpoints: [],
    companyName: "",
    createdAt: "",
    expectedDelivery: "",
    indicator: 0,
    isDelivered: false,
    isDispatched: false,
    isInTransit: false,
    isError: false,
    lastUpdatedAt: "",
    slug: "",
    trackingNumber: "",
    updatedAt: "",
    url: ""
};
export default class CommunityOrderDetail extends LightningElement {
    @track orderRecordId = "";
    @track isLoading = true;
    @track orderDataAvaliable = false;
    @track orderZRE = false;
    @track isOrderComplete = true;
    @track isAgent = true;
    @track allowDownloadPAPdf = true;
    @track allowViewCommission = true;
    @track showShipmentFlag = false;
    @track isEmptyTrackingUrl = true;
    @track orderHeaderData = Object.assign({}, orderHeaderObject);
    @track orderData;
    @track salesHeaderData = [];
    @track orderLineItems = [];
    @track shipmentLineItems = [];
    @track orderLineItemsObject = {};
    @track trackingData = Object.assign({}, trackingDataObject);
    @track trackingCheckpoints;
    @track strategicAccountName = "";
    @track strategicAccountNo = "";
    @track shipcomplete = "No";
    currentUerEmail = "";
    currentUrl = new URL(window.location.href);
    
    @wire(getRecord, { recordId: USER_ID, fields: [USER_EMAIL]}) 
    userDetails({error, data}) {
        if (data !== undefined) {
            this.currentUerEmail = data.fields.Email.value;
        }
    }

    connectedCallback() {
        var currentUrl = new URL(window.location.href);
        var paths = currentUrl.pathname.split("/");
        
        var currentUrl = new URL(window.location);
        this.orderRecordId = paths[3];

        if (currentUrl.host.includes("stage")) {
            this.orderRecordId = paths[4];
        }

        console.log("Order Record ID: ", this.orderRecordId);
        console.log("Current User Id: ", USER_ID);
        if (localStorage.getItem("User Type") !== "Agent") {
            this.isAgent = false;
            this.allowViewCommission = false;
        }

        // Get data from salesforce org
        this.getOrderHeaderData();
        // Get data from SAP
        this.getOrderDetails();
        this.getUserPermission();
    }

    async getOrderHeaderData() {
        var orderHeaderData = await getOrder({orderId: this.orderRecordId});
        if (orderHeaderData !== null) {
            console.log("orderHeaderData: ", orderHeaderData);

            this.orderHeaderData = orderHeaderData;
            this.orderHeaderData.EffectiveDate_FORMAT = "";
            this.orderHeaderData.Order_Req_Delivery_Date__c_FORMAT = "";

            if (this.orderHeaderData.EffectiveDate !== undefined) {
                this.orderHeaderData.EffectiveDate_FORMAT = new Date(this.orderHeaderData.EffectiveDate + " 23:59:59");
            }

            if (this.orderHeaderData.Order_Req_Delivery_Date__c !== undefined) {
                this.orderHeaderData.Order_Req_Delivery_Date__c_FORMAT = new Date(this.orderHeaderData.Order_Req_Delivery_Date__c + " 23:59:59");
            }

            if (this.orderHeaderData.TotalAmount > 0 && this.orderHeaderData.TotalCommission__c > 0) {
                var per = (this.orderHeaderData.TotalCommission__c/this.orderHeaderData.TotalAmount)*100;
                this.orderHeaderData.TotalCommission_per = per.toFixed(2) +"%";
            } else {
                this.orderHeaderData.TotalCommission_per = "0.00%";
            }

            if (orderHeaderData.Strategic_Account__r !== undefined) {
                this.strategicAccountName = orderHeaderData.Strategic_Account__r.Name;
                this.strategicAccountNo = orderHeaderData.Strategic_Account__r.GE_LGT_EM_SAP_Customer_Number__c;
            }

            if (this.orderHeaderData.GBSTK__c !== "Complete") {
                this.isOrderComplete = false;
            }

            if (this.orderHeaderData.ShippingAddress.street !== undefined) {
                this.orderHeaderData.ShippingAddress_C = this.orderHeaderData.ShippingAddress.street + "\n" + this.orderHeaderData.ShippingAddress.city + " " + this.orderHeaderData.ShippingAddress.state + " " + this.orderHeaderData.ShippingAddress.postalCode + "\n" + this.orderHeaderData.ShippingAddress.country;
            } else {
                this.orderHeaderData.ShippingAddress_C = "";
            }
        }
    }

    async getOrderDetails() {
        await getDetails({orderId: this.orderRecordId})
        .then( result => {
            if (result !== null) {
                console.log("Order Detail: ", result);
                this.orderDataAvaliable = true;
                result.salesHeaderData[0].REQ_DEL_DATE_FORMAT = new Date(result.salesHeaderData[0].REQ_DEL_DATE + " 23:59:59");
                this.orderData = result;

                if (this.orderData.salesHeaderData !== undefined) {
                    this.salesHeaderData = this.orderData.salesHeaderData[0];
                    console.log("salesHeaderData: ", JSON.stringify(this.salesHeaderData));
                    
                    if (this.salesHeaderData.ORDER_TYPE == "ZRE") {
                        this.orderZRE = true;
                    }

                    if (this.salesHeaderData.ORDER_STATUS == "Ship Complete") {
                        this.shipcomplete = "Yes";
                    }
                }

                this.getOrderLineItems();
                this.getOrderShipmentLines();
            }
            this.isLoading = false;
        });
    }

    async getOrderLineItems() {
        if (this.orderData.salesItemData !== undefined) {
            var lineItems = this.orderData.salesItemData;
            
            lineItems.forEach(item => {
                var accordionTitle = item.ITEM_NUMBER;
                accordionTitle += "  |  " + item.PRODUCT_NUMBER + " ";
                accordionTitle += "  :  " + item.PRODUCT_DESCRIPTION + " ";
                accordionTitle += "  |  Shipped Qty: " + Math.floor(item.QTY_SHIPPED);
                accordionTitle += "  of  " + Math.floor(item.QUANTITY);
                
                if (item.SPECIAL_INSTRUCTIONS !== "") {
                    accordionTitle += "  |  " + item.SPECIAL_INSTRUCTIONS;
                }

                item.accordianTitle = accordionTitle;
                item.REQ_DEL_DATE_FORMAT = "";
                item.QTY_REMAINING = item.QUANTITY - item.QTY_SHIPPED;
                item.STANDARD_COMMISSION_PER = "0.00%";
                item.TOTAL_COMMISSION_PER = "0.00%";

                if (item.REQ_DEL_DATE !== undefined) {
                    item.REQ_DEL_DATE_FORMAT = new Date(item.REQ_DEL_DATE + " 23:59:59");
                }

                if (item.STANDARD_COMMISSION !== undefined && item.STANDARD_COMMISSION > 0) {
                    var stdPer = (item.STANDARD_COMMISSION/item.ITEM_NET_VALUE) * 100;
                    item.STANDARD_COMMISSION_PER = stdPer.toFixed(2) +'%';
                }

                if (item.ITEM_COMM_VALUE !== undefined && item.ITEM_COMM_VALUE > 0) {
                    var totalPer = (item.ITEM_COMM_VALUE/item.ITEM_NET_VALUE) * 100;
                    item.TOTAL_COMMISSION_PER = totalPer.toFixed(2) +'%';
                }

                this.orderLineItems.push(item);
                this.orderLineItemsObject[item.ITEM_NUMBER] = item;
            });

            console.log("Order Line Items: ", JSON.stringify(this.orderLineItems));
            console.log("Order Line Items Object: ", JSON.stringify(this.orderLineItemsObject));
        }
    }

    getOrderShipmentLines() {
        if (this.orderData.scheduleData !== undefined) {
            var shipmentItems = this.orderData.scheduleData;

            shipmentItems.forEach(item => {
                var shipQty = 0;
                var actShipDate = "";
                var lineItemNo = item.ITEM_NUMBER;

                var shipmentAccordionTitle = lineItemNo;
                shipmentAccordionTitle += "  |  " + this.orderLineItemsObject[lineItemNo].PRODUCT_NUMBER + " ";
                shipmentAccordionTitle += "  :  " + this.orderLineItemsObject[lineItemNo].PRODUCT_DESCRIPTION + " ";
                shipmentAccordionTitle += "  |  Shipped Qty: ";

                if (item.ACT_SHIP_DATE !== undefined && item.ACT_SHIP_DATE !== '0000-00-00') {
                    shipQty = Math.floor(item.QUANTITY);
                    actShipDate = "  |  " + new Date(item.ACT_SHIP_DATE + " 23:59:59").toLocaleDateString("en-US", { year: 'numeric', month: '2-digit', day: '2-digit' });
                } else if (item.EST_SHIP_DATE !== undefined && item.EST_SHIP_DATE !== '00/00/0000') {
                    actShipDate = "  |  " + new Date(item.EST_SHIP_DATE).toLocaleDateString("en-US", { year: 'numeric', month: '2-digit', day: '2-digit' });
                }

                shipmentAccordionTitle += shipQty + actShipDate;
                item.accordianTitle = shipmentAccordionTitle;

                item.EST_SHIP_DATE_FORMAT = "";
                item.EST_DEL_DATE_FORMAT = "";
                item.INVOICE_DATE_FORMAT = "";
                item.FPDD_FORMAT = "";

                if (item.EST_SHIP_DATE !== undefined) {
                    item.EST_SHIP_DATE_FORMAT = new Date(item.EST_SHIP_DATE + " 23:59:59");
                }

                if (item.EST_DEL_DATE !== undefined) {
                    item.EST_DEL_DATE_FORMAT = new Date(item.EST_DEL_DATE + " 23:59:59");
                }
                
                if (item.INVOICE_DATE !== undefined) {
                    item.INVOICE_DATE_FORMAT = new Date(item.INVOICE_DATE + " 23:59:59");
                }

                if (item.FPDD !== undefined) {
                    item.FPDD_FORMAT = new Date(item.FPDD + " 23:59:59");
                }

                this.shipmentLineItems.push(item);
            });

            console.log("Shipment Line Items: ", JSON.stringify(this.shipmentLineItems));
        }
    }

    getUserPermission() {
        // Get Read Only User Permission To Check View Price Permission & Download Prie Agreement PDF Set Or Not
        var userPermissions = localStorage.getItem("UserPermission");
        if (userPermissions !== null) {
            userPermissions = JSON.parse(userPermissions);
            if ((userPermissions['profileName'] == "Agent Read Only B2B Storefront Registered Users" ||
                userPermissions['profileName'] == "Distributor Read Only B2B Storefront Registered Users")) {
                    if (userPermissions['permissionSet'].includes('View_PLP_and_PDP_Prices') == false) {
                        this.allowDownloadPAPdf = false;
                    }

                    if (userPermissions['permissionSet'].includes('View_Commissions_Set_Price') == false) {
                        this.allowViewCommission = false;
                    }

            }
        }
    }

    handleRequest(event) {
        var actionName =  event.detail.value;
        var path = "/s/";
        var redirectTo = this.currentUrl.origin;

        if (this.currentUrl.host.includes("stage")) {
            path = "/Agents/s/";
        }

        if (actionName == "change-request") {
            redirectTo += path + 'change-request?id=' + this.orderHeaderData.Id;
        } else if (actionName == "return-replace") {
            redirectTo += path + 'return-replace?id=' + this.orderHeaderData.Id;
        } else if (actionName == "overage") {
            redirectTo += path + 'shipping-discrepancy?id=' + this.orderHeaderData.Id + "/Overage";
        } else if (actionName == "shortage") {
            redirectTo += path + 'shipping-discrepancy?id=' + this.orderHeaderData.Id + "/Shortage";
        } else if (actionName == "lost-damage") {
            redirectTo += path + 'shipping-discrepancy?id=' + this.orderHeaderData.Id + "/Lost";
        } else {
            redirectTo += path + 'warranty-claim?id=' + this.orderHeaderData.Id;
        }

        window.open(redirectTo, "_self");
    }

    async downloadAgreementPdf(event) {
        this.isLoading = true;
        var agreementNo = event.target.title;
        console.log("agreementNo: ", agreementNo);  
        var response = await getPDF({agrNumber : agreementNo});
        console.log("downloadAgreementPdf: ", response);
        if (response.base64Data !== "") {
            downloadFromBase64String(response.base64Data, 'Price-Agreement-' + agreementNo + '.pdf');
        } else {
            fireErrorToast(this, response.message);
        }

        this.isLoading = false;
    }

    closeModal() {
        this.template.querySelector(".shipment-tracking-modal").classList.remove('slds-fade-in-open');
        this.template.querySelector('.slds-backdrop').classList.remove('slds-backdrop_open');
    }

    async showTackingModal(event) {
        this.isLoading = true;
        var trackingNo = event.target.title;
        var carriergName = event.target.name;
        
        console.log("Tracking Info: ", trackingNo + ", " + carriergName + ", " + this.currentUerEmail);

        var response = await getTrackingDetails({carrierName : carriergName, trackingNumber : trackingNo, emailTo : this.currentUerEmail});
        if (response !== null) {
            console.log("response: ", response);
            this.trackingData = response;
            
            if (this.trackingData.indicator == 0) {
                this.showShipmentFlag = true;
            } else {
                if (this.trackingData.url !== undefined && this.trackingData.url !== "") {
                    this.isEmptyTrackingUrl = false;
                }
            }

            if (this.trackingData.checkpoints !== undefined && this.trackingData.checkpoints.length > 0) {
                this.trackingCheckpoints = response.checkpoints.reverse();
            }

            this.template.querySelector('.shipment-tracking-modal').classList.add('slds-fade-in-open');
            this.template.querySelector('.slds-backdrop').classList.add('slds-backdrop_open');
        } else {
            fireErrorToast(this, "Something is wrong.");
        }

        this.isLoading = false;
    }

    handleReport(event) {
        this.isLoading = true;
        var actionName =  event.detail.value;
        
        if (actionName == "line-items") {
            this.downloadLineItems();
        } else if (actionName == "shipment-info") {
            this.downloadShipmentInfo();
        }
    }

    downloadLineItems() {
        var dataTitle = ["Order No.", "Customer PO No.", "Order Line No.", "Catalog No.", "SKU", "Type Mark", "Price Agreement No.", "Quantity Ordered", "Unit of Measure", "Currency", "Price Per Unit", "Line Total", "Standard Commission", "Standard Commission Percentage", "Overage Commission", "Total Commission", "Total Commission Percentage", "Quantity Shipped", "Quantity Remaining", "Requested Delivery Date", "Shipment Status"];
        var dataKey = ["GE_Order_NO__c", "Customer_PO_Number__c", "ITEM_NUMBER", "PRODUCT_DESCRIPTION", "PRODUCT_NUMBER", "SPECIAL_INSTRUCTIONS", "PRICE_AGR_NUMBER", "QUANTITY", "SALES_UNIT", "CURRENCY_x", "UNIT_PRICE", "ITEM_NET_VALUE", "STANDARD_COMMISSION", "STANDARD_COMMISSION_PER", "OVERAGE_COMMISSION", "ITEM_COMM_VALUE", "TOTAL_COMMISSION_PER", "QTY_SHIPPED", "QTY_REMAINING", "REQ_DEL_DATE", "ITEM_STATUS"];
        //var amtDataKey = ["UNIT_PRICE", "ITEM_NET_VALUE", "STANDARD_COMMISSION", "OVERAGE_COMMISSION", "ITEM_COMM_VALUE"];
        var commissionKeys = ["STANDARD_COMMISSION", "OVERAGE_COMMISSION", "ITEM_COMM_VALUE", "STANDARD_COMMISSION_PER", "TOTAL_COMMISSION_PER"];

        let rowEnd = '\n';
        let csvString = '';
        let rowData = new Set();

        dataTitle.forEach(title => {
            rowData.add(title);
        });

        rowData = Array.from(rowData);
        csvString += rowData.join(',');
        csvString += rowEnd;

        this.orderLineItems.forEach(item => {
            var i = 0;

            dataKey.forEach(key => {

                // Set N/A if logged in user is Agent read only or distributor & don't have view commission permission
                if (this.allowViewCommission == false && commissionKeys.includes(key)) {
                    item[key] = "N/A";
                }

                if (i > 0) {
                    csvString += ",";
                }

                var value = "";
                if (["GE_Order_NO__c", "Customer_PO_Number__c"].includes(key)) {
                    value = this.orderHeaderData[key];
                } else {
                    value = (item[key] !== undefined && item[key] !== "") ? item[key] : "";
                }

                csvString += '"'+ value +'"';
                i++;
            });

            csvString += rowEnd;
        });

        console.log("CSV Order Lines: ", JSON.stringify(this.orderLineItems));
        console.log("csv string: ", csvString);
        // Creating anchor element to download
        let downloadElement = document.createElement('a');

        // This encodeURIComponent encodes special characters
        downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURIComponent(csvString);
        downloadElement.target = '_self';
        
        // Set CSV File Name
        downloadElement.download = 'OrderLineItems-' + this.orderHeaderData.GE_Order_NO__c + '.csv';
        document.body.appendChild(downloadElement);
        downloadElement.click(); 

        this.isLoading = false;
    }

    downloadShipmentInfo() {
        var dataTitle = ["Order No.", "Customer PO No.", "Order Line No.", "Catalog No.", "SKU", "Shipped Qty", "Actual Ship Date", "First Promise Date", "Estimated Shipping Date", "Estimated Delivery Date", "Carrier", "Tracking Number", "Shipped From", "Invoice No. #", "Invoice Date", "Packing List"];
        var dataKey = ["GE_Order_NO__c", "Customer_PO_Number__c", "ITEM_NUMBER", "PRODUCT_DESCRIPTION", "PRODUCT_NUMBER", "QUANTITY", "ACT_SHIP_DATE", "FPDD", "EST_SHIP_DATE", "EST_DEL_DATE", "CARRIER_NAME", "TRACKING_NUMBER", "SHIPPED_FROM", "INVOICE_NUMBER", "INVOICE_DATE", "DEL_NUMBER"];

        let rowEnd = '\n';
        let csvString = '';
        let rowData = new Set();

        dataTitle.forEach(title => {
            rowData.add(title);
        });

        rowData = Array.from(rowData);
        csvString += rowData.join(',');
        csvString += rowEnd;

        this.shipmentLineItems.forEach(item => {
            var i = 0;

            dataKey.forEach(key => {

                if (i > 0) {
                    csvString += ",";
                }

                var value = "";
                if (["GE_Order_NO__c", "Customer_PO_Number__c"].includes(key)) {
                    value = this.orderHeaderData[key];
                } else if (["PRODUCT_DESCRIPTION", "PRODUCT_NUMBER"].includes(key)) {
                    value = this.orderLineItemsObject[item["ITEM_NUMBER"]][key];
                } else if(key == "QUANTITY") {
                    value = (item["ACT_SHIP_DATE"] !== undefined && item["ACT_SHIP_DATE"] !== "0000-00-00") ? Math.floor(item[key]) : 0;
                } else if(["ACT_SHIP_DATE", "EST_SHIP_DATE"].includes(key)) {
                    value = (item[key] !== undefined && (item[key] !== "0000-00-00" && item[key] !== "00/00/0000")) ? new Date(item[key] + " 23:59:59").toLocaleDateString("en-US", { year: 'numeric', month: '2-digit', day: '2-digit' }) : "";
                } else {
                    value = (item[key] !== undefined && item[key] !== "") ? item[key] : "";
                }

                csvString += '"'+ value +'"';
                i++;
            });

            csvString += rowEnd;
        });

        console.log("csv string: ", csvString);
        // Creating anchor element to download
        let downloadElement = document.createElement('a');

        // This encodeURIComponent encodes special characters
        downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURIComponent(csvString);
        downloadElement.target = '_self';
        
        // Set CSV File Name
        downloadElement.download = 'OrderShipmentItems-' + this.orderHeaderData.GE_Order_NO__c + '.csv';
        document.body.appendChild(downloadElement);
        downloadElement.click(); 

        this.isLoading = false;
    }

    // Catch event from CommunityInventoryView child component
    handleIsLoading(event) {
        console.log("handleIsLoading: ", event.detail);
        this.isLoading = event.detail;
    }
}