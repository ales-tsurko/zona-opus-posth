(function () {

   "use strict";

   if(flock.platform.isMobile) {
      alert("Zona Opus Posth does not works properly on mobile devices.");
   }

   fluid.registerNamespace("soundEngine");

   var enviro = flock.init({
      bufferSize: flock.defaultBufferSizeForPlatform(),
      audio: 44100
   });

   soundEngine.play = function () {

      function isPlaying() {
         if (enviro.model.isPlaying == false) {
            return enviro.play();
         }
      };

      //--------------Sound engine
      // Igra vodi

      var audioFileExtension;
      if(navigator.userAgent.indexOf("OPR") > 0) {
         audioFileExtension = ".ogg";
      } else {
         audioFileExtension = ".mp3";
      }

      function igraVodi () {
         return flock.synth({
            synthDef: [
               {
                  id: "igraGranulator_L",
                  ugen: "flock.ugen.triggerGrains",
                  dur: 1.0,
                  trigger: {
                     ugen: "flock.ugen.dust",
                     rate: "control",
                     density: 3
                  },
                  buffer: {
                     id: "igraVodiBuf",
                     url: "http://alestsurko.by/zona-opus-posth/sounds/igra_vodi".concat(audioFileExtension)
                  },
                  channel: 0,
                  centerPos: {
                     ugen: "flock.ugen.random.pareto",
                     rate: "control",
                     alpha: 1
                  },
                  amp: 0
               },

               {
                  id: "igraGranulator_R",
                  ugen: "flock.ugen.triggerGrains",
                  dur: 1.0,
                  trigger: {
                     ugen: "flock.ugen.dust",
                     rate: "control",
                     density: 3
                  },
                  buffer: {
                     id: "igraVodiBuf"
                  },
                  channel: 1,
                  centerPos: {
                     ugen: "flock.ugen.random.pareto",
                     rate: "control",
                     alpha: 1
                  },
                  amp: 0
               }
            ]
         });
      };

      var igraVodiSynth1 = igraVodi(),
      igraVodiSynth2 = igraVodi();

      igraVodiSynth1.set("igraGranulator_L.speed", 1.2599 * 0.5); // 1.2599 - 4 semitones up
      igraVodiSynth1.set("igraGranulator_R.speed", 1.2599 * 0.5);
      igraVodiSynth2.set("igraGranulator_L.speed", 1.2599 * 2.0);
      igraVodiSynth2.set("igraGranulator_R.speed", 1.2599 * 2.0);

      // Forel
      var forelTrack1 = Object.create(WaveSurfer);
      var forelTrack2 = Object.create(WaveSurfer);
      var forelTrack3 = Object.create(WaveSurfer);

      // Rosinki
      var i,
      numberOfRosinkiSamples = 17,
      rosinkiSamplesURLs = [],
      rosinkiBufferDefs = [],
      rosinkiBuffersIDs = [];

      for(i = 1; i <= numberOfRosinkiSamples; i++) {
         var stringTemplate = "http://alestsurko.by/zona-opus-posth/sounds/rosinki/rosinki_";
         rosinkiSamplesURLs.push((stringTemplate.concat(i)).concat(audioFileExtension));
      }

      for(i = 0; i < rosinkiSamplesURLs.length; i++) {
         rosinkiBufferDefs.push({
            url: rosinkiSamplesURLs[i]
         });
      }

      flock.bufferLoader({
         bufferDefs: rosinkiBufferDefs,
         listeners: {
            afterBuffersLoaded: function(buffers) {
               for(i = 0; i < buffers.length; i++) {
                  rosinkiBuffersIDs.push(buffers[i].id);
               }
            }
         }
      });

      var rosinkiSynth = flock.synth({
         synthDef: [
            {
               id: "rosinkiSampler_L",
               ugen: "flock.ugen.playBuffer",
               buffer: {
                  id: "rosinki_1"
               },
               trigger: {
                  id: "trigger_L",
                  ugen: "flock.ugen.valueChangeTrigger"
               },
               channel: 0,
               mul: 0
            },

            {
               id: "rosinkiSampler_R",
               ugen: "flock.ugen.playBuffer",
               buffer: {
                  id: "rosinki_1"
               },
               trigger: {
                  id: "trigger_R",
                  ugen: "flock.ugen.valueChangeTrigger"
               },
               channel: 1,
               mul: 0
            }
         ]
      });

      var interval = 500;

      function rosinkiCallback() {
         var newBuffer = flock.choose(rosinkiBuffersIDs);
         interval = (Math.random() * 3500) + 500;

         rosinkiSynth.set("rosinkiSampler_L.buffer", {
            id: newBuffer
         });
         rosinkiSynth.set("rosinkiSampler_R.buffer", {
            id: newBuffer
         });

         rosinkiSynth.set("trigger_L.source", 0);
         rosinkiSynth.set("trigger_R.source", 0);

         setTimeout(rosinkiCallback, interval);
      }

      setTimeout(rosinkiCallback, interval);

      // Babochki
      var babochkiBuffersIDs = [];

      flock.bufferLoader({
         bufferDefs: [
            {
               url: "http://alestsurko.by/zona-opus-posth/sounds/babochki/babochki001".concat(audioFileExtension)
            },
            {
               url: "http://alestsurko.by/zona-opus-posth/sounds/babochki/babochki002".concat(audioFileExtension)
            },
            {
               url: "http://alestsurko.by/zona-opus-posth/sounds/babochki/babochki003".concat(audioFileExtension)
            }
         ],

         listeners: {
            afterBuffersLoaded: function (buffers) {
               var i;
               for(i = 0; i < buffers.length; i++) {
                  babochkiBuffersIDs.push(buffers[i].id)
               }
            }
         }
      });

      function babochkiSynth() {
         return flock.synth({
            synthDef: [
               {
                  id: "babochkiSampler_L",
                  ugen: "flock.ugen.playBuffer",
                  buffer: {
                     id: "babochki001"
                  },
                  trigger: {
                     id: "trigger_L",
                     ugen: "flock.ugen.valueChangeTrigger"
                  },
                  loop: 1,
                  channel: 0,
                  mul: {
                     ugen: "flock.ugen.line",
                     start: 0.5,
                     end: 0,
                     duration: 35
                  }
               },

               {
                  id: "babochkiSampler_R",
                  ugen: "flock.ugen.playBuffer",
                  buffer: {
                     id: "babochki001"
                  },
                  trigger: {
                     id: "trigger_R",
                     ugen: "flock.ugen.valueChangeTrigger"
                  },
                  loop: 1,
                  channel: 1,
                  mul: {
                     ugen: "flock.ugen.line",
                     start: 0.5,
                     end: 0,
                     duration: 35
                  }
               }
            ]
         });
      };

      // Blumenstück
      var blumenSynth = flock.synth({
         synthDef: [
            {
               id: "blumenPlayer_L",
               ugen: "flock.ugen.playBuffer",
               buffer: {
                  id: "blumenstuck",
                  url: "http://alestsurko.by/zona-opus-posth/sounds/blumenstuck".concat(audioFileExtension)
               },
               loop: 1,
               channel: 0,
               speed: 1,
               mul: 0
            },

            {
               id: "blumenPlayer_R",
               ugen: "flock.ugen.playBuffer",
               buffer: {
                  id: "blumenstuck"
               },
               loop: 1,
               channel: 1,
               speed: 1,
               mul: 0
            }
         ]
      });

      // Bluzhdayushchiye ogni
      var ogniSynth = flock.synth({
         synthDef: [
            {
               id: "ogniGranulator_L",
               ugen: "flock.ugen.triggerGrains",
               dur: 0.1,
               trigger: {
                  id: "rate_L",
                  ugen: "flock.ugen.impulse",
                  rate: "control",
                  freq: 2
               },
               buffer: {
                  id: "ogniBuf",
                  url: "http://alestsurko.by/zona-opus-posth/sounds/bluzhdayushchiye_ogni".concat(audioFileExtension)
               },
               channel: 0,
               centerPos: {
                  ugen: "flock.ugen.random.pareto",
                  rate: "control",
                  alpha: 1
               },
               amp: 0
            },

            {
               id: "ogniGranulator_R",
               ugen: "flock.ugen.triggerGrains",
               dur: 0.1,
               trigger: {
                  id: "rate_R",
                  ugen: "flock.ugen.impulse",
                  rate: "control",
                  freq: 2
               },
               buffer: {
                  id: "ogniBuf"
               },
               channel: 1,
               centerPos: {
                  ugen: "flock.ugen.random.pareto",
                  rate: "control",
                  alpha: 1
               },
               amp: 0
            }
         ]
      });

      // Shagi na snegu
      var shagiTrack = Object.create(WaveSurfer);

      // Viselitsa
      var viselitsaBuffersIDs = [];

      flock.bufferLoader({
         bufferDefs: [
            {
               url: "http://alestsurko.by/zona-opus-posth/sounds/viselitsa/viselitsa_001".concat(audioFileExtension)
            },
            {
               url: "http://alestsurko.by/zona-opus-posth/sounds/viselitsa/viselitsa_002".concat(audioFileExtension)
            },
            {
               url: "http://alestsurko.by/zona-opus-posth/sounds/viselitsa/viselitsa_003".concat(audioFileExtension)
            },
            {
               url: "http://alestsurko.by/zona-opus-posth/sounds/viselitsa/viselitsa_004".concat(audioFileExtension)
            },
            {
               url: "http://alestsurko.by/zona-opus-posth/sounds/viselitsa/viselitsa_005".concat(audioFileExtension)
            },
            {
               url: "http://alestsurko.by/zona-opus-posth/sounds/viselitsa/viselitsa_006".concat(audioFileExtension)
            }
         ],

         listeners: {
            afterBuffersLoaded: function (buffers) {
               var i;
               for(i = 0; i < buffers.length; i++) {
                  viselitsaBuffersIDs.push(buffers[i].id)
               }
            }
         }
      });

      var viselitsaSynth = flock.synth({
         synthDef: [
            {
               id: "viselitsaSampler_L",
               ugen: "flock.ugen.playBuffer",
               buffer: {
                  id: "viselitsa_001"
               },
               trigger: {
                  id: "trigger_L",
                  ugen: "flock.ugen.valueChangeTrigger"
               },
               channel: 0,
               mul: 0
            },

            {
               id: "viselitsaSampler_R",
               ugen: "flock.ugen.playBuffer",
               buffer: {
                  id: "viselitsa_001"
               },
               trigger: {
                  id: "trigger_R",
                  ugen: "flock.ugen.valueChangeTrigger"
               },
               channel: 1,
               mul: 0
            }
         ]
      });


      //----------------GUI

      // Sound views
      document.addEventListener('DOMContentLoaded', function () {

         function addTrack(track, containerID, isInteract, fileURL) {
            return function() {
               track.init({
                  container: document.querySelector(containerID),
                  height: 50,
                  // waveColor: '#961227',
                  waveColor: '#24262D',
                  progressColor: '#961227',
                  loaderColor: '#961227',
                  cursorColor: '#961227',
                  cursorWidth: 2,
                  interact: isInteract
               });

               track.load(fileURL);
            }();
         };

         // Forel
         var forelFileURL = 'http://alestsurko.by/zona-opus-posth/sounds/forel'.concat(audioFileExtension);

         addTrack(forelTrack1, '#forelFirstWave', true, forelFileURL);
         addTrack(forelTrack2, '#forelSecondWave', true, forelFileURL);
         addTrack(forelTrack3, '#forelThirdWave', true, forelFileURL);

         forelTrack1.on('ready', function() {
            forelTrack1.play();
         });

         forelTrack2.on('ready', function() {
            forelTrack2.play();
         });

         forelTrack3.on('ready', function() {
            forelTrack3.play();
         });

         forelTrack1.on('finish', function() {
            forelTrack1.play();
         });

         forelTrack2.on('finish', function() {
            forelTrack2.play();
         });

         forelTrack3.on('finish', function() {
            forelTrack3.play();
         });

         // Shagi na snegu
         var shagiFileURL = "http://alestsurko.by/zona-opus-posth/sounds/shagi_na_snegu".concat(audioFileExtension);

         addTrack(shagiTrack, "#shagiWave", false, shagiFileURL);

         shagiTrack.on("ready", function() {
            var shagiRegion = shagiTrack.addRegion({
               start: 9,
               end: 58,
               loop: true,
               color: "rgba(150, 18, 39, 0.3)"
            });

            shagiRegion.on("dblclick", function() {
               shagiRegion.update({
                  start: 0,
                  end: shagiTrack.getDuration() - 0.5
               });
            });

            shagiRegion.on("click", function() {
               shagiTrack.stop();
               shagiRegion.play();
               shagiTrack.play();
            });

            shagiRegion.play();
            shagiTrack.play();
         });

      });

      // Controllers
      nx.onload = function () {

         nx.sendsTo("js");
         nx.colorize("#961227");
         nx.colorize("border", "#961227");
         nx.colorize("fill", "#24262D");
         nx.colorize("black", "#961227");

         // Igra vodi
         igraVolume1.set({
            value: 0.0
         }, true);

         igraVolume1.on('value', function(value){
            igraVodiSynth1.set("igraGranulator_L.amp", value * 0.7);
            igraVodiSynth1.set("igraGranulator_R.amp", value * 0.7);
            isPlaying();
         });

         igraVolume2.set({
            value: 0.0
         }, true);

         igraVolume2.on('value', function(value){
            igraVodiSynth2.set("igraGranulator_L.amp", value * 0.7);
            igraVodiSynth2.set("igraGranulator_R.amp", value * 0.7);
            isPlaying();
         });

         // Forel
         // Volume
         forelVolume.on('value', function(value) {
            forelTrack1.setVolume(value);
            forelTrack2.setVolume(value);
            forelTrack3.setVolume(value);
         });

         forelVolume.set({
            value: 0.7
         }, true);

         // Reset playing to 0 position
         forelReset.on('press', function(value) {
            if (value == 1) {
               forelTrack1.stop();
               forelTrack1.play();

               forelTrack2.stop();
               forelTrack2.play();

               forelTrack3.stop();
               forelTrack3.play();
            }
         });

         // Octave transposition
         forelFirstOct.decimalPlaces = 0;
         forelSecondOct.decimalPlaces = 0;
         forelThirdOct.decimalPlaces = 0;

         forelFirstOct.on('value', function(value) {
            forelTrack1.setPlaybackRate(Math.pow(2, value));
         });

         forelFirstOct.set({
            value: -1
         }, true);

         forelSecondOct.on('value', function(value) {
            forelTrack2.setPlaybackRate(Math.pow(2, value));
         });

         forelSecondOct.set({
            value: -2
         }, true);

         forelThirdOct.on('value', function(value) {
            forelTrack3.setPlaybackRate(Math.pow(2, value));
         });

         forelThirdOct.set({
            value: -3
         }, true);

         // Rosinki
         rosinkiVolume.set({
            value: 0
         }, true);

         rosinkiVolume.on("value", function(value) {
            rosinkiSynth.set("rosinkiSampler_L.mul", value * 0.8);
            rosinkiSynth.set("rosinkiSampler_R.mul", value * 0.8);
            isPlaying();
         });

         // Babochki
         // Trigger
         babochkiTrigger.on("press", function(value) {
            if(value == 1) {
               var newBuffer = flock.choose(babochkiBuffersIDs);
               var synth = babochkiSynth();

               synth.set({
                  "babochkiSampler_L.buffer": {
                     id: newBuffer
                  },
                  "babochkiSampler_R.buffer": {
                     id: newBuffer
                  },
                  "trigger_L.source": value,
                  "trigger_R.source": value
               });

               setTimeout(function () {synth.pause();}, 35000);
            }

            isPlaying();
         });

         // Blumenstück
         // Volume
         blumenVolume.set({
            value: 0
         }, true);

         blumenVolume.on("value", function(value) {
            blumenSynth.set({
               "blumenPlayer_L.mul": value,
               "blumenPlayer_R.mul": value
            });
            isPlaying();
         });

         // Loop range
         blumenRange.mode = "edge";

         blumenRange.on("*", function(object) {
            blumenSynth.set({
               "blumenPlayer_L.start": object.start,
               "blumenPlayer_R.start": object.start,
               "blumenPlayer_L.end": object.stop,
               "blumenPlayer_R.end": object.stop,
            });
         });

         blumenRange.set({
            start: 0.5,
            stop: 0.7
         }, true);

         // Octave transposition
         var oct = 1;
         blumenOct.decimalPlaces = 0;

         blumenOct.on("value", function(value) {
            oct = Math.pow(2, value);
            blumenSynth.set({
               "blumenPlayer_L.speed": blumenDirection * oct,
               "blumenPlayer_R.speed": blumenDirection * oct,
            });
         });

         blumenOct.set({
            value: -1
         }, true);

         // Direction change
         var blumenDirection = 1,
         blumenCallbackInterval;
         blumenRate.responsivity = 0.04;

         blumenRate.on("value", function(value) {
            blumenCallbackInterval = (1.07 - value) * 1000;
         });

         blumenRate.set({
            value: 0.7
         }, true);

         function blumenCallback() {
            blumenDirection = flock.choose([-1,1]);
            blumenSynth.set({
               "blumenPlayer_L.speed": blumenDirection * oct,
               "blumenPlayer_R.speed": blumenDirection * oct,
            });

            setTimeout(blumenCallback, blumenCallbackInterval);
         }

         setTimeout(blumenCallback, blumenCallbackInterval);

         // Bluzhdayushchiye ogni
         ogniRate.responsivity = 0.04;

         ogniVolume.set({
            value: 0
         }, true);

         ogniVolume.on("value", function(value) {
            ogniSynth.set({
               "ogniGranulator_L.amp": value * 0.5,
               "ogniGranulator_R.amp": value * 0.5
            });
            isPlaying();
         });

         ogniDuration.on("value", function(value) {
            ogniSynth.set({
               "ogniGranulator_L.dur": value * 0.5 + 0.015,
               "ogniGranulator_R.dur": value * 0.5 + 0.015,
            });
         });

         ogniDuration.set({
            value: 0.015
         }, true);

         ogniRate.on("value", function(value) {
            ogniSynth.set({
               "rate_L.freq": value * 20 + 1,
               "rate_R.freq": value * 20 + 1
            });
         });

         ogniRate.set({
            value: 0.7
         }, true);

         // Shagi na snegu
         // Volume
         shagiVolume.on("value", function(value) {
            shagiTrack.setVolume(value);
         });

         shagiVolume.set({
            value: 0
         }, true);

         // Reset playing to 0 position
         shagiReset.on('press', function(value) {
            if (value == 1) {
               shagiTrack.stop();
               shagiTrack.play();
            }
         });

         // Octave transposition
         shagiOct.decimalPlaces = 0;

         shagiOct.on("value", function(value) {
            shagiTrack.setPlaybackRate(Math.pow(2, value));
         });

         shagiOct.set({
            value: -1
         }, true);

         // Viselitsa
         // Trigger
         viselitsaTrigger.on("press", function(value) {

            if(value == 1) {
               var newBuffer = flock.choose(viselitsaBuffersIDs);
               viselitsaSynth.set({
                  "viselitsaSampler_L.buffer": {
                     id: newBuffer
                  },
                  "viselitsaSampler_R.buffer": {
                     id: newBuffer
                  },
                  "trigger_L.source": value,
                  "trigger_R.source": value,
                  "viselitsaSampler_L.mul": 0.7,
                  "viselitsaSampler_R.mul": 0.7,
               });
            };

            isPlaying();
         });

      };
   };

}());
