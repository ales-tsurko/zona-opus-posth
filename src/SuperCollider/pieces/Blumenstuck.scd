AppClock.play(
	Routine.run({
		var filePath, leftBuf, rightBuf,
		window,
		soundFileView, soundFile,
		playingRange,
		directionChangeRate, directionChangeKnob, routine,
		track,
		posFunc,
		masterVol,
		trackOct,
		transpose,
		resetButton, pauseButton,
		label;

		filePath = "sounds/blumenstuck.wav".resolveRelative;

		leftBuf = Buffer.readChannel(s, filePath, channels: 0);
		rightBuf = Buffer.readChannel(s, filePath, channels: 1);

		s.sync;

		// The player
		SynthDef("blumenstuckEngine", {arg trig = 0, transpose = 1, oct, pause = 0, reverse = 1,
			start = 0, end = 1, id, amp;
			var pos, lPlayer, rPlayer, out;
			pos = Phasor.ar(
				Changed.kr(trig),
				BufRateScale.kr(leftBuf.bufnum) * transpose * oct * pause * reverse,
				BufFrames.kr(leftBuf.bufnum) * start,
				BufFrames.kr(leftBuf.bufnum) * end,
				BufFrames.kr(leftBuf.bufnum) * start);
			lPlayer = BufRd.ar(1, leftBuf.bufnum, pos, 1);
			rPlayer = BufRd.ar(1, rightBuf.bufnum, pos, 1);

			out = [lPlayer, rPlayer];

			SendReply.kr(Impulse.kr(30), '/cursorPosition', pos, id);
			Out.ar(0, out * amp);
		}).add;

		s.sync;

		// Synths initialization
		track = Synth("blumenstuckEngine");

		s.sync;

		track.set(\id, track.nodeID);

		s.sync;

		window = Window("Blumenstück", Rect(200, 500, 800, 462), false).front;
		window.alpha = 0.95;
		window.onClose = {
			soundFile.free;
			leftBuf.free;
			rightBuf.free;
			posFunc.free;
			track.free;
			routine.stop;
			routine.free;
		};

		// Sound views
		soundFile = SoundFile.new;
		soundFile.openRead(filePath);

		soundFileView = SoundFileView(window, Rect(101, 10, 579, 290));
		soundFileView.soundfile = soundFile;
		soundFileView.read(0, soundFile.numFrames);
		soundFileView.refresh;
		soundFileView.gridOn = false;
		soundFileView.timeCursorOn = true;
		soundFileView.timeCursorColor = Color.new255(240,234,210);
		soundFileView.rmsColor = Color.new255(151,191,183);
		soundFileView.peakColor = Color.new255(109,166,162);
		soundFileView.background = Color.new255(109,166,162);
		soundFileView.setSelectionColor(0, Color.new255(11,29,39));
		posFunc = OSCFunc({arg msg;
			AppClock.sched(0.0, {
				if(msg[2] == track.nodeID, {soundFileView.timeCursorPosition = msg[3]});
			});
		}, '/cursorPosition');
		soundFileView.setSelectionSize(0,  soundFile.numFrames);

		// Playing range
		playingRange = RangeSlider(window, Rect(101, 310, 579, 100));
		playingRange.knobColor = Color.new255(11,29,39);
		playingRange.action = {
			var selectionSize = (soundFile.numFrames * playingRange.hi) - (soundFile.numFrames * playingRange.lo);

			track.set(\start, playingRange.lo);
			track.set(\end, playingRange.hi);
			soundFileView.setSelectionStart(0, soundFile.numFrames * playingRange.lo);
			soundFileView.setSelectionSize(0,  selectionSize);
		};

		soundFileView.action = {
			var selectionSize = soundFileView.selection(0)[1] / soundFile.numFrames;
			playingRange.activeLo = soundFileView.selection(0)[0] / soundFile.numFrames;
			playingRange.activeHi = (soundFileView.selection(0)[0] / soundFile.numFrames) + selectionSize;
		};

		// Direction change
		directionChangeKnob = Knob(window, Rect(690, 310, 100, 100));
		label = StaticText(window, Rect(690, 410, 100, 50));
		label.string = "Direction Change Rate";
		label.align = \center;

		directionChangeKnob.mode = \vert;
		directionChangeKnob.action = {
			directionChangeRate = 0.999 * (1-directionChangeKnob.value) + 0.001;
		};

		directionChangeKnob.valueAction = 0;
		routine = Routine({
			loop{
				track.set(\reverse, [-1,1].choose);
				directionChangeRate.wait;
			}
		});
		routine.play;

		// Master volume
		masterVol = Slider(window, Rect(690, 10, 100, 290));
		masterVol.action = {track.set(\amp, masterVol.value)};

		// Octave transposition
		trackOct = NumberBox(window, Rect(60, 145, 30, 20));
		label = StaticText(window, Rect(10, 145, 50, 20));
		label.string = "Octave:";
		trackOct.clipLo = -5;
		trackOct.clipHi = 5;
		trackOct.action = {track.set(\oct, 2**(trackOct.value))};
		trackOct.valueAction = 3;

		// Transpose
		transpose = PopUpMenu(window, Rect(414, 431, 80, 20));
		transpose.items = [
			"A/F#m", "Bb/Gm", "B/G#m",
			"C/Am", "Db/Bbm", "D/Bm",
			"Eb/Cm", "E/C#m", "F/Dm",
			"F#/D#m", "G/Em", "Ab/Fm"
		];
		transpose.action = {arg menu; track.set(\transpose, menu.value.midiratio)};

		label = StaticText(window, Rect(341, 431, 65, 20));
		label.string = "Transpose:";

		// Buttons
		resetButton = Button(window, Rect(121, 419, 100, 33));
		resetButton.states = [["Reset"],["Reset"]];
		resetButton.action = {arg butt; track.set(\trig, butt.value)};

		pauseButton = Button(window, Rect(231, 419, 100, 33));
		pauseButton.states = [["Paused"], ["Playing"]];
		pauseButton.action = {arg butt; track.set(\pause, butt.value)};
	});
)