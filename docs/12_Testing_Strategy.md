# 12. Testing Strategy & Data Factory

[← Back to Master Documentation Index](../PharmaConnect_Project_Documentation.md) | [← Prev: 11. Salesforce DevOps Center](11_Salesforce_DevOps_Center.md) | [Next: 13. Project Governance →](13_Project_Management_and_Governance.md)

---

## 1. Overview & Free Org Testing Model

Because a Free Developer Edition Org provides only 2 active user licenses, testing complex role hierarchies and security settings is achieved programmatically via **`System.runAs()`** and **`TestDataFactory`**.

---

## 2. Test Data Factory Pattern

```apex
// TestDataFactory.cls
@isTest
public class TestDataFactory {
    
    public static User createTestUser(String profileName, String roleDeveloperName) {
        Profile p = [SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1];
        UserRole r = [SELECT Id FROM UserRole WHERE DeveloperName = :roleDeveloperName LIMIT 1];
        
        String uniqueKey = String.valueOf(System.currentTimeMillis());
        User u = new User(
            FirstName = 'Test',
            LastName = 'Rep_' + uniqueKey,
            Email = 'testrep_' + uniqueKey + '@pharmatest.internal',
            Username = 'rep_' + uniqueKey + '@pharmaconnect.test',
            Alias = 'trep',
            TimeZoneSidKey = 'Asia/Kolkata',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = p.Id,
            UserRoleId = r.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert u;
        return u;
    }

    public static Healthcare_Provider__c createProvider(String name, String territory, String license) {
        return new Healthcare_Provider__c(
            Provider_Name__c = name,
            Territory__c = territory,
            License_Number__c = license,
            Status__c = 'Active',
            Specialization__c = 'Cardiology',
            Provider_Type__c = 'Specialist'
        );
    }
}
```

> [!NOTE]
> In Apex unit tests, `insert new User()` does NOT count against your active Developer Edition user license limit. This allows full testing of ASMs, RSMs, and Reps simultaneously.

---

## 3. Test Coverage Requirements
* **Minimum Coverage:** >= 85% on all controllers, services, selectors, and trigger handlers.
* **Bulkification:** Test DML operations with 200+ records to ensure governor limit compliance.
* **Positive, Negative & Exception Scenarios:** Verify expected exceptions using `try { ... } catch (AuraHandledException e)`.

---

[Next: 13. Project Governance & Roadmap →](13_Project_Management_and_Governance.md)
