import {api, LightningElement, wire, track} from 'lwc';
import getPriceAgreements from '@salesforce/apex/CommunityPriceAgreementController.getPriceAgreements';
import getPriceAgreementsv2 from '@salesforce/apex/CommunityPriceAgreementController.getPriceAgreementsv2';
//import getPriceAgreementByAccountSelector from '@salesforce/apex/CommunityPriceAgreementController.getPriceAgreementByAccountSelector';
import modify from '@salesforce/apex/CommunityPriceAgreementController.modify';
import getPDF from '@salesforce/apex/AgreementPDFController.getPDF';
import checkPAHeader from '@salesforce/apex/communityOpenClass.checkPAHeader';
import checkPAItem from '@salesforce/apex/communityOpenClass.checkPAItem';
import {fireErrorToast} from "c/toast";
import {
    subscribe,
    unsubscribe,
    APPLICATION_SCOPE,
    MessageContext
} from 'lightning/messageService';
import recordSelected from '@salesforce/messageChannel/selectedAccount__c';
import {downloadFromBase64String} from "c/downloader";

export default class CommunityPriceAgreements extends LightningElement {

    priceAgreementsToDisplay = [];
    priceAgreementsInSearchResult = [];
    allPriceAgreements = [];
    searchText = '';
    offset = 50;
    isLoading = false;
    hasRendered = false;
    base64PDF;
    isSpinner = false;
    allowCSVDownload = true;
    selectedAgreementNo = '';

    columns=[];

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
    @track buttonLabel;
    @track fileDownloadNote;
    @track allowPdfDownload = true;
    @track showDownloadNote = false;

    @wire(MessageContext)
    messageContext;

    // Encapsulate logic for Lightning message service subscribe and unsubsubscribe
    subscribeToMessageChannel() {
        console.log('subbed before');
        if (!this.subscription) {
            console.log('subbed');
            this.subscription = subscribe(
                this.messageContext,
                recordSelected,
                (message) => this.handleMessage(message),
                {scope: APPLICATION_SCOPE}
            );
        }
    }

    async handleMessage(message) {

            this.isLoading = true;
            console.log('TDBG HANDLING MESSAGE IN OPEN PRICE AGREEMENTS WIDGET....');
            console.log('message.recordId: ',message.recordId);
            console.log('message.recordId == undefined: ',message.recordId === undefined);
            console.log('message.recordId == undefined: ',typeof message.recordId);
            this.clearSearchFields();
            if (message.recordId!= 'undefined' && message.recordId) this.selectedID = message.recordId;
            else this.selectedID = localStorage.getItem('AccountID');

            console.log('this.selectedID ',this.selectedID);
            this.userType = message.userType;
            this.distributorID = message.distributorID;
            this.distributorName = message.distributorName;
            this.distributorNumber = message.distributorNumber;
            this.agentNumber = message.agentNumber;
            console.log('localStorage AgentID',localStorage.getItem('AgentID'));
            console.log('localStorage AccountID',localStorage.getItem('AccountID'));
            console.log('All Open Agreements - Agent Account ID passed from Component: '+this.selectedID);
            console.log('All Open Agreements - Agent Account Number passed from Component: '+this.agentNumber);
            console.log('All Open Agreements - Distributor Account ID passed from Component: '+this.distributorID); // ID OF THE DISTRIBUTOR
            console.log('All Open Agreements - Distributor Account Name passed from Component: '+this.distributorName); // NAME OF THE DISTRIBUTOR
            console.log('All Open Agreements - Distributor Account Number passed from Component: '+this.distributorNumber); // SAP CUSTOMER NUMBER OF THE DISTRIBUTOR
            console.log('UserType: ' + this.userType);

/*            await getPriceAgreementsv2({accountId: this.selectedID, distributorId : this.distributorID, userType : this.userType, distributorNumber: this.distributorNumber})
                .then(result => {
                    this.priceAgreementsToDisplay = [];
                    console.log('distributor ',this.distributorNumber);
                    if (result.length > 0) {
                        var tempPaList = [];
                        for (const priceAgreement of result) {
                            let clone = Object.assign({}, priceAgreement);
                            Object.setPrototypeOf(clone, this.priceAgreementProto);
                            tempPaList.push(clone);
                        }
                        // for (var i = 0; i < result.length; i++) {
                        //     let tempRecord = Object.assign({}, result[i]);
                        //     tempRecord.recordLink = "/Agents/s/SAP_Price_Agreement__c" + "/" + tempRecord.Id + "/detail"; //STAGE
                        //     //tempRecord.recordLink = "/s/SAP_Price_Agreement__c" + "/" + tempRecord.Id + "/detail"; // PRODUCTION
                        //     if(result[i].Agreement_Type__c === "ZTRM"){
                        //         tempRecord.agreementTypeName = "Term";
                        //     }
                        //     else if(result[i].Agreement_Type__c === "ZPRO"){
                        //         tempRecord.agreementTypeName = "Promo";
                        //     }
                        //     else if(result[i].Agreement_Type__c === "ZPRJ"){
                        //         tempRecord.agreementTypeName = "Project";
                        //     }
                        //     tempPaList.push(tempRecord);
                        // }

                        this.isLoading = false;
                        this.paItems = tempPaList;
                        this.priceAgreementsToDisplay = tempPaList;
                        //this.priceAgreementProto;
                        console.log('Agreements Returned: '+JSON.stringify(this.paItems));
                        console.log('Agreements displayed: '+JSON.stringify(this.priceAgreementsToDisplay));
                        console.log('Agreements searched: '+JSON.stringify(this.priceAgreementsInSearchResult));
                        this.paItemsMessage = '';

                    } else {

                        this.isLoading = false;
                        this.paItemsMessage = 'No Open Price Agreements Found.';
                        this.buttonLabel = "View History";
                    }

                }).catch(error => {
                console.error(error);

                this.isLoading = false;
                this.paItemsMessage = "No Open Price Agreements Found.";
                this.buttonLabel = "View History";
            });*/

            await getPriceAgreementsv2({accountId: this.selectedID, distributorId : this.distributorID, userType : this.userType, distributorNumber: this.distributorNumber, queryLimit: 50000})
                            .then(result => {
                                this.priceAgreementsToDisplay = [];
                                console.log('distributor ',this.distributorNumber);
                                if (result.length > 0) {
                                    var tempPaList = [];
                                    for (const priceAgreement of result) {
                                        let clone = Object.assign({}, priceAgreement);
                                        Object.setPrototypeOf(clone, this.priceAgreementProto);
                                        tempPaList.push(clone);
                                    }
                                    this.isLoading = false;
                                    this.paItems = tempPaList;
                                    this.priceAgreementsToDisplay = tempPaList;
                                    this.allPriceAgreements = tempPaList;
                                    //this.priceAgreementProto;
                                    console.log('Agreements Returned: '+JSON.stringify(this.paItems));
                                    console.log('Agreements displayed: '+JSON.stringify(this.priceAgreementsToDisplay));
                                    console.log('Agreements searched: '+JSON.stringify(this.priceAgreementsInSearchResult));
                                    this.paItemsMessage = '';

                                } else {
                                    this.priceAgreementsToDisplay = [];
                                    this.allPriceAgreements = [];
                                    this.priceAgreementsInSearchResult = [];
                                    this.isLoading = false;
                                    this.paItemsMessage = 'No Open Price Agreements Found.';
                                    this.buttonLabel = "View History";
                                }

                            }).catch(error => {
                            console.error(error);

                            this.isLoading = false;
                            this.paItemsMessage = "No Open Price Agreements Found.";
                            this.buttonLabel = "View History";
                        });



    }

    @wire(getPriceAgreementsv2, {accountId: localStorage.getItem('AgentID'), distributorId : localStorage.getItem('DistributorID'), userType : localStorage.getItem('User Type'), distributorNumber: localStorage.getItem('DistributorAccount'), queryLimit: 50})
    handleFirst50LoadedRecords({data, error}) {
        console.log(localStorage.getItem('AgentID'));
        console.log(localStorage.getItem('DistributorID'));
        console.log(localStorage.getItem('User Type'));
        console.log(localStorage.getItem('DistributorAccount'));
        console.log('First50 ',data);
        console.log('First50Error ',error);
        if (data) {
            this.priceAgreementsToDisplay = [];
            for (const priceAgreement of data) {
                let clone = Object.assign({}, priceAgreement);
                Object.setPrototypeOf(clone, this.priceAgreementProto);
                this.priceAgreementsToDisplay.push(clone);
            }
        }
        if (error) {
            console.error(error);
        }

    }

    @wire(getPriceAgreementsv2, {accountId: localStorage.getItem('AgentID'), distributorId : localStorage.getItem('DistributorID'), userType : localStorage.getItem('User Type'), distributorNumber: localStorage.getItem('DistributorAccount'), queryLimit: 50000})
    handleAllLoadedRecords({data, error}) {

        this.isLoading = true;
        console.log('isLoading on');

        if (data) {
            console.log('DATA loaded ',data);
            this.allPriceAgreements = [];
            for (const priceAgreement of data) {
                let clone = Object.assign({}, priceAgreement);
                Object.setPrototypeOf(clone, this.priceAgreementProto);
                this.allPriceAgreements.push(clone);
            }
            this.priceAgreementsInSearchResult = this.allPriceAgreements;
            this.isLoading = false;
        }
        if (error) {
            console.error(error);
            this.isLoading = false;
        }
        this.isLoading = false;

    }

    setColumnValues(){
        console.log("Inside setColumnValues");
        console.log("User Type: "+this.userType);
        if (this.userType=="Agent") {
            this.columns = [
                // {
                //     label: 'Agreement No.', fieldName: 'Agreement_No__c', type: 'button', wrapText: true, hideDefaultActions: true,
                //     typeAttributes: {label: {fieldName: 'Agreement_No__c'}, target: '_blank', name: 'PriceAgreement'},
                //     cellAttributes: {alignment: 'right'}
                // }
                {
                    label: 'Agreement No.',
                    fieldName: 'agreementLink',
                    type: 'url',
                    typeAttributes: {label: {fieldName: "Agreement_No__c"}, tooltip: "Price Agreement", target: "_self"},
                    cellAttributes: {alignment: 'right'}
                },
                {label: 'Job Name', fieldName: 'Extended_Description__c', type: 'text', wrapText: true},
                {label: 'Agreement Type', fieldName: 'agreementTypeName', type: 'text', wrapText: true},
                {label: 'Customer Name', fieldName: 'Customer_Name__c', type: 'text', wrapText: true},
                {label: 'Description', fieldName: 'Description__c', type: 'text', wrapText: true},
                {
                    label: 'Valid To', fieldName: 'Expiration_Date__c', type: 'date-local',
                    typeAttributes: {
                        month: "2-digit",
                        day: "2-digit",
                        year: "numeric",
                    },
                    wrapText: true,
                    initialWidth: 95,
                    cellAttributes: {alignment: 'right'}
                },
                {
                    label: 'Total',
                    fieldName: 'Agreement_Subtotal__c',
                    type: 'currency',
                    //sortable: true,
                    initialWidth: 95,
                    typeAttributes: { currencyCode: { fieldName: 'CurrencyIsoCode' } },
                    cellAttributes: {alignment: 'right'}
                },
               // {label: 'Currency', fieldName: 'CurrencyIsoCode', type: 'text', wrapText: true, initialWidth: 95},
                {
                    label: 'Modify',
                    type: 'button',
                    typeAttributes: {label: 'Modify', name: 'modify', title: 'modify'},
                    cellAttributes: {
                        alignment: 'center',
                        class: {
                            fieldName: 'modifyButtonClass'
                        }
                    },
                    wrapText: true
                },
                {
                    label: 'Convert to Order',
                    type: 'button',
                    typeAttributes: {label: 'Convert to Order', name: 'convert-to-order'},
                    cellAttributes: {
                        alignment: 'center',
                        class: {
                            fieldName: 'convertToOrderButtonClass'
                        },
                    },
                    wrapText: true
                }
            ];
        } else {
            this.columns = [
                {
                    label: 'Agreement No.',
                    fieldName: 'agreementLink',
                    type: 'url',
                    typeAttributes: {label: {fieldName: "Agreement_No__c"}, tooltip: "Price Agreement", target: "_self"},
                    cellAttributes: {alignment: 'right'}
                },
                {label: 'Job Name', fieldName: 'Extended_Description__c', type: 'text', wrapText: true},
                {label: 'Agreement Type', fieldName: 'agreementTypeName', type: 'text', wrapText: true},
                {label: 'Customer Name', fieldName: 'Customer_Name__c', type: 'text', wrapText: true},
                {label: 'Description', fieldName: 'Description__c', type: 'text', wrapText: true},
                {
                    label: 'Valid To', fieldName: 'Expiration_Date__c', type: 'date-local',
                    typeAttributes: {
                        month: "2-digit",
                        day: "2-digit",
                        year: "numeric",
                    },
                    wrapText: true,
                    initialWidth: 95,
                    cellAttributes: {alignment: 'right'}
                },
                {
                    label: 'Total',
                    fieldName: 'Agreement_Subtotal__c',
                    type: 'currency',
                    //sortable: true,
                    initialWidth: 95,
                    typeAttributes: { currencyCode: { fieldName: 'CurrencyIsoCode' } },
                    cellAttributes: {alignment: 'right'}
                },
               // {label: 'Currency', fieldName: 'CurrencyIsoCode', type: 'text', wrapText: true, initialWidth: 95},
                {
                    label: 'Convert to Order',
                    type: 'button',
                    typeAttributes: {label: 'Convert to Order', name: 'convert-to-order'},
                    cellAttributes: {
                        alignment: 'center',
                        class: {
                            fieldName: 'convertToOrderButtonClass'
                        },
                    },
                    wrapText: true
                }
            ];
        }
    }


    priceAgreementProto = {
        get agreementTypeName() {
            if (this.Agreement_Type__c === 'ZTRM') {
                return 'Term';
            } else if (this.Agreement_Type__c === 'ZPRJ') {
                return 'Project';
            } else if (this.Agreement_Type__c === 'ZOTP') {
                return 'One Time';
            } else if(this.Agreement_Type__c === "ZPRO"){
                return "Promo";
            } else if(this.Agreement_Type__c === "ZCLB"){
                return "Claimback";
                }
            return '';
        },
        get hasExpried() {
            var today = new Date();

            /*if (this.Expiration_Date__c !== null) {
                this.Expiration_Date__c = this.Expiration_Date__c + " 23:59:59";
            }*/

            var expireDate = new Date(this.Expiration_Date__c);

            //return this.Expiration_Date__c == null || new Date(this.Expiration_Date__c) < new Date();
            return this.Expiration_Date__c == null || today > expireDate;
        },
        get allowAgreementType() {
            return ["ZPRJ", "ZOTP"];
        },
        get convertToOrderButtonClass() {
            // return this.hasExpried === true || (this.Agreement_Type__c !== 'ZPRJ' && this.Agreement_Type__c !== 'ZOPT') ? "slds-hidden " : "";
            return (this.hasExpried === true || this.allowAgreementType.includes(this.Agreement_Type__c) == false) ? "commAgrHideCell" : "";
        },
        get modifyButtonClass() {
            var todayDate = new Date();

            /*if (this.Expiration_Date__c !== null) {
                this.Expiration_Date__c = this.Expiration_Date__c + " 23:59:59";
            }*/

            var expDate = new Date(this.Expiration_Date__c);
            expDate.setDate(expDate.getDate() + 30);

            return (todayDate > expDate || this.allowAgreementType.includes(this.Agreement_Type__c) == false) ? "commAgrHideCell" : "";
        },

        get agreementLink() {
            var currentUrl = new URL(window.location);
            if (currentUrl.host.includes("stage")) {
                var agreementDetailUrl = "/Agents/s/price-agreement" + "/" + this.Id + "/" + this.Agreement_No__c;
            } else {
                var agreementDetailUrl = "/s/price-agreement" + "/" + this.Id + "/" + this.Agreement_No__c;
            }

            return agreementDetailUrl;
        }
    }

    async connectedCallback() {
        console.log('OPEN AGREEMENTS - Subscribing to Message Channel...');

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

        this.subscribeToMessageChannel();

        this.setColumnValues();
    }

    renderedCallback() {
        if (this.hasRendered === false) {
            this.modal = this.template.querySelector('.slds-modal')
            this.backdrop = this.template.querySelector('.slds-backdrop')
            window.addEventListener('keyup', event => {
                if (event.key === 'Escape') {
                    this.closeModal();
                }
            });
            this.hasRendered = true;
        }
    }

    async handleRowAction(event) {
        try {
            this.isLoading = true;
            const actionName = event.detail.action.name;
            const priceAgreement = event.detail.row;
            if (priceAgreement.hasExpried === true && actionName === 'convert-to-order') {
                return;
            }
            if (actionName === 'modify' || actionName === 'convert-to-order') {
                let url = await modify({priceAgreementNum: priceAgreement.Agreement_No__c, isRevise: actionName === 'modify'});
                console.log('url ',url);
                if (localStorage.getItem('DistributorID')) {
                    url+='&effectiveAccount=' + localStorage.getItem('DistributorID');
                } else {
                    url+='&effectiveAccount=' + localStorage.getItem('AgentID');
                }

                if (url) {
                    console.log('url ',url);
                    window.location.href = url;
                }
            } else if (actionName === 'PriceAgreement') {
                this.allowCSVDownload = true;
                this.allowPdfDownload = true;
                this.showDownloadNote = false;
                this.fileDownloadNote = "";
                let response = await getPDF({agrNumber: priceAgreement.Agreement_No__c});
                let csvResponse = await checkPAHeader({priceId: priceAgreement.Agreement_No__c});
                this.selectedAgreementNo = priceAgreement.Agreement_No__c;
                console.log('Selected Price Agreement: '+this.selectedAgreementNo);
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
                    } else if(response.message !== '' && this.allowCSVDownload == false) {
                        this.allowPdfDownload = false;
                        this.showDownloadNote = true;
                        this.fileDownloadNote = "A PDF Document will be available after a customer is assigned. CSV download option is not available for expired agreements.";
                    } else {
                        this.allowPdfDownload = false;
                        this.showDownloadNote = true;
                       // this.fileDownloadNote = "PDF download option would be available once a customer is assigned to the agreement.";
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

    handleInputKeyUp(event) {
        if (event.key === 'Enter') {
            // this.searchText = event.target.value;
            // this.searchForPriceAgreements();
            this.handleAgreementSearch();
        }
    }

    handleAgreementSearch() {
        try {
            let inputs = this.template.querySelectorAll('.search-inputs lightning-input');
            let areInputsValid = true;
            for (const input of inputs) {
                areInputsValid = areInputsValid && input.reportValidity();
                if (input.name === 'Search') {

                    this.searchText = input.value !== "" ? input.value.trim() : '';

                }
            }
            if (areInputsValid === false) {
                return;
            }

            this.searchForPriceAgreements();
        } catch (error) {
            console.error(error);
        }
    }

    clearSearch() {
        let inputs = this.template.querySelectorAll('.search-inputs lightning-input');

        for (const input of inputs) {
            input.value = null;
        }

        this.searchText = '';
        this.searchForPriceAgreements();
    }

    async searchForPriceAgreements() {
        try {
            console.log('search');
            if ((this.searchText === '' || this.searchText == null || this.searchText == undefined) &&
                (this.fromDate === '' || this.fromDate == null || this.fromDate == undefined) &&
                (this.toDate === '' || this.toDate == null || this.toDate == undefined)) {
                this.priceAgreementsInSearchResult = this.allPriceAgreements;
                // Remove this.offset value to remove limit from price agreement array By Sameer Mahadik On (12-07-2021)
                this.priceAgreementsToDisplay = this.priceAgreementsInSearchResult.slice(0);
            } else {
                this.isLoading = true;
                this.priceAgreementsInSearchResult = [];
                let searchText = this.searchText.toLowerCase();
                let p = new Promise(resolve => {
                    window.setTimeout(() => {
                        let result = [];
                        for (const priceAgreement of this.allPriceAgreements) {
                            var validDateStart = new Date(priceAgreement.Expiration_Date__c + " 00:00:01").getTime();
                            var validDateEnd = new Date(priceAgreement.Expiration_Date__c + " 23:59:59").getTime();

                            var agreementType = "";

                            if (priceAgreement.Agreement_Type__c === 'ZTRM') {
                                agreementType = 'Term';
                            } else if (priceAgreement.Agreement_Type__c === 'ZPRJ') {
                                agreementType = 'Project';
                            } else if (priceAgreement.Agreement_Type__c === 'ZOTP') {
                                agreementType = 'One Time';
                            } else if(priceAgreement.Agreement_Type__c === "ZPRO"){
                                agreementType = "Promo";
                            } else if(priceAgreement.Agreement_Type__c === "ZCLB"){
                                agreementType = "Claimback";
                            }

                            priceAgreement.Agreement_Type__c_Custom = agreementType;

                            if (priceAgreement.Description__c?.toLowerCase().includes(searchText) ||
                                priceAgreement.Extended_Description__c?.toLowerCase().includes(searchText) ||
                                priceAgreement.Agreement_No__c?.toLowerCase().includes(searchText) ||
                                priceAgreement.Agreement_Type__c?.toLowerCase().includes(searchText) ||
                                priceAgreement.Customer_Name__c?.toLowerCase().includes(searchText) ||
                                priceAgreement.CurrencyIsoCode?.toLowerCase().includes(searchText) ||
                                priceAgreement.Agreement_Type__c_Custom?.toLowerCase().includes(searchText)) {
                                    // priceAgreement.Expiration_Date__c = priceAgreement.Expiration_Date__c.split(" ")[0];
                                    result.push(priceAgreement);
                                    console.log('price agreement', priceAgreement);
                                    console.log('price agreement date', priceAgreement.Expiration_Date__c);
                            }
                        }
                        console.log(result);
                        resolve(result);
                    });
                });
                this.priceAgreementsInSearchResult = await p;
                // Remove this.offset value to remove limit from price agreement array By Sameer Mahadik On (12-07-2021)
                this.priceAgreementsToDisplay = this.priceAgreementsInSearchResult.slice(0);
            }
        } catch (error) {
            console.error(error);
        } finally {
            this.isLoading = false;
        }
    }


    loadMorePriceAgreements(event) {
        /*
        console.log('Load more');
        let target = event.target;
        try {
            if (this.isLoading === true || this.priceAgreementsToDisplay.length === this.priceAgreementsInSearchResult.length) {
                return;
            }
            this.isLoading = true;
            target.isLoading = true;
            window.setTimeout(() => {
                try {
                    this.priceAgreementsToDisplay = this.priceAgreementsToDisplay.concat(this.priceAgreementsInSearchResult.slice(this.priceAgreementsToDisplay.length, this.priceAgreementsToDisplay.length + this.offset));
                } catch (error) {
                    console.error(error);
                } finally {
                    this.isLoading = false;
                    target.isLoading = false;
                }
            })
        } catch (error) {
            console.error(error);
        }
        */
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

        // This encodeURIComponent encodes special characters
        downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURIComponent(csvString);
        downloadElement.target = '_self';

        // Set CSV File Name
        downloadElement.download = 'Price-Agreement-List.csv';
        // below statement is required if you are using firefox browser
        document.body.appendChild(downloadElement);
        // click() Javascript function to download CSV file
        downloadElement.click();
    }

    showPDF() {
        console.log("Show PDF Call");
        downloadFromBase64String(this.base64PDF, 'Price-Agreement-'+ this.selectedAgreementNo + '.pdf');
        // this.template.querySelector('.pdfCsvViewModal').classList.remove('slds-fade-in-open');
        // this.template.querySelector('.pdfViewModal').classList.add('slds-fade-in-open');
    }

    backToCSV() {
        this.template.querySelector('.pdfViewModal').classList.remove('slds-fade-in-open');
        this.template.querySelector('.pdfCsvViewModal').classList.add('slds-fade-in-open');
    }

    getAgreementTypeName() {
        console.log("Inside getAgreementTypeName");
        // if (type === 'ZTRM') {
        //     return 'Term';
        // } else if (type === 'ZPRJ') {
        //     return 'Project';
        // } else if (type === 'ZOPT') {
        //     return 'One Time';
        // }
        // return '';
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

    clearSearchFields() {

        let inputs = this.template.querySelectorAll('.search-inputs lightning-input');



        for (const input of inputs) {

            input.value = null;

        }



        this.searchText = '';

    }

}