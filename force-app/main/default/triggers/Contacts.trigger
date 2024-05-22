trigger Contacts on Contact (after insert, before update, after update, before delete, after undelete) {
    fflib_SObjectDomain.triggerHandler(Contacts.class);
}