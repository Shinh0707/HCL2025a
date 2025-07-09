class EndScreen{
    RBox buttonBox;
    NoiseShader ns;
    PImage cimg;
    boolean ended = false;

    EndScreen(){
        ended = false;
        ns = new NoiseShader(width,height);
        buttonBox = new RBox(0.3,0.3,0.75,0.15);
        cimg = createImage(width, height, RGB);
    }

    boolean draw(GameData data){
        fill(0);
        rect(0,0,width,height);
        if (ended && !mousePressed) return true;
        fill(255);
        textFont(data.font, 32);
        textSize(64);
        textAlign(CENTER, CENTER);
        float p = 0.3;
        if (data.players[0].isAlive()){
            text("プレイヤー1 が 勝利した", width/2, height/2);
        } else if (data.players[1].isAlive()){
            text("プレイヤー2 が 勝利した", width/2, height/2);
        } else {
            p = 0.5;
            text("勝者 は いなかった", width/2, height/2);
        }
        buttonBox.apply(
            width,
            height,
            (x,y,w,h) -> {
                fill(inside(mouseX,mouseY,x,y,w,h)? 255: 200);
                rectButton(x,y,w,h,0,"Return",() ->{
                    ended = true;
                });
            }
        );
        capture(cimg);
        ns.apply(cimg,p,p);
        return false;
    }
}