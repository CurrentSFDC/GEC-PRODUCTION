import { LightningElement, track, wire } from 'lwc';
import leadTimes from '@salesforce/contentAssetUrl/gecicon30leadtimeBKpng';
import quickStock from '@salesforce/contentAssetUrl/newQuickStockConfigure';
import marketplace from '@salesforce/contentAssetUrl/newMarketplace';
import savedCarts from '@salesforce/contentAssetUrl/cartspng';
import customers from '@salesforce/contentAssetUrl/newMyCustomers';
import priceAgreement from '@salesforce/contentAssetUrl/newPriceAgreements';
import proline from '@salesforce/contentAssetUrl/newProlineImage';
import contactUs from '@salesforce/contentAssetUrl/contactusiconpng';
import phone from '@salesforce/contentAssetUrl/phoneicon3png';
import email from '@salesforce/contentAssetUrl/downloadpng';
import releaseNotes from '@salesforce/contentAssetUrl/iconfapencilsquareopng';
import amp from '@salesforce/contentAssetUrl/AMPIcon30x30png';

// USED FOR GETTING THE USER DATA - WITHOUT APEX CALL
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import ACCOUNT_FIELD from '@salesforce/schema/User.AccountId';
import getUserPerMissionSet from '@salesforce/apex/communityOpenClass.getUserPerMissionSet';
import getUserProfile from '@salesforce/apex/communityOpenClass.getUserProfile';
import USER_COUNTRY from '@salesforce/schema/User.Country';

import {
    subscribe,
    unsubscribe,
    APPLICATION_SCOPE,
    MessageContext
} from 'lightning/messageService';
import recordSelected from '@salesforce/messageChannel/selectedAccount__c';
// import getActiveCart from '@salesforce/apex/ReorderHelper.getActiveCart';
import UserType from '@salesforce/schema/User.User_Type__c';

export default class NewBookmarksBar extends LightningElement {

    leadTimes = leadTimes;
    quickStock = quickStock;
    marketplace = marketplace;
    savedCarts = savedCarts;
    customers = customers;
    priceAgreement = priceAgreement;
    proline = proline;
    contactUs = contactUs;
    phone = phone;
    email = email;
    releaseNotes = releaseNotes;
    amp = amp;
    @track contactUsModal = false;
    @track accountID;
    @track baseURL;
    @track selectedID;
    @track UserType;
    @track showPricing = true;
    @track isAgent = false;


        // GET CURRENT LOGGED IN COMMUNITY USER INFORMATION
        @wire(getRecord, {
            recordId: USER_ID,
            fields: [ACCOUNT_FIELD, UserType, USER_COUNTRY]
        }) wireuser({
            error,
            data
        }) {
            if (error) {
            this.error = error ;
            } else if (data) {
                // console.log("Data = ", data);
                this.accountID = data.fields.AccountId.value;
                this.UserType = data.fields.User_Type__c.value;
                this.baseURL = window.location.origin;
                var country = data.fields.Country.value;
                if(country.toUpperCase()=="CA" || country.toUpperCase()=="CAD" || country.toUpperCase()=="CANADA"){ 
                    console.log('Country Name Before Conversion: '+ country);
                    country='Canada';
            }
            console.log('Country: '+country);
                localStorage.setItem("UserCountry", country);
                if (this.UserType == 'Agent') {
                    this.isAgent = true;
                }
            }
        }
    //--------------------------------------------------

    @wire(MessageContext)
    messageContext;

    // Encapsulate logic for Lightning message service subscribe and unsubsubscribe
    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                recordSelected,
                (message) => this.handleMessage(message),
                { scope: APPLICATION_SCOPE }
            );
        }
    }

    handleMessage(message) {
        this.selectedID = message.recordId;

        console.log('QuickLinks - Account ID passed from Component: '+this.selectedID);

    }

    quickStockLink(){

        //console.log('HREF ID: '+e.target.id);

        window.location.href="/DefaultStore/ccrz__ProductList?categoryId=a763j000000DU7kAAG";
    }

    quickConfigLink(){

        //console.log('HREF ID: '+e.target.id);

        window.location.href="/DefaultStore/ccrz__ProductList?categoryId=a762F0000009wXWQAY";
    }

    prolineLink(){

        //console.log('HREF ID: '+e.target.id);

        window.location.href="/DefaultStore/ccrz__ProductList?categoryId=a763j000000DU7lAAG";
    }

    connectedCallback() {
        this.getUserPermissions();
        this.subscribeToMessageChannel();
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

    saveCartLink() {
        console.log('SaveCartLink');
        // console.log('HREF ID: '+e.target.id);
        // let cartId = await getActiveCart();
        // console.log('Cart Id: '+cartId);
        // var remoteCall = _.extend(CCRZ.RemoteInvocation, { className: 'ReorderHelper' });
        // remoteCall.invokeContainerLoadingCtx($('.deskLayout'), 'getActiveCart', (res, err)  => {
        //     if (res.success) {
        //         console.log("response: " + res);
        //     } else {
        //         console.log("response else");
        //             }
        //         }, {
        //             nmsp: false, escape: false
        //         });
        window.location.href="/DefaultStore/ccrz__MyAccount?viewState=viewAccount&effectiveAccount="+this.selectedID+"&cclcl=en_US";
    }

    priceAgreementLink() {
        const priceAgreementUrl = this.baseURL+'/s/price-agreements'
        window.open(priceAgreementUrl, '_self');
    }

    leadTimesLink(){
        const leadTimesURL = 'https://myconnect.gecurrent.com/s/Current-Family-Estimate-Leadtime.pdf';
        window.open(leadTimesURL, '_self');
    }

    openContactUs(){
        this.contactUsModal = true;
    }

    closeContactUs(){
        this.contactUsModal = false;
    }

}