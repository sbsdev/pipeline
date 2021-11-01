<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0"
                xmlns="http://www.daisy.org/z3986/2005/dtbook/"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:dtb="http://www.daisy.org/z3986/2005/dtbook/"
		xmlns:pf="http://www.daisy.org/ns/pipeline/functions"
                exclude-result-prefixes="dtb">

  <xsl:output method="xml" encoding="utf-8" indent="no"
              doctype-public="-//NISO//DTD dtbook 2005-3//EN"
              doctype-system="http://www.daisy.org/z3986/2005/dtbook-2005-3.dtd" />

  <xsl:template name="boilerplate">
    <xsl:variable name="language" select="('de',ancestor-or-self::*[@xml:lang|@lang]/(@xml:lang|@lang)[1])[last()]"/>
    <xsl:variable name="about-book" select="pf:i18n-translate('about-book',$language,$translations)"/>
    <xsl:variable name="copyright-blurb" select="pf:i18n-translate('copyright-blurb',$language,$translations)"/>
    <xsl:variable name="electronic-data-thanks" select="pf:i18n-translate('electronic-data-thanks',$language,$translations)"/>
    <xsl:variable name="producer" select="pf:i18n-translate('producer',$language,$translations)"/>
    <xsl:variable name="producer-brief" select="pf:i18n-translate('producer-brief',$language,$translations)"/>
    <xsl:variable name="producer-url" select="pf:i18n-translate('producer-url',$language,$translations)"/>
    <xsl:variable name="producer-url-brief" select="pf:i18n-translate('producer-url-brief',$language,$translations)"/>
    <xsl:variable name="production" select="pf:i18n-translate('production',$language,$translations)"/>
   <level1>
      <h1><xsl:value-of select="$about-book"/></h1>
      <p><xsl:value-of select="$copyright-blurb"/></p>
      <xsl:if test="//dtb:meta[lower-case(@name)='prod:source']/@content = 'electronicData'">
        <p><xsl:value-of select="$electronic-data-thanks"/></p>
      </xsl:if>
      <xsl:variable name="year" select="tokenize(//dtb:meta[lower-case(@name)='dc:date']/@content, '-')[1]"/>
      <p><xsl:value-of select="$production"/>:<br/><xsl:value-of select="$electronic-data-thanks"/><br/><a href="{$producer-url}" external="true"><xsl:value-of select="$producer-url-brief"/></a><br/><xsl:value-of select="concat($producer-brief,' ', $year)"/></p>
    </level1>
  </xsl:template>

  <!-- Add boilerplate text before the title page -->
  <xsl:template match="dtb:frontmatter//dtb:level1[@class='titlepage'][1]">
    <xsl:call-template name="boilerplate"/>
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <!-- Copy all other elements and attributes -->
  <xsl:template match="node()|@*">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
