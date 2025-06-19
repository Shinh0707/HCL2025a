import processing.video.*;

void setup() {
  turnStartMillis = millis();
  turn1Count = 1;  
}

void draw() {
  if (cam.available()) {
    cam.read();
  }

  image(cam, 0, 0, width, height);

  // 残り時間計算
  int elapsed = (millis() - turnStartMillis) / 1000;
  remainingTime = max(0, turnTime - elapsed);

  if (remainingTime == 0) {
    nextTurn();
  }


  fill(0, 150);
  rect(0, height - 100, width, 100);


  String displayText = "";
  if (turn == 1) {
    displayText = "プレイヤー 1 - " + turn1Count + "   |   残り時間: " + remainingTime + "秒";
  } else {
    displayText = "プレイヤー 2 - " + turn2Count + "   |   残り時間: " + remainingTime + "秒";
  }

  fill(255);
  textSize(24);
  text(displayText, width / 2, height - 50);
}

void nextTurn() {
  if (turn == 1) {
    if (turn1Count >= 10) return;  // プレイヤー1が10ターン終わったら止める
    turn = 2;
    turn2Count++;
  } else {
    if (turn2Count >= 10) return;  // プレイヤー2が10ターン終わったら止める
    turn = 1;
    turn1Count++;
  }
  turnStartMillis = millis();
}
