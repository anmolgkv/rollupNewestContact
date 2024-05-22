public with sharing class UpdateNewestContactOnAccount {

    private Set<Id> accountIds;
    private Set<Id> contactIdsToBeIgnored = new Set<Id>();

    // CONSTRUCTOR

    public UpdateNewestContactOnAccount(List<Contact> contacts) {
        this.accountIds = accountIdsFor(contacts);

        // Note: In case a contact is deleted.
        // ignore it while recalculating as its still available in related list during before delete
        if(Trigger.operationType == TriggerOperation.BEFORE_DELETE) {
            contactIdsToBeIgnored = new Map<Id, Contact>(contacts).keySet();
        }
    }


    public UpdateNewestContactOnAccount(List<Contact> contacts, Map<Id, Contact> existingRecords) {
        this.accountIds = accountIdsFor(contacts, existingRecords);
    }


    // PUBLIC

    public void execute() {
        List<Account> accountsToBeUpdated = new List<Account>();

        List<Account> accounts = [SELECT Id, (SELECT Id FROM Contacts ORDER BY LastModifiedDate DESC)
                                    FROM Account
                                    WHERE Id IN : accountIds
                                    WITH USER_MODE];

        for(Account account : accounts) {
            accountsToBeUpdated.add(
                new Account(
                    Id = account.Id,
                    NewestContact__c = newestContactId(account.Contacts)
                )
            );
        }

        update as User accountsToBeUpdated;
    }


    // PRIVATE

    private Id newestContactId(List<Contact> contacts) {
        for(Contact contact : contacts) {
            if(!contactIdsToBeIgnored.contains(contact.Id)) {
                return contact.Id;
            }
        }

        return null;
    }


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