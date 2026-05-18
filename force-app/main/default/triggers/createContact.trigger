trigger createContact on Account (after insert) {
    AccountHandler.createNewContact(Trigger.new);
}