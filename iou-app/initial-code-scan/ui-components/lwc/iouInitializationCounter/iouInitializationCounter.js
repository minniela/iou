import {LightningElement, wire, api} from 'lwc';
import getCountDetails from '@salesforce/apex/InitializationCounterService.getViolationCountDetails';

import { publish, MessageContext } from 'lightning/messageService';
import IOU_POPULATED from '@salesforce/messageChannel/IOU_Populated__c';

export default class IouInitializationCounter extends LightningElement {

    @wire(MessageContext)
    messageContext;

    connectedCallback() {
        this.checkForCountDetails();
    }

    publishCountData(payload) {
        //todo: if this wire data, would it re-fire when data was populated
        console.log(JSON.stringify(payload));
        //publish(this.messageContext, IOU_POPULATED);
    }

    @api
    checkForCountDetails() {
        getCountDetails()
            .then(response => {
                this.publishCountData(response);
            })
            .catch(error => {
                console.log(JSON.stringify(error));
            })
    }
}
