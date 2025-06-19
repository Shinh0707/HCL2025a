/* ─────────────  共通定義  ───────────── */
final int EFFECT_ATTACK = 0;         // 攻撃
final int EFFECT_HEAL   = 1;         // 回復
final int EFFECT_BOOST  = 2;         // 次の一撃が 1.5 倍

class Player {
  String name;
  int    hp    = 100;
  float  boost = 1.0;   // 1.0 通常 / 1.5 ブースト中
  boolean alive = true;
  Player(String n){ name = n; }
}

/* 魔法 ID(0‑24) → 3 タイプへ分類 */
int classifyMagic(int id){
  if(id == 16 || id == 17) return EFFECT_HEAL;   // ヒール系
  if(id == 19)             return EFFECT_BOOST;  // ブースト
  return EFFECT_ATTACK;                          // その他すべて攻撃
}

/* ──────────────────────────────────────
   ① 効果処理・プレイヤー状態変化
      caster  : 魔法を撃つ側
      target  : 受ける側（回復／強化時は caster を渡す）
      magicId : 出水さんの魔法 ID
   ────────────────────────────────────── */
void apply_magic(Player caster, Player target, int magicId){

  int type = classifyMagic(magicId);

  switch(type){

    case EFFECT_ATTACK:
      int dmg = int(20 * caster.boost);          // 基本 20
      target.hp -= dmg;
      if(target.hp <= 0){ target.hp = 0; target.alive = false; }
      println(caster.name+" attacks "+target.name+" for "+dmg);
      break;

    case EFFECT_HEAL:
      int heal = int(15 * caster.boost);         // 基本 15
      caster.hp = min(caster.hp + heal, 100);
      println(caster.name+" heals "+heal);
      break;

    case EFFECT_BOOST:
      caster.boost = 1.5;                        // 次の一撃だけ強化
      println(caster.name+" gains BOOST");
      return;                                    // ブースト自体ではリセットしない
  }
  caster.boost = 1.0;                            // 攻撃/回復を撃ったらブースト解除
}

/* ──────────────────────────────────────
   ② プレイヤー状態表示（見た目）
      左上に HP バーと BOOST アイコンを描画
   ────────────────────────────────────── */
void draw_pcond(Player[] ps){
  textAlign(LEFT,TOP); textSize(14);
  for(int i=0;i<ps.length;i++){
    Player p = ps[i];
    int y = 15 + i*25;

    fill(255); text(p.name+" HP:"+p.hp, 10, y);
    noStroke(); fill(220); rect(90, y-2, 100, 10);          // 背景バー
    fill(255,0,0); rect(90, y-2, map(p.hp,0,100,0,100),10); // HP
    if(p.boost>1.0){ fill(255,230,0); ellipse(200, y+3, 8, 8);} // BOOST
  }
}

/* ──────────────────────────────────────
   ③ ゲーム終了判定
      - どちらかの HP が 0 なら勝者/引き分けを表示して true
      - 続行なら false
   ────────────────────────────────────── */
boolean check(Player[] ps){
  Player winner = null;
  int aliveCnt = 0;
  for(Player p: ps) if(p.alive){ aliveCnt++; winner = p; }

  if(aliveCnt <= 1){
    textAlign(CENTER,CENTER); textSize(32); fill(255);
    if(aliveCnt==1) text(winner.name+" WINS!", width/2, height/2);
    else            text("DRAW!",              width/2, height/2);
    return true;     // ゲーム終了
  }
  return false;      // ゲーム続行
}

void draw_effects(int[] effectIds){
  for(int id : effectIds){
    draw_effect(id);
  }
}
void draw_effect(int effectId){
  // effectId => 
}
