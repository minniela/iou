import {LightningElement} from 'lwc';
import LightningConfirm from 'lightning/confirm';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import startOver from "@salesforce/apex/InitialIngestor.startOver";

export default class IouStartOver extends LightningElement {

    //todo: refresh the page upon deletion of records, instead of another layer of message service
    //todo: subscribe to message service to display conditionally

    async requireConfirmation() {
        const confirmed = await LightningConfirm.open({
            message: 'Do you want to proceed?',
            label: 'Confirm Record Deletion',
            theme: 'warning'
        });
        if (confirmed) {
            this.showToast('Confirmed!', 'Deletion in progress, page will reload when complete.', 'success');
            this.handleDelete();
        }
    }

    handleDelete() {
        startOver()
            .then(response => {
                if (response.success) {

                }
                else {
                    this.showToast(response.title, response.message, 'error');
                }
            })
            .catch(error => {
                this.showToast('Failed to delete IOU records.', error.body.message, 'error');
            })
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
}
