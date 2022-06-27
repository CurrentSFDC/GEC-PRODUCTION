import {LightningElement, api, wire, track} from 'lwc';
import getRelatedAccounts from '@salesforce/apex/communityOpenClass.getRelatedAccounts';
import getSoldToAccounts from '@salesforce/apex/communityOpenClass.getSoldToAccounts';
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import CONTACT_FIELD from '@salesforce/schema/User.ContactId';
import ACCOUNT_FIELD from '@salesforce/schema/User.AccountId';
import PROFILE_FIELD from '@salesforce/schema/User.ProfileId';
import UserType from '@salesforce/schema/User.User_Type__c';

export default class CommunityCustomerList extends LightningElement {
    @track currentStep = '1';
    @track searchable = [];
    @track accounts =[];
    @track soldToList = [];
    @track distributorAccounts = [];
    @track accountAgentNumber;
    @track contactID;
    @track UserType;
    @api accountID;
    @track profileID;
    @track message;
    @track error;
    @track showFooter = false;
    @track searchString = '';
    @track showScroll = false;
    @track selectedAgent = '';
    @track isAgent = true;
    @track allowDownload = false;
    @track isLoading = true;
    @track selectedRow;
    @track segmentationFullName = {FD: "Fixture", LB: "Lamp"};

    async connectedCallback() {
        window.addEventListener('scroll', 
        () => {
            if(document.documentElement.scrollTop > 200) {
                this.showScroll = true;
            } else {
                this.showScroll = false;
            }
        });   
    }

    // GET CURRENT LOGGED IN COMMUNITY USER INFORMATION
    @wire(getRecord, {
        recordId: USER_ID,
        fields: [CONTACT_FIELD, ACCOUNT_FIELD, UserType, PROFILE_FIELD]
        }) wireuser({
            error,
            data
        }) {
            if (error) {
            this.error = "NO DATA" ; 
            console.log('ERROR: '+this.error);
            } else if (data) {
                this.contactID = data.fields.ContactId.value;
                this.accountID = data.fields.AccountId.value;
                this.profileID = data.fields.ProfileId.value;
                this.UserType = data.fields.User_Type__c.value;
                if (this.UserType !== "Agent") {
                    this.isAgent = false;
                }
                this.getRelatedAccounts();
            }
    };

    getRelatedAccounts() {
        getRelatedAccounts({contactId: this.contactID, userType: this.UserType})
        .then(result => {
            this.accounts = [];
            this.isLoading = false;
            if (result.length > 0) {
                for (const account of result) {
                    const clone = Object.assign({}, account);
                    clone.Segment = this.segmentationFullName[clone.Customer_Segmentation__c] !== undefined ? this.segmentationFullName[clone.Customer_Segmentation__c] : "";
                    this.accounts.push(clone);
                }

                this.searchable = this.accounts;

                if (this.UserType !== "Agent") {
                    this.allowDownload = true;
                }
            }
        })
        .catch(error => {
            this.message = "No Data";
            console.log("getRelatedAccounts Error : ", error);
        });
    }

    getCustomers(event){
        this.isLoading = true;
        const row = this.searchable[event.target.value];
        this.accountAgentNumber = row.GE_LGT_EM_SAP_Customer_Number__c;
        this.selectedAgent = row.Name + ' - ' + this.accountAgentNumber + ' - ' + row.Customer_Segmentation__c;
        this.searchString = '';
        this.selectedRow = row;
        this.getSoldToAccounts();
        this.goToStepTwo();
        this.scrollTop();
    }

    async getSoldToAccounts() {
        await getSoldToAccounts({accountId: this.accountAgentNumber})
            .then(result => {
                this.soldToList = [];
                this.isLoading = false;
                if (result.length > 0) {
                    this.allowDownload = true;
                    for (const account of result) {
                        const clone = Object.assign({}, account);
                        clone.Segment = this.segmentationFullName[clone.Customer_Segmentation__c] !== undefined ? this.segmentationFullName[clone.Customer_Segmentation__c] : "";
                        this.soldToList.push(clone);
                    }
                }

                this.distributorAccounts = this.soldToList;
            })
            .catch(error => {
                console.log(error);
                this.error = error;
            });
    }

    goToStepTwo() {
        this.currentStep = '2';
        this.showFooter = true;
        this.template.querySelector('div.stepOne').classList.add('slds-hide');
        this.template.querySelector('div.stepTwo').classList.remove('slds-hide');
    }

    goBackToStepOne() {
        this.currentStep = '1';
        this.searchable = this.accounts;
        this.searchString = '';
        this.selectedAgent = '';
        this.template.querySelector('div.stepTwo').classList.add('slds-hide');
        this.template.querySelector('div.stepOne').classList.remove('slds-hide');
        this.showFooter = false;
        this.allowDownload = false;
    }

    searchDataTable(event) {
        this.searchString = event.target.value;
        var searchString = event.target.value.toUpperCase();
        var allRecords = [];
        var searchResults = [];

        if(this.currentStep == '1') {
            allRecords = this.accounts;

            for(var i = 0; i < allRecords.length; i++) {
                allRecords[i].Segment = this.segmentationFullName[allRecords[i].Customer_Segmentation__c] !== undefined ? this.segmentationFullName[allRecords[i].Customer_Segmentation__c] : "";
                if((allRecords[i].Name) && (allRecords[i].Name.toUpperCase().includes(searchString)) || 
                    (allRecords[i].Customer_Segmentation__c) && (allRecords[i].Customer_Segmentation__c.toUpperCase().includes(searchString)) || 
                    (allRecords[i].Segment) && (allRecords[i].Segment.toUpperCase().includes(searchString)) || 
                    (allRecords[i].GE_LGT_EM_SAP_Customer_Number__c) && (allRecords[i].GE_LGT_EM_SAP_Customer_Number__c.toUpperCase().includes(searchString)) ||
                    (allRecords[i].ShippingCity) && (allRecords[i].ShippingCity.toUpperCase().includes(searchString)) ||
                    (allRecords[i].ShippingState) && (allRecords[i].ShippingState.toUpperCase().includes(searchString)) || 
                    (allRecords[i].ShippingStreet) && (allRecords[i].ShippingStreet.toUpperCase().includes(searchString)) ||
                    (allRecords[i].ShippingPostalCode) && (allRecords[i].ShippingPostalCode.toUpperCase().includes(searchString)) ||
                    (allRecords[i].ShippingCountry) && (allRecords[i].ShippingCountry.toUpperCase().includes(searchString)) ){
                        searchResults.push(allRecords[i]);
                }
            }

            this.searchable = searchResults;
        } else if(this.currentStep == "2") {
            allRecords = this.soldToList;

            for(var i = 0; i < allRecords.length; i++) {
                allRecords[i].Segment = this.segmentationFullName[allRecords[i].Customer_Segmentation__c] !== undefined ? this.segmentationFullName[allRecords[i].Customer_Segmentation__c] : "";
                if((allRecords[i].Name) && (allRecords[i].Name.toUpperCase().includes(searchString)) || 
                    (allRecords[i].Customer_Segmentation__c) && (allRecords[i].Customer_Segmentation__c.toUpperCase().includes(searchString)) || 
                    (allRecords[i].Segment) && (allRecords[i].Segment.toUpperCase().includes(searchString)) || 
                    (allRecords[i].GE_LGT_EM_SAP_Customer_Number__c) && (allRecords[i].GE_LGT_EM_SAP_Customer_Number__c.toUpperCase().includes(searchString)) ||
                    (allRecords[i].ShippingCity) && (allRecords[i].ShippingCity.toUpperCase().includes(searchString)) ||
                    (allRecords[i].ShippingState) && (allRecords[i].ShippingState.toUpperCase().includes(searchString)) || 
                    (allRecords[i].ShippingStreet) && (allRecords[i].ShippingStreet.toUpperCase().includes(searchString)) ||
                    (allRecords[i].ShippingPostalCode) && (allRecords[i].ShippingPostalCode.toUpperCase().includes(searchString)) ||
                    (allRecords[i].ShippingCountry) && (allRecords[i].ShippingCountry.toUpperCase().includes(searchString)) ){
                        searchResults.push(allRecords[i]);
                }
            }

            this.distributorAccounts = searchResults;
        }
    }

    scrollPage() {
        console.log("scrollPage call");
    }

    scrollTop() {
        const scrollOptions = {
            left: 0,
            top: 0,
            behavior: 'smooth'
        }
        window.scrollTo(scrollOptions);
    }

    downloadCustomerList() {
        this.isLoading = true;
        var dataTitle = ["Agent Name", "Agent Segmentation", "Agent Account #", "Agent Address", "Customer Name", "Customer Segmentation", "Customer Account #", "Customer Address"];
        var dataCustTitle = ["Customer Name", "Customer Segmentation", "Customer Account #", "Customer Address"];
        var dataKey = ["Name", "Segment", "GE_LGT_EM_SAP_Customer_Number__c", "Customer_Address"];

        let rowEnd = '\n';
        let csvString = '';
        let rowData = new Set();

        if (this.UserType == "Agent") {
            var lisatData = this.soldToList;
            dataTitle.forEach(title => {
                rowData.add(title);
            });
        } else {
            var lisatData = this.accounts;
            dataCustTitle.forEach(title => {
                rowData.add(title);
            });
        }

        rowData = Array.from(rowData);
        csvString += rowData.join(',');
        csvString += rowEnd;

        lisatData.forEach(data => {

            if (this.UserType == "Agent") {
                var agentAddress = this.selectedRow.ShippingStreet + " " + this.selectedRow.ShippingCity + " " + this.selectedRow.ShippingState + " " + this.selectedRow.ShippingPostalCode + " " + this.selectedRow.ShippingCountry;
                csvString += '"'+ this.selectedRow.Name +'",' + '"'+ this.selectedRow.Segment +'",' + '"'+ this.selectedRow.GE_LGT_EM_SAP_Customer_Number__c +'",' + '"'+ agentAddress +'",';
            }

            var i = 0;
            dataKey.forEach(key => {

                if (i > 0) {
                    csvString += ",";
                }

                var value = "";
                if (key == "Customer_Address") {
                    value = data["ShippingStreet"] + " " + data["ShippingCity"] + " " + data["ShippingState"] + " " + data["ShippingPostalCode"] + " " + data["ShippingCountry"];
                } else {
                    value = data[key] !== undefined ? data[key] : "";
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
        if (this.UserType == "Agent") {
            downloadElement.download = 'Customer-List(' + this.selectedAgent + ').csv';
        } else {
            var currentDistributorName = localStorage.getItem("DistributorName") + " - " + localStorage.getItem("DistributorAccount") + " - " + localStorage.getItem("DistributorSegment");
            downloadElement.download = 'Customer-List(' + currentDistributorName + ').csv';
        }
        document.body.appendChild(downloadElement);
        downloadElement.click();
        this.isLoading = false;
    }
}