import { LightningElement, api, track } from 'lwc';
import createCheckIn from '@salesforce/apex/NewCheckInController.createCheckIn';
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

    connectedCallback() {
        this.projectid = this.recordId;
        if (this.projectid != undefined) {
            this.disabled = true;
        }
    }

    handleButtonAction(event) {
        try {
            let action = event.target.dataset.name;
            if (action === 'cancel') {
                console.log('Cancel Btn clicked');
                this.modal = false;
            } else if (action === 'savenew') {
                console.log('Save and New Btn clicked');
                if ((this.name != null || this.name != undefined) && (this.name.trim() != '')) {
                    this.handleSaveData();
                    this.modal = true;
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
        console.log(event.target.value);
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
                record: checkInRecord
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

}