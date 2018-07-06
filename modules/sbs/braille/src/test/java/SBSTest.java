import javax.inject.Inject;

import java.io.File;
import java.util.Arrays;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import com.google.common.collect.ImmutableList;
import com.google.common.collect.ImmutableMap;

import org.daisy.dotify.api.text.Integer2TextFactoryMakerService;

import org.daisy.maven.xproc.api.XProcEngine;
import org.daisy.maven.xproc.xprocspec.XProcSpecRunner;
import org.daisy.maven.xspec.TestResults;
import org.daisy.maven.xspec.XSpecRunner;

import org.daisy.pipeline.braille.common.BrailleTranslator.FromStyledTextToBraille;
import org.daisy.pipeline.braille.common.CSSStyledText;
import static org.daisy.pipeline.braille.common.Query.util.query;

import org.daisy.pipeline.junit.AbstractXSpecAndXProcSpecTest;

import static org.daisy.pipeline.pax.exam.Options.mavenBundle;
import static org.daisy.pipeline.pax.exam.Options.thisPlatform;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import org.junit.Test;

import org.ops4j.pax.exam.Configuration;
import org.ops4j.pax.exam.Option;
import org.ops4j.pax.exam.util.PathUtils;

import static org.ops4j.pax.exam.CoreOptions.composite;
import static org.ops4j.pax.exam.CoreOptions.options;
import static org.ops4j.pax.exam.CoreOptions.vmOption;

public class SBSTest extends AbstractXSpecAndXProcSpecTest {
	
	@Inject
	private XProcEngine xprocEngine;
	
	@Inject
	private XSpecRunner xspecRunner;
	
	@Inject
	private XProcSpecRunner xprocspecRunner;
	
	@Override
	public void runXProcSpec() {}
	
	@Override
	public void runXSpec() {}
	
	@Test
	public void runXSpecAndXProcSpec() throws Exception {
		File baseDir = new File(PathUtils.getBaseDir());
		File xspecTestsDir = new File(baseDir, "src/test/xspec");
		File generatedXSpecTestsDir = new File(baseDir, "target/generated-test-sources/xspec");
		String generateXSpecTests = new File(baseDir, "src/test/resources/generate-xspec-tests.xpl").toURI().toASCIIString();
		File xprocspecTestsDir = new File(baseDir, "src/test/xprocspec");
		File generatedXProcSpecTestsDir = new File(baseDir, "target/generated-test-sources/xprocspec");
		String generateXProcSpecTests = new File(baseDir, "src/test/resources/generate-xprocspec-tests.xpl").toURI().toASCIIString();
		Map<String,File> xspecTests = new HashMap<String,File>();
		for (File file : xspecTestsDir.listFiles())
			xspecTests.put(file.getName().replaceAll("\\.xspec$", ""), file);
		Map<String,File> xprocspecTests = new HashMap<String,File>();
		for (String test : new String[]{
			"test_translator",
			"test_epub3-to-pef",
			"test_dtbook-to-pef",
			"test_dtbook-to-pef_downgrade",
			"test_dtbook-to-pef_notes",
			"test_dtbook-to-pef_pagination",
			"test_dtbook-to-pef_print_page_numbers",
			"test_dtbook-to-pef_prodnote",
			"test_dtbook-to-pef_tables",
			"test_dtbook-to-pef_titlepage"
			})
			xprocspecTests.put(test, new File(xprocspecTestsDir, test + ".xprocspec"));
		boolean xspecHasFocus = xspecRunner.hasFocus(xspecTests.values());
		boolean xprocspecHasFocus = xprocspecRunner.hasFocus(xprocspecTests.values());
		List<AssertionError> errors = new ArrayList<AssertionError>();
		if (xspecHasFocus || !xprocspecHasFocus) {
			
			// execute tests a second time via EPUB 3, except if they contain custom CSS (in style attributes)
			Set<String> tests = new HashSet<>(xspecTests.keySet());
			for (String test : tests) {
				File generatedTest = new File(generatedXSpecTestsDir, xspecTests.get(test).getName());
				if (!test.equals("test_block-translate") &&
				    !test.equals("test_handle_downgrading-1") &&
				    !test.equals("test_handle-downgrading-2") &&
				    !test.equals("test_dtbook2sbsform-9") &&
				    !test.equals("test_handle-dl")) {
					xprocEngine.run(generateXSpecTests,
					                ImmutableMap.of("source", (List<String>)ImmutableList.of(xspecTests.get(test).toURI().toASCIIString())),
					                ImmutableMap.of("result", generatedTest.toURI().toASCIIString()),
					                null,
					                ImmutableMap.of("parameters",
					                                (Map<String,String>)ImmutableMap.of("projectBaseDir",
					                                                                    baseDir.toURI().toASCIIString())));
					xspecTests.put(test + "_via_epub3", generatedTest); }}
			File xspecReportsDir = new File(baseDir, "target/surefire-reports");
			xspecReportsDir.mkdirs();
			TestResults result = xspecRunner.run(xspecTests, xspecReportsDir);
			if (result.getFailures() > 0 || result.getErrors() > 0) {
				System.out.println(result.toDetailedString());
				errors.add(new AssertionError("There are XSpec test failures."));
			}
		}
		if (xprocspecHasFocus || !xspecHasFocus) {
			
			// execute tests a second time via EPUB 3, except if they contain custom, DTBook-specific CSS
			Set<String> tests = new HashSet<>(xprocspecTests.keySet());
			for (String test : tests)
				if (!test.equals("test_translator") &&
				    !test.equals("test_epub3-to-pef")) {
					File generatedTest = new File(generatedXProcSpecTestsDir, test + ".xprocspec");
					xprocEngine.run(generateXProcSpecTests,
					                ImmutableMap.of("source", (List<String>)ImmutableList.of(xprocspecTests.get(test).toURI().toASCIIString())),
					                ImmutableMap.of("result", generatedTest.toURI().toASCIIString()),
					                null,
					                null);
					xprocspecTests.put(test + "_via_epub3", generatedTest); }
			File xprocspecReportsDir = new File(baseDir, "target/xprocspec-reports");
			boolean success = xprocspecRunner.run(xprocspecTests,
			                                      xprocspecReportsDir,
			                                      new File(baseDir, "target/surefire-reports"),
			                                      new File(baseDir, "target/xprocspec"),
			                                      null,
			                                      new XProcSpecRunner.Reporter.DefaultReporter());
			if (!success)
				errors.add(new AssertionError("There are XProcSpec test failures."));
		}
		for (AssertionError e : errors)
			throw e;
	}
	
	@Inject
	private Integer2TextFactoryMakerService int2textFactory;
	
	// @Test // XFAIL
	public void testInt2textFactory() throws Exception {
		assertEquals("zwölf", int2textFactory.newInteger2Text("de").intToText(12));
	}
	
	@Override
	protected String[] testDependencies() {
		return new String[]{
			brailleModule("common-utils"),
			brailleModule("css-utils"),
			brailleModule("pef-utils"),
			brailleModule("liblouis-utils"),
			"org.daisy.pipeline.modules.braille:liblouis-native:jar:" + thisPlatform() + ":?",
			brailleModule("libhyphen-core"),
			"org.daisy.pipeline.modules.braille:libhyphen-native:jar:" + thisPlatform() + ":?",
			"ch.sbs.pipeline:sbs-braille-tables:?",
			"ch.sbs.pipeline:sbs-hyphenation-tables:?",
			brailleModule("dotify-utils"),
			brailleModule("dotify-formatter"),
			brailleModule("dtbook-to-pef"),
			brailleModule("epub3-to-pef"),
			pipelineModule("common-utils"),
			pipelineModule("file-utils"),
			pipelineModule("fileset-utils"),
			pipelineModule("epubcheck-adapter"),
			pipelineModule("nordic-epub3-dtbook-migrator"),
			// because of bug in lou_indexTables we need to include liblouis-tables even though
			// we're not using it (needed for include-brf)
			brailleModule("liblouis-tables"),
			// logging
			"org.slf4j:jul-to-slf4j:?",
			"org.daisy.pipeline:logging-activator:?",
			// FIXME: Dotify needs older version of jing
			"org.daisy.libs:jing:20120724.0.0",
		};
	}
	
	@Override @Configuration
	public Option[] config() {
		return options(
			composite(super.config()),
			vmOption("-Xmx8g"),
			// second version of guava needed for epubcheck-adapter
			mavenBundle("com.google.guava:guava:14.0.1"));
	}
	
	private Iterable<CSSStyledText> styledText(String... textAndStyle) {
		List<CSSStyledText> styledText = new ArrayList<CSSStyledText>();
		String text = null;
		boolean textSet = false;
		for (String s : textAndStyle) {
			if (textSet)
				styledText.add(new CSSStyledText(text, s));
			else
				text = s;
			textSet = !textSet; }
		if (textSet)
			throw new RuntimeException();
		return styledText;
	}
	
	private Iterable<CSSStyledText> text(String... text) {
		List<CSSStyledText> styledText = new ArrayList<CSSStyledText>();
		for (String t : text)
			styledText.add(new CSSStyledText(t, ""));
		return styledText;
	}
	
	private Iterable<String> braille(String... text) {
		return Arrays.asList(text);
	}
}
