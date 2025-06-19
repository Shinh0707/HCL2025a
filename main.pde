void setup(){
  setupMarkers();
  size(640, 480);
  font = createFont("MS Gothic", 20); 
  textFont(font);
  textAlign(CENTER, CENTER);
  String[] cameras = Capture.list();
  if (cameras.length == 0) {
    println("カメラが見つかりませんでした。");
    exit();
  } else {
    cam = new Capture(this, cameras[0], height, width);
    cam.start();
  }
  frameRate(30);
}