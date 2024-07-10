trigger RemoveContactLastNameFromAccountName on Contact (after delete) {
    Map<Id, List<Contact>> accountContactsMap = new Map<Id, List<Contact>>();

    // Populate the map with the contacts being deleted
    for (Contact con : Trigger.old) {
        if (con.AccountId != null) {
            if (!accountContactsMap.containsKey(con.AccountId)) {
                accountContactsMap.put(con.AccountId, new List<Contact>());
            }
            accountContactsMap.get(con.AccountId).add(con);
        }
    }

    // List to hold accounts to be updated
    List<Account> accountsToUpdate = new List<Account>();

    // Fetch all relevant accounts in one query
    List<Account> accounts = [SELECT Id, LastName__c FROM Account WHERE Id IN :accountContactsMap.keySet()];

    // Iterate over the accounts
    for (Account acc : accounts) {
        String accountLastName = acc.LastName__c;
        if (accountLastName != null ) {
            List<Contact> contacts = accountContactsMap.get(acc.Id);

            // Process each contact to remove their last name from the account's last name field
            for (Contact con : contacts) {
                String contactLastName = con.LastName;

                if (accountLastName.contains(contactLastName)) {
                    // Use regex to remove only the exact occurrence of the contact's last name
                    accountLastName = accountLastName.replace(contactLastName, '').trim();
                }
            }

            // Update the account's last name if changes were made
            if (!accountLastName.equals(acc.LastName__c)) {
                acc.LastName__c = accountLastName;
                accountsToUpdate.add(acc);
            }
        }
    }

    // Update the accounts
    if (!accountsToUpdate.isEmpty()) {
        update accountsToUpdate;
    }
}
