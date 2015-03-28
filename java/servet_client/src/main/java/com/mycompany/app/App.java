package com.mycompany.app;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.URL;

import org.apache.http.HttpHost;
import org.apache.http.HttpResponse;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.HttpClient;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.message.BasicHttpRequest;
import org.json.JSONException;
import org.json.JSONObject;
import org.junit.Assert;
import static org.junit.Assert.*;

// origin https://gist.github.com/krmahadevan/3302548

public class App {


/**
 *  http://localhost:4444/grid/api/proxy?id=http://localhost:5555
 *  http://localhost:4444/grid/api/proxy?id=http://SERGUEIK42:5555
 */


static String hubHost = "localhost";
static int hubPort = 4444;

public static void main(String[] args) throws ClientProtocolException, IOException, JSONException {

	URL proxyApi = new URL("http://" + hubHost + ":" + hubPort + "/grid/admin/MyConsoleServlet");
	HttpClient client = new DefaultHttpClient();
	BasicHttpRequest r = new BasicHttpRequest("GET", proxyApi.toExternalForm());
	HttpHost host = new HttpHost(hubHost, hubPort);
	HttpResponse response = client.execute(host, r);
	assertEquals(200, response.getStatusLine().getStatusCode());
	JSONObject o = extractObject(response);
	System.out.println(o);

}
private static JSONObject extractObject(HttpResponse resp) throws IOException, JSONException {
	BufferedReader rd = new BufferedReader(new InputStreamReader(resp.getEntity().getContent()));
	StringBuilder s = new StringBuilder();
	String line;
	while ((line = rd.readLine()) != null) {
		s.append(line);
	}
	rd.close();
	return new JSONObject(s.toString());
}
}
