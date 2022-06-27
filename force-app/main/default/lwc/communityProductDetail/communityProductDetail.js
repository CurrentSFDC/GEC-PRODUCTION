/**
 *  2021-02-17.
 */

import {LightningElement, api, track} from 'lwc';
import getProductDetails from '@salesforce/apex/CommunityProductDetailController.getProductDetails';

export default class CommunityProductDetail extends LightningElement {
    @api communityContentId;
    productDetails;
    communityContent;
    @track isLoading = false;

    async connectedCallback() {
        //todo only for builder testing purposes
        if (!this.communityContentId) {
            this.communityContentId = 'a3gc00000041ah4AAA';
        }
        this.productDetails = await getProductDetails({communityContentId: this.communityContentId});
        console.log(`CommunityProductDetail productDetails`, JSON.parse(JSON.stringify(this.productDetails)));
        this.communityContent = this.productDetails.communityContent;
    }

    // Catch event from communityProductDocument child component
    handleIsLoading(event) {
        this.isLoading = event.detail;
    }

}