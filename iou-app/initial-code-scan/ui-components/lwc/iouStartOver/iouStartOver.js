import {LightningElement} from 'lwc';
import startOver from "@salesforce/apex/InitialIngestor.startOver";

export default class IouStartOver extends LightningElement {

    //todo: prompt user to confirm the destructive action
    //todo: add a response from the apex
    //todo: handle response and toast any error
    //todo: refresh the page upon deletion of records, instead of another layer of message service
    //todo: subscribe to message service to display conditionally

    handleDelete() {
        startOver()
            .then(() => {

            })
            .catch(error => {

            })
    }
}
