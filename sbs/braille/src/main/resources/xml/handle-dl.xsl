<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:dtb="http://www.daisy.org/z3986/2005/dtbook/"
                xmlns:html="http://www.w3.org/1999/xhtml"
                exclude-result-prefixes="#all">
  
  <!--
      Group dt elements and their following dd element.
  -->
  
  <xsl:template match="dtb:dl|html:dl">
    <xsl:variable name="this" as="element()" select="."/>
    <xsl:element name="{if (self::dtb:dl) then 'list' else 'ul'}" namespace="{namespace-uri(.)}">
      <xsl:if test="self::dtb:dl">
        <xsl:attribute name="type" select="'ul'"/>
      </xsl:if>
      <xsl:attribute name="class" select="'dl'"/>
      <xsl:for-each-group select="node()" group-ending-with="*:dd">
        <xsl:sequence select="current-group()[1][self::text()]"/>
        <xsl:if test="exists(current-group()[not(position()=1 and self::text())])">
          <xsl:element name="li" namespace="{namespace-uri($this)}">
            <xsl:if test="exists(current-group()/self::*:dd)">
              <xsl:attribute name="class" select="'dd'"/>
            </xsl:if>
            <xsl:for-each select="current-group()[not(position()=1 and self::text())]">
              <xsl:choose>
                <xsl:when test="self::*:dd">
                  <xsl:sequence select="child::node()"/>
                </xsl:when>
                <xsl:when test="self::*:dt">
                  <xsl:element name="span" namespace="{namespace-uri($this)}">
                    <xsl:attribute name="class" select="'dt'"/>
                    <xsl:sequence select="child::node()[position()&lt;last()]"/>
                    <xsl:choose>
                      <xsl:when test="child::node()[last()]/self::text()">
                        <xsl:value-of select="replace(child::node()[last()],'\s+$','')"/>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:sequence select="child::node()[last()]"/>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:element>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:sequence select="."/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:for-each>
          </xsl:element>
        </xsl:if>
      </xsl:for-each-group>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>
