package org.daisy.dotify.formatter.impl.common;

import org.daisy.dotify.api.writer.Row;

import java.util.List;

/**
 * Provides a page object.
 *
 * @author Joel Håkansson
 */
public interface Page {

    /**
     * Gets the rows on this page.
     *
     * @return returns the rows on this page
     */
    public List<? extends Row> getRows();

}
