import {LightningElement} from 'lwc';
import {getInstructions} from './instructions';

export default class IouSetupInstructions extends LightningElement {

    nextStepIndex = 0
    nextStepTitle = getInstructions()[this.nextStepIndex].title;

    handleNextStep() {
        this.nextStepIndex += 1;
        this.nextStepTitle = getInstructions()[this.nextStepIndex].title;
    }
}
