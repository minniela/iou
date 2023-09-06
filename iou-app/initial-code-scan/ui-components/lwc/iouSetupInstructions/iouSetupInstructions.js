import {LightningElement, track, wire} from 'lwc';
import {getInstructions} from './instructions';
import initializeApp from '@salesforce/apex/InitialIngestor.initiate';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import { subscribe, MessageContext } from 'lightning/messageService';
import IOU_POPULATED from '@salesforce/messageChannel/IOU_Populated__c';

export default class IouSetupInstructions extends LightningElement {

    @wire(MessageContext)
    messageContext;

    @track staticResource = 'initialCodeScan';
    @track hasLink = true;
    @track showSpinner = false;
    @track hasNextStep = true;

    nextStepIndex;
    nextStepTitle;
    nextStepInstruction;
    nextStepLink;
    nextStepLinkText;

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
        this.nextStepIndex = payload.classCount > 0 ? payload.triggerAuditHasStarted ? 7 : 6 : 0;
        const currentStep = getInstructions()[this.nextStepIndex];
        this.configureThisStep(currentStep);
    }

    configureThisStep(step) {
        this.nextStepTitle = step.title;
        this.nextStepInstruction = step.instruction;
        this.hasLink = step.link !== '';
        this.nextStepLink = step.link;
        this.nextStepLinkText = step.linkText;

        this.hasNextStep = this.nextStepIndex < getInstructions().length - 1;
    }

    handleNextStep() {
        this.nextStepIndex += 1;
        const currentStep = getInstructions()[this.nextStepIndex];
        this.configureThisStep(currentStep);
    }

    handleStaticResourceInput(event) {
        this.staticResource = event.detail.value;
    }

    handlePopulateClick() {
        this.showSpinner = true;
        initializeApp({staticResource: this.staticResource})
            .then(result => {
                if (result.success) {
                    this.checkCounter();
                    this.handleNextStep();
                }
                else {
                    this.showToast(result.title, result.message);
                }
            })
            .catch(error => {
                this.showToast('Ensure the Static Resource Name is correct.', error.body.message);
            })
            .finally(() => {
               this.showSpinner = false;
            });
    }

    checkCounter() {
        this.template.querySelector('c-iou-initialization-counter').checkForCountDetails();
    }

    showToast(title, message) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: "error"
        });
        this.dispatchEvent(event);
    }
}
