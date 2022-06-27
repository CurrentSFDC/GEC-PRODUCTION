import {
    LightningElement,
    track,
    wire,
    api
} from 'lwc';
 
import getTimeTrackers from '@salesforce/apex/CaseTimeTracking.getTimeTrackers';
export default class Cssexample extends LightningElement {
    @track timetrackers;
    @track errors;
    @api recordId
    @wire(getTimeTrackers, { caseId: '$recordId' })
    wireAllAccs({
        error,
        data
    }) {
        if (data) {
            this.timetrackers = data;
        } else {
            this.error = error;
        }
    }
}