@isTest
private class PopulateCampaignSourceOnOppBatchTest {
    @TestSetup
    static void makeData(){
        List<Apex_static_components__c> constantsList = TestDataFactory.createConstant(true);
        Id recordTypeId = Utils.getRecordTypeId( Utils.ACCOUNT_OBJECT_TYPE, Utils.BROKERAGE_ACCOUNT_RECORD_TYPE_NAME );
        Account acc = new Account(OwnerId = UserInfo.getUserId(), 
                                  Name = 'Neighbourhood Holdings',
                                  RecordTypeId = recordTypeId); 
        insert acc;
        Contact con1 = new Contact(LastName = 'Test Contact1', AccountId = acc.id, Email = 'test_1@gmail.com' );
        insert con1;
        List<Campaign> campaignList = new List<Campaign>();
        for( Integer i = 0; i< 5; i++ ){
            Campaign c = new Campaign();
            c.Name = 'Test ' + i;
            c.IsActive = true;
            campaignList.add( c );
        }
        insert campaignList;

        campaignList = [select id,createddate from campaign];
        Test.setCreatedDate(campaignList[0].Id, Datetime.now().addDays(-21));
        Test.setCreatedDate(campaignList[1].Id, Datetime.now().addDays(-20));
        Test.setCreatedDate(campaignList[2].Id, Datetime.now().addDays(-22));
        Test.setCreatedDate(campaignList[3].Id, Datetime.now().addDays(-23));
        Test.setCreatedDate(campaignList[4].Id, Datetime.now().addDays(-24));
		List<CampaignMember> cmList = new List<CampaignMember>();
        for( campaign c : campaignList ){
            CampaignMember cm = new CampaignMember( CampaignId = c.Id, ContactId = con1.Id );
            cmList.add(cm);
        }
        insert cmList;

        Opportunity opp = new Opportunity();
        opp.Name = 'test Opp';
        opp.FinServ__ReferredByContact__c = con1.Id;
        opp.StageName = 'Qualification';
        opp.CloseDate = Date.today();
        insert opp;
    }

    @isTest static void batchTest(){
        list<campaign> campaignList = [select id,createddate from campaign];
        for( campaign c: campaignList ){
            system.debug('createddate: '+c.id+' '+c.createddate);
        }
        Set<Id> oppIds = new Set<Id>();
        Opportunity opp = [select id,FinServ__ReferredByContact__c,campaignId,createddate from Opportunity];
        system.debug(opp.id);
        oppIds.add(opp.id);
        List<Opportunity> opps = new List<Opportunity>();
        opps.add(opp);
        
        PopulateCampaignSourceOnOpportunityBatch batch = new PopulateCampaignSourceOnOpportunityBatch(oppIds);
        List<Opportunity> ql = batch.start(null);
		batch.execute(null,opps);
		batch.Finish(null);
    }
}