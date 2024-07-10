import { LightningElement } from 'lwc';
import deleteDuplicateAttachments from '@salesforce/apex/AttachmentController.deleteDuplicateAttachments';

export default class DeleteDuplicateAttachments extends LightningElement {
    error;

    deleteDuplicates() {
        deleteDuplicateAttachments()
            .then(() => {
                // Handle success
                console.log('Duplicate attachments deleted successfully.');
            })
            .catch(error => {
                // Handle error
                this.error = error.body.message;
                console.error('Error deleting duplicate attachments: ' + JSON.stringify(error));
            });
    }

}