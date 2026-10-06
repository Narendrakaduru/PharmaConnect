/**
 * PharmaConnect — Territory Management Setup (Setup Objects)
 * ─────────────────────────────────────────────────────────────
 * Purpose : Creates territory Public Groups and assigns User 2
 *           to Group_Territory_Hyderabad_Central.
 *
 * Run with:
 *   sf apex run --target-org sf-ep-dev --file scripts/apex/setup_territory_management.apex
 */

System.debug('=== 1. CREATING TERRITORY PUBLIC GROUPS ===');

Map<String, String> territoryGroups = new Map<String, String>{
    'Group_Territory_Hyderabad_Central' => 'Territory: Hyderabad Central',
    'Group_Territory_Warangal'          => 'Territory: Warangal',
    'Group_Territory_Vijayawada'        => 'Territory: Vijayawada'
};

Map<String, Id> groupMap = new Map<String, Id>();
for (Group g : [SELECT Id, DeveloperName FROM Group WHERE DeveloperName IN :territoryGroups.keySet()]) {
    groupMap.put(g.DeveloperName, g.Id);
}

List<Group> newGroups = new List<Group>();
for (String devName : territoryGroups.keySet()) {
    if (!groupMap.containsKey(devName)) {
        newGroups.add(new Group(
            DeveloperName = devName,
            Name = territoryGroups.get(devName),
            Type = 'Regular',
            DoesIncludeBosses = true
        ));
    }
}

if (!newGroups.isEmpty()) {
    insert newGroups;
    for (Group g : newGroups) {
        groupMap.put(g.DeveloperName, g.Id);
        System.debug('✓ Created Public Group: ' + g.DeveloperName + ' (' + g.Id + ')');
    }
} else {
    System.debug('✓ All Territory Public Groups already exist.');
}

System.debug('=== 2. ASSIGNING USER 2 TO HYDERABAD CENTRAL PUBLIC GROUP ===');

User user2 = [
    SELECT Id, Username, Email 
    FROM User 
    WHERE Username LIKE 'harishlankepalli555%' OR Email = 'harishlankepalli555@gmail.com'
    LIMIT 1
];

Id hydGroupId = groupMap.get('Group_Territory_Hyderabad_Central');

List<GroupMember> existingMembers = [
    SELECT Id FROM GroupMember 
    WHERE GroupId = :hydGroupId AND UserOrGroupId = :user2.Id
];

if (existingMembers.isEmpty()) {
    insert new GroupMember(
        GroupId = hydGroupId,
        UserOrGroupId = user2.Id
    );
    System.debug('✓ Assigned User 2 (' + user2.Username + ') to Group_Territory_Hyderabad_Central');
} else {
    System.debug('✓ User 2 is already a member of Group_Territory_Hyderabad_Central');
}

System.debug('=== Territory Public Groups & User Assignment Complete ===');
