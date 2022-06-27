import {LightningElement, wire, track} from 'lwc';
import getCommunityContent from '@salesforce/apex/CommunityContentController.getCommunityContent';
import {sortData, getURLParameters} from "c/util";
import logo from '@salesforce/contentAssetUrl/MicrosoftTeamsimage_1png';


export default class CommunityContentTable extends LightningElement {

    @track communityContentRecords = [];
    @track URL;
    @track contentID;
    @track personaType;
    @track header;
    @track videoModal = false;
    @track videoSrc;
    @track recordName;
    @track recordDescription;
    @track recordType;
    sorter = {
        direction: 'asc',
        fieldName: '',
        activeTh: null,
    }
    logo = logo;


    @wire(getCommunityContent, {urlParameters: getURLParameters()})
    onLoad({data, error}) {
        if (data) {
            this.communityContentRecords = data;
        }
        if (error) {
            console.error(error);
        }
    }

    connectedCallback() {
        let urlParameters = getURLParameters();
        console.log('URL PARAMETERS: '+JSON.stringify(urlParameters));
        if(urlParameters.type){
            let type = urlParameters.type.toLowerCase();
            if(type === 'training'){
                this.header = 'Training'
            }
            if(type === 'marketing-and-promotions'){
                this.header = 'Marketing & Promotions'
            }
            if(type === 'webinar'){
                this.header = 'Webinars'
            }
            if(type === 'news'){
                this.header = 'News'
            }
            if(type === 'newproducts'){
                this.header = 'New Product Introduction'
            }
            if(type === 'connect-training'){
                this.header = 'Connect Training Library'
            }
            if(type === 'tools'){
                this.header = 'Connect Tools'
            }
        }
    }

    get typeSortDirectionArrow() {
        return this.sorter.fieldName !== 'Content_Type__c' || this.sorter.direction === 'asc' ? 'utility:arrowup' : 'utility:arrowdown';
    }

    get titleSortDirectionArrow() {
        return this.sorter.fieldName !== 'Title__c' || this.sorter.direction === 'asc' ? 'utility:arrowup' : 'utility:arrowdown';
    }

    get descriptionSortDirectionArrow() {
        return this.sorter.fieldName !== 'Description__c' || this.sorter.direction === 'asc' ? 'utility:arrowup' : 'utility:arrowdown';
    }

    get dateSortDirectionArrow() {
        return this.sorter.fieldName !== 'Display_Date__c' || this.sorter.direction === 'asc' ? 'utility:arrowup' : 'utility:arrowdown';
    }

    sort(event) {
        if(event.currentTarget !== this.sorter.activeTh){
            if(this.sorter.activeTh){
                this.sorter.activeTh.classList.remove('active');
            }
            this.sorter.activeTh = event.currentTarget;
            this.sorter.activeTh.classList.add('active');
            this.sorter.direction = 'asc';
            this.sorter.fieldName = event.currentTarget.dataset.sortBy;
        }
        else{
            this.sorter.direction = this.sorter.direction === 'asc' ? 'desc' : 'asc';
        }
        this.communityContentRecords = sortData(JSON.parse(JSON.stringify(this.communityContentRecords)), this.sorter.fieldName, this.sorter.direction)
    }

    openLink(event){
        console.log('Header: '+this.header);
        
        if(this.header == "New Product Introduction"){
            const row = this.communityContentRecords[event.target.value];
            console.log('ROW: '+row);
            console.log('ROW ID Selected: '+this.communityContentRecords[event.target.value].Id);
            this.contentID = row.Id;
            this.URL = "/s/content?communityContentId="+this.contentID;
        } else if(this.header == "Connect Training Library"){
            const row = this.communityContentRecords[event.target.value];
            console.log('ROW: '+row);
            console.log('ROW ID Selected: '+this.communityContentRecords[event.target.value].Id);
            this.contentID = row.Id;
            this.videoSrc = this.communityContentRecords[event.target.value].Hyperlink__c;
            this.recordName = this.communityContentRecords[event.target.value].Title__c;
            this.recordDescription = this.communityContentRecords[event.target.value].Description__c;
            this.recordType = this.communityContentRecords[event.target.value].Content_Type__c;
            //this.URL = "/Agents/s/content?communityContentId="+this.contentID;
            this.videoModal = true;
        } else {
            this.URL = this.communityContentRecords[event.target.value].Hyperlink__c;
        }
    }

    closeVideoModal(){
        this.videoModal = false;
    }

}