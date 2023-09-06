import {LightningElement, wire, api} from 'lwc';

import { publish, MessageContext } from 'lightning/messageService';
import IOU_POPULATED from '@salesforce/messageChannel/IOU_Populated__c';

export default class IouInitializationCounter extends LightningElement {

    @wire(MessageContext)
    messageContext;

    @api
    publishCountData() {
        //todo: if this wire data, would it re-fire when data was populated
        publish(this.messageContext, IOU_POPULATED);
    }
}
