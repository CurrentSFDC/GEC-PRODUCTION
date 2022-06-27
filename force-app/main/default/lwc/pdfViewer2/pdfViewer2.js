import {LightningElement,api} from 'lwc';

export default class PdfViewer2 extends LightningElement {

    @api get base64Pdf(){

    }

    set base64Pdf(value) {
        try{
            if(value){
                console.log(`value`,value);
                let f = this.template.querySelector('.pdfFrame');
                f.contentWindow.postMessage(value,'*');
            }
        }
        catch(error){
            console.error(error);
        }
    }
}