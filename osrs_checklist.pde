PFont ibm;
int itemsAmount;
int ystart;
int itemtextpos;
int chancetextpos;
int checkpos;
int winWidth;
int winHeight;
int rowHeight = 40;
String temp;
PShape yes;
PShape no;
JSONArray items;
JSONObject tempItem;
JSONObject currItem;

void setup() {
  ibm = createFont("IBMPlexSans-Regular.ttf", 12);
  textFont(ibm);
  textAlign(CENTER);
  items = loadJSONArray("data.json");
  itemsAmount = items.size();
  size(500, 500);
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

void draw() {
  fill(0xFFD8CCB4);
  stroke(0xFF94866D);
  winHeight = itemsAmount*rowHeight + 1;
  itemtextpos = getItemSize() + 24;
  chancetextpos = getChanceSize() + 24;
  checkpos = itemtextpos+chancetextpos;
  for (int i = 0; i < itemsAmount; i++) {
    ystart = i*rowHeight; //<>//
    currItem = items.getJSONObject(i);
    rect(0,ystart,itemtextpos+24,rowHeight);
    text(currItem.getString("name"), itemtextpos/2, ystart+12);
    rect(itemtextpos,ystart,chancetextpos,rowHeight);
    rect(checkpos,ystart,rowHeight,rowHeight);
  }
}
