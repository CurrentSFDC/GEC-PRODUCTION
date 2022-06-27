import { LightningElement, track, api, wire } from 'lwc';
import updateContactInfo from '@salesforce/apex/communityOpenClass.updateContactInfo';
import loggedInAsUserCheck from '@salesforce/apex/communityOpenClass.loggedInAsUserCheck';
import {getRecord} from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import CONTACT_FIELD from '@salesforce/schema/User.ContactId';
import ACCOUNT_FIELD from '@salesforce/schema/User.AccountId';
import PROFILE_FIELD from '@salesforce/schema/User.ProfileId';
import NAME_FIELD from '@salesforce/schema/User.Name';
import UserType from '@salesforce/schema/User.User_Type__c';
import PROFILE_PHOTO from '@salesforce/schema/User.FullPhotoUrl';
export default class CommunityUserProfileMenu extends LightningElement {

@track impersonate = false;
@track userID;
@track userPhoto;
@track sfdcOrgURL;
@track contactName;
@track contactID;

loggedInAsUserBool;

    @wire( loggedInAsUserCheck )  
    wiredData( value ) {

        const { data, error } = value;

        if ( data || data === false ) {
                            
            console.log( 'Data received from Apex ' + JSON.stringify( data ) );
            this.loggedInAsUserBool = data;
            if(this.loggedInAsUserBool == true){
                this.impersonate = true;
            } else {
                this.impersonate = false;
            }
           
            
            /*connectLogins({contactId : this.contactID})
                .then(result => {
                    
                        console.log('REGISTERED LOGIN FOUND: '+JSON.stringify(result));
                        if(result.length > 0){
                            
                            //localStorage.setItem('Impersonate', true);
                            let internalName = result[0].Delegated_User__r.Name;
                            let internalUserName = result[0].Delegated_User__r.Username;
                            let internalUserPhone = result[0].Delegated_User__r.Phone;
                            localStorage.setItem('internalName', internalName);
                            localStorage.setItem('internalUserName', internalUserName);
                            localStorage.setItem('internalUserPhone', internalUserPhone);
                        } else {
                           // this.impersonate = false;
                        }
                    });*/


        } else if ( error ) {

            console.error( JSON.stringify( error ) );
            
        }

    }


// GET CURRENT LOGGED IN COMMUNITY USER INFORMATION
@wire(getRecord, {

    recordId: USER_ID,
    fields: [CONTACT_FIELD, ACCOUNT_FIELD, UserType, PROFILE_FIELD, PROFILE_PHOTO, NAME_FIELD]
}) wireuser({
                error,
                data
            }) {
    if (error) {
        this.error = "NO DATA";
        console.log('ERROR: ' + this.error);
    } else if (data) {
        let isInternal = localStorage.getItem('internalName');
        if(isInternal != null){
            this.impersonate = true;
        } else {
            this.impersonate = false;
        }


        console.log('LOAD STEP 1 - WIRE METHOD...');
        this.contactID = data.fields.ContactId.value;
        this.userID = USER_ID;
        this.userPhoto = data.fields.FullPhotoUrl.value;
        this.contactName = data.fields.Name.value;
        console.log('Setting Contact ID: ' + this.contactID);
        localStorage.setItem('userID', USER_ID);
        localStorage.setItem('userPhoto', data.fields.FullPhotoUrl.value);
        localStorage.setItem('contactName', data.fields.Name.value);
    }
    }





async connectedCallback(){
    let isInternal = localStorage.getItem('internalName');
    /*this.userID = localStorage.getItem('userID');
    this.userPhoto = localStorage.getItem('userPhoto');
    this.contactID = localStorage.getItem('ContactID');
    this.contactName = localStorage.getItem('contactName');*/

    if(isInternal != null){
        this.impersonate = true;
    } else {
        this.impersonate = false;
    }
}


/*async renderedCallback(){
    let isInternal = localStorage.getItem('internalName');

    if(isInternal != null){
        this.impersonate = true;
    } else {
        this.impersonate = false;
    }
}*/

goHome(event){
    var baseURL = window.location.origin;
    console.log('Base URL: '+baseURL);
    this.sfdcOrgURL = baseURL+'/s/';
    console.log('New URL: '+this.sfdcOrgURL);
    window.open(this.sfdcOrgURL, "_self");
}

goProfile(event){
    var baseURL = window.location.origin;
    console.log('Base URL: '+baseURL);
    this.sfdcOrgURL = baseURL+'/s/profile/'+this.userID;
    console.log('New URL: '+this.sfdcOrgURL);
    window.open(this.sfdcOrgURL, "_self");
}

goSettings(event){
    var baseURL = window.location.origin;
    console.log('Base URL: '+baseURL);
    this.sfdcOrgURL = baseURL+'/s/settings/'+this.userID;
    console.log('New URL: '+this.sfdcOrgURL);
    window.open(this.sfdcOrgURL, "_self");
}

handleNormalLogout(){
    var baseURL = window.location.origin;
    console.log('Base URL: '+baseURL);
    


    var newURL = baseURL + '/secur/logout.jsp?retUrl=' + baseURL;
   
        console.log('Item Modified');
        //window.location.replace("https://stage-gecurrent.cs91.force.com/Agents/secur/logout.jsp?retUrl=https%3A%2F%2Fstage-gecurrent.cs91.force.com%2FAgents%2FCommunitiesLanding");
        window.location.replace(newURL)
    

}

async handleLogout(){
    
    var baseURL = window.location.origin;
    console.log('Base URL: '+baseURL);
    
    let updateContact = {'sobjectType': 'Contact'};
    updateContact.Id = this.contactID;
    updateContact.Impersonate_Mode__c = false;

    var newURL = baseURL + '/secur/logout.jsp?retUrl=' + baseURL;
    await updateContactInfo({data : updateContact})
    .then(result => {
        console.log('Item Modified');
        localStorage.clear();
        //window.location.replace("https://stage-gecurrent.cs91.force.com/Agents/secur/logout.jsp?retUrl=https%3A%2F%2Fstage-gecurrent.cs91.force.com%2FAgents%2FCommunitiesLanding");
        window.location.replace(newURL);
    })
}

}