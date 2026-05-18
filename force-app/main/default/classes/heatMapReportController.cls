public class heatMapReportController {
    public string AccountId {get;set;}
    public static datetime reportDate {get;set;}
    public static string orgId {get;set;}
    public static string userName {get;set;}
    public static string environment {get;set;}
    public static list<Product_Client_Usage__c> productClientUsageList {get;set;}
    public static list<productClientWrap> productClientWrapList {get;set;}
    public static String dynamicUrl {get;set;}
    public static String overviewContent {get;set;}
    public static String accountName {get;set;}
    
    
    public heatMapReportController(){
        
        AccountId = apexpages.currentpage().getparameters().get('accountId');
        List<Account_Services__c> accountService=[SELECT Account__r.Name,id,Account__c,ODS_Service_Name__c FROM Account_Services__c Where ODS_Service_Name__c='Salesforce' AND Account__c=:AccountId Limit 1];
        if(!accountService.isEmpty()){
            accountName=accountService[0].Account__r.Name;
            list<Attachment> AttachmentRecord=[Select Id From Attachment Where Name=:'productCloud.png' AND ParentId=:accountService[0].id limit 1];
            system.debug('AttachmentRecord---'+AttachmentRecord);
            if(!AttachmentRecord.isEmpty()){
                dynamicUrl='/servlet/servlet.FileDownload?file='+AttachmentRecord[0].id;
            } 
        }
        system.debug('dynamicUrl---'+dynamicUrl);
        
        if(AccountId !=null){
            list<Account> accountList=[Select id,Name From Account where Id=:AccountId Limit 1];
            if(!accountList.isEmpty()){
                String fileName = 'Heat Map Recommendations Report For '+accountList[0].Name+'.pdf';
                Apexpages.currentPage().getHeaders().put('content-disposition', 'inline; filename='+fileName);   
            }
            getHeatMapCustomMetadataDetails(AccountId);
            getProductClientUsage(AccountId);
        }
        
        
    }
    public static void getHeatMapCustomMetadataDetails(String accountId){
        list <ClientAndNamedCredMapping__mdt> ClientAndNamedCredMappingRecord=[SELECT Account_Id__c,Connect_to_sandbox__c,Customer_Org_Url__c,Id,Is_Active__c,Last_Run_Date_Time__c,Named_Credentail__c,Next_Run_Date_Time__c,Username__c FROM ClientAndNamedCredMapping__mdt where Account_Id__c=:accountId limit 1];
        if(!ClientAndNamedCredMappingRecord.isEmpty()){
            userName=ClientAndNamedCredMappingRecord[0].Username__c;
            datetime lastRunDateTime=ClientAndNamedCredMappingRecord[0].Last_Run_Date_Time__c;
            environment= (ClientAndNamedCredMappingRecord[0].Connect_to_sandbox__c) ? 'SDX' : 'PROD';
            reportDate = (lastRunDateTime !=null) ? lastRunDateTime.date() : null;
        }
        list<account> accountRecord=[SELECT Organization_ID__c FROM Account where Id=:accountId limit 1];
        if(!accountRecord.isEmpty()){
            orgId=accountRecord[0].Organization_ID__c;
        }
    }
    public static void getProductClientUsage(string accountId){
        Set<Id> filterProductId=New Set<Id>();
        filterProductId.addAll(SalesforceProductFilterHelper.productFilter(accountId));
        
        productClientWrapList=new list<productClientWrap>();
        productClientUsageList=new list<Product_Client_Usage__c>();
        productClientUsageList=[SELECT Salesforce_Product__r.Chart_Color__c,Salesforce_Product_Usage__c,Product_Name__c,Account__c,Account__r.Name,Salesforce_Product__r.Name,Salesforce_Product__r.Description__c,(SELECT Id,Salesforce_Product_Feature__r.Name,Client_Usage_Percentage__c,Salesforce_Product_Feature__r.Description__c FROM Product_Feature_Client_Usages__r Where Salesforce_Product_Feature__r.Active__c=true ORDER BY Client_Usage_Percentage__c ASC NULLS FIRST) FROM Product_Client_Usage__c where Account__c=:accountId AND Salesforce_Product__c IN:filterProductId ORDER BY Salesforce_Product_Usage__c DESC NULLS FIRST];
        
        list<Product_Subfeature_Client_Usage__c> proSubFeatureList=[SELECT Recommendation__c,Account__c,Client_Usage_Percentage__c,Product_Feature_Client_Usage__c,SF_ProductSubFeatureName__c,Salesforce_Product_Subfeature__r.Description__c  FROM Product_Subfeature_Client_Usage__c where Account__c=:accountId AND Salesforce_Product_Subfeature__r.Active__c=true ORDER BY Client_Usage_Percentage__c  ASC NULLS FIRST];
        Map<string,list<Product_Subfeature_Client_Usage__c>> proSubFeatureMapList=new Map<string,list<Product_Subfeature_Client_Usage__c>>();
        
        for(Product_Subfeature_Client_Usage__c psc:proSubFeatureList){
            list<Product_Subfeature_Client_Usage__c> updatePSubFeature=new list<Product_Subfeature_Client_Usage__c>();
            updatePSubFeature.add(psc);
            if(proSubFeatureMapList.containsKey(psc.Product_Feature_Client_Usage__c)){
                updatePSubFeature.addAll(proSubFeatureMapList.get(psc.Product_Feature_Client_Usage__c));
            }
            proSubFeatureMapList.put(psc.Product_Feature_Client_Usage__c,updatePSubFeature);
        }
        overviewContent='';
        for(Product_Client_Usage__c pcu:productClientUsageList){
            system.debug('pcu.Salesforce_Product__r.Name--'+pcu.Salesforce_Product__r.Name);
            overviewContent +='<b>'+pcu.Salesforce_Product_Usage__c +'% </b> of '+pcu.Salesforce_Product__r.Name+', ';
            list<FeatureClientWrap> featureClientList=new list<FeatureClientWrap>();
            for(Product_Feature_Client_Usage__c pfc:pcu.Product_Feature_Client_Usages__r){
                String fDescription = pfc.Salesforce_Product_Feature__r.Description__c;
                fDescription = fDescription.replaceAll('\\<.*?\\>','');
                fDescription = fDescription.replaceAll('<br>','');
                fDescription = fDescription.replaceAll('<br/>',''); 
                fDescription = fDescription.replaceAll('&amp;','&'); 
                fDescription = fDescription.replaceAll('&#39;','\''); 
                
                list<SubFeatureClientWrap> subFeatureClientList=new list<SubFeatureClientWrap>();
                if(proSubFeatureMapList.containsKey(pfc.id)){
                    for(Product_Subfeature_Client_Usage__c psfc:proSubFeatureMapList.get(pfc.id)){
                        String spDescription=psfc.Recommendation__c;
                        if(psfc.Recommendation__c !=null && spDescription != 'null'){
                            spDescription= psfc.Recommendation__c;
                            spDescription=spDescription.replaceAll('null', '');
                        }else{
                            spDescription = psfc.Salesforce_Product_Subfeature__r.Description__c;
                            spDescription = spDescription.replaceAll('\\<.*?\\>','');
                            spDescription = spDescription.replaceAll('<br>','');
                            spDescription = spDescription.replaceAll('<br/>','');
                            spDescription = spDescription.replaceAll('&amp;','&'); 
                            spDescription = spDescription.replaceAll('&#39;','\''); 
                        }
                        subFeatureClientList.add(new SubFeatureClientWrap(psfc.SF_ProductSubFeatureName__c,spDescription,psfc.Client_Usage_Percentage__c));
                    }
                }
                string classNamePar;
                string classNamespan;
                if(pfc.Client_Usage_Percentage__c == 0){
                    classNamePar='red-bg count'; 
                    classNamespan='red-darkbg count-icon';
                }else if(pfc.Client_Usage_Percentage__c>=1 && pfc.Client_Usage_Percentage__c<35){
                    classNamePar='orange-bg count';
                    classNamespan='orange-darkbg count-icon';
                }else if(pfc.Client_Usage_Percentage__c>=35 && pfc.Client_Usage_Percentage__c<70){
                    classNamePar='yellow-bg count'; 
                    classNamespan='yellow-darkbg count-icon';
                }else if(pfc.Client_Usage_Percentage__c>=70 && pfc.Client_Usage_Percentage__c<95){
                    classNamePar='light-green-bg count';
                    classNamespan='light-green-darkbg count-icon';
                }else if(pfc.Client_Usage_Percentage__c>=95 && pfc.Client_Usage_Percentage__c<=100){
                    classNamePar='green-bg count'; 
                    classNamespan='green-darkbg count-icon';
                }
                featureClientList.add(new FeatureClientWrap(pfc.Salesforce_Product_Feature__r.Name,fDescription,pfc.Client_Usage_Percentage__c,classNamePar,classNamespan,subFeatureClientList));   
            }
            String pDescription = pcu.Salesforce_Product__r.Description__c;
            pDescription = pDescription.replaceAll('\\<.*?\\>','');
            pDescription = pDescription.replaceAll('<br>','');
            pDescription = pDescription.replaceAll('<br/>',''); 
            pDescription = pDescription.replaceAll('&amp;','&'); 
            pDescription = pDescription.replaceAll('&#39;','\''); 
            productClientWrapList.add(new productClientWrap(pcu.Salesforce_Product__r.Name,pDescription,pcu.Salesforce_Product_Usage__c,featureClientList));
        }
        overviewContent = overviewContent.removeEnd(', '); 
        String lastWord = overviewContent.substring(overviewContent.lastIndexOf(',')+1);
        //system.debug('lastWord-'+lastWord);
        overviewContent=overviewContent.replace(','+lastWord, ' and'+lastWord);
        overviewContent+=' are utilized by customer.';
        system.debug('overviewContent--'+overviewContent);
        
    }
    
    public class productClientWrap
    {
        public string ProductName {get;set;}
        public string ProductDescription {get;set;}
        public decimal productClientUsage {get;set;}
        public list<FeatureClientWrap> FeatureClientWrapList {get;set;}
        public productClientWrap(string pName,string d, decimal pUsage,list<FeatureClientWrap> fWrap){
            this.ProductName=pName;
            this.ProductDescription=d;
            this.productClientUsage=pUsage;
            this.FeatureClientWrapList=fWrap;
        }
    }
    public class FeatureClientWrap
    {
        public string FeatureName {get;set;}
        public string FeatureDescription {get;set;}
        public decimal FeatureClientUsage {get;set;}
        public string classNamePar {get;set;}
        public string classNamespan {get;set;}
        public list<SubFeatureClientWrap> ProductSubfeatureClient {get;set;}
        public FeatureClientWrap(string fName,string d, decimal fUsage,string p,string s,list<SubFeatureClientWrap> subFeatureUsage){
            this.FeatureName=fName;
            this.FeatureDescription=d;
            this.FeatureClientUsage=fUsage;
            this.classNamePar=p;
            this.classNamespan=s;
            this.ProductSubfeatureClient=subFeatureUsage;
        }
    }
    public class SubFeatureClientWrap
    {
        public string SubFeatureName {get;set;}
        public string SubFeatureDescription {get;set;}
        public decimal SubFeatureClientUsage {get;set;}
        public SubFeatureClientWrap(string fName,string d, decimal fUsage){
            this.SubFeatureName=fName;
            this.SubFeatureDescription=d;
            this.SubFeatureClientUsage=fUsage;
        }
    }
}