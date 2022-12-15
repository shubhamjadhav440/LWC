/**********************************************************************************************
* Name : HomePageController_x7sHub
* Author : 7Summits
* Description : This is a class to get the Revenue Snapshots for the Home Page components
* Comments : The Class is declared 'Without Sharing' as we have to fetch the metrics and edge 
    data for Parent and all the child accounts.
*******************************************************************************************/

public without sharing class HomePageController_x7sHub {

   /* Method Name: getKeyMetricsSnapshot
    * Author Name: 7Summits Backend Team
    * Description: Get the Key metrics data for the account for current and previous month and 
    * return the complete snapshot
    * Returns: String
    */
    @AuraEnabled (Cacheable=true)
    public static String getKeyMetricsSnapshot(String userId,Integer monthNumber,Integer year)
    {	
        //Map which stores Current and Previous Month Key Metrics Data 
        Map<String,KeyMetricsWrapper_x7sHub> keyMetricsMap = new  Map<String,KeyMetricsWrapper_x7sHub>();
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
                     
                     // Getting the Current Month Metrics i.e SNAP LTO,SNAP SLN and SNAP SSL data for the account
                     KeyMetricsWrapper_x7sHub currentMonthMetrics = getKeyMetrics(allAccountIds,monthNumber,year);
                     
                     // Getting the Previous Month Metrics i.e SNAP LTO,SNAP SLN and SNAP SSL data for the account
                   	 KeyMetricsWrapper_x7sHub prevMonthMetrics = getKeyMetrics(allAccountIds,monthNumber-1,year);
                     
                     // Adding the current and Previous Month Key metrics to the Map
                  	 keyMetricsMap.put(SnapHubConstants_x7sHub.CURRENT_MONTH, currentMonthMetrics);
                     keyMetricsMap.put(SnapHubConstants_x7sHub.PREVIOUS_MONTH, prevMonthMetrics);
                    }
        }
        //Returning the response with Key Metrics and Edge data as Json String
       	System.debug('The Final Response to be Returned as JSON '+JSON.serialize(keyMetricsMap));      
        return JSON.serialize(keyMetricsMap);
    }
    
    /* Method Name: getEdgeSnapshot
    * Author Name: 7Summits Backend Team
    * Description: Get the Snap Edge Data based on Month and Year
    * Returns: String
    */
    @AuraEnabled (Cacheable=true)
    public static String getEdgeSnapshot(String userId,Integer monthNumber,Integer year)
    {	
        //Map which stores Current and Previous Month Key Metrics Data 
        SnapEdgeInfoWrapper_x7sHub snapEdgeData = new SnapEdgeInfoWrapper_x7sHub();
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
                     
                     // Getting the Current Month Snap Edge Data i.e SNAP LTO,SNAP SLN and SNAP SSL data for the account
                     snapEdgeData.currentMonthTotalEdgeRevenue  = getEdgeInfoByMonth(allAccountIds,monthNumber,year);
                     
                     // Getting the Previous Month Snap Edge Data i.e SNAP LTO,SNAP SLN and SNAP SSL data for the account
                   	 snapEdgeData.previousMonthTotalEdgeRevenue  = getEdgeInfoByMonth(allAccountIds,monthNumber-1,year);
                    
                     // Getting the Current Year Snap Edge Data i.e SNAP LTO,SNAP SLN and SNAP SSL data for the account
                     snapEdgeData.currentYearTotalEdgeRevenue  = getEdgeInfoByYear(allAccountIds,year);
                     
                     // Getting the Previous Year Snap Edge Data i.e SNAP LTO,SNAP SLN and SNAP SSL data for the account
                   	 snapEdgeData.previousYearTotalEdgeRevenue  = getEdgeInfoByYear(allAccountIds,year-1);
                  
                }
        }
        //Returning the response with Key Metrics and Edge data as Json String
       	System.debug('The Final Response to be Returned as JSON '+JSON.serialize(snapEdgeData));      
        return JSON.serialize(snapEdgeData);
    }
	
    /* Method Name: getSnapshotsLastModifiedDate
    * Author Name: 7Summits Backend Team
    * Description: Get the Last Modified Date and Time Stamp for SnapShot Data
    * Returns: String
    */
    @AuraEnabled (Cacheable=true)
    public static String getSnapshotsLastModifiedDate()
    {	
        String methodName = 'getSnapshotsLastModifiedDate';
        DateTime lastModifiedDate ;
        
        List<DateTime> modDateList = new List<DateTime>();
        DateTime ltoDate = [SELECT LastModifiedDate FROM Snapshot_Data_LTO__c WITH SECURITY_ENFORCED ORDER BY SystemModstamp DESC LIMIT 1].LastModifiedDate;
        DateTime slnDate = [SELECT LastModifiedDate FROM Snapshot_Data_SLN__c WITH SECURITY_ENFORCED ORDER BY SystemModstamp DESC LIMIT 1].LastModifiedDate;
        DateTime sslDate = [SELECT LastModifiedDate FROM Snapshot_Data_SSL__c WITH SECURITY_ENFORCED ORDER BY SystemModstamp DESC LIMIT 1].LastModifiedDate;
        
        modDateList.add(ltoDate);
        modDateList.add(slnDate);
        modDateList.add(sslDate);
        for(DateTime temp : modDateList)
        {
            if(lastModifiedDate == null)
            {
                lastModifiedDate = temp;
            }
            if(temp> lastModifiedDate)
            {
                lastModifiedDate = temp;
            }
        }
        System.debug(methodName +' lastModifiedDate Unformatted :'+lastModifiedDate);
        return JSON.serialize(lastModifiedDate); 
    }
    /* Method Name: getKeyMetrics
    * Author Name: 7Summits Backend Team
    * Description: Get the Key metrics like loansFunded,amountFinanced,total applications
    *  and approved for LTO,SLN and SSL
    * Parameters: Set<Id>
    * Returns: KeyMetricsWrapper_x7sHub
    */

    public static KeyMetricsWrapper_x7sHub  getKeyMetrics(Set<Id> accountIdSet,Integer monthNumber,Integer year)
    {	
        KeyMetricsWrapper_x7sHub metrics = new KeyMetricsWrapper_x7sHub(); 
        try{
            // Getting the aggregate of Snap LTO Data  
            AggregateResult[] snapLTOData   = [SELECT SUM(Completed_Originations__c)loansFunded ,SUM(Total_Funded__c) amountFinanced,SUM(Applications__c) totalApplications,
                                               SUM(Approved_Applications__c) totalApproved FROM Snapshot_Data_LTO__c WHERE Account__c IN :accountIdSet
                                               and calendar_month(Month_and_Year_Current_Month_is_MTD__c) =:monthNumber and calendar_year(Month_and_Year_Current_Month_is_MTD__c)=:year WITH SECURITY_ENFORCED];
           
            // Getting the aggregate of Snap SLN Data  
            AggregateResult[] snapSLNData   = [SELECT SUM(Completed_Originations__c)loansFunded ,SUM(Total_Funded__c) amountFinanced,SUM(Applications__c) totalApplications,
                                               SUM(Approved_Applications__c) totalApproved FROM Snapshot_Data_SLN__c WHERE Account__c IN :accountIdSet 
                                               and calendar_month(Month_and_Year_Current_Month_is_MTD__c) =:monthNumber and calendar_year(Month_and_Year_Current_Month_is_MTD__c)=:year WITH SECURITY_ENFORCED];
           
            // Getting the aggregate of Snap SSL Data  
            AggregateResult[] snapSSLData   = [SELECT SUM(Completed_Originations__c)loansFunded ,SUM(Total_Funded__c) amountFinanced,SUM(Applications__c) totalApplications,
                                               SUM(Approved_Applications__c) totalApproved FROM Snapshot_Data_SSL__c WHERE Account__c IN :accountIdSet
                                               and calendar_month(Month_and_Year_Current_Month_is_MTD__c) =:monthNumber and calendar_year(Month_and_Year_Current_Month_is_MTD__c)=:year WITH SECURITY_ENFORCED];
            
            Map<String,AggregateResult[]> dataMap =new Map<String,AggregateResult[]>();
            dataMap.put('snapLTOData',snapLTOData);
            dataMap.put('snapSLNData',snapSLNData);
            dataMap.put('snapSSLData',snapSSLData);
            
            for(String mapKey:dataMap.keySet())
            {
                AggregateResult[] result = dataMap.get(mapKey);
                 for(AggregateResult aggObject : result) {
                   
                     //Using Ternary Operator to check if the field value is not Null. Adding data only if it is not null.
                    metrics.loansFunded=Integer.valueOf(aggObject.get('loansFunded'))!=null ? metrics.loansFunded+Integer.valueOf(aggObject.get('loansFunded')): metrics.loansFunded;
                    metrics.amountFinanced=(Decimal)aggObject.get('amountFinanced')!=null ?  metrics.amountFinanced+(Decimal)aggObject.get('amountFinanced') : metrics.amountFinanced;
                    metrics.totalApplications=Integer.valueOf(aggObject.get('totalApplications')) !=null ? metrics.totalApplications+Integer.valueOf(aggObject.get('totalApplications')) :metrics.totalApplications;
                    metrics.totalApproved=Integer.valueOf(aggObject.get('totalApproved')) !=null ? metrics.totalApproved+Integer.valueOf(aggObject.get('totalApproved')) :metrics.totalApproved;
                    
                 }      
            }
       
        }catch (Exception e) {
            System.debug('getKeyMetrics: Error while Getting Metrics Data : ' + e.getMessage() + ' , Error Line Number: ' + e.getLineNumber());
        }
        return metrics;
    }
    
    /* Method Name: getEdgeInfoByMonth
    * Author Name: 7Summits Backend Team
    * Description: Get the Snap Edge Info for LTO,SLN and SSL related to the user account
    * Parameters: Set<Id>
    * Returns: SnapEdgeInfoWrapper_x7sHub
    */

    public static Integer getEdgeInfoByMonth(Set<Id> accountIdSet,Integer monthNumber,Integer year)
    {	
        Integer edgeData =0;
        try{
            // Getting the aggregate of Snap LTO Data  
            AggregateResult[] snapLTOData   = [SELECT SUM(EDGE__c)totalEdgeRevenue FROM Snapshot_Data_LTO__c WHERE Account__c IN :accountIdSet
                                               and calendar_month(Month_and_Year_Current_Month_is_MTD__c) =:monthNumber and calendar_year(Month_and_Year_Current_Month_is_MTD__c)=:year WITH SECURITY_ENFORCED];
           
            // Getting the aggregate of Snap SLN Data  
            AggregateResult[] snapSLNData   = [SELECT SUM(EDGE__c)totalEdgeRevenue FROM Snapshot_Data_SLN__c WHERE Account__c IN :accountIdSet 
                                               and calendar_month(Month_and_Year_Current_Month_is_MTD__c) =:monthNumber and calendar_year(Month_and_Year_Current_Month_is_MTD__c)=:year WITH SECURITY_ENFORCED];
           
            // Getting the aggregate of Snap SSL Data  
            AggregateResult[] snapSSLData   = [SELECT SUM(EDGE__c)totalEdgeRevenue FROM Snapshot_Data_SSL__c WHERE Account__c IN :accountIdSet
                                               and calendar_month(Month_and_Year_Current_Month_is_MTD__c) =:monthNumber and calendar_year(Month_and_Year_Current_Month_is_MTD__c)=:year WITH SECURITY_ENFORCED];
            
            Map<String,AggregateResult[]> dataMap =new Map<String,AggregateResult[]>();
            dataMap.put('snapLTOData',snapLTOData);
            dataMap.put('snapSLNData',snapSLNData);
            dataMap.put('snapSSLData',snapSSLData);
            
            for(String mapKey:dataMap.keySet())
            {
                AggregateResult[] result = dataMap.get(mapKey);
                 for(AggregateResult aggObject : result) {
                   
                     //Using Ternary Operator to check if the field value is not Null. Adding data only if it is not null.
                    edgeData=Integer.valueOf(aggObject.get('totalEdgeRevenue'))!=null ? edgeData+Integer.valueOf(aggObject.get('totalEdgeRevenue')): edgeData;
                   
                 }      
            }
       
        }catch (Exception e) {
            System.debug('getEdgeInfoByMonth: Error while Getting Snap Edge Data : ' + e.getMessage() + ' , Error Line Number: ' + e.getLineNumber());
        }
        System.debug('The Snap Edge Data for the selected month '+edgeData);
        return edgeData;
    }
    
    /* Method Name: getEdgeInfoByYear
    * Author Name: 7Summits Backend Team
    * Description: Get the Snap Edge Info for LTO,SLN and SSL related to the user account year wise
    * Parameters: Set<Id>
    * Returns: SnapEdgeInfoWrapper_x7sHub
    */

    public static Integer getEdgeInfoByYear(Set<Id> accountIdSet,Integer year)
    {	
        Integer edgeData = 0; 
        try{
            // Getting the aggregate of Snap LTO Data  
            AggregateResult[] snapLTOData   = [SELECT SUM(EDGE__c)totalEdgeRevenueYearly FROM Snapshot_Data_LTO__c WHERE Account__c IN :accountIdSet
                                               and calendar_month(Month_and_Year_Current_Month_is_MTD__c) >=1 and calendar_year(Month_and_Year_Current_Month_is_MTD__c)=:year WITH SECURITY_ENFORCED];
           
            // Getting the aggregate of Snap SLN Data  
            AggregateResult[] snapSLNData   = [SELECT SUM(EDGE__c)totalEdgeRevenueYearly FROM Snapshot_Data_SLN__c WHERE Account__c IN :accountIdSet 
                                               and calendar_month(Month_and_Year_Current_Month_is_MTD__c) >=1 and calendar_year(Month_and_Year_Current_Month_is_MTD__c)=:year WITH SECURITY_ENFORCED];
           
            // Getting the aggregate of Snap SSL Data  
            AggregateResult[] snapSSLData   = [SELECT SUM(EDGE__c)totalEdgeRevenueYearly FROM Snapshot_Data_SSL__c WHERE Account__c IN :accountIdSet
                                               and calendar_month(Month_and_Year_Current_Month_is_MTD__c) >=1 and calendar_year(Month_and_Year_Current_Month_is_MTD__c)=:year WITH SECURITY_ENFORCED];
            Map<String,AggregateResult[]> dataMap =new Map<String,AggregateResult[]>();
            dataMap.put('snapLTOData',snapLTOData);
            dataMap.put('snapSLNData',snapSLNData);
            dataMap.put('snapSSLData',snapSSLData);
            
            for(String mapKey:dataMap.keySet())
            {
                AggregateResult[] result = dataMap.get(mapKey);
                 for(AggregateResult aggObject : result) {
                   //Using Ternary Operator to check if the field value is not Null. Adding data only if it is not null.
                    edgeData=Integer.valueOf(aggObject.get('totalEdgeRevenueYearly'))!=null ? edgeData+Integer.valueOf(aggObject.get('totalEdgeRevenueYearly')): edgeData;
                   
                 }      
            }
       
        }catch (Exception e) {
            System.debug('getEdgeInfoByYear: Error while Getting Snap Edge Data : ' + e.getMessage() + ' , Error Line Number: ' + e.getLineNumber());
        }
        System.debug('The Snap Edge Data for the selected month '+edgeData);
        return edgeData;
    }

    /* Method Name: getAccountHighlights
    * Author Name: 7Summits 
    * Description: Get the count of Trained Users and outstanding tasks for Adventures
    * return the complete snapshot
    * Returns: String
    */
    @AuraEnabled (Cacheable=true)
    public static String getAccountHighlights(String userId)
    {	
        //Map which stores Current and Previous Month Key Metrics Data 
        Map<String,Integer> responseMap = new  Map<String,Integer>();
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
                     
                     // Getting the Number of Trained Contacts for the Account and its sub accounts/locations
                     AggregateResult[] trainedUsersAggResult = [SELECT count(Id) trainedUsers FROM contact  WHERE AccountId IN :allAccountIds AND Contact.Enrolled__c = True AND Contact.Snap_Certified_1_for_7__c = True WITH SECURITY_ENFORCED ];
                     if(!trainedUsersAggResult.isEmpty())
                     {
                        responseMap.put('trainedUsers', (Integer)trainedUsersAggResult[0].get('trainedUsers')); 
                     }

                      // Getting the Number of Outstanding Tasks from Adventures
                      AggregateResult[] outstandingTasksAggResult = [SELECT SUM(Number_of_Outstanding_Tasks__c) outstandingTasks FROM X7S_Adventure__c WHERE OwnerId =:userId AND active__c = true WITH SECURITY_ENFORCED ];
                      if(!outstandingTasksAggResult.isEmpty())
                      {
                         responseMap.put('outstandingTasks', Integer.valueof(outstandingTasksAggResult[0].get('outstandingTasks'))); 
                      }
                     
                    }
        }
        //Returning the response with Key Metrics and Edge data as Json String
       	System.debug('The Final Response to be Returned as JSON '+JSON.serialize(responseMap));      
        return JSON.serialize(responseMap);
    }

    /* Method Name: getCurrentJourneyStage
    * Author Name: 7Summits 
    * Description: Get the current stage for the account Journey
    * return the complete snapshot
    * Returns: String
    */
    @AuraEnabled (Cacheable=true)
    public static String getCurrentJourneyStage(String userId)
    {	
        String methodName ='getCurrentJourneyStage';

        //Map which stores Current and Previous Month Key Metrics Data 
        Map<String,String> responseMap = new  Map<String,String>();
        
        if(String.isNotBlank(userId))
        {
                // Getting the accountId based on the User Id
                String accountId =Utility_x7sHub.getAccountIdByUser(userId);
                System.debug(methodName+' The account Id associated with user '+userId+': '+accountId);
                if(String.isNotBlank(accountId))
                {
                    
                     // Getting the current Journey Stage
                     Account account = [SELECT Stage__c FROM account  where Id=:accountId WITH SECURITY_ENFORCED ];
                     responseMap.put('journeyStage', account.Stage__c);
                }
        }
        
       	System.debug(methodName+ ' The Final Response to be Returned as JSON '+JSON.serialize(responseMap));      
        return JSON.serialize(responseMap);
    }
    
}