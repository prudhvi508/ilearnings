trigger CopyAccountBillingAddressToContact on Contact (before insert, before update) {
    // Collect Contact Ids where COPY ADDRESS FROM ACCOUNT checkbox is true
    Set<Id> contactIdsWithCopyAddress = new Set<Id>();
    for (Contact con : Trigger.new) {
        if (con.Copy_Address_From_Account__c) {
            contactIdsWithCopyAddress.add(con.Id);
        }
    }
    
    // Query for Contacts and their associated Account Billing Addresses
    Map<Id, Account> accountMap = new Map<Id, Account>();
    for (Contact con : [SELECT Id, AccountId, Account.BillingStreet, Account.BillingCity, Account.BillingState,
                                Account.BillingPostalCode, Account.BillingCountry
                        FROM Contact
                        WHERE Id IN :contactIdsWithCopyAddress]) {
        if (con.AccountId != null) {
            accountMap.put(con.AccountId, con.Account);
        }
    }
    
    // Update Contact Mailing Address fields
    for (Contact con : Trigger.new) {
        if (con.Copy_Address_From_Account__c && accountMap.containsKey(con.AccountId)) {
            Account acc = accountMap.get(con.AccountId);
            con.MailingStreet = acc.BillingStreet;
            con.MailingCity = acc.BillingCity;
            con.MailingState = acc.BillingState;
            con.MailingPostalCode = acc.BillingPostalCode;
            con.MailingCountry = acc.BillingCountry;
        }
    }
}
