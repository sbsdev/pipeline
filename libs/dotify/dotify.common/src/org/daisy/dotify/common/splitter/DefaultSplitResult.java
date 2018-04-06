package org.daisy.dotify.common.splitter;

import java.util.List;

/**
 * Provides a default splitter result.
 * @author Joel Håkansson
 *
 * @param <T> the type of units
 */
public class DefaultSplitResult<T extends SplitPointUnit> implements SplitResult<T> {
	private final List<T> head;
	private final SplitPointDataSource<T> tail;
	
	/**
	 * Creates a new result.
	 * @param head the head of the result
	 * @param tail the tail of the result
	 */
	public DefaultSplitResult(List<T> head, SplitPointDataSource<T> tail) {
		this.head = head;
		this.tail = tail;
	}
	
	@Override
	public List<T> head() {
		return head;
	}

	@Override
	public SplitPointDataSource<T> tail() {
		return tail;
	}
}
