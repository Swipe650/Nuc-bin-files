import eventlet
eventlet.monkey_patch()  # Must be the very first thing

import time
import requests
from flask import Flask, render_template_string, request, jsonify
from flask_socketio import SocketIO

app = Flask(__name__)
socketio = SocketIO(app, cors_allowed_origins="*")

BASE_URL = "http://127.0.0.1:47836"
CURRENT_URL = f"{BASE_URL}/current"
POLL_INTERVAL = 1

HTML_TEMPLATE = """
<!DOCTYPE html>
<html>
<head>
    <title id="page-title">Now Playing</title>
    <link id="favicon" rel="icon" type="image/png" href="">
    <script src="https://cdn.socket.io/4.7.2/socket.io.min.js"></script>
    <style>
        body { margin:0; font-family:-apple-system; color:white; overflow:hidden; }
        .bg { position:fixed; width:100%; height:100%; background-size:cover; filter:blur(10px) brightness(0.35); z-index:-1; transition: background-image 0.5s ease; }
        .overlay { display:flex; height:100vh; align-items:center; justify-content:center; }
        .card { display:flex; gap:40px; background:rgba(0,0,0,0.4); padding:30px; border-radius:20px; backdrop-filter:blur(20px); max-width:90vw; }
        .art { width:260px; border-radius:16px; }
        .info { 
            display:flex; 
            flex-direction:column; 
            justify-content:center; 
            min-width: 400px;  /* Set minimum width to match previous fixed size */
            flex: 1;
        }
        .track { 
            font-size:2em; 
            word-break:break-word; 
            overflow-wrap:break-word;
        }
        .artist { color:#ccc; }
        .album { color:#999; margin-bottom:20px; }
        .progress-container { 
            width:100%;  /* Dynamic width - fills the container */
            height:6px; 
            background:rgba(255,255,255,0.2); 
            border-radius:10px; 
            overflow:hidden; 
            cursor:pointer;
            min-width: 300px;  /* Ensure progress bar doesn't get too small */
        }
        .progress { height:100%; background:#1db954; width:0%; transition:width 0.2s linear; }
        .time { display:flex; justify-content:space-between; font-size:0.8em; color:#aaa; }
        .controls { margin-top:20px; display:flex; gap:20px; }
        .btn { background:rgba(255,255,255,0.1); border:none; color:white; padding:10px 15px; border-radius:10px; cursor:pointer; font-size:1em; }
        .btn:hover { background:rgba(255,255,255,0.25); }
        .meta { margin-top:10px; font-size:0.85em; color:#bbb; }
        
        /* Responsive adjustments */
        @media (max-width: 768px) {
            .card { flex-direction: column; align-items: center; gap:20px; padding:20px; }
            .art { width:200px; }
            .track { font-size:1.5em; text-align:center; }
            .artist, .album { text-align:center; }
            .info { min-width: 280px; }  /* Slightly smaller minimum on mobile */
        }
    </style>
</head>
<body>
    <div id="bg" class="bg"></div>
    <div class="overlay">
        <div class="card">
            <img id="art" class="art" src="" />
            <div class="info">
                <div id="track" class="track"></div>
                <div id="artist" class="artist"></div>
                <div id="album" class="album"></div>
                <div class="progress-container" id="progress-container">
                    <div id="progress" class="progress"></div>
                </div>
                <div class="time">
                    <span id="current"></span>
                    <span id="duration"></span>
                </div>
                <div class="controls">
                    <button class="btn" onclick="control('previous')">⏮</button>
                    <button class="btn" onclick="control('playpause')">⏯</button>
                    <button class="btn" onclick="control('next')">⏭</button>
                </div>
                <div id="meta" class="meta"></div>
            </div>
        </div>
    </div>
<script>
const socket = io();
let trackDurationSec = 0;

socket.on('update', (data) => {
    document.getElementById('track').innerText = data.track;
    document.getElementById('artist').innerText = data.artist;
    document.getElementById('album').innerText = data.album;
    document.getElementById('current').innerText = data.current;
    document.getElementById('duration').innerText = data.duration;
    document.getElementById('progress').style.width = data.progress + '%';
    document.getElementById('meta').innerText = `Volume: ${data.volume}% | Shuffle: ${data.shuffle} | Repeat: ${data.repeat}`;
    document.getElementById('art').src = data.art;
    document.getElementById('bg').style.backgroundImage = `url('${data.art}')`;
    document.getElementById('page-title').innerText = `${data.artist} - ${data.track}`;
    document.getElementById('favicon').href = data.art;

    trackDurationSec = data.duration_sec || trackDurationSec;
});

function control(action) {
    fetch(`/control/${action}`, { method: 'POST' });
}

const progressContainer = document.getElementById('progress-container');
progressContainer.addEventListener('click', (e) => {
    const rect = progressContainer.getBoundingClientRect();
    const clickX = e.clientX - rect.left;
    const width = rect.width;
    const percent = clickX / width;
    const seekSeconds = Math.floor(percent * trackDurationSec);

    fetch(`/seek/${seekSeconds}`, { method: 'PUT' });
});
</script>
</body>
</html>
"""

def get_current_track():
    try:
        data = requests.get(CURRENT_URL).json()
        current_sec = data.get("currentInSeconds", 0)
        duration_sec = data.get("durationInSeconds", 1)
        progress = (current_sec / duration_sec) * 100 if duration_sec else 0
        return {
            "track": data.get("title"),
            "artist": data.get("artist"),
            "album": data.get("album"),
            "art": data.get("image"),
            "current": data.get("current"),
            "duration": data.get("duration"),
            "duration_sec": duration_sec,
            "progress": progress,
            "volume": round(data.get("volume", 0) * 100),
            "shuffle": data.get("player", {}).get("shuffle"),
            "repeat": data.get("player", {}).get("repeat")
        }
    except Exception as e:
        print("ERROR:", e)
        return {}

def background_task():
    while True:
        socketio.emit('update', get_current_track())
        socketio.sleep(POLL_INTERVAL)

@app.route('/')
def index():
    return render_template_string(HTML_TEMPLATE)

@app.route('/control/<action>', methods=['POST'])
def control(action):
    try:
        url = None
        if action == 'playpause': url = f"{BASE_URL}/player/playpause"
        elif action == 'next': url = f"{BASE_URL}/player/next"
        elif action == 'previous': url = f"{BASE_URL}/player/previous"
        if url:
            try:
                requests.post(url, timeout=2)
            except Exception:
                try:
                    requests.get(url, timeout=2)
                except Exception as e:
                    print("CONTROL ERROR:", e)
    except Exception as e:
        print("CONTROL ROUTE ERROR:", e)
    return ('', 204)

@app.route('/seek/<int:seconds>', methods=['PUT'])
def seek(seconds):
    try:
        url = f"{BASE_URL}/player/seek/absolute?seconds={seconds}"
        try:
            requests.put(url, timeout=2)
        except Exception:
            try:
                requests.get(url, timeout=2)
            except Exception as e:
                print("SEEK ERROR:", e)
    except Exception as e:
        print("SEEK ROUTE ERROR:", e)
    return ('', 204)

@socketio.on('connect')
def connect():
    print("Client connected")

if __name__ == '__main__':
    socketio.start_background_task(background_task)
    socketio.run(app, host='0.0.0.0', port=5000, debug=True)
