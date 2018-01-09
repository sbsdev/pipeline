package org.daisy.dotify.impl.input.xml;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.net.URISyntaxException;

import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactoryConfigurationError;
import javax.xml.xpath.XPathExpressionException;

import org.daisy.dotify.api.tasks.TaskSystemException;
import org.junit.Test;
import org.xml.sax.SAXException;


public class XMLInputManagerTest {

	@Test
	public void testLists_01() throws IOException, TaskSystemException, URISyntaxException, ParserConfigurationException, SAXException, TransformerConfigurationException, TransformerException, TransformerFactoryConfigurationError, XPathExpressionException {
		File f = TestHelper.toObfl("resource-files/ordered-lists-input.xhtml");
		TestHelper.assertEqualPath(
				this.getClass().getResourceAsStream("resource-files/ordered-lists-expected.xml"),
				new FileInputStream(f),
				TestHelper.getObflTestContext("resource-files/obfl-filter-sequence.xsl"));
	}
	
	@Test
	public void testColophon_01() throws IOException, TaskSystemException, URISyntaxException, ParserConfigurationException, SAXException, TransformerConfigurationException, TransformerException, TransformerFactoryConfigurationError, XPathExpressionException {
		File f = TestHelper.toObfl("resource-files/colophon-input.xhtml", false);
		TestHelper.assertEqualPath(
				this.getClass().getResourceAsStream("resource-files/colophon-expected.xml"),
				new FileInputStream(f),
				TestHelper.getObflTestContext("resource-files/obfl-filter-sequence.xsl"));
	}

}
