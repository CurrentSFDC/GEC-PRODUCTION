/**
 * Created by Misi on 2021-07-26.
 */

public with sharing class VimeoConnectorMock implements HttpCalloutMock{

    public HttpResponse respond(HttpRequest param1) {
        HttpResponse httpResponse = new HttpResponse();
        httpResponse.setStatusCode(200);
        VimeoConnector.VimeoDetails details = new VimeoConnector.VimeoDetails();
        details.thumbnail_medium = 'https://foo.bar';
        httpResponse.setBody(JSON.serialize(new List<VimeoConnector.VimeoDetails>{details}));
        return httpResponse;
    }
}