package org.daisy.dotify.api.formatter;

public class NoField implements Field {
	
	private NoField() {}
	
	private static final NoField instance = new NoField();
	
	public static NoField getInstance() {
		return instance;
	}
	
	public String getTextStyle() {
		return null;
	}
}
