class HPUI {
  float[] displayHP = new float[]{100, 100};  // 表示用（アニメーション）
  float[] targetHP = new float[]{100, 100};   // 実際のHP
  float[] prevActualHP = new float[]{100, 100};  // 前フレームのHP
  ArrayList<FloatingText> texts = new ArrayList<FloatingText>();
  
  HPUI(float maxHP){
    displayHP = new float[]{maxHP,maxHP};  // 表示用（アニメーション）
    targetHP = new float[]{maxHP,maxHP};   // 実際のHP
    prevActualHP = new float[]{maxHP,maxHP};  // 前フレームのHP
  }

  void draw(GameData data) {
    float[] actualHP = new float[]{
      data.players[0].hp,
      data.players[1].hp
    };

    checkHPChange(actualHP);
    animateHP();

    float barWidth = 200;
    float barHeight = 20;
    float margin = 20;
    float maxHP = data.settings.MAX_HP;

    for (int i = 0; i < 2; i++) {
      float x = (i == 0) ? margin : width - barWidth - margin;
      int r = (i == 0) ? 255 : 0;
      int b = (i == 1) ? 255 : 0;
      strokeWeight(1);
      // 背景バー（減少部分を見せる用：灰色で背景の代用）
      noStroke();
      fill(80);  // 背景色（透明代用）
      rect(x, margin, barWidth, barHeight);

      // 現在のHPバー（アニメーション部分）
      fill(r, 0, b);
      rect(x, margin, barWidth * (1 - displayHP[i] / maxHP), barHeight);

      // 枠線
      stroke(255);
      noFill();
      rect(x, margin, barWidth, barHeight);

      // HP数値
      fill(255);
      textSize(21);
      textAlign((i == 0) ? LEFT : RIGHT, CENTER);
      text("P"+(i+1)+" Hacked: " + int((1 - displayHP[i] / maxHP)*100)+"%", (i == 0) ? x : x + barWidth, margin + barHeight + 12);
    }

    // ダメージ演出
    for (int i = texts.size() - 1; i >= 0; i--) {
      if (texts.get(i).draw()) {
        texts.remove(i);
      }
    }
  }

  void checkHPChange(float[] actualHP) {
    for (int i = 0; i < 2; i++) {
      if (actualHP[i] != prevActualHP[i]) {
        int diff = int(actualHP[i] - prevActualHP[i]);
        float x = (i == 0) ? 120 : width - 120;
        float y = 100;
        int attacker = (i == 0) ? 1 : 0;
        color c = (attacker == 0) ? color(255, 0, 0) : color(0, 0, 255);
        String dmgText = (diff > 0 ? "+" : "") + diff;
        texts.add(new FloatingText(dmgText, x, y, c, 60));
        prevActualHP[i] = actualHP[i];
        targetHP[i] = actualHP[i];
      }
    }
  }

  void animateHP() {
    for (int i = 0; i < 2; i++) {
      float diff = targetHP[i] - displayHP[i];
      if (abs(diff) > 0.1) {
        displayHP[i] += diff * 0.05;
      } else {
        displayHP[i] = targetHP[i];
      }
    }
  }

  void registerDamage(int playerIndex, float amount) {
    float x = (playerIndex == 0) ? 120 : width - 120;
    float y = 100;
    color c = (playerIndex == 0) ? color(255, 0, 0) : color(0, 0, 255);
    texts.add(new FloatingText((amount > 0 ? "+" : "") + amount, x, y, c, 60));
  }
}

class FloatingText {
  String text;
  float x, y;
  int duration;
  int age = 0;
  color col;

  FloatingText(String text, float x, float y, color col, int duration) {
    this.text = text;
    this.x = x;
    this.y = y;
    this.col = col;
    this.duration = duration;
  }

  boolean draw() {
    float alpha = map(age, 0, duration, 255, 0);
    textSize(32); // 見やすい大きさ
    textAlign(CENTER, CENTER);
    fill(col, alpha);
    text(text, x, y);
    age++;
    return age > duration;
  }
}
