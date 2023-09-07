import {LightningElement} from 'lwc';
import startOver from "@salesforce/apex/InitialIngestor.startOver";

export default class IouStartOver extends LightningElement {

    handleDelete() {
        startOver()
            .then(() => {

            })
            .catch(error => {

            })
    }
}
