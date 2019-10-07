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

	static TestMethod void getRecent_givenDefault_shouldGetRecentRecords() {
		List<Account> recentAccounts;
		LookupAuraService.Searchable searcher = new LookupAuraService.Searchable();
		searcher.searchTerm = 'test';
		searcher.objectName = 'Account';
		searcher.fields = new List<String> { 'Name', 'Id' };

		Test.startTest();

			recentAccounts = (List<Account>) JSON.deserialize(LookupAuraService.getRecent(searcher), List<Account>.class);

		Test.stopTest();

		System.assertEquals(5, recentAccounts.size());
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

	static TestMethod void getSelectedRecord_givenId_shouldGetOneRecord() {
		Account acc = [ SELECT Id FROM Account WHERE Name = 'Test 1' LIMIT 1];
		LookupAuraService.Searchable searcher = new LookupAuraService.Searchable();
		searcher.searchTerm = 'test';
		searcher.objectName = 'Account';
		searcher.fields = new List<String> { 'Name', 'Id' };

		Test.startTest();

			List<Account> accounts = (List<Account>) JSON.deserialize(LookupAuraService.getSelectedRecord(acc.Id, searcher), List<Account>.class);

		Test.stopTest();

		System.assertEquals(1, accounts.size());
	}
}
