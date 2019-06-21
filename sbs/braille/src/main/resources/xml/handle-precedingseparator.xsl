<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:dtb="http://www.daisy.org/z3986/2005/dtbook/"
                exclude-result-prefixes="#all">
  
  <!--
      Insert hr.separator before elements with class "precedingseparator"
  -->
  
  <xsl:template match="*[@class]">
    <xsl:choose>
      <xsl:when test="tokenize(@class,'\s+')='precedingseparator'">
        <dtb:hr class="separator"/>
        <xsl:copy>
          <xsl:apply-templates select="@* except @class"/>
          <xsl:variable name="classes" as="xs:string*" select="tokenize(@class,'\s+')[not(.=('','precedingseparator'))]"/>
          <xsl:if test="exists($classes)">
            <xsl:attribute name="class" select="string-join($classes,' ')"/>
          </xsl:if>
          <xsl:apply-templates/>
        </xsl:copy>
      </xsl:when>
      <xsl:otherwise>
        <xsl:next-match/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>
