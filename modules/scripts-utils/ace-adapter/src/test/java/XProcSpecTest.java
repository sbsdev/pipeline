import org.daisy.pipeline.junit.AbstractXSpecAndXProcSpecTest;

public class XProcSpecTest extends AbstractXSpecAndXProcSpecTest {
	
	protected String[] testDependencies() {
		return new String[] {
			pipelineModule("html-utils"),
			pipelineModule("file-utils"),
		};
	}
}
