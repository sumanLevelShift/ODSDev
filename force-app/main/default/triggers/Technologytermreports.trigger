/*******************************************************************************************
* @author           Vignesh M
* @version          1.0 
* @Status           Development Completed
* @Trigger Name     Technologytermreports
* @description      This is the trigger For updating technology term field if the comments contains from Technology_Terms__mdt 
*********************************************************************************************
Version     Date            Team            Comments
*********************************************************************************************
* 1         18 Dec 2020     DemandBlue      Initial Development
*********************************************************************************************/
trigger Technologytermreports on Task (after insert,after update) {
    List<Task> Updateinstance = new List<Task>();
    List<Technology_Terms__mdt> arrayname =  new List<Technology_Terms__mdt>();
    String subjectstring = label.TechnologyTermReportSubject;
    List<string> subjectStringList = subjectstring.split(',');
    arrayname = [SELECT Label FROM Technology_Terms__mdt];
    
    List<task> Tasktoupdate1 = [SELECT Description,Id,Subject,Technology_Terms_report__c FROM Task WHERE id =:trigger.new and subject NOT IN :subjectStringList];
    if(trigger.isInsert)
    {
        for (Task tasks : Tasktoupdate1)
        {
            if(tasks.Description != null ) {
                string getTechTerm=tasks.Description;
                string containingData ='';
                boolean flage = false ;
                for(Technology_Terms__mdt  checkTermName : arrayname ){
                    
                    if(getTechTerm.containsIgnoreCase(checkTermName.Label)){
                        if(flage){
                            containingData += ','; 
                        }
                        containingData += checkTermName.Label;
                        flage = true;
                        // system.debug('Test' +checkTermName.Label);
                    }            
                }
                Task taskToUpdate = new Task();  
                taskToUpdate.Technology_Terms_report__c = containingData;
                taskToUpdate.Id=tasks.Id;
                Updateinstance.add(taskToUpdate);         
            }
        }
    }
    update Updateinstance;
    if(trigger.isUpdate)
    {
        for (Task taskes : Trigger.old)
        {
            for (Task tas : Tasktoupdate1)
            {
                if(taskes.Description != tas.Description && taskes.id == tas.id){
                    string getTechTerm1=tas.Description;
                    string containingDatas ='';
                    boolean flages = false ;
                    for(Technology_Terms__mdt  checkTermName : arrayname ){
                        
                        if(getTechTerm1.containsIgnoreCase(checkTermName.Label)){
                            if(flages){
                                containingDatas += ','; 
                            }
                            containingDatas += checkTermName.Label;
                            flages = true;
                        }            
                    }
                    Task taskToUpdates = new Task();  
                    taskToUpdates.Technology_Terms_report__c = containingDatas;
                    taskToUpdates.Id=tas.Id;
                    Updateinstance.add(taskToUpdates);         
                } 
                
            }
            
        }
        update Updateinstance;
    }
    
}