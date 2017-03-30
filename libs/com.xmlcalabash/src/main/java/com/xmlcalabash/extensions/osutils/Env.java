package com.xmlcalabash.extensions.osutils;

import com.xmlcalabash.core.XMLCalabash;
import com.xmlcalabash.library.DefaultStep;
import com.xmlcalabash.io.WritablePipe;
import com.xmlcalabash.core.XProcRuntime;
import com.xmlcalabash.core.XProcException;
import com.xmlcalabash.core.XProcConstants;
import com.xmlcalabash.runtime.XAtomicStep;
import com.xmlcalabash.model.RuntimeValue;
import com.xmlcalabash.util.TreeWriter;
import net.sf.saxon.s9api.QName;
import net.sf.saxon.s9api.SaxonApiException;

import java.net.URI;
import java.io.File;
import java.io.IOException;
import java.util.Map;

/**
 * Created by IntelliJ IDEA.
 * User: ndw
 * Date: Jun 3, 2009
 * Time: 7:48:27 PM
 * To change this template use File | Settings | File Templates.
 */

@XMLCalabash(
        name = "pos:env",
        type = "{http://exproc.org/proposed/steps/os}env " +
                "{http://xmlcalabash.com/ns/extensions/osutils}env")

public class Env extends DefaultStep {
    private static final QName c_env = new QName("c", XProcConstants.NS_XPROC_STEP, "env");
    private static final QName _name = new QName("name");
    private static final QName _value = new QName("value");

    private WritablePipe result = null;

    /**
     * Creates a new instance of UriInfo
     */
    public Env(XProcRuntime runtime, XAtomicStep step) {
        super(runtime,step);
    }

    public void setOutput(String port, WritablePipe pipe) {
        result = pipe;
    }

    public void reset() {
        result.resetWriter();
    }

    public void run() throws SaxonApiException {
        super.run();

        TreeWriter tree = new TreeWriter(runtime);
        tree.startDocument(step.getNode().getBaseURI());
        tree.addStartElement(XProcConstants.c_result);
        tree.startContent();

        Map<String,String> env = System.getenv();
        for (String key : env.keySet()) {
            tree.addStartElement(c_env);
            tree.addAttribute(_name, key);
            tree.addAttribute(_value, env.get(key));
            tree.startContent();
            tree.addEndElement();
        }
        
        tree.addEndElement();
        tree.endDocument();

        result.write(tree.getResult());
    }
}