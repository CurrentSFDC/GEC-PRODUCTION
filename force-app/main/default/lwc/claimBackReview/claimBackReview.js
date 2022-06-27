import { LightningElement, api } from 'lwc';

export default class ClaimBackReview extends LightningElement {

    @api mainDetails;
    @api accountCurrency;
    mapOptions = {
        'disableDefaultUI': true, // when true disables Map|Satellite, +|- zoom buttons
        'draggable': false, // when false prevents panning by dragging on the map
    };

    get isDistributor() {
        return localStorage.getItem('User Type') == 'Distributor';
    }

}