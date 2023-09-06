import {LightningElement, wire, api} from 'lwc';
import getCountDetails from '@salesforce/apex/InitializationCounterService.getViolationCountDetails';

import { publish, MessageContext } from 'lightning/messageService';
import IOU_POPULATED from '@salesforce/messageChannel/IOU_Populated__c';

export default class IouInitializationCounter extends LightningElement {

    @wire(MessageContext)
    messageContext;

    connectedCallback() {
        this.publishCountData();
    }

    @api
    publishCountData() {
        //todo: if this wire data, would it re-fire when data was populated
        this.checkForCountDetails();
        //publish(this.messageContext, IOU_POPULATED);
    }

    checkForCountDetails() {
        getCountDetails()
            .then(response => {
                console.log(JSON.stringify(response));
            })
            .catch(error => {
                console.log(JSON.stringify(error));
            })
    }
}
