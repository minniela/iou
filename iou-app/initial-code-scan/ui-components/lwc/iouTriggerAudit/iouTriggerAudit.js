import {LightningElement, wire} from 'lwc';
import { subscribe, MessageContext } from 'lightning/messageService';
import IOU_POPULATED from '@salesforce/messageChannel/IOU_Populated__c';

export default class IOUTriggerAudit extends LightningElement {

    @wire(MessageContext)
    messageContext;

    connectedCallback() {
        this.subscribeToMessageChannel();
    }

    subscribeToMessageChannel() {
        this.subscription = subscribe(
            this.messageContext,
            IOU_POPULATED,
            (message) => this.handleMessage(message)
        );
    }

    handleMessage(message) {
        alert('got it!');
    }
}
