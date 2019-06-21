<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:dtb="http://www.daisy.org/z3986/2005/dtbook/"
                xmlns:brl="http://www.daisy.org/z3986/2009/braille/">
	
	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>
	
	<!--
	    Move brl:volume elements inside preceding level1.
	-->
	
	<xsl:template match="dtb:bodymatter|dtb:rearmatter">
		<xsl:copy>
			<xsl:sequence select="@*"/>
			<xsl:for-each-group select="*" group-starting-with="dtb:level|dtb:level1">
				<xsl:for-each select="current-group()[1]">
					<xsl:if test="not(self::dtb:level or self::dtb:level1)">
						<xsl:message terminate="yes">
							<xsl:text>Unexpected first element </xsl:text>
							<xsl:value-of select="name(.)"/>
							<xsl:text> within bodymatter/rearmatter</xsl:text>
						</xsl:message>
					</xsl:if>
					<xsl:copy>
						<xsl:sequence select="@*"/>
						<xsl:apply-templates/>
						<xsl:for-each select="current-group()[position()&gt;1]">
							<xsl:if test="not(self::brl:volume)">
								<xsl:message terminate="yes">
									<xsl:text>Unexpected element </xsl:text>
									<xsl:value-of select="name(.)"/>
									<xsl:text> within bodymatter/rearmatter</xsl:text>
								</xsl:message>
							</xsl:if>
							<xsl:apply-templates select="."/>
						</xsl:for-each>
					</xsl:copy>
				</xsl:for-each>
			</xsl:for-each-group>
		</xsl:copy>
	</xsl:template>
	
</xsl:stylesheet>
