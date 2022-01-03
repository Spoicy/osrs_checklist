import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.URL;
import java.net.URLConnection;

PFont ibm;
int itemsAmount;
int ystart;
int iconpos;
int itemtextpos;
int chancetextpos;
int checkpos;
int winWidth;
int winHeight;
int rowHeight = 64;
int fontsize = 24;
int padding = 24;
int fontHeight = fontsize*2/3;
int fontpos;
int shapeX;
int shapeY;
int redrawCheck = 0;
String temp;
PShape yes;
PShape no;
PImage output;
PImage currIcon;
PImage tempIcon;
JSONArray items;
JSONObject tempItem;
JSONObject currItem;
DownloadImage downImg = new DownloadImage(this);

void setup() {
  ibm = createFont("IBMPlexSans-Regular.ttf", fontsize);
  textFont(ibm);
  textAlign(CENTER);
  shapeMode(CENTER);
  imageMode(CENTER);
  items = loadJSONArray("data.json");
  itemsAmount = items.size();
  iconpos = getIconSize() + padding;
  itemtextpos = getItemSize() + padding;
  chancetextpos = getChanceSize() + padding;
  checkpos = itemtextpos+chancetextpos+iconpos;
  size(700, 600);
  background(0xFFE2DBC8);
  yes = loadShape("Yes_check.svg");
  no = loadShape("Red_X.svg");
  noLoop();
}

int getItemSize() {
  int highestSize = 0;
  for (int i = 0; i < itemsAmount; i++) {
    tempItem = items.getJSONObject(i);
    temp = tempItem.getString("item");
    int itemSize = (int) textWidth(temp);
    if (itemSize > highestSize) {
      highestSize = itemSize;
    }
  }
  return highestSize;
}

int getChanceSize() {
  int highestSize = 0;
  for (int i = 0; i < itemsAmount; i++) {
    tempItem = items.getJSONObject(i);
    temp = tempItem.getString("chance");
    int chanceSize = (int) textWidth(temp);
    if (chanceSize > highestSize) {
      highestSize = chanceSize;
    }
  }
  return highestSize;
}

int getIconSize() {
  int highestSize = 0;
  for (int i = 0; i < itemsAmount; i++) {
    tempItem = items.getJSONObject(i);
    tempIcon = downImg.load(tempItem.getString("icon"), sketchPath("temp/icon.png"));
    tempIcon.resize(0,rowHeight-padding);
    if (tempIcon.width > highestSize) {
      highestSize = tempIcon.width;
    }
  }
  return highestSize;
}

void mousePressed() {
  for (int i = 0; i < itemsAmount; i++) {
    if (mouseX >= checkpos && mouseX <= checkpos + rowHeight && mouseY >= rowHeight*i && mouseY <= rowHeight*i+rowHeight) {
      tempItem = items.getJSONObject(i);
      if (tempItem.getInt("unlocked") == 0) {
        tempItem.setInt("unlocked", 1);
      } else {
        tempItem.setInt("unlocked", 0);
      }
      items.setJSONObject(i, tempItem);
      saveJSONArray(items, "data.json");
      redrawCheck = 1;
    }
  }
  if (redrawCheck == 1) {
    redraw();
  }
}

void draw() {
  fill(0xFFD8CCB4);
  stroke(0xFF94866D);
  winHeight = itemsAmount*rowHeight + 1;
  // Set the necessary position values
  winWidth = iconpos+itemtextpos+chancetextpos+rowHeight+1;
  // Go through all items in JSON and create a row for each one
  for (int i = 0; i < itemsAmount; i++) {
    ystart = i*rowHeight; //<>//
    fontpos = ystart + fontHeight + (rowHeight-fontHeight)/2 + 1;
    currItem = items.getJSONObject(i);
    currIcon = downImg.load(currItem.getString("icon"), sketchPath("temp/icon.png"));
    currIcon.resize(0,rowHeight-padding);
    shapeX = checkpos+rowHeight/2+1;
    shapeY = ystart+rowHeight/2+1;
    // Create the table row with rectangles
    fill(0xFFD8CCB4);
    rect(0,ystart,iconpos,rowHeight);
    rect(iconpos,ystart,itemtextpos,rowHeight);
    rect(checkpos,ystart,rowHeight,rowHeight);
    // Stylize the chance part of the row with the necessary color
    temp = currItem.getString("rarity");
    fill(unhex(temp));
    rect(itemtextpos+iconpos,ystart,chancetextpos,rowHeight);
    // Set text and item icon
    fill(0xFF936039);
    text(currItem.getString("item"), iconpos+itemtextpos/2+1, fontpos);
    image(currIcon, iconpos/2+1, ystart+rowHeight/2+1);
    fill(0xFF000000);
    text(currItem.getString("chance"), iconpos+itemtextpos+chancetextpos/2+1, fontpos);
    // Set a checkmark or red x depending on if item is unlocked
    if (currItem.getInt("unlocked") == 0) {
      shape(no, shapeX, shapeY, rowHeight-padding, rowHeight-padding);
    } else {
      shape(yes, shapeX, shapeY, rowHeight-padding, rowHeight-padding);
    }
  }
  output = get(0,0,winWidth, winHeight);
  output.save("output/checklist.png");
  redrawCheck = 0;
}

// Code from Processing Forums user Flolo
public class DownloadImage {
  PApplet parent;

  public DownloadImage(PApplet parent) {
    this.parent = parent;
  }
  public PImage load(String search, String path) {

    // This will get input data from the server
    InputStream inputStream = null;

    // This will read the data from the server;
    OutputStream outputStream = null;

    try {
      // This will open a socket from client to server
      URL url = new URL(search);

      // This user agent is for if the server wants real humans to visit
      String USER_AGENT = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/56.0.2924.87 Safari/537.36";

      // This socket type will allow to set user_agent
      URLConnection con = url.openConnection();

      // Setting the user agent
      con.setRequestProperty("User-Agent", USER_AGENT);

      // Requesting input data from server
      inputStream = con.getInputStream();

      // Open local file writer
      outputStream = new FileOutputStream(path);

      // Limiting byte written to file per loop
      byte[] buffer = new byte[2048];

      // Increments file size
      int length;

      // Looping until server finishes
      while ((length = inputStream.read(buffer)) != -1) {
        // Writing data
        outputStream.write(buffer, 0, length);
      }
    } 
    catch (Exception ex) {
      ex.printStackTrace();
    }

    // closing used resources
    // The computer will not be able to use the image
    // This is a must

    try {
      outputStream.close();
      inputStream.close();
    } 
    catch (IOException e) {
      e.printStackTrace();
    }


    PImage img = parent.loadImage(path);
    return img;
  }
}
