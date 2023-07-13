public with sharing class AccountActivationHelper {
    public static void activateAccount(Id accountId, String activationSummary) {
        // Check if the user has Account Manager permission
        if (!hasAccountManagerPermission()) {
            throw new AuraHandledException('Only Account Managers can activate accounts.');
        }

        Account account = [SELECT Id, Name, Type, Active__c, Company_Email__c, Phone FROM Account WHERE Id = :accountId];

        // Check if the account is of type "Customer"
        if (account.Type != 'Customer') {
            throw new AuraHandledException('This functionality applies only to customer accounts.');
        }

        // Check if the account is already active
        if (account.Active__c) {
            throw new AuraHandledException('Account is already active.');
        }

        // Create a default contact
        Contact defaultContact = new Contact(
            FirstName = account.Name,
            LastName = account.Name + ' Customer Representative',
            Email = account.Company_Email__c,
            Phone = account.Phone,
            AccountId = accountId
        );
        insert defaultContact;

        // Update the account fields
        account.Active__c = true;
        account.Account_Activation_Summary__c = activationSummary;
        update account;
    }

    private static Boolean hasAccountManagerPermission() {
        Set<Id> accountManagerPermissionSetIds = new Set<Id>();
        for (PermissionSet ps : [SELECT Id FROM PermissionSet WHERE Name = 'Account Manager']) {
            accountManagerPermissionSetIds.add(ps.Id);
        }
        return ![SELECT Id FROM PermissionSetAssignment WHERE PermissionSetId IN :accountManagerPermissionSetIds AND AssigneeId = :UserInfo.getUserId()].isEmpty();
    }
}