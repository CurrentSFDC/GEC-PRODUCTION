/**
 *  2021-02-09.
 */

import {LightningElement} from 'lwc';
import refToNewspng from '@salesforce/contentAssetUrl/newswidget2png';

export default class CommunityRefToNews extends LightningElement {
    refToNewspng = refToNewspng;
}