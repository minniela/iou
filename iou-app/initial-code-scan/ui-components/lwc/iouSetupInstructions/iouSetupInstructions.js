import {LightningElement, track} from 'lwc';
import {getInstructions} from './instructions';
import initializeApp from '@salesforce/apex/InitialIngestor.initiate';

export default class IouSetupInstructions extends LightningElement {

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
        initializeApp({staticResource: ''})
            .then(result => {

            })
            .catch(error => {

            });
    }
}
