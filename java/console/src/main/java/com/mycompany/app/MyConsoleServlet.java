package com.mycompany.app;

import java.io.IOException;
import java.util.Iterator;

import java.util.logging.Logger;
import javax.servlet.Servlet;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;

import javax.servlet.http.HttpServletResponse;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.openqa.grid.common.exception.GridException;
import org.openqa.grid.internal.ProxySet;
import org.openqa.grid.internal.Registry;
import org.openqa.grid.internal.RemoteProxy;
import org.openqa.grid.web.servlet.RegistryBasedServlet;
// https://gist.github.com/krmahadevan/3302497

public class MyConsoleServlet extends RegistryBasedServlet {

private static final long serialVersionUID = -1975392591408983229L;

public MyConsoleServlet() {
	this(null);
}

public MyConsoleServlet(Registry registry) {
	super(registry);
}

@Override
protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
	doPost(req, resp);
}

@Override
protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
	process(req, resp);

}

protected void process(HttpServletRequest request, HttpServletResponse response) throws IOException {
	response.setContentType("text/json");
	response.setCharacterEncoding("UTF-8");
	response.setStatus(200);
	JSONObject res;
	try {
		res = getResponse();
		response.getWriter().print(res);
		response.getWriter().close();
	} catch (JSONException e) {
		throw new GridException(e.getMessage());
	}

}

private JSONObject getResponse() throws IOException, JSONException {
	JSONObject requestJSON = new JSONObject();
	ProxySet proxies = this.getRegistry().getAllProxies();
	Iterator<RemoteProxy> iterator = proxies.iterator();
	JSONArray busyProxies = new JSONArray();
	JSONArray freeProxies = new JSONArray();
	while (iterator.hasNext()) {
		RemoteProxy eachProxy = iterator.next();
		if (eachProxy.isBusy()) {
			busyProxies.put(eachProxy.getOriginalRegistrationRequest().getAssociatedJSON());
		} else {
			freeProxies.put(eachProxy.getOriginalRegistrationRequest().getAssociatedJSON());
		}
	}
	requestJSON.put("BusyProxies", busyProxies);
	requestJSON.put("FreeProxies", freeProxies);

	return requestJSON;
}

}
