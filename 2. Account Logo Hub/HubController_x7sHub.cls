/**********************************************************************************************
* Name : HubController_x7sHub
* Author : 7Summits Backend Team
* Description : This is a Controller class for getting the details related to Snap Finance Team
* Comments : The Class is declared 'Without Sharing' as we have to fetch the details of the owner 
	 co-owner and logo of the Ultimate Parent.
*******************************************************************************************/
public without sharing class HubController_x7sHub {
    
    // Get the Limit of the Rows to be fetched
    private static Integer rowsLimit {get {
        if(rowsLimit==null)
        {
            rowsLimit= System.Limits.getLimitQueryRows();
        }
        return rowsLimit;
    }
    set;}
    /* Method Name: getSnapSupportTeam
    * Author Name: 7Summits Backend Team
    * Description: Get the details of the Snap Support Team which includes details of the Owner and Co-Owner
    * Parameters: String 
    * Returns: String
    */
    @AuraEnabled (Cacheable=true)
    public static String getSnapSupportTeam(String userId)
    {	
        //Created a List of User Object which stores details of all account team members
        List<SnapUser_x7sHub> userList = new List<SnapUser_x7sHub>();
        
        if(String.isNotBlank(userId))
        {
            try{
                // Getting the accountId based on the User Id
                String accountId =Utility_x7sHub.getAccountIdByUser(userId);

                System.debug('The account Id associated with user '+userId+': '+accountId);
                if(String.isNotBlank(accountId))
                {
                    List<AccountTeamMember> accountTeamMemberList =
                    [   SELECT Id, AccountId, UserId, TeamMemberRole, User.FirstName, User.LastName, User.FunFact__c, User.Email, User.Title, User.MediumPhotoUrl
                        FROM AccountTeamMember
                        WHERE AccountId = :accountId    ];

                    if(!accountTeamMemberList.isEmpty()){
                        for(accountTeamMember member : accountTeamMemberList){
                            SnapUser_x7sHub teamMember = new SnapUser_x7sHub();
                            
                            teamMember.id = member.User.Id;
                            teamMember.email = member.User.Email;
                            teamMember.funFact = member.User.FunFact__c;
                            teamMember.title = member.User.Title;
                            teamMember.photoURL = member.User.MediumPhotoUrl;
                            String firstName = String.isBlank(member.User?.FirstName) ? '' : member.User.FirstName;
                            String LastName = String.isBlank(member.User?.LastName) ? '' : member.User.LastName;
                            teamMember.name = (firstName + ' ' + LastName).trim();
                            userList.add(teamMember);
                        }
                    }
                }
            }catch (Exception e) 
            { 
                System.debug('getSnapSupportTeam Error Message: ' + e.getMessage() + ' , Error Line Number: ' + e.getLineNumber());
                System.debug('Stack trace: ' + e.getStackTraceString()); 
            }
        }
        System.debug('userList :' +JSON.serialize(userList));
        // Serializing the List and sending it as JSON
        return JSON.serialize(userList);
    }

    /* Method Name: getAccountLogo
    * Author Name: 7Summits Backend Team
    * Description: Get the details of the Snap Support Team which includes details of the Owner and Co-Owner
    * Parameters: String 
    * Returns: String
    */
    @AuraEnabled (Cacheable=true)
    public static String getAccountLogo(String userId)
    {
        String logoURL='';
        if(String.isNotBlank(userId))
        {
            try{
                // Getting the accountId based on the User Id
                Account account =Utility_x7sHub.getAccountDetails(userId);
               
               if(null !=account)
                {
                    List<Account> ultParentAccount= [SELECT Logo_URL__c FROM Account WHERE Id =:account.Ultimate_Parent_Id__c ];
                    System.debug('The Account details for Ultimate Parent Id  :'+account.Ultimate_Parent_Id__c+' : '+ultParentAccount);
                    
                    if(!ultParentAccount.isEmpty()){
                    	logoURL =ultParentAccount[0].Logo_URL__c;
                    }
                 }
            }catch (Exception e) 
            { 
                System.debug('getAccountLogo Error Message: ' + e.getMessage() + ' , Error Line Number: ' + e.getLineNumber());
                System.debug('Stack trace: ' + e.getStackTraceString()); 
            }
        }
        
        System.debug('The Photo Url for the ultimate Parent :' +logoURL);
        return logoURL;
    
    }	

    /* Method Name: getCadenceCallLogs
    * Author Name: 7Summits 
    * Description: Get the details of all the Calls 
    * Parameters: String 
    * Returns: String
    */
    @AuraEnabled (Cacheable=true)
    public static String getCadenceCallLogs(String userId)
    {	
        String methodName = 'getCadenceCallLogs';
        List<EnterpriseCallWrapper_x7sHub> response = new List<EnterpriseCallWrapper_x7sHub>();
        if(String.isNotBlank(userId))
        {
            try{
                // Getting the accountId based on the User Id
                String accountId =Utility_x7sHub.getAccountIdByUser(userId);
                System.debug('The account Id associated with user '+userId+': '+accountId);
                
                if(String.isNotBlank(accountId))
                {
                    List<Enterprise_Call__c>  callsList =[SELECT  name, Id,Account__c, Date_Time__c,  Owner.name FROM Enterprise_Call__c WHERE Account__c =:accountId WITH SECURITY_ENFORCED ORDER BY Date_Time__c desc LIMIT :rowsLimit];
                
                        if(!callsList.isEmpty())
                        {
                            // Populating the EnterpriseCallsWrapper with the details
                            for(Enterprise_Call__c call:callsList){
                                EnterpriseCallWrapper_x7sHub wrapper = new EnterpriseCallWrapper_x7sHub();
                                wrapper.id = call.Id;
                                wrapper.name = call.name;
                                wrapper.owner = call.Owner.name;
                                wrapper.callDate = call.Date_Time__c;
                                response.add(wrapper);
                            }
                        }
                }
            }catch (Exception e) 
            { 
                System.debug(methodName+' Error Message: ' + e.getMessage() + ' , Error Line Number: ' + e.getLineNumber());
                System.debug('Stack trace: ' + e.getStackTraceString()); 
            }
        }
        System.debug(methodName+' callList :' +JSON.serialize(response));
        // Serializing the List and sending it as JSON
        return JSON.serialize(response);
    }

    /* Method Name: getCadenceCallLogsInPages
    * Author Name: 7Summits 
    * Description: Get the details of all the Cadence Calls related to the account supporting Pagination
    * Parameters: String, Integer pageNumber,Integer recordsPerPage
    * Returns: String
    */
    @AuraEnabled (Cacheable=true)
    public static String getCadenceCallLogsInPages(String userId,Integer pageNumber,Integer recordsPerPage)
    {	
        String methodName = 'getCadenceCallLogsInPages';
        Map<String,Object> responseMap = new  Map<String,Object>();
        List<EnterpriseCallWrapper_x7sHub> response = new List<EnterpriseCallWrapper_x7sHub>();
        Integer totalRecordsCount =0; 
        if(String.isNotBlank(userId))
        {
            try{
                // Getting the accountId based on the User Id
                String accountId =Utility_x7sHub.getAccountIdByUser(userId);
                System.debug('The account Id associated with user '+userId+': '+accountId);
                if(String.isNotBlank(accountId))
                {
                     //Logic for Pagination 
                    // Calculating the Start Index for the ContactsList
                    Integer startIndex = (recordsPerPage * (pageNumber-1));
                    System.debug('The StartIndex to fetch the records from List :'+startIndex);
                    
                    // Calculating the Start Index for the ContactsList
                    Integer endIndex =(startIndex + recordsPerPage)-1;
                    System.debug('The EndIndex to fetch the records from List :'+endIndex);

                    List<Enterprise_Call__c>  callsList =[SELECT  name, Id,Account__c, Date_Time__c, Owner.name FROM Enterprise_Call__c WHERE Account__c =:accountId WITH SECURITY_ENFORCED ORDER BY Date_Time__c desc LIMIT :rowsLimit ];
                
                        if(!callsList.isEmpty())
                        {
                            // Get the Size of the Original List
                            totalRecordsCount = callsList.size();
                            System.debug('Total Number of Records fetched '+totalRecordsCount);
                            // Check if the startIndex is less than max Records
                            if(startIndex <= totalRecordsCount && endIndex > totalRecordsCount)
                            {
                                // If endIndex is greater than maximum records, update the endIndex
                                   endIndex = totalRecordsCount;
                            }
                            else if(startIndex <= totalRecordsCount && endIndex == totalRecordsCount)
                            {
                                    endIndex = endIndex-1;
                            }
                            // Populating the EnterpriseCallsWrapper with the details

                            
                            for(Integer i=startIndex;i<=endIndex;i++)
                            {
                                EnterpriseCallWrapper_x7sHub wrapper = new EnterpriseCallWrapper_x7sHub();
                               	wrapper.id = callsList[i].Id;
                                wrapper.name = callsList[i].name;
                                wrapper.owner = callsList[i].Owner.name;
                                wrapper.callDate = callsList[i].Date_Time__c;
                                response.add(wrapper);

                            }
                            
                        }
                }
            }catch (Exception e) 
            { 
                System.debug(methodName+' Error Message: ' + e.getMessage() + ' , Error Line Number: ' + e.getLineNumber());
                System.debug('Stack trace: ' + e.getStackTraceString()); 
            }
        }
        responseMap.put(SnapHubConstants_x7sHub.RECORDS,response);
        responseMap.put(SnapHubConstants_x7sHub.TOTAL_RECORDS,totalRecordsCount);   
        System.debug(methodName+' callList :' +JSON.serialize(responseMap));
        // Serializing the List and sending it as JSON
        return JSON.serialize(responseMap);
    }

   /* Method Name: getLastCallSummary
    * Author Name: 7Summits 
    * Description: Get the summary of the last Cadence Call
    * Parameters: String 
    * Returns: String
    */
    @AuraEnabled (Cacheable=true)
    public static String getLastCallSummary(String userId)
    {	
        String methodName = 'getLastCallSummary';
        EnterpriseCallWrapper_x7sHub wrapper = new EnterpriseCallWrapper_x7sHub();
        if(String.isNotBlank(userId))
        {
            try{
                // Getting the accountId based on the User Id
                String accountId =Utility_x7sHub.getAccountIdByUser(userId);
                System.debug('The account Id associated with user '+userId+': '+accountId);
                if(String.isNotBlank(accountId))
                {
                    DateTime currentTime = system.now();
                    System.debug(methodName+' Current Date Time :'+currentTime);
                    Enterprise_Call__c  call =[SELECT name, Id,Account__c, Date_Time__c, Owner.name,Agenda__c  FROM Enterprise_Call__c WHERE Account__c =:accountId AND Date_Time__c < :currentTime  WITH SECURITY_ENFORCED ORDER BY Date_Time__c desc limit 1 ];
                
                        if(null !=call)
                        {
                                wrapper.id = call.Id;
                                wrapper.owner = call.Owner.name;
                                wrapper.name = call.name;
                                wrapper.callDate = call.Date_Time__c;
                                wrapper.agenda =call.Agenda__c; 
                        }
                }
                
            }catch (Exception e) 
            { 
                System.debug(methodName+' Error Message: ' + e.getMessage() + ' , Error Line Number: ' + e.getLineNumber());
                System.debug('Stack trace: ' + e.getStackTraceString()); 
            }
        }
        System.debug(methodName+' Last Call Summary :' +JSON.serialize(wrapper));
        // Serializing the Response and sending it as JSON
        return JSON.serialize(wrapper);
    }

    
    /* Method Name: getOutstandingActionItems
    * Author Name: 7Summits 
    * Description: Get the outstanding Action Items(Not Closed) related to the Cadence calls for that account
    * Parameters: String 
    * Returns: String
    */
    @AuraEnabled (Cacheable=true)
    public static String getOutstandingActionItems(String userId)
    {	
        String methodName = 'getOutstandingActionItems';
        List<ActionItemWrapper_x7sHub> response = new List<ActionItemWrapper_x7sHub>();
        if(String.isNotBlank(userId))
        {
            try{
                // Getting the accountId based on the User Id
                String accountId =Utility_x7sHub.getAccountIdByUser(userId);
                System.debug('The account Id associated with user '+userId+': '+accountId);
                if(String.isNotBlank(accountId))
                {
                    String accountIdTrimmed = String.valueof(accountId).substring(0,15);
                    List<Action_Item__c>  actionItems =[SELECT Name, Id,Description__c,Assignee__r.Name, Due_Date__c,Enterprise_Call_Account_ID__c FROM Action_Item__c WHERE Enterprise_Call_Account_ID__c =:accountIdTrimmed AND Status__c !='Closed'  WITH SECURITY_ENFORCED ORDER BY Due_Date__c asc];
                
                    if(!actionItems.isEmpty())
                    {
                        // Populating the EnterpriseCallsWrapper with the details
                        for(Action_Item__c actionItem : actionItems){
                            ActionItemWrapper_x7sHub wrapper = new ActionItemWrapper_x7sHub();
                           
                            wrapper.id = actionItem.Id;
                            wrapper.name = actionItem.Name;
                            wrapper.description = actionItem.Description__c;
                            wrapper.assignee = actionItem.Assignee__r.Name;
                            wrapper.dueDate = actionItem.Due_Date__c;
                            response.add(wrapper);
                        }

                    }
                }
                
            }catch (Exception e) 
            { 
                System.debug(methodName+' Error Message: ' + e.getMessage() + ' , Error Line Number: ' + e.getLineNumber());
                System.debug('Stack trace: ' + e.getStackTraceString()); 
            }
        }
        System.debug(methodName+' Outstanding Action Items ' +JSON.serialize(response));
        // Serializing the Response and sending it as JSON
        return JSON.serialize(response);
    }

    /* Method Name: getUpcomingTouchPoint
    * Author Name: 7Summits 
    * Description: Get the Upcoming Touchpoint
    * Parameters: String 
    * Returns: String
    */
    @AuraEnabled (Cacheable=true)
    public static String getUpcomingTouchPoint(String userId)
    {	
        String methodName = 'getUpcomingTouchPoint';
        Map<String,Object> responseMap = new Map<String,Object>(); 
        if(String.isNotBlank(userId))
        {
            try{
                // Getting the accountId based on the User Id
                String accountId =Utility_x7sHub.getAccountIdByUser(userId);
                System.debug('The account Id associated with user '+userId+': '+accountId);
                if(String.isNotBlank(accountId))
                {
                    DateTime currentTime = system.now();
                    Date currentDate = system.today();
                    System.debug(methodName+' Current Date Time :'+currentTime);
                    // Fetch the Upcoming Enterprise call 
                    List<Enterprise_Call__c>  enterpriseCall =[SELECT name, Id, Date_Time__c FROM Enterprise_Call__c WHERE Account__c =:accountId AND Date_Time__c > :currentTime  WITH SECURITY_ENFORCED ORDER BY Date_Time__c ASC LIMIT 1 ];
                    // Fetch the Upcoming Enterprise Business Review Meeting 
                    List<Business_Review__c> eBRMeeting =[SELECT id,Name,Meeting_Date__c FROM Business_Review__c WHERE Account_Name__r.id =:accountId AND Meeting_Date__c > :currentDate  WITH SECURITY_ENFORCED ORDER BY  Meeting_Date__c  ASC LIMIT 1 ];
                    String typeOfCall =SnapHubConstants_x7sHub.BLANK_STRING;
                    // Compare the Enterprise call date and EBR meeting date 
                    if( !enterpriseCall.isEmpty() && !eBRMeeting.isEmpty())
                    {
                        DateTime enterpriseCallDate = enterpriseCall[0].Date_Time__c;
                        DateTime eBRMeetingDate = eBRMeeting[0].Meeting_Date__c;
                            if(enterpriseCallDate < eBRMeetingDate)
                            {
                                typeOfCall =SnapHubConstants_x7sHub.CALL_TYPE_CADENCE;
                            }
                            else
                            {
                                typeOfCall =SnapHubConstants_x7sHub.CALL_TYPE_EBR;
                            }    
                    }   
                    else if( !enterpriseCall.isEmpty())
                    {
                        // Making upcoming Touchpoint as Cadence Call 
                        typeOfCall =SnapHubConstants_x7sHub.CALL_TYPE_CADENCE;
                    }
                    else if( !eBRMeeting.isEmpty())
                    {
                         // Making upcoming Touchpoint as EBR
                        typeOfCall =SnapHubConstants_x7sHub.CALL_TYPE_EBR;
                    }
                    // Based on the value of the CALL Type, prepare the Response Map
                    if(typeOfCall.equalsIgnoreCase(SnapHubConstants_x7sHub.CALL_TYPE_CADENCE)){
                            DateTime enterpriseCallDate = enterpriseCall[0].Date_Time__c;
                        	responseMap.put(SnapHubConstants_x7sHub.CALL_ID,enterpriseCall[0].Id);
                        	responseMap.put(SnapHubConstants_x7sHub.CALL_DATE,enterpriseCallDate);
                        	responseMap.put(SnapHubConstants_x7sHub.CALL_TYPE,SnapHubConstants_x7sHub.CALL_TYPE_CADENCE);
                    }
                    if(typeOfCall.equalsIgnoreCase(SnapHubConstants_x7sHub.CALL_TYPE_EBR)){
                            DateTime eBRMeetingDate = eBRMeeting[0].Meeting_Date__c;
                         	responseMap.put(SnapHubConstants_x7sHub.CALL_ID,eBRMeeting[0].Id);
                        	responseMap.put(SnapHubConstants_x7sHub.CALL_DATE,eBRMeetingDate);
                        	responseMap.put(SnapHubConstants_x7sHub.CALL_TYPE,SnapHubConstants_x7sHub.CALL_TYPE_EBR);
                    }
                }
                
            }catch (Exception e) 
            { 
                System.debug(methodName+' Error Message: ' + e.getMessage() + ' , Error Line Number: ' + e.getLineNumber());
                System.debug('Stack trace: ' + e.getStackTraceString()); 
            }
        }
        System.debug(methodName+' Upcoming Touchpoint :' +JSON.serialize(responseMap));
        // Serializing the Response and sending it as JSON
        return JSON.serialize(responseMap);
    }

    /* Method Name: getOpenEBRGoals
    * Author Name: 7Summits 
    * Description: Get the Open Enterprise Business Review Goals for the account
    * Parameters: String 
    * Returns: String
    */
    @AuraEnabled (Cacheable=true)
    public static String getOpenEBRGoals(String userId)
    {	
        String methodName = 'getOpenEBRGoals';
        List<EBRGoalsWrapper_x7sHub> response = new List<EBRGoalsWrapper_x7sHub>();
        if(String.isNotBlank(userId))
        {
            try{
                // Getting the accountId based on the User Id
                String accountId =Utility_x7sHub.getAccountIdByUser(userId);
                System.debug('The account Id associated with user '+userId+': '+accountId);
                if(String.isNotBlank(accountId))
                {
                    List<String> excludedStatusList = new List<String>{'Closed', 'Completed'};
                    String accountIdTrimmed = String.valueof(accountId).substring(0,15);
                    List<Business_Goal__c>  businessGoals =[SELECT Id,Name, Related_Pillar__c, Status__c, Target_Date__c FROM Business_Goal__c  WHERE Account_ID__c =:accountIdTrimmed AND Status__c NOT IN :excludedStatusList  WITH SECURITY_ENFORCED ORDER BY Target_Date__c asc Limit :rowsLimit];
                
                    if(!businessGoals.isEmpty())
                    {
                        // Populating the EBRGoalsWrapper_x7sHub with the details
                        for(Business_Goal__c businessGoal : businessGoals){
                            EBRGoalsWrapper_x7sHub wrapper = new EBRGoalsWrapper_x7sHub();
                           
                            wrapper.id = businessGoal.Id;
                            wrapper.title = businessGoal.Name;
                            wrapper.pillar = businessGoal.Related_Pillar__c;
                            wrapper.status = businessGoal.Status__c;
                            wrapper.targetDate = businessGoal.Target_Date__c;
                            response.add(wrapper);
                        }

                    }
                }
                
            }catch (Exception e) 
            { 
                System.debug(methodName+' Error Message: ' + e.getMessage() + ' , Error Line Number: ' + e.getLineNumber());
                System.debug('Stack trace: ' + e.getStackTraceString()); 
            }
        }
        System.debug(methodName+' Open EBR Goals ' +JSON.serialize(response));
        // Serializing the Response and sending it as JSON
        return JSON.serialize(response);
    }

    /* Method Name: getEBRMeetingsInPages
    * Author Name: 7Summits 
    * Description: Get the details of all the Enterprise Business Review Meetings related to the account supporting Pagination
    * Parameters: String, Integer pageNumber,Integer recordsPerPage
    * Returns: String
    */
    @AuraEnabled (Cacheable=true)
    public static String getEBRMeetingsInPages(String userId,Integer pageNumber,Integer recordsPerPage)
    {	
        String methodName = 'getEBRMeetingsInPages';
        Map<String,Object> responseMap = new  Map<String,Object>();
        List<EBRMeetingsWrapper_x7sHub> response = new List<EBRMeetingsWrapper_x7sHub>();
        Integer totalRecordsCount =0; 
        if(String.isNotBlank(userId))
        {
            try{
                // Getting the accountId based on the User Id
                String accountId =Utility_x7sHub.getAccountIdByUser(userId);
                System.debug('The account Id associated with user '+userId+': '+accountId);
                if(String.isNotBlank(accountId))
                {
                     //Logic for Pagination 
                    // Calculating the Start Index for the ContactsList
                    Integer startIndex = (recordsPerPage * (pageNumber-1));
                    System.debug('The StartIndex to fetch the records from List :'+startIndex);
                    
                    // Calculating the Start Index for the ContactsList
                    Integer endIndex =(startIndex + recordsPerPage)-1;
                    System.debug('The EndIndex to fetch the records from List :'+endIndex);

                    List<Business_Review__c>  ebrMeetingsList =[SELECT id, Name, Meeting_Date__c,Owner.Name FROM Business_Review__c WHERE Account_Name__r.id =:accountId
                                                              WITH SECURITY_ENFORCED ORDER BY Meeting_Date__c desc LIMIT :rowsLimit ];
                
                        if(!ebrMeetingsList.isEmpty())
                        {
                            // Get the Size of the Original List
                            totalRecordsCount = ebrMeetingsList.size();
                            System.debug('Total Number of Records fetched '+totalRecordsCount);
                            // Check if the startIndex is less than max Records
                            if(startIndex <= totalRecordsCount && endIndex > totalRecordsCount)
                            {
                                // If endIndex is greater than maximum records, update the endIndex
                                   endIndex = totalRecordsCount;
                            }
                            else if(startIndex <= totalRecordsCount && endIndex == totalRecordsCount)
                            {
                                    endIndex = endIndex-1;
                            }
                            // Populating the EnterpriseCallsWrapper with the details

                            
                            for(Integer i=startIndex;i<=endIndex;i++)
                            {
                                EBRMeetingsWrapper_x7sHub wrapper = new EBRMeetingsWrapper_x7sHub();
                               	wrapper.id = ebrMeetingsList[i].Id;
                                wrapper.title = ebrMeetingsList[i].name;
                                wrapper.owner = ebrMeetingsList[i].Owner.name;
                                wrapper.meetingDate = ebrMeetingsList[i].Meeting_Date__c;
                                response.add(wrapper);
                            }
                            
                        }
                }
            }catch (Exception e) 
            { 
                System.debug(methodName+' Error Message: ' + e.getMessage() + ' , Error Line Number: ' + e.getLineNumber());
                System.debug('Stack trace: ' + e.getStackTraceString()); 
            }
        }
        responseMap.put(SnapHubConstants_x7sHub.RECORDS,response);
        responseMap.put(SnapHubConstants_x7sHub.TOTAL_RECORDS,totalRecordsCount);   
        System.debug(methodName+' Meetings List :' +JSON.serialize(responseMap));
        // Serializing the List and sending it as JSON
        return JSON.serialize(responseMap);
    }
    
 /* Method Name: getEBRGoalsByGrouping
    * Author Name: 7Summits 
    * Description: Get the Open Enterprise Business Review Goals for the account group by either Timeline or Related Pillar
    * Parameters: String 
    * Returns: String
    */
    @AuraEnabled (Cacheable=true)
    public static String getEBRGoalsByGrouping(String userId,String groupType)
    {	
        String methodName = 'getEBRGoalsByGrouping';
        
        Map<Object,List<EBRGoalsWrapper_x7sHub>> responseMap = new Map<Object,List<EBRGoalsWrapper_x7sHub>>();
        if(String.isNotBlank(userId))
        {
            try{
                // Getting the accountId based on the User Id
                String accountId =Utility_x7sHub.getAccountIdByUser(userId);
                System.debug('The account Id associated with user '+userId+': '+accountId);
                if(String.isNotBlank(accountId))
                {
                    String accountIdTrimmed = String.valueof(accountId).substring(0,15);
                    List<Business_Goal__c>  businessGoals ;
                    if(groupType.equalsIgnoreCase('Pillar'))
                    {
                        businessGoals =[SELECT Id,Name,Related_Pillar__c, Status__c, Target_Date__c FROM Business_Goal__c  WHERE Account_ID__c =:accountIdTrimmed  WITH SECURITY_ENFORCED ORDER BY Related_Pillar__c,Target_Date__c ASC Limit :rowsLimit];
                    }
                    else{
                        businessGoals =[SELECT Id,Name,Related_Pillar__c, Status__c, Target_Date__c FROM Business_Goal__c  WHERE Account_ID__c =:accountIdTrimmed  WITH SECURITY_ENFORCED ORDER BY Target_Date__c desc Limit :rowsLimit];
                    }
                
                    if(!businessGoals.isEmpty())
                    {
                        // Populating the EBRGoalsWrapper_x7sHub with the details
                        for(Business_Goal__c businessGoal : businessGoals){
                            EBRGoalsWrapper_x7sHub wrapper = new EBRGoalsWrapper_x7sHub();
                            wrapper.id = businessGoal.Id;
                            wrapper.title = businessGoal.Name;
                            wrapper.pillar = businessGoal.Related_Pillar__c;
                            wrapper.status = businessGoal.Status__c;
                            wrapper.targetDate = businessGoal.Target_Date__c;
                            
                            List<EBRGoalsWrapper_x7sHub> eBrGoalsList;
                            
                            if(groupType.equalsIgnoreCase('Pillar'))
                            {
                                // Get the list of Goals if the Map key already exists
                                if(!responseMap.isEmpty() && responseMap.containsKey(wrapper.pillar))
                                {
                                    eBrGoalsList = responseMap.get(wrapper.pillar);  
                                }
                                else{
                                    //Create a new List if the Map doesnt have the key
                                    eBrGoalsList = new List<EBRGoalsWrapper_x7sHub>();  
                                } 
                                eBrGoalsList.add(wrapper);
                                responseMap.put(wrapper.pillar,eBrGoalsList);
                            }
                            else
                            {
                                if(!responseMap.isEmpty() && responseMap.containsKey(wrapper.targetDate))
                                {
                                    eBrGoalsList = responseMap.get(wrapper.targetDate);  
                                }
                                else{
                                    eBrGoalsList = new List<EBRGoalsWrapper_x7sHub>();  
                                } 
                                eBrGoalsList.add(wrapper);
                                responseMap.put(wrapper.targetDate,eBrGoalsList);
                            }

                        }

                    }
                }
                
            }catch (Exception e) 
            { 
                System.debug(methodName+' Error Message: ' + e.getMessage() + ' , Error Line Number: ' + e.getLineNumber());
                System.debug('Stack trace: ' + e.getStackTraceString()); 
            }
        }
        System.debug(methodName+'getEBRGoalsByGrouping ' +JSON.serialize(responseMap));
        // Serializing the Response and sending it as JSON
        return JSON.serialize(responseMap);
    }

}