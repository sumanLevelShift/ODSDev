trigger opportunityTestTrigger on Opportunity (before insert) 
{
    if(trigger.isBefore && trigger.isInsert){
        
        OpportunityHandler.appendAccountAndOwnerName(Trigger.new);
    }

}