/*
 * Created by andra on 2021. 06. 22..
 */

import {LightningElement, api, wire} from 'lwc';
import getRgaDoc from '@salesforce/apex/CaseRgaPdfController.getRgaDoc';
import {fireErrorToast, hideLoadingSpinner, showLoadingSpinner} from "c/util";
import {SOMETHING_WENT_WRONG_PLEASE_TRY_AGAIN_LATER} from "c/constants";
import {downloadFileFromBlob, downloadFromBase64String} from "c/downloader";

export default class DownloadRgaDocument extends LightningElement {
    @api caseId;
    @api disId;

    async handleClick(event) {
            try {
                showLoadingSpinner(this);
                console.log(this.caseId);
                let response = await getRgaDoc({caseId: this.caseId});
                response = JSON.parse(response);
                if (response != null) {
                    if (response.hasError === true) {
                        console.log(response.message);
                        fireErrorToast(this, response.message);
                    }
                    else if(response.base64Data != null){
                        var caseNo = response.caseNo;
                        downloadFromBase64String(response.base64Data, response.caseNo + '_RGA_doc.pdf');
                    }
                    else{
                        console.log(response.message);
                        fireErrorToast(this, SOMETHING_WENT_WRONG_PLEASE_TRY_AGAIN_LATER);
                    }
                } else {
                    console.log('Response is null');
                    fireErrorToast(this, SOMETHING_WENT_WRONG_PLEASE_TRY_AGAIN_LATER);
                }

            } catch (error) {
                console.error(error);
                fireErrorToast(this, SOMETHING_WENT_WRONG_PLEASE_TRY_AGAIN_LATER);
            } finally {
                hideLoadingSpinner(this);
            }
        }
}