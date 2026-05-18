global class ODS_CaseSchedule implements Database.Batchable<sObject>{

    global Database.QueryLocator start(Database.BatchableContext bc){
        
        List<Account> accList = [SELECT Id FROM Account WHERE Is_Portal_Access__c = true AND Force_com_Account_Status__c = '7: Customer' AND Count_of_Services__c > 0 ORDER BY Name ASC];
        system.debug('accList : '+ accList);
		return Database.getQueryLocator([SELECT Id, Account__r.Name FROM Account_Services__c WHERE Account__c IN: accList AND ODS_Services__r.Name__c = 'Salesforce']);
        
    }
    
    global void execute(Database.BatchableContext bc, List<Account_Services__c> accServicesList){
        
        Date currentDate = system.today();
        Integer currMonth = system.today().month();
        Integer currYear = system.today().year();
        
        String release;
        String releaseDate;   
        
        List<string> customRelease = Label.Release_Timeline.split(';'); //custom Label
        if(customRelease != null){
            for(String cs : customRelease){
                
                List<String> releaseInfo = cs.split('\\|'); // 3-6|Summer|0|May/June|0
                system.debug('releaseInfo[] : ' + releaseInfo);
                
                List<String> monthRange = releaseInfo[0].split('-'); //Month Range-->3,6
                
                integer initMonth = Integer.valueOf(monthRange[0]);
                integer endMonth = Integer.valueOf(monthRange[1]);
                
                for(Integer i = initMonth ; i <= endMonth; i++)
                {
                    if(currMonth == i){ 
                        String seasonYr;
                        String monthYr;
                        if(Integer.valueOf(releaseInfo[2]) != 0){
                            seasonYr = String.valueOf(currYear + 1).substring(2);
                        }
                        else{
                            seasonYr = String.valueOf(currYear).substring(2);  
                        }
                        release = releaseInfo[1] + ' \'' + seasonYr;
                        system.debug('release: '+release);
                        
                        if(Integer.valueOf(releaseInfo[4]) != 0){
                            monthYr = String.valueOf(currYear + 1);
                        }
                        else{
                            monthYr = String.valueOf(currYear);   
                        }
                        releaseDate = releaseInfo[3] + ', ' + monthYr;
                        system.debug('releaseDate: '+ releaseDate);
                        
                    }      
                }
            }
            
        }
        
        if(!accServicesList.isEmpty()){
 
            Map<id,Case> caseMap = new Map<id,Case>();
            for(Case cs : [SELECT Id,Account_Services__c FROM Case WHERE Account_Services__c IN: accServicesList AND Type = 'Release Update' AND Release__c =: release]){
            		caseMap.put(cs.Account_Services__c,cs);
       		}
            
            List<Case> caseList = new List<Case>();

            //Iterating over Account Services
            for(Account_Services__c acs : accServicesList){
                if(caseMap.get(acs.id) == null){
                    Case c  = new Case();
                    c.Status = 'Not Started';
                    c.Type = 'Release Update';
                    c.Reason = 'Release Updates and Impact Analysis';
                    c.Origin = 'Web';
                    c.Subject = 'Release Updates and Impact Analysis for ' + acs.Account__r.Name;
                    c.Account_Services__c = acs.id;
                    c.Release__c = release;
                    c.Release_Date__c = releaseDate;
                    caseList.add(c);
                }
            }
        	insert caseList;
            
        }      
        
    }
    
    global void finish(Database.BatchableContext bc){
        
	}
}