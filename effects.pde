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

class EffectData1 extends EffectData {
  PVector beamStart, beamEnd;

  EffectData1() {
    duration = 1500;
  }

  void onStart() {
    beamStart = playerPos.copy();
    beamEnd = opponentPos.copy();
  }

  boolean draw(GameData data) {
    float elapsed = millis() - startTime;
    float t = constrain(elapsed / duration, 0, 1);
    float alpha = 1.0 - t;

    PVector currentEnd = PVector.lerp(beamStart, beamEnd, t);

    // 中心ビーム
    stroke(255, 255, 150, 255 * alpha);
    strokeWeight(4);
    line(beamStart.x, beamStart.y, currentEnd.x, currentEnd.y);

    // 螺旋ビーム
    drawSpiralBeam(beamStart, currentEnd, 10, 2.5, alpha);

    // 先端光球
    fill(255, 255, 255, 255 * alpha);
    noStroke();
    ellipse(currentEnd.x, currentEnd.y, 40, 40);

    // 1.5秒経ったら終了
    return remain() < 0;
  }

  void drawSpiralBeam(PVector start, PVector end, float amplitude, float turns, float alpha) {
    int segments = 60;
    PVector dir = PVector.sub(end, start).normalize();
    PVector normal = new PVector(-dir.y, dir.x);

    beginShape();
    for (int i = 0; i <= segments; i++) {
      float t = i / (float)segments;
      PVector point = PVector.lerp(start, end, t);
      float angle = t * TWO_PI * turns + frameCount * 0.5f;
      float offset = sin(angle) * amplitude;
      point.add(PVector.mult(normal, offset));
      stroke(255, 100, 0, 180 * alpha);
      strokeWeight(7 * (1 - t));
      vertex(point.x, point.y);
    }
    endShape();
  }
}





class EffectData2 extends EffectData {
  ArrayList<ParticleBase> particles;
  int action2DurationFrames = 140;
  int lastGlowFrames = 50;
  int totalDurationFrames = action2DurationFrames;
  
  EffectData2() {
    duration = totalDurationFrames * (1000f / 60f);  // 60FPS換算でミリ秒
    particles = new ArrayList<>();
  }
  
  void onStart() {
    particles.clear();
    for (int i = 0; i < 40; i++) {
      particles.add(new AttackParticle(playerPos, opponentPos));
    }
  }
  
  boolean draw(GameData data) {
    // 背景残像効果（必要なら）
    fill(0, 40);
    rect(0, 0, width, height);
    
    // パーティクル更新・描画
    for (int i = particles.size() -1; i >= 0; i--) {
      ParticleBase p = particles.get(i);
      p.update();
      p.display();
      if (p.isDead()) {
        particles.remove(i);
      }
    }
    
    // フレーム換算
    int frame = (int)(remainTime() / (1000f / 60f));
    
    // 最後の50フレームでカード光る演出
    if (frame > totalDurationFrames - lastGlowFrames) {
      float t = map(frame, totalDurationFrames - lastGlowFrames, totalDurationFrames, 0, 1);
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
      rectMode(CORNER);
    }
    
    return remain() < 0 && particles.isEmpty();
  }
}

class EffectData3 extends EffectData {
  ArrayList<FireballParticle> attackParticles;
  ArrayList<CardBurnParticle> burnParticles;

  boolean attackActive = false;
  boolean burnActive = false;
  
  int frame = 0;

  EffectData3() {
    // durationは攻撃60フレーム + 燃焼80フレーム想定
    duration = (60 + 80) * (1000f / 60f);
    attackParticles = new ArrayList<>();
    burnParticles = new ArrayList<>();
  }

  void onStart() {
    attackParticles.clear();
    burnParticles.clear();

    for (int i = 0; i < 40; i++) {
      attackParticles.add(new FireballParticle(playerPos, opponentPos));
    }

    attackActive = true;
    burnActive = false;
    frame = 0;
  }

  boolean draw(GameData data) {
    if (attackActive) {
      fill(0, 40);
      rect(0, 0, width, height);

      for (int i = attackParticles.size() - 1; i >= 0; i--) {
        FireballParticle p = attackParticles.get(i);
        p.update();
        p.display();
        if (p.isDead()) attackParticles.remove(i);
      }

      frame++;
      if (frame > 60 || attackParticles.isEmpty()) {
        attackActive = false;
        burnActive = true;
        frame = 0;

        for (int i = 0; i < 60; i++) {
          burnParticles.add(new CardBurnParticle(opponentPos));
        }
      }
      return false; // 継続
    }
    else if (burnActive) {
      fill(0, 50);
      rect(0, 0, width, height);

      for (int i = burnParticles.size() - 1; i >= 0; i--) {
        CardBurnParticle p = burnParticles.get(i);
        p.update();
        p.display();
        if (p.isDead()) burnParticles.remove(i);
      }

      if (frame < 80) {
        float alpha = map(80 - frame, 0, 80, 0, 180);
        float scale = map(frame, 0, 80, 1.0f, 0.3f);

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
        rectMode(CORNER);
      }

      frame++;
      if (frame > 80 && burnParticles.isEmpty()) {
        burnActive = false;
      }
      return !burnActive; // burnActive falseなら終了
    }
    return true; // 両方無効なら終了
  }
}

class EffectData4 extends EffectData {
  ArrayList<CardGlowParticle> particles;
  int durationFrames = 150;
  int frame = 0;

  EffectData4() {
    duration = durationFrames * (1000f / 60f); // 60FPS換算のミリ秒
    particles = new ArrayList<>();
  }

  void onStart() {
    particles.clear();
    for (int i = 0; i < 60; i++) {
      particles.add(new CardGlowParticle(playerPos));
    }
    frame = 0;
  }

  boolean draw(GameData data) {
    fill(0, 30);
    rect(0, 0, width, height);

    for (int i = particles.size() - 1; i >= 0; i--) {
      CardGlowParticle p = particles.get(i);
      p.update();
      p.display();
      if (p.isDead()) particles.remove(i);
    }

    if (frame < durationFrames) {
      float alpha = map(durationFrames - frame, 0, durationFrames, 0, 220);
      float scale = map(frame, 0, durationFrames, 0.6f, 1.5f);

      fill(255, 255, 220, alpha);
      rectMode(CENTER);
      pushMatrix();
      translate(playerPos.x, playerPos.y - 40);
      scale(scale);
      noStroke();
      rect(0, 0, 60, 85, 20);

      fill(255, 200, 50, alpha * 0.8f);
      textAlign(CENTER, CENTER);
      textSize(36 * scale);
      text("+2", 0, 0);
      popMatrix();
      rectMode(CORNER);
    }

    frame++;
    return frame > durationFrames && particles.isEmpty();
  }
}

class EffectData5 extends EffectData {
  ArrayList<StealSpark> stealSparks;
  StealCard stealCard;
  int stealDurationFrames = 100;
  int frame = 0;

  EffectData5() {
    duration = stealDurationFrames * (1000f / 60f);
    stealSparks = new ArrayList<>();
  }

  void onStart() {
    stealSparks.clear();
    for (int i = 0; i < 80; i++) {
      stealSparks.add(new StealSpark(opponentPos));
    }
    stealCard = new StealCard(opponentPos, playerPos);
    frame = 0;
  }

  boolean draw(GameData data) {
    fill(0, 60);
    rect(0, 0, width, height);

    // パーティクル更新・描画
    for (int i = stealSparks.size() - 1; i >= 0; i--) {
      StealSpark s = stealSparks.get(i);
      s.update();
      s.display();
      if (s.age > s.lifetime) {
        stealSparks.remove(i);
      }
    }

    // カード本体更新・描画
    if (stealCard != null) {
      stealCard.update();
      stealCard.display();
    }

    frame++;

    // stealCard.isFinished()がtrueなら終了
    return stealCard != null && stealCard.isFinished();
  }
}


class EffectData6 extends EffectData {
  int durationFrames = 120;  // 2秒 (60fps)
  int frame = 0;
  PVector center;

  EffectData6() {
    duration = durationFrames * (1000f / 60f);
  }

  void onStart() {
    frame = 0;
    center = playerPos.copy();  // 使う位置はplayerPosとするなど調整可能
  }

  boolean draw(GameData data) {
    if (frame > durationFrames) return true;

    float progress = frame / (float)durationFrames;
    float alpha = sin(progress * PI) * 180 + 75;  // 透過が揺れる
    stroke(180, 220, 255, alpha);
    strokeWeight(max(1, 2 + 3 * sin(frame * 0.15f)));

    pushMatrix();
    translate(center.x, center.y);

    // 魔法陣の円
    int circles = 3;
    for (int i = 0; i < circles; i++) {
      float radius = 80 + i * 20 + 10 * sin(frame * 0.1f + i);
      radius = max(radius, 1);
      ellipse(0, 0, radius * 2, radius * 2);
    }

    // 回転する放射状ライン
    int rays = 12;
    float rotation = frame * 0.05f;
    for (int i = 0; i < rays; i++) {
      float angle = TWO_PI / rays * i + rotation;
      float len = 90 + 10 * sin(frame * 0.2f + i);
      float x = cos(angle) * len;
      float y = sin(angle) * len;
      line(0, 0, x, y);
    }

    // 輝く小円が回る
    int smallDots = 8;
    for (int i = 0; i < smallDots; i++) {
      float angle = TWO_PI / smallDots * i - rotation * 1.5f;
      float r = 70 + 5 * sin(frame * 0.3f + i);
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

    frame++;
    return false;  // 継続
  }
}


class EffectData7 extends EffectData {
  PVector from, to;
  int durationFrames;
  int frame;

  EffectData7() {
    this.durationFrames = 120;
    duration = durationFrames * (1000f / 60f);
  }

  void onStart() {
    frame = 0;
    from = playerPos.copy();
    to = opponentPos.copy();
  }

  boolean draw(GameData data) {
    float t = frame / (float)durationFrames;
    float alpha = 255 * sin(t * PI);

    // 軌道の乱れ（時間と共にやや安定）
    float offset = 10 * sin(frame * 0.3f) * (1 - t * 0.5f);
    PVector chaoticTo = new PVector(to.x + random(-offset, offset), to.y + random(-offset, offset));

    // ビーム（中心白→赤→紫の三重構造）
    strokeWeight(12);
    stroke(160, 0, 255, alpha * 0.4f);
    line(from.x, from.y, chaoticTo.x, chaoticTo.y);

    strokeWeight(6);
    stroke(255, 50, 100, alpha * 0.7f);
    line(from.x, from.y, chaoticTo.x, chaoticTo.y);

    strokeWeight(3);
    stroke(255, 255, 255, alpha);
    line(from.x, from.y, chaoticTo.x, chaoticTo.y);

    // 発射元の魔方陣
    pushMatrix();
    translate(from.x, from.y);
    rotate(frame * 0.05f);
    stroke(255, 0, 100, alpha * 0.6f);
    noFill();
    for (int i = 0; i < 3; i++) {
      float r = 50 + i * 25 + 5 * sin(frame * 0.1f + i);
      ellipse(0, 0, r, r);
    }
    popMatrix();

    // 着弾点での多重衝撃波リング
    for (int i = 0; i < 4; i++) {
      float ringR = (frame - i * 8) * 4;
      if (ringR > 0 && ringR < 300) {
        stroke(255, 80, 255, alpha * (1.0f - i * 0.2f));
        noFill();
        strokeWeight(1.5f);
        ellipse(to.x, to.y, ringR, ringR);
      }
    }

    // 火花散乱（無数のビット）
    for (int i = 0; i < 25; i++) {
      float angle = random(TWO_PI);
      float len = random(10, 35);
      float x1 = to.x + cos(angle) * len;
      float y1 = to.y + sin(angle) * len;
      stroke(255, 100, 255, alpha * 0.5f);
      strokeWeight(1);
      line(to.x, to.y, x1, y1);
    }

    frame++;
    return frame > durationFrames;
  }
}

class EffectData8 extends EffectData {
  int durationFrames;
  int frame;

  EffectData8() {
    this.durationFrames = 120;
    duration = durationFrames * (1000f / 60f);
  }

  void onStart() {
    frame = 0;
  }

  boolean draw(GameData data) {
    float t = frame / (float)durationFrames;
    float alpha = 255 * sin(t * PI);

    // 吸収ビーム（相手からプレイヤーへ）
    strokeWeight(10);
    stroke(100, 150, 255, alpha * 0.6f);
    line(opponentPos.x, opponentPos.y, lerp(opponentPos.x, playerPos.x, t), lerp(opponentPos.y, playerPos.y, t));

    strokeWeight(4);
    stroke(180, 220, 255, alpha);
    line(opponentPos.x, opponentPos.y, lerp(opponentPos.x, playerPos.x, t), lerp(opponentPos.y, playerPos.y, t));

    // プレイヤー付近にエネルギーの渦巻き
    pushMatrix();
    translate(playerPos.x, playerPos.y);
    noFill();
    stroke(150, 200, 255, alpha);
    strokeWeight(2 + 2 * sin(frame * 0.2f));
    for (int i = 0; i < 3; i++) {
      float r = 20 + 10 * i + 5 * sin(frame * 0.15f + i);
      ellipse(0, 0, r + frame * 0.5f, r + frame * 0.5f);
    }
    popMatrix();

    // 中間地点の小爆発
    if (t > 0.5f) {
      int sparks = 20;
      PVector mid = new PVector(
        lerp(opponentPos.x, playerPos.x, t),
        lerp(opponentPos.y, playerPos.y, t)
      );
      for (int i = 0; i < sparks; i++) {
        float angle = TWO_PI / sparks * i + frame * 0.3f;
        float len = 10 + 5 * sin(frame * 0.4f + i);
        float x = mid.x + cos(angle) * len;
        float y = mid.y + sin(angle) * len;
        stroke(150, 200, 255, alpha * (1 - (t - 0.5f) * 2));
        strokeWeight(1.5f);
        line(mid.x, mid.y, x, y);
      }
    }

    frame++;
    return frame > durationFrames;
  }
}

class EffectData9 extends EffectData {
  int durationFrames;
  int frame;

  EffectData9() {
    this.durationFrames = 120;
    duration = durationFrames * (1000f / 60f);
  }

  void onStart() {
    frame = 0;
  }

  boolean draw(GameData data) {
    float progress = frame / (float)durationFrames;

    // 光球のサイズと輝き（脈動）
    float baseRadius = 50;
    float radius = baseRadius + baseRadius * progress + 10 * sin(frame * 0.3f);
    float alpha = 150 + 105 * sin(progress * PI);

    noStroke();
    // 光球のグラデーション的な重ね円
    for (int i = 0; i < 5; i++) {
      float r = radius * (1 + i * 0.15f);
      fill(100, 180, 255, alpha * (1.0f - i * 0.2f));
      ellipse(playerPos.x, playerPos.y, r * 2, r * 2);
    }

    // 外側の回転リング
    stroke(150, 200, 255, alpha);
    strokeWeight(3);
    noFill();
    pushMatrix();
    translate(playerPos.x, playerPos.y);
    float rotation = frame * 0.04f;
    for (int i = 0; i < 4; i++) {
      float angle = TWO_PI / 4 * i + rotation;
      float ringRadius = radius * 1.8f;
      ellipse(cos(angle) * ringRadius, sin(angle) * ringRadius, 30, 30);
    }
    popMatrix();

    // 周囲を回る小さな光点
    noStroke();
    fill(180, 230, 255, alpha * 0.7f);
    pushMatrix();
    translate(playerPos.x, playerPos.y);
    int dotCount = 12;
    for (int i = 0; i < dotCount; i++) {
      float angle = TWO_PI / dotCount * i - frame * 0.08f;
      float r = radius * 1.3f;
      ellipse(cos(angle) * r, sin(angle) * r, 8, 8);
    }
    popMatrix();

    // テキストで「Charging...」
    fill(200, 230, 255, alpha);
    textAlign(CENTER, CENTER);
    textSize(24);
    text("Charging...", playerPos.x, playerPos.y + radius + 30);

    frame++;
    return frame > durationFrames;
  }
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
    rectMode(CORNER);
  }

  boolean isFinished() {
    return age > duration;
  }
}
