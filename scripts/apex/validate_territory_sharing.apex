/**
 * PharmaConnect — Territory Management Validation Script
 * ─────────────────────────────────────────────────────────────
 * Validates:
 * 1. Role Hierarchy (Area Sales Manager -> Medical Representative)
 * 2. Territory Public Groups existence
 * 3. User 2 (MR) membership in Group_Territory_Hyderabad_Central
 * 4. Medical Representative profile record territory assignment
 *
 * Run with:
 *   sf apex run --target-org sf-ep-dev --file scripts/apex/validate_territory_sharing.apex
 */

System.debug('====================================================');
System.debug('   PHARMACONNECT TERRITORY MANAGEMENT VALIDATION     ');
System.debug('====================================================');

// ── 1. LOAD USERS ─────────────────────────────────────────────
User user1 = [
    SELECT Id, Username, Name, UserRoleId, UserRole.Name 
    FROM User 
    WHERE Username LIKE 'kadurunarendra%' OR Email = 'kadurunarendra@gmail.com'
    LIMIT 1
];

User user2 = [
    SELECT Id, Username, Name, UserRoleId, UserRole.Name, ManagerId, Manager.Name 
    FROM User 
    WHERE Username LIKE 'harishlankepalli555%' OR Email = 'harishlankepalli555@gmail.com'
    LIMIT 1
];

System.debug('1. Active Personas:');
System.debug('   • User 1 (ASM) : ' + user1.Name + ' (' + user1.Username + ') | Role: ' + user1.UserRole.Name);
System.debug('   • User 2 (MR)  : ' + user2.Name + ' (' + user2.Username + ') | Role: ' + user2.UserRole.Name + ' | Manager: ' + user2.Manager.Name);

// ── 2. VERIFY ROLE HIERARCHY ──────────────────────────────────
UserRole mrRole = [
    SELECT Id, Name, ParentRoleId, ParentRole.Name 
    FROM UserRole 
    WHERE Id = :user2.UserRoleId
];

Boolean isHierarchyCorrect = (mrRole.ParentRoleId == user1.UserRoleId);
System.debug('2. Role Hierarchy:');
System.debug('   • MR Role (' + mrRole.Name + ') reports to ASM Role (' + mrRole.ParentRole.Name + '): ' + (isHierarchyCorrect ? '✓ PASS' : '✗ FAIL'));

// ── 3. VERIFY TERRITORY PUBLIC GROUPS ─────────────────────────
List<String> requiredGroups = new List<String>{
    'Group_Territory_Hyderabad_Central',
    'Group_Territory_Warangal',
    'Group_Territory_Vijayawada'
};

Map<String, Id> groupMap = new Map<String, Id>();
for (Group g : [SELECT Id, DeveloperName, Name FROM Group WHERE DeveloperName IN :requiredGroups]) {
    groupMap.put(g.DeveloperName, g.Id);
}

System.debug('3. Territory Public Groups:');
for (String grpName : requiredGroups) {
    System.debug('   • ' + grpName + ': ' + (groupMap.containsKey(grpName) ? '✓ Found (' + groupMap.get(grpName) + ')' : '✗ MISSING'));
}

// ── 4. VERIFY USER 2 GROUP MEMBERSHIP ─────────────────────────
Id hydGroupId = groupMap.get('Group_Territory_Hyderabad_Central');
List<GroupMember> memberships = [
    SELECT Id FROM GroupMember 
    WHERE GroupId = :hydGroupId AND UserOrGroupId = :user2.Id
];

Boolean isMember = !memberships.isEmpty();
System.debug('4. Group Membership:');
System.debug('   • User 2 in Group_Territory_Hyderabad_Central: ' + (isMember ? '✓ PASS' : '✗ FAIL'));

// ── 5. VERIFY MEDICAL REPRESENTATIVE RECORD ───────────────────
List<Medical_Representative__c> mrRecords = [
    SELECT Id, Name, User__c, Territory__c, Region__c, Status__c
    FROM Medical_Representative__c
    WHERE User__c = :user2.Id
    LIMIT 1
];

System.debug('5. Medical Representative Record:');
if (!mrRecords.isEmpty()) {
    Medical_Representative__c mr = mrRecords[0];
    System.debug('   • Record ID : ' + mr.Id);
    System.debug('   • Rep Name  : ' + mr.Name);
    System.debug('   • Territory : ' + mr.Territory__c + (mr.Territory__c == 'Hyderabad Central' ? ' (✓ PASS)' : ' (✗ FAIL)'));
    System.debug('   • Status    : ' + mr.Status__c);
} else {
    System.debug('   ✗ No Medical_Representative__c record found for User 2');
}

System.debug('====================================================');
System.debug('   TERRITORY CONFIGURATION VALIDATION COMPLETE      ');
System.debug('====================================================');
