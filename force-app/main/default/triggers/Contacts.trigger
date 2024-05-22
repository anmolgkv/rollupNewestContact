trigger Contacts on Contact (after insert, after update, after delete, after undelete) {
    fflib_SObjectDomain.triggerHandler(Contacts.class);
}