global class SalarySlipEmailService implements Messaging.InboundEmailHandler {
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope env) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        
        // Process the email and extract details (e.g., salary slip ID)
        // Assuming salary slip ID is in the email subject
        
        String salarySlipId = email.subject;
        Salary_Slip__c slip = [SELECT Id, Employee_Name__c, Employee_Email__c, Salary_Month__c, Attachment_URL__c FROM Salary_Slip__c WHERE Id = :salarySlipId LIMIT 1];
        
        if(slip != null) {
            sendSalarySlipEmail(slip);
        }
        
        result.success = true;
        return result;
    }
    
    public static void sendSalarySlipEmail(Salary_Slip__c slip) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new String[] {slip.Employee_Email__c});
        email.setSubject('Your Salary Slip for ' + slip.Salary_Month__c);
        email.setPlainTextBody('Dear ' + slip.Employee_Name__c + ',\n\nPlease find attached your salary slip for ' + slip.Salary_Month__c + '.');
        
        // Retrieve the attachment from URL (assuming it is stored in a public URL or accessible location)
        HttpRequest req = new HttpRequest();
        req.setEndpoint(slip.Attachment_URL__c);
        req.setMethod('GET');
        Http http = new Http();
        HttpResponse res = http.send(req);
        
        if (res.getStatusCode() == 200) {
            Blob pdfBlob = res.getBodyAsBlob();
            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
            attachment.setFileName('SalarySlip_' + slip.Salary_Month__c + '.pdf');
            attachment.setBody(pdfBlob);
            email.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment });
            
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
        }
    }
}
