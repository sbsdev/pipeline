<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0"
                xmlns="http://www.daisy.org/z3986/2005/dtbook/"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:dtb="http://www.daisy.org/z3986/2005/dtbook/"
                exclude-result-prefixes="dtb">

  <xsl:import href="copy.xsl"/>

  <xsl:output method="xml" encoding="utf-8" indent="no"/>

  <xsl:template match="dtb:rearmatter">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
      <xsl:if test="//dtb:note">
	<level1>
	  <h1>Fussnoten</h1>
	  <xsl:copy-of select="//dtb:note"/>
	</level1>
      </xsl:if>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="dtb:book[not(dtb:rearmatter)]">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
      <xsl:if test="//dtb:note">
	<rearmatter>
	  <level1>
	    <h1>Fussnoten</h1>
	    <xsl:copy-of select="//dtb:note"/>
	  </level1>
	</rearmatter>
      </xsl:if>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="dtb:note"/>

</xsl:stylesheet>
