import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord } from 'lightning/uiRecordApi';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import deleteExpensesForSystem from '@salesforce/apex/SystemController.deleteExpensesForSystem';

export default class DeleteSystemExpensesLWC extends LightningElement {
    @api recordId;
    @track isModalOpen = false;
    @track isDeleted = false;
    @track isLoading = false;
    
    handleDeleteRequest() {
        this.isModalOpen = true;
    }

    handleDeletion() {
        this.isModalOpen = false;
        this.isLoading = true;

        deleteExpensesForSystem({ recordId: this.recordId })
        .then(result => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Deleted!',
                    message: 'Can\'t get them back now! Well, you could restore them from the recycling bin.',
                    variant: 'success'
                })
            );
            this.isLoading = false;
            getRecordNotifyChange([{recordId: this.recordId}]);
            updateRecord({ fields: { Id: this.recordId } });
        });

        this.isDeleted = true;

    }

    closeModal() {
        this.isModalOpen = false;
    }

}