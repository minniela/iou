import {LightningElement, track, wire} from 'lwc';
import {getInstructions} from './instructions';
import initializeApp from '@salesforce/apex/InitialIngestor.initiate';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import { publish, MessageContext } from 'lightning/messageService';
import IOU_POPULATED from '@salesforce/messageChannel/IOU_Populated__c';

export default class IouSetupInstructions extends LightningElement {

    @wire(MessageContext)
    messageContext;

    @track staticResource = 'initialCodeScan';
    @track hasLink = true;
    @track showSpinner = false;
    @track hasNextStep = true;

    nextStepIndex = 0;
    nextStepTitle = getInstructions()[this.nextStepIndex].title;
    nextStepInstruction = getInstructions()[this.nextStepIndex].instruction;
    nextStepLink = getInstructions()[this.nextStepIndex].link;
    nextStepLinkText = getInstructions()[this.nextStepIndex].linkText;

    handleNextStep() {
        this.nextStepIndex += 1;
        const nextStep = getInstructions()[this.nextStepIndex];
        this.nextStepTitle = nextStep.title;
        this.nextStepInstruction = nextStep.instruction;

        this.hasLink = nextStep.link !== '';
        this.nextStepLink = nextStep.link;
        this.nextStepLinkText = nextStep.linkText;
    }

    handleStaticResourceInput(event) {
        this.staticResource = event.detail.value;
    }

    handlePopulateClick() {
        this.showSpinner = true;
        initializeApp({staticResource: this.staticResource})
            .then(result => {
                if (result.success) {
                    publish(this.messageContext, IOU_POPULATED);
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

    showToast(title, message) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: "error"
        });
        this.dispatchEvent(event);
    }
}
