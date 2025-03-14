%{--
  - Copyright 2016 SimplifyOps, Inc. (http://simplifyops.com)
  -
  - Licensed under the Apache License, Version 2.0 (the "License");
  - you may not use this file except in compliance with the License.
  - You may obtain a copy of the License at
  -
  -     http://www.apache.org/licenses/LICENSE-2.0
  -
  - Unless required by applicable law or agreed to in writing, software
  - distributed under the License is distributed on an "AS IS" BASIS,
  - WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  - See the License for the specific language governing permissions and
  - limitations under the License.
  --}%

<%--
  Created by IntelliJ IDEA.
  User: greg
  Date: 8/27/15
  Time: 3:54 PM
--%>

<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="tabpage" content="configure"/>
    <meta name="layout" content="base"/>
    <g:set var="projectLabel" value="${session.frameworkLabels?session.frameworkLabels[params.project]:params.project}"/>
    <title><g:appTitle/> - <g:message code="scmController.page.${integration}.diff.title" args="[projectLabel]"/></title>

</head>

<body>
<div class="content">
<div id="layoutBody">
<div class="row">
    <div class="col-sm-12">
        <g:render template="/common/messages"/>
    </div>
</div>

<div class="row">
    <div class="col-sm-12">
        <div class="card">
            <div class="list-group-item">
                <h4 class="list-group-item-heading"><g:message code="scmController.page.${integration}.diff.description"/></h4>
            </div>

            <div class="list-group-item">
                
                    <g:render template="/scheduledExecution/showHead" model="[scheduledExecution: job]"/>
            
            </div>
            <g:set var="jobstatus" value="${integration=='export'?scmExportStatus?.get(job.extid):scmImportStatus?.get(job.extid)}"/>

            <div class="list-group-item">
                <div class="flex">
                    <g:set var="exportStatus" value="${scmExportStatus?.get(job.extid)}"/>
                    <g:set var="importStatus" value="${scmImportStatus?.get(job.extid)}"/>
                    <span style="margin-right: 10px;">
                    <g:render template="/scm/statusBadge" model="[
                            showClean:true,
                            exportStatus: exportStatus?.synchState?.toString(),
                            importStatus: importStatus?.synchState?.toString(),
                            text  : '',
                            integration:integration,
                            exportCommit: exportStatus?.commit,
                            importCommit: importStatus?.commit,
                    ]"/>
                    </span>
                    <g:if test="${scmFilePaths && scmFilePaths[job.extid] && integration=='export'}">
                        <g:if test="${scmExportRenamedPath}">
                            <div>
                                <span class="has_tooltip text-primary" title="Original repo path" data-viewport="#section-content">
                                    <g:icon name="file"/>
                                    ${scmExportRenamedPath}
                                </span>
                            </div>
                        </g:if>
                        <span class="has_tooltip" title="Repo file path" data-viewport="#section-content">
                            <g:if test="${scmExportRenamedPath}">
                                <g:icon name="arrow-right"/>
                            </g:if>

                            <g:icon name="file"/>
                            ${scmFilePaths[job.extid]}
                        </span>
                    </g:if>

                    <g:if test="${scmFilePaths && scmFilePaths[job.extid] && integration=='import'}">
                        <span class="has_tooltip" title="Original repo path" data-viewport="#section-content">
                            <g:icon name="file"/>
                            ${scmFilePaths[job.extid]}
                        </span>

                        <g:if test="${scmImportRenamedPath}">
                            <g:if test="${scmImportRenamedPath}">
                                <g:icon name="arrow-right"/>
                            </g:if>
                            <div>
                                <span class="has_tooltip text-primary" title="Repo file path" data-viewport="#section-content">
                                    <g:icon name="file"/>
                                    ${scmImportRenamedPath}
                                </span>
                            </div>
                        </g:if>
                    </g:if>
                </div>
                
            </div>
            <g:if test="${jobstatus?.commit}">
                <div class="list-group-item">
                    <g:render template="commitInfo" model="[commit:jobstatus.commit,title:'Current Commit']"/>
                </div>
            </g:if>


            <g:if test="${diffResult && integration=='import' && diffResult.hasProperty("incomingCommit") && diffResult.incomingCommit}">
                <g:set var="commit" value="${diffResult.incomingCommit}"/>
                <g:if test="${jobstatus?.commit?.commitId != commit.commitId}">
                    <div class="list-group-item">
                        <g:render template="commitInfo" model="[commit:commit,title:'Incoming Commit']"/>
                    </div>
                </g:if>
            </g:if>
            <g:if test="${diffResult?.oldNotFound}">

                <div class="list-group-item">
                    <div class="list-group-item-text text-info">
                        <g:message code="not.added.to.scm"/>
                    </div>
                </div>
            </g:if>
            <g:elseif test="${diffResult?.newNotFound}">

                <div class="list-group-item">
                    <div class="list-group-item-text text-warning">
                        <g:message code="file.has.been.removed.in.scm" />
                    </div>
                </div>
            </g:elseif>
            <g:elseif test="${diffResult && !diffResult.modified}">

                <div class="list-group-item">
                    <div class="list-group-item-text text-primary">
                        <g:message code="no.changes"/>
                    </div>
                </div>
            </g:elseif>
            <g:elseif test="${diffResult?.content}">
                <div class="list-group-item">
                    <g:link action="diff" controller="scm"
                            class="btn btn-simple"
                            params="[project: params.project, id: job.extid, download: true, integration:integration]">
                        <g:icon name="download"/>
                        <g:message code="download.diff" />
                    </g:link>

                </div>

                <div id="difftext"
                     class="list-group-item scriptContent expanded apply_ace"
                     data-ace-session-mode="diff">${diffResult.content}</div>
            </g:elseif>
            <g:if test="${diffResult && (diffResult.modified || diffResult.oldNotFound) && diffResult.actions}">
                <div class="list-group-item">
                <g:each in="${diffResult.actions}" var="action">

                    <g:render template="/scm/actionLink"
                              model="${[action:action,
                                      integration:integration,
                                      project:params.project,
                                      linkparams:[id:job.extid],
                                      classes:"btn "+(diffResult.oldNotFound ? 'btn-success' : 'btn-info')]}"
                    />
                </g:each>
                </div>
            </g:if>
        </div>
    </div>
</div>

<!--[if (gt IE 8)|!(IE)]><!--> <asset:javascript src="ace-bundle.js"/><!--<![endif]-->
<g:javascript>
    fireWhenReady('difftext', function (z) {
        jQuery('.apply_ace').each(function () {
            _applyAce(this, '400px');
        });
    });
</g:javascript>
</div>
</div>
</body>
</html>