AppClock.play(
	Routine({

		var filePath, leftBuf, rightBuf,
		window,
		soundFileView1, soundFileView2, soundFileView3, soundFile,
		track1, track2, track3,
		posFunc,
		masterVol,
		track1Oct, track2Oct, track3Oct,
		transpose,
		resetButton, pauseButton,
		label;

		filePath = "sounds/forel.wav".resolveRelative;

		leftBuf = Buffer.readChannel(s, filePath, channels: 0);
		rightBuf = Buffer.readChannel(s, filePath, channels: 1);

		s.wait;

		// The player
		SynthDef("forelEngine", {arg trig = 0, transpose = 1, oct = 1, pause = 0, id, amp;
			var pos, lPlayer, rPlayer, out;
			pos = Phasor.ar(
				Changed.kr(trig), BufRateScale.kr(leftBuf.bufnum) * transpose * oct * pause,
				0, BufFrames.kr(leftBuf.bufnum));
			lPlayer = BufRd.ar(1, leftBuf.bufnum, pos, 1);
			rPlayer = BufRd.ar(1, rightBuf.bufnum, pos, 1);

			out = [lPlayer, rPlayer];

			SendReply.kr(Impulse.kr(30), '/cursorPosition', pos, id);
			Out.ar(0, out * amp);
		}).add;

		s.sync;

		// Synths initialization
		track1 = Synth("forelEngine");
		track2 = Synth("forelEngine");
		track3 = Synth("forelEngine");

		s.sync;

		track1.set(\id, track1.nodeID);
		track2.set(\id, track2.nodeID);
		track3.set(\id, track3.nodeID);

		s.sync;

		window = Window("Forel", Rect(200, 500, 800, 462), false).front;
		window.alpha = 0.95;
		window.onClose = {
			soundFile.free;
			leftBuf.free;
			rightBuf.free;
			posFunc.free;
			track1.free;
			track2.free;
			track3.free;
		};

		// Sound views
		soundFileView1 = SoundFileView(window, Rect(101, 10, 579, 126));
		soundFileView2 = SoundFileView(window, Rect(101, 146, 579, 126));
		soundFileView3 = SoundFileView(window, Rect(101, 283, 579, 126));

		soundFile = SoundFile.new;
		soundFile.openRead(filePath.resolveRelative);

		soundFileView1.soundfile = soundFile;
		soundFileView1.read(0, soundFile.numFrames);
		soundFileView1.refresh;
		soundFileView1.gridOn = false;
		soundFileView1.timeCursorOn = true;
		soundFileView1.timeCursorColor = Color.new255(240,234,210);
		soundFileView1.rmsColor = Color.new255(151,191,183);
		soundFileView1.peakColor = Color.new255(109,166,162);
		soundFileView1.background = Color.new255(11,29,39);

		soundFileView2.soundfile = soundFile;
		soundFileView2.read(0, soundFile.numFrames);
		soundFileView2.refresh;
		soundFileView2.gridOn = false;
		soundFileView2.timeCursorOn = true;
		soundFileView2.timeCursorColor = Color.new255(240,234,210);
		soundFileView2.rmsColor = Color.new255(151,191,183);
		soundFileView2.peakColor = Color.new255(109,166,162);
		soundFileView2.background = Color.new255(11,29,39);

		soundFileView3.soundfile = soundFile;
		soundFileView3.read(0, soundFile.numFrames);
		soundFileView3.refresh;
		soundFileView3.gridOn = false;
		soundFileView3.timeCursorOn = true;
		soundFileView3.timeCursorColor = Color.new255(240,234,210);
		soundFileView3.rmsColor = Color.new255(151,191,183);
		soundFileView3.peakColor = Color.new255(109,166,162);
		soundFileView3.background = Color.new255(11,29,39);

		posFunc = OSCFunc({arg msg;
			AppClock.sched(0.0, {
				msg[2].switch(
					track1.nodeID, {soundFileView1.timeCursorPosition = msg[3]},
					track2.nodeID, {soundFileView2.timeCursorPosition = msg[3]},
					track3.nodeID, {soundFileView3.timeCursorPosition = msg[3]}
				);

			});
		}, '/cursorPosition');

		// Master volume
		masterVol = Slider(window, Rect(690, 10, 100, 400));

		masterVol.action = {
			track1.set(\amp, masterVol.value);
			track2.set(\amp, masterVol.value);
			track3.set(\amp, masterVol.value);
		};

		label = StaticText(window, Rect(690, 410, 100, 50));
		label.string = "Volume";
		label.align = \center;

		// Octave transposition
		track1Oct = NumberBox(window, Rect(60, 63, 30, 20));
		label = StaticText(window, Rect(10, 63, 50, 20));
		label.string = "Octave:";
		track1Oct.clipLo = -5;
		track1Oct.clipHi = 5;
		track1Oct.action = {
			track1.set(\oct, 2**(track1Oct.value));
		};
		track1Oct.valueAction = -1;

		track2Oct = NumberBox(window, Rect(60, 199, 30, 20));
		label = StaticText(window, Rect(10, 199, 50, 20));
		label.string = "Octave:";
		track2Oct.clipLo = -5;
		track2Oct.clipHi = 5;
		track2Oct.action = {
			track2.set(\oct, 2**(track2Oct.value));
		};
		track2Oct.valueAction = -2;

		track3Oct = NumberBox(window, Rect(60, 336, 30, 20));
		label = StaticText(window, Rect(10, 336, 50, 20));
		label.string = "Octave:";
		track3Oct.clipLo = -5;
		track3Oct.clipHi = 5;
		track3Oct.action = {
			track3.set(\oct, 2**(track3Oct.value));
		};
		track3Oct.valueAction = -3;

		// Transpose
		transpose = PopUpMenu(window, Rect(414, 431, 80, 20));
		transpose.items = [
			"E/C#m", "F/Dm", "F#/D#m",
			"G/Em", "Ab/Fm", "A/F#m",
			"Bb/Gm", "B/G#m", "C/Am",
			"Db/Bbm", "D/Bm", "Eb/Cm"
		];
		transpose.action = {arg menu;
			track1.set(\transpose, menu.value.midiratio);
			track2.set(\transpose, menu.value.midiratio);
			track3.set(\transpose, menu.value.midiratio);
		};

		label = StaticText(window, Rect(341, 431, 65, 20));
		label.string = "Transpose:";

		// Buttons
		resetButton = Button(window, Rect(121, 419, 100, 33));
		resetButton.states = [["Reset"],["Reset"]];
		resetButton.action = {arg butt;
			track1.set(\trig, butt.value);
			track2.set(\trig, butt.value);
			track3.set(\trig, butt.value);
		};

		pauseButton = Button(window, Rect(231, 419, 100, 33));
		pauseButton.states = [["Paused"], ["Playing"]];
		pauseButton.action = {arg butt;
			track1.set(\pause, butt.value);
			track2.set(\pause, butt.value);
			track3.set(\pause, butt.value);
		};
	});
);
