@IsTest
public with sharing class User_t extends DomainBuilder {

    private static final Id STANDARD_USER = [SELECT Id FROM Profile WHERE Name='Standard User'].Id;

    public User_t() {
        super(User.SObjectType);

        String name = new Random().string();
        set(User.Alias, 'alias');
        set(User.Email, name + '@scott.com');
        set(User.EmailEncodingKey, 'UTF-8');
        set(User.FirstName, 'Jill');
        set(User.Lastname, 'Scott');
        set(User.languagelocalekey, 'en_US');
        set(User.localesidkey, 'en_US');
        set(User.timezonesidkey, 'America/Los_Angeles');
        set(User.isActive, true);
        set(User.username, name + '@scott.com');
        set(User.profileId, STANDARD_USER);
        set(User.UserPermissionsSFContentUser, false);
        add(new PermissionSetAssignment_t('ProcessityUser'));
    }


    public static User standard(String lastName) {
        return (User) new User_t()
                            .set(User.profileId, STANDARD_USER)
                            .set(User.LastName, lastName)
                            .persist();
    }

    public User_t add(PermissionSetAssignment_t psa) {
        return (User_t) psa.setParent(PermissionSetAssignment.AssigneeId, this);
    }
}