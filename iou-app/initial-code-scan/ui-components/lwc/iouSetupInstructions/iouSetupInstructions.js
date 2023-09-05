import {LightningElement, track, wire} from 'lwc';
import {getInstructions} from './instructions';
import initializeApp from '@salesforce/apex/InitialIngestor.initiate';

import { publish, MessageContext } from 'lightning/messageService';
import IOU_POPULATED from '@salesforce/messageChannel/IOU_Populated__c';

export default class IouSetupInstructions extends LightningElement {

    @wire(MessageContext)
    messageContext;

    @track staticResource = 'initialCodeScan';
    @track hasLink = true;
    @track showSpinner = false;

    nextStepIndex = 0
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
                }
                else {
                    console.log(result.title);
                    console.log(result.message);
                }
            })
            .catch(error => {
                console.log(JSON.stringify(error));
            })
            .finally(() => {
               this.showSpinner = false;
            });
    }
}
