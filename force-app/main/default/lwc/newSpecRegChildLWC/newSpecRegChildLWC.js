import { LightningElement , api, track } from 'lwc';
import getAccName from '@salesforce/apex/connectCreateCase.getAccountName';

export default class NewSpecRegChildLWC extends LightningElement {
    @api jobName;
    @api jobCity;
    @api jobState;
    @api influencerState;
    @api specifyingAgencyRole;
    @api commentsl
    @api influencer;
    @api influencerCity;
    @api influencerRole;
   // @api influencerState;
    @api sku;
    @api materialDesc;    
    @api quantitySelected;
    @api estimatedSalesPrice;
    @api accountID;
    @api delAgency;
    @api orderingAgency;
    @api estimatedBiddingStartDate;
    @api estimatedBiddingEndDate;
    @api _data;
    @track accountName;
    @track accountName1;
    @track accountName2;
    

    @api setConfirmValues(inputData){
        this.accountID=inputData.AccountID;
        getAccName({id_dtl: this.accountID})
        .then(result => {
        this.accountName = result;
        console.log(JSON.stringify("The Result for Case Number: "+ JSON.stringify(this.accountName)))
        });
        this.orderingAgency=inputData.OrderingAgency;
        getAccName({id_dtl: this.orderingAgency})
        .then(result => {
        this.accountName1 = result;
        console.log(JSON.stringify("The Result for Case Number: "+ JSON.stringify(this.accountName1)))
        });
        this.delAgency=inputData.DeliveryAgency;
        getAccName({id_dtl: this.delAgency})
        .then(result => {
        this.accountName2 = result;
        console.log(JSON.stringify("The Result for Case Number: "+ JSON.stringify(this.accountName2)))
        });
        this.jobName=inputData.JobName;
        this.jobCity=inputData.JobCity;
        this.jobState=inputData.JobStateInput;        
        this.comments=inputData.Comments;
        this.estimatedBiddingStartDate=inputData.EstimatedBiddingStartDate;
        this.estimatedBiddingEndDate=inputData.EstimatedBiddingEndDate;
        this.specifyingAgencyRole=inputData.SpecifyingAgencyRole;
        this.influencer=inputData.Influencer;
        this.influencerCity=inputData.InfluencerCity;
        this.influencerRole=inputData.InfluencerRole;
       // this.influencerState=inputData.InfluencerState;
        this.estimatedSalesPrice=inputData.EstimatedSalesPrice;
        this.influencerState=inputData.InfluencerStateInput;
      

    };

}