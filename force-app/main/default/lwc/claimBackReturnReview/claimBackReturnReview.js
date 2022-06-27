import { LightningElement, api, track } from 'lwc';

export default class StockBalancingReturnReview extends LightningElement {

    @api mainDetails = {};
    @api itemList = [];
    @api accountCurrency;

    @track mapMarker =[];
    mapOptions = {
                'disableDefaultUI': true, // when true disables Map|Satellite, +|- zoom buttons
                'draggable': false, // when false prevents panning by dragging on the map
    };

    @api provideDataToReview(main, products){
        this.mainDetails = main;
        this.itemList = products;

        this.mapMarker = [{
            location: {
                Country: main.mapCountry,
                City: main.mapCity,
                State: main.mapState,
                Street: main.mapStreet
            }}];
    };
}