var leftBuf, rightBuf,
octUpSynth, octDownSynth,
window,
transposeMenu,
volumeBass, volumeSoprano,
label,
linkChannels;

window = Window("Igra vodi", Rect(200, 500, 230, 500), false).front;
window.alpha = 0.95;

if(window.isClosed == false, {
	Routine.run({
		leftBuf = Buffer.readChannel(s, "sounds/igra_vodi.wav".resolveRelative, channels: 0);
		rightBuf = Buffer.readChannel(s, "sounds/igra_vodi.wav".resolveRelative, channels: 1);

		s.wait;

		SynthDef("igraVodiEngine", {arg rate, transpose = 0, amp;
			var leftBufNum, rightBufNum,
			rateScale, varRate, trig, pos, dur,
			genL, genR, out;

			leftBufNum = leftBuf.bufnum;
			rightBufNum = rightBuf.bufnum;
			rateScale = BufRateScale.kr(leftBufNum);
			varRate = (rateScale * rate) * transpose.midiratio;

			trig = Dust.kr(20);
			pos = TRand.kr(0,0.9,trig);
			dur = 1;

			genL = GrainBuf.ar(1, trig, dur, leftBufNum, varRate, pos);
			genR = GrainBuf.ar(1, trig, dur, rightBufNum, varRate, pos);

			out = [genL, genR] * amp;

			Out.ar(0, out);
		}).add;

		s.sync;

		octUpSynth = Synth.new("igraVodiEngine", [rate: 2]);
		octDownSynth = Synth.new("igraVodiEngine", [rate: 0.5]);
	});

});

window.onClose = {
	octUpSynth.free;
	octDownSynth.free;
	leftBuf.free;
	rightBuf.free;
};

volumeBass = Slider(window, Rect(10, 10, 100, 400));

volumeSoprano = Slider(window, Rect(120, 10, 100, 400));

label = StaticText(window, Rect(10, 415, 100, 50));
label.string = "Lo";
label.align = \center;

label = StaticText(window, Rect(120, 415, 100, 50));
label.string = "Hi";
label.align = \center;

linkChannels = CheckBox(window, Rect(10, 460, 200, 50), "Link Channels");

linkChannels.action = {
	if(linkChannels.value, {
		var channelsDifference = volumeBass.value - volumeSoprano.value;

		volumeBass.action = {
			volumeSoprano.value = volumeBass.value - channelsDifference;
			octDownSynth.set(\amp, volumeBass.value);
			octUpSynth.set(\amp, volumeSoprano.value);
		};

		volumeSoprano.action = {
			volumeBass.value = volumeSoprano.value + channelsDifference;
			octDownSynth.set(\amp, volumeBass.value);
			octUpSynth.set(\amp, volumeSoprano.value);
		};
	}, {
		volumeBass.action = {
			volumeSoprano.value = volumeSoprano.value;
			octDownSynth.set(\amp, volumeBass.value);
		};
		volumeSoprano.action = {
			volumeBass.value = volumeBass.value;
			octUpSynth.set(\amp, volumeSoprano.value);
		};
	});
};

linkChannels.valueAction = false;

transposeMenu = PopUpMenu(window, Rect(140, 475, 80, 20));
transposeMenu.items = [
	"C/Am", "Db/Bbm", "D/Bm",
	"Eb/Cm", "E/C#m", "F/Dm",
	"F#/D#m", "G/Em", "Ab/Fm",
	"A/F#m", "Bb/Gm", "B/G#m"
];

transposeMenu.action = {arg menu;
	octUpSynth.set(\transpose, menu.value);
	octDownSynth.set(\transpose, menu.value);
};