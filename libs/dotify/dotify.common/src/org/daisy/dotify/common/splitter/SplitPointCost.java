package org.daisy.dotify.common.splitter;

// FIXME: wouldn't it be better to pass position (float) instead of index?

/**
 * Provides a cost function for a split point.
 *  
 * @author Joel Håkansson
 * @param <T> the type of split point unit
 *
 */
@FunctionalInterface
public interface SplitPointCost<T extends SplitPointUnit> {

	/**
	 * Returns the cost of breaking after the specified unit. The following units are
	 * provided as a SplitPointDataSource. This object should not be mutated.
	 *
	 * @param unit the unit
	 * @param index the index of the breakpoint unit
	 * @param limit the maximum length to consider
	 * @return returns the cost
	 */
	public double getCost(T unit, int index, int limit);
	
}
