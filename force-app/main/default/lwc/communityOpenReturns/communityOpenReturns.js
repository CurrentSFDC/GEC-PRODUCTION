import {LightningElement, wire} from 'lwc';
import getOpenReturns from '@salesforce/apex/CommunityOpenReturnsController.getOpenReturns';
import {getURLParameters} from "c/util";

import {
    subscribe,
    unsubscribe,
    APPLICATION_SCOPE,
    MessageContext
} from 'lightning/messageService';
import recordSelected from '@salesforce/messageChannel/selectedAccount__c';

const defaultOrderQuery = {
    accountId: null,
    soldToId: null,
    searchText: null,
    fromDate: null,
    toDate: null,
    queryLimit: 50,
    queryOffset: 0,
};

export default class CommunityOpenReturns extends LightningElement {
    orderColumns = [

        {

            label: 'Return Order #',

            fieldName: 'recordLink',

            type: 'url',

            typeAttributes: {label: {fieldName: "GE_Order_NO__c"}, tooltip: "Name", target: "_self"},

            cellAttributes: {alignment: 'right'}

        },

        {

            label: 'PO #',

            fieldName: 'Customer_PO_Number__c',

            type: 'Text',

            //sortable: true,

            cellAttributes: {alignment: 'left'}

        },

        {

            label: 'Account',

            fieldName: 'soldToName',

            type: 'Text',

            //sortable: true,

            cellAttributes: {alignment: 'left'}

        },

        // {

        //     label: 'Agent',

        //     fieldName: 'agentName',

        //     type: 'Text',

        //     //sortable: true,

        //     cellAttributes: {alignment: 'left'}

        // },

        {

            label: 'Order Date',

            fieldName: 'EffectiveDate',

            type: 'date-local',

            //sortable: true,

            cellAttributes: {alignment: 'right'}

        },

      

        /*{

            label: 'Current Order #',

            fieldName: 'GE_Order_NO__c',

            type: 'Text',

            sortable: true,

            cellAttributes: { alignment: 'center' }

        },*/

        {

            label: 'Req Delivery Date',

            fieldName: 'Order_Req_Delivery_Date__c',

            //type: 'Text',

            //sortable: true,

            type: 'date-local',

            typeAttributes: {

                month: "2-digit",

                day: "2-digit",

                year: "numeric",

            },

            cellAttributes: {alignment: 'right'}

        },

        {

            label: 'Project Name',

            fieldName: 'GE_Opportunity_Id__c',

            type: 'Text',

            //sortable: true,

            cellAttributes: {alignment: 'left'}

        },

        {

            label: 'Order Amount',

            fieldName: 'Grand_Total__c',

            type: 'currency',

            //sortable: true,

            typeAttributes: { currencyCode: { fieldName: 'CurrencyIsoCode' } },

            cellAttributes: {alignment: 'center'}

        },

        // {

        //     label: 'Currency',

        //     fieldName: 'CurrencyIsoCode',

        //     type: 'Text',

        //     cellAttributes: { alignment: 'left' }

        // },

        {

            label: 'Order Status',

            fieldName: 'GBSTK__c',

            type: 'text',

            //sortable: true,

            cellAttributes: {alignment: 'left'}

        },

    ];
    orders = [];
    isLoading = false;
    hasMoreRecords = false;
    hasRendered = false;
    orderQuery = {...defaultOrderQuery};

    @wire(getOpenReturns, {orderQuery: {accountId: localStorage.getItem('AgentID'),

    soldToId: localStorage.getItem('DistributorID'),

    searchText: null,

    fromDate: null,

    toDate: null,

    queryLimit: 50,

    queryOffset: 0}

})

loadFirstReturnOrderRecords({data, error}) {

    this.isLoading = true;

    this.orders = [];

 

    if (data !== undefined && data.length > 0) {

        this.noCases = false;

        this.hasMoreRecords = data.length === this.orderQuery.queryLimit;

 

        var orderData = [];

        for (const order of data) {

            let o = Object.assign({}, order);

            Object.setPrototypeOf(o, this.orderProto);

            orderData.push(o);

        }

 

        this.orders = orderData;

        this.isLoading = false;

    } else if(data !== undefined && data.length < 1) {

        this.hasMoreRecords = false;

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
    
            if(agentID != null){
    
                console.log('AGENT IS NOT BLANK BRANCH...');
    
                this.orderQuery.accountId = agentID;
    
                this.orderQuery.soldToId = disAccId;
    
                console.log('Sending Agent Account ID: '+this.orderQuery.accountId);
    
                console.log('Sending Distributor Account ID: '+this.orderQuery.soldToId);
    
            } else {
    
                console.log('DISTRIBUTOR BRANCH...');
    
                this.orderQuery.accountId = null;
    
                this.orderQuery.soldToId = disAccId;
    
                console.log('Sending Agent Account ID: '+this.orderQuery.accountId);
    
                console.log('Sending Distributor Account ID: '+this.orderQuery.soldToId);
    
            }
    
            /*let urlParameters = getURLParameters();
    
            if (urlParameters['id'] != null) {
    
                this.orderQuery.accountId = urlParameters['id'];
    
                this.fetchOpenReturns();
    
            }*/
    
        } catch (error) {
    
            console.error(error);
    
        }
    
    }

    handleMessage(message){

 

        console.log('ACCOUNT HAS CHANGED FROM ACCOUNT SELECTOR...');
    
        let agentID = message.recordId;
    
        console.log('Handling the Agent ID: '+agentID);
    
        let disAccId = message.distributorID;
    
        console.log('Handling the Distributor ID: '+disAccId);
    
        this.clearSearchFields();
    
     
    
        if(agentID != ' ' && disAccId != ' '){
    
            console.log('HANDLE MESSAGE - AGENT AND DISTRIBUTOR IS NOT BLANK BRANCH...');
    
            this.orderQuery.accountId = agentID;
    
            this.orderQuery.soldToId = disAccId;
    
            console.log('Sending Agent Account ID: '+this.orderQuery.accountId);
    
            console.log('Sending Distributor Account ID: '+this.orderQuery.soldToId);
    
            this.fetchInitialOpenReturns();
    
        } else if (agentID != ' ' && disAccId == ' ') {
    
            console.log('HANDLE MESSAGE - AGENT IS NOT BLANK BRANCH...');
    
            this.orderQuery.accountId = agentID;
    
            this.orderQuery.soldToId = null;
    
            console.log('Sending Agent Account ID: '+this.orderQuery.accountId);
    
            console.log('Sending Distributor Account ID: '+this.orderQuery.soldToId);
    
            this.fetchInitialOpenReturns();
    
        } else {
    
            console.log('HANDLE MESSAGE - DISTRIBUTOR BRANCH...');
    
            this.orderQuery.accountId = null;
    
            this.orderQuery.soldToId = disAccId;
    
            console.log('Sending Agent Account ID: '+this.orderQuery.accountId);
    
            console.log('Sending Distributor Account ID: '+this.orderQuery.soldToId);
    
            this.fetchInitialOpenReturns();
    
        }
    
    }

    renderedCallback() {
        if (this.hasRendered === false) {
            window.addEventListener('keypress', event => {
                if (event.key === 'Enter') {
                    this.handleOrderSearch();
                }
            });
            this.hasRendered = true;
        }
    }

    clearSearch(event) {
        let inputs = this.template.querySelectorAll('.search-inputs lightning-input');
        for (const input of inputs) {
            input.value = null;
        }
        this.orders = [];
        this.orderQuery.searchText = null;
        this.orderQuery.fromDate = null;
        this.orderQuery.toDate = null;
        this.orderQuery.queryOffset = 0;
        this.fetchOpenReturns();
    }

    async fetchOpenReturns() {
        try {
            this.isLoading = true;
            let orders = await getOpenReturns({orderQuery: this.orderQuery});
            if (orders != null && orders.length > 0) {
                this.hasMoreRecords = orders.length === this.orderQuery.queryLimit;
                for (const order of orders) {
                    let o = Object.assign({}, order);
                    Object.setPrototypeOf(o, this.orderProto);
                    this.orders.push(o);
                }
                this.orders = [...this.orders];
            } else {
                this.hasMoreRecords = false;
            }
        } catch (error) {
            console.error(error);
        } finally {
            this.isLoading = false;
        }
    }

    async fetchInitialOpenReturns() {

        this.orders = [];
    
        this.isLoading = true;
    
        let orders = await getOpenReturns({orderQuery: this.orderQuery});
    
     
    
        if (orders != null && orders.length > 0) {
    
            this.hasMoreRecords = orders.length === this.orderQuery.queryLimit;
    
     
    
            var orderData = [];
    
            for (const order of orders) {
    
                let o = Object.assign({}, order);
    
                Object.setPrototypeOf(o, this.orderProto);
    
                orderData.push(o);
    
            }
    
            this.orders = orderData;
    
            this.isLoading = false;
    
        } else {
    
            this.hasMoreRecords = false;
    
            this.isLoading = false;
    
        }
    
    }

    orderProto = {
        get recordLink() {
            return "/s/order" + "/" + this.Id + "/detail";
        },
        get agentName() {
            return this.Agent_Account__r?.Name;
        },
        get soldToName() {
            return this.Sold_To__r?.Name;
        },
    }

    async loadMoreOrders(event) {
        let target = event.target;
        try {
            if (this.isLoading === true || this.hasMoreRecords === false) {
                return;
            }
            target.isLoading = true;
            this.orderQuery.queryOffset += this.orderQuery.queryLimit;
            await this.fetchOpenReturns();
        } catch (error) {
            console.error(error);
        } finally {
            target.isLoading = false;
        }
    }

    handleOrderSearch(event) {
        try {
            let inputs = this.template.querySelectorAll('.search-inputs lightning-input');
            let areInputsValid = true;
            for (const input of inputs) {
                areInputsValid = areInputsValid && input.reportValidity();
                if (input.name === 'Search') {

                    this.orderQuery.searchText = input.value !== "" ? input.value.trim() : null;
                
                }
    
                if (input.name === 'FromDate') {
                    this.orderQuery.fromDate = input.value !== "" ? input.value : null;
                }
    
               if (input.name === 'ToDate') {
                    this.orderQuery.toDate = input.value !== "" ? input.value : null;
                }
            }
            if (areInputsValid === false) {
                return;
            }
            this.orders = [];
            this.orderQuery.queryOffset = 0;
            this.fetchOpenReturns();
        } catch (error) {
            console.error(error);
        }
    }

    clearSearchFields() {

        let inputs = this.template.querySelectorAll('.search-inputs lightning-input');
    
     
    
        for (const input of inputs) {
    
            input.value = null;
    
        }
    
     
    
        this.orderQuery.searchText = null;
    
        this.orderQuery.fromDate = null;
    
        this.orderQuery.toDate = null;
    
        this.orderQuery.queryOffset = 0;
    
    }
}