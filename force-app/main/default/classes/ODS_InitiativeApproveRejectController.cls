public class ODS_InitiativeApproveRejectController{
    
    public string initiativeId {get; set;}
    public string approvalType {get; set;}
    
    public ODS_InitiativeApproveRejectController(){        
        initiativeId = ApexPages.currentPage().getParameters().get('Id');
        approvalType = ApexPages.currentPage().getParameters().get('Type');
    }
    
    public PageReference ApproveRejectInitiative(){
        system.debug('##initiativeId:' +initiativeId);
        system.debug('##approvalType:' +approvalType);         
        PageReference pgRef ; 
        if(initiativeId != null && approvalType != null){
            Initiatives__c init = [select Status__c, Account_Service__c, Client_side_Contact__r.Name from Initiatives__c where id =: initiativeId];
            string URL = System.Label.ODS_SiteURL+'/apex/InitiativePage?CurrenInitiativeId='+initiativeId+'&AccServiceId='+init.Account_Service__c;            
            system.debug('##init:' +init);
            if(init.Status__c == 'Initiative Approved' || init.Status__c == 'Re-evaluate'){
                pgRef = new PageReference('/apex/ODS_URLExpired');
            }else{                 
                if(approvalType == 'Approve'){                
                    Initiatives__c initiative = new Initiatives__c(id=initiativeId);
                    initiative.Status__c  = 'Initiative Approved';
                    initiative.Approver_Name__c = UserInfo.GetUserID();
                    initiative.Initiative_Approved_Date__c = Date.Today();              
                    Update initiative;                
                    ODS_InitiativeController.sendEmailInitiative(initiativeId,init.Account_Service__c,'Initiative Approved',init.Client_side_Contact__r.Name,URL);                    
                    pgRef = new PageReference('/apex/Dashboard'); 
                }
                else if(approvalType == 'Reject'){
                    pgRef = new PageReference('/apex/InitiativePage?CurrenInitiativeId='+initiativeId + '&Type=Reject'); 
                }
            }                       
        }
        
        pgRef.setRedirect(True);
        return pgRef;        
    }
}