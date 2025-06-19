class Marker {
    int id;
    int magicId;
}

class Effect {
    int id;
}

class Magic {
    int id;
    String name;
    String description;
    int[] effectIds;
}

class Buff extends Effect{
    int life;
}

class PlayerStatus{
    float hp;
    Buff[] buffs;

    boolean isAlive() {
        return hp > 0;
    }

    void addHP(float value){
        hp = constrain(hp+value,0.0,settings.PLAYER_MAX_HP);
    }
}

class Player {
    int id;
    PlayerStatus status;

    boolean isAlive() { return status.isAlive();}
    void addHP(float value) { status.addHP(value);}
}