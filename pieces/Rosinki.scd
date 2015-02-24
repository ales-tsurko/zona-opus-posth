AppClock.play(
	Routine.run({
		var samples, routine, controlSynth, ampBus, transposeBus, group,
		densityMul, maximumDensityMul,
		window,
		volumeSlider, densityKnob, transposeMenu,
		label;

		samples = SoundFile.collectIntoBuffers("sounds/rosinki/*".resolveRelative, s);

		ampBus = Bus.control;
		transposeBus = Bus.control;

		maximumDensityMul = 0.2;
		densityMul = 1;

		s.sync;

		SynthDef("rosinkiControl", {arg amp, transpose;
			Out.kr(ampBus, amp);
			Out.kr(transposeBus, transpose);
		}).add;

		s.sync;

		controlSynth = Synth("rosinkiControl");

		s.sync;

		SynthDef("rosinkiEngine", {arg bufnum;
			var inAmp, inTranspose,
			glissEnv, vibrato, playBuf, panPos, out;

			inAmp = In.kr(ampBus);
			inTranspose = In.kr(transposeBus);

			glissEnv = XLine.kr(1, 0.5, Rand(1.0, 30));
			vibrato = LFNoise1.kr(8, 0.001);
			playBuf = PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum));
			playBuf = playBuf + (PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum) * glissEnv + vibrato, doneAction: 2) * 0.8);
			out = PitchShift.ar(playBuf, 0.2, inTranspose, 0, 0.2);
			panPos = LFNoise1.kr(0.8, 2);
			out = Splay.ar(out, center: panPos);
			Out.ar(0, out * inAmp);
		}).add;

		group = Group.new;

		s.sync;

		routine = Routine({
			loop {
				Synth("rosinkiEngine", [\bufnum, samples.choose.bufnum], group);
				(rrand(0.5, 5) * densityMul).wait;
			}
		});

		window = Window("Rosinki", Rect(200, 500, 120, 500), false).front;
		window.alpha = 0.95;
		window.onClose = {
			routine.stop;
			group.free;
			routine.free;
			samples.do({arg item; item.free});
			controlSynth.free;
		};

		routine.play;

		// Volume control
		volumeSlider = Slider(window, Rect(10, 10, 100, 260));
		volumeSlider.action = {controlSynth.set(\amp, volumeSlider.value)};
		volumeSlider.valueAction = 0;
		label = StaticText(window, Rect(10, 270, 100, 20));
		label.string = "Volume";
		label.align = \center;

		// Density knob
		densityKnob = Knob(window, Rect(10, 300, 100, 100));
		densityKnob.mode = \vert;
		densityKnob.action = {
			densityMul = (1 - maximumDensityMul * (1 - densityKnob.value)) + maximumDensityMul;
		};
		label = StaticText(window, Rect(10, 410, 100, 20));
		label.string = "Density";
		label.align = \center;

		// Transpose
		transposeMenu = PopUpMenu(window, Rect(30, 475, 80, 20));
		transposeMenu.items = [
			"D/Bm", "Eb/Cm", "E/C#m",
			"F/Dm", "F#/D#m", "G/Em",
			"Ab/Fm", "A/F#m", "Bb/Gm",
			"B/G#m","C/Am", "Db/Bbm"
		];
		transposeMenu.action = {arg menu;
			controlSynth.set(\transpose, transposeMenu.value.midiratio);
		};
		transposeMenu.valueAction = 0;
	});
)

