package org.daisy.dotify.formatter.impl.page;

/**
 * Provides state needed for a text flow.
 * 
 * @author Joel Håkansson
 */
public class PageStruct {

	private final int pageOffset;
	private final int pageCount;

	public PageStruct() {
		pageOffset = 0;
		pageCount = 0;
	}

	private PageStruct(Builder builder) {
		pageOffset = builder.pageOffset;
		pageCount = builder.pageCount;
	}

	public int getDefaultPageOffset() {
		return pageOffset;
	}

	/**
	 * This is used for searching and MUST be continuous. Do not use for page numbers.
	 * @return returns the page count
	 */
	public int getPageCount() {
		return pageCount;
	}
	
	public Builder builder() {
		return from(this);
	}
	
	public static Builder from(PageStruct template) {
		return new Builder(template);
	}

	public static class Builder {
		
		private int pageOffset;
		private int pageCount;
		
		private Builder(PageStruct template) {
			pageOffset = template.pageOffset;
			pageCount = template.pageCount;
		}
		
		public Builder setDefaultPageOffset(int value) {
			pageOffset = value;
			return this;
		}
		
		/**
		 * Advance to the next page.
		 */
		public Builder increasePageCount() {
			pageCount++;
			return this;
		}
		
		public PageStruct build() {
			return new PageStruct(this);
		}
	}
}
