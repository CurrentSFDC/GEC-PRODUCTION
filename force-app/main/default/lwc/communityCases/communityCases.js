import {LightningElement, wire, track} from 'lwc';
import getCases from '@salesforce/apex/CommunityCases.getCases';
import {getURLParameters} from "c/util";
import {
    subscribe,
    unsubscribe,
    APPLICATION_SCOPE,
    MessageContext
} from 'lightning/messageService';
import recordSelected from '@salesforce/messageChannel/selectedAccount__c';

const defaultCaseQuery = {
    accountId: null,
    soldToId: null,
    searchText: null,
    fromDate: null,
    toDate: null,
    queryLimit: 50,
    queryOffset: 0,
};

export default class CommunityCases extends LightningElement {
    @track noCases = false;
    @track noCasesMessage = '';
    @track userType;
    @track customerColumns = false;
    hasRendered = false;
    hasMoreRecords = false;
    isLoading = false;
    cases = [];
    @track caseColumns = [
        {
            label: 'Case #',
            fieldName: 'recordLink',
            type: 'url',
            typeAttributes: {label: {fieldName: "CaseNumber"}, tooltip: "Name", target: "_self",
            class:{
                fieldName: 'iconColor' }},
            //cellAttributes: {alignment: 'right'},
            cellAttributes:{
                alignment: 'right',
                iconName:{fieldName:'rowIcon'}, 
                            
                        
                iconPosition:'left',
               
             
                class:{
                fieldName: 'iconColor' }
                
            }
        
        },
        /*{
            label: 'Agent',
            fieldName: 'agentName',
            type: 'Text',
            //sortable: true,
            cellAttributes: {alignment: 'left'}
        },*/
        {
            label: 'Sold To',
            fieldName: 'soldToName',
            type: 'Text',
            //sortable: true,
            cellAttributes: {alignment: 'left'}
        },
        {
            label: 'PO #',
            fieldName: 'GE_NAS_Purchase_Order__c',
            type: 'Text',
            //sortable: true,
            cellAttributes: {alignment: 'left'}
        },
        {
            label: 'Date Opened',
            fieldName: 'CreatedDate',
            type: 'date',
            cellAttributes: {alignment: 'right'}
        },
        {
            label: 'Case Type',
            fieldName: 'GE_NAS_Sub_Type__c',
            type: 'Text',
            cellAttributes: {alignment: 'left'}
        },
        {
            label: 'Source',
            fieldName: 'Origin',
            type: 'Text',
            cellAttributes: {alignment: 'left'}
        },
        {
            label: 'Status',
            fieldName: 'Status',
            type: 'Text',
            cellAttributes: {alignment: 'left'}
        }
    ];

    @track custColumns = [
        {
            label: 'Case #',
            fieldName: 'recordLink',
            type: 'url',
            typeAttributes: {label: {fieldName: "CaseNumber"}, tooltip: "Name", target: "_self"},
            cellAttributes: {alignment: 'right'}
        },
        {
            label: 'Account',
            fieldName: 'agentName',
            type: 'Text',
            //sortable: true,
            cellAttributes: {alignment: 'left'}
        },

        {
            label: 'Date Opened',
            fieldName: 'CreatedDate',
            type: 'date',
            cellAttributes: {alignment: 'center'}
        },
        {
            label: 'Case Type',
            fieldName: 'GE_NAS_Sub_Type__c',
            type: 'Text',
            cellAttributes: {alignment: 'center'}
        },
        {
            label: 'Source',
            fieldName: 'Origin',
            type: 'Text',
            cellAttributes: {alignment: 'center'}
        },
        {
            label: 'Status',
            fieldName: 'Status',
            type: 'Text',
            cellAttributes: {alignment: 'center'}
        }
    ];
    caseQuery = {...defaultCaseQuery};

    caseProto = {
        get recordLink(){
            return "/s/case"+"/" + this.Id + "/detail";
        },
        get agentName() {
            return this.Account?.Name;
        },
        get soldToName() {
            return this.Sold_To_Account__r?.Name;
        },
    }

    @wire(getCases, {caseQuery: {accountId: localStorage.getItem('AgentID'),

    soldToId: localStorage.getItem('DistributorID'),

    searchText: null,

    fromDate: null,

    toDate: null,

    queryLimit: 50,

    queryOffset: 0}

})

loadFirstCasesRecords({data, error}) {

    this.isLoading = true;

    this.cases = [];

 

    if (data !== undefined && data.length > 0) {

        console.log("loadFirstCasesRecords Data: ", data);

        this.noCases = false;

        this.hasMoreRecords = data.length === this.caseQuery.queryLimit;

 

        var caseData = [];

        for (const cas of data) {

            let o = Object.assign({}, cas);

            Object.setPrototypeOf(o, this.caseProto);
            //o.rowIcon = cas.Number_of_PO_s__c > 1 ? "utility:announcement":""
            o.rowIcon = cas.Number_of_PO_s__c > 1 ? "standard:merge":""
            o.iconColor = cas.Number_of_PO_s__c > 1 ? "slds-text-slds-icon-text-warning":""

            if (cas.Origin.includes("Email")) {

                o.Origin = "Email";

            }

           

            caseData.push(o);

        }

 

        this.cases = caseData;

        this.isLoading = false;

    } else if(data !== undefined && data.length < 1) {

        this.noCases = true;

        this.noCasesMessage = "No Open Cases based on your Selections";

        this.isLoading = false;

    } else {

        this.hasMoreRecords = false;

        this.isLoading = false;

    }

 

    if (error) {

        console.log(error);

        this.isLoading = false;

    }

}

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

    connectedCallback() {

        try {
    
            this.subscribeToMessageChannel();
    
     
    
            let agentID = localStorage.getItem('AgentID');
    
           let disAccId = localStorage.getItem('DistributorID');
    
            this.userType = localStorage.getItem('User Type');
    
            console.log('Setting User Type: '+this.userType);
    
            if(agentID != null){
    
                console.log('AGENT IS NOT BLANK BRANCH...');
    
                this.caseQuery.accountId = agentID;
    
                this.caseQuery.soldToId = disAccId;
    
                console.log('Sending Agent Account ID: '+this.caseQuery.accountId);
    
                console.log('Sending Distributor Account ID: '+this.caseQuery.soldToId);
    
            } else {
    
                console.log('DISTRIBUTOR BRANCH...');
    
                this.customerColumns = true;
    
                this.caseQuery.accountId = null;
    
                this.caseQuery.soldToId = disAccId;
    
                console.log('Sending Agent Account ID: '+this.caseQuery.accountId);
    
                console.log('Sending Distributor Account ID: '+this.caseQuery.soldToId);
    
            }
    
            /*let urlParameters = getURLParameters();
    
            if (urlParameters['id'] != null) {
    
                this.caseQuery.accountId = urlParameters['id'];
    
                this.fetchCases();
    
            }*/
    
        } catch (error) {
    
            console.error(error);
    
        }
    
    }


    handleMessage(message){

    console.log('ACCOUNT HAS CHANGED FROM ACCOUNT SELECTOR... :', message);

    let agentID = message.recordId;

    console.log('Handling the Agent ID: '+agentID);

    let disAccId = message.distributorID;

    console.log('Handling the Distributor ID: '+disAccId);

    this.clearSearchFields();

 

    if(agentID != ' ' && disAccId != ' '){

        console.log('HANDLE MESSAGE - AGENT AND DISTRIBUTOR IS NOT BLANK BRANCH...');

        this.caseQuery.accountId = agentID;

        this.caseQuery.soldToId = disAccId;

        console.log('Sending Agent Account ID: '+this.caseQuery.accountId);

        console.log('Sending Distributor Account ID: '+this.caseQuery.soldToId);

        this.fetchInitialCases();

    } else if ((agentID != ' ' || agentID != 'undefined') && disAccId == ' ') {

        console.log('HANDLE MESSAGE - AGENT IS NOT BLANK BRANCH...');

        this.caseQuery.accountId = agentID;

        this.caseQuery.soldToId = null;

        console.log('Sending Agent Account ID: '+this.caseQuery.accountId);

        console.log('Sending Distributor Account ID: '+this.caseQuery.soldToId);

        this.fetchInitialCases();

    } else {

        console.log('HANDLE MESSAGE - DISTRIBUTOR BRANCH...');

        this.caseQuery.accountId = null;

        this.caseQuery.soldToId = disAccId;

        this.customerColumns = true;

        console.log('Sending Agent Account ID: '+this.caseQuery.accountId);

        console.log('Sending Distributor Account ID: '+this.caseQuery.soldToId);

        this.fetchInitialCases();

    }

}

renderedCallback() {
    if (this.hasRendered === false) {
        window.addEventListener('keyup', event => {
            try{
                if (event.key === 'Enter') {
                    this.handleCaseSearch();
                }
            }
            catch(error){
                console.error(error);
            }
        });
        this.hasRendered = true;
    }
}

handleCaseSearch(event) {
    try {
        let inputs = this.template.querySelectorAll('.search-inputs lightning-input');
        let areInputsValid = true;
        for (const input of inputs) {
            areInputsValid = areInputsValid && input.reportValidity();
            if (input.name === 'Search') {

                this.caseQuery.searchText = input.value !== "" ? input.value.trim() : null;
            
            }

            if (input.name === 'FromDate') {
                this.caseQuery.fromDate = input.value !== "" ? input.value : null;
            }

            if (input.name === 'ToDate') {
                this.caseQuery.toDate = input.value !== "" ? input.value : null;
            }
        }
        if (areInputsValid === false) {
            return;
        }
        this.cases = [];
        this.caseQuery.queryOffset = 0;
        console.log(`this.caseQuery`,this.caseQuery);
        this.fetchCases();
    } catch (error) {
        console.error(error);
    }
}

clearSearch() {
    let inputs = this.template.querySelectorAll('.search-inputs lightning-input');

    for (const input of inputs) {
        input.value = null;
    }

    this.cases = [];
    this.caseQuery.searchText = null;
    this.caseQuery.fromDate = null;
    this.caseQuery.toDate = null;
    this.caseQuery.queryOffset = 0;
    this.fetchCases();
}

    async fetchCases(){
        try {
            this.isLoading = true;
            let cases = await getCases({caseQuery: this.caseQuery});
            if (cases != null && cases.length > 0) {
                this.noCases = false;
                this.hasMoreRecords = cases.length === this.caseQuery.queryLimit;
                for (const cas of cases) {
                    let o = Object.assign({}, cas);
                    Object.setPrototypeOf(o, this.caseProto);
                    //o.rowIcon = cas.Number_of_PO_s__c > 1 ? "utility:announcement":""
                o.rowIcon = cas.Number_of_PO_s__c > 1 ? "standard:merge":""
                o.iconColor = cas.Number_of_PO_s__c > 1 ? "slds-text-slds-icon-text-warning":""
                    if(cas.Origin.includes("Email")){
                        o.Origin = "Email";
                    }
                    
                    this.cases.push(o);
                }
                this.cases = [...this.cases];
            } else if(cases.length < 1){
                this.noCases = true;
                this.noCasesMessage = "No Open Cases based on your Selections";
            }
            else {
                
                this.hasMoreRecords = false;
            }
        } catch (error) {
            console.error(error);
        } finally {
            this.isLoading = false;
        }
    }

    async fetchInitialCases() {

        this.cases=[];
    
        this.isLoading = true;
    
        let cases = await getCases({caseQuery: this.caseQuery});
    
     
    
        if (cases != null && cases.length > 0) {
    
            this.noCases = false;
    
            this.hasMoreRecords = cases.length === this.caseQuery.queryLimit;
    
     
    
            var caseData = [];
    
            for (const cas of cases) {
    
                let o = Object.assign({}, cas);
    
                Object.setPrototypeOf(o, this.caseProto);
                //o.rowIcon = cas.Number_of_PO_s__c > 1 ? "utility:announcement":""
                o.rowIcon = cas.Number_of_PO_s__c > 1 ? "standard:merge":""
                o.iconColor = cas.Number_of_PO_s__c > 1 ? "slds-text-slds-icon-text-warning":""
    
                if(cas.Origin.includes("Email")){
    
                    o.Origin = "Email";
    
                }
    
               
    
                caseData.push(o);
    
            }
    
     
    
            this.cases = caseData;
    
            this.isLoading = false;
    
        } else if (cases.length < 1) {
    
            this.noCases = true;
    
            this.noCasesMessage = "No Open Cases based on your Selections";
    
        } else {
    
            this.hasMoreRecords = false;
    
        }
    
     
    
        this.isLoading = false;
    
    }

    async loadMoreCases(event) {
        let target = event.target;
        try {
            if (this.isLoading === true || this.hasMoreRecords === false) {
                return;
            }
            target.isLoading = true;
            this.caseQuery.queryOffset += this.caseQuery.queryLimit;
            await this.fetchCases();
        } catch (error) {
            console.error(error);
        }
        finally {
            target.isLoading = false;
        }
    }

    clearSearchFields() {

        let inputs = this.template.querySelectorAll('.search-inputs lightning-input');
    
     
    
        for (const input of inputs) {
    
            input.value = null;
    
        }
    
     
    
        this.caseQuery.searchText = null;
    
        this.caseQuery.fromDate = null;
    
        this.caseQuery.toDate = null;
    
        this.caseQuery.queryOffset = 0;
    
    }

}