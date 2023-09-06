import {LightningElement, wire, track} from 'lwc';
import { subscribe, MessageContext } from 'lightning/messageService';
import IOU_POPULATED from '@salesforce/messageChannel/IOU_Populated__c';

export default class IouViolationCount extends LightningElement {

    @wire(MessageContext)
    messageContext;

    @track violationCount = 0;
    @track violationsFound = false;

    connectedCallback() {
        this.subscribeToMessageChannel();
    }

    subscribeToMessageChannel() {
        this.subscription = subscribe(
            this.messageContext,
            IOU_POPULATED,
            (payload) => this.handleMessage(payload)
        );
    }

    handleMessage(payload) {
        this.violationCount = payload.violationCount;
        this.violationsFound = this.violationCount > 0;
    }
}
