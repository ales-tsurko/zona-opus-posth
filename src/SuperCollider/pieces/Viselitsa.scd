var samples, verbBus, verb, group,
window,
volumeSlider, triggerButton,
label;

samples = SoundFile.collectIntoBuffers("sounds/viselitsa/*".resolveRelative, s);

verbBus = Bus.audio;

Routine.run({
	SynthDef("viselitsaEngine", {arg bufnum;
		var playBuf;
		playBuf = PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum), doneAction: 2);
		Out.ar(verbBus.index, playBuf);
	}).add;

	group = Group.new;

	s.sync;

	SynthDef("viselitsaVerb", {arg amp = 1;
		var in;
		in = In.ar(verbBus.index, 2);
		in = GVerb.ar(in, 130, 10, 0.4, 0.5, 15, 1, 0.2, 0.5, 131);
		Out.ar(0, in * amp * 0.6);
	}).add;

	s.sync;

	verb = Synth.tail(s, "viselitsaVerb");
});

window = Window("Viselitsa", Rect(200, 500, 120, 500), false).front;
window.alpha = 0.95;
window.onClose = {
	group.free;
	samples.do({arg item; item.free});
	verb.free;
};

// Volume control
volumeSlider = Slider(window, Rect(10, 10, 100, 400));
label = StaticText(window, Rect(10, 420, 100, 20));
label.string = "Volume";
label.align = \center;
volumeSlider.action = {verb.set(\amp, volumeSlider.value)};
volumeSlider.valueAction = 1;

// Trigger button
triggerButton = Button(window, Rect(10, 440, 100, 50));
triggerButton.states = [["Trigger"]];
triggerButton.action = {
	Synth("viselitsaEngine", [\bufnum, samples.choose.bufnum], group);
};