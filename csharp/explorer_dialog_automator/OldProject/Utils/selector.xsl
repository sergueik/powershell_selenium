<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:util="urn:util" xmlns:test="http://xmlsoft.org/XSLT/" version="1.0">
  <xsl:output omit-xml-declaration="no" indent="yes"/>
  <xsl:template match="/">
    <xsl:element name="transaction">
      <xsl:call-template name="bootstrap"/>
    </xsl:element>
  </xsl:template>
  <xsl:template name="bootstrap">
    <!-- inspect response headers -->
    <xsl:apply-templates select="//response//header[name='Content-Type'][contains(value , 'text/html') or value = 'application/x-javascript']"/>
  </xsl:template>
  <xsl:template name="response_locator" match="//response//header">
    <!-- grab the response node with matched header and pass to down the pipeline -->
    <xsl:apply-templates select="../../../*[name() = 'response']"/>
  </xsl:template>
  <xsl:template name="request_locator" match="response">
    <!-- navigate to preceding request -->
    <xsl:apply-templates select="preceding-sibling::*[name()='request']"/>
  </xsl:template>
  <xsl:template name="request_formatter" match="request">
    <!-- for breadcrumbs xpath code see http://www.dpawson.co.uk/xsl/sect2/N6077.html#d5745e18 -->
    <xsl:variable name="stepno" select="util:labelstep()"/>
    <xsl:element name="request">
      <xsl:attribute name="stepno">
        <xsl:copy-of select="$stepno"/>
      </xsl:attribute>
      <xsl:apply-templates select="./*"/>
      <xsl:element name="hints">
        <xsl:element name="hint">
          <xsl:attribute name="name">status</xsl:attribute>
          <xsl:attribute name="value">
            <xsl:value-of select="following-sibling::*[name()='response']/status"/>
          </xsl:attribute>
        </xsl:element>
      </xsl:element>
    </xsl:element>
  </xsl:template>
  <xsl:template name="peek" match="//request//header">
    <!-- pick certain request headers -->
    <!-- TODO enclose in headers node -->
    <xsl:choose>
      <xsl:when test="name='Content-Type'">
        <xsl:choose>
          <xsl:when test="contains(value, 'application/x-www-form-urlencoded')">
            <xsl:element name="header">
              <xsl:attribute name="name">
                <xsl:value-of select="name"/>
              </xsl:attribute>
              <xsl:attribute name="value">
                <xsl:value-of select="value"/>
              </xsl:attribute>
            </xsl:element>
          </xsl:when>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="name='Referer' or name='User-Agent' or name='Connection' or name='Host'">
        <xsl:element name="header">
          <xsl:attribute name="name">
            <xsl:value-of select="name"/>
          </xsl:attribute>
          <xsl:attribute name="value">
            <xsl:value-of select="value"/>
          </xsl:attribute>
        </xsl:element>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  <xsl:template name="copy" match="*[name()='httpVersion' or name()='url' or name()='method']">
    <xsl:copy-of select="."/>
  </xsl:template>
  <!-- flatten nested name / value  nodes  into attributes to simplify Xparse job -->
  <xsl:template name="flatten_querystring" match="queryString">
    <xsl:element name="queryString">
      <xsl:for-each select="./param">
        <xsl:element name="param">
          <xsl:attribute name="name">
            <xsl:value-of select="name"/>
          </xsl:attribute>
          <xsl:attribute name="value">
            <xsl:value-of select="value"/>
          </xsl:attribute>
        </xsl:element>
      </xsl:for-each>
    </xsl:element>
  </xsl:template>
  <xsl:template name="flatten_cookies" match="cookies">
    <xsl:element name="cookies">
      <xsl:for-each select="./cookie">
        <xsl:element name="cookie">
          <xsl:attribute name="name">
            <xsl:value-of select="name"/>
          </xsl:attribute>
          <xsl:attribute name="value">
            <xsl:value-of select="value"/>
          </xsl:attribute>
        </xsl:element>
      </xsl:for-each>
    </xsl:element>
  </xsl:template>
  <xsl:template name="postData" match="postData">
    <xsl:element name="formvals">
    <!-- invoke perl or c# to generate formvals -->
    <xsl:value-of select="util:formvals(text)" disable-output-escaping="yes"/>
    <xsl:copy-of select="."/>
    </xsl:element>
  </xsl:template>
  <xsl:template name="ignore" match="*[name()='headersSize' or name()='bodySize']">
</xsl:template>
</xsl:stylesheet>
