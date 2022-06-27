/**
 * Created by david on 2021. 01. 29..
 */

import { LightningElement } from 'lwc';
import CreditUS from '@salesforce/contentAssetUrl/GE_Current_Credit_Application_US_JDB_63';
import CreditCA from '@salesforce/contentAssetUrl/Current_Credit_ApplicationCanada_Rev_68';
import W9Form from '@salesforce/contentAssetUrl/ConnectReferenceMaterialW9CurrentLighti';



export default class CommunityReferenceMaterial extends LightningElement {

    CreditCA = CreditCA;
    CreditUS = CreditUS;
    W9Form = W9Form;
}