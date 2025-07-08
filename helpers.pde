import processing.video.*;
import jp.nyatla.nyar4psg.*;

Capture setupCamera(PApplet parent, int frameRate){
    String[] cameras = Capture.list();
    if (cameras.length != 0) {
        println(cameras);
        for (String camera : cameras){
            if (camera.indexOf("Virtual Camera") != -1){
                continue;
            }
            println("Use Camera ["+camera+"]");
            Capture cam = new Capture(parent, width, height, camera, frameRate);
            return cam;
        }
    }
    println("カメラが見つかりませんでした。");
    exit();
    return null;
}

PVector getMarkerCenter(MultiMarker nya, int i_id){
    PVector[] vertex = nya.getMarkerVertex2D(i_id);
    PVector center = new PVector(0,0,0);
    for(int i = 0; i < 4; i++){
        center.add(nya.screen2MarkerCoordSystem(i_id, int(vertex[i].x), int(vertex[i].y)));
    }
    center.div(4);
    return center;
}

PVector getMarkerCenterScreen(MultiMarker nya, int i_id){
    PVector center = getMarkerCenter(nya, i_id);
    return nya.marker2ScreenCoordSystem(i_id, center.x, center.y, center.z);
}

void showText(GameData data, String msg){
    fill(0, 150);
    rect(0, height - 100, width, 100);

    fill(255);
    textSize(24);
    textFont(data.font);
    textAlign(CENTER, CENTER);
    text(msg, width / 2, height - 50);
}