(
s.waitForBoot({
	var piecesPaths, selectedPiecePath, window, list, loadButton, alert,
	label, cpuPeak;

	alert = {arg message;
		var window, text, button;
		window = Window("Alert", Rect(200, 200, 200, 113), false).front;
		text = StaticText(window, Rect(10, 10, 180, 50));
		text.string = message;
		text.align = \center;
		text.font = Font("Helvetica", 15);

		button = Button(window, Rect(50, 70, 100, 33));
		button.states = [["OK"]];
		button.action = {window.close};
	};

	piecesPaths = Dictionary.new(8);
	piecesPaths["Igra vodi"] = "pieces/Igra Vodi.scd".resolveRelative;
	piecesPaths["Forel"] = "pieces/Forel.scd".resolveRelative;
	piecesPaths["Bluzhdayushchiye ogni"] = "pieces/Bluzhdayushchiye ogni.scd".resolveRelative;
	piecesPaths["Blumenstück"] = "pieces/Blumenstuck.scd".resolveRelative;
	piecesPaths["Babochki"] = "pieces/Babochki.scd".resolveRelative;
	piecesPaths["Viselitsa"] = "pieces/Viselitsa.scd".resolveRelative;
	piecesPaths["Rosinki"] = "pieces/Rosinki.scd".resolveRelative;
	piecesPaths["Shagi na snegu"] = "pieces/Shagi.scd".resolveRelative;

	window = Window.new("Player", Rect(100, 100, 270, 243), false).front;
	window.userCanClose = false;

	list = ListView(window, Rect(10, 10, 250, 180));
	list.items = ["Igra vodi", "Forel", "Rosinki", "Babochki", "Blumenstück",
		"Bluzhdayushchiye ogni", "Shagi na snegu", "Viselitsa"];
	list.selectionMode = \single;
	list.action = {selectedPiecePath = piecesPaths[list.items[list.value]]};
	list.valueAction = 0;
	list.font = Font("Helvetica", 20, true);

	loadButton = Button(window, Rect(10, 200, 100, 33));
	loadButton.states = [["Load"]];
	loadButton.action = {
		var windowsArray = Window.allWindows.collect({arg item; item.name});
		list.items[list.value].switch(
			"Rosinki", {if(windowsArray.any({|item| (item == "Rosinki")}), {
				alert.value("It's possible to open only one instance of the Rosinki".toUpper);
			}, {selectedPiecePath.load})},
			"Viselitsa", {if(windowsArray.any({|item| (item == "Viselitsa")}), {
				alert.value("It's possible to open only one instance of the Viselitsa".toUpper);
			}, {selectedPiecePath.load})},
			{selectedPiecePath.load}
		);
	};

	label = StaticText(window, Rect(160, 200, 100, 20));
	label.string = "Peak CPU";
	label.font = Font("Helvetica", 12);
	label.align = \center;

	cpuPeak = StaticText(window, Rect(160, 220, 100, 20));
	cpuPeak.align = \center;
	cpuPeak.font = Font("Helvetica", 20, true);
	AppClock.sched(0.0, {
		cpuPeak.string = s.peakCPU.round(0.01).asString++"%";
		1.0;
	});
});
)

Window.closeAll;