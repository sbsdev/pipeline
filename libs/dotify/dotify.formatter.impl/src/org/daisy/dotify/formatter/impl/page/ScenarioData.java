package org.daisy.dotify.formatter.impl.page;

import java.util.List;
import java.util.Stack;

import org.daisy.dotify.api.formatter.FormattingTypes.BreakBefore;
import org.daisy.dotify.formatter.impl.core.Block;
import org.daisy.dotify.formatter.impl.core.BlockContext;
import org.daisy.dotify.formatter.impl.core.LayoutMaster;
import org.daisy.dotify.formatter.impl.row.LineProperties;

/**
 * Provides data about a single rendering scenario.
 * 
 * @author Joel Håkansson
 */
class ScenarioData extends BlockProcessor {
	private Stack<RowGroupSequence> dataGroups = new Stack<>();

	ScenarioData() {
		super();
		dataGroups = new Stack<>();
	}

	/**
	 * Creates a deep copy of the supplied instance
	 * @param template the instance to copy
	 */
	ScenarioData(ScenarioData template) {
		super(template);
		dataGroups = new Stack<>();
		for (RowGroupSequence rgs : template.dataGroups) {
			dataGroups.add(new RowGroupSequence(rgs));
		}
	}

	float calcSize() {
		float size = 0;
		for (RowGroupSequence rgs : dataGroups) {
			for (RowGroup rg : rgs.getGroup()) {
				size += rg.getUnitSize();
			}
		}
		return size;
	}
	
	protected boolean hasSequence() {
		return !dataGroups.isEmpty();
	}
	
	private boolean hasResult() {
		return !dataGroups.isEmpty();
	}
	
	protected boolean maybeNewRowGroupSequence(BreakBefore breakBefore, VerticalSpacing vs) {
		if (!hasSequence() || ((breakBefore != BreakBefore.AUTO || vs != null) && hasResult())) {
			RowGroupSequence rgs = new RowGroupSequence(breakBefore, vs);
			dataGroups.add(rgs);
			return true;
		} else {
			if (breakBefore != BreakBefore.AUTO || vs != null) {
				dataGroups.peek().vSpacing = vs;
				dataGroups.peek().breakBefore = breakBefore;
			}
			return false;
		}
	}
	
	protected void addRowGroup(RowGroup rg) {
		dataGroups.peek().getGroup().add(rg);
	}
	
	RowGroup peekResult() {
		return dataGroups.peek().currentGroup();
	}

	List<RowGroupSequence> getDataGroups() {
		return dataGroups;
	}
	
	void processBlock(LayoutMaster master, Block g, BlockContext bc) {
		loadBlock(master, g, bc);
		while (hasNextInBlock()) {
			processNextRowGroup(bc, LineProperties.DEFAULT);
		}
		dataGroups.peek().getBlocks().add(g);
	}
}
