import { LightningElement, track, wire, api } from 'lwc';
import getOpenOrders from '@salesforce/apex/CommunityNotificationsClass.getNotifications';
import getAllNotificaitons from '@salesforce/apex/CommunityNotificationsClass.getAllNotifications';
import {NavigationMixin} from 'lightning/navigation';
import {
    subscribe,
    unsubscribe,
    APPLICATION_SCOPE,
    MessageContext
} from 'lightning/messageService';
import recordSelected from '@salesforce/messageChannel/selectedAccount__c';
import openOrder from '@salesforce/contentAssetUrl/gecicon50notificationWHTpng';

const defaultNotificationQuery = {
    accountId: null,
    soldToId: null,
    searchText: null,
    source: null,
    fromDate: null,
    toDate: null,
    queryLimit: 50,
    queryOffset: 0,
};

export default class CommunityNotificationsWidget extends NavigationMixin(LightningElement) {

    notificationQuery = Object.assign({}, defaultNotificationQuery);
    opendOrder = openOrder;
    @track selectedID;
    @track userType;
    @track distributorID;
    @track distributorName;
    @track distributorNumber;
    @track agentNumber;
   
    @track isLoading = false;
    @track hasMoreRecords = false;
    @api configType = ' ';
    @track isWidget = false;
    @track isViewAll = false;
    @track source;
    @track value;
    orders = [];

    @track baseOptions = [
        { label: 'Service Request', value: 'Service Request' },
        { label: 'Order', value: 'Order' },
        //{ label: 'Price Agreement', value: 'Price Agreement' },
        { label: 'Release Notes', value: 'Release Note' },
        { label: 'New User', value: 'New User' },
    ];
    

    orderColumns = [
        {
            label: 'Source',
            fieldName: 'Source__c',
            type: 'text',
            //sortable: true,
            initialWidth: 120, 
            cellAttributes: {alignment: 'right'}
        },
        {
            label: 'Number',
            fieldName: 'linkToOrder',
            type: 'url',
            typeAttributes: {label: {fieldName: "Name"}, tooltip: "Name", target: "_self"},
            cellAttributes: {alignment: 'left'},
            initialWidth: 100, 
        },
        {
            label: 'Date',
            fieldName: 'Date__c',
            type: 'date-local',
            //sortable: true,
            cellAttributes: {alignment: 'left'},
            initialWidth: 100, 
        },
        /*{
            label: 'Agent',
            fieldName: 'agentName',
            type: 'text',
            //sortable: true,
            initialWidth: 120, 
            cellAttributes: {alignment: 'right'}
        },*/
        {
            label: 'Distributor',
            fieldName: 'soldToName',
            type: 'text',
            //sortable: true,
            initialWidth: 250,
            cellAttributes: {alignment: 'left'}
        },
        {
            label: 'Notification',
            fieldName: 'Notification__c',
            type: 'Text',
            //sortable: true,
            cellAttributes: {alignment: 'left'},
            initialWidth: 200, 
        },
        /*{
            label: 'Current Order #',
            fieldName: 'GE_Order_NO__c',
            type: 'Text',
            sortable: true,
            cellAttributes: { alignment: 'center' }
        },*/
        {
            label: 'Description',
            fieldName: 'Description__c',
            type: 'text',
            //sortable: true,
            wrapText: true,
            cellAttributes: {alignment: 'left'},
            
        }
    ];

    widgetColumns = [
        {
            label: 'Source',
            fieldName: 'Source__c',
            type: 'text',
            //sortable: true,
            initialWidth: 120, 
            cellAttributes: {alignment: 'right'}
        },
        {
            label: 'Number',
            fieldName: 'linkToOrder',
            type: 'url',
            typeAttributes: {label: {fieldName: "Name"}, tooltip: "Name", target: "_self"},
            cellAttributes: {alignment: 'left'},
            initialWidth: 91, 
        },
        {
            label: 'Date',
            fieldName: 'Date__c',
            type: 'date-local',
            //sortable: true,
            cellAttributes: {alignment: 'left'},
            initialWidth: 99, 
        },
        {
            label: 'Notification',
            fieldName: 'Notification__c',
            type: 'Text',
            //sortable: true,
            cellAttributes: {alignment: 'left'},
            initialWidth: 181, 
        },
        /*{
            label: 'Current Order #',
            fieldName: 'GE_Order_NO__c',
            type: 'Text',
            sortable: true,
            cellAttributes: { alignment: 'center' }
        },*/
        {
            label: 'Description',
            fieldName: 'Description__c',
            type: 'text',
            //sortable: true,
            wrapText: true,
            initialWidth: 388, 
            cellAttributes: {alignment: 'left'},
            
        }
    ];

    @track orderItems = [];
    @track orderItemsMessage;
    @track message = 'No Data Found.';
    @track buttonLabel;

    handleKey(event){
        if(event.which == 13){
            this.handleNotifcationSearch();
        }
    }



    @wire(getAllNotificaitons, {notificationQuery: {accountId: localStorage.getItem('AgentID'),
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
            //this.noCases = false;
            this.hasMoreRecords = data.length === this.notificationQuery.queryLimit;

            var orderData = [];
            for (const order of data) {
                let o = Object.assign({}, order);
                Object.setPrototypeOf(o, this.orderProto);
                orderData.push(o);
            }

            this.orders = orderData;
            this.orderItems = orderData;
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
    };



    @wire(MessageContext)
    messageContext;









    handleActionPick(event){
        this.source = event.target.value;
        console.log('Source :' +this.source);
    }

    // Encapsulate logic for Lightning message service subscribe and unsubsubscribe
   async subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                recordSelected,
                (message) => this.handleMessage(message),
                {scope: APPLICATION_SCOPE}
            );
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
            this.notificationQuery.accountId = agentID;
            this.notificationQuery.soldToId = disAccId;
            console.log('Sending Agent Account ID: '+this.notificationQuery.accountId);
            console.log('Sending Distributor Account ID: '+this.notificationQuery.soldToId);
            this.fetchInitialOrders();
        } else if (agentID != ' ' && disAccId == ' ') {
            console.log('HANDLE MESSAGE - AGENT IS NOT BLANK BRANCH...');
            this.notificationQuery.accountId = agentID;
            this.notificationQuery.soldToId = null;
            console.log('Sending Agent Account ID: '+this.notificationQuery.accountId);
            console.log('Sending Distributor Account ID: '+this.notificationQuery.soldToId);
            this.fetchInitialOrders();
        } else {
            console.log('HANDLE MESSAGE - DISTRIBUTOR BRANCH...');
            this.notificationQuery.accountId = null;
            this.notificationQuery.soldToId = disAccId;
            console.log('Sending Agent Account ID: '+this.notificationQuery.accountId);
            console.log('Sending Distributor Account ID: '+this.notificationQuery.soldToId);
            this.fetchInitialOrders();
        }
    }

   async renderedCallback() {
        this.subscribeToMessageChannel();
        if(this.configType === "Widget"){
        const style = document.createElement('style');
        style.innerText = `c-community-notifications-widget .slds-card__header {
            background-color: #FF9F19;
            width: 100%;
            align: center;
            color: white;
            font-family: 'Segoe UI';
            padding: 10px;
        }`;
        this.template.querySelector('lightning-card').appendChild(style);

        const styleHeader = document.createElement('style');
        styleHeader.innerText = `c-community-notifications-widget .slds-text-heading_small {
            width: 100%;
            font-family: 'Segoe UI';
            font-weight: bold;
            font-size: 18px;
            margin: 0;
            padding: 0;
        }`;
        this.template.querySelector('lightning-card').appendChild(styleHeader);
    }
    }

    // Standard lifecycle hooks used to subscribe and unsubsubscribe to the message channel
    /*async connectedCallback() {
        if(this.configType === "Widget"){
            this.isWidget = true;
        } else if(this.configType === "View All Page"){
            this.isViewAll = true;
        }
        console.log('Configuration Type: '+this.configType);
        this.isLoading = true;
        console.log('NOTIFICATIONS - Subscribing to Message Channel...');
        //this.subscribeToMessageChannel();

        this.userType = localStorage.getItem('User Type');
        this.selectedID = localStorage.getItem('AgentID');
        this.distributorID = localStorage.getItem('DistributorID');
        this.distributorName = localStorage.getItem('DistributorName')
        this.distributorNumber = localStorage.getItem('DistributorAccount');
        this.agentNumber = localStorage.getItem('AgentNumber');

        console.log('NOTIFICATIONS - Agent Account ID passed from Component: '+this.selectedID);
        console.log('NOTIFICATIONS - Agent Account Number passed from Component: '+this.agentNumber);
        console.log('NOTIFICATIONS - Distributor Account ID passed from Component: '+this.distributorID); // ID OF THE DISTRIBUTOR
        console.log('NOTIFICATIONS - Distributor Account Name passed from Component: '+this.distributorName); // NAME OF THE DISTRIBUTOR
        console.log('NOTIFICATIONS - Distributor Account Number passed from Component: '+this.distributorNumber); // SAP CUSTOMER NUMBER OF THE DISTRIBUTOR

        
        getOpenOrders({accountId: this.selectedID, distributorId : this.distributorID, userType : this.userType}) 
       
            .then(result => {
                console.log('Executed APEX - getOpenOrders in Connected Callback....');
                if (result.length > 0) {
                    this.buttonLabel = "View All";
                    var tempOrderList = [];
                    for (var i = 0; i < result.length; i++) {
                        let tempRecord = Object.assign({}, result[i]);
                        if(tempRecord.Source__c === "Order"){
                            console.log('Record ID for Line: '+tempRecord.Records_ID__c);
                            tempRecord.recordLink = "/Agents/s/order" + "/" + tempRecord.Records_ID__c; // STAGE
                        } else if (tempRecord.Source__c === "Release Note"){
                            tempRecord.recordLink = "/Agents/s/release-notes";
                        } else if (tempRecord.Source__c === "Service Request"){
                            tempRecord.recordLink = "/Agents/s/case/"+tempRecord.Records_ID__c;
                        }
                        tempOrderList.push(tempRecord);
                    }
                    this.isLoading = false;
                    this.orderItems = tempOrderList;
                    this.orders = tempOrderList;
                    this.orderItemsMessage = '';
                    console.log('ConnectedCallback - Notifications Returned: '+JSON.stringify(this.orderItems));
                } else {
                    
                    this.isLoading = false;
                    this.orderItemsMessage = 'No Notifications to Display.';
                    this.buttonLabel = "View History";
                }
            }).catch(error => {
            console.error(error);
            this.isLoading = false;
            this.orderItemsMessage = "No Notifications to Display.";
            this.buttonLabel = "View History";
        });
        this.subscribeToMessageChannel();
    }*/

    connectedCallback() {
        try {
            this.subscribeToMessageChannel();

            if(this.configType === "Widget"){
                this.isWidget = true;
                //this.fetchWidgetData();
            } else if(this.configType === "View All Page"){
                this.isViewAll = true;
            }

            let agentID = localStorage.getItem('AgentID');
            let disAccId = localStorage.getItem('DistributorID');
            if(agentID != null){
                console.log('AGENT IS NOT BLANK BRANCH...');
                this.notificationQuery.accountId = agentID;
                this.notificationQuery.soldToId = disAccId;
                console.log('Sending Agent Account ID: '+this.notificationQuery.accountId);
                console.log('Sending Distributor Account ID: '+this.notificationQuery.soldToId);
            } else {
                console.log('DISTRIBUTOR BRANCH...');
                this.notificationQuery.accountId = null;
                this.notificationQuery.soldToId = disAccId;
                console.log('Sending Agent Account ID: '+this.notificationQuery.accountId);
                console.log('Sending Distributor Account ID: '+this.notificationQuery.soldToId);
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

    disconnectedCallback() {
        //this.unsubscribeToMessageChannel();
    }

    viewAllOrderItems(evt) {
        var baseURL = window.location.origin
        this.sfdcOrgURL = baseURL + '/s/all-notifications' // STAGE
        //this.sfdcOrgURL = baseURL + '/s/open-orders' + '?id=' + this.selectedID; // PRODUCTION
        window.open(this.sfdcOrgURL, '_self');

        //var url = '/Agents/s/order/related/'+ this.selectedID+'/AgentOrders__r';
        //window.open(url);
    }


    handleNotifcationSearch(event) {
        try {
            let inputs = this.template.querySelectorAll('.search-inputs lightning-input');
            let source = this.template.querySelector('.ss').value;
            let areInputsValid = true;
            for (const input of inputs) {
                areInputsValid = areInputsValid && input.reportValidity();
                if (source) {
                    this.notificationQuery.source = source;
                }
                if (input.name === 'SearchNotifications') {
                    this.notificationQuery.searchText = input.value !== "" ? input.value : null;
                }
                if (input.name === 'FromDate') {
                    this.notificationQuery.fromDate = input.value !== "" ? input.value : null;
                }
                if (input.name === 'ToDate') {
                    this.notificationQuery.toDate = input.value !== "" ? input.value : null;
                }
            }
            if (areInputsValid === false) {
                return;
            }
            this.orders = [];
            this.notificationQuery.queryOffset = 0;
            this.fetchOrders();
        } catch (error) {
            console.error(error);
        }
    }

    async fetchOrders() {
        try {
            this.isLoading = true;
            console.log('inside fetchorders');
            let orders = await getAllNotificaitons({notificationQuery: this.notificationQuery});
            if (orders != null && orders.length > 0) {
                console.log('inside if fetchOrders');
                this.hasMoreRecords = orders.length === this.notificationQuery.queryLimit;
                for (const order of orders) {
                    let o = Object.assign({}, order);
                    Object.setPrototypeOf(o, this.orderProto);
                    
                    this.orders.push(o);
                }
                this.orders = [...this.orders];
                console.log('Fetch Notifications: '+JSON.stringify(this.orders));
            } else {
                console.log('inside else fetchOrders');
                this.hasMoreRecords = false;
            }
        } catch (error) {
            console.error(error);
        } finally {
            this.isLoading = false;
        }
    }

    async fetchWidgetData() {
        this.orders = [];
        this.isLoading = true;
        let orders = await getOpenOrders({accountId: this.selectedID, distributorId : this.distributorID, userType : this.userType}) ;

        if (orders != null && orders.length > 0) {
            this.hasMoreRecords = orders.length === this.notificationQuery.queryLimit;

            var orderData = [];
            for (const order of orders) {
                let o = Object.assign({}, order);
                Object.setPrototypeOf(o, this.orderProto);
                orderData.push(o);
            }
            this.orderItems = orderData;
            console.log('Fetch Widget Notifications: '+JSON.stringify(this.orders));
            this.isLoading = false;
        } else {
            this.hasMoreRecords = false;
            this.isLoading = false;
        }
    }

    async fetchInitialOrders() {
        this.orders = [];
        this.isLoading = true;
        let orders = await getAllNotificaitons({notificationQuery: this.notificationQuery});

        if (orders != null && orders.length > 0) {
            this.hasMoreRecords = orders.length === this.notificationQuery.queryLimit;

            var orderData = [];
            for (const order of orders) {
                let o = Object.assign({}, order);
                Object.setPrototypeOf(o, this.orderProto);
                orderData.push(o);
            }
            this.orders = orderData;
            this.orderItems = orderData;
            console.log('Fetch Initial Notifications: '+JSON.stringify(this.orders));
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
            this.notificationQuery.queryOffset += this.notificationQuery.queryLimit;
            await this.fetchOrders();
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
        this.source = null;
        this.notificationQuery.searchText = null;
        this.notificationQuery.source = null;
        this.notificationQuery.fromDate = null;
        this.notificationQuery.toDate = null;
        this.notificationQuery.queryOffset = 0;
    }

    orderProto = {
        get linkToOrder() {
            var baseURL = window.location.origin
            if(this.Source__c === "Order"){
                console.log('Record ID for Line: '+this.Records_ID__c);
                return baseURL + "/s/order" + "/" + this.Records_ID__c; // STAGE
            } else if (this.Source__c === "Release Note"){
                return  baseURL + "/s/release-notes";
            } else if (this.Source__c === "Service Request"){
                return baseURL +  "/s/case/"+this.Records_ID__c;
            }
           
        },
        get agentName() {
            return this.Agent___r?.Name;
        },
        get soldToName() {
            return this.Distributor__r?.Name;
        }
    
    }

    clear(event) {
        let inputs = this.template.querySelectorAll('.search-inputs lightning-input');
        for (const input of inputs) {
            input.value = null;
        }
        this.orders = [];
        this.source = null;
        this.notificationQuery.searchText = null;
        this.notificationQuery.source = null;
        this.notificationQuery.fromDate = null;
        this.notificationQuery.toDate = null;
        this.notificationQuery.queryOffset = 0;
        this.fetchOrders();

    }

}