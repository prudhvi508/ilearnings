trigger AddContactsToOpportunityContactRoles on Opportunity (after insert) {
    // Collecting Account Ids from new Opportunities
    Set<Id> accountIds = new Set<Id>();
    for (Opportunity opp : Trigger.new) {
        if (opp.AccountId != null) {
            accountIds.add(opp.AccountId);
        }
    }
    
    // Querying for Contacts associated with the same Account
    Map<Id, List<Contact>> accountIdToContacts = new Map<Id, List<Contact>>();
    List<Contact> relatedContacts = [SELECT Id, AccountId FROM Contact WHERE AccountId IN :accountIds];
    
    // Grouping Contacts by Account Id
    for (Contact con : relatedContacts) {
        if (!accountIdToContacts.containsKey(con.AccountId)) {
            accountIdToContacts.put(con.AccountId, new List<Contact>());
        }
        accountIdToContacts.get(con.AccountId).add(con);
    }
    
    // Adding Contacts to Opportunity Contact Roles
    List<OpportunityContactRole> oppContactRolesToAdd = new List<OpportunityContactRole>();
    for (Opportunity opp : Trigger.new) {
        if (accountIdToContacts.containsKey(opp.AccountId)) {
            for (Contact con : accountIdToContacts.get(opp.AccountId)) {
                OpportunityContactRole role = new OpportunityContactRole();
                role.OpportunityId = opp.Id;
                role.ContactId = con.Id;
                role.Role = 'Decision Maker'; // You can set the role as per your requirement
                oppContactRolesToAdd.add(role);
            }
        }
    }
    
    // Inserting Opportunity Contact Roles
    if (!oppContactRolesToAdd.isEmpty()) {
        insert oppContactRolesToAdd;
    }
}
