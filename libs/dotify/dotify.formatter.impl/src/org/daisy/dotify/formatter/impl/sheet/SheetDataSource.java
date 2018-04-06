package org.daisy.dotify.formatter.impl.sheet;

import java.util.ArrayList;
import java.util.function.Consumer;
import java.util.List;
import java.util.NoSuchElementException;
import java.util.Optional;

import org.daisy.dotify.api.formatter.TransitionBuilderProperties.ApplicationRange;
import org.daisy.dotify.api.writer.SectionProperties;
import org.daisy.dotify.common.splitter.SplitPointDataSource;
import org.daisy.dotify.common.splitter.Supplements;
import org.daisy.dotify.formatter.impl.core.FormatterContext;
import org.daisy.dotify.formatter.impl.core.TransitionContent;
import org.daisy.dotify.formatter.impl.datatype.VolumeKeepPriority;
import org.daisy.dotify.formatter.impl.page.BlockSequence;
import org.daisy.dotify.formatter.impl.page.PageImpl;
import org.daisy.dotify.formatter.impl.page.PageSequenceBuilder2;
import org.daisy.dotify.formatter.impl.page.PageStruct;
import org.daisy.dotify.formatter.impl.page.RestartPaginationException;
import org.daisy.dotify.formatter.impl.search.CrossReferenceHandler;
import org.daisy.dotify.formatter.impl.search.DefaultContext;
import org.daisy.dotify.formatter.impl.search.DocumentSpace;
import org.daisy.dotify.formatter.impl.search.PageDetails;
import org.daisy.dotify.formatter.impl.search.PageId;
import org.daisy.dotify.formatter.impl.search.TransitionProperties;
import org.daisy.dotify.formatter.impl.search.SheetIdentity;

/**
 * Provides a data source for sheets. Given a list of 
 * BlockSequences, sheets are produced one by one.
 * 
 * @author Joel Håkansson
 */
public class SheetDataSource implements SplitPointDataSource<Sheet> {
	//Global state
	private final FormatterContext context;
	//Input data
	private PageStruct struct;
	private DefaultContext initialContext;
	private final Integer volumeGroup;
	private final List<BlockSequence> seqsIterator;
	//Local state
	private int seqsIndex;
	private PageSequenceBuilder2 psb;
	private SectionProperties sectionProperties;
	private int sheetIndex;
	private int pageIndex;
	private String counter;
	private int initialPageOffset;
	private boolean volBreakAllowed;
	private boolean updateCounter;
	private boolean allowsSplit;
	private boolean wasSplitInsideSequence;
	private boolean volumeEnded;
	//Output buffer
	private List<Sheet> sheetBuffer;
	private int bufferIndex;

	public SheetDataSource(FormatterContext context, Integer volumeGroup, List<BlockSequence> seqsIterator) {
		this.context = context;
		this.volumeGroup = volumeGroup;
		this.seqsIterator = seqsIterator;
		this.sheetBuffer = new ArrayList<>();
		this.bufferIndex = 0;
		this.volBreakAllowed = true;
		this.seqsIndex = 0;
		this.psb = null;
		this.sectionProperties = null;
		this.sheetIndex = 0;
		this.pageIndex = 0;
		this.counter = null;
		this.initialPageOffset = 0;
		this.updateCounter = false;
		this.allowsSplit = true;
		this.wasSplitInsideSequence = false;
		this.volumeEnded = false;
		// initialized later
		this.struct = null;
		this.initialContext = null;
	}

	// FIXME: original function had "tail" argument which was different when a normal copy
	// was made and when it was the remainder of a split
	// - in case of "struct", the goal was to mutate the objects that were originally passed (~= callback with side effect)
	// - in case of "updateCounter", the goal was to execute some code at the first line after the break
	
	// - in case of "psb", the goal was to ...?

	/**
	 * Creates a deep copy of template
	 *
	 * @param template the template
	 */
	private SheetDataSource(SheetDataSource template) {
		this.struct = template.struct;
		this.context = template.context;
		this.initialContext = template.initialContext;
		this.volumeGroup = template.volumeGroup;
		this.seqsIterator = template.seqsIterator;
		this.seqsIndex = template.seqsIndex;
		this.psb = PageSequenceBuilder2.copyUnlessNull(template.psb);
		this.sectionProperties = template.sectionProperties;
		this.sheetIndex = template.sheetIndex;
		this.pageIndex = template.pageIndex;
		this.sheetBuffer = new ArrayList<>(template.sheetBuffer);
		this.bufferIndex = template.bufferIndex;
		this.volBreakAllowed = template.volBreakAllowed;
		this.counter = template.counter;
		this.initialPageOffset = template.initialPageOffset;
		this.updateCounter = template.updateCounter;
		this.allowsSplit = template.allowsSplit;
		this.wasSplitInsideSequence = template.wasSplitInsideSequence;
		this.volumeEnded = template.volumeEnded;
	}

	// FIXME: make immutable
	public void initialize(PageStruct struct, DefaultContext rcontext) {
		this.struct = struct;
		this.initialContext = rcontext;
	}

	private void checkInitialized() {
		if (struct == null || initialContext == null)
			throw new IllegalStateException("Not initialized yet");
	}

	PageStruct getPageStruct() {
		checkInitialized();
		return struct;
	}

	public DefaultContext getContext() {
		checkInitialized();
		if (psb == null)
			return initialContext;
		else
			return psb.getContext();
	}

	private void modifyStruct(Consumer<PageStruct.Builder> modifier) {
		PageStruct.Builder b = struct.builder();
		modifier.accept(b);
		struct = b.build();
	}

	public void modifyRefs(Consumer<CrossReferenceHandler.Builder> modifier) {
		if (psb == null) {
			DefaultContext.Builder b = initialContext.builder();
			modifier.accept(b.getRefs());
			initialContext = b.build();
		} else
			psb.modifyRefs(modifier);
	}

	@Override
	public Supplements<Sheet> getSupplements() {
		return null;
	}
	
	@Override
	public boolean isEmpty() {
		checkInitialized();
		return seqsIndex>=seqsIterator.size() && bufferIndex >= sheetBuffer.size() && (psb==null || !psb.hasNext());
	}
	
	@Override
	public Iterator<Sheet> iterator() {
		checkInitialized();
		return new SheetDataSource(this).asIterator();
	}
	
	private Iterator<Sheet> asIterator() {
		return new SheetDataSourceIterator();
	}
	
	public int countRemainingSheets(/*float position*/) {
		int count = 0;
		for (Iterator<Sheet> it = iterator(); it.hasNext();) {
			it.next(/*position + count,*/false);
			count++;
		}
		return count;
	}

	public int countRemainingPages(/*float position*/) {
		int pages = 0;
		for (Iterator<Sheet> it = iterator(); it.hasNext();) {
			pages += it.next(/*position++,*/false).getPages().size();
		}
		return pages;
	}

	private class SheetDataSourceIterator implements Iterator<Sheet> {

		@Override
		public boolean hasNext() {
			return seqsIndex < seqsIterator.size() || bufferIndex < sheetBuffer.size() || (psb != null && psb.hasNext());
		}

		@Override
		public Sheet next(/*float position,*/ boolean last) throws RestartPaginationException {
			if (last && !allowsSplit) {
				throw new IllegalStateException();
			}
			allowsSplit = false;
			if (ensureBuffer(bufferIndex + 1)) {
				if (last) {
					if (counter!=null) {
						modifyRefs(refs -> refs.setPageNumberOffset(counter, initialPageOffset + psb.getSizeLast()));
					} else {
						modifyStruct(str -> str.setDefaultPageOffset(initialPageOffset + psb.getSizeLast()));
					}
					wasSplitInsideSequence = psb.hasNext();
					allowsSplit = true;
					updateCounter = true;
					volumeEnded = false;
				}
				return sheetBuffer.get(bufferIndex++);
			} else {
				throw new NoSuchElementException();
			}
		}

		@Override
		public SheetDataSource iterable() {
			return new SheetDataSource(SheetDataSource.this);
		}

		/**
		 * Ensures that there are at least index elements in the buffer.
		 * When index is -1 this method always returns false.
		 * @param index the index (or -1 to get all remaining elements)
		 * @return returns true if the index element was available, false otherwise
		 */
		private boolean ensureBuffer(int index) {
			Sheet.Builder s = null;
			SheetIdentity si = null;
			while (index<0 || sheetBuffer.size()<index) {
				if (updateCounter) { 
					if(counter!=null) {
						initialPageOffset = getContext().getRefs().getPageNumberOffset(counter) - psb.size();
					} else {
						initialPageOffset = struct.getDefaultPageOffset() - psb.size();
					}
					updateCounter = false;
				}
				if (psb==null || !psb.hasNext()) {
					if (s!=null) {
						//Last page in the sequence doesn't need volume keep priority
						sheetBuffer.add(s.build());
						s=null;
						continue;
					}
					if (seqsIndex>=seqsIterator.size()) {
						// cannot ensure buffer, return false
						return false;
					}
					// init new sequence
					BlockSequence bs = seqsIterator.get(seqsIndex);
					seqsIndex++;
					counter = bs.getSequenceProperties().getPageCounterName().orElse(null);
					if (bs.getInitialPageNumber()!=null) {
						 initialPageOffset = bs.getInitialPageNumber() - 1;
					} else if (counter!=null) {
						initialPageOffset = Optional.ofNullable(getContext().getRefs().getPageNumberOffset(counter)).orElse(0);
					} else {
						 initialPageOffset = struct.getDefaultPageOffset();
					}
					psb = new PageSequenceBuilder2(struct.getPageCount(), bs.getLayoutMaster(), initialPageOffset, bs, context, getContext(), seqsIndex);
					sectionProperties = bs.getLayoutMaster().newSectionProperties();
					s = null;
					si = null;
					sheetIndex = 0;
					pageIndex = 0;
				}
				int currentSize = sheetBuffer.size();
				while (psb.hasNext() && currentSize == sheetBuffer.size()) {
					if (!sectionProperties.duplex() || pageIndex % 2 == 0 || volumeEnded || s==null) {
						if (s!=null) {
							Sheet r = s.build();
							sheetBuffer.add(r);
							s = null;
							if (volumeEnded) {
								pageIndex += pageIndex%2==1?1:0;
							}
							continue;
						} else if (volumeEnded) {
							throw new AssertionError("Error in code.");
						}
						volBreakAllowed = true;
						s = new Sheet.Builder(sectionProperties);
						si = new SheetIdentity(getContext().getSpace(), getContext().getCurrentVolume(), volumeGroup, sheetBuffer.size());
						sheetIndex++;
					}
	
					TransitionContent transition = null;
					if (context.getTransitionBuilder().getProperties().getApplicationRange()!=ApplicationRange.NONE) {
						if (!allowsSplit && index-1==sheetBuffer.size()) {
							if ((!sectionProperties.duplex() || pageIndex % 2 == 1)) {
								transition = context.getTransitionBuilder().getInterruptTransition();
							} else if (context.getTransitionBuilder().getProperties().getApplicationRange()==ApplicationRange.SHEET) {
								// This id is the same id as the one created below in the call to nextPage
								PageId thisPageId = psb.nextPageId(0);
								// This gets the page details for the next page in this sequence (if any)
								Optional<PageDetails> next = getContext().getRefs().findNextPageInSequence(thisPageId);
								// If there is a page details in this sequence and volume break is preferred on this page
								if (next.isPresent()) {
									TransitionProperties st = getContext().getRefs().getTransitionProperties(thisPageId);
									double v1 = st.getVolumeKeepPriority().orElse(10) + (st.hasBlockBoundary()?0.5:0);
									st = getContext().getRefs().getTransitionProperties(next.get().getPageId());
									double v2 = st.getVolumeKeepPriority().orElse(10) + (st.hasBlockBoundary()?0.5:0);
									if (v1>v2) {
										//break here
										transition = context.getTransitionBuilder().getInterruptTransition();
									}
								}
							}
							volumeEnded = transition!=null;
						} else if (wasSplitInsideSequence && sheetBuffer.size()==0  && (!sectionProperties.duplex() || pageIndex % 2 == 0)) {
							transition = context.getTransitionBuilder().getResumeTransition();
						}
					}
					boolean hyphenateLastLine = 
							!(	!context.getConfiguration().allowsEndingVolumeOnHyphen() 
									&& sheetBuffer.size()==index-1 
									&& (!sectionProperties.duplex() || pageIndex % 2 == 1));
					
					PageImpl p = psb.nextPage(initialPageOffset, hyphenateLastLine, Optional.ofNullable(transition));
					modifyStruct(str -> str.increasePageCount());
					VolumeKeepPriority vpx = p.getAvoidVolumeBreakAfter();
					if (context.getTransitionBuilder().getProperties().getApplicationRange()==ApplicationRange.SHEET) {
						Sheet sx = s.build();
						if (!sx.getPages().isEmpty()) {
							VolumeKeepPriority vp = sx.getAvoidVolumeBreakAfterPriority();
							if (vp.orElse(10)>vpx.orElse(10)) {
								vpx = vp;
							}
						}
					}
					s.avoidVolumeBreakAfterPriority(vpx);
					if (!psb.hasNext()) {
						s.avoidVolumeBreakAfterPriority(VolumeKeepPriority.empty());
						//Don't get or store this value in crh as it is transient and not a property of the sheet context
						s.breakable(true);
					} else {
						boolean br = getContext().getRefs().getBreakable(si);
						//TODO: the following is a low effort way of giving existing uses of non-breakable units a high priority, but it probably shouldn't be done this way
						if (!br) {
							s.avoidVolumeBreakAfterPriority(VolumeKeepPriority.of(1));
						}
						s.breakable(br);
					}
	
					setPreviousSheet(si.getSheetIndex()-1, Math.min(p.keepPreviousSheets(), sheetIndex-1));
					volBreakAllowed &= p.allowsVolumeBreak();
					if (!sectionProperties.duplex() || pageIndex % 2 == 1) {
						final SheetIdentity _si = si;
						modifyRefs(refs -> refs.setBreakable(_si, volBreakAllowed));
					}
					s.add(p);
					pageIndex++;
				}
				if (!psb.hasNext()||volumeEnded) {
					if (!psb.hasNext()) {
						modifyRefs(
							refs -> refs.setSequenceScope(new DocumentSpace(getContext().getSpace(), getContext().getCurrentVolume()),
							                              seqsIndex, psb.getGlobalStartIndex(), psb.getToIndex()));
					}
					if (counter!=null) {
						modifyRefs(refs -> refs.setPageNumberOffset(counter, initialPageOffset + psb.getSizeLast()));
					} else {
						modifyStruct(str -> str.setDefaultPageOffset(initialPageOffset + psb.getSizeLast()));
					}
				}
			}
			return true;
		}

		private void setPreviousSheet(int start, int p) {
			int i = 0;
			//TODO: simplify this?
			for (int x = start; i < p && x > 0; x--) {
				SheetIdentity si = new SheetIdentity(getContext().getSpace(), getContext().getCurrentVolume(), volumeGroup, x);
				modifyRefs(refs -> refs.setBreakable(si, false));
				i++;
			}
		}
	}
}
