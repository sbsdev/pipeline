package org.daisy.dotify.formatter.impl.page;

import java.util.ArrayList;
import java.util.function.Consumer;
import java.util.List;
import java.util.NoSuchElementException;

import org.daisy.dotify.common.splitter.SplitPointDataSource;
import org.daisy.dotify.common.splitter.Supplements;
import org.daisy.dotify.formatter.impl.core.Block;
import org.daisy.dotify.formatter.impl.core.BlockContext;
import org.daisy.dotify.formatter.impl.core.LayoutMaster;

class RowGroupDataSource extends BlockProcessor implements SplitPointDataSource<RowGroup> {

	private final LayoutMaster master;
	private final Supplements<RowGroup> supplements;
	private final VerticalSpacing vs;
	private final List<Block> blocks;
	private List<RowGroup> groups;
	private int groupIndex;
	private BlockContext bc;
	private int blockIndex;
	private boolean hyphenateLastLine;
	private boolean mergeRefs;

	RowGroupDataSource(LayoutMaster master, BlockContext bc, List<Block> blocks, VerticalSpacing vs, Supplements<RowGroup> supplements) {
		super();
		this.master = master;
		this.bc = bc;
		this.groups = null;
		this.groupIndex = 0;
		this.blocks = blocks;
		this.supplements = supplements;
		this.vs = vs;
		this.blockIndex = 0;
		this.hyphenateLastLine = true;
		this.mergeRefs = false;
	}

	/**
	 * Creates a deep copy of template
	 *
	 * @param template the template
	 */
	private RowGroupDataSource(RowGroupDataSource template) {
		super(template);
		this.master = template.master;
		this.bc = template.bc;
		this.groups = template.groups == null ? null : new ArrayList<>(template.groups);
		this.groupIndex = template.groupIndex;
		this.blocks = template.blocks;
		this.supplements = template.supplements;
		this.vs = template.vs;
		this.blockIndex = template.blockIndex;
		this.hyphenateLastLine = template.hyphenateLastLine;
		this.mergeRefs = template.mergeRefs;
	}
	
	private String indent = "";
	
	static RowGroupDataSource copyUnlessNull(RowGroupDataSource template) {
		return template==null?null:new RowGroupDataSource(template);
	}

	VerticalSpacing getVerticalSpacing() {
		return vs;
	}
	
	BlockContext getContext() {
		// merge modifications to refs by rowGroupProvider
		if (mergeRefs && rowGroupProvider != null) {
			bc = bc.builder().refs(rowGroupProvider.getRefs()).build();
		}
		mergeRefs = false;
		return bc;
	}
	
	// FIXME: make immutable
	void modifyContext(Consumer<BlockContext.Builder> modifier) {
		BlockContext.Builder b = getContext().builder();
		modifier.accept(b);
		bc = b.build();
	}

	// FIXME: make immutable
	void setHyphenateLastLine(boolean value) {
		this.hyphenateLastLine = value;
	}

	private int groupSize() {
		return groups==null?0:groups.size();
	}

	@Override
	public Supplements<RowGroup> getSupplements() {
		return supplements;
	}

	@Override
	public boolean isEmpty() {
		if (groupIndex < groupSize() || hasNextInBlock()) {
			return false;
		}
		while (blockIndex < blocks.size()) {
			Block b = blocks.get(blockIndex);
			blockIndex++;
			loadBlock(master, b, getContext());
			if (hasNextInBlock()) {
				return false;
			} else {
				// FIXME: this will change the value of getContext() which makes RowGroupDataSource mutable
				mergeRefs = true;
			}
		}
		return true;
	}

	@Override
	public Iterator<RowGroup> iterator() {
		return new RowGroupDataSource(this).asIterator();
	}

	private Iterator<RowGroup> asIterator() {
		return new RowGroupDataSourceIterator();
	}

	@Override
	protected void newRowGroupSequence(VerticalSpacing vs) {
		if (groups!=null) {
			throw new IllegalStateException();
		} else {
			groups = new ArrayList<>();
		}
	}

	@Override
	protected boolean hasSequence() {
		return groups!=null;
	}

	@Override
	protected boolean hasResult() {
		return hasSequence() && !groups.isEmpty();
	}

	@Override
	protected void addRowGroup(RowGroup rg) {
		groups.add(rg);
	}

	private class RowGroupDataSourceIterator implements Iterator<RowGroup> {

		@Override
		public boolean hasNext() {
			return !isEmpty();
		}

		@Override
		public RowGroup next(boolean last) throws NoSuchElementException {
			if (ensureBuffer(groupIndex + 1)) {
				if (last) {
					hyphenateLastLine = true;
				}
				return groups.get(groupIndex++);
			} else {
				throw new NoSuchElementException();
			}
		}

		@Override
		public RowGroupDataSource iterable() {
			return new RowGroupDataSource(RowGroupDataSource.this);
		}

		/**
		 * Ensures that there are at least index elements in the buffer.
		 * When index is -1 this method always returns false.
		 * @param index the index (or -1 to get all remaining elements)
		 * @return returns true if the index element was available, false otherwise
		 */
		private boolean ensureBuffer(int index) {
			while (index<0 || groupSize()<index) {
				if (blockIndex>=blocks.size() && !hasNextInBlock()) {
					return false;
				}
				if (!hasNextInBlock()) {
					//get next block
					Block b = blocks.get(blockIndex);
					blockIndex++;
					loadBlock(master, b, getContext());
				}
				processNextRowGroup(getContext(), !hyphenateLastLine && groupSize()>=index-1);
				// refs possibly mutated
				mergeRefs = true;
			}
			return true;
		}
	}
	
	@Override
	public String toString() {
		return super.toString().substring("org.daisy.dotify.formatter.impl.page.".length());
	}
}
