import {LightningElement, track, wire} from 'lwc';
import LightningConfirm from 'lightning/confirm';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import startOver from "@salesforce/apex/InitialIngestor.startOver";

import { subscribe, MessageContext } from 'lightning/messageService';
import IOU_POPULATED from '@salesforce/messageChannel/IOU_Populated__c';

export default class IouStartOver extends LightningElement {

    @wire(MessageContext)
    messageContext;

    @track showDeleteButton = false;
    @track showSpinner = false;

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
        this.showDeleteButton = payload.classCount > 0;
    }

    async requireConfirmation() {
        const confirmed = await LightningConfirm.open({
            message: 'Do you want to proceed?',
            label: 'Confirm Record Deletion',
            theme: 'warning'
        });
        if (confirmed) {
            this.showToast(
                'Confirmed!',
                'Deletion in progress, page will reload when complete.',
                'success',
                'sticky');
            this.handleDelete();
        }
    }

    handleDelete() {
        this.showSpinner = true;
        startOver()
            .then(response => {
                if (response.success) {
                    window.location.reload();
                }
                else {
                    this.showToast(response.title, response.message, 'error');
                }
            })
            .catch(error => {
                this.showToast('Failed to delete IOU records.', error.body.message, 'error');
            })
            .finally(() => {
                this.showSpinner = false;
            });
    }

    showToast(title, message, variant, mode) {
        mode = mode === '' ? 'dismissible' : mode;
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(event);
    }
}
