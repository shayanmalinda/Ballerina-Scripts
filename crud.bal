import ballerina/http;
import ballerina/log;
import ballerina/mysql;
import ballerina/sql;
import ballerina/io;

string dbUser = "root";
string dbPassword = "";
string dbName = "crud";
int serverPort = 9092;

type Customer record {|
    int id;
    string firstname;
    string lastname;
    string email;
|};
        

@http:ServiceConfig {
    basePath: "/customers"
}
service customer on new http:Listener(serverPort) {

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/"
    }
    resource function getCustomers(http:Caller caller, http:Request req) {

        mysql:Client|sql:Error mysqlClient = new (user = dbUser, password = dbPassword, database = dbName);

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


        mysql:Client|sql:Error mysqlClient = new (user = dbUser, password = dbPassword, database = dbName);

        if (mysqlClient is mysql:Client) {

            var customer = req.getJsonPayload();
            if(customer is json){
                json|error firstName = customer.firstname;
                json|error lastName = customer.lastname;
                json|error email = customer.email;
                string sqlString = "('"+firstName.toString() + "','"+lastName.toString()+"','"+email.toString()+"');";
                sql:ExecuteResult|()|error execute = mysqlClient->execute(<@untained> ("INSERT INTO customers (firstname,lastname,email) VALUES "+ sqlString)); 
                var result = caller->respond("success");
                if (result is error) {
                    log:printError("Error sending response", result);
                }  
            }

            sql:Error? err = mysqlClient.close();
        } else {
            io:println("MySQL Client initialization for querying data failed!", mysqlClient);
        }

    }

    @http:ResourceConfig {
        methods: ["PUT"],
        path: "/"
    }
    resource function editCustomers(http:Caller caller, http:Request req) {


        mysql:Client|sql:Error mysqlClient = new (user = dbUser, password = dbPassword, database = dbName);

        if (mysqlClient is mysql:Client) {

            var customer = req.getJsonPayload();
            if(customer is json){
                json|error id = customer.id;
                json|error firstName = customer.firstname;
                json|error lastName = customer.lastname;
                json|error email = customer.email;
                string sqlString = "UPDATE customers SET firstname='"+firstName.toString()+"',lastname='"+lastName.toString()+"',email='"+email.toString()+"' WHERE id="+id.toString();
                sql:ExecuteResult|()|error execute = mysqlClient->execute(<@untained> (sqlString));
                if (execute is error) {
                    io: println(execute.toString());
                    var respond = caller->respond("failed");
                }  
                else{
                    var respond = caller->respond("success");
                }
            }

            sql:Error? err = mysqlClient.close();
        } else {
            io:println("MySQL Client initialization for querying data failed!", mysqlClient);
        }

    }



    @http:ResourceConfig {
        methods: ["DELETE"],
        path: "/"
    }
    resource function deleteCustomer(http:Caller caller, http:Request req) {


        mysql:Client|sql:Error mysqlClient = new (user = dbUser, password = dbPassword, database = dbName);

        if (mysqlClient is mysql:Client) {

            var customer = req.getJsonPayload();
            if(customer is json){
                json|error id = customer.id;
                string sqlString = "DELETE FROM customers WHERE id="+id.toString();
                sql:ExecuteResult|()|error execute = mysqlClient->execute(<@untained> (sqlString));
                if (execute is error) {
                    io: println(execute.toString());
                    var respond = caller->respond("failed");
                }  
                else{
                    var respond = caller->respond("success");
                }
            }

            sql:Error? err = mysqlClient.close();
        } else {
            io:println("MySQL Client initialization for querying data failed!", mysqlClient);
        }

    }
}