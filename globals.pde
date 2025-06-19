final int MAGIC_COUNT = 25;     // 魔法総数
final int MARKER_COUNT = 10;    // マーカー数
final int CHANGE_INTERVAL = 10 * 1000;  // 魔法割り当て切替間隔(ms)

Capture cam;
MultiMarker nya;

int[] magicAssign = new int[MARKER_COUNT];  // マーカーごとの魔法ID割当
Magic[] magics = new Magic[MAGIC_COUNT];

int lastChange = 0;

int turn = 1;  
int turn1Count = 0;
int turn2Count = 0;
int turnTime = 10;    
int remainingTime;
int turnStartMillis;

PFont font;
