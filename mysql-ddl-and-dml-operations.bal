import ballerina/io;
import ballerina/mysql;
import ballerina/sql;
string dbUser = "root";
string dbPassword = "";
string dbName = "MYSQL_BBE_EXEC";

function initializeDatabase() returns sql:Error? {
    mysql:Client mysqlClient = check new (user = dbUser, password = dbPassword);

    sql:ExecuteResult? result =
        check mysqlClient->execute("CREATE DATABASE IF NOT EXISTS " + dbName);
    io:println("Database created. ");

    check mysqlClient.close();
}

function initializeTable(mysql:Client mysqlClient)
    returns int|string|sql:Error? {
    sql:ExecuteResult? result =
        check mysqlClient->execute("DROP TABLE IF EXISTS Customers");
    if (result is sql:ExecuteResult) {
        io:println("Drop table executed. ", result);
    }

    result = check mysqlClient->execute("CREATE TABLE IF NOT EXISTS Customers" +
        "(customerId INTEGER NOT NULL AUTO_INCREMENT, firstName  VARCHAR(300)" +
        ",lastName  VARCHAR(300), registrationID INTEGER," +
        "creditLimit DOUBLE, country  VARCHAR(300), PRIMARY KEY (customerId))");

    result = check mysqlClient->execute("INSERT INTO Customers (firstName," +
        "lastName,registrationID,creditLimit, country) VALUES ('Peter', " +
        "'Stuart', 1, 5000.75, 'USA')");
    int|string? generatedId = ();

    if (result is sql:ExecuteResult) {
        io:println("Rows affected: ", result.affectedRowCount);
        io:println("Generated Customer ID: ", result.lastInsertId);
        generatedId = result.lastInsertId;
    }
    return generatedId;
}
function updateRecord(mysql:Client mysqlClient, int generatedId) {
    string query = string ` ${generatedId}`;
    sql:ExecuteResult|sql:Error? result =
        mysqlClient->execute("Update Customers set creditLimit = 15000.5 "+
        "where customerId =" + generatedId.toString());
    if (result is sql:ExecuteResult) {
        io:println("Updated Row count: ", result?.affectedRowCount);
    } else if (result is sql:Error) {
        io:println("Error occured: ", result);
    } else {
        io:println("Empty result");
    }
}

function deleteRecord(mysql:Client mysqlClient, int generatedId) {
    sql:ExecuteResult|sql:Error? result =
        mysqlClient->execute("Delete from Customers where customerId = "+
        generatedId.toString());
    if (result is sql:ExecuteResult) {
        io:println("Deleted Row count: ", result.affectedRowCount);
    } else if (result is sql:Error) {
        io:println("Error occured: ", result);
    } else {
        io:println("Empty result");
    }
}

public function main() {
    sql:Error? err = initializeDatabase();
    if (err is ()) {

        mysql:Client|sql:Error mysqlClient = new (user = dbUser,
            password = dbPassword, database = dbName);
        if (mysqlClient is mysql:Client) {

            int|string|sql:Error? initResult = initializeTable(mysqlClient);
            if (initResult is int) {

                updateRecord(mysqlClient, initResult);

                deleteRecord(mysqlClient, initResult);
                io:println("Sample executed successfully!");
            } else if (initResult is sql:Error) {
                io:println("Customer table initialization failed!", initResult);
            }

            sql:Error? e = mysqlClient.close();
        } else {
            io:println("Table initialization failed!!", mysqlClient);
        }
    } else {
        io:println("Database initialization failed!!", err);
    }
}