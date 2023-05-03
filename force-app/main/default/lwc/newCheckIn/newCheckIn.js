import { LightningElement, api, track, wire } from 'lwc';
import createCheckIn from '@salesforce/apex/NewCheckInController.createCheckIn';
import deleteContentVersion from '@salesforce/apex/NewCheckInController.deleteContentVersion';
import { CurrentPageReference } from 'lightning/navigation'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class New_Check_In extends LightningElement {
    @api recordId;

    @track modal = true;
    @track disabled = false;

    @track name;
    @track notes;
    @track daylost;
    @track projectid;
    @track location;
    @track weather;
    @track documentId = [];
    @track fileId = [];

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.state.recordId;
        }
    }

    connectedCallback() {
        this.projectid = this.recordId;
        console.log(this.projectid + 'RecordIds');
        if (this.projectid != undefined) {
            this.disabled = true;
        }
    }
    @api opencheckin(){
        this.modal = true;
    }

    handleButtonAction(event) {
        try {
            let action = event.target.dataset.name;
            if (action === 'cancel') {
                console.log('Cancel Btn clicked');
                if (this.documentId.length > 0) {
                    deleteContentVersion({
                        documentId: this.documentId
                    })
                        .then(result => {

                        })
                        .catch((error) => {
                            console.log("Error acciured in deleteContentVersion apex method");
                            console.log(JSON.stringify(error));
                        })
                }
                this.modal = false;
            } else if (action === 'savenew') {
                console.log('Save and New Btn clicked');
                if ((this.name != null || this.name != undefined) && (this.name.trim() != '')) {
                    this.handleSaveData();
                    this.modal = true;
                    this.reset();
                }
            } else if (action === 'save') {
                console.log('Save Btn clicked');
                if ((this.name != null || this.name != undefined) && (this.name.trim() != '')) {
                    this.handleSaveData();
                    this.modal = false;
                }
            }
        } catch (error) {
            console.log("In the chatch block of handleButtonAction");
            console.log(JSON.stringify(error));
        }
    }

    handleInputChange(event) {
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
        this.projectid = '';
        this.location = '';
        this.weather = '';
        this.fileId = [];
        this.documentId = [];
    }

}