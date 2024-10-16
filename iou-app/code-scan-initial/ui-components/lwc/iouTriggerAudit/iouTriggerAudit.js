import {LightningElement, wire, track} from 'lwc';
import { subscribe, MessageContext } from 'lightning/messageService';
import IOU_POPULATED from '@salesforce/messageChannel/IOU_Populated__c';
import flagApex from '@salesforce/apex/TriggerAuditController.flagApexClass';
import Toast from 'lightning/toast';

export default class IOUTriggerAudit extends LightningElement {

    className;

    @wire(MessageContext)
    messageContext;

    @track classesCreated = false;

    subscription = null;

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
        this.classesCreated = payload.classCount > 0;
    }

    saveClass() {
        flagApex({className: this.className})
            .then(wasSuccessful => {
                if (wasSuccessful === true) {
                    this.showToast('The Apex Class was successfully audited!', 'success');
                }
                else {
                    this.showToast('The class was unable to be saved. Checks the debug logs for more info.', 'error');
                }
            })
            .catch(error => {
                this.showToast('The class was unable to be saved. See the browser\'s console output for more info.', 'error');
                console.log(JSON.stringify(error));
            })
    }

    showToast(message, result) {
        Toast.show({
            label: 'Trigger Audit Save Result',
            message: message,
            variant: result
        }, this);
    }
}
