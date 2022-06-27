/**
 * Created on 2021. 02. 16..
 */

 import {LightningElement, track, wire } from 'lwc';
 import { getRecord } from 'lightning/uiRecordApi';
 import hasCreateCase from '@salesforce/customPermission/Create_Community_Cases'
 import USER_ID from '@salesforce/user/Id';
 //import NAME_FIELD from '@salesforce/schema/User.Name';
 //import CITY_FIELD from '@salesforce/schema/User.City';
 import PROFILE_FIELD from '@salesforce/schema/User.ProfileId';
 import MANAGE_CONTENT_FIELD from '@salesforce/schema/User.Manage_Community_Content__c';
 import getUserType from '@salesforce/apex/communityOpenClass.getUserType';
 import getUserPerMissionSet from '@salesforce/apex/communityOpenClass.getUserPerMissionSet';
 import getUserProfile from '@salesforce/apex/communityOpenClass.getUserProfile';

 
 
 export default class CommunityMenu extends LightningElement {
 
     @track sitePage = true;
     @track profile;
     @track manageContent;
     @track SysAdmin = false;
     @track showCaseTypes = false;
     @track isAgent = false;
     @track userType;
     @track serviceLink;
     @track showPricing = true;
     @track showCreateClaimback = true;
     @wire(getRecord, {
         recordId: USER_ID, 
         fields: [PROFILE_FIELD, MANAGE_CONTENT_FIELD]
     }) wireuser({
         error,
         data
     }) {
         if (error) {
         this.error = error ; 
         } else if (data) {
             //this.influencer = data.fields.Name.value;
             //this.influencerCity = data.fields.City.value;
             //this.influencerState = data.fields.State.value;
             this.profile = data.fields.ProfileId.value;
             this.manageContent = data.fields.Manage_Community_Content__c.value;
             console.log('Manage Content: '+this.manageContent);
             console.log('Profile Returned: '+this.profile);
            
                    if(this.manageContent == true){
                        this.SysAdmin = true;
                    } else{
                        this.SysAdmin = false;
                        //this.checkPermissions();
                
                    }
            
            
         }
     }
 
     connectedCallback() {
 
         var siteURL = window.location.href;
         if (siteURL == 'https://stage-gecurrent.cs91.force.com/s/login/SelfRegister') {
             this.sitePage = false;
         } else {
             this.sitePage = true;
         }
         
          this.checkPermissions();
          this.getUserPermissions();
          this.getUserType();

          let agentID = sessionStorage.getItem('AgentID');
          console.log("AgentId:"+agentID);
          this.serviceLink = "/s/cases?id=" + agentID;
          console.log("AgserviceLinkentId:"+this.serviceLink);

 
 
     }

     async connectHomeLoad() {
         
        var baseURL = window.location.origin
        this.sfdcOrgURL = baseURL+'/s';
        console.log(this.sfdcOrgURL);
        window.open(this.sfdcOrgURL, "_self");

     }
     
 
     checkPermissions(){
         if(hasCreateCase == true){
             this.showCaseTypes = true;
         } else {
             this.showCaseTypes = false;
         }
     }

     /*
     * Get LoggedIn user User Type
     */
     getUserType() {
         getUserType({UserId: USER_ID})
         .then(result => {
            this.userType = result;
            if(this.userType == 'Agent') {
                this.isAgent = true;
            }
         })
         .catch(error => {
            console.log("getUserType Error : ", error);
            this.error = error ;
         });
     }

     getUserPermissions() {

        var permissionSets = [];
    
        getUserPerMissionSet({UserId: USER_ID})
    
        .then(result => {
    
            permissionSets = result;
    
            console.log("permissionSets: ", permissionSets);
    
            getUserProfile({UserId: USER_ID})
    
            .then(result1 => {
    
                console.log("User Profile Name: ", result1);
    
                var userPermissionData = {profileName: result1, permissionSet: permissionSets};
    
                localStorage.setItem("UserPermission", JSON.stringify(userPermissionData));
    
     
    
                if (result1 == "Agent Read Only B2B Storefront Registered Users" || result1 == "Distributor Read Only B2B Storefront Registered Users") {
    
                    if (permissionSets.includes("View_PLP_and_PDP_Prices") == false) {
    
                        this.showPricing = false;
    
                    }
    
     
    
                    if (permissionSets.includes("Distributor_Case_Management") == false) {
    
                        this.showCreateClaimback = false;
    
                    }
    
                } else if(result1 == "Distributor B2B Storefront Registered Users") {
    
                    this.showCreateClaimback = true;
    
                } else {
    
                    this.showCreateClaimback = false;
    
                }
    
            });
    
        });
    
    }

        async searchOrders(event){
            var baseURL = window.location.origin;
            this.sfdcOrgURL = baseURL+'/s/orders';
            console.log(this.sfdcOrgURL);
            window.open(this.sfdcOrgURL, "_self");
        }
    
        async newSpecReg(event){
            var baseURL = window.location.origin;
            this.sfdcOrgURL = baseURL+'/s/new-spec-registration';
            console.log(this.sfdcOrgURL);
            window.open(this.sfdcOrgURL, "_self");
        }
    
        async markCol(event){
            var baseURL = window.location.origin;
            this.sfdcOrgURL = baseURL+'/s/marketing-collateral';
            console.log(this.sfdcOrgURL);
            window.open(this.sfdcOrgURL, "_self");
        }
    
        async prIn(event){
            var baseURL = window.location.origin;
            this.sfdcOrgURL = baseURL+'/s/pricing-request';
            console.log(this.sfdcOrgURL);
            window.open(this.sfdcOrgURL, "_self");
        }
    
        async chReq(event){
            var baseURL = window.location.origin;
            this.sfdcOrgURL = baseURL+'/s/change-request';
            console.log(this.sfdcOrgURL);
            window.open(this.sfdcOrgURL, "_self");
        }
    
        async expOrd(event){
            var baseURL = window.location.origin;
            this.sfdcOrgURL = baseURL+'/s/expedite';
            console.log(this.sfdcOrgURL);
            window.open(this.sfdcOrgURL, "_self");
        }
    
        async ret(event){
            var baseURL = window.location.origin;
            this.sfdcOrgURL = baseURL+'/s/return-replace';
            console.log(this.sfdcOrgURL);
            window.open(this.sfdcOrgURL, "_self");
        }
        async techser(event){
            var baseURL = window.location.origin;
            this.sfdcOrgURL = baseURL+'/s/technical-service';
            console.log(this.sfdcOrgURL);
            window.open(this.sfdcOrgURL, "_self");
        }
    
        async stockAcc(event){
            var baseURL = window.location.origin;
            this.sfdcOrgURL = baseURL+'/s/stock-balancing-return';
            console.log(this.sfdcOrgURL);
            window.open(this.sfdcOrgURL, "_self");
        }
    
        async clBack(event){
            var baseURL = window.location.origin;
            this.sfdcOrgURL = baseURL+'/s/claim-back';
            console.log(this.sfdcOrgURL);
            window.open(this.sfdcOrgURL, "_self");
        }
    
        async clSea(event){

            var baseURL = window.location.origin;
        
            this.sfdcOrgURL = baseURL+'/s/claim-search';
        
            console.log(this.sfdcOrgURL);
        
            window.open(this.sfdcOrgURL, "_self");
        
        } 
    
        async adjCre(event){
            var baseURL = window.location.origin;
            this.sfdcOrgURL = baseURL+'/s/adjustments';
            console.log(this.sfdcOrgURL);
            window.open(this.sfdcOrgURL, "_self");
        }
    
        async waCla(event){
            var baseURL = window.location.origin;
            this.sfdcOrgURL = baseURL+'/s/warranty-claim';
            console.log(this.sfdcOrgURL);
            window.open(this.sfdcOrgURL, "_self");
        }
    
        async newProd(event){
            var baseURL = window.location.origin;
            this.sfdcOrgURL = baseURL+'/s/assets?type=newproducts';
            console.log(this.sfdcOrgURL);
            window.open(this.sfdcOrgURL, "_self");
        }
    
        async markProm(event){
            var baseURL = window.location.origin;
            this.sfdcOrgURL = baseURL+'/s/assets?type=marketing-and-promotions';
            console.log(this.sfdcOrgURL);
            window.open(this.sfdcOrgURL, "_self");
        }
    
        async train(event){
            var baseURL = window.location.origin;
            this.sfdcOrgURL = baseURL+'/s/assets?type=training';
            console.log(this.sfdcOrgURL);
            window.open(this.sfdcOrgURL, "_self");
        }
    
        async web(event){
            var baseURL = window.location.origin;
            this.sfdcOrgURL = baseURL+'/s/assets?type=webinar';
            console.log(this.sfdcOrgURL);
            window.open(this.sfdcOrgURL, "_self");
        }
    
        async news(event){
            var baseURL = window.location.origin;
            this.sfdcOrgURL = baseURL+'/s/assets?type=news';
            console.log(this.sfdcOrgURL);
            window.open(this.sfdcOrgURL, "_self");
        }
    
        async tools(event){
            var baseURL = window.location.origin;
            this.sfdcOrgURL = baseURL+'/s/assets?type=tools';
            console.log(this.sfdcOrgURL);
            window.open(this.sfdcOrgURL, "_self");
        }
    
        async quStock(event){
            var baseURL = window.location.origin;
            this.sfdcOrgURL = baseURL+'/s/underconstruction';
            console.log(this.sfdcOrgURL);
            window.open(this.sfdcOrgURL, "_self");
        }
    
        async cusList(event){
            var baseURL = window.location.origin;
            this.sfdcOrgURL = baseURL+'/s/customer-list';
            console.log(this.sfdcOrgURL);
            window.open(this.sfdcOrgURL, "_self");
        }
    
        async svCart(event){
            var baseURL = window.location.origin;
            this.sfdcOrgURL = baseURL+'/DefaultStore/ccrz__MyAccount?viewState=viewAccount';
            console.log(this.sfdcOrgURL);
            window.open(this.sfdcOrgURL, "_self");
        }
    
        async prAgree(event){
            var baseURL = window.location.origin;
            this.sfdcOrgURL = baseURL+'/s/price-agreements';
            console.log(this.sfdcOrgURL);
            window.open(this.sfdcOrgURL, "_self");
        }
    
        async orderNew(event){
            var baseURL = window.location.origin;
            this.sfdcOrgURL = baseURL+'/s/orders';
            console.log(this.sfdcOrgURL);
            window.open(this.sfdcOrgURL, "_self");
        }
 
     async Overage(event) {
         
         var baseURL = window.location.origin
         this.sfdcOrgURL = baseURL+'/s/shipping-discrepancy'+'?type=Overage';
         console.log(this.sfdcOrgURL);
         window.open(this.sfdcOrgURL, "_self");
 
 
 }

 
 async Shortage(event) {
         
     var baseURL = window.location.origin
     this.sfdcOrgURL = baseURL+'/s/shipping-discrepancy'+'?type=Shortage';
     console.log(this.sfdcOrgURL);
     window.open(this.sfdcOrgURL, "_self");
 
 
 }
 
 async Lost(event) {
         
     var baseURL = window.location.origin
     this.sfdcOrgURL = baseURL+'/s/shipping-discrepancy'+'?type=Lost';
     console.log(this.sfdcOrgURL);
     window.open(this.sfdcOrgURL, "_self");
 
 
 }
 
 async LDR(event) {
     var requestURL = window.location.href;    
     var baseURL = window.location.origin
     this.sfdcOrgURL = baseURL+'/s/lighting-design'+'?requestURL='+requestURL;
     console.log(this.sfdcOrgURL);
     window.open(this.sfdcOrgURL, "_self");
 
 
 }
 
 async When(event) {
     var requestURL = window.location.href;    
     var baseURL = window.location.origin
     this.sfdcOrgURL = baseURL+'/s/when-can-i-get-it'+'?requestURL='+requestURL;
     console.log(this.sfdcOrgURL);
     window.open(this.sfdcOrgURL, "_self");
 
 
 }
 
 async Support(event) {
     var requestURL = window.location.href;    
     var baseURL = window.location.origin
     this.sfdcOrgURL = baseURL+'/s/connect-platform-support'+'?requestURL='+requestURL;
     console.log(this.sfdcOrgURL);
     window.open(this.sfdcOrgURL, "_self");
 
 
 }





 
 }