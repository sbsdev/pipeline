package org.daisy.pipeline.tts.synthesize.calabash.impl;

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import net.sf.saxon.s9api.XdmNode;

import org.daisy.pipeline.tts.Voice;

public class TTSLogImpl implements TTSLog {

	public static class EntryImpl implements Entry {

		@Override
		public void addError(Error err) {
			errors.add(err);
		}

		@Override
		public Collection<Error> getReadOnlyErrors() {
			return errors;
		}

		@Override
		public void setSSML(XdmNode ssml) {
			this.ssml = ssml;
		}

		@Override
		public XdmNode getSSML() {
			return ssml;
		}

		@Override
		public void setSelectedVoice(Voice v) {
			this.selectedVoice = v;
		}

		@Override
		public Voice getSelectedVoice() {
			return selectedVoice;
		}

		@Override
		public void setActualVoice(Voice v) {
			this.actualVoice = v;
		}

		@Override
		public Voice getActualVoice() {
			return actualVoice;
		}

		@Override
		public void addTTSinput(String input) {
			this.ttsinput.add(input);
		}

		@Override
		public List<String> getTTSinput() {
			return ttsinput;
		}

		@Override
		public void setSoundfile(String soundfile) {
			this.soundfile = soundfile;
		}

		@Override
		public String getSoundFile() {
			return soundfile;
		}

		@Override
		public void setPositionInFile(double begin, double end) {
			this.beginInFile = begin;
			this.endInFile = end;
		}

		@Override
		public double getBeginInFile() {
			return beginInFile;
		}

		@Override
		public double getEndInFile() {
			return endInFile;
		}

		@Override
		public void resetTTSinput() {
			ttsinput.clear();
		}

		@Override
		public void setTimeout(float secs) {
			this.timeout = secs;
		}

		@Override
		public float getTimeout() {
			return timeout;
		}

		private List<Error> errors = new ArrayList<Error>();
		private XdmNode ssml; //SSML
		private List<String> ttsinput = new ArrayList<String>();
		private Voice selectedVoice;
		private Voice actualVoice;
		private String soundfile; //
		private double beginInFile; //in seconds
		private double endInFile; //in seconds
		private float timeout;
	}

	public Entry getOrCreateEntry(String id) {
		Entry res = mLog.get(id);
		if (res != null)
			return res;
		res = new EntryImpl();
		mLog.put(id, res);
		return res;
	}

	public Entry getWritableEntry(String id) {
		return mLog.get(id);
	}

	public Set<Map.Entry<String, Entry>> getEntries() {
		return mLog.entrySet();
	}

	public void addGeneralError(ErrorCode errcode, String message) {
		synchronized (generalErrors) {
			generalErrors.add(new Error(errcode, message));
		}
	}

	public Collection<Error> readonlyGeneralErrors() {
		return generalErrors;
	}

	private List<Error> generalErrors = new ArrayList<Error>();
	private Map<String, Entry> mLog = new HashMap<String, Entry>();
}
