const getInstructions = () => {
    return [
        {
            title: 'Download Ruleset:',
            instruction: '',
            link: ''
        },
        {
            title: 'Install SFCA:',
            instruction: '<div class="slds-text-font_monospace">sfdx plugins:install @salesforce/sfdx-scanner</div>',
            link: ''
        },
        {
            title: 'Run SFCA:',
            instruction: '<div class="slds-text-font_monospace">' +
                'sfdx scanner:run -f json -o scans/initialCodeScan.json -t force-app --pmdconfig level-0-tech-debt-ruleset.xml' +
                '</div>',
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
    ];
}

export {getInstructions};
