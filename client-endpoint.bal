import ballerina/http;
import ballerina/io;
http:Client clientEndpoint = new ("http://postman-echo.com");

public function main() {
    io:println("GET request:");
    var response = clientEndpoint->get("/get?test=123");

    handleResponse(response);

    io:println("\nPOST request:");
    response = clientEndpoint->post("/post", "POST: Hello World");

    handleResponse(response);

    io:println("\nUse custom HTTP verbs:");
    response = clientEndpoint->execute("COPY", "/get", "CUSTOM: Hello World");

    http:Request req = new;
    req.addHeader("Sample-Name", "http-client-connector");

    response = clientEndpoint->get("/get", req);
    if (response is http:Response) {
        string contentType = response.getHeader("Content-Type");
        io:println("Content-Type: " + contentType);

        int statusCode = response.statusCode;
        io:println("Status code: " + statusCode.toString());
    } else {
        io:println("Error when calling the backend: ",
                                    response.detail()?.message);
    }
}
function handleResponse(http:Response|error response) {
    if (response is http:Response) {
        var msg = response.getTextPayload();
        if (msg is json) {

            io:println(msg.toJsonString());
        } else {
            io:println("Invalid payload received:", msg.reason());
        }
    } else {
        io:println("Error when calling the backend: ",
                                    response.detail()?.message);
    }
}