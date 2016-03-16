/*

The MIT License (MIT)

Copyright (c) 2013 Ben Nadel

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

*/

component
	output = false
	hint = "I wrap around a query and provide high-level methods into that query."
	{


	// Initializes the query helper with the given query. If no query is provided, the helper 
	// is initialized with an empty query.
	any function init( query data = queryNew( "" ) ) {

		target = data;

		return( this );

	}


	// ---
	// PUBLIC METHODS.
	// ---


	// I return the given column as an array.
	public array function getColumn( required string name ) {

		var values = [];

		for ( var i = 1 ; i <= target.recordCount ; i++ ) {

			arrayAppend( values, target[ name ][ i ] );

		}

		return( values );

	}


	// I return the underlying query.
	public query function getQuery() {

		return( target );

	}


	// I return the max value of the given column. If the column is empty, it returns zero.
	public numeric function max( required string columnName ) {

		return(
			arrayMax( target[ columnName ] )
		);

	}


	// I sort the query on the given column name. THIS Is returned as a short-cut.
	public any function sort(
		required string columnName,
		string direction = "asc"
		) {

		var sortedQuery = new Query(
			sql = "SELECT * FROM target ORDER BY #columnName# #direction#",
			dbtype = "query",
			target = target
		);

		target = sortedQuery.execute().getResult();

		return( this );

	}


	// I return the query as an array of structs.
	public array function toArray(
		numeric startIndex = 1,
		numeric endIndex = target.recordCount
		) {

		var rows = [];

		for ( var i = startIndex ; i <= endIndex ; i++ ) {

			arrayAppend( rows, toStruct( i ) );

		}

		return( rows );

	}


	// I return the given row as a struct, in which each column is a key. If no row is provided,
	// it will default to the first row.
	public struct function toStruct( numeric index = 1 ) {

		var row = {};

		for ( var columnName in listToArray( target.columnList ) ) {

			row[ columnName ] = target[ columnName ][ index ];

		}

		return( row );

	}


	// ---
	// PRIVATE METHODS.
	// ---


}