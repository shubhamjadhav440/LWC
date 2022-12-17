/**********************************************************************************************
* Name : AccountController_x7sHub
* Author : 7Summits
* Description : This is a Controller class for getting the Account related information 
* Comments : The Class is declared 'Without Sharing' as we have to fetch the details of all the locations
****************************************************************************************************/
public without sharing class AccountController_x7sHub {
 
     // Get the Limit of the Rows to be fetched
     private static Integer rowsLimit {get {
        if(rowsLimit==null)
        {
            rowsLimit= System.Limits.getLimitQueryRows();
        }
        return rowsLimit;
    }
    set;}
 
    /* Method Name: getAccountOverviewSnapshot
    * Author Name: 7Summits 
    * Description: Get the Account Overview Snapshot (Including Data for all the sublocations)
    * Returns: String
    */
    @AuraEnabled (Cacheable=true)
    public static String getAccountOverviewSnapshot(String userId)
    {	
        String methodName = 'getAccountOverviewSnapshot';
        //Map which stores Current and Previous Month Key Metrics Data 
        AccountOverviewWrapper_x7sHub accountOverviewWrapper = new AccountOverviewWrapper_x7sHub();
        if(String.isNotBlank(userId))
        {
                // Getting the accountId based on the User Id
                String accountId =Utility_x7sHub.getAccountIdByUser(userId);
                System.debug('The account Id associated with user '+userId+': '+accountId);
                if(String.isNotBlank(accountId))
                {
                    //Create a set for all the accountIds for which we have to fetch the Key Metrics
                    Set<Id> allAccountIds = new Set<Id>();
                    // Adding the Parent Account Id to the set
                    allAccountIds.add(accountId);
                    
                    // Getting all the Child Accounts related to this parent account
                    List<Account> allAccounts = Utility_x7sHub.getAllChildAccounts(accountId);
                     if(null!=allAccounts)
                        {
                            for(Account account :allAccounts)
                            {
                                allAccountIds.add(account.Id);
                            }
                        }
                     System.debug('All The Accounts for which we have to fetch child records '+allAccountIds);
                     
                     DateTime currentTime = system.now();
                     Date currentDate = system.today();

                     System.debug('CurrentDate : '+currentDate +' Current Time : '+currentTime);
                     
                     try{
                            // Getting the count of Onboarded/Active Accounts
                            List<String> acceptedStatusList = new List<String>{'Approved','Complete','Active','Pending'};
                            AggregateResult[] activeAccountsAggResult   = [SELECT COUNT(Merchant_Application_Status__c) activeAccounts FROM account WHERE Id IN :allAccountIds AND Merchant_Application_Status__c IN :acceptedStatusList WITH SECURITY_ENFORCED];
                            if(!activeAccountsAggResult.isEmpty())
                            {
                                accountOverviewWrapper.activeAccounts  = (Integer)activeAccountsAggResult[0].get('activeAccounts');
                            }

                            // Getting the count of accounts in Boarding i.e on boarding status is not 'Completed'
                            AggregateResult[] inBoardingAccountsAggResult   = [SELECT COUNT(Onboarding_Status__c) inBoardingAccounts FROM account WHERE Id IN :allAccountIds AND Onboarding_Status__c !=:SnapHubConstants_x7sHub.COMPLETE_STATUS WITH SECURITY_ENFORCED];
                            if(!activeAccountsAggResult.isEmpty())
                            {
                                accountOverviewWrapper.inBoardingAccounts  = (Integer)inBoardingAccountsAggResult[0].get('inBoardingAccounts');
                            }
                            
                            // Getting the count of Cadence Calls Completed 
                            AggregateResult[] callsCompletedAggResult  = [SELECT COUNT(Id) callsCompleted FROM Enterprise_Call__c WHERE Account__c  IN :allAccountIds AND Date_Time__c < :currentTime WITH SECURITY_ENFORCED];
                            if(!callsCompletedAggResult.isEmpty())
                            {
                                accountOverviewWrapper.cadenceCallsCompleted  = (Integer)callsCompletedAggResult[0].get('callsCompleted');
                            }

                            // Getting the count of Enterprise Business Review Meetings Completed 
                            AggregateResult[] eBRCompletedAggResult  = [SELECT COUNT(Id) eBRCompleted FROM Business_Review__c WHERE Account_Name__r.id  IN :allAccountIds AND Meeting_Date__c < : currentDate WITH SECURITY_ENFORCED];
                            if(!eBRCompletedAggResult.isEmpty())
                            {
                                accountOverviewWrapper.eBRCompleted  = (Integer)eBRCompletedAggResult[0].get('eBRCompleted');
                            }

                             
                              
                             // Getting the Store Visits conditions from Custom Labels
                            String taskSubjectCalls = System.Label.LABEL_CSM_METRICS_CALLS;
                            String taskSubjectVisits = System.Label.LABEL_CSM_METRICS_VISITS;
                            String[] subjectArrayVisits = taskSubjectVisits.split(';');
                            String status = System.Label.LABEL_CSM_METRICS_STATUS;
			                String userRole = '%' + System.Label.LABEL_CSM_METRICS_ROLE + '%';

                            // Getting the count of Store Visits
                             AggregateResult[] storeVisitsAggResult  = [SELECT count(Id) storeVisits FROM task WHERE WhatId IN :allAccountIds  AND Subject in :subjectArrayVisits AND owner.UserRole.Name like :userRole AND Status = :status  WITH SECURITY_ENFORCED];
                             
                             if(!storeVisitsAggResult.isEmpty())
                             {
                                 accountOverviewWrapper.storeVisits  = (Integer)storeVisitsAggResult[0].get('storeVisits');
                             }

                            // Getting the Amount Financed Till Date for Account and its sub accounts
                            accountOverviewWrapper.amountFinanced = getAmmountFinancedTillDate(allAccountIds);

                   

                    }catch (Exception e) {
                        System.debug(methodName+' : Error while Getting Account Data : ' + e.getMessage() + ' , Error Line Number: ' + e.getLineNumber());
                    }
                  
                }
        }
        //Returning the response with Key Metrics and Edge data as Json String
       	System.debug(methodName+'The Final Response to be Returned as JSON '+JSON.serialize(accountOverviewWrapper));      
        return JSON.serialize(accountOverviewWrapper);
    }

    /* Method Name: getAmmountFinancedTillDate
    * Author Name: 7Summits 
    * Description: Get the amountFinanced Data for LTO,SLN and SSL and aggregate them
    * Parameters: Set<Id>
    * Returns: Decimal
    */

    private static Decimal  getAmmountFinancedTillDate(Set<Id> accountIdSet)
    {	
        Decimal amountFinanced = 0.0;
        try{
            // Getting the aggregate of Snap LTO Data  
            AggregateResult[] snapLTOData   = [SELECT SUM(Total_Funded__c) amountFinanced FROM Snapshot_Data_LTO__c WHERE Account__c IN :accountIdSet WITH SECURITY_ENFORCED];
           
            // Getting the aggregate of Snap SLN Data  
            AggregateResult[] snapSLNData   = [SELECT SUM(Total_Funded__c) amountFinanced FROM Snapshot_Data_SLN__c WHERE Account__c IN :accountIdSet WITH SECURITY_ENFORCED];

            // Getting the aggregate of Snap SSL Data  
            AggregateResult[] snapSSLData   = [SELECT SUM(Total_Funded__c) amountFinanced FROM Snapshot_Data_SSL__c WHERE Account__c IN :accountIdSet WITH SECURITY_ENFORCED];
            
            Map<String,AggregateResult[]> dataMap =new Map<String,AggregateResult[]>();
            dataMap.put('snapLTOData',snapLTOData);
            dataMap.put('snapSLNData',snapSLNData);
            dataMap.put('snapSSLData',snapSSLData);
            
            for(String mapKey:dataMap.keySet())
            {
                AggregateResult[] result = dataMap.get(mapKey);
                 for(AggregateResult aggObject : result) {
                     //Using Ternary Operator to check if the field value is not Null. Adding data only if it is not null.
                     amountFinanced=(Decimal)aggObject.get('amountFinanced')!=null ?  amountFinanced+(Decimal)aggObject.get('amountFinanced') : amountFinanced; 
                 }      
            }
       
        }catch (Exception e) {
            System.debug('getAmmountFinancedTillDate: Error while Getting Metrics Data : ' + e.getMessage() + ' , Error Line Number: ' + e.getLineNumber());
        }
        return amountFinanced;
    }

    /* Method Name: getLocationSummary
    * Author Name: 7Summits 
    * Description: Get the Summary of all the locations under the logged in user's Account
    * Returns: String, String
    */
    @AuraEnabled (Cacheable=true)
    public static String getLocationSummary(String type, String id)
    {	
        String methodName = 'getLocationSummary';
        //Map which stores Current and Previous Month Key Metrics Data 
        List<LocationSummaryWrapper_x7sHub> response = new List<LocationSummaryWrapper_x7sHub>();
        if(String.isNotBlank(id) && String.isNotBlank(type))
        {
                String accountId ;
                 //Check the type of the Id being sent 
                 if(type.equalsIgnoreCase('userID'))
                 {
                    // Getting the accountId based on the User Id
                    accountId = Utility_x7sHub.getAccountIdByUser(id);
                 }
                 else{
                    // The Id passed is already the account Id to fetch the locations 
                    accountId = id;
                 }

                
                System.debug('The account Id associated with user '+id+': '+accountId);
                if(String.isNotBlank(accountId))
                {
                    //Create a set for all the accountIds for which we have to fetch the Key Metrics
                    Set<Id> allAccountIds = new Set<Id>();
                     // Getting all the Child Accounts related to this parent account
                    List<Account> allAccounts = Utility_x7sHub.getAllChildAccounts(accountId);
                     if(null!=allAccounts)
                        {
                            for(Account account :allAccounts)
                            {
                                allAccountIds.add(account.Id);
                            }
                        }
                        System.debug('All The Accounts for which we have to fetch child records '+allAccountIds);
                     
                     try{
                        
                            List<Account>  locationsList =[SELECT Name,No_of_Certified_Contacts__c,id,ParentId, Onboarding_Status__c,BillingState,AccountHierarchyLevel__c,Parent.Name,LTO_SLN_SSL_Total_Funded__c  FROM Account WHERE Id in :allAccountIds WITH SECURITY_ENFORCED ORDER BY AccountHierarchyLevel__c asc  LIMIT :rowsLimit];
                
                            if(!locationsList.isEmpty())
                            {

                                // Populating the LocationSummaryWrapper_x7sHub with the details
                                for(Account location:locationsList){
                                    LocationSummaryWrapper_x7sHub wrapper = new LocationSummaryWrapper_x7sHub();
                                    wrapper.id = location.Id;
                                    wrapper.name = location.name;
                                    wrapper.parentId = location.ParentId;
                                    wrapper.parentName = location.Parent.Name;
                                    wrapper.hierarchyLevel = location.AccountHierarchyLevel__c;
                                    wrapper.certifiedContacts = location.No_of_Certified_Contacts__c;
                                    wrapper.onBoardingStatus = location.Onboarding_Status__c;
                                    wrapper.billingState = location.billingState ;
                                    wrapper.lastMonthRevenue = location.LTO_SLN_SSL_Total_Funded__c;
                                    response.add(wrapper);
                                }
                            }

                    }catch (Exception e) {
                        System.debug(methodName+' : Error while Getting Account Data : ' + e.getMessage() + ' , Error Line Number: ' + e.getLineNumber());
                    }
                  
                }
        }
        //Returning the response with Key Metrics and Edge data as Json String
       	System.debug(methodName+'The Final Response to be Returned as JSON '+JSON.serialize(response));      
        return JSON.serialize(response);
    }

    /* Method Name: allowNewLocations
    * Author Name: 7Summits 
    * Description: Returns the boolean value of Account.Allow_Merchant_to_Add_Accounts__c
    * on the ultimate parent account.
    * Returns: boolean
    */
    @AuraEnabled
    public static Boolean allowNewLocations (ID userId){

        Boolean allow = false;
        try {
            List<User> userInfoList =
            [   SELECT Id, ContactId, Contact.Account.Ultimate_Parent_Id__c
                FROM User
                WHERE Id = :userId  ];

            if(userInfoList.isEmpty()){
                System.debug('No user found for ID: '+userId);
                return false;
            }

            User theUser = userInfoList[0];
            String ultParentAccountId = theUser.Contact.Account.Ultimate_Parent_Id__c;

            List<Account> ultimateParentAccount =
            [   SELECT Id, Allow_Merchant_to_Add_Accounts__c
                FROM Account
                WHERE Id = :ultParentAccountId  ];

            if(ultimateParentAccount.isEmpty()){
                System.debug('No Account found for Ultimate_Parent_Id__c: '+ultParentAccountId);
                return false;
            }

            allow =  ultimateParentAccount[0].Allow_Merchant_to_Add_Accounts__c;

        } catch (Exception e) {
            System.debug('allowNewLocations : Error while retrieving permission boolean : ' + e.getMessage() + ' , Error Line Number: ' + e.getLineNumber());
        }

        return allow;
    }

    @AuraEnabled (Cacheable=true)
    public static String getLocationPages(String type, String id, Integer pageNumber,Integer recordsPerPage)
    {	
        String methodName = 'getLocationPages';

        Map<String,Object> responseMap = new  Map<String,Object>();
        List<LocationSummaryWrapper_x7sHub> response = new List<LocationSummaryWrapper_x7sHub>();
        Integer totalRecordsCount = 0; 

        if(String.isNotBlank(id) && String.isNotBlank(type))
        {
            String accountId ;
            //Check the type of the Id being sent 
            if(type.equalsIgnoreCase('userID'))
            {
                // Getting the accountId based on the User Id
                accountId = Utility_x7sHub.getAccountIdByUser(id);
            }
            else{
                // The Id passed is already the account Id to fetch the locations 
                accountId = id;
            }
            
            System.debug('The account Id associated with user '+id+': '+accountId);
            if(String.isNotBlank(accountId))
            {
                //Create a set for all the accountIds for which we have to fetch the Key Metrics
                Set<Id> allAccountIds = new Set<Id>();
                 // Getting all the Child Accounts related to this parent account
                List<Account> allAccounts = Utility_x7sHub.getAllChildAccounts(accountId);
                if(null!=allAccounts){
                    for(Account account :allAccounts){
                        allAccountIds.add(account.Id);
                    }
                }
                System.debug('All The Accounts for which we have to fetch child records '+allAccountIds);
                
                try{
                    
                    List<Account>  locationsList =
                    [   SELECT Name,No_of_Certified_Contacts__c,id,ParentId, Onboarding_Status__c,BillingState,AccountHierarchyLevel__c,
                        Parent.Name,LTO_SLN_SSL_Total_Funded__c  
                        FROM Account 
                        WHERE Id in :allAccountIds WITH SECURITY_ENFORCED 
                        ORDER BY AccountHierarchyLevel__c asc  LIMIT :rowsLimit     ];

                    // Logic for Pagination 
                    // Calculating the Start Index for the locationsList
                    Integer startIndex = (recordsPerPage * (pageNumber-1));
                    System.debug('The StartIndex to fetch the records from List :'+startIndex);
                    
                    // Calculating the Start Index for the locationsList
                    Integer endIndex =(startIndex + recordsPerPage)-1;
                    System.debug('The EndIndex to fetch the records from List :'+endIndex);
                    
                    if(!locationsList.isEmpty()){

                        totalRecordsCount = locationsList.size();
                        System.debug('Total Number of Records fetched '+totalRecordsCount);
                        // Check if the startIndex is less than max Records
                        if(startIndex <= totalRecordsCount && endIndex > totalRecordsCount){
                            // If endIndex is greater than maximum records, update the endIndex
                            endIndex = totalRecordsCount - 1;
                        }
                        else if(startIndex <= totalRecordsCount && endIndex == totalRecordsCount){
                            endIndex = endIndex-1;
                        }
                        System.debug('The Updated EndIndex :'+endIndex);

                        // Populating the LocationSummaryWrapper_x7sHub with the details
                        for(Integer i=startIndex;i<=endIndex;i++){

                            LocationSummaryWrapper_x7sHub wrapper = new LocationSummaryWrapper_x7sHub();
                            wrapper.id = locationsList[i].Id;
                            wrapper.name = locationsList[i].name;
                            wrapper.parentId = locationsList[i].ParentId;
                            wrapper.parentName = locationsList[i].Parent.Name;
                            wrapper.hierarchyLevel = locationsList[i].AccountHierarchyLevel__c;
                            wrapper.certifiedContacts = locationsList[i].No_of_Certified_Contacts__c;
                            wrapper.onBoardingStatus = locationsList[i].Onboarding_Status__c;
                            wrapper.billingState = locationsList[i].billingState ;
                            wrapper.lastMonthRevenue = locationsList[i].LTO_SLN_SSL_Total_Funded__c;
                            response.add(wrapper);
                        }
                    }
                    
                }catch (Exception e) {
                    System.debug(methodName+' : Error while Getting Account Data : ' + e.getMessage() + ' , Error Line Number: ' + e.getLineNumber());
                    System.debug('Stack trace: ' + e.getStackTraceString());
                }
                    
           }
        }

        responseMap.put(SnapHubConstants_x7sHub.RECORDS,response);
        responseMap.put(SnapHubConstants_x7sHub.TOTAL_RECORDS,totalRecordsCount);   
        System.debug('The Response from'+methodName+' : '+JSON.serialize(responseMap));
        return JSON.serialize(responseMap);
    }
    
}