/**********************************************************************************************
* Name : HubControllerTest_x7sHub
* Author : 7Summits Backend Team
* Description : This is a Test class for Hub Controller
*******************************************************************************************/

@isTest(SeeAllData=false)
public with sharing class HubControllerTest_x7sHub {
    
    @TestSetup
    static void testSetup() {
        User adminUser = [SELECT Id,UserRoleId FROM User WHERE profile.name =: TestConstants_x7sHub.SYSTEM_ADMIN_PROFILE and isActive=true  and UserRoleId !='' Limit 1];
        
         try {
            System.runAs(adminUser) {
                	// Creating an Owner Account and associating a User in it
                   	User owner = TestUtilities_x7sHub.createStandardUser();
            		owner.UserRoleId=adminUser.UserRoleId;
           			insert owner;
                	            		
                	User coOwner =TestUtilities_x7sHub.createCommunityUser();
                	coOwner.Title = TestConstants_x7sHub.TITLE;
                	coOwner.FunFact__c = TestConstants_x7sHub.FUNFACT;
                	insert coOwner;
                	
                	User testUser =TestUtilities_x7sHub.createCommunityUser(TestConstants_x7sHub.FIRST_NAME,TestConstants_x7sHub.LAST_NAME,TestConstants_x7sHub.COMMUNITY_EMAIL_TWO);
                	insert testUser;
                	
                	Contact testUserContact = [SELECT AccountId,LastName FROM Contact WHERE ID =:testUser.ContactId LIMIT 1];
                   	Account testUserAccount = [SELECT Id,ownerId,Owner.FirstName, owner.LastName,Name,Account_Co_Owner__r.Id, Account_Co_Owner__r.FirstName FROM Account where Id = :testUserContact.AccountId];
           			
                	testUserAccount.OwnerId =owner.Id;
                	testUserAccount.Account_Co_Owner__r=coOwner;
                	
                	update testUserAccount;
                	testUser.Title=TestConstants_x7sHub.TITLE;
                	testUser.FunFact__c=TestConstants_x7sHub.FUNFACT;
                
                	update testUser;

                    //Create Test Cadence Calls fow different Dates
                     Datetime dt = Datetime.now();
                     Enterprise_Call__c call1 = createTestCadenceCalls(owner.Id,testUserAccount.Id,  dt);
                     Enterprise_Call__c call2 = createTestCadenceCalls(owner.Id,testUserAccount.Id,  Datetime.newInstance(dt.year(), dt.Month(), dt.Day()-4, 3, 20, 59));
                     Enterprise_Call__c call3 = createTestCadenceCalls(owner.Id,testUserAccount.Id,  Datetime.newInstance(dt.year(), dt.Month(), dt.Day()-6, 4, 30, 59));

                     //Create Action Items related to the Cadence Call 
                     Date currentDate = Date.Today();
                     createTestActionItems( owner.Id,TestConstants_x7sHub.ACTION_ITEM_NAME_ONE,'Open', call2.Id ,currentDate.addDays(-2) );
                     createTestActionItems( owner.Id,TestConstants_x7sHub.ACTION_ITEM_NAME_TWO,'Open', call2.Id ,currentDate.addDays(-4) ); 

                     // Create Cadence Call for future Date to compare the touchpoint between cadence and EBT
                     Enterprise_Call__c call4 = createTestCadenceCalls(owner.Id,testUserAccount.Id,  Datetime.newInstance(dt.year(), dt.Month(), dt.Day()+4, 4, 30, 59));
                     //Create Enterprise Business Review Meeting
                     Business_Review__c businessReview = createTestEBRMeeting(owner.Id,testUserAccount.id,currentDate.addDays(+2));
                     
                     //Create EBR Goal related to Enterprise Business Review Meeting
                     createTestEBRGoals(owner.Id, businessReview.Id, TestConstants_x7sHub.EBR_GOAL_NAME,TestConstants_x7sHub.EBR_GOAL_PILLAR, TestConstants_x7sHub.EBR_GOAL_STATUS,currentDate.addDays(+2) );

                     //Creating New User, Account and Contact to Test Upcoming touchpoint for Different account
                     User testUser3 =TestUtilities_x7sHub.createCommunityUser(TestConstants_x7sHub.FIRST_NAME,TestConstants_x7sHub.LAST_NAME,TestConstants_x7sHub.COMMUNITY_EMAIL_THREE);
                	 insert testUser3;
                	
                	Contact testUserContact3 = [SELECT AccountId,LastName FROM Contact WHERE ID =:testUser3.ContactId LIMIT 1];
                   	Account testUserAccount3 = [SELECT Id,ownerId,Owner.FirstName, owner.LastName,Name,Account_Co_Owner__r.Id, Account_Co_Owner__r.FirstName FROM Account where Id = :testUserContact3.AccountId];
           			
                    // Create Cadence Call for future Date to compare the touchpoint between cadence and EBT
                     Enterprise_Call__c call5 = createTestCadenceCalls(owner.Id,testUserAccount3.Id,  Datetime.newInstance(dt.year(), dt.Month(), dt.Day()+2, 4, 30, 59));
                     //Create Enterprise Business Review Meeting
                     createTestEBRMeeting(owner.Id,testUserAccount3.id,currentDate.addDays(+5));
                     
                  }
        	} catch (Exception e) {
           		System.debug('An Exception Occured while Data setup' + + e.getMessage() + ' , Error Line Number: ' + e.getLineNumber());
        }
    }
	/* 
    @IsTest
    public static void testGetSnapSupportTeam() {

        User theTestUser =
        [
            SELECT Id, ContactId, Contact.Account.Id, Email
            FROM User
            WHERE FirstName= :TestConstants_x7sHub.FIRST_NAME AND LastName= :TestConstants_x7sHub.LAST_NAME
        ][0];

        Id testAccountId = theTestUser.Contact.AccountId;

        List<User> testUsers = new List<User>();
        for(Integer i = 1; i < 3; i++){
            User u = TestUtilities_x7sHub.createStandardUser();

            u.FunFact__c = TestConstants_x7sHub.FUNFACT+i;
            u.Title = TestConstants_x7sHub.TITLE+i;
            u.FirstName = 'FirstName'+i;
            u.LastName = 'LastName'+i;

            testUsers.add(u);
        }
        insert testUsers;

        // Create team
        List<AccountTeamMember> teamList = new List<AccountTeamMember>();
        for(User theUser : testUsers){
            AccountTeamMember accTeamMember = new AccountTeamMember();
            accTeamMember.AccountId = testAccountId;
            accTeamMember.AccountAccessLevel = 'Read';
            accTeamMember.CaseAccessLevel = 'Read';
            accTeamMember.ContactAccessLevel = 'Read';
            accTeamMember.TeamMemberRole = 'Account Manager';
            accTeamMember.UserId = theUser.Id;
        
            teamList.add(accTeamMember);
        }

        insert teamList;
        
        Test.startTest();

        // JSON from type : List<SnapUser_x7sHub>
        String jsonResult = HubController_x7sHub.getSnapSupportTeam(theTestUser.Id);

        System.debug(jsonResult);
        
        Test.stopTest();
        
        List<SnapUser_x7sHub> snapUsers = (List<SnapUser_x7sHub>)JSON.deserialize(jsonResult, List<SnapUser_x7sHub>.class);
        
        System.assert(snapUsers.size() > 0, 'Account Team Member info not returned.');
        
        // Verify a few fields to confirm team member info was created correctly.
        for(SnapUser_x7sHub snapUser : snapUsers){
            
            System.assert(snapUser.title.startsWith(TestConstants_x7sHub.TITLE));
            System.assert(snapUser.funFact.startsWith(TestConstants_x7sHub.FUNFACT));
        }
    }
    */
    
     @IsTest
    public static void testGetAccountLogo() {
        
        Test.startTest();
        
        String userId;
               try{
                    User tesUser = [SELECT Id,Contact.AccountId FROM User WHERE Email like 'CommunityUser@x7s.org%' LIMIT 1];
                    Account ultimateParentAcc = [SELECT Id,ownerId,Owner.FirstName, owner.LastName,Name,Account_Co_Owner__r.Id, Account_Co_Owner__r.FirstName FROM Account where Id = :tesUser.Contact.AccountId];
                    
                    ultimateParentAcc.Logo_URL__c=TestConstants_x7sHub.ACCOUNT_LOGO;
                    update ultimateParentAcc;
                    
                    userId = tesUser.Id;
                    if(String.isNotBlank(userId))
                    {
                        String jsonResponse =HubController_x7sHub.getAccountLogo(userId);
                                        
                        System.assertEquals(TestConstants_x7sHub.ACCOUNT_LOGO,jsonResponse, 'The Logo of the ultimate Parent matched');
                    
                    }
                 }catch (Exception e) 
                { 
                    System.debug('testGetAccountLogo Error Message: User ID'+userID+' :' + e.getMessage() + ' , Error Line Number: ' + e.getLineNumber());
            	}
            

      	
        Test.stopTest();
    }


    @IsTest
    public static void testGetCadenceCallLogsInPages() {
        
        Test.startTest();
        
        String userId;
               try{
                    User tesUser = [SELECT Id FROM User WHERE Email like 'CommunityUser@x7s.org%' LIMIT 1];
                    System.debug('The Test user Id :'+tesUser);
                    userId = tesUser.Id;
                    if(String.isNotBlank(userId))
                    {
                        // Testing the method to fetch the records on Page Number 1 with 2 records per page
                        String jsonResponse =HubController_x7sHub.getCadenceCallLogsInPages(userId,1,2);
                        System.debug('JSON Response '+jsonResponse);
                        Map<String,Object> responseMap = (Map<String,Object>)JSON.deserializeUntyped(jsonResponse);
                        Integer recordsReturnedOnPage =0;
                        Integer totalRecordCount =0;
                        if(null !=responseMap)
                        {
                            totalRecordCount=(Integer)responseMap.get(SnapHubConstants_x7sHub.TOTAL_RECORDS);
                            List<Object> recordsList=(List<Object>)responseMap.get(SnapHubConstants_x7sHub.RECORDS);
                            recordsReturnedOnPage=(Integer)recordsList.size();
                        }
                        System.assert(totalRecordCount>2, 'There should be more than 2 Cadence Calls Logs');
                        
                    }
                 }catch (Exception e) 
                { 
                    System.debug('testGetCadenceCallLogsInPages Error Message: User ID'+userID+' :' + e.getMessage() + ' , Error Line Number: ' + e.getLineNumber());
            	}
            

      	
        Test.stopTest();
    }

    @IsTest
    public static void testGetCadenceCallLogs() {
        
        Test.startTest();
        
        String userId;
               try{
                    User tesUser = [SELECT Id FROM User WHERE Email like 'CommunityUser@x7s.org%' LIMIT 1];
                    System.debug('The Test user Id :'+tesUser);
                    userId = tesUser.Id;
                    if(String.isNotBlank(userId))
                    {
                        String jsonResponse =HubController_x7sHub.getCadenceCallLogs(userId);
                        System.debug('JSON Response '+jsonResponse);
                        List<EnterpriseCallWrapper_x7sHub> responseList = (List<EnterpriseCallWrapper_x7sHub>)JSON.deserialize(jsonResponse, List<EnterpriseCallWrapper_x7sHub>.class);
                        
                        System.assert(jsonResponse != null, 'User has Cadence Calls Logs associated with his account');
                    
                        System.assert(responseList.size()>0, 'User has atleast 1 Cadence Calls Log associated with his account');
                        
                        
                    }
                 }catch (Exception e) 
                { 
                    System.debug('testGetCadenceCallLogs Error Message: User ID'+userID+' :' + e.getMessage() + ' , Error Line Number: ' + e.getLineNumber());
            	}
            

      	
        Test.stopTest();
    }

    @IsTest
    public static void testGetLastCallSummary() {
        
        Test.startTest();
        
        String userId;
               try{
                    User tesUser = [SELECT Id FROM User WHERE Email like 'CommunityUser@x7s.org%' LIMIT 1];
                    System.debug('The Test user Id :'+tesUser);
                    userId = tesUser.Id;
                        if(String.isNotBlank(userId))
                        {
                            String jsonResponse =HubController_x7sHub.getLastCallSummary(userId);
                            EnterpriseCallWrapper_x7sHub response= (EnterpriseCallWrapper_x7sHub)JSON.deserialize(jsonResponse, EnterpriseCallWrapper_x7sHub.class);
                            System.assert(jsonResponse != null, 'Found the Last Call summary details');
                            
                            DateTime currentTime = system.now();
                            System.assert(currentTime>response.callDate, ' There is a call recorded at past date');
                            
                        }
                 }catch (Exception e) 
                { 
                     System.debug('testGetLastCallSummary Error Message: User ID'+userID+' :' + e.getMessage() + ' , Error Line Number: ' + e.getLineNumber());
            	}

        Test.stopTest();
    }

    @IsTest
    public static void testGetOutstandingActionItems() {
        
        Test.startTest();
        
        String userId;
               try{
                    User tesUser = [SELECT Id FROM User WHERE Email like 'CommunityUser@x7s.org%' LIMIT 1];
                    System.debug('The Test user Id :'+tesUser);
                    userId = tesUser.Id;
                    if(String.isNotBlank(userId))
                    {
                        String jsonResponse =HubController_x7sHub.getOutstandingActionItems(userId);
                        System.debug('JSON Response '+jsonResponse);
                        List<ActionItemWrapper_x7sHub> responseList = (List<ActionItemWrapper_x7sHub>)JSON.deserialize(jsonResponse, List<ActionItemWrapper_x7sHub>.class);
                        
                        System.assert(jsonResponse != null, 'User has Action Items associated with the Cadence Call ');
                    
                        System.assert(responseList.size()>0, 'User has atleast 1 outstanding Action Item ');

                        ActionItemWrapper_x7sHub wrapper = (ActionItemWrapper_x7sHub)responseList[0];
                       
                        System.assertEquals(TestConstants_x7sHub.ACTION_ITEM_NAME_TWO,wrapper.name,'The Name of the action Item matched');

                    }

                }catch (Exception e) 
                { 
                    System.debug('testGetOutstandingActionItems Error Message: User ID'+userID+' :' + e.getMessage() + ' , Error Line Number: ' + e.getLineNumber());
            	}
            

      	
        Test.stopTest();
    }

    @IsTest
    public static void testGetUpcomingTouchPoint() {
        
        Test.startTest();
            
               try{
                    User tesUser = [SELECT Id FROM User WHERE Email like 'CommunityUser@x7s.org%' LIMIT 1];
                    User tesUser2 = [SELECT Id FROM User WHERE Email like 'TestCommunityUser@x7s.org%' LIMIT 1];
                    System.debug('testGetUpcomingTouchPoint The Test user Id :'+tesUser+ ' Id 2 :'+tesUser2);
                    String userId = tesUser.Id;
                    String userId2 = tesUser2.Id;
                    if(String.isNotBlank(userId))
                    {
                        // Testing the method to fetch the upcoming TouchPoint
                        String jsonResponse =HubController_x7sHub.getUpcomingTouchPoint(userId);
                        System.debug('JSON Response '+jsonResponse);
                        Map<String,Object> responseMap = (Map<String,Object>)JSON.deserializeUntyped(jsonResponse);
                        
                        String callType=(String)responseMap.get(SnapHubConstants_x7sHub.CALL_TYPE);
                        System.debug('callType '+callType);
                        System.assertEquals(callType,SnapHubConstants_x7sHub.CALL_TYPE_EBR, 'There is an Upcoming Enterprise Business Review Touchpoint for the Account');
                        
                    }
                    if(String.isNotBlank(userId2))
                    {
                        // Testing the method to fetch the upcoming TouchPoint
                        String jsonResponse =HubController_x7sHub.getUpcomingTouchPoint(userId2);
                        System.debug('JSON Response '+jsonResponse);
                        Map<String,Object> responseMap = (Map<String,Object>)JSON.deserializeUntyped(jsonResponse);
                        
                        String callType=(String)responseMap.get(SnapHubConstants_x7sHub.CALL_TYPE);
                        System.debug('callType '+callType);
                        System.assertEquals(callType,SnapHubConstants_x7sHub.CALL_TYPE_CADENCE, 'There is an Upcoming Enterprise Business Review Touchpoint for the Account 2');
                        
                    }
                 }catch (Exception e) 
                { 
                    System.debug('testGetUpcomingTouchPoint Error Message:' + e.getMessage() + ' , Error Line Number: ' + e.getLineNumber());
            	}
      Test.stopTest();
    }

    @IsTest
    public static void testGetOpenEBRGoals() {
        
        Test.startTest();
        
        String userId;
               try{
                    User tesUser = [SELECT Id FROM User WHERE Email like 'CommunityUser@x7s.org%' LIMIT 1];
                    System.debug('testGetOpenEBRGoals :The Test user Id :'+tesUser);
                    userId = tesUser.Id;
                    if(String.isNotBlank(userId))
                    {
                        String jsonResponse =HubController_x7sHub.getOpenEBRGoals(userId);
                        System.debug('JSON Response '+jsonResponse);
                        List<EBRGoalsWrapper_x7sHub> responseList = (List<EBRGoalsWrapper_x7sHub>)JSON.deserialize(jsonResponse, List<EBRGoalsWrapper_x7sHub>.class);
                        
                        System.assert(jsonResponse != null, 'User has Open EBR Goals');
                    
                        System.assert(responseList.size()>0, 'User has atleast 1 Open EBR Goals associated with his account');

                        EBRGoalsWrapper_x7sHub wrapper =(EBRGoalsWrapper_x7sHub)responseList[0];
                    
                        System.assertEquals(wrapper.title, TestConstants_x7sHub.EBR_GOAL_NAME,'Goal Name matches the expected result');
                          
                    }
                 }catch (Exception e) 
                { 
                    System.debug('testGetOpenEBRGoals Error Message: User ID'+userID+' :' + e.getMessage() + ' , Error Line Number: ' + e.getLineNumber());
            	}
            

      	
        Test.stopTest();
    }

    @IsTest
    public static void testGetEBRMeetingsInPages() {
        
        Test.startTest();
        
        String userId;
               try{
                    User tesUser = [SELECT Id FROM User WHERE Email like 'CommunityUser@x7s.org%' LIMIT 1];
                    System.debug('The Test user Id :'+tesUser);
                    userId = tesUser.Id;
                    if(String.isNotBlank(userId))
                    {
                        // Testing the method to fetch the records on Page Number 1 with 2 records per page
                        String jsonResponse =HubController_x7sHub.getEBRMeetingsInPages(userId,1,2);
                        System.debug('testGetEBRMeetingsInPages :JSON Response '+jsonResponse);
                        Map<String,Object> responseMap = (Map<String,Object>)JSON.deserializeUntyped(jsonResponse);
                        Integer recordsReturnedOnPage =0;
                        Integer totalRecordCount =0;
                        if(null !=responseMap)
                        {
                            totalRecordCount=(Integer)responseMap.get(SnapHubConstants_x7sHub.TOTAL_RECORDS);
                            List<Object> recordsList=(List<Object>)responseMap.get(SnapHubConstants_x7sHub.RECORDS);
                            recordsReturnedOnPage=(Integer)recordsList.size();
                        }
                        System.assert(totalRecordCount>0, 'There should be atleast 1 EBR Meetingm associated with Account');
                        String jsonResponse2 =HubController_x7sHub.getEBRMeetingsInPages(userId,2,2);
                        System.debug('testGetEBRMeetingsInPages :JSON Response for 2nd Page '+jsonResponse2);
                        
                    }
                 }catch (Exception e) 
                { 
                    System.debug('testGetCadenceCallLogsInPages Error Message: User ID'+userID+' :' + e.getMessage() + ' , Error Line Number: ' + e.getLineNumber());
            	}
            

      	
        Test.stopTest();
    }

    @IsTest
    public static void testGetEBRGoalsByGrouping() {
        
        Test.startTest();
        
        String userId;
               try{
                    User tesUser = [SELECT Id FROM User WHERE Email like 'CommunityUser@x7s.org%' LIMIT 1];
                    System.debug('getEBRGoalsByGrouping :The Test user Id :'+tesUser);
                    userId = tesUser.Id;
                    if(String.isNotBlank(userId))
                    {
                        String jsonResponse =HubController_x7sHub.getEBRGoalsByGrouping(userId,'Pillar');
                        Map<String,Object> responseMap = (Map<String,Object>)JSON.deserializeUntyped(jsonResponse);
                        List<Object> goalsList = (List<Object>)responseMap.get('Training');
                        System.assert(goalsList.size()>0, 'There should be atleast 1 Goal associated with the Training Pillar ');

                        String jsonResponseTimeLine =HubController_x7sHub.getEBRGoalsByGrouping(userId,'TimeLine');
                        System.debug('JSON Response by TimeLine'+jsonResponse);
                        Map<String,Object> responseMapTimeLine = (Map<String,Object>)JSON.deserializeUntyped(jsonResponseTimeLine);
                        System.assert(responseMapTimeLine.size()>0, 'There should be atleast 1 Goal associated with the Timeline ');

                          
                    }
                 }catch (Exception e) 
                { 
                    System.debug('getEBRGoalsByGrouping Error Message: User ID'+userID+' :' + e.getMessage() + ' , Error Line Number: ' + e.getLineNumber());
            	}
            

      	
        Test.stopTest();
    }


    /* Method Name: createTestCadenceCalls
    * Author Name: 7Summits 
    * Description: This method is called from the @TestSetup Context. It creates the Test Cadence Call record
    * Parameters: String, String, DateTime
    * Returns: Enterprise_Call__c
    */
    private static Enterprise_Call__c createTestCadenceCalls(String userId,String accountId, DateTime callDate) {
        Integer randomNumber = Integer.valueof((Math.random() * 1000));
        Enterprise_Call__c enterprise_call = new Enterprise_Call__c(
              Account__c = accountId,
              OwnerId = userId,
              Date_Time__c = callDate ,
              Agenda__c=TestConstants_x7sHub.CALL_AGENDA+randomNumber
        	);
        	insert enterprise_call;    
            return   enterprise_call;  
        } 

    /* Method Name: createTestActionItems
    * Author Name: 7Summits 
    * Description: This method is called from the @TestSetup Context. It creates the Test Action Items
    * Parameters: String, String,String ,String, Date
    * Returns: void
    */
    private static void createTestActionItems(String userId,String name,String status, String enterpriseCallId,Date dueDate ) {
        Action_Item__c action_Item = new Action_Item__c(
              Name = name,
              Assignee__c = userId,
              Due_Date__c = dueDate ,
              Enterprise__c = enterpriseCallId,
              Status__c = status,
              Description__c = name
        	);
        	insert action_Item;      
            System.debug('Action Item created '+action_Item);
        } 

   /* Method Name: createTestEBRMeeting
    * Author Name: 7Summits 
    * Description: This method is called from the @TestSetup Context. It creates the Test Enterprise Review Meeting
    * Parameters: String, Account, Date
    * Returns: void
    */
    private static Business_Review__c createTestEBRMeeting(String userId,String accountId, Date callDate) {
        Business_Review__c eBRMeeting = new Business_Review__c(
                Name = TestConstants_x7sHub.EBR_NAME,
                Account_Name__c = accountId,
                OwnerId = userId,
                Meeting_Date__c = callDate  
              );
        try{
              insert eBRMeeting;  
              System.debug('eBRMeeting Created'+eBRMeeting);  
        }catch (Exception e) 
        { 
            System.debug('createTestEBRMeeting Error Message: ' + e.getMessage() + ' , Error Line Number: ' + e.getLineNumber());
            System.debug('Stack trace: ' + e.getStackTraceString()); 
        }  
        return eBRMeeting;
    } 

     /* Method Name: createTestEBRGoals
    * Author Name: 7Summits 
    * Description: This method is called from the @TestSetup Context. It creates the Test Enterprise Review Meeting
    * Parameters: String, Account, Date
    * Returns: void
    */
    private static void createTestEBRGoals(String userId,String businessReviewId,String name,String relatedPillar,String status, Date targetDate) {
        Business_Goal__c businessGoal = new Business_Goal__c(
                Name = name,
                OwnerId = userId,
                Related_Pillar__c = relatedPillar,
                Status__c = status,
                Business_Review__c = businessReviewId,
                Target_Date__c = targetDate  
              );
        try{
              insert businessGoal;  
              System.debug('businessGoal Created'+businessGoal);  
        }catch (Exception e) 
        { 
            System.debug('createTestEBRGoals Error Message: ' + e.getMessage() + ' , Error Line Number: ' + e.getLineNumber());
            System.debug('Stack trace: ' + e.getStackTraceString()); 
        }  
    } 

}