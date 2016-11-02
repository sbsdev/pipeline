<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:brl="http://www.daisy.org/z3986/2009/braille/"
                exclude-result-prefixes="#all">
  
  <xsl:template match="*[brl:toc-line]">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <brl:select>
        <xsl:apply-templates select="brl:toc-line"/>
        <brl:otherwise>
          <xsl:apply-templates select="node() except brl:toc-line"/>
        </brl:otherwise>
      </brl:select>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>
