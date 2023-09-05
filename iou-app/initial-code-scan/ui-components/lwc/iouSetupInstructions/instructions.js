const getInstructions = () => {
    return [
        {
            title: 'Download Ruleset:',
            instruction: 'visit the link below to download',
            link: 'https://github.com/minniela/iou',
            linkText: 'IOU GitHub Repo'
        },
        {
            title: 'Install SF CLI:',
            instruction: 'skip this if already installed',
            link: 'https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_install_cli.htm',
            linkText: "Salesforce CLI Download"
        },
        {
            title: 'Install SFCA:',
            instruction: '<div class="slds-text-font_monospace">sfdx plugins:install @salesforce/sfdx-scanner</div>',
            link: 'https://forcedotcom.github.io/sfdx-scanner/en/v3.x/getting-started/install/',
            linkText: "SFCA Install Details"
        },
        {
            title: 'Run SFCA:',
            instruction: '<div class="slds-text-font_monospace">' +
                'sfdx scanner:run -f json -o scans/initialCodeScan.json -t force-app --pmdconfig level-0-tech-debt-ruleset.xml' +
                '</div>',
            link: 'https://forcedotcom.github.io/sfdx-scanner/en/v3.x/scanner-commands/run/',
            linkText: "SFCA Command Reference"
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
