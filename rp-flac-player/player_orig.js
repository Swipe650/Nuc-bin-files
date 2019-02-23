 /*!
 *  Howler.js Audio Player Demo
 *  howlerjs.com
 *
 *  (c) 2013-2018, James Simpson of GoldFire Studios
 *  goldfirestudios.com
 *
 *  MIT License
 */

// Cache references to DOM elements.
var elms = ['track', 'album', 'timer', 'duration', 'playBtn', 'pauseBtn', 'prevBtn', 'nextBtn', 'playlistBtn', 'volumeBtn', 'loading', 'playlist', 'list', 'volume', 'barEmpty', 'barFull', 'sliderBtn', 'cover', 'nextLoading', 'prevLoading', 'progress'];
elms.forEach(function(elm) {
  window[elm] = document.getElementById(elm);
});

/**
 * Player class containing the state of our playlist and where we are in it.
 * Includes all methods for playing, skipping, updating the display, etc.
 * @param {Array} playlist Array of objects with playlist song details ({title, file, howl}).
 */
var Player = function(playlist) {
  this.playlist = playlist;
  this.index = 0;

  // Display the title of the first track.
  track.innerHTML = playlist.songs[0].artist + ' - ' + playlist.songs[0].title;
  album.innerHTML = 'Album: ' + playlist.songs[0].album + ' (' + playlist.songs[0].year+ ')';
  cover.innerHTML = "<img src=\'" + playlist.songs[0].cover + "\'>";

  while (list.hasChildNodes()) {   
    list.removeChild(list.firstChild);
  }

  // Setup the playlist display.
  var playlistLength = playlist.songs.length;
  for (var i = 0; i < playlistLength; i++) {
    var currentPlaylistItem = playlist.songs[i];
    var div = document.createElement('div');
    div.className = 'list-song';
    div.innerHTML = currentPlaylistItem.artist + ' - ' + currentPlaylistItem.title;
    div.index = i;
    div.onclick = function() {
      player.playlistSkipTo(this.index);
    };
    list.appendChild(div);
  }

};
Player.prototype = {
  /**
   * Play a song in the playlist.
   * @param  {Number} index Index of the song in the playlist (leave empty to play the first or current).
   */
  play: function(index) {
    var self = this;
    var sound;
    var updateTitle;

    index = typeof index === 'number' ? index : self.index;
    var data = self.playlist;

    // If we already loaded this track, use the current one.
    // Otherwise, setup and load a new Howl.
    if (data.howl) {
      sound = data.howl;
    } else {
      sound = data.howl = new Howl({
        src: [data.file],
        html5: true, // Force to HTML5 so that the audio can stream in (best for large files).
        onplay: function() {
          playBtn.style.display = 'none';
          pauseBtn.style.display = 'block';
          clearInterval(updateTitle);
          // Start upating the progress of the track.
          setTimeout(function() {
            requestAnimationFrame(self.step.bind(self));
            // magical code here
          }, 1000);
          updateTitle = setInterval(function(){ self.updateTitleInHtml() }, 3000);
        },
        onload: function() {
          clearInterval(updateTitle);
          loading.style.display = 'none';
          getNextEventAndAddToPlaylist(self);
        },
        onend: function() {
          clearInterval(updateTitle);
          data.howl.stop();
          self.pause();
          player = new Player(nextPlaylist);
          player.play();
        },
        onpause: function() {
          clearInterval(updateTitle);
        },
        onstop: function() {
          clearInterval(updateTitle);
        }
      });
    }

    // Begin playing the sound.
    sound.play();

    // Update the track display.
    if(!data.songs[index]) {
        index = 0;
    }
    track.innerHTML = data.songs[index].artist + ' - ' + data.songs[index].title;
    album.innerHTML = 'Album: ' + data.songs[index].album + ' (' + data.songs[index].year+ ')';
    cover.innerHTML = "<img src=\'" + data.songs[index].cover + "\'>";
    // Show the pause button.
    if (sound.state() === 'loaded') {
      playBtn.style.display = 'none';
      pauseBtn.style.display = 'block';
    } else {
      loading.style.display = 'block';
      playBtn.style.display = 'none';
      pauseBtn.style.display = 'none';
    }

    // Keep track of the index we are currently playing.
    self.index = index;
  },

  /**
   * Pause the currently playing track.
   */
  pause: function() {
    var self = this;

    // Get the Howl we want to manipulate.
    var sound = self.playlist.howl;

    // Pause the sound.
    sound.pause();

    // Show the play button.
    playBtn.style.display = 'block';
    pauseBtn.style.display = 'none';
  },

  /**
   * Skip to the next or previous track.
   * @param  {String} direction 'next' or 'prev'.
   */
  skip: function(direction) {
    var self = this;
    nextBtn.style.display = 'none';
    prevBtn.style.display = 'none';
    prevLoading.style.display = 'block';
    nextLoading.style.display = 'block';
    setTimeout(function(){ showButtons(); }, 3000);
    self.playlist.howl.stop();
    clearInterval(self.updateTitle);

    // Get the next track based on the direction of the track.
    var index = 0;
    if (direction === 'prev') {
      index = self.index - 1;
      if (index < 0) {
        index = 0;
      }
      self.skipTo(index);
    } else {
      index = self.index + 1;
      if (index >= self.playlist.songs.length) {
        if(self.playlist.file == nextPlaylist.file) {
          index = 0;
          self.skipTo(index);
        } else {
          self.playlist.howl.stop();
          player = new Player(nextPlaylist);
          player.play();
        }
      } else {
        self.skipTo(index);
      }
    }
  },

  /**
   * Skip to a specific track based on its playlist index.
   * @param  {Number} index Index in the playlist.
   */
  skipTo: function(index) {
    var self = this;
    clearInterval(self.updateTitle);

    // Stop the current track.
    self.playlist.howl.stop();
    self.play(index); 
    this.seekTo(index, self.playlist);
  },

  /**
   * skip from Playlist to a specific track based on its playlist index.
   * @param  {Number} index Index in the playlist.
   */
  playlistSkipTo: function(index) {
    var self = this;
    nextBtn.style.display = 'none';
    prevBtn.style.display = 'none';
    prevLoading.style.display = 'block';
    nextLoading.style.display = 'block';
    setTimeout(function(){ showButtons(); }, 3000);
    this.skipTo(index);
  },

  /**
   * Set the volume and update the volume slider display.
   * @param  {Number} val Volume between 0 and 1.
   */
  volume: function(val) {
    var self = this;

    // Update the global volume (affecting all Howls).
    Howler.volume(val);

    // Update the display on the slider.
    var barWidth = (val * 90) / 100;
    barFull.style.width = (barWidth * 100) + '%';
    sliderBtn.style.left = (window.innerWidth * barWidth + window.innerWidth * 0.05 - 25) + 'px';
  },

  /**
   * Seek to a new position in the currently playing track.
   */
  seekTo: function(index, data) {
    var self = this;
    // Convert the percent into a seek position.
    var seekToPosition = data.totalLength * data.songs[index].begin;
    data.howl.seek(seekToPosition);   
  },

  /**
   * The step called within requestAnimationFrame to update the playback position.
   */
  step: function() {
