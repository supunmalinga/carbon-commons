<!--
~ Copyright (c) 2005-2010, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
~
~ WSO2 Inc. licenses this file to you under the Apache License,
~ Version 2.0 (the "License"); you may not use this file except
~ in compliance with the License.
~ You may obtain a copy of the License at
~
~    http://www.apache.org/licenses/LICENSE-2.0
~
~ Unless required by applicable law or agreed to in writing,
~ software distributed under the License is distributed on an
~ "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
~ KIND, either express or implied.  See the License for the
~ specific language governing permissions and limitations
~ under the License.
-->
<%@ page import="org.apache.axis2.context.ConfigurationContext" %>
<%@ page import="org.wso2.carbon.CarbonConstants" %>
<%@ page import="org.wso2.carbon.application.mgt.ui.ApplicationAdminClient" %>
<%@ page import="org.wso2.carbon.ui.CarbonUIMessage" %>
<%@ page import="org.wso2.carbon.ui.CarbonUIUtil" %>
<%@ page import="org.wso2.carbon.utils.ServerConstants" %>
<%@ page import="org.wso2.carbon.ui.util.CharacterEncoder" %>
<%
    String pageAction = CharacterEncoder.getSafeText(request.getParameter("action"));
    String pageNumber = CharacterEncoder.getSafeText(request.getParameter("pageNumber"));
    int pageNumberInt = 0;
    if (pageNumber != null) {
        pageNumberInt = Integer.parseInt(pageNumber);
    }
    String[] faultyCarbonAppFileNames = request.getParameterValues("carbonAppFileName");
    String processAllServiceGroups = CharacterEncoder.getSafeText(request.getParameter("processAllCarbonApps"));
%>

<%
    String backendServerURL = CarbonUIUtil.getServerURL(config.getServletContext(), session);
    ConfigurationContext configContext =
            (ConfigurationContext) config.getServletContext().getAttribute(CarbonConstants.CONFIGURATION_CONTEXT);

    String cookie = (String) session.getAttribute(ServerConstants.ADMIN_SERVICE_COOKIE);
    ApplicationAdminClient client;
    try {
        client = new ApplicationAdminClient(cookie, backendServerURL, configContext, request.getLocale());
    } catch (Exception e) {
        CarbonUIMessage uiMsg = new CarbonUIMessage(CarbonUIMessage.ERROR, e.getMessage(), e);
        session.setAttribute(CarbonUIMessage.ID, uiMsg);
%>
<jsp:include page="../admin/error.jsp"/>
<%
        return;
    }

    try {
        if (pageAction.equals("delete")) {
            if (processAllServiceGroups != null) {
                String[] faultyList = client.getAllFaultyApps();
                client.deleteFaultyApp(faultyList);
            } else {
                client.deleteFaultyApp(faultyCarbonAppFileNames);
            }
        } else if (pageAction.equals("redeploy")) {
            if (processAllServiceGroups != null) {
                String[] faultyList = client.getAllFaultyApps();
                client.redeployApplications(faultyList);
            } else {
                client.redeployApplications(faultyCarbonAppFileNames);
            }
        } else {
            throw new Exception("Invalid page action : " + pageAction);
        }
%>
<script>
    location.href = 'faulty_carapps.jsp?pageNumber=<%=pageNumberInt%>'
</script>
<%
    } catch (Exception e) {
        CarbonUIMessage uiMsg = new CarbonUIMessage(CarbonUIMessage.ERROR, e.getMessage(), e);
        session.setAttribute(CarbonUIMessage.ID, uiMsg);
%>
<jsp:include page="../admin/error.jsp"/>
<%
        return;
    }
%>
