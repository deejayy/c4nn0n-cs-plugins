#if defined fp_db_included
    #endinput
#endif

#define fp_db_included

#include <sqlx>

#define SQL_HOST "192.168.123.2"
#define SQL_USER "cs_fp"
#define SQL_PASS "cs_fp"
#define SQL_DB "cs_fp"
#define SQL_LOGFILE "database-log.sql"
#define SQL_ERRORFILE "database-error.log"

new g_logfile[256];
new g_errorlog[256];

new Handle:gTuple;

/**
 * Initializes database tuple
 *
 * @returns null
 */
db_init()
{
	gTuple = SQL_MakeDbTuple(SQL_HOST, SQL_USER, SQL_PASS, SQL_DB);

	if(gTuple != Empty_Handle) {
	} else {
		server_print("SQL_MakeDbTuple failed");
	}

	new logdir[256];
	get_localinfo("amxx_logs", logdir, charsmax(logdir));
	format(g_logfile, charsmax(g_logfile), "%s/%s", logdir, SQL_LOGFILE);
	format(g_errorlog, charsmax(g_errorlog), "%s/%s", logdir, SQL_ERRORFILE);
}

/**
 * Closes database connection, when it is open
 *
 * @return null
 */
db_close()
{
	SQL_FreeHandle(gTuple);
}

/**
 * Common error handler for ThreadQuery
 *
 * @param failState int    filled automatically by native
 * @param query     Handle ^
 * @param error     string ^
 * @param errCode   int    ^
 * @param data      array  ^
 * @param dataSize  int    ^
 *
 * @return null
 */
public db_handle_errors(failState, Handle:query, error[], errCode, data[], dataSize)
{
	new finalQuery[2048];

	SQL_GetQueryString(query, finalQuery, charsmax(finalQuery));
	com_putsd(g_logfile, "%s;", finalQuery);
//	server_print("SQL_GetQueryString: %s", finalQuery);

	if (failState == TQUERY_CONNECT_FAILED) {
		server_print("SQL_ThreadQuery: Could not connect to SQL database.");
	} else if (failState == TQUERY_QUERY_FAILED) {
		server_print("SQL_ThreadQuery: Query failed");
	}

	if (errCode) {
		server_print("Error on query: %s", error);
		com_putsd(g_errorlog, "%s;", error);
	}
}

/**
 * Silently executes an SQL query
 *
 * @param queryString string SQL
 * @param any:...     mixed  params to format like printf
 *
 * @return null
 */
db_silent_query(queryString[], any:...)
{
	new pQueryString[2048];
	vformat(pQueryString, charsmax(pQueryString), queryString, 2)

	SQL_ThreadQuery(gTuple, "db_handle_errors", pQueryString);
}

/**
 * Executes an SQL query and passes it to the given handler
 *
 * @param handler     string handler function's name
 * @param data        array  forwarded data to handler
 * @param dataSize    int    data array's size
 * @param queryString string SQL
 * @param any:...     mixed  params to format like printf
 *
 * @return null
 */
db_query(handler[], data[], dataSize, queryString[], any:...)
{
	new pQueryString[2048]
	vformat(pQueryString, charsmax(pQueryString), queryString, 5)

	SQL_ThreadQuery(gTuple, handler, pQueryString, data, dataSize);
}

/**
 * Escapes ' and \ in the source string
 *
 * @param output     string
 * @param outputSize int
 * @param source     string
 *
 * @return null
 */
db_quote_string(output[], outputSize, source[])
{
	copy(output, outputSize, source);

	if (output[0]) {
		for (new i = 0; i < outputSize; i++) {
			if (output[i] == 39 || output[i] == 92) {
				format(output[i], outputSize, "\%s", output[i]);
				i++;
			}
		}
	}
}

/**
 * Fetches the first row from a query result
 *
 * @param query Handle
 *
 * @return Trie
 */
Trie:db_get_record(Handle:query)
{
	new fieldName[32], buffer[256], i, stri[8], columns;
	new Trie:result = TrieCreate();

	if (SQL_MoreResults(query)) {
		columns = SQL_NumColumns(query)
		for (i = 0; i < columns; i++) {
			format(stri, charsmax(stri), "%d", i);
			// new data = SQL_ReadResult(query, i, buffer, charsmax(buffer));
			SQL_ReadResult(query, i, buffer, charsmax(buffer));
			SQL_FieldNumToName(query, i, fieldName, charsmax(fieldName));
			TrieSetString(result, stri, buffer);
			TrieSetString(result, fieldName, buffer);
			// server_print("SQL_ReadResult: %s: %s", fieldName, buffer, data);
		}
	}

	return result;
}
