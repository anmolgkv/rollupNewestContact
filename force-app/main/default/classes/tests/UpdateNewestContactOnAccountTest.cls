@IsTest
private class UpdateNewestContactOnAccountTest {

    @TestSetup
    private static void setup() {
        User_t.standard('Standard');
    }


    @IsTest
    private static void createContactUnderTwoAccounts() {
        System.runAs(standardUser()) {
            // Setup
            Contact_t contact1 = new Contact_t().first('Contact').last('One');
            Contact_t contact2 = new Contact_t().first('Contact').last('Two');

            // Exercise
            new Account_t()
                    .name('Account 1')
                    .add(contact1);
            new Account_t()
                    .name('Account 2')
                    .add(contact2)
                    .persist();

            // Verify
            Account account1 = [SELECT NewestContact__r.FirstName, NewestContact__r.LastName FROM Account WHERE Name = 'Account 1'];
            Account account2 = [SELECT NewestContact__r.FirstName, NewestContact__r.LastName FROM Account WHERE Name = 'Account 2'];

            Assert.areEqual('One', account1.NewestContact__r.LastName);
            Assert.areEqual('Two', account2.NewestContact__r.LastName);
        }
    }


    @IsTest
    private static void createAnotherContactUnderSameAccount() {

        System.runAs(standardUser()) {
            // Setup
            Account account = (Account) new Account_t()
                                            .name('Account 1')
                                            .add(new Contact_t().first('Contact').last('One'))
                                            .persist();

            // Exercise
            insert new Contact(AccountId = account.Id, FirstName = 'Contact', LastName = 'Two');

            // Verify
            Account updatedAccount = [SELECT NewestContact__r.FirstName, NewestContact__r.LastName FROM Account];
            Assert.areEqual('Two', updatedAccount.NewestContact__r.LastName);
        }
    }


    @IsTest
    private static void transferContact() {
        System.runAs(standardUser()) {
            // Setup
            Account account1 = (Account) new Account_t()
                                            .name('Account one')
                                            .add(new Contact_t().first('Contact').last('One'))
                                            .persist();

            Account account2 = (Account) new Account_t()
                                            .name('Account two')
                                            .add(new Contact_t().first('Contact').last('Two'))
                                            .persist();
            sleep(1000);

            // Exercise
            Contact contact1 = [SELECT Id, AccountId FROM Contact WHERE LastName = 'One'];
            contact1.AccountId = account2.Id;
            update contact1;

            // Verify
            account1 = [SELECT NewestContact__c FROM Account WHERE Id = :account1.Id];
            account2 = [SELECT NewestContact__c FROM Account WHERE Id = :account2.Id];

            Assert.isNull(account1.NewestContact__c);
            Assert.areEqual(contact1.Id, account2.NewestContact__c);
        }
    }



    @IsTest
    private static void deleteFirstContact() {
        System.runAs(standardUser()) {
            // Setup
            Account account = (Account) new Account_t()
                                            .name('Account one')
                                            .add(new Contact_t().first('Contact').last('One'))
                                            .add(new Contact_t().first('Contact').last('Two'))
                                            .persist();

            // Exercise
            delete [SELECT Id FROM Contact WHERE LastName = 'One'];

            // Verify
            Account updatedAccount = [SELECT NewestContact__r.LastName FROM Account WHERE Id = :account.Id];

            Assert.areEqual('Two', updatedAccount.NewestContact__r.LastName);
        }
    }



    @IsTest
    private static void deleteAllContacts() {
        System.runAs(standardUser()) {
            // Setup
            Account account = (Account) new Account_t()
                                            .name('Account one')
                                            .add(new Contact_t().first('Contact').last('One'))
                                            .add(new Contact_t().first('Contact').last('Two'))
                                            .persist();

            // Exercise
            delete [SELECT Id FROM Contact];

            // Verify
            Account updatedAccount = [SELECT NewestContact__c FROM Account WHERE Id = :account.Id];
            Assert.isNull(updatedAccount.NewestContact__c);
        }
    }



@IsTest
private static void unDeleteContact() {
    System.runAs(standardUser()) {
        // Setup
        Account account = (Account) new Account_t()
                                        .name('Account one')
                                        .add(new Contact_t().first('Contact').last('One'))
                                        .add(new Contact_t().first('Contact').last('Two'))
                                        .persist();
        delete [SELECT Id FROM Contact WHERE LastName = 'One'];
        sleep(1000);

        // Exercise
        Contact contact1 = [SELECT Id FROM Contact WHERE LastName = 'One' ALL ROWS];
        undelete contact1;

        // Verify
        Account updatedAccount = [SELECT NewestContact__r.LastName FROM Account WHERE Id = :account.Id];
        Assert.areEqual('One', updatedAccount.NewestContact__r.LastName);
    }
}


    // HELPER

    private static User standardUser() {
        return [SELECT Id FROM User WHERE LastName = 'Standard'];
    }


    private static void sleep(integer milliseconds) {
        Long timeDiff = 0;
        DateTime firstTime = System.now();

        do {
            timeDiff = System.now().getTime() - firstTime.getTime();
        } while(timeDiff <= milliseconds);
    }
}