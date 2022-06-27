import { LightningElement, api, track } from 'lwc';

export default class Paginator extends LightningElement {

    @api totalPages;
    @api currentPage;

    @track showPrevious = false;
    @track showNext = false;

    @api setButtons(inputData){
        console.log('Executing Button Logic...');
        this.totalPages = inputData.totalPages;
        this.currentPage = inputData.currentPage;

        if(this.totalPages > 1){
            this.showNext = true;
        } else {
            this.showNext = false;
            this.showPrevious = false;
        }

        if(this.totalPages > 1 && this.currentPage > 1){
            this.showPrevious = true;
        } else {
            this.showPrevious = false;
        }

    };

    connectedCallback(){
        if(this.totalPages > 1){
            this.showNext = true;
        } else {
            this.showNext = false;
            this.showPrevious = false;
        }

        if(this.totalPages > 1 && this.currentPage > 1){
            this.showPrevious = true;
        } else {
            this.showPrevious = false;
        }
    }


    previousHandler() {
        this.dispatchEvent(new CustomEvent('previous'));
    }

    nextHandler() {
        this.dispatchEvent(new CustomEvent('next'));
    }
}