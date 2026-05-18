trigger UpdateProjectCodeAccountTrigger on Account (before update) {
    if(trigger.isBefore && trigger.isUpdate)
    {
        try
        {
            Set<string> CheckDuplicateProjectCode=new Set<string>();
            
            List<Account> lstCheckDuplicateProjectCode = [SELECT Id,Project_Code__c FROM Account WHERE Project_Code__c !=null];
            system.debug('lstCheckDuplicateProjectCode==>'+lstCheckDuplicateProjectCode);
            if(lstCheckDuplicateProjectCode.size()>0)
            {
                for(Account accObj:lstCheckDuplicateProjectCode){
                    CheckDuplicateProjectCode.add(accObj.Project_Code__c);}
            }
            
            for(Account newAcc: trigger.new)
            {
                if(newAcc.Force_com_Account_Status__c == '7: Customer' || newAcc.Account_Status__c == 'Active Customer' || 
                   newAcc.Account_Status__c == 'Customer'){
                    String projectCode = '';
                    if(string.isBlank(newAcc.Project_Code__c)){
                        projectCode = ODS_Common_Utility.generateProjectCodeforAccount(newAcc.Name);
                        if(string.isBlank(projectCode) || projectCode.length() != 3){
                            newAcc.addError('Unable to generate the project code.');
                        }else{
                            newAcc.Project_Code__c = projectCode;
                        }
                    }else{
                        Account oldAccount = Trigger.oldMap.get(newAcc.Id);
                        projectCode=newAcc.Project_Code__c;
                        if(oldAccount.Project_Code__c != projectCode && string.isNotBlank(oldAccount.Project_Code__c)){
                            if(CheckDuplicateProjectCode.contains(projectCode)){
                                newAcc.addError('Project code : ' +projectCode+ ' already exist'); 
                            }
                            if(projectCode.length() != 3 || projectCode.replaceAll('[0-9]', '') == ''){
                                newAcc.addError('The project code must be 3 characters long and cannot consist of all numbers.');  
                            }
                        }
                       
                    } 
                }
            }
        }
        catch(Exception ex)
        {
            system.debug('Error--->'+ex.getMessage());
        }
        
    }
}