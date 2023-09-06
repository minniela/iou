import {LightningElement, wire} from 'lwc';
import { subscribe, MessageContext } from 'lightning/messageService';
import IOU_POPULATED from '@salesforce/messageChannel/IOU_Populated__c';

export default class IouClassCount extends LightningElement {

    @wire(MessageContext)
    messageContext;

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
        console.log('class counter has handled it');
        console.log(JSON.stringify(payload));
    }
}
