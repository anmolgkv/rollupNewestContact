@IsTest
public with sharing class PermissionSetAssignment_t extends DomainBuilder {
    public PermissionSetAssignment_t(String permissionSetName) {
        super(PermissionSetAssignment.SObjectType);
        permissionSet(permissionSetName);
    }

    public PermissionSetAssignment_t permissionSet(String name) {
        PermissionSet permissionSet = [SELECT Id FROM PermissionSet WHERE Name = :name WITH SYSTEM_MODE LIMIT 1];
        return (PermissionSetAssignment_t) set(PermissionSetAssignment.PermissionSetId, permissionSet.Id);
    }
}