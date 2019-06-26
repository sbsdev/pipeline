<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step version="1.0"
                xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                xmlns:c="http://www.w3.org/ns/xproc-step"
                type="px:process-catalog"
                name="main"
                exclude-inline-prefixes="#all">
	
	<p:input port="source"/>
	
	<p:option name="generatedSourcesDirectory" required="true"/>
	<p:option name="generatedResourcesDirectory" required="true"/>
	<p:option name="moduleName" required="true"/>
	<p:option name="moduleVersion" required="true"/>
	<p:option name="moduleTitle" required="true"/>
	
	<p:xslt name="xslt">
		<p:input port="stylesheet">
			<p:document href="process-catalog.xsl"/>
		</p:input>
		<p:with-param name="generatedSourcesDirectory" select="$generatedSourcesDirectory"/>
		<p:with-param name="generatedResourcesDirectory" select="$generatedResourcesDirectory"/>
		<p:with-param name="moduleName" select="$moduleName"/>
		<p:with-param name="moduleVersion" select="$moduleVersion"/>
		<p:with-param name="moduleTitle" select="$moduleTitle"/>
	</p:xslt>
	<p:sink/>
	
	<p:for-each>
		<p:iteration-source>
			<p:pipe step="xslt" port="secondary"/>
		</p:iteration-source>
		<p:store>
			<p:with-option name="href" select="p:base-uri()"/>
			<p:with-option name="method" select="if (/c:data) then 'text' else 'xml'"/>
		</p:store>
	</p:for-each>
	
</p:declare-step>
