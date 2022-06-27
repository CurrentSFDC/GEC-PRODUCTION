import { LightningElement, api, track, wire } from 'lwc';
import getDisputeRequests from '@salesforce/apex/connectCreateCase.getDisputeRequests';
import getAllDisputeProducts from '@salesforce/apex/connectCreateCase.getAllDisputeProducts';



export default class DisputeRequests extends LightningElement {

    @api recordId;
    @track disputes;
    @track disputeID;
    @track disputeProducts = [];
    @track sapOrder;

    @track columns = [
        {
            label: 'CATALOG #',
            fieldName: 'Material_Description__c', 
            //initialWidth: 20,
            type: 'text',
            sortable: true
        },
        {
            label: 'SKU',
            fieldName: 'SAP_Material__c', 
            //initialWidth: 20,
            type: 'text',
            sortable: true
        },
        {
            label: 'INVOICED PRICE',
            fieldName: 'Invoiced_Price__c', 
            //initialWidth: 20,
            type: 'currency',
            sortable: true,
            cellAttributes:{
                alignment: 'left'
            }
        },
        {
            label: 'QUANTITY',
            fieldName: 'Discrepancy_Qty__c', 
            //initialWidth: 20,
            type: 'number',
            sortable: true,
            cellAttributes:{
                alignment: 'left'
            }
        },
        {
            label: 'TOTAL',
            fieldName: 'Discrepancy_Total__c', 
            //initialWidth: 20,
            type: 'currency',
            sortable: true,
            cellAttributes:{
                alignment: 'left'
            }
        },
        {
            label: 'TYPE',
            fieldName: 'GE_NAS_Type_of_Problem1__c', 
            //initialWidth: 20,
            type: 'text',
            sortable: true,
            cellAttributes:{
                alignment: 'left'
            }
        }
     ];

    @wire(getDisputeRequests, {caseId: '$recordId'}) 
    wiredDisputes({
        error,
        data
    }) {
        if (data) {
            this.disputes = data;
            this.disputeProducts = data[0].Case_Products__r ;
            console.log('Data Returned: '+JSON.stringify(this.disputes));
            
            
        } else if (error) {
            this.error = error;
        }
    }

    handleSelected(event){
        this.disputeID = event.currentTarget.dataset.id;
        console.log('Selected Dispute ID: '+this.disputeID);
        /*getAllDisputeProducts({disputeID: this.disputeID})
        .then(result => {
            this.disputeProducts = result;
        })*/
        console.log('Products Returned: '+JSON.stringify(this.disputeProducts)); 
    }



}