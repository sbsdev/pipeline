package org.daisy.dotify.formatter.impl;

import static java.lang.Math.min;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.NoSuchElementException;
import java.util.Stack;
import java.util.logging.Logger;
import java.util.regex.Pattern;

import org.daisy.dotify.api.formatter.Context;
import org.daisy.dotify.api.formatter.FormattingTypes;
import org.daisy.dotify.api.formatter.Leader;
import org.daisy.dotify.api.formatter.Marker;
import org.daisy.dotify.api.translator.BrailleTranslatorResult;
import org.daisy.dotify.api.translator.Translatable;
import org.daisy.dotify.api.translator.TranslationException;
import org.daisy.dotify.api.translator.UnsupportedMetricException;
import org.daisy.dotify.common.text.StringTools;
import org.daisy.dotify.formatter.impl.UnwriteableAreaInfo.UnwriteableArea;

/**
 * BlockHandler is responsible for breaking blocks of text into rows. BlockProperties
 * such as list numbers, leaders and margins are resolved in the process. The input
 * text is filtered using the supplied StringFilter before breaking into rows, since
 * the length of the text could change.
 * 
 * @author Joel Håkansson
 */
class BlockContentManager extends AbstractBlockContentManager {
	private static final Pattern softHyphenPattern  = Pattern.compile("\u00ad");
	private static final Pattern trailingWsBraillePattern = Pattern.compile("[\\s\u2800]+\\z");

	private final Stack<RowImpl> rows;
	private final CrossReferenceHandler refs;
	private final UnwriteableAreaInfo uai;
	private final int available;
	private final Context context;
	private final Block thisBlock;

	private Leader currentLeader;
	private ListItem item;
	private int forceCount;
	private Map<Integer,UnwriteableArea> unwriteableAreas;
	
	BlockContentManager(Block thisBlock, int flowWidth, Stack<Segment> segments, RowDataProperties rdp, CrossReferenceHandler refs,
	                    UnwriteableAreaInfo uai, Context context, FormatterContext fcontext) {
		super(flowWidth, rdp, fcontext);
		this.refs = refs;
		this.uai = uai;
		this.currentLeader = null;
		this.available = flowWidth - rightMargin.getContent().length();

		this.item = rdp.getListItem();
		
		this.rows = new Stack<>();
		this.context = context;
		this.thisBlock = thisBlock;

		if (thisBlock != null && !"".equals(thisBlock.getIdentifier())) {
			groupIdentifiers.add(thisBlock.getIdentifier());
		}

		calculateRows(segments);
	}
	
	@Override
	public boolean isVolatile() {
		if (super.isVolatile()) {
			return true;
		}
		// the following may not qualify as "volatile" but what matters is the
		// result, namely that the BlockContentManager is recreated
		// this is incorrect, see https://github.com/brailleapps/dotify.formatter.impl/issues/20
		if (uai != null) {
			for (int i = 0; i < getRowCount(); i++) {
				UnwriteableArea newArea = uai.getUnwriteableArea(thisBlock, i);
				UnwriteableArea oldArea = unwriteableAreas == null ? null : unwriteableAreas.get(i);
				if (newArea == null) {
					if (oldArea != null) {
						return true;
					}
				} else if (!newArea.equals(oldArea)) {
					return true;
				}
			}
		}
		return false;
	}
	
	public int getBlockHeight() {
		return getRowCount() + 
				rdp.getOuterSpaceBefore() + rdp.getInnerSpaceBefore() + 
				rdp.getOuterSpaceAfter() + rdp.getInnerSpaceAfter() + 
				(rdp.getLeadingDecoration()!=null?1:0)+
				(rdp.getTrailingDecoration()!=null?1:0);
	}
	
	public boolean isCollapsable() {
		return getRowCount() +
				rdp.getInnerSpaceAfter() +
				rdp.getInnerSpaceBefore() == 0 
				&&
				leftMargin.isSpaceOnly() &&
				rightMargin.isSpaceOnly() &&
				rdp.getLeadingDecoration()==null && rdp.getTrailingDecoration()==null;
	}
	
	private void calculateRows(Stack<Segment> segments) {
		isVolatile = false;
		
		for (Segment s : segments) {
			switch (s.getSegmentType()) {
				case NewLine:
				{
					//flush
					layout(pending, currentLeader);
					pending = new ArrayList<>();
					currentLeader = null;
					currentLeaderMode = null;
					MarginProperties ret = new MarginProperties(leftMargin.getContent()+StringTools.fill(fcontext.getSpaceCharacter(), rdp.getTextIndent()), leftMargin.isSpaceOnly());
					addRow(new RowInfo("", createAndConfigureEmptyNewRow(ret)));
					break;
				}
				case Text:
				{
					TextSegment ts = (TextSegment)s;
					appendToPending(
							Translatable.text(
									fcontext.getConfiguration().isMarkingCapitalLetters()?
									ts.getText():ts.getText().toLowerCase()
									).
							locale(ts.getTextProperties().getLocale()).
							hyphenate(ts.getTextProperties().isHyphenating()).
							attributes(ts.getTextAttribute()).build(),
							ts.getTextProperties().getTranslationMode());
					break;
				}
				case Leader:
				{
					layout(pending, currentLeader);
					pending = new ArrayList<>();
					currentLeader = (Leader)s;
					currentLeaderMode = null;
					break;
				}
				case Reference:
				{
					isVolatile = true;
					PageNumberReferenceSegment rs = (PageNumberReferenceSegment)s;
					Integer page = null;
					if (refs!=null) {
						page = refs.getPageNumber(rs.getRefId());
					}
					//TODO: translate references using custom language?
					if (page==null) {
						appendToPending(Translatable.text("??").locale(null).build(), null);
					} else {
						String txt = "" + rs.getNumeralStyle().format(page);
						appendToPending(Translatable.text(
								fcontext.getConfiguration().isMarkingCapitalLetters()?txt:txt.toLowerCase()
								).locale(null).attributes(rs.getTextAttribute(txt.length())).build(), null);
					}
					break;
				}
				case Evaluate:
				{
					isVolatile = true;
					Evaluate e = (Evaluate)s;
					String txt = e.getExpression().render(context);
					if (!txt.isEmpty()) // Don't create a new row if the evaluated expression is empty
					                    // Note: this could be handled more generally (also for regular text) in layout().
						appendToPending(
								Translatable.text(fcontext.getConfiguration().isMarkingCapitalLetters()?txt:txt.toLowerCase()).
								locale(e.getTextProperties().getLocale()).
								hyphenate(e.getTextProperties().isHyphenating()).
								attributes(e.getTextAttribute(txt.length())).
								build(), 
								null);
					break;
				}
				case Marker:
				{
					Marker marker = (Marker)s;
					if (currentLeader != null || !pending.isEmpty()) {
						pending.add(marker);
					} else if (rows.isEmpty()) {
						groupMarkers.add(marker);
					} else {
						rows.peek().addMarker(marker);
					}
					break;
				}
				case Anchor:
				{
					AnchorSegment anchor = (AnchorSegment)s;
					if (currentLeader != null || !pending.isEmpty()) {
						pending.add(anchor);
					} else if (rows.isEmpty()) {
						groupAnchors.add(anchor.getReferenceID());
					} else {
						rows.peek().addAnchor(anchor.getReferenceID());
					}
					break;
				}
				case Identifier:
				{
					IdentifierSegment identifier = (IdentifierSegment)s;
					if (currentLeader != null || !pending.isEmpty()) {
						pending.add(identifier);
					} else if (rows.isEmpty()) {
						groupIdentifiers.add(identifier.getName());
					} else {
						rows.peek().addIdentifier(identifier.getName());
					}
					break;
				}
			}
		}
		
		layout(pending, currentLeader);
		
		if (rows.size()>0) {
			rows.get(0).addAnchors(0, groupAnchors);
			groupAnchors.clear();
			rows.get(0).addIdentifiers(0, groupIdentifiers);
			groupIdentifiers.clear();
			rows.get(0).addMarkers(0, groupMarkers);
			groupMarkers.clear();
			if (rdp.getUnderlineStyle() != null) {
				int minLeft = flowWidth;
				int minRight = flowWidth;
				for (RowImpl r : rows) {
					int width = r.getChars().length();
					int left = r.getLeftMargin().getContent().length();
					int right = r.getRightMargin().getContent().length();
					int space = flowWidth - width - left - right;
					left += r.getAlignment().getOffset(space);
					right = flowWidth - width - left;
					minLeft = min(minLeft, left);
					minRight = min(minRight, right);
				}
				if (minLeft < leftMargin.getContent().length() || minRight < rightMargin.getContent().length()) {
					throw new RuntimeException("coding error");
				}
				addRow(new RowInfo("",
						new RowImpl(StringTools.fill(fcontext.getSpaceCharacter(), minLeft - leftMargin.getContent().length())
				                    + StringTools.fill(rdp.getUnderlineStyle(), flowWidth - minLeft - minRight),
				                    leftMargin,
				                    rightMargin)));
			}
		}
	}
	
	// List of BrailleTranslatorResult or Marker or AnchorSegment or IdentifierSegment
	private List<Object> pending = new ArrayList<>();
	private String currentLeaderMode = null;
	
	private void appendToPending(Translatable spec, String mode) {
		// use the mode of the first following segment to translate the leader pattern (or
		// the mode of the first preceding segment)
		if (pending.isEmpty()) {
			currentLeaderMode = mode;
		}
		try {
			pending.add(fcontext.getTranslator(mode).translate(spec));
		} catch (TranslationException e) {
			throw new RuntimeException(e);
		}
	}
	
	private void layout(List<Object> pending, Leader leader) {
		if (pending.isEmpty() && leader == null && item == null) {
		} else if (pending.isEmpty()) {
			layout("", null, currentLeaderMode, leader);
		} else {
			layout(new AggregatedBrailleTranslatorResult(pending), currentLeaderMode, leader);
		}
	}

	public int getRowCount() {
		return rows.size();
	}

	@Override
	public Iterator<RowImpl> iterator() {
		return rows.iterator();
	}
	
	private void layout(String c, String locale, String mode, Leader leader) {
		layout(Translatable.text(fcontext.getConfiguration().isMarkingCapitalLetters()?c:c.toLowerCase()).locale(locale).build(), mode, leader);
	}
	
	private void layout(Translatable spec, String mode, Leader leader) {
		try {
			layout(fcontext.getTranslator(mode).translate(spec), mode, leader);
		} catch (TranslationException e) {
			throw new RuntimeException(e);
		}
	}

	private void layout(BrailleTranslatorResult btr, String mode, Leader leader) {
		// process first row, is it a new block or should we continue the current row?
		if (rows.size()==0) {
			// add to left margin
			if (item!=null) { //currentListType!=BlockProperties.ListType.NONE) {
				String listLabel;
				try {
					listLabel = fcontext.getTranslator(mode).translate(Translatable.text(fcontext.getConfiguration().isMarkingCapitalLetters()?item.getLabel():item.getLabel().toLowerCase()).build()).getTranslatedRemainder();
				} catch (TranslationException e) {
					throw new RuntimeException(e);
				}
				if (item.getType()==FormattingTypes.ListStyle.PL) {
					newRow(btr, listLabel, 0, rdp.getBlockIndentParent(), mode, leader);
				} else {
					newRow(btr, listLabel, rdp.getFirstLineIndent(), rdp.getBlockIndent(), mode, leader);
				}
				item = null;
			} else {
				newRow(btr, "", rdp.getFirstLineIndent(), rdp.getBlockIndent(), mode, leader);
			}
		} else {
			newRow(popRow(), btr, rdp.getBlockIndent(), mode, leader);
		}
		while (btr.hasNext()) { //LayoutTools.length(chars.toString())>0
			newRow(btr, "", rdp.getTextIndent(), rdp.getBlockIndent(), mode, null);
		}
		if (btr.supportsMetric(BrailleTranslatorResult.METRIC_FORCED_BREAK)) {
			forceCount += btr.getMetric(BrailleTranslatorResult.METRIC_FORCED_BREAK);
		}
	}
	
	private void newRow(BrailleTranslatorResult chars, String contentBefore, int indent, int blockIndent, String mode, Leader leader) {
		newRow(new RowInfo(getPreText(contentBefore, indent, blockIndent), createAndConfigureEmptyNewRow(leftMargin)), chars, blockIndent, mode, leader);
	}
	
	private String getPreText(String contentBefore, int indent, int blockIndent) {
		int thisIndent = Math.max(
				// There is one known cause for this calculation to become < 0. That is when an ordered list is so long
				// that the number takes up more space than the indent reserved for it.
				// In that case it is probably best to push the content instead of failing altogether.
				indent + blockIndent - StringTools.length(contentBefore),
				0);
		return contentBefore + StringTools.fill(fcontext.getSpaceCharacter(), thisIndent).toString();
	}

	//TODO: check leader functionality
	private void newRow(RowInfo m, BrailleTranslatorResult btr, int blockIndent, String mode, Leader leader) {
		// [margin][preContent][preTabText][tab][postTabText] 
		//      preContentPos ^
		String tabSpace = "";
		boolean rightAlign = false;
		if (leader!=null) {
			rightAlign = leader.getAlignment() == Leader.Alignment.RIGHT;
			int leaderPos = leader.getPosition().makeAbsolute(available);
			int offset = leaderPos-m.preTabPos;
			int align = getLeaderAlign(leader, btr.countRemaining());
			
			if (m.preTabPos>leaderPos || offset - align < 0) { // if tab position has been passed or if text does not fit within row, try on a new row
				addRow(m);
				m = new RowInfo(StringTools.fill(fcontext.getSpaceCharacter(), rdp.getTextIndent()+blockIndent), createAndConfigureEmptyNewRow(m.row.getLeftMargin()));
				//update offset
				offset = leaderPos-m.preTabPos;
			}
			tabSpace = buildLeader(offset - align, mode, leader);
		}
		if (rightAlign) {
			// text following the leader should be kept on the current line
			// allow it to extend into the margin
			int remainingLength = btr.countRemaining();
			String next = btr.nextTranslatedRow(Integer.MAX_VALUE, false);
			if (btr.hasNext())
				throw new RuntimeException(); // should not happen
			if (next.length() != remainingLength)
				Logger.getLogger(this.getClass().getCanonicalName()).warning("Leader alignment not done correctly");
			m.row.setChars(m.preContent + m.preTabText + tabSpace + next);
			m.row.setLeaderSpace(m.row.getLeaderSpace()+tabSpace.length());
			addRow(m);
			if (btr instanceof AggregatedBrailleTranslatorResult) {
				AggregatedBrailleTranslatorResult abtr = ((AggregatedBrailleTranslatorResult)btr);
				abtr.addMarkers(m.row);
				abtr.addAnchors(m.row);
				abtr.addIdentifiers(m.row);
			}
		} else {
			breakNextRow(m, btr, tabSpace);
		}
	}

	private int rowIndex = 0;
	
	private void addRow(RowInfo row) {
		if (row.index != rowIndex) {
			throw new RuntimeException("Coding error");
		}
		row.row.block = thisBlock;
		row.row.positionInBlock = row.index;
		rows.add(row.row);
		if (row.unwriteableArea != null) {
			if (unwriteableAreas == null) {
				unwriteableAreas = new HashMap<>();
			}
			unwriteableAreas.put(row.index, row.unwriteableArea);
		}
		rowIndex++;
	}
	
	private RowInfo popRow() {
		rowIndex--;
		if (unwriteableAreas != null) {
			unwriteableAreas.remove(rowIndex);
		}
		return new RowInfo("", rows.pop(), rowIndex);
	}
	
	private String buildLeader(int len, String mode, Leader leader) {
		if (len > 0) {
			String leaderPattern;
			try {
				leaderPattern = fcontext.getTranslator(mode).translate(Translatable.text(leader.getPattern()).build()).getTranslatedRemainder();
			} catch (TranslationException e) {
				throw new RuntimeException(e);
			}
			return StringTools.fill(leaderPattern, len);
		} else {
			Logger.getLogger(this.getClass().getCanonicalName())
				.fine("Leader position has been passed on an empty row or text does not fit on an empty row, ignoring...");
			return "";
		}
	}

	private void breakNextRow(RowInfo m, BrailleTranslatorResult btr, String tabSpace) {
		int contentLen = StringTools.length(tabSpace) + m.preTabTextLen;
		boolean force = contentLen == 0;
		//don't know if soft hyphens need to be replaced, but we'll keep it for now
		String next = !btr.hasNext() ? "" : softHyphenPattern.matcher(btr.nextTranslatedRow(m.maxLenText - contentLen, force)).replaceAll("");
		if ("".equals(next) && "".equals(tabSpace)) {
			m.row.setChars(m.preContent + trailingWsBraillePattern.matcher(m.preTabText).replaceAll(""));
			addRow(m);
		} else {
			m.row.setChars(m.preContent + m.preTabText + tabSpace + next);
			m.row.setLeaderSpace(m.row.getLeaderSpace()+tabSpace.length());
			addRow(m);
		}
		if (btr instanceof AggregatedBrailleTranslatorResult) {
			AggregatedBrailleTranslatorResult abtr = ((AggregatedBrailleTranslatorResult)btr);
			abtr.addMarkers(m.row);
			abtr.addAnchors(m.row);
			abtr.addIdentifiers(m.row);
		}
	}
	
	private static int getLeaderAlign(Leader leader, int length) {
		switch (leader.getAlignment()) {
			case LEFT:
				return 0;
			case RIGHT:
				return length;
			case CENTER:
				return length/2;
		}
		return 0;
	}
	
	private int rowInfoIndex = 0;
	
	private class RowInfo {
		final String preTabText;
		final int preTabTextLen;
		final String preContent;
		final int preTabPos;
		final int maxLenText;
		final RowImpl row;
		final int index;
		final UnwriteableArea unwriteableArea;
		private RowInfo(String preContent, RowImpl r) {
			this(preContent, r, rowInfoIndex++);
		}
		private RowInfo(String preContent, RowImpl r, int index) {
			this.preTabText = r.getChars();
			this.row = r;
			this.index = index;
			this.preContent = preContent;
			int preContentPos = r.getLeftMargin().getContent().length()+StringTools.length(preContent);
			this.preTabTextLen = StringTools.length(preTabText);
			this.preTabPos = preContentPos+preTabTextLen;
			this.unwriteableArea = uai == null ? null : uai.getUnwriteableArea(thisBlock, this.index);
			int unwriteable; {
				if (unwriteableArea != null) {
					if (unwriteableArea.side == UnwriteableArea.Side.LEFT) {
						throw new RuntimeException();
					}
					unwriteable = unwriteableArea.width;
				} else {
					unwriteable = 0;
				}
			}
			this.maxLenText = available-unwriteable-(preContentPos);
			if (this.maxLenText<1) {
				throw new RuntimeException("Cannot continue layout: No space left for characters.");
			}
		}
	}

	@Override
	int getForceBreakCount() {
		return forceCount;
	}
	
	private static class AggregatedBrailleTranslatorResult implements BrailleTranslatorResult {
		
		private final List<Object> results;
		private int currentIndex = 0;
		
		public AggregatedBrailleTranslatorResult(List<Object> results) {
			this.results = results;
		}

		private static class State {
			final int rowSize;
			final int currentIndex;
			final int pendingMarkersSize;
			final int pendingAnchorsSize;
			final int pendingIdentifiersSize;
			State(int rowSize, int currentIndex, int pendingMarkersSize, int pendingAnchorsSize, int pendingIdentifiersSize) {
				this.rowSize = rowSize;
				this.currentIndex = currentIndex;
				this.pendingMarkersSize = pendingMarkersSize;
				this.pendingAnchorsSize = pendingAnchorsSize;
				this.pendingIdentifiersSize = pendingIdentifiersSize;
			}
			static State save(AggregatedBrailleTranslatorResult btr, String row) {
				return new State(row.length(),
				                 btr.currentIndex,
				                 btr.pendingMarkers.size(),
				                 btr.pendingAnchors.size(),
				                 btr.pendingIdentifiers.size());
			}
			String restore(AggregatedBrailleTranslatorResult btr, String row) {
				row = row.substring(0, rowSize);
				btr.currentIndex = currentIndex;
				btr.pendingMarkers.subList(pendingMarkersSize, btr.pendingMarkers.size()).clear();
				btr.pendingAnchors.subList(pendingAnchorsSize, btr.pendingAnchors.size()).clear();
				btr.pendingIdentifiers.subList(pendingIdentifiersSize, btr.pendingIdentifiers.size()).clear();
				return row;
			}
		}

		private static void failIf(boolean test) {
			if (test) {
				throw new RuntimeException("coding error");
			}
		}

		public String nextTranslatedRow(int limit, boolean force) {
			String row = nextTranslatedRowInner(limit, false);
			if (force && row.isEmpty())
				row = nextTranslatedRowInner(limit, true);
			return row;
		}

		private String nextTranslatedRowInner(int limit, boolean force) {
			String row = "";
			Stack<State> backup = new Stack<>();
			BrailleTranslatorResult current = computeNext();
			if (current == null)
				throw new NoSuchElementException();
			o: while (limit > row.length()) {
				failIf(current == null || !current.hasNext());
				if (current.countRemaining() < limit - row.length()) {
					String remainder = current.getTranslatedRemainder();
					failIf(remainder.isEmpty());
					backup.push(State.save(this, row));
					row += remainder;
					currentIndex++;
					current = computeNext();
					if (current == null) {
						break; // everything fits on a line; return
					} // there is more content; try fitting the next segment
				} else { // segment does not fit on the line, try breaking it
					while (true) {
						String r = current.nextTranslatedRow(limit - row.length(), force);
						if (!r.isEmpty()) {
							row += r;
							break o; // segment was broken; return
						} else if (!current.hasNext()) {
							// The BrailleTranslatorResult wrongly indicated that it had more rows. Not sure whether this is
							// an error? Just ignore for now.
							current = computeNext();
							failIf(current == null); // if everything would fit on a line we would have detected it already
							// there is more content, try breaking the next segment
						} else {
							if (force) {
								throw new RuntimeException("corrupt BrailleTranslatorResult: " + current + ": "
								                           + "hasNext() is true but nextTranslatedRow("+ (limit - row.length()) + ", true)"
								                           + " returns empty string");
							}
							if (backup.isEmpty()) {
								failIf(!row.isEmpty());
								break o; // return empty row
							} else {
								failIf(row.isEmpty());
								row = backup.pop().restore(this, row); // backup to the previous segment
								current = computeNext();
								failIf(current == null);
								// try breaking the previous segment
							}
						}
					}
				}
			}
			if (hasNext()) {
				row = trailingWsBraillePattern.matcher(row).replaceAll("");
			}
			return row;
		}

		private BrailleTranslatorResult computeNext() {
			while (currentIndex < results.size()) {
				Object o = results.get(currentIndex);
				if (o instanceof BrailleTranslatorResult) {
					BrailleTranslatorResult current = ((BrailleTranslatorResult)o);
					if (current.hasNext()) {
						return current;
					}
				} else if (o instanceof Marker) {
					pendingMarkers.add((Marker)o);
				} else if (o instanceof AnchorSegment) {
					pendingAnchors.add((AnchorSegment)o);
				} else if (o instanceof IdentifierSegment) {
					pendingIdentifiers.add((IdentifierSegment)o);
				} else {
					throw new RuntimeException("coding error");
				}
				currentIndex++;
			}
			return null;
		}

		public String getTranslatedRemainder() {
			String remainder = "";
			for (int i = currentIndex; i < results.size(); i++) {
				Object o = results.get(i);
				if (o instanceof BrailleTranslatorResult) {
					remainder += ((BrailleTranslatorResult)o).getTranslatedRemainder();
				}
			}
			return remainder;
		}

		public int countRemaining() {
			int remaining = 0;
			for (int i = currentIndex; i < results.size(); i++) {
				Object o = results.get(i);
				if (o instanceof BrailleTranslatorResult) {
					remaining += ((BrailleTranslatorResult)o).countRemaining();
				}
			}
			return remaining;
		}

		public boolean hasNext() {
			return computeNext() != null;
		}
		
		List<Marker> pendingMarkers = new ArrayList<Marker>();
		private void addMarkers(RowImpl row) {
			for (Marker m : pendingMarkers)
				row.addMarker(m);
			pendingMarkers.clear();
		}

		List<AnchorSegment> pendingAnchors = new ArrayList<AnchorSegment>();
		private void addAnchors(RowImpl row) {
			for (AnchorSegment a : pendingAnchors)
				row.addAnchor(a.getReferenceID());
			pendingAnchors.clear();
		}

		List<IdentifierSegment> pendingIdentifiers = new ArrayList<IdentifierSegment>();
		private void addIdentifiers(RowImpl row) {
			for (IdentifierSegment a : pendingIdentifiers)
				row.addIdentifier(a.getName());
			pendingIdentifiers.clear();
		}

		public boolean supportsMetric(String metric) {
			// since we cannot assume that the individual results of any metric can be added, we only support the following known cases
			if (METRIC_FORCED_BREAK.equals(metric) || METRIC_HYPHEN_COUNT.equals(metric)) {
				for (int i = 0; i <= currentIndex && i < results.size(); i++) {
					Object o = results.get(i);
					if (o instanceof BrailleTranslatorResult) {
						if (!((BrailleTranslatorResult)o).supportsMetric(metric)) {
							return false;
						}
					}
				}
				return true;
			} else {
				return false;
			}
		}

		public double getMetric(String metric) {
			// since we cannot assume that the individual results of any metric can be added, we only support the following known cases
			if (METRIC_FORCED_BREAK.equals(metric) || METRIC_HYPHEN_COUNT.equals(metric)) {
				int count = 0;
				for (int i = 0; i <= currentIndex && i < results.size(); i++) {
					Object o = results.get(i);
					if (o instanceof BrailleTranslatorResult) {
						count += ((BrailleTranslatorResult)o).getMetric(metric);
					}
				}
				return count;
			} else {
				throw new UnsupportedMetricException("Metric not supported: " + metric);
			}
		}
	}
}
