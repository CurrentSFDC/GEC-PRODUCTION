import { LightningElement, api, track } from 'lwc';
import {
    FlowAttributeChangeEvent,
    FlowNavigationNextEvent,
} from 'lightning/flowSupport';

export default class ImpersonateFlowLWC extends LightningElement {

@api impersonateURL;
@track newURL;
@track isLoading = false;
loading = false;
origin = 'https://gecurrent--stage.lightning.force.com';
@track authorized = false;

async onLoad(){
    this.isLoading = true;
    this.template.querySelector('.iframe-container').contentDocument.reload(true);
    const containerElem = this.template.querySelector('.iframe-container');
    
    //this.template.querySelector('iframe').contentWindow.postMessage(this.newURL,window.location.origin);  
    this.isLoading = false;
     
}

launch(event){
    var params = [
        'height='+screen.height,
        'width='+screen.width,
        'fullscreen=yes' // only works in IE, but here for completeness
    ].join(',');
    console.log('Setting URL: '+this.impersonateURL);
    //let myFrame = this.template.querySelector('.iframe-container');
    
        this.authorized = true;
        window.open(this.impersonateURL, 'popup_window', params);
        //this.template.querySelector('.iframe-container').contentDocument.reload(true);
   
    //window.open(this.impersonateURL, "theFrame");
    //this.newURL = this.impersonateURL;
    //this.template.querySelector('iframe').contentWindow.location(this.newURL);
}

/*connectedCallback() {
    this.loading = true;
}

renderedCallback() {
    //const spinnerContainer = this.template.querySelector('.slds-spinner_container');
    const containerElem = this.template.querySelector('.iframe-container');
    const iframe = document.createElement('iframe');
    // onload() before setting 'src'
    iframe.onload = function() {
        console.log('iframe is loaded');
            //spinnerContainer.classList.add("slds-hide"); // hide spinner
            this.loading = false;
    };
    iframe.src = this.impersonateURL; // iFrame src; add this URL to CSP
    iframe.id = 'iframe-1';
    iframe.width = '100%';
    iframe.setAttribute('frameborder', '0');
  
    containerElem.appendChild(iframe); // add iFrame to DOM
}*/

}