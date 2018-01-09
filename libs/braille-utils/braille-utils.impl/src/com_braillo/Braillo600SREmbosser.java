package com_braillo;

import org.daisy.braille.api.factory.FactoryProperties;
import org.daisy.braille.api.paper.PageFormat;
import org.daisy.braille.api.paper.Paper;
import org.daisy.braille.api.table.TableCatalogService;

/**
 * Provides an Embosser for Braillo 600SR. This printer
 * is based on the Braillo 400S with the same well-proven technology.
 * 
 * @author alra
 *
 */
public class Braillo600SREmbosser extends AbstractBraillo200Embosser {

	/**
	 * 
	 */
	private static final long serialVersionUID = 9203292206020512779L;

	/**
	 * 
	 * @param service
	 * @param props
	 */
	public Braillo600SREmbosser(TableCatalogService service, FactoryProperties props) {
		super(service, props);
	}

	@Override
	public boolean supportsPageFormat(PageFormat pageFormat) {
		return pageFormat.getPageFormatType() == PageFormat.Type.ROLL
				&& pageFormat.asTractorPaperFormat().getLengthAcrossFeed().asMillimeter() >= 140
				&& pageFormat.asTractorPaperFormat().getLengthAcrossFeed().asMillimeter() <= 330
				&& pageFormat.asTractorPaperFormat().getLengthAlongFeed().asInches() >= 4
				&& pageFormat.asTractorPaperFormat().getLengthAlongFeed().asInches() <= 14;
	}

	@Override
	public boolean supportsPaper(Paper paper) {
		return paper.getType() == Paper.Type.ROLL 
				&& paper.asRollPaper().getLengthAcrossFeed().asMillimeter() >= 140
				&& paper.asRollPaper().getLengthAcrossFeed().asMillimeter() <= 330;
	}
}