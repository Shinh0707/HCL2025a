import processing.video.*;
import jp.nyatla.nyar4psg.*;

Capture setupCamera(PApplet parent, int _frameRate){
    String[] cameras = Capture.list();
    if (cameras.length != 0) {
        for (String camera : cameras){
            println(camera);
            if (camera.indexOf("Virtual Camera") != -1){
                continue;
            }
            println("Use Camera ["+camera+"]");
            try {
                Capture cam = new Capture(parent, width, height, camera, _frameRate);
                cam.start();
                return cam;
            } catch (Exception e) {
                continue;
            }
        }
        return setupCamera(parent, _frameRate);
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

void capture(PImage dst){
    loadPixels();
    dst.pixels = pixels;
    dst.updatePixels();
}
