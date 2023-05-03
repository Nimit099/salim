import { LightningElement } from 'lwc';

export default class CreateNewProjectOnNewButton extends LightningElement {

    successNewRecordInsert() {

    }

    submitRecordForm(event) {
        event.preventDefault(); // stop the form from submitting
        const fields = event.detail.fields;
        // fields.LastName = 'My Custom Last Name'; // modify a field
        this.template.querySelector('lightning-record-form').submit(fields);
    }

    handleRecordEditFormLoad(event) {
        console.log('Layout => ', JSON.stringify(event.detail.layout));
        this.uiPageLayoutView = event.detail.layout;
    }


}