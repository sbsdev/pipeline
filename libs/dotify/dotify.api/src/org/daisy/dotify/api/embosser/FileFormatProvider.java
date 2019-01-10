package org.daisy.dotify.api.embosser;

import org.daisy.dotify.api.factory.FactoryProperties;
import org.daisy.dotify.api.factory.Provider;

/**
 *
 * @author Bert Frees
 */
public interface FileFormatProvider extends Provider<FactoryProperties> {

	/**
	 * <p>Informs the implementation that it was discovered and instantiated using
	 * information collected from a file within the <code>META-INF/services</code> directory.
	 * In other words, it was created using SPI (service provider interfaces).</p>
	 *
	 * <p>This information, in turn, enables the implementation to use the same mechanism
	 * to set dependencies as needed.</p>
	 *
	 * <p>If this information is <strong>not</strong> given, an implementation
	 * should avoid using SPIs and instead use
	 * <a href="http://wiki.osgi.org/wiki/Declarative_Services">declarative services</a>
	 * for dependency injection as specified by OSGi. Note that this also applies to
	 * several newInstance() methods in the Java API.</p>
	 *
	 * <p>The class that created an instance with SPI must call this method before
	 * putting it to use.</p>
	 */
	public void setCreatedWithSPI();

	/**
	 * Creates a new file format with the specified identifier.
	 * @param identifier the identifier
	 * @return returns a new file format
	 */
	public FileFormat newFactory(String identifier);

}
