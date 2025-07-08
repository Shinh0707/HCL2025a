abstract class EffectData{
    float duration;
    float startTime;
    PVector playerPos;
    PVector opponentPos;

    EffectData(){
    }
    void start(PVector playerPos,PVector opponentPos){
        startTime = float(millis());
        this.playerPos = playerPos;
        this.opponentPos = opponentPos;
        onStart();
    }
    abstract void onStart();
    float remainTime(){
        return millis() - startTime;
    }
    float remain(){
        return 1.0 - remainTime()/duration;
    }
    abstract boolean draw(GameData data);
}

class EffectData0 extends EffectData{
    ArrayList<Spark> sparks = new ArrayList<Spark>();

    EffectData0(){
        duration = 3*1000;
    }
    
    void onStart(){
        sparks.clear();
        for (int i = 0; i < 120; i++) {
            sparks.add(new Spark(playerPos));
        }
    }
    
    boolean draw(GameData data){
        for (int i = sparks.size() - 1; i >= 0; i--) {
            Spark s = sparks.get(i);
            s.display();
            if (s.update()) sparks.remove(i);
        }
        return remain() < 0 && sparks.isEmpty();
    }
}

//マーカー1
boolean beamActive = false;
int beamFrame = 0;
int beamDuration = 30;  // ビームの速さ（フレーム数）
int fadeFrames = 5;
PVector beamStart, beamEnd;

void drawAction1(GameData data, PVector playerPos, PVector opponentPos) {
  if (!beamActive) {
    beamActive = true;
    beamFrame = 0;
    beamStart = playerPos.copy();
    beamEnd = opponentPos.copy();
  }

  // ビームの進行割合
  float progress = beamFrame <= beamDuration ? beamFrame / (float)beamDuration : 1.0;
  PVector currentEnd = PVector.lerp(beamStart, beamEnd, progress);

  // フェード用の透明度係数
  float alphaMultiplier = 1.0;
  if (beamFrame > beamDuration) {
    alphaMultiplier = map(beamFrame, beamDuration, beamDuration + fadeFrames, 1.0, 0.0);
  }

  // 外側の紫色ビーム
  strokeWeight(12 * (1 - progress));
  stroke(180, 0, 255, 180 * (1 - progress) * alphaMultiplier);
  drawWavyLine(beamStart, currentEnd, 15 * (1 - progress) * alphaMultiplier, 5);

  // 内側のピンクビーム
  strokeWeight(6 * (1 - progress));
  stroke(255, 100, 255, 220 * (1 - progress) * alphaMultiplier);
  drawWavyLine(beamStart, currentEnd, 8 * (1 - progress) * alphaMultiplier, 8);

  // 白い細い線
  strokeWeight(2);
  stroke(255, 255, 255, 255 * alphaMultiplier);
  drawWavyLine(beamStart, currentEnd, 3 * alphaMultiplier, 15);

  // ビーム先端の光の玉
  noStroke();
  fill(255, 255, 255, 255 * alphaMultiplier);
  ellipse(currentEnd.x, currentEnd.y, 20, 20);

  beamFrame++;
  if (beamFrame > beamDuration + fadeFrames) {
    beamActive = false;
  }
}

// 揺らめく線を描く補助関数
void drawWavyLine(PVector start, PVector end, float amplitude, float frequency) {
  int segments = 30;
  PVector dir = PVector.sub(end, start);
  dir.normalize();
  PVector normal = new PVector(-dir.y, dir.x);

  beginShape();
  for (int i = 0; i <= segments; i++) {
    float t = i / (float)segments;
    PVector point = PVector.lerp(start, end, t);
    float wave = sin(t * TWO_PI * frequency + frameCount * 0.4) * amplitude;
    point.add(PVector.mult(normal, wave));
    vertex(point.x, point.y);
  }
  endShape();
}

//マーカー2
// パーティクルリストと状態管理変数
ArrayList<ParticleBase> action2Particles = null;
boolean action2Active = false;
int action2Frame = 0, action2Duration = 140;  // 表示時間

// drawAction2関数
void drawAction2(GameData data, PVector playerPos, PVector opponentPos) {
  if (!action2Active) {
    action2Particles = new ArrayList<>();
    // 攻撃パーティクル（自分から相手に向かう）
    for (int i = 0; i < 40; i++) {
      action2Particles.add(new AttackParticle(playerPos, opponentPos));
    }
    action2Active = true;
    action2Frame = 0;
  }

  // 残像効果用 半透明で画面を塗りつぶし（必要なら）
  fill(0, 40);
  rect(0, 0, width, height);

  // パーティクルの更新と描画
  for (int i = action2Particles.size() - 1; i >= 0; i--) {
    ParticleBase p = action2Particles.get(i);
    p.update();
    p.display();
    if (p.isDead()) action2Particles.remove(i);
  }

  // カード光る演出（最後の50フレーム）
  if (action2Frame > action2Duration - 50) {
    float t = map(action2Frame, action2Duration - 50, action2Duration, 0, 1);
    rectMode(CENTER);

    // カード本体
    noStroke();
    fill(255, 255, 255, 255 * t);
    float cardWidth = lerp(0, 40, t);
    float cardHeight = lerp(0, 55, t);
    rect(playerPos.x, playerPos.y - 50, cardWidth, cardHeight, 8);

    // 光のオーラ（大）
    noFill();
    stroke(255, 255, 200, 150 * sin(t * PI));
    strokeWeight(8);
    ellipse(playerPos.x, playerPos.y - 50, cardWidth + 30, cardHeight + 30);

    // 光のオーラ（中）
    stroke(255, 255, 220, 200 * sin(t * PI));
    strokeWeight(5);
    ellipse(playerPos.x, playerPos.y - 50, cardWidth + 15, cardHeight + 15);

    // 光のオーラ（小）
    stroke(255, 255, 255, 230 * sin(t * PI));
    strokeWeight(2);
    ellipse(playerPos.x, playerPos.y - 50, cardWidth + 6, cardHeight + 6);

    // カードの文字
    fill(0, 120);
    noStroke();
    textAlign(CENTER, CENTER);
    textSize(22);
    text("+1", playerPos.x, playerPos.y - 50);
  }

  action2Frame++;
  if (action2Frame > action2Duration && action2Particles.isEmpty()) {
    action2Active = false;
  }
}

//マーカー3
// グローバル変数（ゲームのどこかに置いてください）
ArrayList<FireballParticle> action3AttackParticles = null;
ArrayList<CardBurnParticle> action3BurnParticles = null;

boolean action3AttackActive = false;
boolean action3BurnActive = false;

int action3Frame = 0;

// drawAction3関数（EffectPhaseから呼ぶイメージ）
void drawAction3(GameData data, PVector playerPos, PVector opponentPos) {
  if (!action3AttackActive && !action3BurnActive) {
    // 初回呼び出し時のみ初期化
    action3AttackParticles = new ArrayList<>();
    action3BurnParticles = new ArrayList<>();
    for (int i = 0; i < 40; i++) {
      action3AttackParticles.add(new FireballParticle(playerPos, opponentPos));
    }
    action3AttackActive = true;
    action3BurnActive = false;
    action3Frame = 0;
  }

  if (action3AttackActive) {
    fill(0, 40);
    rect(0, 0, width, height);

    for (int i = action3AttackParticles.size() - 1; i >= 0; i--) {
      FireballParticle p = action3AttackParticles.get(i);
      p.update();
      p.display();
      if (p.isDead()) action3AttackParticles.remove(i);
    }

    action3Frame++;
    if (action3Frame > 60 || action3AttackParticles.isEmpty()) {
      action3AttackActive = false;
      action3BurnActive = true;
      action3Frame = 0;
      for (int i = 0; i < 60; i++) {
        action3BurnParticles.add(new CardBurnParticle(opponentPos));
      }
    }
  } else if (action3BurnActive) {
    fill(0, 50);
    rect(0, 0, width, height);

    for (int i = action3BurnParticles.size() - 1; i >= 0; i--) {
      CardBurnParticle p = action3BurnParticles.get(i);
      p.update();
      p.display();
      if (p.isDead()) action3BurnParticles.remove(i);
    }

    if (action3Frame < 80) {
      float alpha = map(80 - action3Frame, 0, 80, 0, 180);
      float scale = map(action3Frame, 0, 80, 1.0, 0.3);

      fill(255, 120, 50, alpha);
      rectMode(CENTER);
      pushMatrix();
      translate(opponentPos.x, opponentPos.y - 30);
      scale(scale);
      rect(0, 0, 40, 55, 10);

      fill(0, alpha);
      textAlign(CENTER, CENTER);
      textSize(24 * scale);
      text("-1", 0, 0);
      popMatrix();
    }

    action3Frame++;
    if (action3Frame > 80 && action3BurnParticles.isEmpty()) {
      action3BurnActive = false;
    }
  }
}

//マーカー4
// グローバル変数
ArrayList<CardGlowParticle> action4Particles = null;
boolean action4Active = false;
int action4Frame = 0;
int action4Duration = 150;

// drawAction4関数
void drawAction4(GameData data, PVector playerPos, PVector opponentPos) {
  if (!action4Active) {
    action4Particles = new ArrayList<>();
    for (int i = 0; i < 60; i++) {
      action4Particles.add(new CardGlowParticle(playerPos));
    }
    action4Active = true;
    action4Frame = 0;
  }

  fill(0, 30);
  rect(0, 0, width, height);

  // パーティクル更新・描画
  for (int i = action4Particles.size() - 1; i >= 0; i--) {
    CardGlowParticle p = action4Particles.get(i);
    p.update();
    p.display();
    if (p.isDead()) action4Particles.remove(i);
  }

  // 大きく神々しいカードの光るシルエット
  if (action4Frame < action4Duration) {
    float alpha = map(action4Duration - action4Frame, 0, action4Duration, 0, 220);
    float scale = map(action4Frame, 0, action4Duration, 0.6, 1.5);

    fill(255, 255, 220, alpha);
    rectMode(CENTER);
    pushMatrix();
    translate(playerPos.x, playerPos.y - 40);
    scale(scale);
    noStroke();
    rect(0, 0, 60, 85, 20);

    fill(255, 200, 50, alpha * 0.8);
    textAlign(CENTER, CENTER);
    textSize(36 * scale);
    text("+2", 0, 0);
    popMatrix();
  }

  action4Frame++;
  if (action4Frame > action4Duration && action4Particles.isEmpty()) {
    action4Active = false;
  }
}

//マーカー5
// グローバル変数
ArrayList<StealSpark> stealSparks = null;
StealCard stealCard = null;
boolean stealActive = false;
int stealFrame = 0;
int stealDuration = 100;

void drawAction5(GameData data, PVector playerPos, PVector opponentPos) {
  if (!stealActive) {
    stealSparks = new ArrayList<>();
    for (int i = 0; i < 80; i++) {
      stealSparks.add(new StealSpark(opponentPos));
    }
    stealCard = new StealCard(opponentPos, playerPos);
    stealActive = true;
    stealFrame = 0;
  }

  fill(0, 60);
  rect(0, 0, width, height);

  // パーティクル更新描画
  if (stealSparks != null && !stealSparks.isEmpty()) {
    for (int i = stealSparks.size() -1; i >= 0; i--) {
      StealSpark s = stealSparks.get(i);
      s.update();
      s.display();
      if (s.age > s.lifetime) {
        stealSparks.remove(i);
      }
    }
  }

  // カード本体更新描画
  if (stealCard != null) {
    stealCard.update();
    stealCard.display();
  }

  stealFrame++;
  if (stealCard != null && stealCard.isFinished()) {
    stealActive = false;
  }
}

//マーカー6
// --- drawAction6: フリーレン風の防御魔法陣シールド ---
int action6Duration = 120; // 2秒（60fps）

void drawAction6(PVector center, int frame) {
  if (frame > action6Duration) return;

  float progress = frame / (float)action6Duration;
  float alpha = sin(progress * PI) * 180 + 75;  // 透過が揺れる
  stroke(180, 220, 255, alpha);
  strokeWeight(max(1, 2 + 3 * sin(frame * 0.15))); // 線の太さ揺らぎ

  pushMatrix();
  translate(center.x, center.y);

  // 魔法陣の円
  int circles = 3;
  for (int i = 0; i < circles; i++) {
    float radius = 80 + i * 20 + 10 * sin(frame * 0.1 + i);
    radius = max(radius, 1);
    ellipse(0, 0, radius * 2, radius * 2);
  }

  // 回転する放射状ライン
  int rays = 12;
  float rotation = frame * 0.05f;
  for (int i = 0; i < rays; i++) {
    float angle = TWO_PI / rays * i + rotation;
    float len = 90 + 10 * sin(frame * 0.2 + i);
    float x = cos(angle) * len;
    float y = sin(angle) * len;
    line(0, 0, x, y);
  }

  // 輝く小円が回る
  int smallDots = 8;
  for (int i = 0; i < smallDots; i++) {
    float angle = TWO_PI / smallDots * i - rotation * 1.5f;
    float r = 70 + 5 * sin(frame * 0.3 + i);
    r = max(r, 1);
    float x = cos(angle) * r;
    float y = sin(angle) * r;
    noStroke();
    fill(200, 230, 255, alpha);
    ellipse(x, y, 10, 10);
  }

  popMatrix();

  // さらに外側の薄い光のリング
  noFill();
  stroke(150, 180, 255, alpha * 0.4f);
  strokeWeight(1);
  ellipse(center.x, center.y, 220, 220);
}

//マーカー7
void drawAction7(PVector from, PVector to, int frame, int duration) {
  float t = frame / float(duration);
  float alpha = 255 * sin(t * PI);

  // 軌道の乱れ（時間と共にやや安定）
  float offset = 10 * sin(frame * 0.3f) * (1 - t * 0.5);
  PVector chaoticTo = new PVector(to.x + random(-offset, offset), to.y + random(-offset, offset));

  // ビーム（中心白→赤→紫の三重構造）
  strokeWeight(12);
  stroke(160, 0, 255, alpha * 0.4); // 紫の外縁
  line(from.x, from.y, chaoticTo.x, chaoticTo.y);

  strokeWeight(6);
  stroke(255, 50, 100, alpha * 0.7); // 赤中間
  line(from.x, from.y, chaoticTo.x, chaoticTo.y);

  strokeWeight(3);
  stroke(255, 255, 255, alpha); // 白中心
  line(from.x, from.y, chaoticTo.x, chaoticTo.y);

  // 発射元の魔方陣
  pushMatrix();
  translate(from.x, from.y);
  rotate(frame * 0.05);
  stroke(255, 0, 100, alpha * 0.6);
  noFill();
  for (int i = 0; i < 3; i++) {
    float r = 50 + i * 25 + 5 * sin(frame * 0.1 + i);
    ellipse(0, 0, r, r);
  }
  popMatrix();

  // 着弾点での多重衝撃波リング
  for (int i = 0; i < 4; i++) {
    float ringR = (frame - i * 8) * 4;
    if (ringR > 0 && ringR < 300) {
      stroke(255, 80, 255, alpha * (1.0 - i * 0.2));
      noFill();
      strokeWeight(1.5);
      ellipse(to.x, to.y, ringR, ringR);
    }
  }

  // 火花散乱（無数のビット）
  for (int i = 0; i < 25; i++) {
    float angle = random(TWO_PI);
    float len = random(10, 35);
    float x1 = to.x + cos(angle) * len;
    float y1 = to.y + sin(angle) * len;
    stroke(255, 100, 255, alpha * 0.5);
    strokeWeight(1);
    line(to.x, to.y, x1, y1);
  }
}

//マーカー8
void drawAction8(GameData data, PVector playerPos, PVector opponentPos, int frame, int duration) {
  float t = frame / (float)duration;
  float alpha = 255 * sin(t * PI);

  // 吸収ビーム（相手からプレイヤーへ）
  strokeWeight(10);
  stroke(100, 150, 255, alpha * 0.6);
  line(opponentPos.x, opponentPos.y, lerp(opponentPos.x, playerPos.x, t), lerp(opponentPos.y, playerPos.y, t));

  strokeWeight(4);
  stroke(180, 220, 255, alpha);
  line(opponentPos.x, opponentPos.y, lerp(opponentPos.x, playerPos.x, t), lerp(opponentPos.y, playerPos.y, t));

  // プレイヤー付近にエネルギーの渦巻き
  pushMatrix();
  translate(playerPos.x, playerPos.y);
  noFill();
  stroke(150, 200, 255, alpha);
  strokeWeight(2 + 2 * sin(frame * 0.2));
  for (int i = 0; i < 3; i++) {
    float r = 20 + 10 * i + 5 * sin(frame * 0.15 + i);
    ellipse(0, 0, r + frame * 0.5, r + frame * 0.5);
  }
  popMatrix();

  // 中間地点の小爆発
  if (t > 0.5) {
    int sparks = 20;
    PVector mid = new PVector(
      lerp(opponentPos.x, playerPos.x, t),
      lerp(opponentPos.y, playerPos.y, t)
    );
    for (int i = 0; i < sparks; i++) {
      float angle = TWO_PI / sparks * i + frame * 0.3;
      float len = 10 + 5 * sin(frame * 0.4 + i);
      float x = mid.x + cos(angle) * len;
      float y = mid.y + sin(angle) * len;
      stroke(150, 200, 255, alpha * (1 - (t - 0.5) * 2));
      strokeWeight(1.5);
      line(mid.x, mid.y, x, y);
    }
  }
}

//マーカー9
void drawAction9(GameData data, PVector playerPos, PVector opponentPos, int frame, int duration) {
  float progress = frame / (float)duration;

  // 光球のサイズと輝き（脈動）
  float baseRadius = 50;
  float radius = baseRadius + baseRadius * progress + 10 * sin(frame * 0.3);
  float alpha = 150 + 105 * sin(progress * PI);

  noStroke();
  // 光球のグラデーション的な重ね円
  for (int i = 0; i < 5; i++) {
    float r = radius * (1 + i * 0.15);
    fill(100, 180, 255, alpha * (1.0 - i * 0.2));
    ellipse(playerPos.x, playerPos.y, r*2, r*2);
  }

  // 外側の回転リング
  stroke(150, 200, 255, alpha);
  strokeWeight(3);
  noFill();
  pushMatrix();
  translate(playerPos.x, playerPos.y);
  float rotation = frame * 0.04;
  for (int i = 0; i < 4; i++) {
    float angle = TWO_PI / 4 * i + rotation;
    float ringRadius = radius * 1.8;
    ellipse(cos(angle)*ringRadius, sin(angle)*ringRadius, 30, 30);
  }
  popMatrix();

  // 周囲を回る小さな光点
  noStroke();
  fill(180, 230, 255, alpha * 0.7);
  pushMatrix();
  translate(playerPos.x, playerPos.y);
  int dotCount = 12;
  for (int i = 0; i < dotCount; i++) {
    float angle = TWO_PI / dotCount * i - frame * 0.08;
    float r = radius * 1.3;
    ellipse(cos(angle)*r, sin(angle)*r, 8, 8);
  }
  popMatrix();

  // テキストで「Charging...」
  fill(200, 230, 255, alpha);
  textAlign(CENTER, CENTER);
  textSize(24);
  text("Charging...", playerPos.x, playerPos.y + radius + 30);
}

//検出できないとき
void drawActionNaN(GameData data, PVector playerPos, PVector opponentPos, int frame, int duration) {
  float progress = frame / (float)duration;
  float alpha = 255 * sin(progress * PI);

  // 背景をほんのり赤くフラッシュ
  noStroke();
  fill(255, 0, 0, alpha * 0.3);
  rect(0, 0, width, height);

  // プレイヤー位置から相手位置に向けて赤い丸が移動
  PVector pos = PVector.lerp(playerPos, opponentPos, progress);

  noStroke();
  fill(255, 50, 50, alpha);
  ellipse(pos.x, pos.y, 30, 30);
}

// === Sparkクラス ===
class Spark {
  PVector pos, vel;
  float size;
  int lifetime;
  int age = 0;
  color col;
  float zigzagFreq;
  float zigzagAmp;

  Spark(PVector center) {
    float angle = random(TWO_PI);
    float speed = random(2.0, 6.0);
    vel = new PVector(cos(angle)*speed, sin(angle)*speed);
    pos = center.copy();
    size = random(6, 20);
    lifetime = int(random(50, 80));

    float r = random(200, 255);
    float g = random(40, 100);
    float b = random(0, 20);
    float a = random(200, 255);
    col = color(r, g, b, a);

    zigzagFreq = random(5, 12);
    zigzagAmp = random(0.5, 2.5);
  }

  boolean update() {
    float n = sin(frameCount * zigzagFreq + pos.x * 0.05) * zigzagAmp;
    vel.rotate(radians(n));
    pos.add(vel);
    vel.mult(0.97);
    age++;
    return age > lifetime;
  }

  void display() {
    float alpha = map(lifetime - age, 0, lifetime, 0, 255);
    float dynamicSize = size * (1.0 + 0.2 * sin(age * 0.3));
    fill(red(col), green(col), blue(col), alpha);
    noStroke();
    ellipse(pos.x, pos.y, dynamicSize, dynamicSize);
  }
}

// --- パーティクルの基底クラス ---
abstract class ParticleBase {
  PVector pos, vel;
  float size;
  int lifetime, age = 0;
  color col;

  ParticleBase(PVector pos, color col, float size, int lifetime) {
    this.pos = pos.copy();
    this.col = col;
    this.size = size;
    this.lifetime = lifetime;
  }

  abstract void update();

  void display() {
    noStroke();
    float alpha = map(lifetime - age, 0, lifetime, 0, 255);
    fill(red(col), green(col), blue(col), alpha);
    ellipse(pos.x, pos.y, size, size);
  }

  boolean isDead() {
    return age > lifetime;
  }
}

// --- 攻撃用パーティクル ---
class AttackParticle extends ParticleBase {
  PVector target;
  float speed;

  AttackParticle(PVector start, PVector target) {
    super(start, color(255, 120, 120, 255), random(6, 10), int(random(30, 50)));
    this.target = target.copy();
    PVector dir = PVector.sub(target, start);
    dir.normalize();
    speed = random(6, 10);
    vel = PVector.mult(dir, speed);
  }

  void update() {
    pos.add(vel);
    age++;
    size *= 0.97; // 少し小さくなる
  }

  void display() {
    noStroke();
    float alpha = map(lifetime - age, 0, lifetime, 0, 255);
    color c1 = color(255, 120, 120, alpha);
    color c2 = color(255, 220, 220, alpha * 0.5);
    for (int i = 0; i < 3; i++) {
      float s = size * (1.0 + i * 0.5);
      int a = int(alpha * (1.0 - i * 0.3));
      fill(red(c1), green(c1), blue(c1), a);
      ellipse(pos.x, pos.y, s, s);
      fill(red(c2), green(c2), blue(c2), a / 2);
      ellipse(pos.x, pos.y, s * 0.6, s * 0.6);
    }
  }
}

class FireballParticle extends ParticleBase {
  PVector target;
  float speed;

  FireballParticle(PVector start, PVector target) {
    super(start, color(255, 140, 0, 255), random(6, 10), int(random(30, 50)));
    this.target = target.copy();
    PVector dir = PVector.sub(target, start);
    dir.normalize();
    speed = random(6, 10);
    vel = PVector.mult(dir, speed);
  }

  void update() {
    pos.add(vel);
    age++;
    size *= 0.95;

    // 炎のゆらぎ（少し揺らぐ）
    pos.x += sin(age * 0.3) * 0.5;
    pos.y += cos(age * 0.2) * 0.3;
  }

  void display() {
    noStroke();
    float alpha = map(lifetime - age, 0, lifetime, 0, 255);
    // 炎の本体
    fill(255, 150, 50, alpha);
    ellipse(pos.x, pos.y, size, size);
    // 炎の外側のぼかし
    fill(255, 100, 20, alpha * 0.5);
    ellipse(pos.x, pos.y, size * 1.6, size * 1.6);
  }
}

class CardBurnParticle extends ParticleBase {
  PVector accel;

  CardBurnParticle(PVector center) {
    super(new PVector(center.x + random(-20, 20), center.y + random(-10, 10)), color(255, 140, 30, 255), random(4, 7), int(random(40, 70)));
    vel = new PVector(random(-1.5, 1.5), random(-2.5, -0.5));
    accel = new PVector(0, 0.06);
  }

  void update() {
    vel.add(accel);
    pos.add(vel);
    age++;
    size *= 0.92;
  }

  void display() {
    noStroke();
    float alpha = map(lifetime - age, 0, lifetime, 0, 255);
    fill(255, 100, 30, alpha);
    ellipse(pos.x, pos.y, size, size * 1.5);
  }
}
// パーティクルクラス
class CardGlowParticle extends ParticleBase {
  PVector accel;

  CardGlowParticle(PVector center) {
    super(new PVector(center.x + random(-30, 30), center.y + random(-20, 20)), color(255, 255, 180, 255), random(5, 10), int(random(50, 90)));
    vel = new PVector(random(-1, 1), random(-3, -1));
    accel = new PVector(0, 0.04);
  }

  void update() {
    vel.add(accel);
    pos.add(vel);
    age++;
    size *= 0.95;
  }

  void display() {
    noStroke();
    float alpha = map(lifetime - age, 0, lifetime, 0, 255);
    fill(255, 240, 180, alpha);
    ellipse(pos.x, pos.y, size, size * 1.5);
  }
}


// 奪う火花パーティクルクラス
class StealSpark {
  PVector pos, vel;
  float size;
  int lifetime, age = 0;
  color col;

  StealSpark(PVector start) {
    pos = start.copy();
    float angle = random(TWO_PI);
    float speed = random(2, 6);
    vel = new PVector(cos(angle) * speed, sin(angle) * speed);
    size = random(4, 10);
    lifetime = int(random(40, 60));
    col = color(255, 200, 100, 255);
  }

  void update() {
    pos.add(vel);
    vel.mult(0.92);
    age++;
    size *= 0.95;
  }

  void display() {
    noStroke();
    float alpha = map(lifetime - age, 0, lifetime, 0, 255);
    fill(red(col), green(col), blue(col), alpha);
    ellipse(pos.x, pos.y, size, size);
  }
}

// 奪うカード本体クラス
class StealCard {
  PVector pos;
  PVector startPos, endPos;
  float progress = 0;
  float sizeX = 60, sizeY = 90;
  float angle = 0;
  int duration = 80;
  int age = 0;

  StealCard(PVector start, PVector end) {
    startPos = start.copy();
    endPos = end.copy();
    pos = start.copy();
  }

  void update() {
    age++;
    progress = constrain(age / (float)duration, 0, 1);
    pos = PVector.lerp(startPos, endPos, progress);

    // 横揺れ（揺らぎ）＋サイズゆらぎ
    pos.x += sin(progress * PI * 8 + frameCount * 0.2) * 10 * (1 - progress);
    pos.y += cos(progress * PI * 5 + frameCount * 0.3) * 5 * (1 - progress);

    sizeX = lerp(60, 35, progress);
    sizeY = lerp(90, 50, progress);

    angle = progress * TWO_PI * 3;

    // 徐々に光の強さUP
  }

  void display() {
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(angle);

    // 光のオーラ外側（神々しい輝き）
    noFill();
    stroke(255, 255, 180, 180 * (1 - progress));
    strokeWeight(15 * (1 - progress));
    ellipse(0, 0, sizeX * 1.5, sizeY * 1.5);

    // カード本体
    noStroke();
    fill(255, 240, 200, 230);
    rectMode(CENTER);
    rect(0, 0, sizeX, sizeY, 15);

    // 光の線（中）
    stroke(255, 220, 120, 200);
    strokeWeight(5);
    line(-sizeX/2 + 10, -sizeY/3, sizeX/2 - 10, sizeY/3);
    line(sizeX/2 - 10, -sizeY/3, -sizeX/2 + 10, sizeY/3);

    // 光の細線（内側）
    stroke(255, 255, 180, 180);
    strokeWeight(2);
    line(-sizeX/3, 0, sizeX/3, 0);

    popMatrix();

    // 到着付近は光の輝き拡大（奪う力感）
    if (progress > 0.8) {
      float glowAlpha = map(progress, 0.8, 1.0, 0, 255);
      noFill();
      stroke(255, 230, 130, glowAlpha);
      strokeWeight(20 * (progress - 0.8) * 5);
      ellipse(endPos.x, endPos.y, sizeX * 2, sizeY * 2);
    }
  }

  boolean isFinished() {
    return age > duration;
  }
}
