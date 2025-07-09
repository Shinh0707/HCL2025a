class StartScreen{
    final String logopath = "images/HCILogoW.png";
    RImg logoBox;
    RBox infoButtonBox;
    RBox buttonBox;
    boolean started = false;
    NoiseShader ns;
    PImage cimg;
    InfoScreen infos;

    StartScreen(){
        started = false;
        ns = new NoiseShader(width,height);
        infos = null;
        cimg = createImage(width,height,RGB);
        logoBox = new RImg(loadImage(logopath),0.2,0.2,0.1);
        infoButtonBox = new RBox(0.25,0.25,0.58,0.32);
        buttonBox = new RBox(0.3,0.3,0.75,0.15);
    }

    boolean draw(){
        fill(0);
        rect(0,0,width,height);
        if (infos != null){
            if (infos.draw()){
                infos = null;
            }else{
                return false;
            }
        }
        if (started) return true;
        logoBox.apply(
            width,
            height,
            (img,x,y,w,h) -> {
                image(img,x,y,w,h);
            }
        );
        infoButtonBox.apply(
            width,
            height,
            (x,y,w,h) -> {
                fill(inside(mouseX,mouseY,x,y,w,h)? 255: 200);
                rectButton(x,y,w,h,0,"HOW TO PLAY",() ->{
                    infos = new InfoScreen();
                });
            }
        );
        buttonBox.apply(
            width,
            height,
            (x,y,w,h) -> {
                fill(inside(mouseX,mouseY,x,y,w,h)? 255: 200);
                rectButton(x,y,w,h,0,"START",() ->{
                    started = true;
                });
            }
        );
        capture(cimg);
        ns.apply(cimg,0.5,0.5);
        return false;
    }
}

class InfoScreen{
    final String howtoplaypath = "images/HowToPlay.png";
    RImg img;
    boolean closed;
    InfoScreen(){
        img = new RImg(loadImage(howtoplaypath),0.01,0.01,0.01);
        closed = false;
    }
    boolean draw(){
        img.apply(
            width,
            height,
            (img,x,y,w,h) -> {
                image(img,x,y,w,h);
            }
        );
        fill(255);
        rectButton(width-int(height*0.05*1.5),int(width*0.01),int(height*0.05),int(height*0.05),0,"X",()->{
            closed = true;
        });
        return closed;
    }
}