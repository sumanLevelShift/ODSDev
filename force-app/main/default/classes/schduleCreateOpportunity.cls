/**
 * @author           Harish Sankaran
 * @version          1.0 
 * @date             13/04/2021
 * @Status           Inprogress
 * @description      Scheduler class for CreateOpportunityForAccountService.
 *
 */
global class schduleCreateOpportunity implements Schedulable {

   global void execute(SchedulableContext ctx) {
      CreateOpportunityForAccountService CreateRenewalOpp = new CreateOpportunityForAccountService();
        database.executeBatch(CreateRenewalOpp);
   }   
}