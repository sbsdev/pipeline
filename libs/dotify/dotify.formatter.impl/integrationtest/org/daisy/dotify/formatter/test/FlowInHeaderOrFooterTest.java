package org.daisy.dotify.formatter.test;

import java.io.IOException;

import org.daisy.dotify.api.engine.LayoutEngineException;
import org.daisy.dotify.api.writer.PagedMediaWriterConfigurationException;
import org.junit.Ignore;
import org.junit.Test;

@SuppressWarnings("javadoc")
public class FlowInHeaderOrFooterTest extends AbstractFormatterEngineTest {
	
	@Test
	public void testFlowInFooter() throws LayoutEngineException, IOException, PagedMediaWriterConfigurationException {
		testPEF("resource-files/flow-in-footer-input.obfl",
		        "resource-files/flow-in-footer-expected.pef",
		        true);
	}
	
	@Test
	public void testFlowInFooterWithMarkerReference() throws LayoutEngineException, IOException, PagedMediaWriterConfigurationException {
		testPEF("resource-files/flow-in-footer-with-marker-reference-input.obfl",
		        "resource-files/flow-in-footer-with-marker-reference-expected.pef",
		        true);
	}
	
	@Test
	public void testFlowInHeader() throws LayoutEngineException, IOException, PagedMediaWriterConfigurationException {
		testPEF("resource-files/flow-in-header-input.obfl",
		        "resource-files/flow-in-header-expected.pef",
		        true);
	}
}
