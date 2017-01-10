package ch.sbs.pipeline.braille.pef.impl;

import java.io.IOException;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import com.google.common.base.Objects;
import com.google.common.base.Optional;

import org.daisy.braille.api.embosser.EmbosserWriter;
import org.daisy.braille.api.embosser.Contract;
import org.daisy.braille.api.embosser.ContractNotSupportedException;
import org.daisy.braille.api.embosser.FileFormat;
import org.daisy.braille.api.embosser.StandardLineBreaks;
import org.daisy.braille.api.factory.FactoryProperties;
import org.daisy.braille.api.table.BrailleConverter;
import org.daisy.braille.api.table.Table;
import org.daisy.braille.api.table.TableFilter;

import static org.daisy.pipeline.braille.common.util.Locales.parseLocale;
import org.daisy.pipeline.braille.common.Query;
import org.daisy.pipeline.braille.common.Query.MutableQuery;
import static org.daisy.pipeline.braille.common.Query.util.mutableQuery;
import static org.daisy.pipeline.braille.common.Provider.util.dispatch;
import org.daisy.pipeline.braille.pef.FileFormatProvider;
import org.daisy.pipeline.braille.pef.TableProvider;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;
import org.osgi.service.component.annotations.ReferenceCardinality;
import org.osgi.service.component.annotations.ReferencePolicy;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class SBSFileFormat implements FileFormat, FactoryProperties {
	
	private static final String FILE_EXTENSION = ".brl";
	private static final String LINE_BREAK = new StandardLineBreaks(StandardLineBreaks.Type.DEFAULT).getString();
	private static final String TABLE_ID = "http://www.sbs.ch/pipeline/liblouis/tables/sbs.dis";
	private static final TableFilter TABLE_FILTER = new TableFilter() {
		public boolean accept(FactoryProperties object) {
			return TABLE_ID.equals(object.getIdentifier());
		}
	};
	
	private final Table table;
	
	private SBSFileFormat(Table table) {
		if (!TABLE_FILTER.accept(table))
			throw new IllegalArgumentException();
		this.table = table;
	}
	
	public String getIdentifier() {
		return SBSFileFormat.class.getName();
	}
	
	public String getDisplayName() {
		return getIdentifier();
	}
	
	public String getDescription() {
		return "";
	}
	
	public String getFileExtension() {
		return FILE_EXTENSION;
	}
	
	public boolean supports8dot() {
		return false;
	}
	
	public boolean supportsDuplex() {
		return false;
	}
	
	public TableFilter getTableFilter() {
		return TABLE_FILTER;
	}
	
	public boolean supportsTable(Table table) {
		return TABLE_FILTER.accept(table);
	}
	
	public void setFeature(String key, final Object value) {
		throw new IllegalArgumentException("Unsupported feature: " + key);
	}
	
	public Object getFeature(String key) {
		throw new IllegalArgumentException("Unsupported feature: " + key);
	}
	
	public EmbosserWriter newEmbosserWriter(final OutputStream os) {
		final BrailleConverter brailleConverter = table.newBrailleConverter();
		final String charset = brailleConverter.getPreferredCharset().name();
		
		// Initially copied from AbstractEmbosserWriter because it is in a private package
		return new EmbosserWriter() {
			private int rowgap;
			private boolean isOpen = false;
			private boolean isClosed = false;
			private boolean currentDuplex;
			private int currentPage;
			private int charsOnRow;

			@Override
			public void newLine() throws IOException {
				for (int i=0; i<((rowgap / 4)+1); i++) {
					lineFeed();
				}
			}

			@Override
			public void setRowGap(int value) {
				if (value<0) {
					throw new IllegalArgumentException("Non negative integer expected.");
				} else {
					rowgap = value;
				}
			}

			@Override
			public int getRowGap() {
				return rowgap;
			}

			@Override
			public void open(boolean duplex) throws IOException {
				try {
					open(duplex, new Contract.Builder().build());
				} catch (ContractNotSupportedException e) {
					IOException ex = new IOException("Could not open embosser.");
					ex.initCause(e);
					throw ex;
				}
			}

			@Override
			public void open(boolean duplex, Contract contract) throws IOException, ContractNotSupportedException {
				charsOnRow = 0;
				rowgap = 0;
				currentPage = 1;
				isOpen=true;
				currentDuplex = duplex;
			}

			@Override
			public void close() throws IOException {
				isClosed=true;
				isOpen=false;
			}

			@Override
			public void write(String braille) throws IOException {
				if (charsOnRow == 0) {
					os.write(" ".getBytes());
					charsOnRow++;
				}
				os.write(String.valueOf(brailleConverter.toText(braille)).getBytes(charset));
				charsOnRow += braille.length();
			}

			@Override
			public void newPage() throws IOException {
				if (supportsDuplex() && !currentDuplex && (currentPage % 2)==1) {
					formFeed();
				}
				formFeed();
			}

			@Override
			public void newSectionAndPage(boolean duplex) throws IOException {
				if (supportsDuplex() && (currentPage % 2)==1) {
					formFeed();
				}
				newPage();
				currentDuplex = duplex;
			}

			@Override
			public void newVolumeSectionAndPage(boolean duplex) throws IOException {
				newSectionAndPage(duplex);
			}

			@Override
			public boolean isOpen() {
				return isOpen;
			}

			@Override
			public boolean isClosed() {
				return isClosed;
			}

			@Override
			public int getMaxHeight() {
				return Integer.MAX_VALUE;
			}

			@Override
			public int getMaxWidth() {
				return Integer.MAX_VALUE;
			}

			@Override
			public boolean supports8dot() {
				return false;
			}

			@Override
			public boolean supportsAligning() {
				return false;
			}

			@Override
			public boolean supportsDuplex() {
				return true;
			}

			@Override
			public boolean supportsVolumes() {
				return false;
			}
			
			@Override
			public boolean supportsZFolding() {
				return false;
			}
			
			@Override
			public boolean supportsPrintMode(PrintMode mode) {
				return false;
			}
			
			private void lineFeed() throws IOException {
				if (charsOnRow == 0)
					os.write(" ".getBytes());
				os.write(LINE_BREAK.getBytes());
				charsOnRow = 0;
			}
			
			private void formFeed() throws IOException {
				lineFeed();
				os.write("p".getBytes(charset));
				charsOnRow = 1;
				currentPage++;
			}
		};
	}
	
	public Object getProperty(String key) {
		throw new UnsupportedOperationException();
	}
	
	@Override
	public String toString() {
		return Objects.toStringHelper("ch.sbs.pipeline.braille.pef.impl.SBSFileFormat").toString();
	}
	
	@Component(
		name = "ch.sbs.pipeline.braille.pef.impl.SBSFileFormat$Provider",
		service = { FileFormatProvider.class }
	)
	public static class Provider implements FileFormatProvider {
		
		private FileFormat instance;
		private final static Iterable<FileFormat> empty = Optional.<FileFormat>absent().asSet();
		
		public Iterable<FileFormat> get(Query query) {
			final MutableQuery q = mutableQuery(query);
			String id; {
				if (q.containsKey("id"))
					id = q.removeOnly("id").getValue().get();
				else if (q.containsKey("format"))
					id = q.removeOnly("format").getValue().get();
				else
					return empty; }
			if (q.containsKey("locale")) {
				Locale locale = parseLocale(q.removeOnly("locale").getValue().get());
				if (!locale.getLanguage().equals("de"))
					return empty; }
			if (!q.isEmpty())
				return empty;
			if (instance == null) {
				Query tableQuery = mutableQuery().add("id", TABLE_ID);
				for (Table t : tableProvider.get(tableQuery)) {
					instance = new SBSFileFormat(t);
					break; }}
			if (instance.getIdentifier().equals(id))
				return Optional.of(instance).asSet();
			else
				return empty;
		}
		
		private List<TableProvider> tableProviders = new ArrayList<TableProvider>();
		private org.daisy.pipeline.braille.common.Provider<Query,Table> tableProvider = dispatch(tableProviders);
	
		@Reference(
			name = "TableProvider",
			unbind = "removeTableProvider",
			service = TableProvider.class,
			cardinality = ReferenceCardinality.MULTIPLE,
			policy = ReferencePolicy.DYNAMIC
		)
		protected void addTableProvider(TableProvider provider) {
			tableProviders.add(provider);
		}
		
		protected void removeTableProvider(TableProvider provider) {
			tableProviders.remove(provider);
		}
	}
	
	private static final Logger logger = LoggerFactory.getLogger(SBSFileFormat.class);
	
}
