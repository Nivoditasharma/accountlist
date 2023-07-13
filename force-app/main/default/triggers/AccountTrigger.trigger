trigger AccountTrigger on Account (after insert, after update) {
    // Get the Account Manager Permission Set Id
    Id accountManagerPermissionSetId = [SELECT Id FROM PermissionSet WHERE Name = 'Account Manager' LIMIT 1].Id;

    List<Contact> contactsToInsert = new List<Contact>();
    List<Account> accountsToUpdate = new List<Account>();

    for (Account acc : Trigger.new) {
        // Check if the Account is a customer account and is active
        if (acc.Type == 'Customer' && acc.Active__c) {
            // Check if the default contact doesn't exist
            if (acc.Default_Contact__c == null) {
                // Create the default contact
                Contact defaultContact = new Contact();
                defaultContact.FirstName = acc.Name;
                defaultContact.LastName = 'Customer Representative';
                defaultContact.AccountId = acc.Id;
                defaultContact.Email = acc.Company_Email__c;
                contactsToInsert.add(defaultContact);

                // Update the Account with the default contact reference
                acc.Default_Contact__c = defaultContact.Id;
                accountsToUpdate.add(acc);
            }
        }
    }

    // Insert the new contacts
    if (!contactsToInsert.isEmpty()) {
        insert contactsToInsert;
    }

    // Update the accounts with the default contact reference
    if (!accountsToUpdate.isEmpty()) {
        update accountsToUpdate;
    }
}