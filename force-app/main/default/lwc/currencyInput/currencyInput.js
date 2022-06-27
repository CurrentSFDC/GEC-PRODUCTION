/**
 * Created by Attention on 2021. 12. 17..
 */

import { LightningElement, api } from 'lwc';

export default class CurrencyInput extends LightningElement {

    @api currencyCode;
    @api value;
    @api disabled;

    get currencyDisplay() {
        return this.currencyCode == 'CAD' ? 'CA$' : '$';
    }

    fireOnChange(event) {
        this.value = (Math.round(parseFloat(event.target.value) * 100) / 100).toFixed(2);
        this.dispatchEvent(new CustomEvent("change"));
    }

}