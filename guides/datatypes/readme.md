# Data Types

This guide explains about SQL data types, and how they are used by the DB gem.

Structured Query Language (SQL) defines a set of data types that can be used to store data in a database. The data types are used to define a column in a table, and each column in a table must have a data type associated with it. The data type of a column typically defines the kind of data that the column can store, althought some database systems allow you to store any kind of data in any column.

When you build a program with a database, you need to be aware of the data types that are available in the database system you are using. The DB gem tries to expose standard data types, so that you can use the same data types across different database systems. There are two main operations that are affected by datatypes: appending literal values to SQL queries, and reading values from the database.

## Appending Literal Data Types

The DB gem converts Ruby objects to SQL literals when you append them to a query. This is generally taken care of by the {ruby DB::Query#literal} and {ruby DB::Query#interpolate} methods, which are used to append literal values to a query. Generally speaking, the following native data types are supported:

- `Time`, `DateTime` and `Date` objects convert to an appropriate format for the database system you are using. Some systems don't natively support timezones, and so time zone information may be lost.
- `String` objects are escaped and quoted.
- `Numeric` (including `Integer` and `Float`) objects are appended as-is.
- `TrueClass` and `FalseClass` objects are converted to the appropriate boolean value for the database system you are using.
- `NilClass` objects are converted to `NULL`.

## Reading Data Types

When you read data from the database, the DB gem tries to convert the data to the appropriate Ruby object. When a query yields rows of fields, and those fields have a well defined field type, known by the adapter, the adapter will cast those objects back into rich Ruby objects where possible. The following conversions are generally supported:

- `TEXT` and `VARCHAR` fields are converted to `String` objects.
- `INTEGER` and `FLOAT` fields are converted to `Integer` and `Float` objects respectively.
- `BOOLEAN` fields are converted to `TrueClass` and `FalseClass` objects.
- `TIMESTAMP` and `DATETIME` fields are converted to `Time` objects.
- `DATE` fields are converted to `Date` objects.
- `NULL` values are converted to `nil`.
