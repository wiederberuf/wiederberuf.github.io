integer face = 0;

key ToucherID;

integer dialogChannel;
integer listenHandle;

list videoMap;

key notecardQueryId; //Identifier for the dataserver event

string notecardName = "videos"; //Name of a notecard in the object's inventory. Needs to be Full Perm for key checking for changed contents to work
 
integer notecardLine; //Initialize the counter value at 0

key notecardKey; //Store the notecard's key, so we don't read it again by accident.
 
list notecardData; //List to store data read from the notecard.

ReadNotecard()
{
    if (llGetInventoryKey(notecardName) == NULL_KEY)
    { //Check if the notecard exists in inventory, and is has been saved since it's creation (newly created notecards that are yet to be saved are assigned NULL_KEY).
        llOwnerSay( "Notecard '" + notecardName + "' is missing, unwritten, or not full permission."); //Notify user.
        return; //Don't do anything else.
    }
    else if (llGetInventoryKey(notecardName) == notecardKey) return;
    //This notecard has already been read - call to read was made in error, so don't do anything. (Notecards are assigned a new key each time they are saved.)

    llOwnerSay("Began reading notecard: " + notecardName); //Notify user that read has started.
    notecardData = []; //Clear the memory of the previous notecard.
    notecardKey = llGetInventoryKey(notecardName); //Remember the key of this iteration of the notecard, so we don't read it again by accident.
    notecardQueryId = llGetNotecardLine(notecardName, notecardLine);
}

// Function to add or update a key-value pair in the map
addToMap(string mykey, string value) {
    integer index = llListFindList(videoMap, [mykey]);
    if (index != -1) {
        // Key already exists, update the value
        videoMap = llListReplaceList(videoMap, [value], index+1, index+1);
    } else {
        // Key doesn't exist, add a new key-value pair
        videoMap += [mykey, value];
    }
}

// Function to get the value associated with a key from the map
string getValue(string mykey) {
    integer index = llListFindList(videoMap, [mykey]);
    if (index != -1) {
        return llList2String(videoMap, index+1);
    } else {
        // Key not found, return an empty string or handle it as appropriate
        return "";
    }
}

// Function to parse a line from the notecard and add its key-value pair to the map
parseNotecardLine(string line) {
    list keyValue = llParseString2List(line, [","], []);
    if (llGetListLength(keyValue) >= 2) {
        string theKey = llList2String(keyValue, 0);
        string value = llList2String(keyValue, 1);
        addToMap(theKey, value);
        buttonLabels = buttonLabels + theKey;
        // llOwnerSay("addToMap " + theKey + " -> " + getValue(theKey));  // DEBUG
    }
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

list buttonLabels = [];


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

        ReadNotecard(); //Pass off to the read function.
    }

    changed(integer change)
    {
        if(change & CHANGED_INVENTORY)
        { //The object's inventory just changed - the notecard could have been modified!
            ReadNotecard();
        }
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
            string videoId = getValue(message);

            showVideo(videoId);
        }

    }

    dataserver(key query_id, string data)
    {
        if (query_id == notecardQueryId)
        {
            if (data == EOF) //Reached end of notecard (End Of File).
            {
                llOwnerSay("Done reading notecard, found " + (string) notecardLine + " videos."); //Notify user.
            }
            else
            {
                parseNotecardLine(data);
                notecardData += data; //Add the line being read to a new entry on the list.
                ++notecardLine; //Increment line number (read next line).
                notecardQueryId = llGetNotecardLine(notecardName, notecardLine); //Query the dataserver for the next notecard line.
            }
        }
    }
}