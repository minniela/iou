import {LightningElement} from 'lwc';

export default class IouSetupInstructions extends LightningElement {

    nextStepInstruction = 'Install SFCA:';

    handleNextStep() {
        this.nextStepInstruction = 'Run SFCA:';
    }
}
