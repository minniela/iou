const getInstructions = () => {
    const hostname = window.location.hostname;
    return [
        {
            title: 'Download the Ruleset',
            instruction: 'visit the link below to download',
            link: 'https://github.com/minniela/iou',
            linkText: 'IOU GitHub Repo'
        },
        {
            title: 'Install the SF CLI',
            instruction: 'skip this if already installed',
            link: 'https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_install_cli.htm',
            linkText: "Salesforce CLI Download"
        },
        {
            title: 'Install SFCA',
            instruction: '<div class="slds-text-font_monospace">sfdx plugins:install @salesforce/sfdx-scanner</div>',
            link: 'https://forcedotcom.github.io/sfdx-scanner/en/v3.x/getting-started/install/',
            linkText: "SFCA Install Details"
        },
        {
            title: 'Run SFCA',
            instruction: '<div class="slds-text-font_monospace">' +
                'sfdx scanner:run -f json -o initialCodeScan.json -t force-app --pmdconfig level-0-tech-debt-ruleset.xml' +
                '</div>',
            link: 'https://forcedotcom.github.io/sfdx-scanner/en/v3.x/scanner-commands/run/',
            linkText: "SFCA Command Reference"
        },
        {
            title: 'Upload the JSON',
            instruction: '<div>create a Static Resource from the ' +
                '<span class="slds-text-font_monospace">scans/initialCodeScan.json</span> ' +
                'file created in the last step</div>',
            link: 'https://' + hostname + '/lightning/setup/StaticResources/home',
            linkText: 'Create Static Resource'
        },
        {
            title: 'Initialize the App',
            instruction: '',
            link: ''
        },
        {
            title: 'Audit the Triggers',
            instruction: 'find the Trigger Audit instructions in the side panel',
            link: 'https://' + hostname + '/lightning/o/Apex_Class__c/list',
            linkText: 'Visit Apex Class Records'
        },
        {
            title: 'You\'re All Set!',
            instruction: 'review the level of Apex Tech Debt',
            link: 'https://' + hostname + '', //todo: add link to report or dashboard,
            linkText: 'IOU Metrics Report' //todo: update text after solution is created
        }
    ];
}

export {getInstructions};
