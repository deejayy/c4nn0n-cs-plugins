#if defined fp_db_included
    #endinput
#endif

#define fp_db_included

#include <sqlx>

#define SQL_HOST "192.168.123.2"
#define SQL_USER "cs_fp"
#define SQL_PASS "cs_fp"
#define SQL_DB "cs_fp"

new Handle:gTuple;
new Handle:gDb;
new bool:gDbConnected;

/**
 * Initializes database connection
 *
 * If it is successful, db handle goes to global variable "gDb",
 * and gDbConnected will be set to true
 *
 * @returns null
 */
dbInit()
{
	gTuple = SQL_MakeDbTuple(SQL_HOST, SQL_USER, SQL_PASS, SQL_DB);

	if(gTuple != Empty_Handle) {
		new errCode, error[128];
		gDb = SQL_Connect(gTuple, errCode, error, charsmax(error));

		if(gDb != Empty_Handle) {
			gDbConnected = true;
		} else {
			server_print("SQL_Connect failed");
		}
	} else {
		server_print("SQL_MakeDbTuple failed");
	}
}

/**
 * Closes database connection, when it is open
 *
 * @return null
 */
dbClose()
{
	if (gDbConnected) {
		SQL_FreeHandle(gDb);
	}
	SQL_FreeHandle(gTuple);
}

/**
 * Gets one int from the query's first row
 *
 * Example code:
 *     server_print("Count: %d", dbGetInt("select count(*) from ..."));
 *
 * @param string queryString input sql query
 *
 * @return int
 */
dbGetInt(queryString[], any:...)
{
	new pQueryString[2048], finalQuery[2048]
	vformat(pQueryString, charsmax(pQueryString), queryString, 2)

	new Handle:query
	new data;

	query = SQL_PrepareQuery(gDb, pQueryString);

	SQL_GetQueryString(query, finalQuery, charsmax(finalQuery));
	server_print("SQL_GetQueryString: %s", finalQuery);

	if(SQL_Execute(query)) {
		if (SQL_MoreResults(query)) {
			data = SQL_ReadResult(query, 0);
			server_print("SQL_ReadResult: %d", data);
		}
	} else {
		new errorString[512]
		SQL_QueryError(query, errorString, charsmax(errorString));
		server_print("SQL_Execute failed: %s", errorString);
	}
	SQL_FreeHandle(query)

	return data;
}

/**
 * Fetches the first row of the query
 *
 * Example code:
 *     new Trie:record = dbGetRecord("select * ...");
 *     new field1[n], field2[n], ... fieldn[n]
 *     TrieGetString(record, "field_name", field1, charsmax(field1));
 *
 * @param string queryString input sql query
 *
 * @return Trie
 */
Trie:dbGetRecord(queryString[], any:...)
{
	new pQueryString[2048], finalQuery[2048]
	vformat(pQueryString, charsmax(pQueryString), queryString, 2)

	new Handle:query
	new data, fieldName[32], buffer[256], i, stri[8], columns;
	new Trie:result = TrieCreate();

	query = SQL_PrepareQuery(gDb, pQueryString);

	SQL_GetQueryString(query, finalQuery, charsmax(finalQuery));
	server_print("SQL_GetQueryString: %s", finalQuery);

	if(SQL_Execute(query)) {
		if (SQL_MoreResults(query)) {
			columns = SQL_NumColumns(query)
			for (i = 0; i < columns; i++) {
				format(stri, charsmax(stri), "%d", i);
				data = SQL_ReadResult(query, i, buffer, charsmax(buffer));
				SQL_FieldNumToName(query, i, fieldName, charsmax(fieldName));
				TrieSetString(result, stri, buffer);
				TrieSetString(result, fieldName, buffer);
				server_print("SQL_ReadResult: %s: %s", fieldName, buffer, data);
			}
		}
	} else {
		new errorString[512]
		SQL_QueryError(query, errorString, charsmax(errorString));
		server_print("SQL_Execute failed: %s", errorString);
	}
	SQL_FreeHandle(query);

	return result;
}

dbSilentQuery(queryString[], any:...)
{
	new pQueryString[2048], finalQuery[2048], result
	vformat(pQueryString, charsmax(pQueryString), queryString, 2)

	new Handle:query
	query = SQL_PrepareQuery(gDb, pQueryString);

	SQL_GetQueryString(query, finalQuery, charsmax(finalQuery));
	server_print("SQL_GetQueryString: %s", finalQuery);

	if(SQL_Execute(query)) {
		result = 1
	} else {
		new errorString[512]
		SQL_QueryError(query, errorString, charsmax(errorString));
		server_print("SQL_Execute failed: %s", errorString);
	}

	SQL_FreeHandle(query);

	return result;
}

dbGetRecordAsync(queryString[], any:...)
{
	new pQueryString[2048], finalQuery[2048], result
	vformat(pQueryString, charsmax(pQueryString), queryString, 2)

	
}
