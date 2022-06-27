import {ShowToastEvent} from "lightning/platformShowToastEvent";

export const fireToast = (lightningElement, toastParameters) => {
    const evt = new ShowToastEvent(toastParameters);
    lightningElement.dispatchEvent(evt);
};

export const fireErrorToast = (lightningElement, message, mode='dismissable' ) => {
    const evt = new ShowToastEvent({
        title: 'Error',
        message: message,
        mode: mode,
        variant: 'error',
    });
    lightningElement.dispatchEvent(evt);
};

export const fireSuccessToast = (lightningElement, message, mode='dismissable') => {
    const evt = new ShowToastEvent({
        title: 'Success',
        message: message,
        mode: mode,
        variant: 'success',
    });
    lightningElement.dispatchEvent(evt);
};

export const fireInfoToast = (lightningElement, message,mode='dismissable') => {
    const evt = new ShowToastEvent({
        title: '',
        message: message,
        mode: mode,
        variant: 'info',
    });
    lightningElement.dispatchEvent(evt);
};