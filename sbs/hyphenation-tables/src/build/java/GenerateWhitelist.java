import ch.sbs.jhyphen.Hyphen;
import ch.sbs.jhyphen.Hyphenator;

import java.io.File;
import java.io.FilenameFilter;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.io.UnsupportedEncodingException;
import java.io.Writer;
import java.nio.charset.UnsupportedCharsetException;
import java.util.Collection;
import java.util.Stack;

import javax.xml.parsers.ParserConfigurationException;
import javax.xml.parsers.SAXParserFactory;

import org.apache.commons.io.FileUtils;
import static org.apache.commons.io.filefilter.FileFilterUtils.asFileFilter;
import static org.apache.commons.io.filefilter.FileFilterUtils.trueFileFilter;

import org.xml.sax.Attributes;
import org.xml.sax.helpers.DefaultHandler;
import org.xml.sax.SAXException;
import org.xml.sax.XMLReader;

public class GenerateWhitelist {
	
	public static void main(String[] args)
			throws FileNotFoundException, ParserConfigurationException, IOException, SAXException,
			       UnsupportedCharsetException, UnsupportedEncodingException {
		
		File projectHome = new File(new File(GenerateWhitelist.class.getResource("/").getPath()), "../..");
		Hyphen.setLibraryPath(((Collection<File>)FileUtils.listFiles(
				new File(projectHome, "target/dependency"),
				asFileFilter(new FilenameFilter() {
					public boolean accept(File dir, String fileName) {
						return dir.getName().equals("shared") && fileName.startsWith("libhyphen"); }}),
				trueFileFilter())).iterator().next());
		
		File dictionaryNewSpelling = new File(projectHome, "src/main/resources/tables/hyph_de_DE.base.dic");
		File dictionaryOldSpelling = new File(projectHome, "src/main/resources/tables/hyph_de_DE_OLDSPELL.base.dic");
		File trennfehlerGesamtliste = new File(projectHome, "src/main/resources/tables/trennfehler_gesamtliste.xml");
		File whitelistSBS = new File(projectHome, "target/generated-resources/whitelist_de_SBS.txt");
		File whitelistUpstream = new File(projectHome, "target/generated-resources/whitelist_de.txt");
		File whitelistOldSpelling = new File(projectHome, "target/generated-resources/whitelist_de_DE_OLDSPELL.txt");
		
		final Hyphenator hyphenatorNewSpelling = new Hyphenator(dictionaryNewSpelling);
		final Hyphenator hyphenatorOldSpelling = new Hyphenator(dictionaryOldSpelling);
		
		final Writer writerSBS = new OutputStreamWriter(new FileOutputStream(whitelistSBS), "ISO8859-1");
		final Writer writerUpstream = new OutputStreamWriter(new FileOutputStream(whitelistUpstream), "ISO8859-1");
		final Writer writerOldSpelling = new OutputStreamWriter(new FileOutputStream(whitelistOldSpelling), "ISO8859-1");
		
		XMLReader reader = SAXParserFactory.newInstance().newSAXParser().getXMLReader();
		
		reader.setContentHandler(new DefaultHandler() {
			
			Stack<String> elements = new Stack<String>();
			
			String wort = null;
			String liste = null;
			String rechtschreibung = null;
			String ist = null;
			String soll = null;
				
			@Override
			public void startElement(String uri, String localName, String qName, Attributes attributes) throws SAXException {
				elements.push(qName);
				if ("wort".equals(qName))
					liste = attributes.getValue("liste");
			}
			
			@Override
			public void endElement(String uri, String localName, String qName) throws SAXException {
				elements.pop();
			}
			
			@Override
			public void characters(char ch[], int start, int length) throws SAXException {
				String text = new String(ch, start, length);
				if ("ss".equals(elements.peek()))
					wort = text;
				else if ("rs".equals(elements.peek()))
					rechtschreibung = text;
				else if ("so".equals(elements.peek())) {
					soll = text;
					ist = ("ALT".equals(rechtschreibung) ?
					           hyphenatorOldSpelling :
					           hyphenatorNewSpelling
					      ).hyphenate(wort, '-', null);
					if (!ist.equals(soll))
						try {
							("ALT".equals(rechtschreibung) ?
							     writerOldSpelling :
							     "sbs".equals(liste) ?
							         writerSBS :
							         writerUpstream
							).write(soll + "\n");  }
						catch (IOException e) {
							throw new SAXException(e); }}
			}
		});
		
		reader.parse(trennfehlerGesamtliste.toURI().toASCIIString());
		
		writerSBS.close();
		writerUpstream.close();
		writerOldSpelling.close();
		
		hyphenatorNewSpelling.close();
		hyphenatorOldSpelling.close();
		
	}
}
