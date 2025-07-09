String NOISE_SHADER_PATH = "shader/noise.glsl";
class NoiseShader{
    PShader sh;
    NoiseShader(int w, int h){
        sh = loadShader(NOISE_SHADER_PATH);
        sh.set("r", float(w),float(h));
    }
    void apply(PImage img, float p0, float p1){
        sh.set("tex",img);
        sh.set("u_time",millis()/1000.0);
        sh.set("ps", p0, p1);
        filter(sh);
    }
}

void showText(GameData data, String msg){
    strokeWeight(1);
    stroke(255);
    fill(0, 150);
    rect(0, height - 100, width, 100);

    fill(255);
    textSize(24);
    textFont(data.font);
    textAlign(CENTER, CENTER);
    text(msg, width / 2, height - 50);
}

float aspect(PImage img){
    float w = img.width;
    float h = img.height;
    return w/h;
}

boolean inside(int _x, int _y, int rx, int ry, int rw, int rh){
    return (_x >= rx) && (_y >= ry) && (_x <= (rx+rw)) && (_y <= (ry+rh));
}

class RBox{
    float left;
    float right;
    float bottom;
    float top;

    RBox(float left, float right, float top, float bottom) {
        this.left = left;
        this.right = right;
        this.bottom = bottom;
        this.top = top;
    }

    int x(int width) {
        return int(this.left * width);
    }

    int y(int height) {
        return int(this.top * height);
    }

    int width(int _width) {
        return int(_width * (1.0 - this.left - this.right));
    }

    int height(int _height) {
        return int(_height * (1.0 - this.top - this.bottom));
    }

    void apply(int _width, int _height,BoxFunction func){
        func.accept(x(_width), y(_height), this.width(_width), this.height(_height));
    }
}

class RImg{
    float left;
    float right;
    float top;
    float asp;
    PImage img;

    RImg(PImage img, float left, float right, float top){
        this.img = img;
        asp = aspect(img); // w/h
        this.left = left;
        this.right = right;
        this.top = top;
    }

    int x(int width) {
        return int(this.left * width);
    }

    int y(int height) {
        return int(this.top * height);
    }

    float wrate(){
        return 1.0-left-right;
    }

    int width(int _width) {
        return int(_width * wrate());
    }

    int height(int _width) {
        return int(_width*wrate()/asp);
    }

    void apply(int _width, int _height, BoxImageFunction func){
        func.accept(img, x(_width), y(_height), this.width(_width), this.height(_width));
    }
}

interface BoxFunction{
    void accept(int x, int y, int w, int h);
}

interface BoxImageFunction{
    void accept(PImage img, int x, int y, int w, int h);
}

void rectButton(int x, int y, int w, int h, int textColor, String msg, Runnable onClick){
    rect(x, y, w, h);
    textSize(int(h*0.9));
    textAlign(CENTER, CENTER);
    fill(textColor);
    text(msg, x+w/2, y+h/2);
    if (mousePressed && inside(mouseX, mouseY, x, y, w, h)){
        onClick.run();
    }
}