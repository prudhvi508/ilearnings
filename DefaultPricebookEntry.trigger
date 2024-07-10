trigger DefaultPricebookEntry on Product2 (after insert) {
    // Retrieve the Standard Pricebook Id
    Id standardPricebookId = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1].Id;
    
    // List to hold new Pricebook Entries
    List<PricebookEntry> newPricebookEntries = new List<PricebookEntry>();
    
    // Loop through all the new products
    for (Product2 product : Trigger.new) {
        // Create a new Pricebook Entry
        PricebookEntry newPricebookEntry = new PricebookEntry(
            Pricebook2Id = standardPricebookId,
            Product2Id = product.Id,
            UnitPrice = 15,
            IsActive = true
        );
        newPricebookEntries.add(newPricebookEntry);
    }
    
    // Insert the new Pricebook Entries
    insert newPricebookEntries;
}
