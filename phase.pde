import java.util.function.*;

abstract class Phase{
    abstract void reset(GameData data);
    /**
    * このフェーズが終わるときに true を返す
    */
    abstract boolean draw(GameData data);
}

class GamePhase extends Phase{
    void reset(GameData data){
        println("main activated");
    }
    boolean draw(GameData data){
        fill(0,0,0);
        rect(0,0,width, height);
        //println("main");
        return true;
    }
}

abstract class TimerPhase extends Phase{
    int startTime = 0;
    void reset(GameData data){
        println("timer activated");
        startTime = millis();
    }
    boolean draw(GameData data){
        //println("timer: "+remainTime());
        _draw(data);
        return remainTime() <= 0;
    }
    int remainTime(){
        return int(maxTime()*1000) - (millis() - startTime);
    }
    int remainingTime(){
        return remainTime()/1000;
    }
    abstract float maxTime();
    abstract void _draw(GameData data);
}

class StandbyPhase extends TimerPhase{
    float maxTime(){
        return 0.5;
    }
    void _draw(GameData data){
        //println(" at standby");
    }
}

class CodingPhase extends TimerPhase{
    final int IMG_W = 100;
    final int IMG_H = 100;
    final int GAP = 30;        // 画像間の空白(px)
    final int BREAK_INDEX = 5; // 折り返し位置（5枚目で改行）

    float maxTime(){
        return 20.0;
    }
    void _draw(GameData data){
        fill(0,0,0);
        rect(0,0,width,height);
        float asp = aspect(data.markerImagePerfect);
        image(data.markerImagePerfect, 0, int((height-width/asp)/2), width, width/asp);
        /*
        {
            int cols = BREAK_INDEX;
            int rows = (data.settings.MARKER_COUNT + cols - 1) / cols;

            int totalW = cols * IMG_W + (cols - 1) * GAP;
            int totalH = rows * IMG_H + (rows - 1) * GAP;
            int remX = width - (IMG_W*BREAK_INDEX+GAP*(BREAK_INDEX-1));
            int remY = height - (IMG_H*(data.settings.MARKER_COUNT/BREAK_INDEX)+GAP*(data.settings.MARKER_COUNT/BREAK_INDEX-1));
            int offsetX = width - totalW - remX/2;  // 右端から内側にずらす
            int offsetY = height - totalH - remY/2; // 下端から内側にずらす

            for (int i = 0; i < data.settings.MARKER_COUNT; i++) {
                int x, y;
                if (i < BREAK_INDEX) {
                    x = i * (IMG_W + GAP);
                    y = 0;
                } else {
                    x = (i - BREAK_INDEX) * (IMG_W + GAP);
                    y = IMG_H + GAP;
                }
                image(data.markerImages[i], offsetX + x, offsetY + y, IMG_W, IMG_H);
            }
        }
        */
        showText(data, "制限時間: 残り " + remainingTime() + "秒");
    }
}

class HackPhase extends Phase{
    int startTime = 0;
    final int maxTime = 2*1000;
    PImage leftImg;
    PImage rightImg;
    PImage dummyImg;
    int check = 0;
    int interval = 0;
    void reset(GameData data){
        for(int i = 0;i < 2;i++){
            data.players[i].ready();
        }
        startTime = millis();
        leftImg = createImage(width, height, RGB);
        rightImg = createImage(width, height, RGB);
        dummyImg = createImage(width, height, RGB);
        check = 0;
        interval = 2;
        println("hack activated");
    }
    int remainTime(){
        return maxTime - (millis() - startTime);
    }
    boolean draw(GameData data){
        //println("hack "+remainTime());
        if (remainTime() < 0){
            return true;
        }
        background(0);
        //image(data.cam, 0, 0);
        data.nya.drawBackground(data.cam);
        if (interval != 0){
            data.nya.detect(dummyImg);
            interval -= 1;
            return false;
        }
        boolean skip = false;
        if (!data.players[0].isDetected()){
            boolean reddet = true;
            if (!data.players[1].isDetected()){
                if (check == 0){
                    reddet = false;
                }else{
                    skip = true;
                }
                check = 1 - check;
            }
            if (reddet){
                data.cam.loadPixels();
                leftImg.copy(data.cam, 0, 0, width/2, height, 0, 0, width/2, height);
                detect(leftImg,(i) -> {
                    PVector center = getMarkerCenterScreen(data.nya, i);
                    println(center);
                    if (center.x < width/2){
                        println("[L] Detected Marker "+i);
                        //circle(center.x, center.y, 50);
                        data.players[0].detect(i, center);
                        interval = 2;
                    }
                });
            }
        }
        if (!skip){
            skip = interval != 0;
        }
        if ((!skip) && (!data.players[1].isDetected())){
            data.cam.loadPixels();
            rightImg.copy(data.cam, width/2, 0, width/2, height, width/2, 0, width/2, height);
            detect(rightImg,(i) -> {
                PVector center = getMarkerCenterScreen(data.nya, i);
                println(center);
                if (center.x > width/2){
                    println("[R] Detected Marker "+i);
                    //circle(center.x, center.y, 50);
                    data.players[1].detect(i, center);
                    interval = 2;
                }
            });
        }
        return data.players[0].isDetected() && data.players[1].isDetected();
    }

    void detect(PImage img,Consumer<Integer> onDetected){
        data.nya.detect(img);
        for (int i = 0; i < data.settings.MARKER_COUNT; i++) {
            if (!data.nya.isExist(i)) {
                continue;
            }
            onDetected.accept(i);
            break;
        }
    }
}

class EffectPhase extends Phase{
    int startTime = 0;
    int intarvalStartTime = 0;
    int maxTime = 5*1000;
    int solved = 0;
    PImage result;
    String showedText = "";
    boolean ended = false;
    boolean p0ended = false;
    boolean p1ended = false;
    void reset(GameData data){
        println("effect activated");
        ended = false;
        p0ended = false;
        p1ended = false;
        result = data.cam.get(0,0,width, height);
        showedText = "";
        startTime = millis();
        intarvalStartTime = millis() - 5000;
        solved = 0;
    }
    int remainTime(){
        return maxTime - (millis() - startTime);
    }
    boolean draw(GameData data){
        if (ended) return true;
        // HPUI.draw()
        image(result, 0, 0);
        if (solved != 0){
            if (solved%2 == 1){
                if (!p0ended){
                    p0ended = data.players[0].drawAction(data);
                }
            }
            if (solved/2 == 1){
                if (!p1ended){
                    p1ended = data.players[1].drawAction(data);
                }
            }
        }
        if (showedText.length() != 0){
          showText(data, showedText);
        }
        if (millis() - intarvalStartTime < 5*1000){
            return false;
        }
        if (solved != 3){
            PVector center0 = data.players[0].markerPos;// 画面上でのマーカーの中心位置
            PVector center1 = data.players[1].markerPos;// 画面上でのマーカーの中心位置
            
            if ((solved%2 != 1) && !((data.players[1].detected_id == 6) && (solved/2 != 1))){
                if (hack(data.players[0].detected_id, data.players[1].detected_id).accept(data, data.players[0], data.players[1])){
                    data.players[0].startAction(center1);
                }
                solved += 1;
                println("P1 solved");
            } else if(solved/2 != 1){
                if(hack(data.players[1].detected_id, data.players[0].detected_id).accept(data, data.players[1], data.players[0])){
                    data.players[1].startAction(center0);
                }
                solved += 2;
                println("P2 solved");
            }
            intarvalStartTime = millis();
            return false;
        }
        // 各エフェクトにつき1つの関数を作成する
        if ((p0ended && p1ended) && (solved == 3)){
            ended = true;
        }
        return ended;
    }

    HackAction hack(int id0, int id1){
        boolean isatk = HackSettings.isAttackHack(id1);
        switch (id0) {
            case 0:
                int choice = int(random(0,2));
                switch (choice){
                    case 0:
                        return (data, p0, p1) -> {
                            damage(data, p0.id, 1);
                            return true;
                        };
                    default:
                        return (data, p0, p1) -> {
                            lost(data, p0.id, 2);
                            return true;
                        };
                }
            case 1:
                return (data, p0, p1) -> {
                    return damage(data, p1.id, 2);
                };
            case 2:
                return (data, p0, p1) -> {
                    boolean success = damage(data, p1.id, 1);
                    get(data, p0.id, 1, true);
                    return success;
                };
            case 3:
                return (data, p0, p1) -> {
                    boolean success = damage(data, p1.id, 1);
                    lost(data, p1.id, 1, true);
                    return success;
                };
            case 4:
                return (data, p0, p1) -> {
                    get(data, p0.id, 2);
                    return true;
                };
            case 5:
                return (data, p0, p1) -> {
                    showedText = "プレイヤー"+(p0.id+1)+"はプレイヤー"+(p1.id+1)+"からパーツを"+1+"個奪取する";
                    return true;
                };
            case 6:
                return (data, p0, p1) -> {
                    showedText = "プレイヤー"+(p0.id+1)+"はガードした";
                    return true;
                };
            case 7:
                if (!isatk){
                    return (data, p0, p1) -> {
                        damage(data, p1.id, 4, true);
                        return true;
                    };
                }
                return (data, p0, p1) -> {
                    showedText = "プレイヤー"+(p0.id+1)+"は攻撃に失敗した";
                    return false;
                };
            case 8:
                if (isatk){
                    return (data, p0, p1) -> {
                        return damage(data, p1.id, 3);
                    };
                }
                return (data, p0, p1) -> {
                    showedText = "プレイヤー"+(p0.id+1)+"は攻撃に失敗した";
                    return false;
                };
            case 9:
                return (data, p0, p1) -> {
                    data.players[p0.id].stack(2);
                    showedText = "プレイヤー"+(p0.id+1)+"は1溜めた";
                    return true;
                };
            default:
                return (data, p0, p1) -> {
                    return damage(data, p1.id, 1);
                };
        }
    }
    boolean damage(GameData data, int target, float value){
        return damage(data, target, value, false);
    }
    boolean damage(GameData data, int target, float value, boolean cantstop){
        if ((data.players[target].detected_id == 6) && (!cantstop)){
            showedText = "プレイヤー"+(target+1)+"は攻撃を防いだ";
            return false;
        }else{
            float dmg = value*(1+data.players[1-target].stacked);
            showedText = "プレイヤー"+(target+1)+"は"+dmg+"の障害を受けた";
            data.hpui.registerDamage(data.players[target].id, dmg);
            data.players[target].reduceHP(dmg);
            return true;
        }
    }
    void get(GameData data, int target, int value){
        get(data, target, value, false);
    }
    void get(GameData data, int target, int value, boolean isAdded){
        int val = int(value*(1+data.players[target].stacked));
        String txt = "プレイヤー"+(target+1)+"はパーツを"+val+"個獲得する";
        if (isAdded){
            showedText += "\n"+txt;
        }else{
            showedText = txt;
        }
    }
    void lost(GameData data, int target, int value){
        lost(data, target, value, false);
    }
    void lost(GameData data, int target, int value, boolean isAdded){
        int val = int(value*(1+data.players[1-target].stacked));
        String txt = "プレイヤー"+(target+1)+"はパーツを"+val+"個失う";
        if (isAdded){
            showedText += "\n"+txt;
        }else{
            showedText = txt;
        }
    }
}

interface HackAction{
    boolean accept(GameData data, Player p0, Player p1);
}
/*
void drawAction0(GameData data, PVector player, PVector opponent){
    if (data.nya.isExist(0)){  // ARマーカーが認識されていれば(必須), 0はマーカーID
        data.nya.beginTransform(0);// 0はマーカーID
        noStroke();
        lights();
        translate(232, 192, 0);
        sphere(112);
        data.nya.endTransform();
    } // ↑3D表示するならここの中でかく
    for(int i = 0; i < 5; i++){
        fill(255,255,255);
        rect(
        int(player.x + random(-width/10,width/10)),
        int(player.y + random(-height/10,height/10)),
        3*(i+1), 3*(i+1));
    }
    // ↑いい感じのエフェクト
}
*/
