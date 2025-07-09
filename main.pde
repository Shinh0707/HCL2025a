StartScreen scn;
EndScreen esn;
Phase[] phases;
GameData data;
int phase_i;

void setup(){
    //size(640,480,P3D);
    //colorMode(RGB, 255);
    size(1080, 780, P3D);
    colorMode(RGB, 255);
    println(MultiMarker.VERSION);
    scn = new StartScreen();
    esn = null;
    data = new GameData(this);
    phases = new Phase[5];
    phases[0] = new GamePhase();
    phases[1] = new StandbyPhase();
    phases[2] = new CodingPhase();
    phases[3] = new HackPhase();
    phases[4] = new EffectPhase();
    phase_i = 0;
}

void draw(){
    if (esn != null){
        if (esn.draw(data)){
            scn = new StartScreen();
            esn = null;
            data = new GameData(this);
            phases = new Phase[5];
            phases[0] = new GamePhase();
            phases[1] = new StandbyPhase();
            phases[2] = new CodingPhase();
            phases[3] = new HackPhase();
            phases[4] = new EffectPhase();
            phase_i = 0;
        }
        return;
    }
    if (scn.draw()){
        data.draw();
        if(phases[phase_i].draw(data)){
            if ((phase_i == 4) && !(data.players[0].isAlive() && data.players[1].isAlive())){
                esn = new EndScreen();
                return;
            }
            phase_i = (phase_i + 1)%5;
            phases[phase_i].reset(data);
        }
        data.pastdraw();
    }
}
