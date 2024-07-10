trigger CreateDefaultContact on Account (after insert) {
    List<Contact> contactsToInsert = new List<Contact>();
    
    for (Account acc : Trigger.new) {
        // Retrieve the number of employees from the Account record
        Integer numberOfEmployees = acc.NumberOfEmployees;
        
        // Create default contact records based on the number of employees
        for (Integer i = 0; i < numberOfEmployees; i++) {
            Contact defaultContact = new Contact(
                FirstName = 'Default',
                LastName = 'Contact',
                AccountId = acc.Id
            );
            contactsToInsert.add(defaultContact);
        }
    }
    
    // Insert the default contact records
    if (!contactsToInsert.isEmpty()) {
        insert contactsToInsert;
    }
}
