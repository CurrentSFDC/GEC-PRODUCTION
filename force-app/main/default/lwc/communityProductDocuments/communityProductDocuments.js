/**
 * 2021-02-12.
 */

import {LightningElement, wire, api} from 'lwc';
import RefToNewspng from '@salesforce/contentAssetUrl/RefToNewspng';
import sendFilesInEmail from '@salesforce/apex/CommunityProductDetailController.sendFilesInEmail';
import {getRecord} from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import EMAIL_FIELD from '@salesforce/schema/User.Email';
import getPdfDownloadLink from '@salesforce/apex/communityOpenClass.getPdfDownloadLink';

export default class CommunityProductDocuments extends LightningElement {

    @api productDocuments;
    @api title;
    documentSections;
    userEmail;

    @wire(getRecord, {recordId: USER_ID, fields: [EMAIL_FIELD]})
    onRecordLoad({error, data}) {
        if (error) {
            console.error(error);
        } else if (data) {
            this.userEmail = data.fields.Email.value;
        }
    }

    async connectedCallback() {
        console.log(`CommunitySalesKits productDocuments`, JSON.parse(JSON.stringify(this.productDocuments)));
        let map = new Map();
        for (const productDocument of this.productDocuments) {
            if (!map.has(productDocument.Type__c)) {
                map.set(productDocument.Type__c, [Object.assign({},productDocument)]);
            } else {
                map.get(productDocument.Type__c).push(Object.assign({},productDocument));
            }
        }
        this.documentSections = [];
        for (const key of map.keys()) {
            this.documentSections.push(
                {
                    sectionName: key,
                    documents: map.get(key)
                }
            )
        }

        for (const documentSection of this.documentSections) {
            for (const document of documentSection.documents) {
                Object.setPrototypeOf(document, this.documentProto);
                document.setDocumentSelected = function (event) {
                    document.isSelected = event.currentTarget.checked;
                    console.log('Selected Document(s): '+document.isSelected);
                };
            }
        }
        this.documentSections = [...this.documentSections];
        console.log(`this.documentSections`, this.documentSections);
    }

    documentProto = {
        isSelected: false,
        get source() {
            //return '/file-asset/' + this.Content_Id__c;
            return this.File_URL__c;
        }
    }

    selectAllFiles(event) {
        for (const documentSection of this.documentSections) {
            for (const document of documentSection.documents) {
                document.isSelected = event.detail.checked;
            }
        }
        this.documentSections = [...this.documentSections];
    }

    downloadSelectedFiles(event) {
        var contentDocumentsId = [];
        var loadingEvent = new CustomEvent("isloading", {
            detail: true
        });
        this.dispatchEvent(loadingEvent);
        try {
            for (const documentSection of this.documentSections) {
                for (const contentDocument of documentSection.documents) {
                    if (contentDocument.isSelected === true && contentDocument.File_URL__c !== undefined) {
                        if(null != contentDocument.Content_Id__c && contentDocument.Content_Id__c != undefined){
                            contentDocumentsId.push(contentDocument.Content_Id__c);
                        }
                    }
                }
            }
            
            console.log('contentDocumentsId: '+contentDocumentsId);
            getPdfDownloadLink({contentDocumentsId: contentDocumentsId}).then(result => {
                loadingEvent = new CustomEvent("isloading", {
                    detail: false
                });
                this.dispatchEvent(loadingEvent);
                if (result.length > 0) {
                    for(const link of result){
                        console.log('Download URL: '+link.ContentDownloadUrl);
                        let a = document.createElement("a");
                        a.setAttribute('href', link.ContentDownloadUrl);
                        a.setAttribute('download', '');
                        a.setAttribute('target', '_blank');
                        a.click();
                        a.remove();
                    }
                }
            });
        } catch (error) {
            console.error(error);
        }
    }

    openEmailModal() {
        this.template.querySelector('.slds-modal').classList.add('slds-fade-in-open');
        this.template.querySelector('.slds-backdrop').classList.add('slds-backdrop_open');
        this.template.querySelector('.slds-modal lightning-input').focus();
        window.addEventListener('keyup', this.modalEventListener);
    }

    async sendSelectedFilesInEmail() {
        try {
            let input = this.template.querySelector('.slds-modal lightning-input');
            if (input.reportValidity() === false) {
                return;
            }
            let documentIds = [];
            for (const documentSection of this.documentSections) {
                for (const document of documentSection.documents) {
                    if (document.isSelected === true) {
                        documentIds.push(document.Id);
                    }
                }
            }
            if (documentIds.length > 0) {
                await sendFilesInEmail({contentDocumentIds: documentIds, targetEmail: input.value});

            }
        } catch (error) {
            console.error(error);
        }
    }

    closeEmailModal() {
        this.template.querySelector('.slds-modal').classList.remove('slds-fade-in-open');
        this.template.querySelector('.slds-backdrop').classList.remove('slds-backdrop_open');
        window.removeEventListener('keyup', this.modalEventListener);
    }

    modalEventListener = function (event) {
        try {
            switch (event.key) {
                case "Enter": {
                    this.sendSelectedFilesInEmail();
                    break;
                }
                case "Escape": {
                    this.closeEmailModal();
                    break;
                }

            }
        } catch (error) {
            console.error(error);
        }
    }.bind(this)
}