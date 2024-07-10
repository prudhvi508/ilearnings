trigger AlertOnOpportunityCloseNoLineItems on Opportunity (before update) {
    for (Opportunity opp : Trigger.new) {
        if (opp.StageName != 'Closed Won' && opp.StageName != 'Closed Lost') {
            continue; // Skip Opportunities not being closed
        }
        
        // Query for Opportunity Line Items count
        Integer lineItemCount = [SELECT COUNT() FROM OpportunityLineItem WHERE OpportunityId = :opp.Id];
        
        if (lineItemCount == 0) {
            opp.addError('Opportunity cannot be closed without Opportunity Line Items.');
        }
    }
}
