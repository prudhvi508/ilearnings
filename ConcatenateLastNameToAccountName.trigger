trigger ConcatenateLastNameToAccountName on Contact (after insert) {
    List<Account> accountsToUpdate = new List<Account>();
    
    // Map to store the Contact's last name against the related Account Id
    Map<Id, String> accountIdToLastNameMap = new Map<Id, String>();
    
    for (Contact con : Trigger.new) {
        // Add Contact's last name and related Account Id to the map
        accountIdToLastNameMap.put(con.AccountId, con.LastName);
    }
    
    // Retrieve the related Accounts
    accountsToUpdate = [SELECT Id, Name FROM Account WHERE Id IN :accountIdToLastNameMap.keySet()];
    
    for (Account acc : accountsToUpdate) {
        // Concatenate Contact's last name to the Account's last name
         acc.Name +=' ' + accountIdToLastNameMap.get(acc.Id);
    }
    
    // Update the Accounts
    if (!accountsToUpdate.isEmpty()) {
        update accountsToUpdate;
    }
}
