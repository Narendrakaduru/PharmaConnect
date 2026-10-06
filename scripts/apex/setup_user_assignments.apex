/**
 * PharmaConnect — User Role & Permission Set Assignment Script
 * ─────────────────────────────────────────────────────────────
 * Purpose : Assigns roles and permission sets to the two active
 *           PharmaConnect personas in the Developer Edition org.
 *
 * Run with:
 *   sf apex run --target-org sf-ep-dev \
 *     --file scripts/apex/setup_user_assignments.apex
 *
 * ─── CONFIGURE BEFORE RUNNING ────────────────────────────────
 * Replace the placeholder values below with the actual Salesforce
 * usernames for your Dev Org users.
 * ─────────────────────────────────────────────────────────────
 */

// ── CONFIGURATION ─────────────────────────────────────────────
// User 1: System Administrator & Area Sales Manager
// This is typically the org creator / admin login.
final String USER1_USERNAME = 'kadurunarendra_dg5gsnkmbmdxcy@gmail.com.devbox1';

// User 2: Medical Representative
// This user is assigned the Medical Representative role and permissions.
final String USER2_USERNAME = 'harishlankepalli555@gmail.com.devbox1';
// ─────────────────────────────────────────────────────────────

System.debug('=== PharmaConnect User Assignment Script ===');

// ── 1. LOAD ROLES ─────────────────────────────────────────────
Map<String, Id> roleMap = new Map<String, Id>();
for (UserRole r : [
    SELECT Id, Name FROM UserRole
    WHERE Name IN (
        'Area Sales Manager - Hyderabad',
        'Medical Representative - Hyderabad'
    )
]) {
    roleMap.put(r.Name, r.Id);
}

Id asmRoleId = roleMap.get('Area Sales Manager - Hyderabad');
Id mrRoleId  = roleMap.get('Medical Representative - Hyderabad');

if (asmRoleId == null || mrRoleId == null) {
    throw new System.HandledException(
        'ERROR: One or more required roles not found. ' +
        'Ensure roles are deployed before running this script. ' +
        'Found roles: ' + roleMap.keySet()
    );
}
System.debug('✓ Roles loaded: ASM=' + asmRoleId + ' | MR=' + mrRoleId);

// ── 2. LOAD PERMISSION SETS ────────────────────────────────────
Map<String, Id> psMap = new Map<String, Id>();
for (PermissionSet ps : [
    SELECT Id, Name FROM PermissionSet
    WHERE Name IN (
        'Pharma_Representative_Access',
        'Pharma_Product_Catalog_Admin',
        'Pharma_Sample_Approver',
        'Pharma_Executive_Analytics'
    )
]) {
    psMap.put(ps.Name, ps.Id);
}

if (psMap.size() != 4) {
    throw new System.HandledException(
        'ERROR: Not all permission sets found. ' +
        'Deploy permission sets before running this script. ' +
        'Found: ' + psMap.keySet()
    );
}
System.debug('✓ Permission sets loaded: ' + psMap.keySet());

// ── 3. LOAD USERS ─────────────────────────────────────────────
Map<String, User> userMap = new Map<String, User>();
for (User u : [
    SELECT Id, Username, Email, UserRoleId, Profile.Name
    FROM User
    WHERE (Username IN (:USER1_USERNAME, :USER2_USERNAME)
       OR Email IN ('kadurunarendra@gmail.com', 'harishlankepalli555@gmail.com')
       OR Id = :UserInfo.getUserId())
    AND IsActive = TRUE
]) {
    userMap.put(u.Username, u);
    userMap.put(u.Email, u);
    if (u.Id == UserInfo.getUserId()) {
        userMap.put('CURRENT_USER', u);
    }
}

User user1 = userMap.containsKey(USER1_USERNAME) ? userMap.get(USER1_USERNAME) : userMap.get('CURRENT_USER');
User user2 = userMap.containsKey(USER2_USERNAME) ? userMap.get(USER2_USERNAME) : userMap.get('harishlankepalli555@gmail.com');

if (user1 == null) {
    throw new System.HandledException(
        'ERROR: User 1 not found or inactive: ' + USER1_USERNAME
    );
}
if (user2 == null) {
    throw new System.HandledException(
        'ERROR: User 2 not found or inactive: ' + USER2_USERNAME
    );
}
System.debug('✓ Users loaded: User1=' + user1.Id + ' (' + user1.Username + ') | User2=' + user2.Id + ' (' + user2.Username + ')');

// ── 4. ASSIGN ROLES ────────────────────────────────────────────
List<User> usersToUpdate = new List<User>();

if (user1.UserRoleId != asmRoleId) {
    usersToUpdate.add(new User(Id = user1.Id, UserRoleId = asmRoleId));
    System.debug('→ Will assign ASM role to User 1');
} else {
    System.debug('✓ User 1 already has ASM role — skipping');
}

if (user2.UserRoleId != mrRoleId) {
    usersToUpdate.add(new User(Id = user2.Id, UserRoleId = mrRoleId));
    System.debug('→ Will assign MR role to User 2');
} else {
    System.debug('✓ User 2 already has MR role — skipping');
}

if (!usersToUpdate.isEmpty()) {
    update usersToUpdate;
    System.debug('✓ Role assignments saved');
}

// ── 5. ASSIGN PERMISSION SETS ──────────────────────────────────
// Permission sets to assign per user
Map<Id, List<String>> userPsAssignments = new Map<Id, List<String>>{
    user1.Id => new List<String>{
        'Pharma_Product_Catalog_Admin',
        'Pharma_Sample_Approver',
        'Pharma_Executive_Analytics'
    },
    user2.Id => new List<String>{
        'Pharma_Representative_Access'
    }
};

// Identify already-existing assignments to avoid duplicates
Set<String> existingAssignments = new Set<String>();
for (PermissionSetAssignment psa : [
    SELECT AssigneeId, PermissionSetId
    FROM PermissionSetAssignment
    WHERE AssigneeId IN (:user1.Id, :user2.Id)
    AND PermissionSet.Name IN (
        'Pharma_Representative_Access',
        'Pharma_Product_Catalog_Admin',
        'Pharma_Sample_Approver',
        'Pharma_Executive_Analytics'
    )
]) {
    existingAssignments.add(psa.AssigneeId + ':' + psa.PermissionSetId);
}

List<PermissionSetAssignment> newAssignments = new List<PermissionSetAssignment>();
for (Id userId : userPsAssignments.keySet()) {
    for (String psName : userPsAssignments.get(userId)) {
        Id psId = psMap.get(psName);
        String key = userId + ':' + psId;
        if (!existingAssignments.contains(key)) {
            newAssignments.add(new PermissionSetAssignment(
                AssigneeId    = userId,
                PermissionSetId = psId
            ));
            System.debug('→ Will assign [' + psName + '] to User ' +
                (userId == user1.Id ? '1' : '2'));
        } else {
            System.debug('✓ [' + psName + '] already assigned to User ' +
                (userId == user1.Id ? '1' : '2') + ' — skipping');
        }
    }
}

if (!newAssignments.isEmpty()) {
    insert newAssignments;
    System.debug('✓ ' + newAssignments.size() + ' permission set assignment(s) created');
} else {
    System.debug('✓ All permission set assignments already in place — nothing to do');
}

System.debug('=== Assignment Script Complete ===');
System.debug('User 1 (' + USER1_USERNAME + '): ASM Role | Product Catalog Admin, Sample Approver, Executive Analytics');
System.debug('User 2 (' + USER2_USERNAME + '): MR Role  | Representative Access');
