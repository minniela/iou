import {LightningElement, wire, track} from 'lwc';
import { subscribe, MessageContext } from 'lightning/messageService';
import IOU_POPULATED from '@salesforce/messageChannel/IOU_Populated__c';

export default class IouClassCount extends LightningElement {

    @wire(MessageContext)
    messageContext;

    @track classCount = 0;
    @track classesFound = false;

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
        this.classCount = payload.classCount;
        this.classesFound = this.classCount > 0;
    }
}
