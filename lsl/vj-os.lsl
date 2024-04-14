integer face = 0;

key ToucherID;

integer dialogChannel;
integer listenHandle;


show(string html)
{
    html = "data:text/html," + llEscapeURL(html);
    llSetPrimMediaParams(face,                  // Side to display the media on.
            [PRIM_MEDIA_AUTO_PLAY,TRUE,      // Show this page immediately
             PRIM_MEDIA_CURRENT_URL,html,    // The url currently showing
             PRIM_MEDIA_HOME_URL,html]);
}
showVideo(string video)
{
    string theUrl = "https://wiederberuf.github.io/index.html?videoId=" + video;
    list params = [
        PRIM_MEDIA_AUTO_PLAY, TRUE,
        PRIM_MEDIA_CURRENT_URL, theUrl,
        PRIM_MEDIA_HOME_URL, theUrl
    ];

    llSetPrimMediaParams(face, params);
}

list buttonLabels = [
    "stop",
    "compilation",
    "abstract",
    "tunnel",
    "vintage",
    "lights",
    "trippy",
    "psy",
    "modulation"
];

string getVideoId(string buttonId) {
    string result;
    if (buttonId == "compilation") {
        result = "k4QDmJDRE6w";
    } else if (buttonId == "abstract") {
        result = "MagELQywiGI";
    } else if (buttonId == "lights") {
        result = "UoHK74aS9sY";
    } else if (buttonId == "psy") {
        result = "MagELQywiGI";
    } else if (buttonId == "modulation") {
        result = "ururr6cbJbE";
    } else if (buttonId == "vintage") {
        result = "pmDl_y7dk_U";
    } else if (buttonId == "tunnel") {
        result = "uioH5a6PNX8";
    } else if (buttonId == "trippy") {
        result = "7GhrD869S_E";
    }
    return result;
}

displayMenu(key user)
{
    // Create the dialog menu
    llDialog(user, "Select a media URL:", buttonLabels, dialogChannel);
    listenHandle = llListen(dialogChannel, "", user, "");
}


default
{
    state_entry()
    {
        dialogChannel = -1 - (integer)("0x" + llGetSubString( (string)llGetKey(), -7, -1) );
        llRequestURL();
    }

    touch_start(integer total_number)
    {
        ToucherID = llDetectedKey(0);
        displayMenu(ToucherID);

    }
    
    http_request(key id, string method, string body)
    {
        if (method == URL_REQUEST_GRANTED)
        {
            showVideo("stop");
        }
    }

    
    // Listen for dialog response
    listen(integer channel, string name, key id, string message)
    {
        if (message == "stop") {
            llInstantMessage(ToucherID, "Stopping all videos.");
            showVideo("stop");
        } else {
            llInstantMessage(ToucherID, "Loading Video: " + message + ". Please be patient");
            string videoId = getVideoId(message);
            showVideo(videoId);
        }

    }
}