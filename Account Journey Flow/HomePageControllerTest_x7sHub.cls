/**********************************************************************************************
* Name : HomePageControllerTest_x7sHub
* Author : 7Summits Backend Team
* Description : This is a Test class for Home Page Controller
*******************************************************************************************/

@isTest(SeeAllData=false)
public with sharing class HomePageControllerTest_x7sHub {
    @TestSetup
    static void testSetup() {
        User adminUser = [SELECT Id,UserRoleId FROM User WHERE profile.name =: TestConstants_x7sHub.SYSTEM_ADMIN_PROFILE and isActive=true  and UserRoleId !='' Limit 1];
        
         try {
            System.runAs(adminUser) {

                	User testUser =TestUtilities_x7sHub.createCommunityUser(TestConstants_x7sHub.FIRST_NAME,TestConstants_x7sHub.LAST_NAME,TestConstants_x7sHub.COMMUNITY_EMAIL_TWO);
                	insert testUser;
                	
                	Contact testUserContact = [SELECT AccountId,LastName FROM Contact WHERE ID =:testUser.ContactId LIMIT 1];
                   	Account testUserAccount = [SELECT Id,ownerId,Owner.FirstName, owner.LastName,Name,Account_Co_Owner__r.Id, Account_Co_Owner__r.FirstName FROM Account where Id = :testUserContact.AccountId];
           			
                    testUserAccount.Stage__c ='Expansion';
                    update testUserAccount;
                	// Creating Test Child Account for the previous created Account
                	Account testChildAccount = TestUtilities_x7sHub.createTestAccount();
                	testChildAccount.ParentId = testUserAccount.Id;
                    testChildAccount.Stage__c ='Expansion';
                	update testChildAccount;

                    //Create Test Learning Adventure
                	createTestAdventure(testUser.Id);
                    
                     // Creating Test Data for Certified Users
                     for(Integer counter=0;counter<3;counter++)
                     {
                         TestUtilities_x7sHub.createContactwithData(testChildAccount.Id,true,true);
                     }
                	
                	// Creating current Month  Snapshot Data for Account and child Account
                	date mTDDate = date.newInstance(2022, 3, 15);
                	createTestSnapShotData(testUserAccount.Id,mTDDate);
                	createTestSnapShotData(testChildAccount.Id,mTDDate);
                	
                	// Creating Previous Month Snapshot Data for Account
                	date mTDDatePrevMonth = date.newInstance(2022, 2, 15);
                	createTestSnapShotData(testUserAccount.Id,mTDDatePrevMonth);
                
                	// Creating Previous Year Snapshot Data for Account
                	date mTDDatePrevYear = date.newInstance(2021, 10, 15);
                	createTestSnapShotData(testUserAccount.Id,mTDDatePrevYear);
                	}
        	} catch (Exception e) {
           		System.debug('An Exception Occured while Data setup' + + e.getMessage() + ' , Error Line Number: ' + e.getLineNumber());
    		}
    }

    @IsTest
    public static void testGetKeyMetricsSnapshot() {
        
        Test.startTest();
        
        String userId;
            try{
                   
        		User tesUser = [SELECT Id FROM User WHERE Email like 'CommunityUser@x7s.org%' LIMIT 1];
            	System.debug('The Test user Id :'+tesUser);
                userId = tesUser.Id;
                if(String.isNotBlank(userId))
                {
                   String jsonResponse = HomePageController_x7sHub.getKeyMetricsSnapshot(userId,3,2022);
                   System.debug('jsonResonse '+jsonResponse);
                   Map<String,KeyMetricsWrapper_x7sHub> response =(Map<String,KeyMetricsWrapper_x7sHub>)JSON.deserialize(jsonResponse, Map<String,KeyMetricsWrapper_x7sHub>.class);
                   
                   KeyMetricsWrapper_x7sHub currentMonthMetrics = response.get(SnapHubConstants_x7sHub.CURRENT_MONTH);
                   System.assert(currentMonthMetrics!=null,'There is Key Metrics Data for Current Month');
                  
                   System.assertEquals(currentMonthMetrics.amountFinanced, 7000,'There is some amount Financed for current Month');
                   
                   System.assertEquals(currentMonthMetrics.loansFunded,40,'There are atleast some Loans funded for current month');
                    
                   System.assertEquals(currentMonthMetrics.totalApproved,18,'There are more than 5 applications which are approved for current month ');
                    
                   KeyMetricsWrapper_x7sHub prevMonthMetrics = response.get(SnapHubConstants_x7sHub.PREVIOUS_MONTH);
                   System.assertEquals(prevMonthMetrics.loansFunded,20,'There are atleast some Loans funded for Previous month');
                   
               	}
            }catch (Exception e) 
            { 
                  System.debug('testGetKeyMetricsSnapshot Error Message: User ID'+userID+' :' + e.getMessage() + ' , Error Line Number: ' + e.getLineNumber());
            }
            
        Test.stopTest();
    }
    
    @IsTest
    public static void testGetEdgeSnapshot() {
        
        Test.startTest();
        
        String userId;
            try{
                   
        		User tesUser = [SELECT Id FROM User WHERE Email like 'CommunityUser@x7s.org%' LIMIT 1];
            	System.debug('The Test user Id :'+tesUser);
                userId = tesUser.Id;
                if(String.isNotBlank(userId))
                {
                   String jsonResponse = HomePageController_x7sHub.getEdgeSnapshot(userId,3,2022);
                   System.debug('jsonResonse '+jsonResponse);
                   SnapEdgeInfoWrapper_x7sHub response =(SnapEdgeInfoWrapper_x7sHub)JSON.deserialize(jsonResponse, SnapEdgeInfoWrapper_x7sHub.class);
                    
                   System.assertEquals(response.currentMonthTotalEdgeRevenue,30000,'The Edge Snap shot for current month is greatet than 10000 ');
                  
                   System.assertEquals(response.previousMonthTotalEdgeRevenue,15000,'The Edge Snap shot for previous month is greatet than 10000 ');
                      
                   System.assertEquals(response.currentYearTotalEdgeRevenue,45000,'The Edge Snap shot for current year is greatet than 10000 ');
                      
                   System.assertEquals(response.previousYearTotalEdgeRevenue,15000,'The Edge Snap shot for previous year is greatet than 10000 ');
               	}
            }catch (Exception e) 
            { 
                  System.debug('testGetEdgeSnapshot Error Message: User ID'+userID+' :' + e.getMessage() + ' , Error Line Number: ' + e.getLineNumber());
            }
            
        Test.stopTest();
    }
    
     @IsTest
    public static void testgetSnapshotsLastModifiedDate() {
        
        Test.startTest();
        String jsonResponse = HomePageController_x7sHub.getSnapshotsLastModifiedDate();
        System.debug('jsonResonse '+jsonResponse);
        System.assert(jsonResponse!=null,'Last modified Date is not Null');
        Test.stopTest();
    }


    @IsTest
    public static void testGetAccountHighlights() {
        
        Test.startTest();
        
        String userId;
            try{
                   
        		User tesUser = [SELECT Id FROM User WHERE Email like 'CommunityUser@x7s.org%' LIMIT 1];
            	System.debug('The Test user Id :'+tesUser);
                userId = tesUser.Id;
                if(String.isNotBlank(userId))
                {
                   String jsonResponse = HomePageController_x7sHub.getAccountHighlights(userId);
                   System.debug('jsonResonse '+jsonResponse);
                   Map<String,Object> responseMap = (Map<String,Object>)JSON.deserializeUntyped(jsonResponse);
                    Integer trainedUsers = 0;
                    Integer outstandingTasks =0;
                   if(null !=responseMap)
                   {
                       trainedUsers=(Integer)responseMap.get('trainedUsers');
                       outstandingTasks=(Integer)responseMap.get('outstandingTasks');  
                   }
                  System.assertEquals(trainedUsers,3,'There are more than 1 trained Users ');
               	}
            }catch (Exception e) 
            { 
                  System.debug('testGetAccountHighlights Error Message: User ID'+userID+' :' + e.getMessage() + ' , Error Line Number: ' + e.getLineNumber());
            }
            
        Test.stopTest();
    }

    @IsTest
    public static void testGetCurrentJourneyStage() {
        
        Test.startTest();
        
        String userId;
            try{
                   
        		User tesUser = [SELECT Id FROM User WHERE Email like 'CommunityUser@x7s.org%' LIMIT 1];
            	System.debug('The Test user Id :'+tesUser);
                userId = tesUser.Id;
               
                   String jsonResponse = HomePageController_x7sHub.getCurrentJourneyStage(userId);
                   System.debug('jsonResonse '+jsonResponse);
                   Map<String,Object> responseMap = (Map<String,Object>)JSON.deserializeUntyped(jsonResponse);
      
                  System.assertEquals(responseMap.get('journeyStage'),'Expansion','The current Journey Stage matches the expected result');
             
            }catch (Exception e) 
            { 
                  System.debug('testGetCurrentJourneyStage Error Message: User ID'+userID+' :' + e.getMessage() + ' , Error Line Number: ' + e.getLineNumber());
            }
            
        Test.stopTest();
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

    /* Method Name: createTestAdventure
    * Author Name: 7Summits 
    * Description: This method is called from the @TestSetup Context. It creates the Test Learning Adventure
    * Parameters: Id, Date
    * Returns: void
    */
    private static void createTestAdventure(String userId) {
       
        X7S_Adventure__c adventure = new X7S_Adventure__c(
              Name = TestConstants_x7sHub.ADVENTURE_NAME,
              Active__c = true,
              OwnerId = userId,
              title__c=TestConstants_x7sHub.ADVENTURE_NAME
        	);
        	insert adventure;  
        }      
}