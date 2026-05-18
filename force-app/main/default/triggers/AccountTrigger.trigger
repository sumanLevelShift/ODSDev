trigger AccountTrigger on Account (before insert, after insert) {
    if(trigger.isBefore){
        if(trigger.isInsert){
            AccountHandler.appendSysdate(trigger.new);
        }
    }
    if(trigger.isafter){
        if(trigger.isInsert){
            AccountHandler.createContact(trigger.new);
        }
    }
}