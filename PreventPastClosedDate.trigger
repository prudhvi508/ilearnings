trigger PreventPastClosedDate on Opportunity (before insert, before update) {
    for (Opportunity opp : Trigger.new) {
        // Check if the opportunity's closed date is in the past
        if (opp.CloseDate < Date.today()) {
            // Add an error message to the opportunity
            opp.addError('Please enter a future closed date.');
        }
    }
}
