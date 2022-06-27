import {LightningElement, api} from 'lwc';
import {convertBase64StringToBlob, convertBase64StringToPDFBlob} from "c/converter";

export default class FileViewerModal extends LightningElement {

    @api src;
    modal;
    backdrop;
    hasRendered = false;

    renderedCallback() {
        console.log(`this.src`,this.src);
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
        if (this.src != null) {
            this.modal.classList.add('slds-fade-in-open');
            this.backdrop.classList.add('slds-backdrop_open');
        }
    }

    closeModal() {
        this.modal.classList.remove('slds-fade-in-open');
        this.backdrop.classList.remove('slds-backdrop_open');
        this.src = null;
    }

}