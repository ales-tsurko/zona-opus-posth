var samples, ampBus, feedbackBus, transposeBus, octBus, controlSynth, group,
window,
label, volumeSlider, feedbackSlider, triggerButton,
oct, transposeMenu;

samples = SoundFile.collectIntoBuffers("sounds/babochki/*".resolveRelative, s);
ampBus = Bus.control;
feedbackBus = Bus.control;
transposeBus = Bus.control;
octBus = Bus.control;

Routine.run({

	controlSynth = SynthDef("babochkiEngineControl", {arg amp,
		feedback = 1, transpose = 1, oct = 1;
		Out.kr(ampBus.index, amp);
		Out.kr(feedbackBus.index, feedback);
		Out.kr(transposeBus.index, transpose);
		Out.kr(octBus.index, oct);
	}).add;

	s.sync;

	controlSynth = Synth("babochkiEngineControl");

	s.wait;

	SynthDef("babochkiEngine", {arg bufnum;
		var inAmp, inFeedback, inTranspose, inOct,
		env, playBuf, delay, out;
		inAmp = In.kr(ampBus.index);
		inFeedback = In.kr(feedbackBus.index);
		inTranspose = In.kr(transposeBus.index);
		inOct = In.kr(octBus.index);

		env = EnvGen.kr(Env.perc(1, 24 * inFeedback + 6, 1, 6), doneAction: 2);
		playBuf = PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum));
		playBuf = PitchShift.ar(playBuf, 0.2, inTranspose * inOct, 0, 0.2);
		delay = CombC.ar(playBuf, 5.5, 5.5, 100) * env;
		out = delay+playBuf;

		Out.ar(0, out * inAmp)
	}).add;
});

group = Group.new;

// transpose, oct (±2)
window = Window("Babochki", Rect(200, 500, 230, 500), false).front;
window.alpha = 0.95;
window.onClose = {
	group.free;
	samples.do({arg item; item.free});
	controlSynth.free;
};

// Volume
volumeSlider = Slider(window, Rect(120, 10, 100, 400));
label = StaticText(window, Rect(120, 410, 100, 50));
label.string = "Volume";
label.align = \center;
volumeSlider.action = {controlSynth.set(\amp, volumeSlider.value)};
volumeSlider.valueAction = 0;

// Feedback control
feedbackSlider = Slider(window, Rect(10, 10, 100, 200));
feedbackSlider.action = {controlSynth.set(\feedback, feedbackSlider.value)};
feedbackSlider.valueAction = 1;
label = StaticText(window, Rect(10, 210, 100, 50));
label.string = "Feedback";
label.align = \center;

// Magic button
triggerButton = Button(window, Rect(10, 260, 100, 150));
triggerButton.states = [["Trigger"]];
triggerButton.action = {
	Synth("babochkiEngine", [\bufnum, samples.choose.bufnum], group);
};

// Octave transposition
oct = NumberBox(window, Rect(60, 475, 30, 20));
label = StaticText(window, Rect(10, 475, 50, 20));
label.string = "Octave:";
oct.clipLo = -2;
oct.clipHi = 2;
oct.action = {controlSynth.set(\oct, 2**(oct.value));};
oct.valueAction = 0;

// Transpose
transposeMenu = PopUpMenu(window, Rect(140, 475, 80, 20));
transposeMenu.items = [
	"B/G#m", "C/Am", "Db/Bbm",
	"D/Bm", "Eb/Cm", "E/C#m",
	"F/Dm", "F#/D#m", "G/Em",
	"Ab/Fm", "A/F#m", "Bb/Gm"
];
transposeMenu.action = {controlSynth.set(\transpose, transposeMenu.value.midiratio)};

