import {LightningElement, track, api, wire} from 'lwc';
import {NavigationMixin} from 'lightning/navigation';
import getOrders from '@salesforce/apex/CommunityOpenOrderController.getOrders';
import { refreshApex } from '@salesforce/apex';
import {getURLParameters} from "c/util";
import reorderHelper from '@salesforce/apex/OrderSearchController.reorder';
import {
    subscribe,
    unsubscribe,
    APPLICATION_SCOPE,
    MessageContext
} from 'lightning/messageService';
import recordSelected from '@salesforce/messageChannel/selectedAccount__c';

const actions = [
    {label: 'Reorder', name: 'reorder'}
];

const defaultOrderQuery = {
    accountId: null,
    soldToId: null,
    searchText: null,
    fromDate: null,
    toDate: null,
    queryLimit: 50,
    queryOffset: 0,
};

export default class AllOpenOrders extends NavigationMixin(LightningElement) {

    hasRendered = false;
    orders = [];
    orderColumns = [

        {

            label: 'Current Order #',

            fieldName: 'linkToOrder',

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

             type:'currency',

           //formatter:'currency',

          // step:'0.01',

            //sortable: true,

           // typeAttributes: { currencyCode: 'EUR' }

           typeAttributes: { currencyCode: { fieldName: 'CurrencyIsoCode' } },

           cellAttributes: {alignment: 'right'}

           

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

            sortable: true,

            cellAttributes: {alignment: 'left'}

        },

        {

            type: 'button',

            typeAttributes: {

                label: 'Reorder',

                name: 'reorder',

                rowActions: actions,

                title: 'reorder',

                variant: 'brand'

            },

            cellAttributes: {

                alignment: 'left',

                class: {

                    fieldName: 'modifyReorderClass'

                }

            }

        },

    ];
    
    orderQuery = Object.assign({}, defaultOrderQuery);
    selectedOrder;
    isLoading = false;
    hasMoreRecords = false;

    @wire(getOrders, {orderQuery: {accountId: localStorage.getItem('AgentID'),

    soldToId: localStorage.getItem('DistributorID'),

    searchText: null,

    fromDate: null,

    toDate: null,

    queryLimit: 50,

    queryOffset: 0}

})

loadFirstOrderRecords({data, error}) {

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
    
                this.fetchOrders();
    
            }*/
    
     
    
            /*if (urlParameters['soldToId'] != null) {
    
                this.orderQuery.soldToId = urlParameters['soldToId'];
    
                //this.fetchOrders();
    
            }
    
            this.fetchOrders();*/
    
     
    
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
    
            this.fetchInitialOrders();
    
        } else if (agentID != ' ' && disAccId == ' ') {
    
            console.log('HANDLE MESSAGE - AGENT IS NOT BLANK BRANCH...');
    
            this.orderQuery.accountId = agentID;
    
            this.orderQuery.soldToId = null;
    
            console.log('Sending Agent Account ID: '+this.orderQuery.accountId);
    
            console.log('Sending Distributor Account ID: '+this.orderQuery.soldToId);
    
            this.fetchInitialOrders();
    
     } else {
    
            console.log('HANDLE MESSAGE - DISTRIBUTOR BRANCH...');
    
            this.orderQuery.accountId = null;
    
            this.orderQuery.soldToId = disAccId;
    
            console.log('Sending Agent Account ID: '+this.orderQuery.accountId);
    
            console.log('Sending Distributor Account ID: '+this.orderQuery.soldToId);
    
            this.fetchInitialOrders();
    
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

    async fetchOrders() {
        try {
            this.isLoading = true;
            let orders = await getOrders({orderQuery: this.orderQuery});
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

    async fetchInitialOrders() {

        this.orders = [];
    
        this.isLoading = true;
    
        let orders = await getOrders({orderQuery: this.orderQuery});
    
     
    
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

    async loadMoreOrders(event) {
        let target = event.target;
        try {
            if (this.isLoading === true || this.hasMoreRecords === false) {
                return;
            }
            target.isLoading = true;
            this.orderQuery.queryOffset += this.orderQuery.queryLimit;
            await this.fetchOrders();
        } catch (error) {
            console.error(error);
        }
        finally {
            target.isLoading = false;
        }
    }

    clear(event) {
        let inputs = this.template.querySelectorAll('.search-inputs lightning-input');
        for (const input of inputs) {
            input.value = null;
        }
        this.orders = [];
        this.orderQuery.searchText = null;
        this.orderQuery.fromDate = null;
        this.orderQuery.toDate = null;
        this.orderQuery.queryOffset = 0;
        this.fetchOrders();

    }

    handleOrderSearch(event) {
        try {
            let inputs = this.template.querySelectorAll('.search-inputs lightning-input');
            let areInputsValid = true;
            for (const input of inputs) {
                areInputsValid = areInputsValid && input.reportValidity();
                if (input.name === 'SearchOrders') {

                    this.orderQuery.searchText = input.value.trim();
                
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
            this.fetchOrders();
        } catch (error) {
            console.error(error);
        }
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const order = event.detail.row;
        switch (actionName) {
            case 'reorder':
                this.reOrder(order);
                break;
            default:
        }
    }

    async reOrder(order) {
        try{
            console.log('Sending ' + order.Id + ' To Reorder Screen');
            this.isLoading = true;
            this.selectedOrder = order;
            let cartId = await reorderHelper({orderId: this.selectedOrder.Id});

            if (localStorage.getItem('DistributorID')) {
                cartId+='&effectiveAccount=' + localStorage.getItem('DistributorID');
            } else {
                cartId+='&effectiveAccount=' + localStorage.getItem('AgentID');
            }

            window.location.href = cartId+'&orderReload=true';

            /*this[NavigationMixin.Navigate]({
                "type": "standard__webPage",
                "attributes": {
                    //Here customLabelExampleAura is name of lightning aura component
                    //This aura component should implement lightning:isUrlAddressable
                    //"componentName": "c__expediteOrderProdLWC"
                    "url": cartId
                }
            });*/
        }
        catch(error){
            console.error(error);
        }
        finally {
            this.isLoading = false;
        }
    }

    orderProto = {
        get linkToOrder() {
            return "/s/order" + "/" + this.Id + "/detail";
        },
        get agentName() {
            return this.Agent_Account__r?.Name;
        },
        get soldToName() {
            return this.Sold_To__r?.Name;
        },
        get modifyReorderClass() {
            var userPermissions = localStorage.getItem("UserPermission");
            if (userPermissions !== null) {
                userPermissions = JSON.parse(userPermissions);
                if ((userPermissions['profileName'] == "Agent Read Only B2B Storefront Registered Users" ||
                    userPermissions['profileName'] == "Distributor Read Only B2B Storefront Registered Users") &&
                    userPermissions['permissionSet'].includes('View_PLP_and_PDP_Prices') == false) {
                        return "commAgrHideCell";
                }
            }
        }
    }

    onHandleSort( event ) {

        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.orders];

        cloneData.sort( this.sortBy( sortedBy, sortDirection === 'asc' ? 1 : -1 ) );
        this.orders = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;

    }

    sortBy( field, reverse, primer ) {

        const key = primer
            ? function( x ) {
                  return primer(x[field]);
              }
            : function( x ) {
                  return x[field];
              };

        return function( a, b ) {
            a = key(a);
            b = key(b);
            return reverse * ( ( a > b ) - ( b > a ) );
        };

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