import org.daisy.pipeline.junit.AbstractXSpecAndXProcSpecTest;

public class DtbookToOdtTest extends AbstractXSpecAndXProcSpecTest {
	
	@Override
	protected String[] testDependencies() {
		return new String[] {
			pipelineModule("dtbook-to-odt"),
			pipelineModule("odt-utils"),
			pipelineModule("dtbook-utils"),
			pipelineModule("file-utils"),
			// for dtbook-to-odt
			pipelineModule("image-utils"),
		};
	}
}
