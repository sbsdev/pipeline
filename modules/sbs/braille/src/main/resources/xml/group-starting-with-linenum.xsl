<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="#all">
  
  <xsl:template match="*:p[*:span[@class='linenum']]">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:for-each-group select="node()" group-starting-with="*:span[@class='linenum']">
        <xsl:if test="current-group()/self::* or not(normalize-space(string-join(current-group()/string(.),''))='')">
          <xsl:element name="span" namespace="{namespace-uri(/*)}">
            <xsl:attribute name="class" select="'line'"/>
            <xsl:apply-templates select="current-group()"/>
          </xsl:element>
        </xsl:if>
      </xsl:for-each-group>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>
