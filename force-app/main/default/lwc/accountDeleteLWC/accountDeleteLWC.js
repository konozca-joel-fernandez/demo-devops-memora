import { LightningElement, track, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

export default class AccountDeleteLWC extends LightningElement {
    @track accountId;
    @track accountName;
    @track hasContacts = false;
    @track showConfirmation = false;
    @track disableDelete = false;
    @track message = '';

    @wire(getRecord, { recordId: '$accountId', fields: ['Account.Name'] })
    wiredAccount({ error, data }) {
        if (data) {
            this.accountName = getFieldValue(data, 'Account.Name');
            this.message = '';
        } else if (error) {
            this.message = 'Error al cargar la cuenta';
            this.accountName = null;
        }
    }

    handleInputChange(event) {
        this.accountId = event.target.value;
        this.accountName = '';
        this.hasContacts = false;
        this.showConfirmation = false;
        this.disableDelete = false;
        this.message = '';
    }

    handleDelete() {
        this.showConfirmation = true;
    }

    handleCancelDelete() {
        this.showConfirmation = false;
    }
}