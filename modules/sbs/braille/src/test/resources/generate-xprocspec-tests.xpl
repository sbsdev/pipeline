<?xml version="1.0" encoding="UTF-8"?>
<p:pipeline version="1.0"
            xmlns:p="http://www.w3.org/ns/xproc"
            xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
            type="px:generate-xprocspec-tests"
            exclude-inline-prefixes="#all">
	
	<p:xslt name="xslt">
		<p:input port="stylesheet">
			<p:document href="generate-xprocspec-tests.xsl"/>
		</p:input>
	</p:xslt>
	
</p:pipeline>
