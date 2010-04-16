<?xml version="1.0" encoding="utf-8"?>
<!--
 Licensed to the Apache Software Foundation (ASF) under one or more
 contributor license agreements.  See the NOTICE file distributed with
 this work for additional information regarding copyright ownership.
 The ASF licenses this file to You under the Apache License, Version 2.0
 (the "License"); you may not use this file except in compliance with
 the License.  You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
-->
<!-- $Id$ -->
<!-- $URL$ -->

<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="1.0">

  <xsl:output
    method="html"
    indent="yes"
    encoding="utf-8"
    media-type="text/html; charset=UTF-8"
    doctype-public="-//W3C//DTD HTML 4.01//EN"
    doctype-system="http://www.w3.org/TR/html4/strict.dtd" />

  <xsl:template match="/">
    <html>
      <head>
        <link rel="stylesheet" type="text/css" href="solr-admin.css"></link>
	<link rel="icon" href="favicon.ico" type="image/ico"></link>
	<link rel="shortcut icon" href="favicon.ico" type="image/ico"></link>
        <title>Solr Admin: Logging</title>
      </head>
      <body>
        <div id="header">
          <p class="logo"><a href="."><img src="iahxserver.jpg" alt="" /></a></p>
          <h1>Solr Admin (<xsl:value-of select="solr/meta/collection" />)</h1>
        </div>
        <div style="margin-top: 1em;">
          <xsl:apply-templates/>
        <div>
        </div>
          <a href=".">Return to Admin Page</a>
        </div>
      </body>
    </html>
  </xsl:template>

  <xsl:include href="meta.xsl"/>

  <xsl:template match="solr/logging">

<br clear="all"/>
<h2>Solr Logging</h2>
<table>
  <tr>
    <td>
      <H3>Log Level:</H3>
    </td>
    <td>
<xsl:value-of select="logLevel" />
    </td>
  </tr>
  <tr>
    <td>
    Set Level
    </td>
    <td>
    [<a href="action.jsp?log=ALL">ALL</a>]
    [<a href="action.jsp?log=CONFIG">CONFIG</a>]
    [<a href="action.jsp?log=FINE">FINE</a>]
    [<a href="action.jsp?log=FINER">FINER</a>]
    [<a href="action.jsp?log=FINEST">FINEST</a>]
    [<a href="action.jsp?log=INFO">INFO</a>]
    [<a href="action.jsp?log=OFF">OFF</a>]
    [<a href="action.jsp?log=SEVERE">SEVERE</a>]
    [<a href="action.jsp?log=WARNING">WARNING</a>]
    </td>
  </tr>
</table>

  </xsl:template>
</xsl:stylesheet>
