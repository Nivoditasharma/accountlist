@IsTest
public class AccountTriggerTest {
    @IsTest
    static void testDefaultCustomerContactCreation() {
        // Create an Account Manager user and assign the Account Manager permission set
        Profile accountManagerProfile = [SELECT Id FROM Profile WHERE Name = 'Account Manager' LIMIT 1];
        User accountManagerUser = new User(
            ProfileId = accountManagerProfile.Id,
            Username = 'accountmanager@test.com',
            Email = 'accountmanager@test.com',
            Alias = 'amuser',
            LastName = 'Account Manager',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert accountManagerUser;

        // Create a standard user
        Profile standardUserProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User standardUser = new User(
            ProfileId = standardUserProfile.Id,
            Username = 'standarduser@test.com',
            Email = 'standarduser@test.com',
            Alias = 'suser',
            LastName = 'Standard User',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert standardUser;

        // Create a test account (customer account, active=false)
        Account testAccount = new Account(
            Name = 'Test Account',
            Type = 'Customer',
            Active__c = false,
            Company_Email__c = 'test@test.com'
        );
        insert testAccount;

       // Set the standard user as the running user
System.runAs(standardUser) {
    // Trigger the account creation/update
    Test.startTest();
    update testAccount;
    Test.stopTest();

    // Verify that the default contact is not created (remains null)
    try {
        Contact defaultContact = [SELECT Id FROM Contact WHERE AccountId = :testAccount.Id LIMIT 1];
        System.assert(false, 'Default contact should not be created');
    } catch (QueryException e) {
        // No contact record found, which is expected
    }

    // Verify that the Account Activation Summary field is blank
    testAccount = [SELECT Id, Account_Activation_Summary__c FROM Account WHERE Id = :testAccount.Id];
    System.assertEquals(null, testAccount.Account_Activation_Summary__c, 'Account Activation Summary should be blank');
}

        // Set the standard user as the running user
        System.runAs(standardUser) {
            // Trigger the account creation/update
            Test.startTest();
            update testAccount;
            Test.stopTest();

            // Verify that the default contact is not created (remains null)
            Contact defaultContact = [SELECT Id FROM Contact WHERE AccountId = :testAccount.Id LIMIT 1];
            System.assertEquals(null, defaultContact, 'Default contact should not be created');

            // Verify that the Account Activation Summary field is blank
            testAccount = [SELECT Id, Account_Activation_Summary__c FROM Account WHERE Id = :testAccount.Id];
            System.assertEquals(null, testAccount.Account_Activation_Summary__c, 'Account Activation Summary should be blank');
        }
    }
}