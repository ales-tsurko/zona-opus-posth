var maxRate, maxPanRate,
leftBuf, rightBuf, soundEngine,
window,
volumeSlider,
rateKnob, panRateKnob, durationRange,
transposeMenu,
label;

maxRate = 20;
maxPanRate = 9;

window = Window("Bluzhdayushchiye ogni", Rect(200, 500, 230, 500), false).front;
window.alpha = 0.95;
window.onClose = {
	soundEngine.free;
	leftBuf.free;
	rightBuf.free;
};

if(window.isClosed == false, {
	Routine.run({
		leftBuf = Buffer.readChannel(s,
			"sounds/bluzhdayushchiye_ogni.wav".resolveRelative, channels: 0);
		rightBuf = Buffer.readChannel(s,
			"sounds/bluzhdayushchiye_ogni.wav".resolveRelative, channels: 1);

		s.wait;

		SynthDef("Ogni Engine", {arg amp = 0, grainRate = 14,
			panRate = 1, transpose = 1, durMin = 0.015, durMax = 0.2;

			var trig, posL, posR, durL, durR,
			rate, panL, panR, ampModL, ampModR, grainL, grainR, out;

			trig = Impulse.kr(grainRate);
			// trig = Impulse.kr(LFNoise1.kr(1, 6, 8).abs); // With accelerando
			posL = TRand.kr(0, 1.0, Dust.kr(1));
			posR = TRand.kr(0, 1.0, Dust.kr(1));
			rate = BufRateScale.kr(leftBuf.bufnum) * transpose;
			panL = LFNoise1.kr(panRate);
			panR = LFNoise1.kr(panRate);
			durL = LFNoise1.kr(0.5, durMax, durMin).abs;
			durR = LFNoise1.kr(0.5, durMax, durMin).abs;
			ampModL = LFNoise1.kr(posL * 2).abs;
			ampModR = LFNoise1.kr(posR * 2).abs;
			grainL = GrainBuf.ar(2, trig, durL, leftBuf.bufnum, rate * 2, posL, 2, panL) * ampModL;
			grainR = GrainBuf.ar(2, trig, durR, rightBuf.bufnum, rate, posR, 2, panR) * ampModR;
			out = (grainL + grainR) * 2;

			Out.ar(0, out * amp);
		}).add;

		s.sync;

		soundEngine = Synth("Ogni Engine");
	});
});

volumeSlider = Slider(window, Rect(10, 10, 100, 400));
volumeSlider.action = {soundEngine.set(\amp, volumeSlider.value)};
label = StaticText(window, Rect(10, 415, 100, 20));
label.string = "Volume";
label.align = \center;

rateKnob = Knob(window, Rect(120, 10, 100, 100));
rateKnob.mode = \vert;
rateKnob.action = {soundEngine.set(\grainRate, rateKnob.value*maxRate+1)};
rateKnob.valueAction = (1/maxRate) + (1/maxRate*14);
label = StaticText(window, Rect(120, 110, 100, 20));
label.string = "Rate";
label.align = \center;

panRateKnob = Knob(window, Rect(120, 140, 100, 100));
panRateKnob.mode = \vert;
panRateKnob.action = {soundEngine.set(\panRate, panRateKnob.value*maxPanRate+1)};
panRateKnob.valueAction = 0;
label = StaticText(window, Rect(120, 240, 100, 20));
label.string = "Pan rate";
label.align = \center;

durationRange = RangeSlider(window, Rect(120, 270, 100, 140));
durationRange.knobColor = Color.new255(11,29,39);
durationRange.action = {
	soundEngine.set(\durMin, durationRange.lo*2+0.01);
	soundEngine.set(\durMax, durationRange.hi*2+0.01);
};
durationRange.activeHi = 0.2;
label = StaticText(window, Rect(120, 415, 100, 20));
label.string = "Duration range";
label.align = \center;

transposeMenu = PopUpMenu(window, Rect(140, 475, 80, 20));
transposeMenu.items = [
	"B/G#m", "C/Am", "Db/Bbm",
	"D/Bm", "Eb/Cm", "E/C#m",
	"F/Dm", "F#/D#m", "G/Em",
	"Ab/Fm", "A/F#m", "Bb/Gm"
];
transposeMenu.action = {soundEngine.set(\transpose, transposeMenu.value.midiratio)};