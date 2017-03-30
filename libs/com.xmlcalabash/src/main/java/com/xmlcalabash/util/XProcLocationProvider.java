package com.xmlcalabash.util;

import net.sf.saxon.event.SourceLocationProvider;
import java.util.Hashtable;

/**
 * Created by IntelliJ IDEA.
 * User: ndw
 * Date: Nov 23, 2008
 * Time: 5:12:19 PM
 * To change this template use File | Settings | File Templates.
 */
public class XProcLocationProvider implements SourceLocationProvider {
    Hashtable<String, Integer> locationMap;
    Hashtable<Integer,String> idMap;
    int nextId;

    public XProcLocationProvider() {
        locationMap = new Hashtable<String,Integer> ();
        idMap = new Hashtable<Integer,String> ();
        nextId = 0;
    }

    public int allocateLocation(String uri) {
        if (locationMap.containsKey(uri)) {
            return locationMap.get(uri);
        } else {
            int id = nextId++;
            idMap.put(id,uri);
            locationMap.put(uri,id);
            return id;
        }
    }

    @Override
    public String getSystemId(int locId) {
        if (idMap.containsKey(locId)) {
            return idMap.get(locId);
        } else {
            return null;
        }
    }

    @Override
    public int getLineNumber(int l) {
        return 0;
    }

    @Override
    public int getColumnNumber(int l) {
        return 0;
    }
}
