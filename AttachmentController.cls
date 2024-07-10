public with sharing class AttachmentController {
    @AuraEnabled(cacheable=false)
    public static void deleteDuplicateAttachments() {
        List<ContentDocument> attachmentsToDelete = new List<ContentDocument>();
        Set<String> attachmentNames = new Set<String>();
       // List<ContentDocument> cvList = [SELECT Id, Title, FileType FROM ContentDocument];

        // Query attachments ordered by parent Id and created date
        for (ContentDocument cv : [SELECT Id, Title, FileType FROM ContentDocument]) {
            String attachmentKey = cv.Title;
        
            // If the attachment is a duplicate, add it to the list for deletion
            if (attachmentNames.contains(attachmentKey)) {
                attachmentsToDelete.add(cv);
            } else {
                attachmentNames.add(attachmentKey);
            }
        }
        
        // Delete duplicate attachments
        delete attachmentsToDelete;
    }

}