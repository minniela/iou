import {LightningElement} from 'lwc';
import LightningConfirm from 'lightning/confirm';
import startOver from "@salesforce/apex/InitialIngestor.startOver";

export default class IouStartOver extends LightningElement {

    //todo: add a response from the apex
    //todo: handle response and toast any error
    //todo: refresh the page upon deletion of records, instead of another layer of message service
    //todo: subscribe to message service to display conditionally

    async requireConfirmation() {
        const confirmed = await LightningConfirm.open({
            message: 'Do you want to proceed?',
            label: 'Confirm Record Deletion',
            theme: 'warning'
        });
        if (confirmed) {
            this.handleDelete();
        }
    }

    handleDelete() {
        startOver()
            .then(() => {

            })
            .catch(error => {

            })
    }
}
