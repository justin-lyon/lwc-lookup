public with sharing class LookupAuraService {

	@AuraEnabled(cacheable=true)
	public static String getRecent(Searchable searcher) {
		Set<Id> recentIds = new Set<Id>();
		for(RecentlyViewed rv : queryRecentByType(searcher.objectName)) {
			recentIds.add(rv.Id);
		}

		List<String> expr = new List<String>();
		expr.add('SELECT ' + String.join(searcher.fields, ', '));
		expr.add('FROM ' + searcher.objectName);
		expr.add('WHERE Id IN (\'' + String.join(new List<Id>(recentIds), '\', \'') + '\')');

		return JSON.serialize(Database.query(String.join(expr, ' ')));
	}

	@AuraEnabled(cacheable=true)
	public static String getRecords(Searchable searcher) {
		String find = 'FIND \'' + String.escapeSingleQuotes(searcher.searchTerm) + '*\' IN ALL FIELDS';
		String returning = 'RETURNING ' + getReturning(searcher.objectName, searcher.fields);
		String limitter = 'LIMIT ' + 5;
		String query = find + ' ' + returning + ' ' + limitter;
		return JSON.serialize(search.query(query));
	}

	private static String getReturning(String objectName, List<String> fields) {
		List<String> returning = new List<String>();
		String objectWithFields = objectName + (fields.isEmpty() ? '' : joinReturnFields(fields));
		returning.add(objectWithFields);
		return String.join(returning, ', ');
	}

	private static String joinReturnFields(List<String> fields) {
		return ' (' + String.escapeSingleQuotes(String.join(fields, ', ')) + ')';
	}

	private static List<RecentlyViewed> queryRecentByType(String objectName) {
		return [
			SELECT Id
			FROM RecentlyViewed
			WHERE Type = :objectName
			LIMIT 5];
	}

	public class Searchable {

		@AuraEnabled
		public String searchTerm {get;set;}
		@AuraEnabled
		public String objectName {get;set;}
		@AuraEnabled
		public List<String> fields {get;set;}
	}
}
