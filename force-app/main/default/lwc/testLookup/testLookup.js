import {api, LightningElement} from 'lwc';


export default class TestLookup extends LightningElement {
    @api label;
    @api disabled;
    @api isSearching;
    @api selectedValue;
    @api selectedOrdValue;
    @api placeholder;
    @api required;
    @api inputClass;
    @api variant;
    @api options;
    @api errorMessage;
    @api messageWhenInvalidValue = 'Invalid value'

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
        this.selectedValue = value;
        this.template.querySelector(`lightning-input`).value = this.selectedValue;
    }

    get hasSelectedValue() {
        return this.selectedValue != null && this.selectedValue !== '';
    }

    @api
    setSelectedOrdValue(value) {
        this.selectedOrdValue = value;
        this.template.querySelector(`lightning-input`).value = this.selectedOrdValue;
    }

    get hasSelectedOrdValue() {
        return this.selectedOrdValue != null && this.selectedOrdValue !== '';
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
        //console.log('testLookup - Selected Value: '+this.selectedValue);
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
        if ((this.selectedOrdValue == null || this.selectedOrdValue === '')
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

            let spanA = document.createElement('span');
            spanA.className = 'slds-media__figure slds-listbox__option-icon';

            let spanB = document.createElement('span');
            spanB.className = 'slds-icon_container';

            let spanD = document.createElement('span');
            spanD.className = 'slds-media__figure slds-listbox__option-icon';

            let spanE = document.createElement('span');
            spanE.className = 'slds-icon_container slds-box slds-icon-standard-form';

            let spanC = document.createElement('lightning-icon');
            spanC.setAttribute('icon-name','standard:account');
            


            let span2 = document.createElement('span');
            span2.className = 'slds-listbox__option-meta slds-listbox__option-meta_entity slds-p-vertical_small';

            span2.innerHTML = this.options[i].replace(re, function (match) {
                return `<b style="color:black;">${match}</b>`
            });

            //span2.appendChild(spanA);
            spanD.appendChild(spanE);

            //spanB.appendChild(spanC);
            span2.appendChild(spanB);
            span1.appendChild(span2);
            
            //div.appendChild(spanD);
            div.appendChild(span2);
            
            li.appendChild(div);
            option.appendChild(li);
        }
    }

    handleReset(event) {
        this.selectedValue = null;
        this.selectedOrdValue= null;
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