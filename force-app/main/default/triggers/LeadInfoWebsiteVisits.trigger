trigger LeadInfoWebsiteVisits on LeadinfoWebsiteVisits__c (before insert,before update) {
    List<Website_Page__c> pagesList = [SELECT Name,Page_URL__c,Points__c,Page_Category__c from Website_Page__c ];
    String servicePageCategoryId = [SELECT Id from Web_Page_Category__c WHERE Name = 'Service Pages'].Id;
    for(LeadinfoWebsiteVisits__c lWV: Trigger.new){
        String richTextContent = lWV.Pages__c;
        if(lWV.Points__c == null){
            lWV.Points__c = 0;
        }
        //String lastChar =  lWV.Duration__c.right(1);
        
        //String richTextContentTime = richTextContent.substringBetween('</a></td><td colspan="1" rowspan="1">','s</td>');
        //richTextContent = richTextContent.substringBetween('<a target="_blank" href="','">');
        
        String s2 = richTextContent.stripHtmlTags();
        System.debug('Rich Text' + s2 );
		String [] str3 = s2.Split(' ');
        Integer servicePageDurationMin = 0;
        Integer servicePageDurationSec = 0;
        Boolean pageNotFound = false;
        for(Integer i =0;i<str3.size();i=i+3){
            for(Website_Page__c page :pagesList){
                if(str3[i+1] == page.Page_URL__c ){
                    lWV.Points__c += page.Points__c;
                    pageNotFound = true;
                    if(page.Page_Category__c== servicePageCategoryId){
                        if(lWV.Duration__c.endsWith('m')){
                            servicePageDurationMin += Integer.valueOf(lWV.Duration__c.removeEnd('m'));
                        }else if(lWV.Duration__c.endsWith('s')){
                            servicePageDurationSec += Integer.valueOf(lWV.Duration__c.removeEnd('s'));
                        }
                    }
                }
            }
            if(pageNotFound == false){
                    lWV.Points__c += 1;
            }
            
		System.debug('Duration' + str3[i+2] );
		}
        
        if(servicePageDurationMin > 1 || servicePageDurationSec > 60){
			lWV.Points__c += 5;
        }       
    }

}