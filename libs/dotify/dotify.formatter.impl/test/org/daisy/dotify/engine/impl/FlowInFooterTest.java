package org.daisy.dotify.engine.impl;

import java.io.IOException;

import org.daisy.dotify.api.engine.LayoutEngineException;
import org.daisy.dotify.api.writer.PagedMediaWriterConfigurationException;

import org.junit.Ignore;
import org.junit.Test;

@SuppressWarnings("javadoc")
public class FlowInFooterTest extends AbstractFormatterEngineTest {
	
	@Test
	public void testFlowInFooter1() throws LayoutEngineException, IOException, PagedMediaWriterConfigurationException {
		testPEF("resource-files/flow-in-footer-1-input.obfl",
		        "resource-files/flow-in-footer-1-expected.pef",
		        false);
	}
	
	@Test
	@Ignore
	public void testFlowInFooterWithMarkerReference() throws LayoutEngineException, IOException, PagedMediaWriterConfigurationException {
		testPEF("resource-files/flow-in-footer-with-marker-reference-input.obfl",
		        "resource-files/flow-in-footer-with-marker-reference-expected.pef",
		        true);
	}
}
