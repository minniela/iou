import {LightningElement, track} from 'lwc';
import {getInstructions} from './instructions';
import initializeApp from '@salesforce/apex/InitialIngestor.initiate';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class IouSetupInstructions extends LightningElement {

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

        this.hasNextStep = this.nextStepIndex < getInstructions().length - 1;
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
        this.template.querySelector('c-iou-initialization-counter').publishCountData();
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
