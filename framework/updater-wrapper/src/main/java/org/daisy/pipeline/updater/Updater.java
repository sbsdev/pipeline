package org.daisy.pipeline.updater;

import java.io.IOException;
import java.io.InputStream;

import org.daisy.pipeline.properties.Properties;

public class Updater {

        private static String UPDATER_BIN="org.daisy.pipeline.updater.bin";
        private static String DEPLOY_PATH="org.daisy.pipeline.updater.deployPath";
        private static String UPDATE_SITE="org.daisy.pipeline.updater.updateSite";
        private static String RELEASE_DESCRIPTOR="org.daisy.pipeline.updater.releaseDescriptor";
        private static String ERROR="Property %s not set";


        //launches the pipeline and waits it to be up
        public void update(UpdaterObserver obs) throws IOException {
                String bin=Properties.getProperty(UPDATER_BIN,"");
                String deployPath=Properties.getProperty(DEPLOY_PATH,"");
                String updateSite=Properties.getProperty(UPDATE_SITE,"");
                String releaseDescriptor=Properties.getProperty(RELEASE_DESCRIPTOR,"");
                if (bin.isEmpty()){
                        throw new IllegalArgumentException(String.format(ERROR,UPDATER_BIN));
                }
                if (deployPath.isEmpty()){
                        throw new IllegalArgumentException(String.format(ERROR,DEPLOY_PATH));
                }
                if (updateSite.isEmpty()){
                        throw new IllegalArgumentException(String.format(ERROR,UPDATE_SITE));
                }

                InputStream os=new Launcher(bin,
                                updateSite,
                                deployPath,
                                releaseDescriptor,
                                "current").launch();
                new OutputParser(os,obs).parse();

        }
}
