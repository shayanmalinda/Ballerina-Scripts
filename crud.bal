import ballerina/http;
import ballerina/log;
import ballerina/mysql;
import ballerina/sql;
import ballerina/io;

string dbUser = "root";
string dbPassword = "";

type Customer record {|
    int id;
    string firstname;
    string lastname;
    string email;
|};

@http:ServiceConfig {
    basePath: "/customers"
}
service customer on new http:Listener(9092) {

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/"
    }
    resource function getCustomers(http:Caller caller, http:Request req) {


        mysql:Client|sql:Error mysqlClient = new (user = dbUser, password = dbPassword, database = "crud");

        if (mysqlClient is mysql:Client) {

            stream<record{}, error> resultStream = mysqlClient->query("Select * from customers", Customer);

            stream<Customer, sql:Error> customerStream = <stream<Customer, sql:Error>>resultStream;

            json[] array=[];

            error? e = customerStream.forEach(function(Customer customer) {
                json|error j = json.constructFrom(customer);
                if (j is json) {
                    array.push(j);
                }
            });

            var result = caller->respond(array);
            if (result is error) {
                log:printError("Error sending response", result);
            }

            sql:Error? err = mysqlClient.close();
        } else {
            io:println("MySQL Client initialization for querying data failed!", mysqlClient);
        }

    }

    @http:ResourceConfig {
        methods: ["POST"],
        path: "/"
    }
    resource function addCustomers(http:Caller caller, http:Request req) {


        mysql:Client|sql:Error mysqlClient = new (user = dbUser, password = dbPassword, database = "crud");

        if (mysqlClient is mysql:Client) {

            stream<record{}, error> resultStream = mysqlClient->query("Select * from customers", Customer);

            stream<Customer, sql:Error> customerStream = <stream<Customer, sql:Error>>resultStream;

            json[] array=[];

            error? e = customerStream.forEach(function(Customer customer) {
                json|error j = json.constructFrom(customer);
                if (j is json) {
                    array.push(j);
                }
            });

            var result = caller->respond(array);
            if (result is error) {
                log:printError("Error sending response", result);
            }

            sql:Error? err = mysqlClient.close();
        } else {
            io:println("MySQL Client initialization for querying data failed!", mysqlClient);
        }

    }
}