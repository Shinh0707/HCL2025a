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
        return 1.0;
    }
    void _draw(GameData data){
        //println(" at standby");
    }
}

class CodingPhase extends TimerPhase{
    float maxTime(){
        return 45.0;
    }
    void _draw(GameData data){
        image(data.cam, 0, 0);
        fill(0, 150);
        rect(0, height - 100, width, 100);

        fill(255);
        textSize(24);
        textFont(data.font);
        textAlign(CENTER, CENTER);
        text("パズルタイマー: 残り " + remainingTime() + "秒", width / 2, height - 50);
    }
}

class HackPhase extends Phase{
    int startTime = 0;
    final int maxTime = 5*1000;
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
                        circle(center.x, center.y, 50);
                        data.players[0].detect(i);
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
                    circle(center.x, center.y, 50);
                    data.players[1].detect(i);
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
    void reset(GameData data){
        println("effect activated");
    }
    boolean draw(GameData data){
        // 効果に応じてプレイヤーのステータス変化
        // エフェクトも出す
        return true;
    }
}
