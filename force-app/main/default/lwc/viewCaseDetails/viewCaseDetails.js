import { LightningElement,api,track,wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import TYPE_FIELD from '@salesforce/schema/Case.Type';
import SUB_TYPE_FIELD from '@salesforce/schema/Case.GE_NAS_Sub_Type__c';

import getCaseProducts from '@salesforce/apex/connectCreateCase.getCaseProducts';
import getDisputeRequests from '@salesforce/apex/connectCreateCase.getDisputeRequests';
import getDisputeProducts from '@salesforce/apex/connectCreateCase.getDisputeProducts';
import getCaseFields from '@salesforce/apex/connectCreateCase.getCaseFields';
import getCaseComments from '@salesforce/apex/connectCreateCase.getCaseComments';
import createCaseComment from '@salesforce/apex/connectCreateCase.createCaseComment';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

// USED FOR GETTING THE USER DATA - WITHOUT APEX CALL

import USER_ID from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';
import EMAIL_FIELD from '@salesforce/schema/User.Email';
import PHONE_FIELD from '@salesforce/schema/User.Phone';
import CONTACT_FIELD from '@salesforce/schema/User.ContactId';
import ACCOUNT_FIELD from '@salesforce/schema/User.AccountId';

const options = {
    year: 'numeric', month: 'numeric', day: 'numeric',
    hour: 'numeric', minute: 'numeric',
    hour12: true
  };

export default class ViewCaseDetails extends LightningElement {

    @api recordId;
    @track caseType;
    @track caseSubType;
    @track showCommon; // SHOWS THE COMMON FIELDS ACROSS ALL CASE TYPES
    @track isWarranty = false; // WARRANTY CLAIM CASE
    @track isReturns = false; // RETURNS CASE
    @track isSpecReg = false; // SPEC REGISTRATION CASE
    @track isExpedite = false; // EXPEDITE CASE
    @track isChange = false; // CHANGE REQUEST CASE
    @track isShipping = false; // SHORTAGE, OVERAGE, LOST/DAMAGED CASE
    @track isLightingDesign = false; // LIGHTING DESIGN CASE
    @track istechsupp = false;
    @track isCredit = false; // ADJUSTMENTS CASE
    @track isPricing = false; // PRICING REQUEST CASE
    @track isStockBalancing = false; // STOCK BALANCING CASE
    @track isPlatformSupport = false; // CONNECT PLATFORM SUPPORT CASE
    @track isMarketing = false; // MARKETING COLLATERAL CASE
    @track isWhenCanIGet = false; // WHEN CAN I GET IT CASE
    @track sectionID;
    @track currencyCode;

    @track showModal = false; 
    @track productLines = [];

    @track caseNumber;
    @track orderNumber;
    @track orderDelivery;
    @track orderExpected;
    @track orderShip;
    @track caseData;

    //COMMON FIELDS
    @track commonFields = 'CaseNumber, Status, Account.Name, Sold_To_Account__r.Name, eLight_Requestor_Name__c, Requestor_Email__c, eLight_Requestor_Phone__c';
    @track requestorName;
    @track requestorEmail;
    @track requestorPhone;
    @track accountName;
    @track soldToAccountName;

    @track jobName;
    @track location;
    @track contactName;
    @track contactEmail;
    @track contactPhone;
    @track address;
    @track comments;
    @track requestedAction;
    @track orderNumber;


    //LIGHTING APPLICATION FIELDS
    @track appFields = ' Subject, Spec_Reg_Number__c, Application_Type__c, Connect_Desired_Services__c, GE_LGT_Actual_Due_Date__c, eLight_Comments__c, Job_Name__c, Site_Contact_Name__c, Site_Contact_Email__c, Site_Contact_Phone__c,eLight_Address_2__c, Account.Owner.Name';
    @track subject;
    @track specRegNumber;
    @track applicationType;
    @track desiredServicies;
    @track dueDate;
    @track accountManager;


    //RETURN AND SHIPPING DISCREPANCY FIELDS
    @track returnFields = ' Requested_Action__c, eLight_Reason_for_Return__c, eLight_Secondary_Reason_s__c, eLight_Comments__c';
    @track shippingFields = 'Discrepancy__c, Requested_Action__c, eLight_Comments__c';
    @track returnReason;
    @track secondReason;
    @track discrepancy;

    //WARRANTY FIELDS
    @track warrantyFields = 'Requested_Action__c, Warranty_Code__c, Warranty_Sub_Code__c, eLight_Comments__c, Site_Name__c, Site_Contact_Name__c, Site_Contact_Email__c, Site_Contact_Phone__c, eLight_Address_2__c';
    @track warrantyCode;
    @track warrantySubCode;

    //SPEC REGISTRATION FIELDS
    @track specFields = 'Ordering_Agency__C, Delivery_Agency__c,Estimated_bidding_ordering_Start_Date__c,Estimated_bidding_ordering_End_Date__c,Spec_Reg_Agency__r.Name,Ordering_Agency__r.Name,Delivery_Agency__r.Name,Order_Name__r.GE_Order_NO__c,Order_Name__r.Order_Req_Delivery_Date__c, Order_Name__r.Order_Expected_Ship_Date__c, Order_Name__r.Order_Ship_From__c,Job_Name__c,Specifying_Agency_s_Role__c,Job_City__c,Job_State__c,Estimated_Job_Value__c,Influencer__c,Influencer_Role__c,Influencer_City__c,Influencer_State__c';
    @track orderingAgency;
    @track deliverAgency;
    @track specAgency;
    @track estimateBidStart;
    @track estimateBidEnd;
    @track influencerName;
    @track influencerCity;
    @track influenceRole;
    @track influencerState;
    @track specAgencyRole;
    @track jobCity;
    @track jobState;

    //WHEN CAN I GET IT FIELDS
    @track whenFields = 'Questions__c';
    @track questions;

    //PRICING FIELDS
    @track pricingFields = 'Subject, Job_Name__c, Estimated_Job_Value__c, eLight_Comments__c';
    @track estimatedJobValue;

    //CHANGE REQUEST FIELDS
    @track changeFields = 'GE_NAS_Confirmation__c, GE_NAS_Purchase_Order__c'
    @track purchaseOrder;

    //EXPEDITE REQUEST FIELDS
    @track expediteFields = 'Order_Ship_From__c,Order_Expected_Ship_Date__c,GE_NAS_Confirmation__c,Expedite_Reason__c,Ship_Complete_Override__c';
    @track orderDelivery;
    @track orderExpected;
    @track orderShip;
    @track expediteReason;
    @track shipComplete;

    //CREDIT REQUEST FIELDS
    @track creditFields = 'GE_NAS_Invoice__c,GE_NAS_Purchase_Order__c,Discrepancy_Amount__c';
    @track invoiceNumber;
    @track discrepancyAmount;

    //MARKETING COLLATERAL FIELDS
    @track marketingFields = 'Questions__c,Material__c,Material_Category__c,Subject,Job_Name__c,Estimated_Job_Value__c';
    @track material;
    @track materialCategory;


    //CONNECT SUPPORT FIELDS
    @track connectFields = 'Question_Category__c,Question_Sub_Category__c,Questions__c';
    @track questionCategory;
    @track questionSubCategory;

    //STOCK BALANCING FIELDS
    @track stockFields = 'GE_NAS_Purchase_Order__c,eLight_Comments__c';

    //TECHNICAL SERVICE FIELDS
    @track technicalFields = 'Agent_Name__c,Primary_Product_Brand__c,Description,Job_Name__c,Estimated_Job_Value__c,GE_LGT_Actual_Due_Date__c';
    @track agentName;
    @track primaryProduct;
    @track description;


    @track commonColumns = false;
   
    @track testField;
    @track caseComments = [];
    @track showCommentModal = false;
    @track timeStamp;
    @track addingSpinner = false;

    @track disputes;
    @track disputeID;
    @track disputeProducts = [];
    @track sapOrder;
    @track showRequests = false;

    @track caseProducts = [];
    @track showProducts = false;
    @track status;
    @track templist = [];

    @track isSpinner = false;
    @track showRMA = false;

    // COLUMNS FOR CONVERT TO ORDER
    @track columns = [
        {
            label: 'Not In Catalog',
            fieldName: 'No_Cat_Number__c',
            type: 'Text',
            sortable: true
        },
    {
        label: 'Catalog #',
        fieldName: 'Material_Description__c',
        type: 'Text',
        sortable: true,
        cellAttributes: { alignment: 'right' }
    },
    {
        label: 'SKU #',
        fieldName: 'SAP_Material__c',
        type: 'Text',
        sortable: true,
        cellAttributes: { alignment: 'left' }
    },
    {
        label: 'Description',
        fieldName: 'GE_NAS_Comments__c',
        type: 'Text',
        cellAttributes: { alignment: 'right' },
        sortable: true,
        wrapText: true
    },
    {
        label: 'Quantity',
        fieldName: 'Order_Qty__c',
        type: 'Text',
        sortable: true,
        cellAttributes: { alignment: 'left' }
    }
    ];

     // COLUMNS FOR Marketing Collateral
     @track marketingColumns = [
    {
        label: 'Not In Catalog',
        fieldName: 'No_Cat_Number__c',
        type: 'Text',
        sortable: true
    },
    {
        label: 'Catalog #',
        fieldName: 'Material_Description__c',
        type: 'Text',
        cellAttributes: { alignment: 'right' },
        sortable: true
    },
    {
        label: 'SKU #',
        fieldName: 'SAP_Material__c',
        type: 'Text',
        sortable: true,
        cellAttributes: { alignment: 'left' }
    },
    {
        label: 'QTY',
        fieldName: 'Order_Qty__c',
        type: 'text',
        sortable: true,
        cellAttributes: { alignment: 'left' }
    },
    {
        label: 'Comments',
        fieldName: 'GE_NAS_Comments__c',
        type: 'text',
        sortable: true,
        wrapText: true,
        cellAttributes: { alignment: 'right' }
    }
    ];

    // COLUMNS FOR PRICING REQUEST
    @track pricingColumns = [
    {
        label: 'Not In Catalog',
        fieldName: 'No_Cat_Number__c',
        type: 'Text',
        sortable: true
    },
    {
        label: 'Catalog #',
        fieldName: 'Material_Description__c',
        type: 'Text',
        sortable: true,
        cellAttributes: { alignment: 'right' }
    },
    {
        label: 'SKU #',
        fieldName: 'SAP_Material__c',
        type: 'Text',
        sortable: true,
        cellAttributes: { alignment: 'left' }
    },
    {
        label: 'QTY',
        fieldName: 'Order_Qty__c',
        type: 'text',
        sortable: true,
        cellAttributes: { alignment: 'left' }
    }
    ];

    // COLUMNS FOR LIGHTING DESIGN REQUEST
    @track ldrColumns = [
    {
        label: 'Not In Catalog',
        fieldName: 'No_Cat_Number__c',
        type: 'Text',
        sortable: true
    },
    {
        label: 'Catalog #',
        fieldName: 'Material_Description__c',
        type: 'Text',
        sortable: true,
        cellAttributes: { alignment: 'right' }
    },
    {
        label: 'SKU #',
        fieldName: 'SAP_Material__c',
        type: 'Text',
        sortable: true,
        cellAttributes: { alignment: 'left' }
    },
    {
        label: 'QTY',
        fieldName: 'Order_Qty__c',
        type: 'text',
        sortable: true,
        cellAttributes: { alignment: 'left' }
    },
    {
        label: 'Description',
        fieldName: 'GE_NAS_Comments__c',
        type: 'Text',
        sortable: true,
        wrapText: true,
        cellAttributes: { alignment: 'right' }
    },
    ];

  // COLUMNS FOR TECHNICAL SUPPORT
  @track techscuppColumns = [
    {
        label: 'Not In Catalog',
        fieldName: 'No_Cat_Number__c',
        type: 'Text',
        sortable: true
    },
    {
        label: 'Catalog #',
        fieldName: 'Material_Description__c',
        type: 'Text',
        sortable: true,
        cellAttributes: { alignment: 'right' }
    },
    {
        label: 'SKU #',
        fieldName: 'SAP_Material__c',
        type: 'Text',
        sortable: true,
        cellAttributes: { alignment: 'left' }
    },
    {
        label: 'QTY',
        fieldName: 'Order_Qty__c',
        type: 'text',
        sortable: true,
        cellAttributes: { alignment: 'left' }
    },
    {
        label: 'Description',
        fieldName: 'GE_NAS_Comments__c',
        type: 'Text',
        sortable: true,
        wrapText: true,
        cellAttributes: { alignment: 'right' }
    },
    ];


    // COLUMNS FOR WHEN CAN I GET IT
    @track whenCanIGetIt = [
    {
        label: 'Not In Catalog',
        fieldName: 'No_Cat_Number__c',
        type: 'Text',
        sortable: true
    },  
    {
        label: 'Catalog #',
        fieldName: 'Material_Description__c',
        type: 'Text',
        sortable: true,
        cellAttributes: { alignment: 'right' }
    },
    {
        label: 'SKU #',
        fieldName: 'SAP_Material__c',
        type: 'Text',
        sortable: true,
        cellAttributes: { alignment: 'left' }
    },
    {
        label: 'QTY',
        fieldName: 'Order_Qty__c',
        type: 'text',
        sortable: true,
        cellAttributes: { alignment: 'left' }
    },
    {
        label: 'Description',
        fieldName: 'GE_NAS_Comments__c',
        type: 'Text',
        sortable: true,
        wrapText: true,
        cellAttributes: { alignment: 'right' }
    },

    ];
    
    //COLUMNS FOR RETURNS, CREDIT, SHIPPING ISSUES
    @track multiColumns = [{
        label: 'PO #',
        fieldName: 'PO__c',
        type: 'Text',
        sortable: true,
        cellAttributes: { alignment: 'right' }
    },{
        label: 'Catalog #',
        fieldName: 'Material_Description__c',
        type: 'Text',
        sortable: true,
        cellAttributes: { alignment: 'right' }
    },
    {
        label: 'SKU #',
        fieldName: 'SAP_Material__c',
        type: 'Text',
        sortable: true,
        cellAttributes: { alignment: 'left' }
    },
    {
        label: 'Quantity',
        fieldName: 'Order_Qty__c',
        type: 'text',
        sortable: true,
        cellAttributes: { alignment: 'left' }
    },
    {
        label: 'Unit of Measure',
        fieldName: 'GE_NAS_Unit_of_Measure__c',
        type: 'text',
        sortable: true,
        cellAttributes: { alignment: 'right' }  
    },
    {
        label: 'Unit Price',
        fieldName: 'Invoiced_Price__c',
        type: 'currency',
        sortable: true,
        cellAttributes: { alignment: 'left' }
    },
    {
        label: 'Disputed #',
        fieldName: 'Discrepancy_Qty__c',
        type: 'text',
        sortable: true,
        cellAttributes: { alignment: 'left' }
    },
    {
        label: 'Total',
        fieldName: 'Discrepancy_Total__c',
        type: 'currency',
        sortable: true,
        cellAttributes: { alignment: 'left' }
    },
    {
        label: 'QuickStock',
        fieldName: 'QuickStock__c',
        type: 'boolean',
        sortable: true,
        cellAttributes: { alignment: 'right' }
    },
    {
        label: 'Type',
        fieldName: 'GE_NAS_Type_of_Problem1__c',
        type: 'text',
        sortable: true,
        cellAttributes: { alignment: 'right' }
    }

    ]; 

     //COLUMNS FOR STOCK BALANCING
     @track stockColumns = [{
        label: 'PO #',
        fieldName: 'PO__c',
        type: 'Text',
        sortable: true,
        cellAttributes: { alignment: 'right' }
    },{
        label: 'Catalog #',
        fieldName: 'Material_Description__c',
        type: 'Text',
        sortable: true,
        cellAttributes: { alignment: 'right' }
    },
    {
        label: 'SKU #',
        fieldName: 'SAP_Material__c',
        type: 'Text',
        sortable: true,
        cellAttributes: { alignment: 'left' }
    },
    {
        label: 'Quantity',
        fieldName: 'Order_Qty__c',
        type: 'text',
        sortable: true,
        cellAttributes: { alignment: 'left' }
    },
    {
        label: 'Unit of Measure',
        fieldName: 'GE_NAS_Unit_of_Measure__c',
        type: 'text',
        sortable: true,
        cellAttributes: { alignment: 'right' }  
    },
    {
        label: 'Disputed #',
        fieldName: 'Discrepancy_Qty__c',
        type: 'text',
        sortable: true,
        cellAttributes: { alignment: 'left' }
    },
    {
        label: 'QuickStock',
        fieldName: 'QuickStock__c',
        type: 'boolean',
        sortable: true,
        cellAttributes: { alignment: 'right' }
    },
    {
        label: 'Type',
        fieldName: 'GE_NAS_Type_of_Problem1__c',
        type: 'text',
        sortable: true,
        cellAttributes: { alignment: 'right' }
    }

    ]; 

       //COLUMNS FOR WARRANTY
       @track warrantyColumns = [
    {
        label: 'Not In Catalog',
        fieldName: 'No_Cat_Number__c',
        type: 'Text',
        sortable: true
    }, 
    {
        label: 'Catalog #',
        fieldName: 'Material_Description__c',
        type: 'Text',
        sortable: true,
        cellAttributes: { alignment: 'right' }
    },
    {
        label: 'SKU #',
        fieldName: 'SAP_Material__c',
        type: 'Text',
        sortable: true,
        cellAttributes: { alignment: 'left' }
    },
    {
        label: 'Alternate SKU #',
        fieldName: 'Non_Finished_Good_SKU__c',
        type: 'Text',
        sortable: true,
        cellAttributes: { alignment: 'left' }
    },
    /*{
        label: 'Quantity',
        fieldName: 'Order_Qty__c',
        type: 'text',
        sortable: true,
        cellAttributes: { alignment: 'left' }
    },*/
    {
        label: 'Installed Date',
        fieldName: 'Install_Date__c',
        type: 'Date',
        type: 'date-local',
        sortable: true,
        cellAttributes: { alignment: 'left'},
        typeAttributes: {
            day: "numeric",
            month: "numeric",
            year: "numeric"
        }
    },
    {
        label: '# Installed',
        fieldName: 'Installed_Qty__c',
        type: 'text',
        sortable: true,
        cellAttributes: { alignment: 'left' }
    },
    {
        label: '# Failed',
        fieldName: 'Discrepancy_Qty__c',
        type: 'number',
        sortable: true,
        cellAttributes: { alignment: 'left' }
    },
    {
        label: 'Unit of Measure',
        fieldName: 'GE_NAS_Unit_of_Measure__c',
        type: 'text',
        sortable: true,
        cellAttributes: { alignment: 'right' }  
    },
    {
        label: 'Comments',
        fieldName: 'GE_NAS_Comments__c',
        type: 'Text',
        sortable: true,
        wrapText: true,
        cellAttributes: { alignment: 'right' }
    },
    /*{
        label: 'Type',
        fieldName: 'GE_NAS_Type_of_Problem1__c',
        type: 'text',
        sortable: true,
        cellAttributes: { alignment: 'right' }
    }*/

    ]; 

    //COLUMNS FOR EXPEDITE
    @track expediteColumns = [
        {
            label: 'Not In Catalog',
            fieldName: 'No_Cat_Number__c',
            type: 'Text',
            sortable: true
        },
    {
        label: 'Catalog #',
        fieldName: 'Material_Description__c',
        type: 'Text',
        sortable: true,
        cellAttributes: { alignment: 'right' }
    },
    {
        label: 'SKU #',
        fieldName: 'SAP_Material__c',
        type: 'Text',
        sortable: true,
        cellAttributes: { alignment: 'left' }
    },
    {
        label: 'Unit of Measure',
        fieldName: 'GE_NAS_Unit_of_Measure__c',
        type: 'text',
        sortable: true,
        cellAttributes: { alignment: 'right' }  
    },
    {
        label: 'Quantity',
        fieldName: 'Order_Qty__c',
        type: 'text',
        sortable: true,
        cellAttributes: { alignment: 'left' }
    },
    {
        label: 'Req. Delivery Date',
        fieldName: 'Requested_Delivery_Date__c',
        type: 'date-local',
        sortable: true,
        cellAttributes: { alignment: 'left'},
        typeAttributes: {
            day: "numeric",
            month: "numeric",
            year: "numeric"
        }
    }

    ];

     //COLUMNS FOR CHANGE REQUEST
     @track changeColumns = [
        {
            label: 'Not In Catalog',
            fieldName: 'No_Cat_Number__c',
            type: 'Text',
            sortable: true
        },
    {
        label: 'Catalog #',
        fieldName: 'Material_Description__c',
        type: 'Text',
        sortable: true,
        cellAttributes: { alignment: 'right' }
    },
    {
        label: 'SKU #',
        fieldName: 'SAP_Material__c',
        type: 'Text',
        sortable: true,
        cellAttributes: { alignment: 'left' }
    },
    {
        label: 'Order Qty',
        fieldName: 'Order_Qty__c',
        type: 'text',
        sortable: true,
        cellAttributes: { alignment: 'left' }
    },
    {
        label: 'Unit of Measure',
        fieldName: 'GE_NAS_Unit_of_Measure__c',
        type: 'text',
        sortable: true,
        cellAttributes: { alignment: 'right' }  
    },
    {
        label: 'Unit Price',
        fieldName: 'Invoiced_Price__c',
        type: 'currency',
        sortable: true,
        cellAttributes: { alignment: 'left' }  
    },
    {
        label: 'Category of Change',
        fieldName: 'GE_NAS_Type_of_Problem1__c',
        type: 'Date',
        sortable: true
    },
    {
        label: 'Req. Delivery Date',
        fieldName: 'Requested_Delivery_Date__c',
        type: 'date-local',
        sortable: true,
        cellAttributes: { alignment: 'left'},
        typeAttributes: {
            day: "numeric",
            month: "numeric",
            year: "numeric"
        }
    },
    {
        label: 'Comments',
        fieldName: 'GE_NAS_Comments__c',
        type: 'Text',
        sortable: true,
        wrapText: true,
        cellAttributes: { alignment: 'right' }
    }

    ];

    // CASE COMMENTS COLUMNS
    @track commentsColumns =[{
        initialWidth: 200,
        label: 'Created Date',
        fieldName: 'CreatedDate',
        type: 'date',
        typeAttributes: {
          day: 'numeric',
          month: 'short',
          year: 'numeric',
          hour: '2-digit',
          minute: '2-digit',
          hour12: true
        },
        //sortable: true
    },
    {
        label: 'Created By',
        initialWidth: 200,
        fieldName: 'CreatedByName',
        type: 'Text',
        //sortable: true
    },
    {
        label: 'Comment',
        wrapText : true,
        fieldName: 'CommentBody',
        type: 'Text',
        //sortable: true
    }];

    @track disputeColumns = [
        {
            label: 'CATALOG #',
            fieldName: 'Material_Description__c', 
            //initialWidth: 20,
            type: 'text',
            sortable: true,
            cellAttributes: { alignment: 'right' }
        },
        {
            label: 'SKU',
            fieldName: 'SAP_Material__c', 
            //initialWidth: 20,
            type: 'text',
            sortable: true,
            cellAttributes: { alignment: 'left' }
        },
        {
            label: 'UNIT PRICE',
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
            label: 'UNIT OF MEASURE',
            fieldName: 'GE_NAS_Unit_of_Measure__c',
            type: 'text',
            sortable: true,
            cellAttributes: { alignment: 'right' }  
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
                alignment: 'right'
            }
        }
     ];

     @track stockDisputeColumns = [
        {
            label: 'CATALOG #',
            fieldName: 'Material_Description__c', 
            //initialWidth: 20,
            type: 'text',
            sortable: true,
            cellAttributes: { alignment: 'right' }
        },
        {
            label: 'SKU',
            fieldName: 'SAP_Material__c', 
            //initialWidth: 20,
            type: 'text',
            sortable: true,
            cellAttributes: { alignment: 'left' }
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
            label: 'UNIT OF MEASURE',
            fieldName: 'GE_NAS_Unit_of_Measure__c',
            type: 'text',
            sortable: true,
            cellAttributes: { alignment: 'right' }  
        },

        {
            label: 'TYPE',
            fieldName: 'GE_NAS_Type_of_Problem1__c', 
            //initialWidth: 20,
            type: 'text',
            sortable: true,
            cellAttributes:{
                alignment: 'right'
            }
        }
     ];

     @track caseOpen = true;
     @track setStatus;
     activeSections = [];
     @track isLoading = false;
     @track UserType;
     @track isDistributor = false;

    async connectedCallback(){
        console.log('Record ID: '+this.recordId);
        this.isSpinner = true;
        this.fetchCaseComments();
        this.getCaseProducts();
        this.getDisputeRequests();
    }


    @wire(getRecord, {
        recordId: '$recordId',
        fields: [TYPE_FIELD, SUB_TYPE_FIELD]
    }) wireuser({
        error,
        data
    }) {
        if (error) {
        this.error = error ; 
        } else if (data) {
            this.caseData = data;
            this.caseType = data.fields.Type.value;
            let type = data.fields.Type.value;
            console.log('Case Type: '+this.caseType);
            this.caseSubType = data.fields.GE_NAS_Sub_Type__c.value;
            let subtype = data.fields.GE_NAS_Sub_Type__c.value;
           
            console.log('Case Sub Type: '+this.caseSubType);
            this.UserType = localStorage.getItem('User Type');
            console.log('USER TYPE: '+this.UserType);
                if(this.UserType == "Agent"){
                    this.isDistributor = false;
                } else if(this.UserType == "Distributor" || this.UserType == "Customer"){
                    this.isDistributor = true;
                }
            this.setCaseType(type, subtype);
        }
    }

    setCaseType(type, subtype){


       getCaseFields({caseId: this.recordId, caseFields: this.commonFields})
                .then(result=>{
                    console.log('Results returned: '+JSON.stringify(result));
                    this.setStatus = result[0].Status;
                    console.log('Case Status: '+this.setStatus);
                    if(this.setStatus == 'Closed'){
                        this.caseOpen = false;
                    } else {
                        this.caseOpen = true;
                    }
                    this.requestorName = result[0].eLight_Requestor_Name__c;
                    this.requestorEmail = result[0].Requestor_Email__c;
                    this.requestorPhone = result[0].eLight_Requestor_Phone__c;
                    this.accountName = result[0].Account.Name;
                    this.soldToAccountName = result[0].Sold_To_Account__r.Name;
                    this.caseNumber = result[0].CaseNumber;
                    //this.caseComments = result[0].CaseComments;
                  
                    //console.log('Case Comments Returned: '+this.caseComments);

                    
                })
            
        if(type == "Sales Support" && subtype == "Lighting Application"){
                /*var sendFields = this.commonFields + ','+ this.appFields;
                console.log('Sending Field List: '+sendFields);*/


                getCaseFields({caseId: this.recordId, caseFields: this.appFields})
                .then(result=>{
                    console.log('Results returned: '+JSON.stringify(result));
                
                    /*this.requestorName = result[0].eLight_Requestor_Name__c;
                    this.requestorEmail = result[0].Requestor_Email__c;
                    this.requestorPhone = result[0].eLight_Requestor_Phone__c;
                    this.accountName = result[0].Account.Name;
                    this.soldToAccountName = result[0].Sold_To_Account__r.Name;*/
                    this.subject = result[0].Subject;
                    if(result[0].Spec_Reg_Number__c == null || result[0].Spec_Reg_Number__c == ' '){
                        this.specRegNumber = ' ';
                    } else {
                        this.specRegNumber = result[0].Spec_Reg_Number__c;
                    }
                    
                    this.applicationType = result[0].Application_Type__c;
                    this.desiredServices = result[0].Connect_Desired_Services__c;
                    this.dueDate = result[0].GE_LGT_Actual_Due_Date__c;
                 

                    this.comments = result[0].eLight_Comments__c;
                    this.jobName = result[0].Job_Name__c;
                    this.contactName = result[0].Site_Contact_Name__c;
                    this.contactEmail = result[0].Site_Contact_Email__c;
                    this.contactPhone = result[0].Site_Contact_Phone__c;
                    this.address = result[0].eLight_Address_2__c;
                    this.accountManager = result[0].Account.Owner.Name;
                    //this.caseComments = result[0].CaseComments;

                })
                this.isLightingDesign = true;
                this.commonColumns = true;
                this.isWarranty = false;
                this.showProducts = true;
                this.showCommon = true;
            } 

            else if(type == "Returns" && subtype == "New RGA"){
                /*var sendFields = this.commonFields + ','+ this.returnFields;
                console.log('Sending Field List: '+sendFields);*/

                getCaseFields({caseId: this.recordId, caseFields: this.returnFields})
                .then(result=>{
                    console.log('Results returned: '+JSON.stringify(result));
                   /* this.setStatus = result[0].Status;
                    console.log('Case Status: '+this.setStatus);
                    if(this.setStatus == 'Closed'){
                        this.caseOpen = false;
                    } else {
                        this.caseOpen = true;
                    }
                    this.requestorName = result[0].eLight_Requestor_Name__c;
                    this.requestorEmail = result[0].Requestor_Email__c;
                    this.requestorPhone = result[0].eLight_Requestor_Phone__c;
                    this.accountName = result[0].Account.Name;
                    this.soldToAccountName = result[0].Sold_To_Account__r.Name;*/
                    this.requestedAction = result[0].Requested_Action__c;
                    this.returnReason = result[0].eLight_Reason_for_Return__c;
                    this.secondReason = result[0].eLight_Secondary_Reason_s__c;
                    this.comments = result[0].eLight_Comments__c;

                })
                this.isReturns = true;
                this.showCommon = true;
                this.showRequests = true;
                this.showProducts = true;
                this.isLightingDesign = false;
                this.getDisputeRequests();
            } 

            else if(type == "Returns" && subtype == "Stock Balancing Return"){
                /*var sendFields = this.commonFields + ','+ this.returnFields;
                console.log('Sending Field List: '+sendFields);*/

                getCaseFields({caseId: this.recordId, caseFields: this.stockFields})
                .then(result=>{
                    console.log('Results returned: '+JSON.stringify(result));
                   /* this.setStatus = result[0].Status;
                    console.log('Case Status: '+this.setStatus);
                    if(this.setStatus == 'Closed'){
                        this.caseOpen = false;
                    } else {
                        this.caseOpen = true;
                    }
                    this.requestorName = result[0].eLight_Requestor_Name__c;
                    this.requestorEmail = result[0].Requestor_Email__c;
                    this.requestorPhone = result[0].eLight_Requestor_Phone__c;
                    this.accountName = result[0].Account.Name;
                    this.soldToAccountName = result[0].Sold_To_Account__r.Name;*/
                    tthis.purchaseOrder = result[0].GE_NAS_Purchase_Order__c;
                    this.comments = result[0].eLight_Comments__c;

                })
                this.isStockBalancing = true;
                this.showCommon = true;
                this.commonColumns = false;
                this.isWarranty = false;
                this.showRequests = true;
                this.showProducts = true;
                this.getDisputeRequests();
            } 

            else if(type == "Warranty" && subtype == "Warranty Claim"){
                /*var sendFields = this.commonFields + ','+ this.returnFields;
                console.log('Sending Field List: '+sendFields);*/

                getCaseFields({caseId: this.recordId, caseFields: this.warrantyFields})
                .then(result=>{
                    console.log('Results returned: '+JSON.stringify(result));
                   /* this.setStatus = result[0].Status;
                    console.log('Case Status: '+this.setStatus);
                    if(this.setStatus == 'Closed'){
                        this.caseOpen = false;
                    } else {
                        this.caseOpen = true;
                    }
                    this.requestorName = result[0].eLight_Requestor_Name__c;
                    this.requestorEmail = result[0].Requestor_Email__c;
                    this.requestorPhone = result[0].eLight_Requestor_Phone__c;
                    this.accountName = result[0].Account.Name;
                    this.soldToAccountName = result[0].Sold_To_Account__r.Name;*/
                    this.requestedAction = result[0].Requested_Action__c;
                    this.warrantyCode = result[0].Warranty_Code__c;
                    this.warrantySubCode = result[0].Warranty_Sub_Code__c;
                    this.comments = result[0].eLight_Comments__c;
                    this.location = result[0].Site_Name__c;
                    this.contactName = result[0].Site_Contact_Name__c;
                    this.contactEmail = result[0].Site_Contact_Email__c;
                    this.contactPhone = result[0].Site_Contact_Phone__c;
                    this.address = result[0].eLight_Address_2__c;

                })
                this.isWarranty = true;
                this.showCommon = true;
                this.showRequests = true;
                this.showProducts = true;
                this.getDisputeRequests();
            } 

            else if(type == "Pricing" && subtype == "Pricing Inquiry"){
                /*var sendFields = this.commonFields + ','+ this.returnFields;
                console.log('Sending Field List: '+sendFields);*/

                let tempCode = localStorage.getItem('currencyCode');
                    if(tempCode === "CAD"){
                        this.currencyCode = "CA";
                    }else {
                        this.currencyCode = '';
                    }

                getCaseFields({caseId: this.recordId, caseFields: this.pricingFields})
                .then(result=>{
                    console.log('Results returned: '+JSON.stringify(result));
                   /* this.setStatus = result[0].Status;
                    console.log('Case Status: '+this.setStatus);
                    if(this.setStatus == 'Closed'){
                        this.caseOpen = false;
                    } else {
                        this.caseOpen = true;
                    }
                    this.requestorName = result[0].eLight_Requestor_Name__c;
                    this.requestorEmail = result[0].Requestor_Email__c;
                    this.requestorPhone = result[0].eLight_Requestor_Phone__c;
                    this.accountName = result[0].Account.Name;
                    this.soldToAccountName = result[0].Sold_To_Account__r.Name;*/
                    this.subject = result[0].Subject;
                    this.jobName = result[0].Job_Name__c;
                    this.estimatedJobValue = result[0].Estimated_Job_Value__c;
                    /*if(tempCode === "CAD"){
                        this.estimatedJobValue = 'CA' + result[0].Estimated_Job_Value__c;
                    } else {
                        this.estimatedJobValue = result[0].Estimated_Job_Value__c;
                    }*/
                    this.comments = result[0].eLight_Comments__c;
                    console.log('Converted VALUE: '+this.estimatedJobValue);
                    

                })
                this.isPricing = true;
                this.showProducts = true;
                this.commonColumns = true;
                this.isWarranty = false;
                this.showCommon = true;
                this.isLightingDesign = false;
            } 

            else if(type == "Pricing" && subtype == "Credit / Debit"){
                /*var sendFields = this.commonFields + ','+ this.returnFields;
                console.log('Sending Field List: '+sendFields);*/

                getCaseFields({caseId: this.recordId, caseFields: this.creditFields})
                .then(result=>{
                    console.log('Results returned: '+JSON.stringify(result));
                   /* this.setStatus = result[0].Status;
                    console.log('Case Status: '+this.setStatus);
                    if(this.setStatus == 'Closed'){
                        this.caseOpen = false;
                    } else {
                        this.caseOpen = true;
                    }
                    this.requestorName = result[0].eLight_Requestor_Name__c;
                    this.requestorEmail = result[0].Requestor_Email__c;
                    this.requestorPhone = result[0].eLight_Requestor_Phone__c;
                    this.accountName = result[0].Account.Name;
                    this.soldToAccountName = result[0].Sold_To_Account__r.Name;*/
                    this.invoiceNumber = result[0].GE_NAS_Invoice__c;
                    this.discrepancyAmount = result[0].Discrepancy_Amount__c;
                    this.purchaseOrder = result[0].GE_NAS_Purchase_Order__c;

                })
                this.isCredit = true;
                this.showCommon = true;
                this.showProducts = true;
            } 

            else if(type == "Product and Availability" && subtype == "When Can I Get It?"){
                /*var sendFields = this.commonFields + ','+ this.returnFields;
                console.log('Sending Field List: '+sendFields);*/

                getCaseFields({caseId: this.recordId, caseFields: this.whenFields})
                .then(result=>{
                    console.log('Results returned: '+JSON.stringify(result));
                   /* this.setStatus = result[0].Status;
                    console.log('Case Status: '+this.setStatus);
                    if(this.setStatus == 'Closed'){
                        this.caseOpen = false;
                    } else {
                        this.caseOpen = true;
                    }
                    this.requestorName = result[0].eLight_Requestor_Name__c;
                    this.requestorEmail = result[0].Requestor_Email__c;
                    this.requestorPhone = result[0].eLight_Requestor_Phone__c;
                    this.accountName = result[0].Account.Name;
                    this.soldToAccountName = result[0].Sold_To_Account__r.Name;*/
                    this.questions = result[0].Questions__c;
                    
                })
                this.showCommon = true;
                this.showProducts = true;
                this.commonColumns = true;
                this.isWarranty = false;
                this.isWhenCanIGet = true;
                this.isLightingDesign = false;
            } 

            else if(type == "Acct/Order Mgmnt" && subtype == "Change Request"){
                /*var sendFields = this.commonFields + ','+ this.returnFields;
                console.log('Sending Field List: '+sendFields);*/

                getCaseFields({caseId: this.recordId, caseFields: this.changeFields})
                .then(result=>{
                    console.log('Results returned: '+JSON.stringify(result));
                   /* this.setStatus = result[0].Status;
                    console.log('Case Status: '+this.setStatus);
                    if(this.setStatus == 'Closed'){
                        this.caseOpen = false;
                    } else {
                        this.caseOpen = true;
                    }
                    this.requestorName = result[0].eLight_Requestor_Name__c;
                    this.requestorEmail = result[0].Requestor_Email__c;
                    this.requestorPhone = result[0].eLight_Requestor_Phone__c;
                    this.accountName = result[0].Account.Name;
                    this.soldToAccountName = result[0].Sold_To_Account__r.Name;*/
                    this.orderNumber = result[0].GE_NAS_Confirmation__c;
                    this.purchaseOrder = result[0].GE_NAS_Purchase_Order__c;

                })
                this.showCommon = true;
                this.showProducts = true;
                this.commonColumns = true;
                this.isWarranty = false;
                this.isChange = true;
            } 

            else if(type == "Acct/Order Mgmnt" && subtype == "Expedite"){
                /*var sendFields = this.commonFields + ','+ this.returnFields;
                console.log('Sending Field List: '+sendFields);*/

                getCaseFields({caseId: this.recordId, caseFields: this.expediteFields})
                .then(result=>{
                    console.log('Results returned: '+JSON.stringify(result));
                   /* this.setStatus = result[0].Status;
                    console.log('Case Status: '+this.setStatus);
                    if(this.setStatus == 'Closed'){
                        this.caseOpen = false;
                    } else {
                        this.caseOpen = true;
                    }
                    this.requestorName = result[0].eLight_Requestor_Name__c;
                    this.requestorEmail = result[0].Requestor_Email__c;
                    this.requestorPhone = result[0].eLight_Requestor_Phone__c;
                    this.accountName = result[0].Account.Name;
                    this.soldToAccountName = result[0].Sold_To_Account__r.Name;*/
                    this.orderShip = result[0].Order_Ship_From__c;
                    this.orderExpected = result[0].Order_Expected_Ship_Date__c;
                    this.orderNumber = result[0].GE_NAS_Confirmation__c;
                    this.expediteReason = result[0].Expedite_Reason__c;
                    this.shipComplete = result[0].Ship_Complete_Override__c;

                })
                this.showCommon = true;
                this.showProducts = true;
                this.commonColumns = true;
                this.isWarranty = false;
                this.isExpedite = true;
            } 

            else if(type == "Sales Support" && subtype == "New Specification Registration"){
                /*var sendFields = this.commonFields + ','+ this.returnFields;
                console.log('Sending Field List: '+sendFields);*/
                getCaseFields({caseId: this.recordId, caseFields: this.specFields})
                .then(result=>{
                    console.log('Results returned: '+JSON.stringify(result));
                   /* this.setStatus = result[0].Status;
                    console.log('Case Status: '+this.setStatus);
                    if(this.setStatus == 'Closed'){
                        this.caseOpen = false;
                    } else {
                        this.caseOpen = true;
                    }
                    this.requestorName = result[0].eLight_Requestor_Name__c;
                    this.requestorEmail = result[0].Requestor_Email__c;
                    this.requestorPhone = result[0].eLight_Requestor_Phone__c;
                    this.accountName = result[0].Account.Name;
                    this.soldToAccountName = result[0].Sold_To_Account__r.Name;*/
                    this.specAgency = result[0].Spec_Reg_Agency__r.Name;
                    if(result[0].Ordering_Agency__c != null ){
                        this.orderingAgency = result[0].Ordering_Agency__r.Name;
                    }
                    if(result[0].Delivery_Agency__c != null){
                        this.deliverAgency = result[0].Delivery_Agency__r.Name;
                    }
                    this.estimateBidStart = result[0].Estimated_bidding_ordering_Start_Date__c
                    this.estimateBidEnd = result[0].Estimated_bidding_ordering_End_Date__c;
                    this.jobName = result[0].Job_Name__c;
                    this.specAgencyRole = result[0].Specifying_Agency_s_Role__c,
                    this.jobCity = result[0].Job_City__c,
                    this.jobState = result[0].Job_State__c,
                    this.estimatedJobValue = result[0].Estimated_Job_Value__c;
                    this.influencerName = result[0].Influencer__c;
                    this.influenceRole = result[0].Influencer_Role__c;
                    this.influencerCity = result[0].Influencer_City__c;
                    this.influencerState = result[0].Influencer_State__c;

                })
                this.isSpecReg = true;
                this.commonColumns = true;
                this.isWarranty = false;
                this.showProducts = true;
            } 

            else if(type == "Sales Support" && subtype == "Marketing Collateral"){
                /*var sendFields = this.commonFields + ','+ this.returnFields;
                console.log('Sending Field List: '+sendFields);*/
                getCaseFields({caseId: this.recordId, caseFields: this.marketingFields})
                .then(result=>{
                    console.log('Results returned: '+JSON.stringify(result));
                   /* this.setStatus = result[0].Status;
                    console.log('Case Status: '+this.setStatus);
                    if(this.setStatus == 'Closed'){
                        this.caseOpen = false;
                    } else {
                        this.caseOpen = true;
                    }
                    this.requestorName = result[0].eLight_Requestor_Name__c;
                    this.requestorEmail = result[0].Requestor_Email__c;
                    this.requestorPhone = result[0].eLight_Requestor_Phone__c;
                    this.accountName = result[0].Account.Name;
                    this.soldToAccountName = result[0].Sold_To_Account__r.Name;*/
                    this.material = result[0].Material__c;
                    this.materialCategory = result[0].Material_Category__c;
                    this.questions = result[0].Questions__c;
                    this.subject = result[0].Subject
                    this.jobName = result[0].Job_Name__c;
                    this.estimatedJobValue = result[0].Estimated_Job_Value__c;
                })
                this.isMarketing = true;
                this.showCommon = true;
                this.commonColumns = true;
                this.isWarranty = false;
                this.showProducts = true;
                this.isLightingDesign = false;
            } 

            else if(type == "Shipping" && (subtype == "Overage" || subtype == "Shortage" || subtype == "Lost/Damaged")){
                /*var sendFields = this.commonFields + ','+ this.returnFields;
                console.log('Sending Field List: '+sendFields);*/
                getCaseFields({caseId: this.recordId, caseFields: this.shippingFields})
                .then(result=>{
                    console.log('Results returned: '+JSON.stringify(result));
                   /* this.setStatus = result[0].Status;
                    console.log('Case Status: '+this.setStatus);
                    if(this.setStatus == 'Closed'){
                        this.caseOpen = false;
                    } else {
                        this.caseOpen = true;
                    }
                    this.requestorName = result[0].eLight_Requestor_Name__c;
                    this.requestorEmail = result[0].Requestor_Email__c;
                    this.requestorPhone = result[0].eLight_Requestor_Phone__c;
                    this.accountName = result[0].Account.Name;
                    this.soldToAccountName = result[0].Sold_To_Account__r.Name;*/
                    this.requestedAction = result[0].Requested_Action__c;
                    this.discrepancy = result[0].Discrepancy__c;
                    this.comments = result[0].eLight_Comments__c;
                })
                this.isShipping = true;
                this.showCommon = true;
                this.showRequests = true;
                this.commonColumns = true;
                this.isWarranty = false;
                this.showProducts = true;
                this.getDisputeRequests();
            } 

            else if(type == "Technical Support" && subtype == "Technical Service"){
                /*var sendFields = this.commonFields + ','+ this.returnFields;
                console.log('Sending Field List: '+sendFields);*/
                getCaseFields({caseId: this.recordId, caseFields: this.technicalFields})
                .then(result=>{
                    console.log('Results returned: '+JSON.stringify(result));
                   /* this.setStatus = result[0].Status;
                    console.log('Case Status: '+this.setStatus);
                    if(this.setStatus == 'Closed'){
                        this.caseOpen = false;
                    } else {
                        this.caseOpen = true;
                    }
                    this.requestorName = result[0].eLight_Requestor_Name__c;
                    this.requestorEmail = result[0].Requestor_Email__c;
                    this.requestorPhone = result[0].eLight_Requestor_Phone__c;
                    this.accountName = result[0].Account.Name;
                    this.soldToAccountName = result[0].Sold_To_Account__r.Name;*/
                    this.accountManager = result[0].Agent_Name__c;
                    
                    this.primaryProduct = result[0].Primary_Product_Brand__c;
                    
                    this.description = result[0].Description;
                    this.dueDate = result[0].GE_LGT_Actual_Due_Date__c;
                    
                        this.jobName = result[0].Job_Name__c;
                  
                    this.estimatedJobValue = result[0].Estimated_Job_Value__c;
                })
                this.istechsupp = true;
                this.showProducts = true;
                this.commonColumns = true;
                this.isWarranty = false;
                this.showCommon = true;
            } 

            else if(type == "Web Assistance" && subtype == "Connect Platform Support"){
                /*var sendFields = this.commonFields + ','+ this.returnFields;
                console.log('Sending Field List: '+sendFields);*/
                getCaseFields({caseId: this.recordId, caseFields: this.connectFields})
                .then(result=>{
                    console.log('Results returned: '+JSON.stringify(result));
                   /* this.setStatus = result[0].Status;
                    console.log('Case Status: '+this.setStatus);
                    if(this.setStatus == 'Closed'){
                        this.caseOpen = false;
                    } else {
                        this.caseOpen = true;
                    }
                    this.requestorName = result[0].eLight_Requestor_Name__c;
                    this.requestorEmail = result[0].Requestor_Email__c;
                    this.requestorPhone = result[0].eLight_Requestor_Phone__c;
                    this.accountName = result[0].Account.Name;
                    this.soldToAccountName = result[0].Sold_To_Account__r.Name;*/
                    this.questionCategory = result[0].Question_Category__c;
                    this.questionSubCategory = result[0].Question_Sub_Category__c;
                    this.questions = result[0].Questions__c;
  
                })
                this.isPlatformSupport = true;
                this.showCommon = true;
                this.commonColumns = true;
                this.isWarranty = false;
            } 


        this.isSpinner = false;
    }

    /*getFields(fields){
        getCaseFields({caseId: this.recordId , caseFields : fields})
            
        .then(result => {
            
            this.caseFields = result;
            this.testField = this.caseFields.Subject;
            console.log('Subject: '+this.testField);
            console.log(result);
            console.log('Data Returned from Apex: ' + result);
            console.log('JSON Stringified: '+JSON.stringify(result));
            console.log('Case Data: '+this.caseFields);
           
        })
        .catch(error => {
            console.log(error);
            this.error = error;
            console.log('Apex failed...');
        }); 

    }*/

   handleSelected(event){
        var disID = event.target.name;
        if (disID !== undefined) {
            console.log('SECTION ID: '+JSON.stringify(disID));
            this.isLoading = true;
            getDisputeProducts({disId : disID})
            .then(result => {
                this.disputeProducts = result;
                this.isLoading = false;
            });
        }
        
    }

    async getDisputeRequests(){
       await getDisputeRequests({caseId: this.recordId})
        .then(result=>{
            if(result){
              this.templist = [];
              for (const disputes of result){
                  const clone = Object.assign({}, disputes);
                  if(disputes.Status__c == "Pending Action"){
                      clone.badgeClass = "Pending";
                      
                  } else if(disputes.Status__c == "Approved"){
                      clone.badgeClass = "Approved";
                      
                  } else if(disputes.Status__c == "Rejected"){
                      clone.badgeClass = "Rejected";
                      
                  }

                  clone.disID = disputes.Id;
                  console.log('Pushing ID to Array...'+ clone.disID);

                  

                  // Set flag to show pdf icon for return type by Sameer Mahadik on(9-8-2021)
                  clone.showRmaPDF = true;
                  if (disputes.Type__c == "Replacement" || disputes.Type__c == "Replace" || disputes.Type__c == "Credit") {
                    clone.showRmaPDF = false;
                  }

                  let dt = new Date( disputes.CreatedDate );
                  let fdate = new Intl.DateTimeFormat( 'en-US', options ).format( dt );
                  clone.disName = disputes.Type__c + ' | ' + disputes.Sold_To__r.Name + ' | ' + disputes.Invoice__c + ' | ' +disputes.Customer_PO__c + ' | ' + fdate;
                  console.log('GENERATED DISPUTE NAME: '+clone.disName);
                  console.log('Dispute Order: '+disputes.Order__c);
                  
                  if(clone.Order__c != null || clone.Order__c != '' || clone.Order__c != undefined){
                      this.showRMA = true;
                  } else if (clone.Order__c == null || clone.Order__c == '' || clone.Order__c == undefined){
                      this.showRMA = false;
                  }
                  console.log('Show RMA Button Status: '+this.showRMA);

                  /*if(disputes.Order__c != ''){
                      this.showRMA = true;
                  } else {
                      this.showRMA = false;
                  }*/
                  this.templist.push(clone);
              }
                    
                this.disputes = this.templist;
                //this.disputeProducts = result[0].Case_Products__r;
                this.status = result[0].Status__c;
                getDisputeProducts({disId : this.disputes[0].disID})
                    .then(result => {
                        this.disputeProducts = result;
                    })
                /*if(this.status == "Pending Action"){
                    this.template.querySelector('.badge').classList.add("badgeColorPending");
                }*/
                console.log('Data Returned: '+JSON.stringify(this.disputes));
            }
            
            
        })
    }

    openModal(){
        this.showModal = true;
        
    }

    closeModal() {
        this.showModal = false;
    } 

    fetchCaseComments(){
        getCaseComments({caseId : this.recordId})
        .then(result=>{

            let tempList = [];
            if(result){
                for (const comments of result){
                    const clone = Object.assign({}, comments);
                    clone.CreatedByName = comments.CreatedBy.Name;
                    tempList.push(clone);
                }
            }
            
            this.caseComments = tempList;
            
            console.log('Case Comments Returned: '+this.caseComments);
        })
    }

    openCommentModal(){
        var date = new Date();
        const n = date.toDateString();
        const time = date.toLocaleTimeString();
        this.timeStamp = n + ' - '+time;
        this.showCommentModal = true;
    }

    closeCommentModal(){
        this.showCommentModal = false;
    }

    createComment(){
        this.addingSpinner = true;
        let commentBody = this.template.querySelector(".cb").value;
        let nComment = { 'sobjectType': 'CaseComment' };
        nComment.ParentId = this.recordId;
        nComment.IsPublished = true;
        nComment.CommentBody = commentBody;

        createCaseComment({newComment : nComment})
        .then(result=>{
            this.addingSpinner = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'SUCCESS',
                    message: 'Comment Added to Case '+this.caseNumber,
                    variant: 'success'
                })
            );
            this.fetchCaseComments();
            this.showCommentModal = false;
        })
    }

    async getCaseProducts(){
        await getCaseProducts({caseId: this.recordId})
        
        .then(result =>{
            console.log('Retrieving Case Products...');
            this.productLines = result;
            console.log('Case Products Returned: '+JSON.stringify(this.productLines));

            getCaseFields({caseId: this.recordId, caseFields: this.caseFields})
                .then(result=>{
                    this.caseNumber = result[0].CaseNumber;
                    this.orderingAgency = result[0].Ordering_Agency__r.Name;
                    this.specAgency = result[0].Spec_Reg_Agency__r.Name;
                    this.deliverAgency = result[0].Delivery_Agency__r.Name;
                    console.log('Case Returned: '+JSON.stringify(result));
                    console.log('Case Number: '+this.caseNumber);

                    
                })

        })
    }
}