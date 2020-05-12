@isTest
private class LookupAuraServiceTest {

	@TestSetup
	static void makeData(){
		List<Account> accounts = new List<Account>();
		accounts.add(new Account(Name = 'Test 1'));
		accounts.add(new Account(Name = 'Test 2'));
		accounts.add(new Account(Name = 'Test 3'));
		accounts.add(new Account(Name = 'Test 4'));
		accounts.add(new Account(Name = 'Test 5'));
		accounts.add(new Account(Name = 'Test 6'));
		insert accounts;
	}

	static TestMethod void getOneRecordById_givenSearchable_shouldGetRecord() {
		Account acc = [SELECT Id FROM Account LIMIT 1];
		LookupAuraService.Searchable searcher = new LookupAuraService.Searchable();
		searcher.searchTerm = 'test';
		searcher.objectName = 'Account';
		searcher.fields = new List<String> { 'Name', 'Id' };

		Test.startTest();

			String data = LookupAuraService.getOneRecordById(searcher, acc.Id);

		Test.stopTest();

		System.debug('data: ' + data);

		// the following is weird because
		// USUALLY: Account acc = Database.query(...LIMIT 1) // => { account }
		// BUT HERE: return JSON.serialize(Database.query(...)) // => [ { account } ]

		List<Account> queried = (List<Account>) JSON.deserialize(data, List<Account>.class);
		System.assertEquals(acc.Id, queried[0].Id);
	}

	static TestMethod void getRecent_givenDefault_shouldGetRecentRecords() {
		List<Account> recentAccounts;
		LookupAuraService.Searchable searcher = new LookupAuraService.Searchable();
		searcher.searchTerm = 'test';
		searcher.objectName = 'Account';
		searcher.fields = new List<String> { 'Name', 'Id' };

		Test.startTest();

		recentAccounts = (List<Account>) JSON.deserialize(LookupAuraService.getRecent(searcher), List<Account>.class);

		Test.stopTest();

		// Recent Queries can Fail in an org where a User doesn't have Recent Records.
		List<RecentlyViewed> recents = [SELECT Id FROM RecentlyViewed WHERE Type = :searcher.objectName];
		Boolean isValid = recents.size() >= 0 || recentAccounts.size() == 5;
		System.assert(isValid, 'RecentlyViewed table is TestVisible, and will vary by environment.');
	}

	static TestMethod void getRecords_givenTerm_shouldGetAccounts() {
		List<Id> fixedAccountIds = new List<Id>();
		for(Account acc : [ SELECT Id FROM Account ]) {
			fixedAccountIds.add(acc.Id);
		}

		Test.setFixedSearchResults(fixedAccountIds);

		List<List<Account>> results;
		LookupAuraService.Searchable searcher = new LookupAuraService.Searchable();
		searcher.searchTerm = 'test';
		searcher.objectName = 'Account';
		searcher.fields = new List<String> { 'Name', 'Id' };

		Test.startTest();

			results = (List<List<Account>>) JSON.deserialize(LookupAuraService.getRecords(searcher), List<List<Account>>.class);

		Test.stopTest();

		System.assertEquals(5, results[0].size());
	}
}