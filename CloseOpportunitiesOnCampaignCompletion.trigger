trigger CloseOpportunitiesOnCampaignCompletion on Campaign (after update) {
    // List to hold Opportunities to update
    List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
    
    // Collecting Campaign Ids where status is changed to 'Completed'
    Set<Id> completedCampaignIds = new Set<Id>();
    for (Campaign camp : Trigger.new) {
        Campaign oldCamp = Trigger.oldMap.get(camp.Id);
        if (camp.Status == 'Completed' && oldCamp.Status != 'Completed') {
            completedCampaignIds.add(camp.Id);
        }
    }
    
    // Query for Opportunities associated with completed Campaigns
    List<Opportunity> opportunities = [SELECT Id, StageName, HasOpportunityLineItem 
                                      FROM Opportunity 
                                      WHERE CampaignId IN :completedCampaignIds 
                                      AND IsClosed = false];
    
    for (Opportunity opp : opportunities) {
        if (opp.HasOpportunityLineItem) {
            opp.StageName = 'Closed Won';
        } else {
            opp.StageName = 'Closed Lost';
        }
        opportunitiesToUpdate.add(opp);
    }
    
    // Update Opportunities
    if (!opportunitiesToUpdate.isEmpty()) {
        update opportunitiesToUpdate;
    }
}
