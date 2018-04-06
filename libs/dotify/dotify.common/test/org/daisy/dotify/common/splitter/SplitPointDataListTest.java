package org.daisy.dotify.common.splitter;

import java.util.NoSuchElementException;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;
import static org.junit.Assert.fail;
import static org.mockito.Mockito.mock;

import org.junit.Test;

@SuppressWarnings("javadoc")
public class SplitPointDataListTest {
	
	@Test
	public void testHasNext() {
		SplitPointDataList<SplitPointUnit> m = new SplitPointDataList<>();
		assertTrue(m.isEmpty());
	}
	
	@Test
	public void testSizeAfterTruncating_01() {
		SplitPointDataList<SplitPointUnit> m = new SplitPointDataList<>(mock(SplitPointUnit.class))
				.tail(1);
		assertTrue(m.isEmpty());
	}

	@Test
	public void testSizeAfterTruncating_02() {
		SplitPointDataList<SplitPointUnit> m = new SplitPointDataList<>(mock(SplitPointUnit.class), mock(SplitPointUnit.class))
				.tail(1);
		assertTrue(!m.isEmpty());
		assertEquals(1, m.getSize());
	}
	
	@Test
	public void testSize() {
		SplitPointDataList<SplitPointUnit> m = new SplitPointDataList<>(mock(SplitPointUnit.class));
		assertEquals(1, m.getSize());

	}

	@Test
	public void testNoSuchElementException() {
		SplitPointDataList.Iterator<SplitPointUnit> m
		= new SplitPointDataList<>(mock(SplitPointUnit.class), mock(SplitPointUnit.class)).iterator();
		assertTrue(m.hasNext());
		m.next(false);
		assertTrue(m.hasNext());
		m.next(false);
		assertFalse(m.hasNext());
		try {
			m.next(false);
			fail();
		} catch (NoSuchElementException e) {
		}
	}
	
	@Test
	public void testGetUntil() {
		SplitPointDataList<SplitPointUnit> m = new SplitPointDataList<>(mock(SplitPointUnit.class), mock(SplitPointUnit.class));
		assertEquals(1, m.head(1).size());
	}

}
