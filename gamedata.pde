import processing.video.*;
import jp.nyatla.nyar4psg.*;

class GameData{
    GameSettings settings;
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
        players[0] = new Player(settings.MAX_HP);
        players[1] = new Player(settings.MAX_HP);
        nya = new MultiMarker(parent, width, height, settings.MARKER_FILE, NyAR4PsgConfig.CONFIG_PSG);
        nya.setLostDelay(1);
        for (int i = 0; i < settings.MARKER_COUNT; i++){
            nya.addNyIdMarker(i,80);
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
}

class GameSettings{
    final int MARKER_COUNT = 10;
    final String FONT_NAME = "data/font/DotGothic16/DotGothic16-Regular.ttf";
    final String MARKER_FILE = "data/camera_para.dat";
    final int FRAME_RATE = 30;
    final int TEXT_FONTSIZE = 20;
    final int MAX_HP = 100;

    PFont createTextFont(){
        return createTextFont(TEXT_FONTSIZE);
    }
    PFont createTextFont(float fontSize){
        return createFont(FONT_NAME, fontSize);
    }
}

class Player{
    int detected_id = -1;
    float hp;

    Player(int maxHp){
        hp = maxHp;
    }

    void ready(){
        detected_id = -1;
    }
    boolean isDetected(){
        return detected_id != -1;
    }
    void detect(int id){
        detected_id = id;
    }
}