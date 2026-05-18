public class ODS_AddStatusReportExternal {
    
    public static Boolean excludeJiraReport(){
        Boolean  excludeJira= [Select id, Exclude_Jira_report_from_DSR__c from User where id =: UserInfo.getUserId()].Exclude_Jira_report_from_DSR__c;
        return excludeJira;
    } 

    
    public static void addOnStatus(Id accSrvcId, Id lstNxtSRId){
        List<String> lstJira =  new List<String>();        
        List<Initiatives__c> initList = [Select id, Jira_Id__c from Initiatives__c where Status__c =: 'Active Initiative' and Account_Service__c =: accSrvcId];
        
        system.debug('initList : ' +initList);
        lstJira = sortJira(initList);
        system.debug(' lstJira : '+lstJira);
                           
        if(!lstJira.isEmpty())
        {
            ODS_JIRAIntegration.callOutToJira(lstJira,lstNxtSRId);
            system.debug('After Callout@@');
        } 
    }    
    
    
    public static List<String> sortJira(List<Initiatives__c> initList){
        system.debug('initList : '+initList);
        list <String> sfinal = new List<String>();
              
        String [] finalss = new List<String>();
        for(Initiatives__c inp : initList){
            try{                
                string data = inp.Jira_Id__c;
                
                if(String.isBlank(data)){
                    continue;
                }
                
                data = data.replace('  ', ' ');
                string story = '';
                string  extract = '';
                if(data.contains('-'))
                {
                    story = data.split('-')[0];
                    //extract = data.split("-")[1];
                }
                else
                {
                    story = data.split(' ')[0];
                    //extract = data.split(" ")[1];
                }
                extract = data.substring(story.length(),data.length()).replaceFirst('-','').replace(story,'').replace(' ','');
                
                List<string> extractArray = extract.split(',');
                //document.getElementById("demo").innerHTML =story;
                for(Integer i=0;i<extractArray.size();i++)
                {
                    if(extractArray[i].contains('&'))
                    {
                        list<string> internalData = extractArray[i].split('&');
                        for(Integer j=0;j<internalData.size();j++)
                        {
                            System.Matcher pm = Pattern.compile('^[a-zA-Z]{1,8}-[0-9]{1,6}$').matcher( story + '-' + internalData[j] );
                            if(pm.matches()){
                                finalss.add(story + '-' + internalData[j]);
                            }
                        }
                    }
                    else if(extractArray[i].contains('to') || extractArray[i].contains('thru') || extractArray[i].contains('–') || extractArray[i].contains('-'))
                    {
                        List<string> internalData = new List<string>();
                        if(extractArray[i].contains('to')!= null){
                            internalData = extractArray[i].split('to');
                        }
                        if(extractArray[i].contains('thru')!= null){
                            internalData = extractArray[i].split('thru');
                        }
                        if(extractArray[i].contains('–')!=null){
                            internalData = extractArray[i].split('–');
                        }
                        if(extractArray[i].contains('-')!=null){
                            internalData = extractArray[i].split('-');
                        } 
                        system.debug('111internalData'+internalData);
                        Integer start = Integer.valueOf(internalData[0].trim());
                        system.debug('2222internalData'+internalData);
                        Integer ends = Integer.valueOf(internalData[1].trim());
                        finalss.add(story + '-' + start);
                        for(Integer j=start; j<ends;j++)
                        {
                            
                            System.Matcher pm1 = Pattern.compile('^[a-zA-Z]{1,8}-[0-9]{1,6}$').matcher(story + '-' + (j+1) );
                            if(pm1.matches()){
                                finalss.add(story + '-' + (j+1));
                            }    
                        }
                    }
                    else
                    {
                        System.Matcher pm2 = Pattern.compile('^[a-zA-Z]{1,8}-[0-9]{1,6}$').matcher(story + '-' + extractArray[i]);
                        if(pm2.matches()){
                            finalss.add(story + '-' + extractArray[i]);
                        }
                    }
                }
                System.debug('finalss///'+finalss);
                
            }               
            catch(Exception e)    
            {
                system.debug(e.getMessage());
                ODS_ExceptionUtility.saveErrorLogs(string.Valueof(e.getCause()), e.getMessage(), e.getStackTraceString(), e.getTypeName());
            }            
        }
     
        return finalss;
    }    

}