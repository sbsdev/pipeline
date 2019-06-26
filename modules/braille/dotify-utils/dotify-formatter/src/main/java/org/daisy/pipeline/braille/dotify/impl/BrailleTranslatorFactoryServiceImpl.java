package org.daisy.pipeline.braille.dotify.impl;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.NoSuchElementException;
import java.util.regex.Matcher;

import com.google.common.base.MoreObjects;
import com.google.common.collect.ImmutableList;
import com.google.common.collect.Lists;

import cz.vutbr.web.css.CSSProperty;
import cz.vutbr.web.css.TermInteger;

import org.daisy.braille.css.BrailleCSSProperty.WhiteSpace;
import org.daisy.braille.css.BrailleCSSProperty.WordSpacing;
import org.daisy.braille.css.SimpleInlineStyle;

import org.daisy.dotify.api.translator.BrailleFilter;
import org.daisy.dotify.api.translator.BrailleTranslator;
import org.daisy.dotify.api.translator.BrailleTranslatorFactory;
import org.daisy.dotify.api.translator.BrailleTranslatorFactoryService;
import org.daisy.dotify.api.translator.BrailleTranslatorResult;
import org.daisy.dotify.api.translator.Translatable;
import org.daisy.dotify.api.translator.TranslatableWithContext;
import org.daisy.dotify.api.translator.TranslationException;
import org.daisy.dotify.api.translator.TranslatorConfigurationException;
import org.daisy.dotify.api.translator.TranslatorSpecification;

import org.daisy.pipeline.braille.common.AbstractBrailleTranslator.util.DefaultLineBreaker;
import org.daisy.pipeline.braille.common.BrailleTranslatorProvider;
import org.daisy.pipeline.braille.common.CSSStyledText;
import org.daisy.pipeline.braille.common.Provider;
import static org.daisy.pipeline.braille.common.Provider.util.memoize;
import org.daisy.pipeline.braille.common.Query;
import org.daisy.pipeline.braille.common.Query.Feature;
import org.daisy.pipeline.braille.common.Query.MutableQuery;
import static org.daisy.pipeline.braille.common.Query.util.mutableQuery;
import static org.daisy.pipeline.braille.common.Query.util.query;
import static org.daisy.pipeline.braille.common.Query.util.QUERY;
import static org.daisy.pipeline.braille.common.Provider.util.dispatch;
import static org.daisy.pipeline.braille.dotify.impl.BrailleFilterFactoryImpl.cssStyledTextFromTranslatable;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;
import org.osgi.service.component.annotations.ReferenceCardinality;
import org.osgi.service.component.annotations.ReferencePolicy;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Component(
	name = "org.daisy.pipeline.braille.dotify.impl.BrailleTranslatorFactoryServiceImpl",
	service = { BrailleTranslatorFactoryService.class }
)
public class BrailleTranslatorFactoryServiceImpl implements BrailleTranslatorFactoryService {
	
	private BrailleFilterFactoryImpl filterFactory;
	
	@Reference(
		name = "BrailleFilterFactoryImpl",
		service = BrailleFilterFactoryImpl.class,
		cardinality = ReferenceCardinality.MANDATORY,
		policy = ReferencePolicy.STATIC
	)
	protected void bindBrailleFilterFactoryImpl(BrailleFilterFactoryImpl filterFactory) {
		this.filterFactory = filterFactory;
	}
	
	public void setCreatedWithSPI() {}
	
	@Reference(
		name = "BrailleTranslatorProvider",
		unbind = "unbindBrailleTranslatorProvider",
		service = BrailleTranslatorProvider.class,
		cardinality = ReferenceCardinality.MULTIPLE,
		policy = ReferencePolicy.DYNAMIC
	)
	@SuppressWarnings(
		"unchecked" // safe cast to BrailleTranslatorProvider<BrailleTranslator>
	)
	protected void bindBrailleTranslatorProvider(BrailleTranslatorProvider<?> provider) {
		brailleTranslatorProviders.add((BrailleTranslatorProvider<org.daisy.pipeline.braille.common.BrailleTranslator>)provider);
		logger.debug("Adding BrailleTranslator provider: {}", provider);
	}
	
	protected void unbindBrailleTranslatorProvider(BrailleTranslatorProvider<?> provider) {
		brailleTranslatorProviders.remove(provider);
		brailleTranslatorProvider.invalidateCache();
		logger.debug("Removing BrailleTranslator provider: {}", provider);
	}
	
	private final List<BrailleTranslatorProvider<org.daisy.pipeline.braille.common.BrailleTranslator>> brailleTranslatorProviders
	= new ArrayList<BrailleTranslatorProvider<org.daisy.pipeline.braille.common.BrailleTranslator>>();
	
	private final Provider.util.MemoizingProvider<Query,org.daisy.pipeline.braille.common.BrailleTranslator> brailleTranslatorProvider
	= memoize(dispatch(brailleTranslatorProviders));
	
	public boolean supportsSpecification(String locale, String mode) {
		try {
			factory.newTranslator(locale, mode);
			return true; }
		catch (TranslatorConfigurationException e) {
			return false; }
	}
	
	public Collection<TranslatorSpecification> listSpecifications() {
		return ImmutableList.of();
	}
	
	public BrailleTranslatorFactory newFactory() {
		return factory;
	}
	
	private BrailleTranslatorFactory factory = new BrailleTranslatorFactoryImpl();
	
	/*
	 * Mode for pre-translated text with support for text-level CSS and line
	 * breaking according to CSS. Corresponds with translator query
	 * `(input:braille)(input:text-css)(output:braille)`
	 */
	private final static String PRE_TRANSLATED_MODE = "pre-translated-text-css";
	
	private class BrailleTranslatorFactoryImpl implements BrailleTranslatorFactory {
		public BrailleTranslator newTranslator(String locale, String mode) throws TranslatorConfigurationException {
			if (PRE_TRANSLATED_MODE.equals(mode))
				return new PreTranslatedBrailleTranslator();
			Matcher m = QUERY.matcher(mode);
			if (!m.matches())
				throw new TranslatorConfigurationException();
			Query query = query(mode);
			for (org.daisy.pipeline.braille.common.BrailleTranslator t : brailleTranslatorProvider.get(query))
				return new BrailleTranslatorFromBrailleTranslator(mode, t);
			try {
				MutableQuery q = mutableQuery(query);
				for (Feature f : q.removeAll("input"))
					if (!"text-css".equals(f.getValue().get()))
						throw new NoSuchElementException();
				for (Feature f : q.removeAll("output"))
					if (!"braille".equals(f.getValue().get()))
						throw new NoSuchElementException();
				if (!q.isEmpty())
					throw new NoSuchElementException();
				return new BrailleTranslatorFromBrailleTranslator(mode, NumberBrailleTranslator.getInstance());
			} catch (NoSuchElementException e) {}
			return new BrailleTranslatorFromFilter(mode, filterFactory.newFilter(locale, mode));
		}
	}
	
	public <T> void setReference(Class<T> c, T reference) throws TranslatorConfigurationException {}
	
	/**
	 * BrailleTranslator with <a
	 * href="http://braillespecs.github.io/braille-css/#h3_white-space-processing">white
	 * space processing</a> and <a
	 * href="http://braillespecs.github.io/braille-css/#line-breaking">line
	 * breaking</a> according to braille CSS.
	 *
	 * White space is normalised. Preserved spaces must have been converted to
	 * no-break spaces and preserved line feeds must have been converted to
	 * &lt;obfl:br/&gt;.
	 *
	 * Through setHyphenating() the translator can be made to perform
	 * automatic hyphenation or not. Regardless of this setting, hyphenation
	 * characters (SHY and ZWSP) in the input are always used in line
	 * breaking. These hyphenation characters must have been removed from the
	 * input when no breaking within words is desired at all (hyphens:none).
	 */
	private static class BrailleTranslatorFromFilter implements BrailleTranslator {
		
		private final String mode;
		private final BrailleFilter filter;
		
		private BrailleTranslatorFromFilter(String mode, BrailleFilter filter) {
			this.mode = mode;
			this.filter = filter;
		}
		
		public BrailleTranslatorResult translate(Translatable input) throws TranslationException {
			return new DefaultLineBreaker.LineIterator(filter.filter(input), '\u2800', '\u2824', 1);
		}
		
		public BrailleTranslatorResult translate(TranslatableWithContext input) throws TranslationException {
			return new DefaultLineBreaker.LineIterator(filter.filter(input), '\u2800', '\u2824', 1);
		}
		
		public String getTranslatorMode() {
			return mode;
		}
		
		@Override
		public String toString() {
			return MoreObjects.toStringHelper("o.d.p.b.dotify.impl.BrailleTranslatorFactoryServiceImpl$BrailleTranslatorFromFilter")
				.add("filter", filter)
				.toString();
		}
	}
	
	/**
	 * Same as above but backed by a LineBreakingFromStyledText instead of a BrailleFilter.
	 */
	private static class BrailleTranslatorFromBrailleTranslator implements BrailleTranslator {
		
		final String mode;
		org.daisy.pipeline.braille.common.BrailleTranslator.LineBreakingFromStyledText lineBreakingFromStyledText;
		org.daisy.pipeline.braille.common.BrailleTranslator.FromStyledTextToBraille fromStyledTextToBraille;
		
		private BrailleTranslatorFromBrailleTranslator(
				String mode,
				org.daisy.pipeline.braille.common.BrailleTranslator translator) {
			this.mode = mode;
			try {
				this.lineBreakingFromStyledText = translator.lineBreakingFromStyledText();
				this.fromStyledTextToBraille = null; }
			catch (UnsupportedOperationException e) {
				this.lineBreakingFromStyledText = null;
				this.fromStyledTextToBraille = translator.fromStyledTextToBraille(); }
		}
		
		public BrailleTranslatorResult translate(Translatable input) throws TranslationException {
			if (input.getAttributes() == null && input.isHyphenating() == false) {
				String text = input.getText();
				if ("".equals(text))
					return new DefaultLineBreaker.LineIterator("", '\u2800', '\u2824', 1);
				if (" ".equals(text))
					return new DefaultLineBreaker.LineIterator("\u2800", '\u2800', '\u2824', 1); }
			return translate(cssStyledTextFromTranslatable(input), 0, -1);
		}
		
		public BrailleTranslatorResult translate(TranslatableWithContext input) throws TranslationException {
			List<CSSStyledText> styledText = Lists.newArrayList(cssStyledTextFromTranslatable(input));
			int from = input.getPrecedingText().size();
			int to = from + input.getTextToTranslate().size();
			for (int i = 0; i < styledText.size(); i++)
				if ("??".equals(styledText.get(i).getText())
				    && (styledText.get(i).getStyle() == null || styledText.get(i).getStyle().isEmpty()))
					styledText.set(i, new CSSStyledText("0"));
			return translate(styledText, from, to);
		}
		
		public BrailleTranslatorResult translate(Iterable<CSSStyledText> styledText, int from, int to) throws TranslationException {
			if (lineBreakingFromStyledText != null)
				return lineBreakingFromStyledText.transform(styledText, from, to);
			else {
				List<String> braille = new ArrayList<>();
				Iterator<CSSStyledText> style = styledText.iterator();
				for (String s : fromStyledTextToBraille.transform(styledText)) {
					SimpleInlineStyle st = style.next().getStyle();
					if (st != null) {
						CSSProperty ws = st.getProperty("white-space");
						if (ws != null) {
							if (ws == WhiteSpace.PRE_WRAP)
								s = s.replaceAll("[\\x20\t\\u2800]", "\u00A0").replaceAll("[\\n\\r]", "\u2028");
							else if (ws == WhiteSpace.PRE_LINE)
								s = s.replaceAll("[\\n\\r]", "\u2028");
							st.removeProperty("white-space"); }}
					braille.add(s);
				}
				StringBuilder brailleString = new StringBuilder();
				int fromChar = 0;
				int toChar = to >= 0 ? 0 : -1;
				for (String s : braille) {
					brailleString.append(s);
					if (--from == 0)
						fromChar = brailleString.length();
					if (--to == 0)
						toChar = brailleString.length();
				}
				return new DefaultLineBreaker.LineIterator(brailleString.toString(), fromChar, toChar, '\u2800', '\u2824', 1);
			}
		}
		
		public String getTranslatorMode() {
			return mode;
		}
	}
	
	/**
	 * Same as above but assumes that input text exists of only braille and
	 * white space characters. Supports CSS property "word-spacing".
	 */
	private static class PreTranslatedBrailleTranslator implements BrailleTranslator {
		
		private PreTranslatedBrailleTranslator() {}
		
		public BrailleTranslatorResult translate(Translatable input) throws TranslationException {
			return translate(cssStyledTextFromTranslatable(input), 0, -1);
		}
			
		public BrailleTranslatorResult translate(TranslatableWithContext input) throws TranslationException {
			int from = input.getPrecedingText().size();
			int to = from + input.getTextToTranslate().size();
			return translate(cssStyledTextFromTranslatable(input), from, to);
		}
		
		private BrailleTranslatorResult translate(Iterable<CSSStyledText> input, int from, int to) throws TranslationException {
			List<String> braille = new ArrayList<>();
			int wordSpacing; {
				wordSpacing = -1;
				for (CSSStyledText styledText : input) {
					SimpleInlineStyle style = styledText.getStyle();
					int spacing = 1;
					if (style != null) {
						CSSProperty val = style.getProperty("word-spacing");
						if (val != null) {
							if (val == WordSpacing.length) {
								spacing = style.getValue(TermInteger.class, "word-spacing").getIntValue();
								if (spacing < 0) {
									if (logger != null)
										logger.warn("word-spacing: {} not supported, must be non-negative", val);
									spacing = 1; }}
									
							// FIXME: assuming style is mutable and text.iterator() does not create copies
							style.removeProperty("word-spacing"); }
						for (String prop : style.getPropertyNames())
							logger.warn("CSS property {} not supported", style.getSourceDeclaration(prop)); }
					if (wordSpacing < 0)
						wordSpacing = spacing;
					else if (wordSpacing != spacing)
						throw new RuntimeException("word-spacing must be constant, but both "
						                           + wordSpacing + " and " + spacing + " specified");
					Map<String,String> attrs = styledText.getTextAttributes();
					if (attrs != null)
						for (String k : attrs.keySet())
							logger.warn("Text attribute \"{}:{}\" ignored", k, attrs.get(k));
					braille.add(styledText.getText()); }
				if (wordSpacing < 0) wordSpacing = 1; }
			StringBuilder brailleString = new StringBuilder();
			int fromChar = 0;
			int toChar = to >= 0 ? 0 : -1;
			for (String s : braille) {
				brailleString.append(s);
				if (--from == 0)
					fromChar = brailleString.length();
				if (--to == 0)
					toChar = brailleString.length();
			}
			return new DefaultLineBreaker.LineIterator(brailleString.toString(), fromChar, toChar, '\u2800', '\u2824', wordSpacing);
		}
		
		public String getTranslatorMode() {
			return PRE_TRANSLATED_MODE;
		}
	}
	
	private static final Logger logger = LoggerFactory.getLogger(BrailleTranslatorFactoryServiceImpl.class);
}
