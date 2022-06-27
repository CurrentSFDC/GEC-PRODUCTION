/**
 * 2021-02-09.
 */

import {LightningElement, wire} from 'lwc';
import refToToolspng from '@salesforce/contentAssetUrl/toolswidget2png';
import getToolsCommunityContentId from '@salesforce/apex/CommunityContentController.getToolsCommunityContentId';

export default class CommunityRefToTools extends LightningElement {
    refToToolspng = refToToolspng;

    @wire(getToolsCommunityContentId)
    communityContentId;

    get refToTools() {
        if (this.communityContentId && this.communityContentId.data) {
            return '/Agents/s/community-content/' + this.communityContentId.data;
        }
        return '';
    }
}