import ballerina/http;
import ballerina/log;
@http:ServiceConfig {
    basePath: "/cbr"
}
service contentBasedRouting on new http:Listener(9090) {
    @http:ResourceConfig {
        methods: ["POST"],
        path: "/route"
    }
    resource function cbrResource(http:Caller outboundEP, http:Request req) {

        http:Client locationEP = new ("http://www.mocky.io");

        var jsonMsg = req.getJsonPayload();

        if (jsonMsg is json) {
            json|error nameString = jsonMsg.name;
            http:Response|error clientResponse;
            if (nameString is json) {
                if (nameString.toString() == "sanFrancisco") {

                    clientResponse =
                            locationEP->post("/v2/594e018c1100002811d6d39a", ());

                } else {
                    clientResponse =
                            locationEP->post("/v2/594e026c1100004011d6d39c", ());
                }
                if (clientResponse is http:Response) {
                    var result = outboundEP->respond(clientResponse);
                    if (result is error) {
                        log:printError("Error sending response", result);
                    }
                } else {
                    http:Response res = new;
                    res.statusCode = 500;
                    res.setPayload(<string>clientResponse.detail()?.message);
                    var result = outboundEP->respond(res);
                    if (result is error) {
                        log:printError("Error sending response", result);
                    }
                }
            } else {
                http:Response res = new;
                res.statusCode = 500;
                res.setPayload(<@untainted string>nameString.detail()?.message);

                var result = outboundEP->respond(res);
                if (result is error) {
                    log:printError("Error sending response", result);
                }
            }
        } else {
            http:Response res = new;
            res.statusCode = 500;
            res.setPayload(<@untainted string>jsonMsg.detail()?.message);
            var result = outboundEP->respond(res);
            if (result is error) {
                log:printError("Error sending response", result);
            }
        }
    }
}