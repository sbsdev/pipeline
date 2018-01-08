package org.daisy.pipeline.cssinlining;

import javax.xml.transform.URIResolver;

import org.daisy.common.xproc.calabash.XProcStepProvider;

import com.xmlcalabash.core.XProcRuntime;
import com.xmlcalabash.core.XProcStep;
import com.xmlcalabash.runtime.XAtomicStep;

import cz.vutbr.web.css.CSSFactory;

public class InlineCSSProvider implements XProcStepProvider {

	private URIResolver resolver;

	@Override
	public XProcStep newStep(XProcRuntime runtime, XAtomicStep step) {
		return new InlineCSSStep(runtime, step, resolver);
	}

	public void setUriResolver(URIResolver resolver) {
		this.resolver = resolver;
	}
}
