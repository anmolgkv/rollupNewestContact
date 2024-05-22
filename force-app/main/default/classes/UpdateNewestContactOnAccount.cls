public with sharing class UpdateNewestContactOnAccount {

    private Set<Id> accountIds;

    // CONSTRUCTOR

    public UpdateNewestContactOnAccount(List<Contact> contacts) {
        this.accountIds = accountIdsFor(contacts);
        
        // Note that there's no need for treating delete as special case because now, after delete, the records are no returned in the query
    }


    public UpdateNewestContactOnAccount(List<Contact> contacts, Map<Id, Contact> existingRecords) {
        this.accountIds = accountIdsFor(contacts, existingRecords);
    }


    // PUBLIC

    public void execute() {
        List<Account> accountsToBeUpdated = new List<Account>();

        List<Account> accounts = [SELECT Id, (SELECT Id FROM Contacts ORDER BY LastModifiedDate DESC LIMIT 1)
                                    FROM Account
                                    WHERE Id IN : accountIds
                                    WITH USER_MODE];

        for(Account account : accounts) {
            accountsToBeUpdated.add(
                new Account(
                    Id = account.Id,
                        NewestContact__c = account.Contacts.isEmpty() ? null : account.Contacts[0].Id
                )
            );
        }

        update as User accountsToBeUpdated;
    }


    // PRIVATE

    private Set<Id> accountIdsFor(List<Contact> contacts) {
        Set<Id> result = new Set<Id>();

        for(Contact contact : contacts) {
            result.add(contact.AccountId);
        }

        return result;
    }


    private Set<Id> accountIdsFor(List<Contact> contacts, Map<Id, Contact> oldRecords) {
        Set<Id> result = new Set<Id>();

        for(Contact contact : contacts) {
            Contact oldContact = oldRecords.get(contact.Id);
            // Note: when a contact is transfered from 1 Account to another.
            // The contact lookup needs to be calculated for both old and new parent accounts
            if(oldContact.AccountId != contact.AccountId) {
                result.add(contact.AccountId);
                result.add(oldContact.AccountId);
            }
        }

        return result;
    }
}