import {ShowToastEvent} from "lightning/platformShowToastEvent";

export const getURLParameters = () => {
    try {
        let urlparameters = {};
        const url = window.location.href;
        let searchParams = new URL(url).searchParams;
        for (const searchParam of searchParams) {
            let key = searchParam[0];
            let value = searchParam[1];
            urlparameters[key] = value;
        }
        return urlparameters;
    } catch (error) {
        console.error(error);
    }
};

export const sortData = (data, fieldname, direction) => {
    try {
        let getValue = (obj) => {
            return obj[fieldname];
        };
        let isReverse = direction === 'asc' ? 1 : -1;
        data.sort((x, y) => {
            x = getValue(x) != null ? getValue(x) : '';
            y = getValue(y) != null ? getValue(y) : '';
            return isReverse * ((x > y) - (y > x));
        });
        return data;
    } catch (error) {
        console.error(error);
    }
}
export const hideLoadingSpinner = (lightningElement, config = {}) => {
    try {
        let cssSelector = `lightning-spinner`;
        if (config.idOfSpinner != null) {
            cssSelector += `[id^=${idOfSpinner}]`
        }
        if (config.customCSSSelector != null) {
            cssSelector = config.customCSSSelector;
        }
        let lightningSpinner = lightningElement.template.querySelector(cssSelector);
        if (lightningSpinner != null) {
            lightningSpinner.classList.add('slds-hidden');
        }
    } catch (error) {
        console.error(error);
    }
};
export const showLoadingSpinner = (lightningElement, config = {}) => {
    try {
        let cssSelector = `lightning-spinner`;
        if (config.idOfSpinner != null) {
            cssSelector += `[id^=${idOfSpinner}]`
        }
        if (config.customCSSSelector != null) {
            cssSelector = config.customCSSSelector;
        }
        let lightningSpinner = lightningElement.template.querySelector(cssSelector);
        if (lightningSpinner != null) {
            lightningSpinner.classList.remove('slds-hidden');
        }
    } catch (error) {
        console.error(error);
    }
};
export const fireErrorToast = (lightningElement, message, mode='dismissable' ) => {
    const evt = new ShowToastEvent({
        title: '',
        message: message,
        mode: mode,
        variant: 'error',
    });
    lightningElement.dispatchEvent(evt);
};