package org.liblouis;

import java.io.File;
import java.io.FilenameFilter;
import java.io.IOException;
import java.util.Collection;

import org.apache.commons.io.FileUtils;
import org.junit.Test;

import static org.apache.commons.io.filefilter.FileFilterUtils.asFileFilter;
import static org.apache.commons.io.filefilter.FileFilterUtils.trueFileFilter;
import static org.junit.Assert.assertEquals;
import static org.liblouis.Utilities.Hyphenation.insertHyphens;

public class TranslatorTest {
	
	@Test
	public void testVersion() {
		assertEquals(
			"3.0.0-alpha1",
			Louis.getLibrary().lou_version());
	}
	
	@Test(expected=CompilationException.class)
	public void testCompileTable() throws Exception {
		new Translator("unexisting_file");
	}
	
	@Test
	public void testToString() throws Exception {
		String tableFile = new File(tablesDir, "foobar.cti").getCanonicalPath();
		Translator translator = new Translator(tableFile);
		assertEquals(
			"Translator{table=" + tableFile + "}",
			translator.toString());
	}
	
	@Test
	public void testTranslate() throws Exception {
		Translator translator = newTranslator("foobar.cti");
		assertEquals(
			"foobar",
			translator.translate("foobar", null, null, null).getBraille());
	}
	
	@Test
	public void testBackTranslate() throws Exception {
		Translator translator = newTranslator("foobar.cti");
		assertEquals("foobar", translator.backTranslate("foobar"));
	}
	
	@Test
	public void testHyphenate() throws Exception {
		Translator hyphenator = newTranslator("foobar.cti,foobar.dic");
		assertEquals(
			"foo-bar",
			insertHyphens("foobar", hyphenator.hyphenate("foobar"), '-', null));
	}
	
	@Test
	public void testTranslateAndHyphenate() throws Exception {
		Translator translator = newTranslator("foobar.cti,foobar.dic");
		String text = "foobar";
		TranslationResult result = translator.translate(text, null, null, byteToInt(translator.hyphenate(text)));
		assertEquals(
				"foo-bar",
				insertHyphens(result.getBraille(), intToByte(result.getInterCharacterAttributes()), '-', null));
	}
	
	@Test
	public void testDisplay() throws Exception {
		Translator translator = newTranslator("foobar.cti");
		assertEquals("foobar", translator.display("⠋⠕⠕⠃⠁⠗"));
	}
	
	@Test
	public void testTypeform() throws Exception {
		Translator translator = newTranslator("foobar.cti");
		assertEquals(
			"/foobar/",
			translator.translate("foobar", new short[]{1,1,1,1,1,1}, null, null).getBraille());
	}
	
	private Translator newTranslator(String tables) throws IOException, CompilationException {
		return new Translator(new File(tablesDir, tables).getCanonicalPath());
	}
	
	private byte[] intToByte(int [] array) {
		byte[] ret = new byte[array.length];
		for (int i = 0; i < ret.length; i++)
			ret[i] = (byte)array[i];
		return ret;
	}
	
	private int[] byteToInt(byte [] array) {
		int[] ret = new int[array.length];
		for (int i = 0; i < ret.length; i++)
			ret[i] = array[i];
		return ret;
	}
	
	private final File tablesDir;

	@SuppressWarnings("unchecked")
	public TranslatorTest() {
		File testRootDir = new File(this.getClass().getResource("/").getPath());
		tablesDir = new File(testRootDir, "tables");
		Louis.setLibraryPath(((Collection<File>)FileUtils.listFiles(
				new File(testRootDir, "../dependency"),
				asFileFilter(new FilenameFilter() {
					public boolean accept(File dir, String fileName) {
						return dir.getName().equals("shared") && fileName.startsWith("liblouis"); }}),
				trueFileFilter())).iterator().next());
	}
}
