public with sharing class Contacts  extends fflib_SObjectDomain {

    // CONSTRUCTOR

    public Contacts(List<Contact> records) {
        super(records);
    }


    // PUBLIC

    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> records) {
            return new Contacts(records);
        }
    }


    public override void onAfterUpdate(Map<Id, SObject> existingRecords) {
        new UpdateNewestContactOnAccount(records, (Map<Id, Contact>)existingRecords).execute();
    }


    public override void onAfterInsert() {
        new UpdateNewestContactOnAccount(records).execute();
    }

    // By moving from beforeDelete to afterDelete, we can simplify the trigger handler
    public override void onAfterDelete() {
        new UpdateNewestContactOnAccount(records).execute();
    }


    public override void onAfterUnDelete() {
        new UpdateNewestContactOnAccount(records).execute();
    }
}