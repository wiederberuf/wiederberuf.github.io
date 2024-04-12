var tag = document.createElement('script');
  tag.src = "https://www.youtube.com/player_api";
  var firstScriptTag = document.getElementsByTagName('script')[0];
  firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);

  var videoIds = ['6gmCC4OkFx8', 'pmDl_y7dk_U', 'uioH5a6PNX8'];
  var startIndex = Math.floor(Math.random() * videoIds.length);
  // Replace the 'ytplayer' element with an <iframe> and
  // YouTube player after the API code downloads.
  var player;
  function onYouTubePlayerAPIReady() {
    player = new YT.Player('ytplayer', {
      height: '100%',
      width: '100%',
      // videoId: videoIds[startIndex],
      videoId: '7GhrD869S_E',
      events: {
            'onReady': onPlayerReady,
          },
      playerVars: {
        'autoplay': 1,
        'controls': 0,
        'disablekb': 1,
        'fs': 1,
        'loop': 1,
        'modestbranding': 1,
        'showinfo': 0,
        'mute': 1,
      }
      
    });
  }

     // 4. The API will call this function when the video player is ready.
      function onPlayerReady(event) {
        // player.loadPlaylist({ playlist: ['6gmCC4OkFx8', 'pmDl_y7dk_U'], index: startIndex });
        event.target.playVideo();
      }
