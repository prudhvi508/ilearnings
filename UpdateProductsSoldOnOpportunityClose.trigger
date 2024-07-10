trigger UpdateProductsSoldOnOpportunityClose on Opportunity (after update) {
    Set<Id> opportunityIds = new Set<Id>();

    // Collect Opportunity Ids where the stage is changed to Closed Won
    for (Opportunity opp : Trigger.new) {
        if (opp.StageName == 'Closed Won' && Trigger.oldMap.get(opp.Id).StageName != 'Closed Won') {
            opportunityIds.add(opp.Id);
        }
    }

    // Check if we have any opportunities to process
    if (!opportunityIds.isEmpty()) {
        // Query OpportunityLineItems related to these opportunities
        List<OpportunityLineItem> opportunityLineItems = [
            SELECT Id, Quantity, PricebookEntry.Product2Id
            FROM OpportunityLineItem
            WHERE OpportunityId IN :opportunityIds
        ];

        // Map to hold productId and total quantity sold
        Map<Id, Decimal> productSalesCountMap = new Map<Id, Decimal>();

        // Populate the map with the quantities sold
        for (OpportunityLineItem oli : opportunityLineItems) {
            Id productId = oli.PricebookEntry.Product2Id;
            Decimal quantitySold = oli.Quantity;

            if (productSalesCountMap.containsKey(productId)) {
                productSalesCountMap.put(productId, productSalesCountMap.get(productId) + quantitySold);
            } else {
                productSalesCountMap.put(productId, quantitySold);
            }
        }

        // List to hold Products to update
        List<Product2> productsToUpdate = new List<Product2>();

        // Query the Product records to update
        for (Id productId : productSalesCountMap.keySet()) {
            Product2 prod = [SELECT Id, No_of_Products_Sold__c FROM Product2 WHERE Id = :productId];
            prod.No_of_Products_Sold__c = (prod.No_of_Products_Sold__c != null ? prod.No_of_Products_Sold__c : 0) + productSalesCountMap.get(productId);
            productsToUpdate.add(prod);
        }

        // Update the Product records
        if (!productsToUpdate.isEmpty()) {
            update productsToUpdate;
        }
    }
}
