import {LightningElement, track, wire} from 'lwc';
import {getInstructions} from './instructions';
import initializeApp from '@salesforce/apex/InitialIngestor.initiate';

import { publish, MessageContext } from 'lightning/messageService';
import IOU_POPULATED from '@salesforce/messageChannel/IOU_Populated__c';

export default class IouSetupInstructions extends LightningElement {

    @wire(MessageContext)
    messageContext;

    @track hasLink = true;

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

    handlePopulateClick() {
        //todo: add spinner
        //todo: add support for static resource name input
        const scanFileName = 'defaultCodeScan';
        initializeApp({staticResource: scanFileName})
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
            });
    }
}
