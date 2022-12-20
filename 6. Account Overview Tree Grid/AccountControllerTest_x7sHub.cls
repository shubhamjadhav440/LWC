/**********************************************************************************************
* Name : AccountControllerTest_x7sHub
* Author : 7Summits 
* Description : This is a Test class for Account Controller
*******************************************************************************************/

@isTest(SeeAllData=false)
public with sharing class AccountControllerTest_x7sHub {
    @TestSetup
    static void testSetup() {
        User adminUser = [SELECT Id,UserRoleId FROM User WHERE profile.name =: TestConstants_x7sHub.SYSTEM_ADMIN_PROFILE and isActive=true  and UserRoleId !='' Limit 1];
        
         try {
            System.runAs(adminUser) {
                    User owner = TestUtilities_x7sHub.createStandardUser();
                    owner.UserRoleId=adminUser.UserRoleId;
                    insert owner;

                	User testUser =TestUtilities_x7sHub.createCommunityUser(TestConstants_x7sHub.FIRST_NAME,TestConstants_x7sHub.LAST_NAME,TestConstants_x7sHub.COMMUNITY_EMAIL_TWO);
                	insert testUser;
                	
                	Contact testUserContact = [SELECT AccountId,LastName FROM Contact WHERE ID =:testUser.ContactId LIMIT 1];
                   	Account testUserAccount = [SELECT Id,ownerId,Owner.FirstName, owner.LastName,Name,Account_Co_Owner__r.Id, Account_Co_Owner__r.FirstName FROM Account where Id = :testUserContact.AccountId];
           			
                    testUserAccount.OwnerId =owner.Id;
                    testUserAccount.Onboarding_Status__c ='Completed';
                    testUserAccount.BillingState ='NY';
                    testUserAccount.Merchant_Application_Status__c = 'Approved';
                    update testUserAccount;

                	// Creating Test Child Account for the previous created Account
                    List<Account> testChildAccounts = new List<Account>();
                    for(Integer i = 0; i < 5; i++){
                        
                        Account testChildAccount = TestUtilities_x7sHub.createTestAccount();
                        testChildAccount.ParentId = testUserAccount.Id;
                        testChildAccount.Onboarding_Status__c ='Completed';
                        testChildAccount.BillingState = 'GA';
                        testChildAccounts.add(testChildAccount);
                        testChildAccount.Merchant_Application_Status__c = 'Active';
                    }
                	update testChildAccounts;
                	
                	// Creating current Month  Snapshot Data for Account and child Account
                	Integer currentMonth = Date.Today().Month();
            		Integer currentYear = Date.Today().Year();
                	date mTDDate = date.newInstance(currentYear, currentMonth, 1);
                	createTestSnapShotData(testUserAccount.Id,mTDDate);

                    for(Account childAccount : testChildAccounts){
                        createTestSnapShotData(childAccount.Id,mTDDate);
                    }
                	
                	// Creating Previous Month Snapshot Data for Account
                	date mTDDatePrevMonth = date.newInstance(currentYear, currentMonth-1, 15);
                	createTestSnapShotData(testUserAccount.Id,mTDDatePrevMonth);
                
                	// Creating Previous Year Snapshot Data for Account
                	date mTDDatePrevYear = date.newInstance(currentYear-1, currentMonth+2, 15);
                	createTestSnapShotData(testUserAccount.Id,mTDDatePrevYear);

                    User testUser1;
                	List<UserRole> roleListList = [SELECT Id FROM UserRole WHERE Name like '%CSM%' ];
					System.debug('roleListList'+roleListList);
        			if (null !=roleListList) {
            		UserRole userRole = roleListList[0];
                	testUser1 =TestUtilities_x7sHub.createStandardUser();
                	testUser1.UserRoleId=userRole.Id;
                	insert testUser1;
                    }
                	
                	
                	//Creating Tasks for current Month
                	createTestTaskForAccount(testUserAccount.Id,mTDDate,'Completed', 'Virtual Visit',3,testUser1.Id,testUserContact.id);
                    createTestTaskForAccount(testUserAccount.Id,mTDDate,'Completed', 'In Person Visit',2,testUser1.Id,testUserContact.id);


                     //Create Test Cadence Calls for different Dates
                     Datetime dt = Datetime.now();
                     Enterprise_Call__c call1 = createTestCadenceCalls(owner.Id,testUserAccount.Id,  dt);
                     Enterprise_Call__c call2 = createTestCadenceCalls(owner.Id,testUserAccount.Id,  Datetime.newInstance(dt.year(), dt.Month(), dt.Day()-4, 3, 20, 59));
                     
                     // Create Test Enterprise Business Review Meeting
                     Date currentDate = Date.Today();
                     createTestEBRMeeting(owner.Id,testUserAccount.id,currentDate.addDays(+5));
                	}
        	} catch (Exception e) {
           		System.debug('An Exception Occured while Data setup' + + e.getMessage() + ' , Error Line Number: ' + e.getLineNumber());
    		}
    }

    @IsTest
    public static void testGetAccountOverviewSnapshot() {
        
        Test.startTest();
        
        String userId;
               try{
        		User tesUser = [SELECT Id FROM User WHERE Email like 'CommunityUser@x7s.org%' LIMIT 1];
            	System.debug('The Test user Id :'+tesUser);
                userId = tesUser.Id;
                if(String.isNotBlank(userId))
                {
                    String jsonResponse =AccountController_x7sHub.getAccountOverviewSnapshot(userId);
                    System.debug('testGetAccountOverviewSnapshot: JSON Response '+jsonResponse);
                    
                    AccountOverviewWrapper_x7sHub response= (AccountOverviewWrapper_x7sHub)JSON.deserialize(jsonResponse, AccountOverviewWrapper_x7sHub.class);
                  /*   System.assert(jsonResponse != null, 'There is Snapshot Data present for the Account');

                    System.assertEquals(5, response.storeVisits, 'There are 5 Store visits related to the account');

                    System.assertEquals(6, response.activeAccounts,'Not the expected number of active accounts'); */
               	}
                 }catch (Exception e) 
                { 
                  System.debug('testGetAccountOverviewSnapshot : Error Message: User ID'+userID+' :' + e.getMessage() + ' , Error Line Number: ' + e.getLineNumber());
            	}
            

      	
        Test.stopTest();
    }

    @IsTest
    public static void testGetLocationSummary() {
        
        Test.startTest();
        
        String userId;
               try{
        		User tesUser = [SELECT Id FROM User WHERE Email like 'CommunityUser@x7s.org%' LIMIT 1];
            	System.debug('The Test user Id :'+tesUser);
                userId = tesUser.Id;
                if(String.isNotBlank(userId))
                {
                    String jsonResponse =AccountController_x7sHub.getLocationSummary('userID', userId);
                    System.debug('testGetLocationSummary :JSON Response '+jsonResponse);
                    
                    List<LocationSummaryWrapper_x7sHub> responseList = (List<LocationSummaryWrapper_x7sHub>)JSON.deserialize(jsonResponse, List<LocationSummaryWrapper_x7sHub>.class);
                        
                        System.assert(responseList.size()>0, 'Account related to logged in user has atleast 1 Location ');

                        LocationSummaryWrapper_x7sHub wrapper =(LocationSummaryWrapper_x7sHub)responseList[0];
                    
                        System.assertEquals(wrapper.onBoardingStatus, 'Completed','The Location is Active');

                        System.assertEquals(wrapper.billingState, 'GA','The Billing state for the location matches the desired output');
               		 }
                 }catch (Exception e) 
                { 
                  System.debug('testGetLocationSummary: Error Message: User ID'+userID+' :' + e.getMessage() + ' , Error Line Number: ' + e.getLineNumber());
            	}
            

      	
        Test.stopTest();
    }

    @IsTest
    public static void testGetLocationPages() {
        
        Test.startTest();
        
        String userId;
        try{
            
            User tesUser = [SELECT Id FROM User WHERE Email like 'CommunityUser@x7s.org%' LIMIT 1];
            System.debug('The Test user Id :'+tesUser);
            userId = tesUser.Id;
            if(String.isNotBlank(userId))
            {
                // Second page, 3 records per page, 5 total locations
                // Expected 2 records
                String jsonResponse =AccountController_x7sHub.getLocationPages('userID', userId, 2, 3);
                System.debug('testGetLocationPages :JSON Response '+jsonResponse);
                
                Map<String,Object> responseMap = (Map<String,Object>)JSON.deserializeUntyped(jsonResponse);
                
                Integer totalRecords = (Integer)responseMap.get(SnapHubConstants_x7sHub.TOTAL_RECORDS);
                List<Object> recordsList=(List<Object>)responseMap.get(SnapHubConstants_x7sHub.RECORDS);

                System.assertEquals(5, totalRecords);
                System.assertEquals(2, recordsList.size(), 'Not the expected number of records');
             }

         }catch (Exception e){ 
             System.debug('testGetLocationPages: Error Message: User ID'+userID+' :' + e.getMessage() + ' , Error Line Number: ' + e.getLineNumber());
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
            //   Name = TestConstants_x7sHub.CALL_NAME+randomNumber,
              Account__c = accountId,
              OwnerId = userId,
              Date_Time__c = callDate ,
              Agenda__c=TestConstants_x7sHub.CALL_AGENDA+randomNumber
        	);
        	insert enterprise_call;    
            return   enterprise_call;  
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

    /* Method Name: createTestTaskForAccount
    * Author Name: 7Summits Backend Team
    * Description: This method is called from the @TestSetup Context. It creates the Key Metrics Data for Testing
    * Parameters: Id, Date
    * Returns: void
    */
    private static void createTestTaskForAccount(Id accountId, Date completionDate,String status, String subject,Integer taskCount, Id ownerId, Id contactId) {
		List<Task> tasks = new List<Task>{};
            for(Integer i = 0; i < taskCount; i++) 
        	{
            	Task t = new Task(Subject=subject,Status=status,Completed_Date__c=completionDate,ownerId=ownerId,whatId=accountId,whoId=contactId);
            	tasks.add(t);
        	}
          insert tasks;   
    }

    /* Method Name: createTestKeyMetrics
    * Author Name: 7Summits Backend Team
    * Description: This method is called from the @TestSetup Context. It creates the Key Metrics Data for Testing
    * Parameters: Id, Date
    * Returns: void
    */
    private static void createTestSnapShotData(Id accountId, Date mTDDate) {

        Snapshot_Data_SLN__c slnData = new Snapshot_Data_SLN__c(Completed_Originations__c=10,Total_Funded__c=1500.0,
                                                        Applications__c=5,Approved_Applications__c=3, EDGE__c=10000, Month_and_Year_Current_Month_is_MTD__c=mTDDate,Account__c=accountId);
        insert slnData;
        
        Snapshot_Data_SSL__c sslData = new Snapshot_Data_SSL__c(Completed_Originations__c=5,Total_Funded__c=1000.0,
                                                        Applications__c=5,Approved_Applications__c=3,EDGE__c=2000, Month_and_Year_Current_Month_is_MTD__c=mTDDate,Account__c=accountId);
        insert sslData;
    
        Snapshot_Data_LTO__c ltoData = new Snapshot_Data_LTO__c(Completed_Originations__c=5,Total_Funded__c=1000.0,
                                                        Applications__c=5,Approved_Applications__c=3,EDGE__c=3000, Month_and_Year_Current_Month_is_MTD__c=mTDDate,Account__c=accountId);
        insert ltoData;
    
}
}