import { LightningElement, track, api } from 'lwc';

export default class ProjectCheckLists extends LightningElement {
    @api recordId;
    @api objectApiName;

    @track fieldsOfCheckLists = ['WASD_Verification__c', 'Tree_Permit__c', 'Admin_Adjustement__c', 'Sewer_Capacity__c', 'ASPR__c', 'Workforce__c', 'PHCD__c'];

    handleSubmit(event) {
        event.preventDefault(); // stop the form from submitting
        const fields = event.detail.fields;
        // fields.LastName = 'My Custom Last Name'; // modify a field
        this.template.querySelector('lightning-record-form').submit(fields);
    }


    // ================ //

    // fields_per_section = [
    //     {
    //         label: "Permitting Checklist",
    //         fields: [
    //             "WASD_Verification__c",
    //             "Tree_Permit__c",
    //             "Admin_Adjustement__c",
    //             "Sewer_Capacity__c",
    //             "ASPR__c",
    //             "Workforce__c",
    //             "PHCD__c"
    //         ]
    //     },
    //     {
    //         label: "Address",
    //         fields: [
    //             "Street__c",
    //             "House_Number__c",
    //             "Postal_Code__c",
    //             "City__c"
    //         ]
    //     },
    //     {
    //         label: "Contact Info",
    //         sublabel: "",
    //         fields: ["Email_Address__c",
    //             "Phone_Number__c"]
    //     }
    // ];
}