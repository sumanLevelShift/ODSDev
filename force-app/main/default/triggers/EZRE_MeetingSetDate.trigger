/**
*@author        Shahida K
*@version       1.0
*@createdDate   15/03/2016
*@status        developed
*@description   Trigger to update meeting set date with date that contact status modified to 'meeting set'
*/

trigger EZRE_MeetingSetDate on Contact (after insert,after update,before delete) 
{
      
    //Trigger to update meeting set date with lastmodified date when status is 'meeting set'
    if(trigger.isAfter)
    {
        if(trigger.isInsert)
        {
            set<Id> contactIdSet=new set<Id>();
            List<Contact> ContactMeetingtoUpdate = new List<Contact>();
            Set<String> ContactNameSet = new Set<String>();
            Set<Id> AccountIdSet = new Set<Id>();
            list<contact>  dupecontactList = new List<Contact>();
            Map<Id,Contact> ContactMap = new Map<Id,Contact>();
            Map<Id,List<Id>> DupeContactIdMap = new Map<Id,List<Id>>();
            
            for(contact conct:trigger.new)
            {    
                contactIdSet.add(conct.id);
                //System.debug('@@@ Account = '+conct.AccountId);
                /* If(!ContactMap.containsKey(conct.Id))
                {
                ContactMap.put(conct.Id, conct); 
                } */
            }
            
// Contact List to  Merge the Duplicates
            list<contact> contactLst=[select id,FirstName,LastName,AccountId from Contact where Id IN: contactIdSet AND Fire_Duplicate_Rule__c = False];
            If(contactLst.size() > 0)
            {
                for(Contact cont : contactLst)
                {
                    String ContactName = '';
                    If(!String.isEmpty(Cont.FirstName))
                    {
                        ContactName = Cont.FirstName + ' '+ Cont.LastName;                       
                    }
                    else
                    {
                        ContactName = Cont.LastName;
                    }    
                    ContactNameSet.add(ContactName);
                    AccountIdSet.add(cont.AccountId);
                    If(!ContactMap.containsKey(cont.Id))
                    {
                        ContactMap.put(cont.Id, cont); 
                    } 
                }
            }
            
            system.debug('############contacts inserted'+contactIdSet);
            system.debug('############contacts inserted Size'+contactIdSet.size());
            list<contact>  contactList=[select id,name,status__c,lastmodifiedDate from contact where status__c='3: Meeting Set' and id IN:contactIdSet];
            system.debug('##############Meeting set contacts'+contactList);
            
            if(contactList.size()>0)
            {
                for(contact cont:contactList)
                {
                    contact contactObj=new contact();
                    contactObj.id=cont.id;
                    contactObj.Meeting_Set_Date__c=cont.LastmodifiedDate;
                    ContactMeetingtoUpdate.add(contactObj);  
                }
            }
            if(ContactMeetingtoUpdate.size() > 0)
            {
                Update ContactMeetingtoUpdate;
            }

// Fetch the Duplicate Contacts against the new Contact Insertered           
            System.debug('@@@ContactNameSet'+ContactNameSet);
            System.debug('@@@AccountIdSet'+AccountIdSet);
            If(ContactNameSet.size() > 0 && AccountIdSet.size() > 0)
            {
                dupecontactList=[select id,FirstName,LastName,AccountId from contact where Name IN: ContactNameSet and  AccountId IN: AccountIdSet]; 
            }
            System.debug('@@@dupecontactList'+dupecontactList.size());
            If(dupecontactList.size() > 0)
            {
                for(Contact con : ContactMap.Values())
                {
                    for(Contact cont : dupecontactList)
                    {
                        If(cont.FirstName == con.FirstName && cont.LastName == con.LastName && cont.AccountId == con.AccountId && cont.Id != con.Id )
                        {
                            if(DupeContactIdMap.containsKey(con.Id))
                            {
                                DupeContactIdMap.get(con.Id).add(cont.Id);
                            }
                            else
                            {
                                DupeContactIdMap.put(con.Id, new List<Id> {cont.Id});
                            }
                        }
                    }
                }
            }
            System.debug('@@@DupeContactIdMapkeyset' + DupeContactIdMap.keySet().size());
            If(DupeContactIdMap.keySet().size() > 0)
            {   
                System.debug('@@@MergeStart');
                For(Contact c:ContactMap.values())
                {
                    If(DupeContactIdMap.ContainsKey(c.Id))
                    {
                    System.debug('@@@MergeResult');
                    System.debug('@@@DupeContactIdMap'+DupeContactIdMap.get(c.Id));   
                    Contact cnt = new Contact();
                    cnt = ContactMap.get(c.Id);   
                    List<Id> DuplicateIds = new List<Id>();
                    DuplicateIds = DupeContactIdMap.get(c.Id);   
//Merge the Duplicate Contacts with the Parent Contact                    
                    Database.MergeResult[] results = Database.merge(cnt,DuplicateIds, false);
                    for(Database.MergeResult res : results) {
                        if (res.isSuccess()) {
                            // Get the master ID from the result and validate it
                            System.debug('Master record ID: ' + res.getId());           
                            
                            // Get the IDs of the merged records and display them
                            List<Id> mergedIds = res.getMergedRecordIds();
                            System.debug('IDs of merged records: ' + mergedIds);                
                            
                            // Get the ID of the reparented record and 
                            // validate that this the contact ID.
                            System.debug('Reparented record ID: ' + res.getUpdatedRelatedIds());    
                        }
                        else {
                            for(Database.Error err : res.getErrors()) {
                                // Write each error to the debug output
                                System.debug(err.getMessage());
                            }
                        }
                    }
                    }    
                }
                    
            }
        }
        
        //trigger to update meeting set date with lastmodified date when status update to 'meeting set'
        if(trigger.isUpdate)
        {
            Map<Id,Contact> newContactMap=trigger.newMap;
            System.debug('############newContactMap'+newContactMap);
            Map<Id,Contact> oldContactMap=trigger.oldMap;
            System.debug('############oldContactMap'+oldContactMap);
            for(Id ContactId :newContactMap.keyset())
            {
                Contact newContact=newContactMap.get(ContactId);
                Contact oldContact=oldContactMap.get(ContactId);
                
                if(newContact.status__c<>oldContact.status__c)
                {
                    system.debug('##############newContactstatus'+newContact.status__c);
                    system.debug('##############newContactstatus'+oldContact.status__c);             
                    if(newContact.status__c=='3: Meeting Set')
                    {
                        Contact contactObj=new Contact();
                        contactObj.Id=newContact.Id;
                        contactObj.Meeting_Set_Date__c=newContact.LastmodifiedDate;
                        //update contact meeting set date with lastmodified date when status is 'Meeting set'
                        update contactObj;                  
                    }
                    
                }
                
                
            }
            
            
        }
        
    }
    //Prevent to Delete Contact      
    if(trigger.isBefore && trigger.isDelete)
    {
        Set<id> lconIdsSet = new set<id>();
        for(Contact con : trigger.old)
        {    
            lconIdsSet.add(con.id); 
        }  
        
        List<Contact_Account_Service__c> lContactAccountSerList = [SELECT id, Account__c, contact__c, 
                                                                   Is_Approver__c, Is_initiate_approver__c, Status_Report_Required__c 
                                                                   FROM Contact_Account_Service__c WHERE contact__c 
                                                                   IN : lconIdsSet];
        
        if(lContactAccountSerList.size() > 0)
        {
            for(Contact_Account_Service__c conAccSr : lContactAccountSerList )
            {    
                if(conAccSr.Is_initiate_approver__c || conAccSr.Is_Approver__c || conAccSr.Status_Report_Required__c )
                {   
                    Contact conRecord = Trigger.oldMap.get(conAccSr.contact__c);                    
                    conRecord.addError(conRecord.FirstName + ' ' + conRecord.LastName + ' is an active recipient in the Contact Account Service of the Account - ' 
                                        + conRecord.AccountID_formula__c + ' and therefore cannot be deleted.');                                       
                }
            }  
        }
    }
      
}