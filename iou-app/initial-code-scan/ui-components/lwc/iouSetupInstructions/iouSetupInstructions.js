import {LightningElement} from 'lwc';

export default class IouSetupInstructions extends LightningElement {

    nextStepIndex = 0
    nextStepInstruction = STEPS[this.nextStepIndex].title;

    handleNextStep() {
        this.nextStepIndex += 1;
        this.nextStepInstruction = STEPS[this.nextStepIndex].title;
    }
}

const STEPS = [
    {
        title: 'Download Ruleset:',
        instruction: '',
        link: ''
    },
    {
        title: 'Install SFCA:',
        instruction: 'sfdx plugins:install @salesforce/sfdx-scanner',
        link: ''
    },
    {
        title: 'Run SFCA:',
        instruction: 'sfdx scanner:run --format json --target "force-app" --outfile "scans/initialCodeScan.json" --pmdconfig "scans/level-0-tech-debt-ruleset.xml"',
        link: ''
    },
    {
        title: 'Upload JSON:',
        instruction: '',
        link: ''
    },
    {
        title: 'Initialize App:',
        instruction: '',
        link: ''
    },
    {
        title: 'Audit Triggers:',
        instruction: '',
        link: ''
    },
    {
        title: 'All Set:',
        instruction: '',
        link: ''
    }
]
