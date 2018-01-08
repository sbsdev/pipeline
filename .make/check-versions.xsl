<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:pom="http://maven.apache.org/POM/4.0.0"
                xpath-default-namespace="http://maven.apache.org/POM/4.0.0">
	
	<xsl:output method="text"/>
	
	<xsl:variable name="effective-pom" select="document('../.effective-pom.xml')/*"/>
	<xsl:variable name="development-versions" select="/*/dependency"/>
	
	<xsl:template match="/">
		<xsl:for-each select="$effective-pom/project">
			<xsl:variable name="groupId" as="xs:string" select="groupId"/>
			<xsl:variable name="artifactId" as="xs:string" select="artifactId"/>
			<xsl:for-each select="parent|
			                      dependencies/dependency|
			                      dependencyManagement/dependencies/dependency">
				<xsl:variable name="development-version" as="element()?"
				              select="$development-versions[string(artifactId)=string(current()/artifactId)
				                                            and string(groupId)=string(current()/groupId)]"/>
				<xsl:if test="exists($development-version)">
					<xsl:if test="not(string($development-version/version)=string(version))">
						<xsl:text>Dependency </xsl:text>
						<xsl:value-of select="groupId"/>
						<xsl:text>:</xsl:text>
						<xsl:value-of select="artifactId"/>
						<xsl:text> of </xsl:text>
						<xsl:value-of select="$groupId"/>
						<xsl:text>:</xsl:text>
						<xsl:value-of select="$artifactId"/>
						<xsl:text> does not match development version: </xsl:text>
						<xsl:value-of select="version"/>
						<xsl:text> &lt;-&gt; </xsl:text>
						<xsl:value-of select="$development-version/version"/>
						<xsl:text>&#x0A;</xsl:text>
					</xsl:if>
				</xsl:if>
			</xsl:for-each>
		</xsl:for-each>
	</xsl:template>
	
</xsl:stylesheet>
