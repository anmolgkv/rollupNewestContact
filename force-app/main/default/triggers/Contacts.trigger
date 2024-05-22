trigger Contacts on Contact (after insert, after update, before delete, after undelete) {
    fflib_SObjectDomain.triggerHandler(Contacts.class);
}