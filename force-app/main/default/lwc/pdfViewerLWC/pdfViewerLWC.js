import {LightningElement, api} from 'lwc';

export default class PdfViewerLwc extends LightningElement {

    @api set base64Pdf(value){
        console.log(`value`,value);
        let f = this.template.querySelector('.pdfFrame');
        f.contentWindow.postMessage(value,'*');
    }
}