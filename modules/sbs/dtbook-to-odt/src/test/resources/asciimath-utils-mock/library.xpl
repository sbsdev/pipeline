<?xml version="1.0" encoding="UTF-8"?>
<p:library version="1.0"
           xmlns:p="http://www.w3.org/ns/xproc"
           xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
           xmlns:m="http://www.w3.org/1998/Math/MathML">
	
	<p:declare-step type="px:asciimathml">
		<p:option name="asciimath" required="true"/>
		<p:output port="result" sequence="false" primary="true"/>
		<p:xslt template-name="main">
			<p:input port="source">
				<p:empty/>
			</p:input>
			<p:input port="stylesheet">
				<p:inline>
					<xsl:stylesheet version="2.0"
					                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
					                xmlns="http://www.w3.org/1998/Math/MathML">
						<xsl:param name="asciimath"/>
						<xsl:template name="main">
							<math>
								<semantics>
									<mrow>
										...
									</mrow>
									<annotation encoding="ASCIIMath"><xsl:value-of select="$asciimath"/></annotation>
								</semantics>
							</math>
						</xsl:template>
					</xsl:stylesheet>
				</p:inline>
			</p:input>
			<p:with-param port="parameters" name="asciimath" select="replace($asciimath,'^`|`$','')"/>
		</p:xslt>
	</p:declare-step>
	
</p:library>

