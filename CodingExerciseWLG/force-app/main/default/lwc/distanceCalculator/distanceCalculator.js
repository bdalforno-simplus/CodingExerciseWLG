import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getTravelDetails from '@salesforce/apex/DistanceCalculatorController.getTravelDetails';

export default class DistanceCalculator extends LightningElement {
    @track origin = '';
    @track destination = '';
    @track distance = '';
    @track travelTime = '';
    @track travelCosts = {};
    @track error;

    handleOriginChange(event) {
        this.origin = event.target.value;
    }

    handleDestinationChange(event) {
        this.destination = event.target.value;
    }

    getDirections() {
        getTravelDetails({ origin: this.origin, destination: this.destination })
            .then(result => {
                this.distance = result.distance;
                this.travelTime = result.travelTime;
                this.travelCosts = result.travelCosts;
                this.error = undefined;
            })
            .catch(error => {
                this.error = error;
                this.distance = '';
                this.travelTime = '';
                this.travelCosts = {};
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error.body.message,
                        variant: 'error',
                    }),
                );
            });
    }
    
    get travelCostModes() {
        return Object.keys(this.travelCosts).map(key => ({
            mode: key,
            cost: this.travelCosts[key]
        }));
    }
}