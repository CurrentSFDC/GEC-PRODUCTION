import { LightningElement, api, track } from 'lwc';


export default class ReturnReplaceChildLWC extends LightningElement {

    @api Account;
    @track accountName;
    @api requestorName;
    @api requestorEmail;
    @api requestorPhone;
    @api returnReason;
    @api secondaryReason;
    @api requestedAction;
    @api comments;

    @api setConfirmValues(inputData){
        this.Account=inputData.Account;
        this.requestorName=inputData.RequestorName;
        console.log('Requestor Name to Display: '+ this.requestorName);
        this.requestorEmail=inputData.RequestorEmail;
        this.requestorPhone=inputData.RequestorPhone;
        this.returnReason=inputData.ReturnReason;
        this.requestedAction=inputData.RequestedAction;
        this.secondaryReason=inputData.SecondaryReason;
        this.comments=inputData.Comments;

    };


}