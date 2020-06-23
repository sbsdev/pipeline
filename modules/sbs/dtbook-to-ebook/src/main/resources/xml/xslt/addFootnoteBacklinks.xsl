<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0"
                xmlns="http://www.daisy.org/z3986/2005/dtbook/"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:dtb="http://www.daisy.org/z3986/2005/dtbook/"
                exclude-result-prefixes="dtb">

  <xsl:import href="copy.xsl"/>

  <xsl:output method="xml" encoding="utf-8" indent="no"/>

  <xsl:template match="dtb:note">
    <xsl:variable name="backlink" select="//dtb:noteref[@idref=concat('#', current()/@id)]/preceding-sibling::dtb:a[1]/@id"/>
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
      <p><a href="#{$backlink}">Zurück</a></p>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
