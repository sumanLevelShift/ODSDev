public class UploadMissingMonthlyTimesheetPDFtoTips {
    public static void uploadTimesheetPDF(string timesheetFrequency,string weeklyTimesheetId,Set<id> monthlyTimesheetIdSet,
                                          date startDate,date endDate,string tipsId,string initiativeType,boolean isABCCustomer,string accountName){
                                              try{
                                                  PageReference pdfPage=new PageReference ('/apex/TipsTimesheetPDF?timesheetFrequency='+timesheetFrequency+'&weeklyTimesheetId='+weeklyTimesheetId);
                                                  pdfPage.getParameters().put('monthlyTimesheetIdSet', String.join(monthlyTimesheetIdSet, ','));
                                                  pdfPage.getParameters().put('startDate', string.valueOf(startDate));
                                                  pdfPage.getParameters().put('endDate', string.valueOf(endDate));
                                                  pdfPage.getParameters().put('tipsId', tipsId);
                                                  pdfPage.getParameters().put('initiativeType', initiativeType);
                                                  
                                                  if(isABCCustomer){
                                                      pdfPage.getParameters().put('CustomeType', 'ABC Type');
                                                  }else{
                                                      pdfPage.getParameters().put('CustomeType', 'Regular');
                                                  }
                                                  Datetime stTimesheetDate = DateTime.newinstance(startDate.year(),startDate.month(),startDate.day());
                                                  Datetime enTimesheetDate = DateTime.newinstance(endDate.year(),endDate.month(),endDate.day());
                                                  //string fileName=accountName+' - Timesheet - ' + stTimesheetDate.format('MM-dd-yyyy')+' to '+enTimesheetDate.format('MM-dd-yyyy')+' TIPS ID -'+tipsId+'.pdf';
                                                  string fileName=tipsId+' - '+accountName+' - '+stTimesheetDate.format('MM-dd-yyyy')+' to '+enTimesheetDate.format('MM-dd-yyyy')+'.pdf';
                                                  String base64Pdf;
                                                  Blob pdfBlob;
                                                  if(!Test.isRunningTest()) { 
                                                      pdfBlob = pdfPage.getContent();
                                                      base64Pdf = EncodingUtil.base64Encode(pdfBlob);
                                                  }
                                                  
                                                  TipsAPIHelperClass apiHelper = new TipsAPIHelperClass();
                                                  string body='{"data":"'+apiHelper.AESEncryptDecrypt('{"WorkOrderId":"'+tipsId+'","StartDate":"'+stTimesheetDate.format('MM/dd/yyyy')+'","EndDate":"'+enTimesheetDate.format('MM/dd/yyyy')+'","FileName":"'+fileName+'","Pdffile":"'+base64Pdf+'"}')+'"}';
                                                  system.debug('PDF Body'+body);
                                                  TipsTimesheetPDFController.uploadTimesheetToTips(body);
                                                  if(String.isNotBlank(weeklyTimesheetId)){
                                                      monthlyTimesheetIdSet.add(weeklyTimesheetId);
                                                  }
                                                  List<ContentDocumentLink> existingVersions = [SELECT ContentDocumentId,Id,LinkedEntityId FROM ContentDocumentLink WHERE 
                                                                                                ContentDocument.Title = :fileName AND LinkedEntityId IN:monthlyTimesheetIdSet];
                                                  If(!existingVersions.isEmpty()){
                                                      delete existingVersions;
                                                  }
                                                  system.debug('monthlyTimesheetIdSet-'+monthlyTimesheetIdSet);
                                                  ContentVersion newVersion = new ContentVersion();
                                                  newVersion.Title = fileName;
                                                  newVersion.PathOnClient = fileName;
                                                  newVersion.VersionData = pdfBlob;
                                                  newVersion.ContentLocation = 'S'; 
                                                  insert newVersion;
                                                  List<ContentDocumentLink> CDLList=new List<ContentDocumentLink>();
                                                  for(ID timesheetId:monthlyTimesheetIdSet){
                                                      ContentDocumentLink cdl = new ContentDocumentLink();
                                                      cdl.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: newVersion.Id].ContentDocumentId;
                                                      cdl.LinkedEntityId = timesheetId;
                                                      cdl.ShareType = 'I'; 
                                                      cdl.Visibility = 'AllUsers'; 
                                                      CDLList.add(cdl);
                                                  }
                                                  if(!CDLList.isEmpty()){
                                                      insert CDLList;
                                                  }
                                              } catch (Exception e) {
                                                  ODS_ExceptionUtility.LogException(e);
                                              }
                                          }
}