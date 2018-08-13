<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:d="http://www.daisy.org/ns/pipeline/data"
                xmlns:opf="http://www.idpf.org/2007/opf"
                version="2.0">
	
	<xsl:variable name="epub.in.fileset" select="collection()[2]"/>
	
	<xsl:template match="/">
		<d:fileset>
			<xsl:apply-templates select="//opf:manifest/opf:item"/>
		</d:fileset>
	</xsl:template>
	
	<xsl:template match="opf:manifest/opf:item">
		<xsl:variable name="default-href" select="resolve-uri(@href,base-uri(.))"/>
		<xsl:variable name="original-href"
		              select="($epub.in.fileset//d:file[resolve-uri(@href,base-uri(.))=$default-href]/@original-href
		                                       /resolve-uri(.,base-uri(parent::*)),
		                       $default-href)[1]"/>
		<xsl:element name="d:file">
			<xsl:choose>
				<xsl:when test="@media-type='application/xhtml+xml'">
					<xsl:attribute name="href" select="replace($default-href,'^(.+)\.x?html|(.+)$','$1$2_braille.xhtml')"/>
					<xsl:attribute name="default-href" select="$default-href"/>
				</xsl:when>
				<xsl:when test="@media-type='application/smil+xml'">
					<xsl:attribute name="href" select="replace($default-href,'^(.+)\.smil|(.+)$','$1$2_braille.smil')"/>
					<xsl:attribute name="default-href" select="$default-href"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:attribute name="href" select="$default-href"/>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:attribute name="original-href" select="$original-href"/>
			<xsl:sequence select="@media-type"/>
		</xsl:element>
	</xsl:template>
	
</xsl:stylesheet>
