import ballerina/io;
import ballerina/mysql;
import ballerina/sql;
import ballerina/time;
string dbUser = "root";
string dbPassword = "";

type BinaryType record {|
    int row_id;
    byte[] blob_type;
    byte[] binary_type;
|};

type DateTimeType record {|
    int row_id;
    string date_type;
    int time_type;
    time:Time timestamp_type;
    string datetime_type;
|};
function queryBinaryType(mysql:Client mysqlClient) {
    io:println("------ Query Binary Type -------");
    stream<record{}, error> resultStream =
        mysqlClient->query("Select * from BINARY_TYPES");

    io:println("Result 1:");
    error? e = resultStream.forEach(function(record {} result) {
        io:println(result);
    });
    if (e is error) {
        io:println(e);
    }

    resultStream = mysqlClient->query("Select * from BINARY_TYPES", BinaryType);
    stream<BinaryType, sql:Error> binaryResultStream =
        <stream<BinaryType, sql:Error>>resultStream;

    io:println("Result 2:");
    e = binaryResultStream.forEach(function(BinaryType result) {
        io:println(result);
    });
    if (e is error) {
        io:println(e);
    }
    io:println("------ ********* -------");
}

function queryDateTimeType(mysql:Client mysqlClient) {
    io:println("------ Query Date Time Type -------");
    stream<record{}, error> resultStream =
        mysqlClient->query("Select * from DATE_TIME_TYPES");

    io:println("Result 1:");
    error? e = resultStream.forEach(function(record {} result) {
        io:println(result);
    });
    if (e is error) {
        io:println(e);
    }

    resultStream = mysqlClient->query("Select * from DATE_TIME_TYPES",
        DateTimeType);
    stream<DateTimeType, sql:Error> dateResultStream =
        <stream<DateTimeType, sql:Error>>resultStream;

    io:println("Result 2:");
    e = dateResultStream.forEach(function(DateTimeType result) {
        io:println(result);
    });
    if (e is error) {
        io:println(e);
    }
    io:println("------ ********* -------");
}

function initializeTable() returns sql:Error? {
    mysql:Client mysqlClient = check new (user = dbUser, password = dbPassword);
    sql:ExecuteResult? result = check
        mysqlClient->execute("CREATE DATABASE IF NOT EXISTS MYSQL_BBE");

    result = check mysqlClient->execute("DROP TABLE IF EXISTS " +
        "MYSQL_BBE.BINARY_TYPES");
    result = check mysqlClient->execute("CREATE TABLE MYSQL_BBE.BINARY_TYPES"+
        "(row_id INTEGER NOT NULL, blob_type BLOB(1024), binary_type "+
        "BINARY (27), PRIMARY KEY (row_id))");
    result = check mysqlClient->execute("INSERT INTO MYSQL_BBE.BINARY_TYPES "+
        "(row_id, blob_type, binary_type) VALUES (1, "+
        "X'77736F322062616C6C6572696E6120626C6F6220746573742E'," +
        "X'77736F322062616C6C6572696E612062696E61727920746573742E')");
    result = check mysqlClient->execute("DROP TABLE IF EXISTS " +
        "MYSQL_BBE.DATE_TIME_TYPES");
    result = check mysqlClient->execute("CREATE TABLE "+
        "MYSQL_BBE.DATE_TIME_TYPES(row_id INTEGER NOT NULL," +
        "date_type DATE, time_type TIME, timestamp_type timestamp, "+
        "datetime_type  datetime, PRIMARY KEY (row_id))");
    result = check mysqlClient->execute("Insert into " +
        "MYSQL_BBE.DATE_TIME_TYPES (row_id, date_type, time_type, "+
        "timestamp_type, datetime_type) values (1,'2017-05-23','14:15:23',"+
        "'2017-01-25 16:33:55','2017-01-25 16:33:55')");
    check mysqlClient.close();
}
public function main() {
    sql:Error? err = initializeTable();
    if (err is sql:Error) {
        io:println("Sample data initialization failed!", err);
    } else {
        mysql:Client|sql:Error mysqlClient = new (user = dbUser,
            password = dbPassword, database = "MYSQL_BBE");
        if (mysqlClient is mysql:Client) {

            queryBinaryType(mysqlClient);
            queryDateTimeType(mysqlClient);
            io:println("Sample executed successfully!");

            sql:Error? e = mysqlClient.close();
        } else {
            io:println("MySQL Client initialization for querying data" +
            "failed!!", mysqlClient);
        }
    }
}