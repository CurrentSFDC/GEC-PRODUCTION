import {api, LightningElement} from 'lwc';

export default class Lookup extends LightningElement {
    @api label;
    @api disabled;
    @api isLoading;
    @api selectedValue;
    @api placeholder;
    @api required;
    @api inputClass;
    @api variant;
    @api options;
    @api errorMessage;
    @api messageWhenInvalidValue = 'Invalid value'
    @api displayText;

    @api
    reportValidity() {
        let lookupInput = this.template.querySelector(`lightning-input`);
        if (lookupInput != null) {
            if (lookupInput.value != null && lookupInput.value !== "" && this.selectedValue == null) {
                lookupInput.setCustomValidity(this.messageWhenInvalidValue);
            } else {
                lookupInput.setCustomValidity("");
            }
            return lookupInput.reportValidity();
        }
        return false;
    }

    @api
    addErrorMessage(errorMessage) {
        let lookupInput = this.template.querySelector(`lightning-input`);
        if (lookupInput != null) {
            lookupInput.setCustomValidity(errorMessage);
            lookupInput.reportValidity();
        }
    }

    @api
    setSelectedValue(value) {
        console.log('selected lookup value ',value);
        this.selectedValue = value;
        this.template.querySelector(`lightning-input`).value = this.selectedValue;
    }

    get hasSelectedValue() {
        if (this.selectedValue == null || typeof(this.selectedValue) == 'undefined') {
            return false;
        }
        console.log('hasSelectedValue lookup value ' + JSON.stringify(this.selectedValue));
//        if (this.displayText == null || this.displayText == '') {
            if (JSON.stringify(this.selectedValue).includes('GE_LGT_EM_MaterialDescription__c')) {
                console.log('hasSelectedValue material detected');
                this.displayText = this.selectedValue.GE_LGT_EM_MaterialDescription__c;
            } else {
                console.log('hasSelectedValue other detected');
                this.displayText = this.selectedValue;
            }
//        }
        return this.selectedValue != null && this.selectedValue !== '';
    }

    get hasOptions() {
        return this.options != null && this.options.length > 0;
    }

    connectedCallback() {
        if (this.label == null || this.label.trim() === "") {
            this.variant = "label-hidden";
        }
    }

    renderedCallback() {
        if (this.errorMessage != null && this.errorMessage !== '') {
            this.addErrorMessage(this.errorMessage);
        }
        if (this.label == null || this.label.trim() === "") {
            this.template.querySelector('.container').classList.add('label-hidden');
        }
        if ((this.selectedValue == null || this.selectedValue === '')
            && this.options != null && this.options.length > 0) {
            this.buildDropdownResult()
        }
    }

    buildDropdownResult() {
        let searchText = this.template.querySelector(`lightning-input[id^=lookup-input]`).value;
        let re = new RegExp(searchText, 'gi');
        let option = this.template.querySelector('.dropdown-result');
        option.innerHTML = '';
        for (let i = 0; i < this.options.length; i++) {
            let li = document.createElement('li');
            li.setAttribute('role', 'presentation');
            li.className = 'slds-listbox__item';

            let div = document.createElement('div');
            div.className = 'slds-media slds-listbox__option slds-listbox__option_entity slds-listbox__option_has-meta';
            div.setAttribute('role', 'option');
            div.addEventListener('click', () => {
                this.handleRecordSelection(i);
            });

            let span1 = document.createElement('span');
            span1.className = 'slds-media__body';

            let span2 = document.createElement('span');
            span2.className = 'slds-listbox__option-meta slds-listbox__option-meta_entity slds-p-vertical_small';

            span2.innerHTML = this.options[i].replace(re, function (match) {
                return `<b style="color:black;">${match}</b>`
            });

            span1.appendChild(span2);
            div.appendChild(span2);
            li.appendChild(div);
            option.appendChild(li);
        }
    }

    handleReset(event) {
        this.selectedValue = null;
        this.options = null;
        this.dispatchEvent(new CustomEvent('reset', {bubbles: true, composed: true}));
    }

    handleRecordSelection(index) {
        try {
            this.options = null;
            const selectedEvent = new CustomEvent('select', {
                detail: {
                    index: index
                },
            });
            this.dispatchEvent(selectedEvent);
        } catch (error) {
            console.error(error);
        }
    }
}