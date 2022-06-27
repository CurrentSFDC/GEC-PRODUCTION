import { LightningElement, api, track } from 'lwc';
import getPriceAgreementDetail from '@salesforce/apex/CommunityPriceAgreementController.getPriceAgreementDetail';
import modify from '@salesforce/apex/CommunityPriceAgreementController.modify';
import getCustListDetail from '@salesforce/apex/CommunityPriceAgreementController.getCustListDetail';
import getPDF from '@salesforce/apex/AgreementPDFController.getPDF';
import checkPAHeader from '@salesforce/apex/communityOpenClass.checkPAHeader';
import checkPAItem from '@salesforce/apex/communityOpenClass.checkPAItem';
import {downloadFromBase64String} from "c/downloader";
//import {fireErrorToast} from "c/toast";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//import getInventoryAvailabilityForComm from '@salesforce/apex/InventoryController.getInventoryAvailabilityForComm';

export default class CommunityPriceAgreementDetail extends LightningElement {
    @api recordId;
    @track agreementRecordId;
    @track base64PDF;
    @track agreementDetails = [];
    @track agreementItems = [];
    @track allowAgreementType = ["ZPRJ", "ZOTP"];
    @track isLoading = true;
    @track mutipleCustomers = false;
    @track allowModify = true;
    @track allowCTO = true;
    @track showLineItems = false;
    @track allowPdfDownload = true;
    @track allowCsvDownload = true;
    @track isCustomerAssigned = true;
    @track userType = localStorage.getItem("User Type");

    connectedCallback() {
        var currentUrl = new URL(window.location.href);
        var paths = currentUrl.pathname.split("/");
        
        var currentUrl = new URL(window.location);
        this.agreementRecordId = paths[3];

        if (currentUrl.host.includes("stage")) {
            this.agreementRecordId = paths[4];
        }

        this.getAgreementDetails();
    }

    renderedCallback() {
        console.log("Rendered Record Id: ", this.recordId);
    }

    async getAgreementDetails () {
        await getPriceAgreementDetail({agreementID: this.agreementRecordId})
        .then(result => {

            this.isLoading = false;

            if (result.length > 0) {
                console.log("Details Result: ", result[0]);
                this.agreementDetails = {...result[0]};

                if (this.agreementDetails.Customer_Name__c == "MULTIPLE") {
                    this.mutipleCustomers = true;
                }

                if (this.agreementDetails.Bill_To_Customer_No__c == undefined && this.agreementDetails.Customer_Name__c == undefined) {
                    this.isCustomerAssigned = false;
                }

                this.agreementDetails.AgentAddress = "";
                if (this.agreementDetails.Fixture_Agent__r !== undefined && this.agreementDetails.Fixture_Agent__r.ShippingAddress !== undefined) {
                    this.agreementDetails.AgentAddress = this.agreementDetails.Fixture_Agent__r.ShippingAddress.street + "\n" + this.agreementDetails.Fixture_Agent__r.ShippingAddress.city + " " + this.agreementDetails.Fixture_Agent__r.ShippingAddress.state + " " + this.agreementDetails.Fixture_Agent__r.ShippingAddress.postalCode + "\n" + this.agreementDetails.Fixture_Agent__r.ShippingAddress.country;
                }

                this.checkModifyAction();
                this.checkConvertToOrderAction();
                this.getAgreementItems();
                this.getAgreementPDF();
                this.checkPAHeader();
            }
        });
    }

    checkModifyAction() {
         if (this.userType == "Agent") {
            var todayDate = new Date();
            var expDate = new Date(this.Expiration_Date__c);
            expDate.setDate(expDate.getDate() + 30);

            if (todayDate > expDate || this.allowAgreementType.includes(this.agreementDetails.Agreement_Type__c) == false) {
                this.allowModify = false;
            }
         } else {
             this.allowModify = false;
         }
    }

    checkConvertToOrderAction() {
        var todayDate = new Date();
        var expireDate = new Date(this.agreementDetails.Expiration_Date__c);

        if ((this.agreementDetails.Expiration_Date__c == null || todayDate > expireDate) ||
            this.allowAgreementType.includes(this.agreementDetails.Agreement_Type__c) == false) {
                this.allowCTO = false;
        }
    }

    getAgreementItems() {
        if (this.agreementDetails.SAP_Price_Agreement_Items__r !== undefined) {
            this.showLineItems = true;
            var rowIndex = 1;
            for (const data of this.agreementDetails.SAP_Price_Agreement_Items__r) {
                let item = Object.assign({}, data);

                item.AgreementLineNo = (rowIndex * 10).toString().padStart(4, "0");
                item.RowLineTitle = item.AgreementLineNo;
                item.RowLineTitle += "  |  " + item.Material_No__c;
                item.RowLineTitle += "  :  " + item.Item_Description__c;
                item.RowLineTitle += "  |  " + "Quantity: " + item.Quantity__c;
                item.RowLineTitle += "  |  " + "Unit Price: " + Intl.NumberFormat('en-US', { style: 'currency', currency: this.agreementDetails.CurrencyIsoCode }).format(item.Sales_Price__c);
                item.ExtendedPrice = item.Sales_Price__c * item.Quantity__c;

                
                 
                var todayDate = new Date().toISOString().slice(0, 10);
                item.activeclass = "" ; 
                if (item.ValidFrom__c <= todayDate){
                    item.activeclass = "activeagreements";    
                }  

                this.agreementItems.push(item);
                rowIndex++;
            }
        }
    }

    get getAgreementFullName() {
        var agreementType = "";

        if (this.agreementDetails.Agreement_Type__c === 'ZTRM') {
            agreementType = 'Term';
        } else if (this.agreementDetails.Agreement_Type__c === 'ZPRJ') {
            agreementType = 'Project';
        } else if (this.agreementDetails.Agreement_Type__c === 'ZOTP') {
            agreementType = 'One Time';
        } else if(this.agreementDetails.Agreement_Type__c === "ZPRO"){
            agreementType = "Promo";
        } else if(this.agreementDetails.Agreement_Type__c === "ZCLB"){
            agreementType = "Claimback";
        }

        return agreementType;
    }

    async getAgreementPDF() {
        var response = await getPDF({agrNumber: this.agreementDetails.Agreement_No__c});

        if (response.message != null && response.message !== '') {
            this.allowPdfDownload = false;
        } else if (response.base64Data !== "") {
            this.base64PDF = response.base64Data;
        }
    }

    async checkPAHeader() {
        var csvResponse = await checkPAHeader({priceId: this.agreementDetails.Agreement_No__c});

        if(csvResponse == "Y") {
            this.allowCsvDownload = false;
        }
    }

    async handleActions(event) {
        var actionName =  event.detail.value;
        
        this.isLoading = true;
        console.log("Action Name: ", actionName);
        if (actionName == "modify" || actionName == "convert-to-order") {
            let url = await modify({priceAgreementNum: this.agreementDetails.Agreement_No__c, isRevise: actionName === 'modify'});
            console.log("Modify & CTO Url: ", url);
            this.isLoading = false;
            
            if (url !== null && url !== "") {
                if (localStorage.getItem('DistributorID')) {
                    url+='&effectiveAccount=' + localStorage.getItem('DistributorID');
                } else {
                    url+='&effectiveAccount=' + localStorage.getItem('AgentID');
                }

                window.location.href = url;
            }
        } else if (actionName == "download-pdf") {
            this.isLoading = false;
            downloadFromBase64String(this.base64PDF, 'Price-Agreement-' + this.agreementDetails.Agreement_No__c + '.pdf');
        } else if (actionName == "download-csv") {
            this.downloadAgreementCSV();
        }
    }

    downloadAgreementCSV() {
        this.isLoading = true;

        checkPAItem({priceId: this.agreementDetails.Agreement_No__c})
        .then(result => {
            console.log("CSV Data : ", result);
            let headerAgreementKeys = ["Name", "Sold_to_acc", "Opportunity_Name__c", "Agreement_Type__c", "Agreement_Subtotal__c", "Extended_Description__c", "Strategic_Partner_Name__c", "Valid_From__c", "Expiration_Date__c", "Agent_Name__c", "Agent_Number__c", "CurrencyIsoCode", "SAP_Price_Agreement_Items__r"];
            let lineAgreementKeys = ["Material_No__c", "Item_Description__c", "Quantity__c", "UOM__c", "ValidFrom__c", "ValidTo__c", "Sales_Price__c", "Extended_price", "Hierarchy_Level_1_Description__c"];
            let csvTitels = ["Price Agreement", "Sold to Account", "Opportunity ID/Project Name", "Type", "Total Net Value", "Job Name", "End User", "Effective Date", "Expiration Date", "Agent Name", "Rep Number/Rep Name", "Currency", "Product Code", "Product Description", "Product Qty", "Product UOM", "Valid From Date", "Valid To Date", "Sales Price", "Extended Price", "UPC Code"];

            let rowEnd = '\n';
            let csvString = '';
            let rowData = new Set();

            csvTitels.forEach(title => {
                rowData.add(title);
            });

            rowData = Array.from(rowData);
            csvString += rowData.join(',');
            csvString += rowEnd;

            result.forEach(function callback(data, index) {
                let j = 0;
                let headerItems = '';
                headerAgreementKeys.forEach(hData => {
                    if (hData !== "SAP_Price_Agreement_Items__r") {

                        if (j > 0) {
                            headerItems += ',';
                        }

                        let headerValue = '';
                        if (hData !== "Sold_to_acc") {
                            if (hData == "Agreement_Type__c") {
                                let typeValue = '';
                                if (data[hData] === 'ZTRM') {
                                    typeValue = 'Term';
                                } else if (data[hData] === 'ZPRJ') {
                                    typeValue = 'Project';
                                } else if (data[hData] === 'ZOPT') {
                                    typeValue = 'One Time';
                                } else if(data[hData] === 'ZCLB'){
                                    typeValue = 'Claimback';
                                }

                                headerValue = typeValue;
                            } else if (hData == 'Opportunity_Name__c' && data[hData] !== undefined) {
                                headerValue = data['Opportunity_Name__r']['Name'];
                            } else {
                                if (data[hData] !== undefined) {
                                    headerValue = data[hData];
                                }
                            }
                        } else {
                            headerValue = "";
                            if (data['Bill_To_Customer_No__c'] !== undefined && data['Customer_Name__c'] !== undefined) {
                                
                                if(data['Customer_Name__c'] == 'MULTIPLE'){
                                    headerValue =  data['Customer_Name__c'];
                                } else  {
                                    headerValue = data['Bill_To_Customer_No__c'] + " - " + data['Customer_Name__c'];
                                }
                            }
                        }

                        headerItems += '"' + headerValue + '"';
                        j++;
                    } else {
                        if(data.hasOwnProperty(hData)) {
                            headerItems += ",";
                            data[hData].forEach(function callBack(lineData, lineIndex) {
                                let i = 0;
                                let lineItems = '';
                                lineAgreementKeys.forEach(lData => {
                                    if (i > 0) {
                                        lineItems += ','
                                    }

                                    let lineValue = ''
                                    if (lData !== 'Extended_price') {
                                        if (lineData[lData] !== undefined) {
                                            lineValue = lineData[lData];
                                        }

                                    } else {
                                        lineValue = (lineData['Sales_Price__c'] * lineData['Quantity__c']);
                                    }
                                    
                                    lineItems += '"' + lineValue + '"';
                                    i++;
                                });
                            
                                csvString += headerItems + lineItems;
                                csvString += rowEnd;
                            });
                        } else {
                            csvString += headerItems;
                            csvString += rowEnd;
                        }
                    }
                });
            });
            // Creating anchor element to download
            let downloadElement = document.createElement('a');

            // This encodeURIComponent encodes special characters
            downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURIComponent(csvString);
            downloadElement.target = '_self';
            // Set CSV File Name
            downloadElement.download = 'Price-Agreement-' + this.agreementDetails.Agreement_No__c + '.csv';
            // below statement is required if you are using firefox browser
            document.body.appendChild(downloadElement);
            // click() Javascript function to download CSV file
            downloadElement.click(); 

            this.isLoading = false;
        })
        .catch(error => {
            this.isLoading = false;
            console.log("Error : ", error);
        });
    }

    async downloadCustomerList() {
        this.isLoading = true;
        var agentNumber = localStorage.getItem("AgentNumber");
        if (this.userType == "Distributor") {
            agentNumber = localStorage.getItem("ContactID");
        }

        var result = await getCustListDetail({agreementID: this.agreementDetails.Id, userType: this.userType, userDetail: agentNumber});

        if (result.length > 0) {
            var dataTitle = ["Name", "Segmentation", "Account", "Address"];
            var dataKey = ["Name", "Customer_Segmentation__c", "GE_LGT_EM_SAP_Customer_Number__c", "ShippingAddress"];

            let rowEnd = '\n';
            let csvString = '';
            let rowData = new Set();

            dataTitle.forEach(title => {
                rowData.add(title);
            });

            rowData = Array.from(rowData);
            csvString += rowData.join(',');
            csvString += rowEnd;

            result.forEach(data => {
                var i = 0;
                dataKey.forEach(key => {
                    if (i > 0) {
                        csvString += ",";
                    }

                    var value = "";
                    if (key == "ShippingAddress") {
                        if (data["ShippingAddress"] !== undefined) {
                            value = data["ShippingAddress"]["street"] + " " + data["ShippingAddress"]["city"] + " " + data["ShippingAddress"]["state"] + " " + data["ShippingAddress"]["postalCode"] + " " + data["ShippingAddress"]["country"];
                        }
                    } else {
                        value = data[key] !== undefined ? data[key] : "";
                    }

                    csvString += '"'+ value +'"';
                    i++;
                });

                csvString += rowEnd;
            });

            // Creating anchor element to download
            let downloadElement = document.createElement('a');

            // This encodeURIComponent encodes special characters
            downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURIComponent(csvString);
            downloadElement.target = '_self';
            
            // Set CSV File Name
            downloadElement.download = 'Customer-List-' + this.agreementDetails.Agreement_No__c + '.csv';
            document.body.appendChild(downloadElement);
            downloadElement.click(); 

            this.isLoading = false;
        } else {
            this.isLoading = false;
                const evt = new ShowToastEvent({
                    title: 'Warning',
                    message: 'This agreement is not available to any of your distributors. Please reach out to your pricing specialist for assistance.',
                    variant: 'error',
                    mode: 'sticky'
                });
                this.dispatchEvent(evt);
        }

    }

}