import { LightningElement, api, track, wire } from 'lwc';
import createCheckIn from '@salesforce/apex/NewCheckInController.createCheckIn';
import deleteContentVersion from '@salesforce/apex/NewCheckInController.deleteContentVersion';
import { CurrentPageReference } from 'lightning/navigation'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';


export default class New_Check_In extends LightningElement {
    @api recordId;

    @track modal = true;                     // to show/hide modal
    @track disabled = false;                 // to disable the project field
    @track name;
    @track notes;
    @track daylost;
    @track projectid;
    @track location;
    @track weather;
    @track documentId = [];                // to get the document id of the attachment(for deleting files on cancel click)
    @track fileId = [];                   // to get the contentversion id (for attaching to the record)

    // get the record id when it open using quick action button
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.state.recordId;
        } 
    }

    connectedCallback() {
        this.projectid = this.recordId;
        if (this.projectid != undefined) {
            this.disabled = true;             // to disable the field if it open using quick action button    
        }
    }

    renderedCallback(){
        // to apply css on when it open without using quick action button in the record
        if(this.projectid == undefined){
            let element = this.template.querySelector('.popup');
            element.style = 'width:60%; margin: 7% auto;';
            element = this.template.querySelector('.background');
            element.style = 'display:block;';
        }
    }

    handleButtonAction(event) {
        try {
            let action = event.target.dataset.name;
            if (action === 'cancel') {
                if(this.projectid != undefined || this.projectid != null){
                     this.dispatchEvent(new CloseActionScreenEvent());        // to close the slds modal of quick action
                }
               // to delete files if it click cancel after uploading images
                if (this.documentId.length > 0) {
                    deleteContentVersion({
                        documentId: this.documentId
                    })
                        .then(result => {
                            console.log('OUTPUT : deleted files');
                        })
                        .catch((error) => {
                            console.log("Error acciured in deleteContentVersion apex method");
                            console.log(JSON.stringify(error));
                        })
                }
                this.modal = false;
            } else if (action === 'savenew') {
               // to reset every field
                if ((this.name != null || this.name != undefined) && (this.name.trim() != '')) {
                    this.handleSaveData();
                    this.modal = true;
                    this.reset();
                }
            } else if (action === 'save') {
               // to save and close the popup
                if ((this.name != null || this.name != undefined) && (this.name.trim() != '')) {
                    this.handleSaveData();
                    this.modal = false;
                    if(this.projectid != undefined || this.projectid != null){
                     this.dispatchEvent(new CloseActionScreenEvent());
                }
                }
            }
        } catch (error) {
            console.log("In the chatch block of handleButtonAction");
            console.log(JSON.stringify(error));
        }
    }

    handleInputChange(event) {
        // to get the input of every fields
        if (event.currentTarget.dataset.name === 'name') {
            this.name = event.target.value;
        } else if (event.currentTarget.dataset.name === 'notes') {
            this.notes = event.target.value;
        } else if (event.currentTarget.dataset.name === 'dalylost') {
            this.daylost = event.target.value;
        } else if (event.currentTarget.dataset.name === 'projectid') {
            this.projectid = event.target.value;
        } else if (event.currentTarget.dataset.name === 'location') {
            this.location = event.target.value;
        } else if (event.currentTarget.dataset.name === 'weather') {
            this.weather = event.target.value;
        }
    }

    handleSaveData() {
        // to save data in the object 
        try {
            let checkInRecord = {
                'sobjectType': 'buildertek__Check_In__c'
            };
            checkInRecord['Name'] = this.name;
            checkInRecord['buildertek__Notes__c'] = this.notes;
            checkInRecord['buildertek__Days_Lost__c'] = this.daylost;
            checkInRecord['buildertek__Project__c'] = this.projectid;
            checkInRecord['buildertek__Reporting_Location__c'] = this.location;
            checkInRecord['buildertek__Weather__c'] = this.weather;

            createCheckIn({
                record: checkInRecord,
                fileIds: this.fileId
            })
                .then(result => {
                    console.log('Res ==>' + result);
                    if (result != null) {
                        this.showToastNotification('Success', 'Check-In Created Successfully', 'success');
                    } else {
                        this.showToastNotification('Error', 'Something Went Wrong', 'error');
                    }
                })
                .catch((error) => {
                    console.log("Error acciured in createCheckIn apex method");
                    console.log(JSON.stringify(error));
                })
        } catch (error) {
            console.log("In the chatch block of handleSaveData");
            console.log(JSON.stringify(error));
        }
    }

    showToastNotification(title, message, variant) {
        try {
            const evt = new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            });
            this.dispatchEvent(evt);
        } catch (error) {
            console.log(JSON.stringify(error));
        }
    }

    openfileUpload(event) {
        try {
            event.detail.files.forEach(element => {
                this.documentId.push(element.documentId)
                this.fileId.push(element.contentVersionId);
            });
        } catch (error) {
            console.log(JSON.stringify(error));
        }
    }
    reset() {
        this.name = '';
        this.notes = '';
        this.daylost = '';
        if(recordId == undefined){  // it is used to not clear value of project field if it will create from record quick action button
        this.projectid = '';
        }
        this.location = '';
        this.weather = '';
        this.fileId = [];
        this.documentId = [];
    }

}