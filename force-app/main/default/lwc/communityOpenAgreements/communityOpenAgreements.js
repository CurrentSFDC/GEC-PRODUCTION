import {LightningElement, api, wire, track} from 'lwc';

import getPriceAgreements from '@salesforce/apex/communityOpenClass.getPriceAgreements';
//import getPriceAgreementByAccountSelector from '@salesforce/apex/CommunityPriceAgreementController.getPriceAgreementByAccountSelector';
//import getPriceAgreementsv2 from '@salesforce/apex/CommunityPriceAgreementController.getPriceAgreementsv2';
import getPriceAgreementsv2 from '@salesforce/apex/CommunityPriceAgreementController.getPriceAgreementsforWidget';


import {downloadFromBase64String} from "c/downloader";
//import getPermSetDtl from '@salesforce/apex/communityOpenClass.getPermSet';
import {
    subscribe,
    unsubscribe,
    APPLICATION_SCOPE,
    MessageContext
} from 'lightning/messageService';
import recordSelected from '@salesforce/messageChannel/selectedAccount__c';
import priceAgreement from '@salesforce/contentAssetUrl/geciconpriceagreementsWT';

import getPDF from '@salesforce/apex/AgreementPDFController.getPDF';
import checkPAHeader from '@salesforce/apex/communityOpenClass.checkPAHeader'
import checkPAItem from '@salesforce/apex/communityOpenClass.checkPAItem'
import {fireErrorToast} from "c/toast";
import USER_ID from '@salesforce/user/Id';
import getUserPerMissionSet from '@salesforce/apex/communityOpenClass.getUserPerMissionSet';
import getUserProfile from '@salesforce/apex/communityOpenClass.getUserProfile';

export default class CommunityOpenAgreements extends LightningElement {

    priceAgreement = priceAgreement;

    @track paItems = [];
    @track paItemsMessage;
    @track paItemsViewAll;
    @track usrProfile;
    @track selectedID;
    @track userType;
    @track distributorID;
    @track distributorName;
    @track distributorNumber;
    @track agentNumber;
    @track isAgreementsLoading = true;
    @track buttonLabel;
    @track fileDownloadNote;
    @track allowPdfDownload = true;
    @track showDownloadNote = false;
    @track showPricing = true;

    isLoading = false;
    hasRendered = false;
    base64PDF;
    isSpinner = false;
    allowCSVDownload = true;

    @track paColumns = [
        //     {
        //     label: 'Agreement #',
        //     //fieldName: 'recordLink',
        //     type: 'button',
        //     fieldName: 'Agreement_No__c',
        //     //type: 'button',
        //     typeAttributes: { label: { fieldName: "Agreement_No__c" }, tooltip:"Agreement #", target: "_blank", name: 'PriceAgreement' },
        //     cellAttributes: { alignment: 'right' }
        // }
            {
                label: 'Agreement #',
                fieldName: 'agreementLink',
                type: 'url',
                typeAttributes: {label: {fieldName: "Agreement_No__c"}, tooltip: "Price Agreement", target: "_self"},
                cellAttributes: {alignment: 'right'} 
            },
            /*{
                label: 'Agreement #',
                fieldName: 'Agreement_No__c',
                type: 'Text',
                //sortable: true,
                cellAttributes: {alignment: 'right'}
            },*/
            {

                label: 'Job Name',
            
                fieldName: 'Extended_Description__c',
            
                type: 'Text',
            
                // sortable: true,
            
                cellAttributes: { alignment: 'left' }
            
            },
            {

                label: 'Total',
    
                fieldName: 'Agreement_Subtotal__c',
    
                type: 'currency',
    
                //sortable: true,
    
                typeAttributes: { currencyCode: { fieldName: 'CurrencyIsoCode' } },
    
                cellAttributes: {alignment: 'right'}
    
            },
            /*{
                label: 'Valid From',
                fieldName: 'Valid_From__c',
                type: 'date',
                sortable: true,
                cellAttributes: { alignment: 'center' }
            },*/
            {
                label: 'Valid To',
                fieldName: 'Expiration_Date__c',
                type: 'date-local',
                //sortable: true,
                cellAttributes: {alignment: 'right'},
                
            }
        ];


    @wire(MessageContext)
    messageContext;

    // Encapsulate logic for Lightning message service subscribe and unsubsubscribe
    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                recordSelected,
                (message) => this.handleMessage(message),
                {scope: APPLICATION_SCOPE}
            );
        }
    }

    async handleMessage(message) {
        /*if (message.recordId == null) {
            return;
        }*/
        this.isAgreementsLoading = true;
        console.log('HANDLING MESSAGE IN OPEN PRICE AGREEMENTS WIDGET....');
        this.selectedID = message.recordId;
        this.userType = message.userType;
        this.distributorID = message.distributorID;
        this.distributorName = message.distributorName;
        this.distributorNumber = message.distributorNumber;
        this.agentNumber = message.agentNumber;
        console.log('Open Agreements - Agent Account ID passed from Component: '+this.selectedID);
        console.log('Open Agreements - Agent Account Number passed from Component: '+this.agentNumber);
        console.log('Open Agreements - Distributor Account ID passed from Component: '+this.distributorID); // ID OF THE DISTRIBUTOR
        console.log('Open Agreements - Distributor Account Name passed from Component: '+this.distributorName); // NAME OF THE DISTRIBUTOR
        console.log('Open Agreements - Distributor Account Number passed from Component: '+this.distributorNumber); // SAP CUSTOMER NUMBER OF THE DISTRIBUTOR
        console.log('UserType: ' + this.userType);

        /*await getPermSetDtl({})//to get contactId, profileId
        .then(result => {
          console.log("Inside the Permission Set Apex call");
          this.usrProfile = result;
          console.log('ProfileName****************' + this.usrProfile);
        }).catch(error => {
            console.log("The error SENT TO APEX is: " +JSON.stringify(error));
            this.error = error;        
        });

        if(this.usrProfile=='Default_Profile'){
        this.paItemsMessage = "No Data Found.";
        }
        else if (this.usrProfile=='View_PLP_and_PDP_Prices'){*/
          
            await getPriceAgreementsv2({accountId: this.selectedID, distributorId : this.distributorID, userType : this.userType, distributorNumber: this.distributorNumber, queryLimit: 50})
            .then(result => {
                if (result.length > 0) {
                    this.buttonLabel = "View All";
                    var tempPaList = [];
                    for (var i = 0; i < result.length; i++) {
                        let tempRecord = Object.assign({}, result[i]);
                        //tempRecord.recordLink = "/Agents/s/SAP_Price_Agreement__c" + "/" + tempRecord.Id + "/detail"; //STAGE
                        //tempRecord.recordLink = "/s/SAP_Price_Agreement__c" + "/" + tempRecord.Id + "/detail"; // PRODUCTION
                        
                        var currentUrl = new URL(window.location);
                        if (currentUrl.host.includes("stage")) {
                            var agreementDetailUrl = "/Agents/s/price-agreement" + "/" + tempRecord.Id + "/" + tempRecord.Agreement_No__c;
                        } else {
                            var agreementDetailUrl = "/s/price-agreement" + "/" + tempRecord.Id + "/" + tempRecord.Agreement_No__c;
                        }
                        tempRecord.agreementLink = agreementDetailUrl;
                        
                        if(result[i].Agreement_Type__c === "ZTRM"){
                            tempRecord.agreementTypeName = "Term";
                        }
                        else if(result[i].Agreement_Type__c === "ZPRO"){
                            tempRecord.agreementTypeName = "Promo";
                        }
                        else if(result[i].Agreement_Type__c === "ZPRJ"){
                            tempRecord.agreementTypeName = "Project";
                        } 
                        else if (result[i].Agreement_Type__c === 'ZOTP') {
                            tempRecord.agreementTypeName = 'One Time';
                        } 
                        else if (result[i].Agreement_Type__c === 'ZCLB') {
                            tempRecord.agreementTypeName = 'Claimback';
                            }
                        else {
                            tempRecord.agreementTypeName = '';
                        }
                        tempPaList.push(tempRecord);
                    }
                    this.isAgreementsLoading = false;
                    this.paItems = tempPaList;
                    console.log('Agreements Returned: '+JSON.stringify(this.paItems));
                    this.paItemsMessage = '';
        
                } else {
                    this.isAgreementsLoading = false;
                    this.paItemsMessage = 'No Open Price Agreements Found.';
                    this.buttonLabel = "View History";
                }
        
            }).catch(error => {
            console.error(error);
           this.isAgreementsLoading = false;
            this.paItemsMessage = "No Open Price Agreements Found.";
            this.buttonLabel = "View History";
        });

/*        await getPriceAgreements({accountId: this.selectedID, distributorId : this.distributorID, userType : this.userType, distributorNumber: this.distributorNumber})
                    .then(result => {
                        if (result.length > 0) {
                            this.buttonLabel = "View All";
                            var tempPaList = [];
                            for (var i = 0; i < result.length; i++) {
                                let tempRecord = Object.assign({}, result[i]);
                                tempRecord.recordLink = "/Agents/s/SAP_Price_Agreement__c" + "/" + tempRecord.Id + "/detail"; //STAGE
                                //tempRecord.recordLink = "/s/SAP_Price_Agreement__c" + "/" + tempRecord.Id + "/detail"; // PRODUCTION
                                if(result[i].Agreement_Type__c === "ZTRM"){
                                    tempRecord.agreementTypeName = "Term";
                                }
                                else if(result[i].Agreement_Type__c === "ZPRO"){
                                    tempRecord.agreementTypeName = "Promo";
                                }
                                else if(result[i].Agreement_Type__c === "ZPRJ"){
                                    tempRecord.agreementTypeName = "Project";
                                }
                                else if (result[i].Agreement_Type__c === 'ZOTP') {
                                    tempRecord.agreementTypeName = 'One Time';
                                }
                                else {
                                    tempRecord.agreementTypeName = '';
                                }
                                tempPaList.push(tempRecord);
                            }
                            this.isAgreementsLoading = false;
                            this.paItems = tempPaList;
                            console.log('Agreements Returned: '+JSON.stringify(this.paItems));
                            this.paItemsMessage = '';

                        } else {
                            this.isAgreementsLoading = false;
                            this.paItemsMessage = 'No Open Price Agreements Found.';
                            this.buttonLabel = "View History";
                        }

                    }).catch(error => {
                    console.error(error);
                    this.isAgreementsLoading = false;
                    this.paItemsMessage = "No Open Price Agreements Found.";
                    this.buttonLabel = "View History";
                });*/

    
}

    renderedCallback() {
        const style = document.createElement('style');
        style.innerText = `c-community-open-agreements .slds-card__header {
            background-color: #5f82b6;
            width: 100%;
            align: center;
            color: white;
            font-family: 'Segoe UI';
            padding: 10px;
        }`;
        //OLD STYLE - Montserrat
        this.template.querySelector('lightning-card').appendChild(style);

        const styleHeader = document.createElement('style');
        styleHeader.innerText = `c-community-open-agreements .slds-text-heading_small {
            width: 100%;
            margin: 0;
            font-family: 'Segoe UI';
            font-weight: bold;
            font-size: 18px;
            padding: 0;
        }`;
        this.template.querySelector('lightning-card').appendChild(styleHeader);
    }

    // Standard lifecycle hooks used to subscribe and unsubsubscribe to the message channel
    async connectedCallback() {
        console.log('OPEN AGREEMENTS - Subscribing to Message Channel...');
        // Get LoggedIn User Permission By Sameer Mahadik On(8-18-2021)
        this.getUserPermissions();

        this.userType = localStorage.getItem('User Type');
        this.selectedID = localStorage.getItem('AgentID');
        this.distributorID = localStorage.getItem('DistributorID');
        this.distributorName = localStorage.getItem('DistributorName')
        this.distributorNumber = localStorage.getItem('DistributorAccount');
        this.agentNumber = localStorage.getItem('AgentNumber');

        console.log('Open Price Agreements CC - Agent Account ID passed from Component: '+this.selectedID);
        console.log('Open Price Agreements CC - Agent Account Number passed from Component: '+this.agentNumber);
        console.log('Open Price Agreements CC - Distributor Account ID passed from Component: '+this.distributorID); // ID OF THE DISTRIBUTOR
        console.log('Open Price Agreements CC - Distributor Account Name passed from Component: '+this.distributorName); // NAME OF THE DISTRIBUTOR
        console.log('Open Price Agreements CC - Distributor Account Number passed from Component: '+this.distributorNumber); // SAP CUSTOMER NUMBER OF THE DISTRIBUTOR
        console.log('UserType: ' + this.userType);

        await getPriceAgreementsv2({accountId: this.selectedID, distributorId : this.distributorID, userType : this.userType, distributorNumber: this.distributorNumber, queryLimit: 50})
    .then(result => {
        if (result.length > 0) {
            this.buttonLabel = "View All";
            var tempPaList = [];
            for (var i = 0; i < result.length; i++) {
                let tempRecord = Object.assign({}, result[i]);
                //tempRecord.recordLink = "/Agents/s/SAP_Price_Agreement__c" + "/" + tempRecord.Id + "/detail"; //STAGE
                //tempRecord.recordLink = "/s/SAP_Price_Agreement__c" + "/" + tempRecord.Id + "/detail"; // PRODUCTION
                
                var currentUrl = new URL(window.location);
                if (currentUrl.host.includes("stage")) {
                    var agreementDetailUrl = "/Agents/s/price-agreement" + "/" + tempRecord.Id + "/" + tempRecord.Agreement_No__c;
                } else {
                    var agreementDetailUrl = "/s/price-agreement" + "/" + tempRecord.Id + "/" + tempRecord.Agreement_No__c;
                }
                tempRecord.agreementLink = agreementDetailUrl;
                
                if(result[i].Agreement_Type__c === "ZTRM"){
                    tempRecord.agreementTypeName = "Term";
                }
                else if(result[i].Agreement_Type__c === "ZPRO"){
                    tempRecord.agreementTypeName = "Promo";
                }
                else if(result[i].Agreement_Type__c === "ZPRJ"){
                    tempRecord.agreementTypeName = "Project";
                }
                else if (result[i].Agreement_Type__c === 'ZOTP') {
                    tempRecord.agreementTypeName = 'One Time';
                }
                else if (result[i].Agreement_Type__c === 'ZCLB') {
                    tempRecord.agreementTypeName = 'Claimback';
                    }
                else {
                    tempRecord.agreementTypeName = '';
                }
                tempPaList.push(tempRecord);
            }
            this.isAgreementsLoading = false;
            this.paItems = tempPaList;
            console.log('Agreements Returned: '+JSON.stringify(this.paItems));
            this.paItemsMessage = '';

        } else {
            this.isAgreementsLoading = false;
            this.paItemsMessage = 'No Open Price Agreements Found.';
            this.buttonLabel = "View History";
        }

    }).catch(error => {
    console.error(error);
    this.isAgreementsLoading = false;
    this.paItemsMessage = "No Open Price Agreements Found.";
    this.buttonLabel = "View History";
});

/*        await getPriceAgreements({accountId: this.selectedID, distributorId : this.distributorID, userType : this.userType, distributorNumber: this.distributorNumber})
            .then(result => {
                if (result.length > 0) {
                    this.buttonLabel = "View All";
                    var tempPaList = [];
                    for (var i = 0; i < result.length; i++) {
                        let tempRecord = Object.assign({}, result[i]);
                        tempRecord.recordLink = "/Agents/s/SAP_Price_Agreement__c" + "/" + tempRecord.Id + "/detail"; //STAGE
                        //tempRecord.recordLink = "/s/SAP_Price_Agreement__c" + "/" + tempRecord.Id + "/detail"; // PRODUCTION
                        if(result[i].Agreement_Type__c === "ZTRM"){
                            tempRecord.agreementTypeName = "Term";
                        }
                        else if(result[i].Agreement_Type__c === "ZPRO"){
                            tempRecord.agreementTypeName = "Promo";
                        }
                        else if(result[i].Agreement_Type__c === "ZPRJ"){
                            tempRecord.agreementTypeName = "Project";
                        }
                        tempPaList.push(tempRecord);
                    }
                    this.isAgreementsLoading = false;
                    this.paItems = tempPaList;
                    console.log('Agreements Returned: '+JSON.stringify(this.paItems));
                    this.paItemsMessage = '';

                } else {
                    this.isAgreementsLoading = false;
                    this.paItemsMessage = 'No Open Price Agreements Found.';
                    this.buttonLabel = "View History";
                }

            }).catch(error => {
            console.error(error);
            this.isAgreementsLoading = false;
            this.paItemsMessage = "No Open Price Agreements Found.";
            this.buttonLabel = "View History";
        });*/

        this.subscribeToMessageChannel();
        // Get User Assigned Permission By Sameer Mahadik On(8-18-2021)
        // if (localStorage.getItem("UserPermission") !== null) {
        //     var permissionData = JSON.parse(localStorage.getItem("UserPermission"));
        //     var permissionSets = permissionData['permissionSet'];
        //     var profileName = permissionData['profileName'];

        //     if ((profileName == "Agent Read Only B2B Storefront Registered Users" ||
        //          profileName == "Distributor Read Only B2B Storefront Registered Users") &&
        //          permissionSets.includes("View_PLP_and_PDP_Prices") == false) {
        //             this.showPricing = false;
        //     }
        // }
    }

    disconnectedCallback() {
        //this.unsubscribeToMessageChannel();
    }

    getUserPermissions() {
        var permissionSets = [];
        getUserPerMissionSet({UserId: USER_ID})
        .then(result => {
            permissionSets = result;
            getUserProfile({UserId: USER_ID})
            .then(result1 => {
                if ((result1 == "Agent Read Only B2B Storefront Registered Users" ||
                    result1 == "Distributor Read Only B2B Storefront Registered Users") &&
                    permissionSets.includes("View_PLP_and_PDP_Prices") == false) {
                    this.showPricing = false;
                }
            });
        });
    }

    viewAllpaItems(evt) {
        var baseURL = window.location.origin
        //this.sfdcOrgURL = baseURL + '/Agents/s/price-agreements'; //STAGE
        this.sfdcOrgURL = baseURL + '/s/price-agreements'; // PRODUCTION
        window.open(this.sfdcOrgURL, '_self');
    }

    async handleRowAction(event) {
        try {
            this.isLoading = true;
            const actionName = event.detail.action.name;
            const priceAgreement = event.detail.row;
            if (actionName === 'PriceAgreement') {
                this.allowCSVDownload = true;
                this.allowPdfDownload = true;
                this.showDownloadNote = false;
                this.fileDownloadNote = "";
                let response = await getPDF({agrNumber: priceAgreement.Agreement_No__c});
                let csvResponse = await checkPAHeader({priceId: priceAgreement.Agreement_No__c});
                this.selectedAgreementNo = priceAgreement.Agreement_No__c;
                console.log("csvResponse : ", csvResponse);
                if(csvResponse == "Y") {
                    this.allowCSVDownload = false;
                    this.showDownloadNote = true;
                    this.fileDownloadNote = "CSV download option is not available for expired agreements.";
                }
                // if (response.message != null && response.message !== '') {
                //     fireErrorToast(this, response.message);
                // } else 
                if ((response.base64Data != null && response.base64Data !== '') ||
                    (response.message != null && response.message !== '')) {
                    //this.template.querySelector('.slds-modal').classList.add('slds-fade-in-open');
                    this.template.querySelector('.pdfCsvViewModal').classList.add('slds-fade-in-open');
                    this.template.querySelector('.slds-backdrop').classList.add('slds-backdrop_open');
                    if (response.base64Data !== "") {
                        this.base64PDF = response.base64Data;
                    }  else if(response.message !== '' && this.allowCSVDownload == false) {
                        this.allowPdfDownload = false;
                        this.showDownloadNote = true;
                        this.fileDownloadNote = "PDF download option would be available once a customer is assigned to the agreement. CSV download option is not available for expired agreements.";
                    } else {
                        this.allowPdfDownload = false;
                        this.showDownloadNote = true;
                        //this.fileDownloadNote = "PDF download option would be available once a customer is assigned to the agreement.";
                        this.fileDownloadNote = "A PDF Document will be available after a customer is assigned.";

                    }
                    //this.pdfSrc = URL.createObjectURL(convertBase64StringToPDFBlob(response.base64Data));
                    //downloadPDFFromBase64String(response.base64Data, priceAgreement.Agreement_No__c + '.pdf');
                } else {
                    fireErrorToast(this, 'Something went wrong.');
                }
            }
        } catch (error) {
            console.error(error);
            fireErrorToast(this, 'Something went wrong.');
        } finally {
            this.isLoading = false;
        }
    }

    closeModal() {
        // this.template.querySelector('.slds-modal').classList.remove('slds-fade-in-open');
        this.template.querySelector('.pdfViewModal').classList.remove('slds-fade-in-open');
        this.template.querySelector('.pdfCsvViewModal').classList.remove('slds-fade-in-open');
        this.template.querySelector('.slds-backdrop').classList.remove('slds-backdrop_open');
        this.base64PDF = null;
    }

    // Download csv file By Sameer on (4/15/2021)
    downloadCSVFile() {
        let rowEnd = '\n';
        let csvString = '';
        let rowData = new Set();

        this.priceAgreementsToDisplay.forEach(function (record) {
            Object.keys(record).forEach(function (key) {
                rowData.add(key);
            });
        });

        rowData = Array.from(rowData);
        
        csvString += rowData.join(',');
        csvString += rowEnd;

        // Convert data values in CSV format
        for(let i=0; i < this.priceAgreementsToDisplay.length; i++){
            let colValue = 0;

            for(let key in rowData) {
                if(rowData.hasOwnProperty(key)) {
                    let rowKey = rowData[key];

                    // add , after every value except the first
                    if(colValue > 0){
                        csvString += ',';
                    }
                    // If the column is undefined, then set blank value
                    let value = this.priceAgreementsToDisplay[i][rowKey] === undefined ? '' : this.priceAgreementsToDisplay[i][rowKey];
                    csvString += '"'+ value +'"';
                    colValue++;
                }
            }
            csvString += rowEnd;
        }

        // Creating anchor element to download
        let downloadElement = document.createElement('a');

        // This  encodeURI encodes special characters
        downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csvString);
        downloadElement.target = '_self';
        
        // Set CSV File Name
        downloadElement.download = 'Price-Agreement-List.csv';
        // below statement is required if you are using firefox browser
        document.body.appendChild(downloadElement);
        // click() Javascript function to download CSV file
        downloadElement.click(); 
    }

    /*showPDF() {
        console.log("Show PDF Call");
        this.template.querySelector('.pdfCsvViewModal').classList.remove('slds-fade-in-open');
        this.template.querySelector('.pdfViewModal').classList.add('slds-fade-in-open');
    }*/

    showPDF() {
        // Download pdf By Sameer Mahadik On(8-25-2021)
        downloadFromBase64String(this.base64PDF, 'Price-Agreement-'+ this.selectedAgreementNo + '.pdf');
        // this.template.querySelector('.pdfCsvViewModal').classList.remove('slds-fade-in-open');
        // this.template.querySelector('.pdfViewModal').classList.add('slds-fade-in-open');
        }
        

    backToCSV() {
        this.template.querySelector('.pdfViewModal').classList.remove('slds-fade-in-open');
        this.template.querySelector('.pdfCsvViewModal').classList.add('slds-fade-in-open');
    }

    downloadAgreementCSV() {
        this.isSpinner = true;

        checkPAItem({priceId: this.selectedAgreementNo})
        .then(result => {
            console.log("CSV Data : ", result);
            let headerAgreementKeys = ["Name", "Sold_to_acc", "Opportunity_Name__c", "Agreement_Type__c", "Agreement_Subtotal__c", "Extended_Description__c", "Strategic_Partner_Name__c", "Valid_From__c", "Expiration_Date__c", "Agent_Name__c", "Agent_Number__c", "SAP_Price_Agreement_Items__r"];
            let lineAgreementKeys = ["Material_No__c", "Item_Description__c", "Quantity__c", "UOM__c", "ValidFrom__c", "ValidTo__c", "Sales_Price__c", "Extended_price"];
            let csvTitels = ["Price Agreement", "Sold to Account", "Opportunity ID/Project Name", "Type", "Total Net Value", "Job Name", "End User", "Effective Date", "Expiration Date", "Agent Name", "Rep Number/Rep Name", "Product Code", "Product Description", "Product Qty", "Product UOM", "Valid From Date", "Valid To Date", "Sales Price", "Extended Price"];

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
                let currencyIsoCode = '';
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
                                } else if (data[hData] === 'ZCLB') {
                                    typeValue = 'Claimback';
                                    }

                                headerValue = typeValue;
                            } else if (hData == 'Opportunity_Name__c' && data[hData] !== undefined) {
                                headerValue = data['Opportunity_Name__r']['Name'];
                            } else {
                                if (data['CurrencyIsoCode'] != undefined && data['CurrencyIsoCode'] !== '') {
                                    currencyIsoCode = data['CurrencyIsoCode']+' ';
                                }
                                
                                if (data[hData] !== undefined) {
                                    headerValue = hData == 'Agreement_Subtotal__c' ? currencyIsoCode + data[hData] : data[hData];
                                }
                            }
                        } else {
                            // let customerLists = data['Customer_List__c'].split(",");
                            // let soldToCustomerListNo = '';
                            // if(customerLists.length > 1) {
                            //     customerLists.forEach(custListNo => {
                            //         if(custListNo == data['Bill_To_Customer_No__c']) {
                            //             soldToCustomerListNo = custListNo;
                            //         }
                            //     });
                            // } else {
                            //     soldToCustomerListNo = customerLists[0];
                            // }
                            headerValue = "";
                            if (data['Bill_To_Customer_No__c'] !== undefined && data['Customer_Name__c'] !== undefined) {
                                headerValue = data['Bill_To_Customer_No__c'] + " - " + data['Customer_Name__c'];
                            }
                            // headerValue = soldToCustomerListNo + " - " + data['Customer_Name__c'];
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
                                        if (lData !== undefined) {
                                            lineValue = lData == 'Sales_Price__c' ? currencyIsoCode + lineData[lData] : lineData[lData];
                                        }
                                    } else {
                                        lineValue = currencyIsoCode + (lineData['Sales_Price__c'] * lineData['Quantity__c']);
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

            // This  encodeURI encodes special characters
            downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csvString);
            downloadElement.target = '_self';
            
            // Set CSV File Name
            downloadElement.download = 'Price-Agreement-' +this.selectedAgreementNo+ '.csv';
            // below statement is required if you are using firefox browser
            document.body.appendChild(downloadElement);
            // click() Javascript function to download CSV file
            downloadElement.click(); 

            this.isSpinner = false;
        })
        .catch(error => {
            this.isSpinner = false;
            console.log("Error : ", error);
        });
    }

}