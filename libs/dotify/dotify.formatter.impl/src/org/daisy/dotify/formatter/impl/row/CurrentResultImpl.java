package org.daisy.dotify.formatter.impl.row;

import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.Optional;
import java.util.regex.Pattern;

import org.daisy.dotify.api.formatter.FormattingTypes;
import org.daisy.dotify.api.formatter.Leader;
import org.daisy.dotify.api.translator.BrailleTranslatorResult;
import org.daisy.dotify.api.translator.Translatable;
import org.daisy.dotify.api.translator.TranslationException;
import org.daisy.dotify.common.text.StringTools;

class CurrentResultImpl implements CurrentResult {
	private static final Pattern softHyphenPattern  = Pattern.compile("\u00ad");
	private static final Pattern trailingWsBraillePattern = Pattern.compile("[\\s\u2800]+\\z");
	private final SegmentProcessorContext spc;
	private final BrailleTranslatorResult btr;
	private final String mode;
	private boolean first;
	
	private static final Logger logger = Logger.getLogger(CurrentResultImpl.class.getCanonicalName());
	
	CurrentResultImpl(SegmentProcessorContext spc, BrailleTranslatorResult btr, String mode) {
		this.spc = spc;
		this.btr = btr;
		this.mode = mode;
		this.first = true;
	}
	
	private CurrentResultImpl(CurrentResultImpl template) {
		this.spc = template.spc;
		this.btr = template.btr.copy();
		this.mode = template.mode;
		this.first = template.first;
	}

	@Override
	public CurrentResult copy() {
		return new CurrentResultImpl(this);
	}

	@Override
	public boolean hasNext(SegmentProcessing spi) {
		return first || btr.hasNext();
	}

	@Override
	public Optional<RowImpl> process(SegmentProcessing spi, LineProperties lineProps) {
		if (first) {
			first = false;
			return processFirst(spi, lineProps);
		}
		try {
			if (btr.hasNext()) { //LayoutTools.length(chars.toString())>0
				if (spi.hasCurrentRow()) {
					return Optional.of(spi.flushCurrentRow());
				}
				return startNewRow(spi, btr, "", spc.getRdp().getTextIndent(), spc.getRdp().getBlockIndent(), mode, lineProps);
			}
		} finally {
			if (!btr.hasNext() && btr.supportsMetric(BrailleTranslatorResult.METRIC_FORCED_BREAK)) {
				spi.addToForceCount(btr.getMetric(BrailleTranslatorResult.METRIC_FORCED_BREAK));
			}
		}
		return Optional.empty();
	}

	private Optional<RowImpl> processFirst(SegmentProcessing spi, LineProperties lineProps) {
		// process first row, is it a new block or should we continue the current row?
		if (!spi.hasCurrentRow()) {
			// add to left margin
			if (spi.hasListItem()) { //currentListType!=BlockProperties.ListType.NONE) {
				ListItem item = spi.getListItem();
				String listLabel;
				try {
					listLabel = spc.getFormatterContext().getTranslator(mode).translate(Translatable.text(spc.getFormatterContext().getConfiguration().isMarkingCapitalLetters()?item.getLabel():item.getLabel().toLowerCase()).build()).getTranslatedRemainder();
				} catch (TranslationException e) {
					throw new RuntimeException(e);
				}
				try {
					if (item.getType()==FormattingTypes.ListStyle.PL) {
						return startNewRow(spi, btr, listLabel, 0, spc.getRdp().getBlockIndentParent(), mode, lineProps);
					} else {
						return startNewRow(spi, btr, listLabel, spc.getRdp().getFirstLineIndent(), spc.getRdp().getBlockIndent(), mode, lineProps);
					}
				} finally {
					spi.discardListItem();
				}
			} else {
				return startNewRow(spi, btr, "", spc.getRdp().getFirstLineIndent(), spc.getRdp().getBlockIndent(), mode, lineProps);
			}
		} else {
			return continueRow(spi, new RowInfo("", spc.getAvailable()-lineProps.getReservedWidth()), btr, spc.getRdp().getBlockIndent(), mode, lineProps);
		}
	}
	
	private Optional<RowImpl> startNewRow(SegmentProcessing spi, BrailleTranslatorResult chars, String contentBefore, int indent, int blockIndent, String mode, LineProperties lineProps) {
		if (spi.hasCurrentRow()) {
			throw new RuntimeException("Error in code.");
		}
		spi.newCurrentRow(spc.getMargins().getLeftMargin(), spc.getMargins().getRightMargin());
		return continueRow(spi, new RowInfo(getPreText(contentBefore, indent+blockIndent), spc.getAvailable()-lineProps.getReservedWidth()), chars, blockIndent, mode, lineProps);
	}
	
	private String getPreText(String contentBefore, int totalIndent) {
		int thisIndent = Math.max(
				// There is one known cause for this calculation to become < 0. That is when an ordered list is so long
				// that the number takes up more space than the indent reserved for it.
				// In that case it is probably best to push the content instead of failing altogether.
				totalIndent - StringTools.length(contentBefore),
				0);
		return contentBefore + StringTools.fill(spc.getSpaceCharacter(), thisIndent);
	}

	//TODO: check leader functionality
	private Optional<RowImpl> continueRow(SegmentProcessing spi, RowInfo m1, BrailleTranslatorResult btr, int blockIndent, String mode, LineProperties lineProps) {
		RowImpl ret = null;
		// [margin][preContent][preTabText][tab][postTabText] 
		//      preContentPos ^
		String tabSpace = "";
		boolean rightAlign = false;
		if (spi.getLeaderManager().hasLeader()) {
			rightAlign = spi.getLeaderManager().getCurrentLeader().getAlignment() == Leader.Alignment.RIGHT;
			int preTabPos = m1.getPreTabPosition(spi.getCurrentRow());
			int leaderPos = spi.getLeaderManager().getLeaderPosition(spc.getAvailable()-lineProps.getReservedWidth());
			int offset = leaderPos-preTabPos;
			int align = spi.getLeaderManager().getLeaderAlign(btr.countRemaining());
			
			if (preTabPos>leaderPos || offset - align < 0) { // if tab position has been passed or if text does not fit within row, try on a new row
				MarginProperties _leftMargin = spi.getCurrentRow().getLeftMargin();
				if (spi.hasCurrentRow()) {
					ret = spi.flushCurrentRow();
				}
				spi.newCurrentRow(_leftMargin, spc.getMargins().getRightMargin());
				m1 = new RowInfo(getPreText("", spc.getRdp().getTextIndent()+blockIndent), spc.getAvailable()-lineProps.getReservedWidth());
				//update offset
				offset = leaderPos-m1.getPreTabPosition(spi.getCurrentRow());
			}
			try {
				tabSpace = spi.getLeaderManager().getLeaderPattern(spc.getFormatterContext().getTranslator(mode), offset - align);
			} finally {
				// always discard leader
				spi.getLeaderManager().removeLeader();
			}
		}
		if (rightAlign) {
			// text following the leader should be kept on the current line
			// allow it to extend into the margin
			int remainingLength = btr.countRemaining();
			String next = btr.nextTranslatedRow(Integer.MAX_VALUE, false, false);
			if (btr.hasNext())
				throw new RuntimeException(); // should not happen
			if (next.length() != remainingLength)
				logger.log(Level.WARNING, "Leader alignment not done correctly");
			RowImpl.Builder row = spi.getCurrentRow();
			row.text(m1.getPreContent() + row.getText() + tabSpace + next);
			row.leaderSpace(row.getLeaderSpace() + tabSpace.length());
			if (btr instanceof AggregatedBrailleTranslatorResult) {
				AggregatedBrailleTranslatorResult abtr = ((AggregatedBrailleTranslatorResult)btr);
				row.addMarkers(abtr.getMarkers());
				row.addAnchors(abtr.getAnchors());
				row.addIdentifiers(abtr.getIdentifiers());
				abtr.clearPending();
			}
		} else {
			breakNextRow(m1, spi.getCurrentRow(), btr, tabSpace, lineProps.suppressHyphenation());
		}
		return Optional.ofNullable(ret);
	}

	private void breakNextRow(RowInfo m1, RowImpl.Builder row, BrailleTranslatorResult btr, String tabSpace, boolean wholeWordsOnly) {
		int contentLen = StringTools.length(tabSpace) + StringTools.length(row.getText());
		boolean force = contentLen == 0;
		//don't know if soft hyphens need to be replaced, but we'll keep it for now
		String next = softHyphenPattern.matcher(btr.nextTranslatedRow(m1.getMaxLength(row) - contentLen, force, wholeWordsOnly)).replaceAll("");
		if ("".equals(next) && "".equals(tabSpace)) {
			row.text(m1.getPreContent() + trailingWsBraillePattern.matcher(row.getText()).replaceAll(""));
		} else {
			row.text(m1.getPreContent() + row.getText() + tabSpace + next);
			row.leaderSpace(row.getLeaderSpace()+tabSpace.length());
		}
		if (btr instanceof AggregatedBrailleTranslatorResult) {
			AggregatedBrailleTranslatorResult abtr = ((AggregatedBrailleTranslatorResult)btr);
			row.addMarkers(abtr.getMarkers());
			row.addAnchors(abtr.getAnchors());
			row.addIdentifiers(abtr.getIdentifiers());
			abtr.clearPending();
		}
	}
}
