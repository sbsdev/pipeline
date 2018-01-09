package org.daisy.pipeline.webservice.impl;

import java.io.File;

import org.daisy.common.properties.PropertyPublisher;
import org.daisy.pipeline.webserviceutils.Properties;
import org.daisy.pipeline.webserviceutils.Routes;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class PipelineWebServiceConfiguration {

        
        private boolean usesAuthentication = true;
        private long maxRequestTime = 600000; // 10 minutes in ms
        private String tmpDir=System.getProperty("java.io.tmpdir","/tmp");
        private boolean ssl=false;

        private String sslKeystore="";
        private String sslKeystorePassword="";
        private String sslKeyPassword="";

        private String clientKey=null;
        private String clientSecret=null;
        private static Logger logger = LoggerFactory.getLogger(PipelineWebServiceConfiguration.class);
        private boolean cleanUpOnStartUp = false;

        /**
         * Constructs a new instance.
         */
        public PipelineWebServiceConfiguration() {
                readOptions();
        }

        private void readOptions() {
                //Authentication        
                String authentication = Properties.AUTHENTICATION.get();
                if (authentication != null) {
                        if (authentication.equalsIgnoreCase("true")) {
                                usesAuthentication = true;
                        }
                        else if (authentication.equalsIgnoreCase("false")) {
                                usesAuthentication = false;
                                logger.info("Web service authentication is OFF");
                        }
                        else {
                                logger.error(String.format(
                                                "Value specified in option %s (%s) is not valid. Using default value of %s.",
                                                Properties.AUTHENTICATION, authentication, usesAuthentication));
                        }
                }
                //Temporal directory
                String tmp = Properties.TMPDIR.get();
                if (tmp != null) {
                        File f = new File(tmp);
                        if (f.exists()) {
                                tmpDir = tmp;
                        }
                        else {
                                logger.error(String.format(
                                                "Value specified in option %s (%s) is not valid. Using default value of %s.",
                                                Properties.TMPDIR, tmp, tmpDir));
                        }
                }
                        
                

                //Max req time
                String maxrequesttime = Properties.MAX_REQUEST_TIME.get();
                if (maxrequesttime != null) {
                        try {
                                long ms = Long.parseLong(maxrequesttime);
                                maxRequestTime = ms;
                        } catch(NumberFormatException e) {
                                logger.error(String.format(
                                                "Value specified in option %s (%s) is not a valid numeric value. Using default value of %d.",
                                                Properties.MAX_REQUEST_TIME, maxrequesttime, maxRequestTime));
                        }
                }
                //ssl related stuff
                ssl=Properties.SSL.get()!=null&&Properties.SSL.get().equalsIgnoreCase("true");
                sslKeystore=Properties.SSL_KEYSTORE.get("");
                sslKeystorePassword=Properties.SSL_KEYSTOREPASSWORD.get("");
                sslKeyPassword=Properties.SSL_KEYPASSWORD.get("");


                clientKey=Properties.CLIENT_KEY.get();
                clientSecret=Properties.CLIENT_SECRET.get();

                cleanUpOnStartUp = Boolean.valueOf(Properties. CLEAN_UP_ON_START_UP.get("false"));
        }

        public void publishConfiguration(PropertyPublisher propPublisher){
                //mode
                publish(propPublisher, Properties.LOCALFS,Properties.LOCALFS.get("false"));
                //ssl related properties
                publish(propPublisher, Properties.SSL,Properties.SSL.get("false"));
                publish(propPublisher, Properties.SSL_KEYSTORE,!Properties.SSL_KEYSTORE.get("").isEmpty()+"");
                publish(propPublisher, Properties.SSL_KEYSTOREPASSWORD,!Properties.SSL_KEYSTOREPASSWORD.get("").isEmpty()+"");
                publish(propPublisher, Properties.SSL_KEYPASSWORD,!Properties.SSL_KEYPASSWORD.get("").isEmpty()+"");
                //client keys and secret
                publish(propPublisher, Properties.CLIENT_KEY,Properties.CLIENT_KEY.get(""));
                publish(propPublisher, Properties.CLIENT_SECRET,!Properties.CLIENT_SECRET.get("").isEmpty()+"");
                //request
                publish(propPublisher, Properties.MAX_REQUEST_TIME,this.getMaxRequestTime()+"");
                //tmp dir
                publish(propPublisher, Properties.TMPDIR,this.getTmpDir());
                publish(propPublisher, Properties.AUTHENTICATION,this.isAuthenticationEnabled()+"");
                Routes routes=new Routes();
                publish(propPublisher, Properties.HOST,routes.getHost()+"");
                publish(propPublisher, Properties.PATH,routes.getPath()+"");
                publish(propPublisher, Properties.PORT,routes.getPort()+"");

                publish(propPublisher, Properties.CLEAN_UP_ON_START_UP,this.getCleanUpOnStartUp()+"");

        }

        public void unpublishConfiguration(PropertyPublisher propPublisher){
                //mode
                unpublish(propPublisher, Properties.LOCALFS);
                //ssl related properties
                unpublish(propPublisher, Properties.SSL);
                unpublish(propPublisher, Properties.SSL_KEYSTORE);
                unpublish(propPublisher, Properties.SSL_KEYSTOREPASSWORD);
                unpublish(propPublisher, Properties.SSL_KEYPASSWORD);
                //client keys and secret
                unpublish(propPublisher, Properties.CLIENT_KEY);
                unpublish(propPublisher, Properties.CLIENT_SECRET);
                //request
                unpublish(propPublisher, Properties.MAX_REQUEST_TIME);
                //tmp dir
                unpublish(propPublisher, Properties.TMPDIR);
                unpublish(propPublisher, Properties.AUTHENTICATION);
                unpublish(propPublisher, Properties.CLEAN_UP_ON_START_UP);

        }

        private static void publish(PropertyPublisher publisher, Properties propertyName, String value) {
                publisher.publish(propertyName.getName(), value, PipelineWebServiceConfiguration.class);
        }

        private static void unpublish(PropertyPublisher publisher, Properties propertyName) {
                publisher.unpublish(propertyName.getName(), PipelineWebServiceConfiguration.class);
        }

        public String getTmpDir() {
                return tmpDir;
        }

        /**
         * Determines if this instance is ssl.
         *
         * @return The ssl.
         */
        public boolean isSsl() {
                return this.ssl;
        }

        /**
         * Gets the sslKeystore for this instance.
         *
         * @return The sslKeystore.
         */
        public String getSslKeystore() {
                return this.sslKeystore;
        }

        /**
         * Gets the sslKeystorePassword for this instance.
         *
         * @return The sslKeystorePassword.
         */
        public String getSslKeystorePassword() {
                return this.sslKeystorePassword;
        }

        /**
         * Gets the sslKeyPassword for this instance.
         *
         * @return The sslKeyPassword.
         */
        public String getSslKeyPassword() {
                return this.sslKeyPassword;
        }

        /**
         * Gets the clientKey for this instance.
         *
         * @return The clientKey.
         */
        public String getClientKey() {
                return this.clientKey;
        }

        /**
         * Gets the clientSecret for this instance.
         *
         * @return The clientSecret.
         */
        public String getClientSecret() {
                return this.clientSecret;
        }

        public boolean isAuthenticationEnabled() {
                return usesAuthentication;
        }

        
        public boolean isLocalFS() {
                return Boolean.valueOf(Properties.LOCALFS.get("false"));
        }

        // the length of time in ms that a request is valid for, counting from its timestamp value
        public long getMaxRequestTime() {
                return maxRequestTime;
        }

        public boolean getCleanUpOnStartUp() {
                return this.cleanUpOnStartUp;
        }

}

