import processing.opengl.*;
import processing.video.*;
import jp.nyatla.nyar4psg.*;
import java.util.ArrayList;
import java.util.Collections;


void setup() {
  // NyARToolkit初期化
  nya = new MultiMarker(this, width, height, "camera_para.dat", NyAR4PsgConfig.CONFIG_PSG);
  for (int i = 0; i < MARKER_COUNT; i++) {
    nya.addNyIdMarker(i, 80);
  }

  initMagics();
  assignRandomMagic();
}

void draw() {
  background(0);

  if (cam.available()) {
    cam.read();
  }

  // カメラ映像描画（透過調整可）
  tint(255, 100);
  image(cam, 0, 0, width, height);
  noTint();

  // マーカー検出（カメラ映像を渡す）
  nya.detect(cam);

  // 各マーカーが検出されていれば魔法モデル表示
  for (int i = 0; i < MARKER_COUNT; i++) {
    if (nya.isExist(i)) {
      pushMatrix();
      nya.beginTransform(i);

      int magicId = magicAssign[i];
      Magic m = magics[magicId];

      // 回転で見栄えアップ
      float angle = frameCount * 0.02f;
      drawMagicModel(magicId, m.name, angle);

      nya.endTransform();
      popMatrix();
    }
  }

  // 一定時間経過したら魔法割当を再シャッフル
  if (millis() - lastChange > CHANGE_INTERVAL) {
    assignRandomMagic();
    lastChange = millis();
  }

  // 情報表示
  fill(255);
  textSize(14);
  text("ARマーカーに魔法を表示中 (10秒ごとに切替)", width/2, height - 20);
}

// 魔法の初期化
void initMagics() {
  magics[0] = new Magic("ファイア", "普通の炎攻撃");
  magics[1] = new Magic("マグマ", "強力な炎攻撃");
  magics[2] = new Magic("アイス", "普通の氷攻撃");
  magics[3] = new Magic("ブリザード", "強力な氷攻撃");
  magics[4] = new Magic("ウォーター", "普通の水攻撃");
  magics[5] = new Magic("スコール", "強力な水攻撃");
  magics[6] = new Magic("ウィンド", "普通の風攻撃");
  magics[7] = new Magic("トルネード", "強力な風攻撃");
  magics[8] = new Magic("ボルト", "普通の雷攻撃");
  magics[9] = new Magic("サンダー", "強力な雷攻撃");
  magics[10] = new Magic("シャイン", "普通の光攻撃");
  magics[11] = new Magic("ゴッドレイ", "強力な光攻撃");
  magics[12] = new Magic("ダーク", "普通の闇攻撃");
  magics[13] = new Magic("ブラックポイズン", "強力な闇攻撃");
  magics[14] = new Magic("マッド", "普通の土攻撃");
  magics[15] = new Magic("グラウンド", "強力な土攻撃");
  magics[16] = new Magic("ヒール", "普通の回復技");
  magics[17] = new Magic("モアヒール", "強力な回復技");
  magics[18] = new Magic("ケア", "状態異常回復");
  magics[19] = new Magic("ブースト", "攻撃力アップ");
  magics[20] = new Magic("ガード", "守備力アップ");
  magics[21] = new Magic("ポイズン", "毒状態にする");
  magics[22] = new Magic("ダウン", "攻撃力ダウン");
  magics[23] = new Magic("クラッシュ", "守備力ダウン");
  magics[24] = new Magic("ランダム", "ランダム効果");
}

// ランダムに魔法をマーカーへ割り当て
void assignRandomMagic() {
  ArrayList<Integer> pool = new ArrayList<Integer>();
  for (int i = 0; i < MAGIC_COUNT; i++) {
    pool.add(i);
  }
  Collections.shuffle(pool);
  for (int i = 0; i < MARKER_COUNT; i++) {
    magicAssign[i] = pool.get(i);
  }
}

// 魔法の3Dモデル描画
void drawMagicModel(int idx, String name, float ang) {
  pushMatrix();
  scale(0.5f);
  rotateY(ang);

  noStroke();

  switch (idx) {
    case 0:  fill(255, 100, 0);  cone(15, 30); break;
    case 1:  fill(255, 50, 0);   sphere(20); break;
    case 2:  fill(0, 150, 255);  box(20); break;
    case 3:  fill(100, 200, 255); cone(12, 25); break;
    case 4:  fill(0, 100, 255);  sphere(18); break;
    case 5:  fill(0, 70, 200);   cylinder(15, 30); break;
    case 6:  fill(200);          torus(15, 5); break;
    case 7:  fill(180);          cone(15, 40); break;
    case 8:  fill(255, 255, 0);  box(10, 30, 5); break;
    case 9:  fill(255, 255, 100); cylinder(10, 35); break;
    case 10: fill(255);          sphere(18); break;
    case 11: fill(255, 255, 255, 150); cylinder(8, 40); break;
    case 12: fill(100, 0, 150);  box(20); break;
    case 13: fill(50, 0, 100);   sphere(20); break;
    case 14: fill(120, 70, 10);  box(20, 15, 20); break;
    case 15: fill(80, 50, 10);   translate(0, 5, 0); box(25, 10, 25); break;
    case 16: fill(0, 200, 0);    torus(15, 5); break;
    case 17: fill(0, 255, 0);    sphere(18); break;
    case 18: fill(255, 150, 0);  cone(10, 20); break;
    case 19: fill(255, 200, 50); torus(20, 8); break;
    case 20: fill(150, 150, 150); box(18); break;
    case 21: fill(50, 200, 50);  sphere(15); break;
    case 22: fill(200, 0, 0);    cone(15, 30); break;
    case 23: fill(100, 50, 50);  box(15, 30, 15); break;
    case 24: fill(150, 0, 200);  torus(18, 7); break;
    default: fill(255); sphere(10); break;
  }
  popMatrix();
}

// 魔法クラス
class Magic {
  String name;
  String description;

  Magic(String name, String description) {
    this.name = name;
    this.description = description;
  }
}

// 3D図形の追加実装（cone, cylinder, torus）
// Processing標準にないので簡易実装例を入れておきます

void cone(float r, float h) {
  int detail = 24;
  beginShape(TRIANGLE_FAN);
  vertex(0, -h/2, 0); // 頂点（尖り）
  for (int i = 0; i <= detail; i++) {
    float angle = TWO_PI / detail * i;
    float x = r * cos(angle);
    float z = r * sin(angle);
    vertex(x, h/2, z);
  }
  endShape();
}

void cylinder(float r, float h) {
  int detail = 24;
  beginShape(QUAD_STRIP);
  for (int i = 0; i <= detail; i++) {
    float angle = TWO_PI / detail * i;
    float x = r * cos(angle);
    float z = r * sin(angle);
    vertex(x, -h/2, z);
    vertex(x, h/2, z);
  }
  endShape();

  // 底面
  beginShape(TRIANGLE_FAN);
  vertex(0, -h/2, 0);
  for (int i = 0; i <= detail; i++) {
    float angle = TWO_PI / detail * i;
    vertex(r * cos(angle), -h/2, r * sin(angle));
  }
  endShape();

  // 天面
  beginShape(TRIANGLE_FAN);
  vertex(0, h/2, 0);
  for (int i = 0; i <= detail; i++) {
    float angle = TWO_PI / detail * i;
    vertex(r * cos(angle), h/2, r * sin(angle));
  }
  endShape();
}

void torus(float r1, float r2) {
  int detail = 24;
  int detail2 = 12;
  for (int i = 0; i < detail; i++) {
    float angle = TWO_PI / detail * i;
    float nextAngle = TWO_PI / detail * (i+1);
    beginShape(QUAD_STRIP);
    for (int j = 0; j <= detail2; j++) {
      float angle2 = TWO_PI / detail2 * j;
      float x1 = (r1 + r2 * cos(angle2)) * cos(angle);
      float z1 = (r1 + r2 * cos(angle2)) * sin(angle);
      float y1 = r2 * sin(angle2);
      vertex(x1, y1, z1);

      float x2 = (r1 + r2 * cos(angle2)) * cos(nextAngle);
      float z2 = (r1 + r2 * cos(angle2)) * sin(nextAngle);
      float y2 = y1;
      vertex(x2, y2, z2);
    }
    endShape();
  }
}
