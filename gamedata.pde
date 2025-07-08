import processing.video.*;
import jp.nyatla.nyar4psg.*;

class GameData{
    GameSettings settings;
    HPUI hpui;
    PImage[] markerImages;
    Player[] players;
    Capture cam;
    MultiMarker nya;
    PFont font;
    PApplet parent;

    GameData(PApplet parent){
        this.parent = parent;
        settings = new GameSettings();
        cam = setupCamera(parent, settings.FRAME_RATE);
        font = settings.createTextFont();
        players = new Player[2];
        players[0] = new Player(0, settings.MAX_HP);
        players[1] = new Player(1, settings.MAX_HP);
        hpui = new HPUI(settings.MAX_HP);
        nya = new MultiMarker(parent, width, height, settings.MARKER_FILE, NyAR4PsgConfig.CONFIG_PSG);
        nya.setLostDelay(1);
        markerImages = new PImage[settings.MARKER_COUNT];
        for (int i = 0; i < settings.MARKER_COUNT; i++){
            nya.addNyIdMarker(i,80);
            markerImages[i] = parent.loadImage("AR/" + i + ".jpg");
        }
        nya.addARMarker("data/patt.hiro",80);
        nya.addARMarker("data/patt.kanji",80);
        cam.start();
    }

    void draw(){
        if (cam.available()){
            cam.read();
        }
    }

    void pastdraw(){
        hpui.draw(this);
    }
}

class GameSettings{
    final int MARKER_COUNT = 10;
    final String FONT_NAME = "data/font/DotGothic16/DotGothic16-Regular.ttf";
    final String MARKER_FILE = "data/camera_para.dat";
    final int FRAME_RATE = 30;
    final int TEXT_FONTSIZE = 20;
    final int MAX_HP = 9;

    PFont createTextFont(){
        return createTextFont(TEXT_FONTSIZE);
    }
    PFont createTextFont(float fontSize){
        return createFont(FONT_NAME, fontSize);
    }
}

class Player{
    int id;
    int detected_id = -1;
    PVector markerPos = new PVector(0,0,0);
    EffectData activeEffect = null;
    float hp;
    int stacked = 0;

    Player(int id, int maxHp){
        this.id = id;
        int x = width/4;
        if (id == 0){
            x = width - x;
        }
        markerPos = new PVector(x,height/2,0);
        hp = maxHp;
    }
    void reduceHP(float value){
        hp = max(0,hp-value);
    }
    void stack(int value){
        stacked += value;
    }
    void ready(){
        activeEffect = null;
        detected_id = -1;
        stacked = max(0, stacked-1);
    }
    boolean isDetected(){
        return detected_id != -1;
    }
    void detect(int id, PVector pos){
        detected_id = id;
        markerPos = pos;
        setAction(id);
    }
    boolean drawAction(GameData data){
        if (activeEffect == null){
            return true;
        }
        return activeEffect.draw(data);
    }
    void startAction(PVector opponentPos){
        if (activeEffect == null){
            setAction(-1);
        }
        activeEffect.start(markerPos, opponentPos);
    }
    void setAction(int detected_id){
      println("Activate "+detected_id);
      switch(detected_id){
        case 0:
          activeEffect =new EffectData0();
          break;
        case 1:
          activeEffect =new EffectData0();
          break;
        case 2:
          activeEffect =new EffectData0();
          break;
        case 3:
          activeEffect =new EffectData0();
          break;
        case 4:
          activeEffect =new EffectData0();
          break;
        case 5:
          activeEffect =new EffectData0();
          break;
        case 6:
          activeEffect =new EffectData0();
          break;
        case 7:
          activeEffect =new EffectData0();
          break;
        case 8:
          activeEffect =new EffectData0();
          break;
        case 9:
          activeEffect =new EffectData0();
          break;
        default:
          activeEffect =new EffectData0();
          break;
      }
    }
}

static class HackSettings {
  public static final int[] attacks = {1,2,3,-1};
  public static boolean isAttackHack(int hack_id) {
    for(int id : HackSettings.attacks){
        if (hack_id == id){
            return true;
        }
    }
    return false;
  }
}
