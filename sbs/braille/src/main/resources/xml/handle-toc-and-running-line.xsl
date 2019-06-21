<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:brl="http://www.daisy.org/z3986/2009/braille/"
                xmlns:html="http://www.w3.org/1999/xhtml"
                exclude-result-prefixes="#all">
  
  <!--
      brl:* elements are not allowed in HTML and are converted to html:* by the px:html-load step
      (px:epub3-to-pef.load)
  -->

  <xsl:template match="*[brl:toc-line|html:toc-line or brl:running-line|html:running-line]">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <brl:select>
        <xsl:apply-templates select="brl:toc-line|html:toc-line|brl:running-line|html:running-line"/>
        <brl:otherwise>
          <xsl:apply-templates select="node() except (brl:toc-line|html:toc-line|brl:running-line|html:running-line)"/>
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
