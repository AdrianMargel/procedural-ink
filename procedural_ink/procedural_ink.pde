public class Vector {
  public float x;
  public float y;
  public Vector(float x, float y) {
    this.x=x;
    this.y=y;
  }
  public Vector(Vector vec) {
    this.x=vec.x;
    this.y=vec.y;
  }
  public void addVec(Vector vec) {
    x+=vec.x;
    y+=vec.y;
  }
  public void subVec(Vector vec) {
    x-=vec.x;
    y-=vec.y;
  }
  public void sclVec(float scale) {
    x*=scale;
    y*=scale;
  }
  public void nrmVec() {
    sclVec(1/getMag());
  }
  public void nrmVec(float mag) {
    sclVec(mag/getMag());
  }
  public void limVec(float lim) {
    float mag=getMag();
    if (mag>lim) {
      sclVec(lim/mag);
    }
  }
  public float getAng() {
    return atan2(y, x);
  }
  public float getAng(Vector vec) {
    return atan2(vec.y-y, vec.x-x);
  }
  public float getMag() {
    return sqrt(sq(x)+sq(y));
  }
  public float getMag(Vector vec) {
    return sqrt(sq(vec.x-x)+sq(vec.y-y));
  }
  public void rotVec(float rot) {
    float mag=getMag();
    float ang=getAng();
    ang+=rot;
    x=cos(ang)*mag;
    y=sin(ang)*mag;
  }
}

class Tile {
  Vector pos;
  float value;
  boolean changed;
  Tile(Vector p, float val) {
    pos=new Vector(p);
    value=val;
    changed=true;
  }
  float getVal() {
    return value;
  }
  void setVal(float val) {
    changed=true;
    value=val;
  }

  Vector getPos() {
    return new Vector(pos);
  }
}

class Particle {
  Vector pos;
  float speed;
  float angle;
  float saturation;
  Particle(Vector p) {
    pos=new Vector(p);
    speed=0;
  }
  void run(Map map) {
    int x=map.getGridX(pos.x);
    int y=map.getGridY(pos.y);

    ArrayList<Tile> lowestTiles=new ArrayList<Tile>();
    ArrayList<Vector> lowestDiffs=new ArrayList<Vector>();
    
    float lowestVal=Integer.MAX_VALUE;
    for (int tx=-range; tx<=range; tx++) {
      for (int ty=-range; ty<=range; ty++) {
        if(tx==0||ty==0){
          continue;
        }
        Vector distCalc=new Vector(tx,ty);
        if(distCalc.getMag()>range){
          continue;
        }
        Tile testTile=map.getGridTile(x+tx, y+ty);
        if (testTile!=null) {
          float testVal=testTile.getVal();
          if (testVal<lowestVal) {
            lowestTiles=new ArrayList<Tile>();
            lowestDiffs=new ArrayList<Vector>();
            
            lowestTiles.add(testTile);
            lowestDiffs.add(new Vector(tx,ty));
            lowestVal=testVal;
          }else if (testVal==lowestVal) {
            lowestTiles.add(testTile);
            lowestDiffs.add(new Vector(tx,ty));
          }
          
        }
      }
    }
    if (lowestTiles.size()!=0) {
      
      int index=(int)random(0,lowestTiles.size());
      Vector lowDiff=lowestDiffs.get(index);
      Tile lowest=lowestTiles.get(index);
      
      Tile onTile=map.getTile(pos);
      
      int diffX=(int)lowDiff.x;
      int diffY=(int)lowDiff.y;
      
      if (onTile!=null) {
        float val=onTile.getVal();
        
        Vector diff=new Vector(map.getRealX(diffX), map.getRealY(diffY));

        //diff.sclVec(-1);
        
        float newAng=diff.getAng();
        float newSpeed=1;
        if(diffX==0&&diffY==0){
          newSpeed=0;
        }
        
        float keep=curve;
        float replace=1-curve;
        
        Vector angChange=new Vector(cos(angle)*speed*keep,sin(angle)*speed*keep);
        angChange.addVec(new Vector(cos(newAng)*newSpeed*replace,sin(newAng)*newSpeed*replace));
        angle=angChange.getAng();
        speed=newSpeed;
        
        /*diff.sclVec(1);
        velo.addVec(diff);

        velo.limVec(1);*/

        onTile.setVal(min(val+weight,35.5));
        //onTile.setVal(50);
      }
    }
  }
  void move() {
    Vector velo=new Vector(cos(angle)*speed,sin(angle)*speed);
    pos.addVec(velo);
    //velo=new Vector(0,0);
  }
  void lim(float xLim, float yLim) {//<<>>
    float x=pos.x;
    float y=pos.y;

    while (x>=xLim) {
      x-=xLim;
    }
    while (x<0) {
      x+=xLim;
    }

    while (y>=yLim) {
      y-=yLim;
    }
    while (y<0) {
      y+=yLim;
    }
  }
  void display(float zoom,Map map){
    float dx=map.getGridFX(pos.x,true);
    float dy=map.getGridFY(pos.y,true);
    noFill();
    stroke(0);
    ellipse(dx*zoom,dy*zoom,10,10);
    stroke(255,0,0);
    line(dx*zoom+cos(angle)*10,dy*zoom+sin(angle)*10,dx*zoom,dy*zoom);
  }
}

class Particle2 extends Particle{
  Particle2(Vector p) {
    super(p);
  }
  @Override
  void run(Map map) {
    int x=map.getGridX(pos.x);
    int y=map.getGridY(pos.y);

    ArrayList<Tile> highestTiles=new ArrayList<Tile>();
    ArrayList<Vector> highestDiffs=new ArrayList<Vector>();
    
    float highestVal=Integer.MIN_VALUE;
    for (int tx=-range2; tx<=range2; tx++) {
      for (int ty=-range2; ty<=range2; ty++) {
        if(tx==0||ty==0){
          continue;
        }
        Vector distCalc=new Vector(tx,ty);
        if(distCalc.getMag()>range2){
          continue;
        }
        Tile testTile=map.getGridTile(x+tx, y+ty);
        if (testTile!=null) {
          float testVal=testTile.getVal();
          if (testVal>highestVal) {
            highestTiles=new ArrayList<Tile>();
            highestDiffs=new ArrayList<Vector>();
            
            highestTiles.add(testTile);
            highestDiffs.add(new Vector(tx,ty));
            highestVal=testVal;
          }else if (testVal==highestVal) {
            highestTiles.add(testTile);
            highestDiffs.add(new Vector(tx,ty));
          }
          
        }
      }
    }
    if (highestTiles.size()!=0) {
      
      int index=(int)random(0,highestTiles.size());
      Vector lowDiff=highestDiffs.get(index);
      Tile high=highestTiles.get(index);
      
      Tile onTile=map.getTile(pos);
      
      int diffX=(int)lowDiff.x;
      int diffY=(int)lowDiff.y;
      
      if (onTile!=null) {
        float val=onTile.getVal();
        
        Vector diff=new Vector(map.getRealX(diffX), map.getRealY(diffY));
        
        //diff.sclVec(-1);
        
        float newAng=diff.getAng();
        float newSpeed=1;
        if(diffX==0&&diffY==0){
          newSpeed=0;
        }
        
        float keep=curve2;
        float replace=1-curve2;
        
        Vector angChange=new Vector(cos(angle)*speed*keep,sin(angle)*speed*keep);
        angChange.addVec(new Vector(cos(newAng)*newSpeed*replace,sin(newAng)*newSpeed*replace));
        angle=angChange.getAng();
        speed=newSpeed;
        
        /*diff.sclVec(1);
        velo.addVec(diff);

        velo.limVec(1);*/

        onTile.setVal(max(val-weight2,-10));
        //onTile.setVal(50);
      }
    }
  }
}

class Map {
  Tile[][] tiles;
  float scale;
  ArrayList<Particle> ink;
  Map(int wide, int high, float s) {
    scale=s;
    ink=new ArrayList<Particle>();
    tiles=new Tile[wide][high];
    for (int x=0; x<wide; x++) {
      for (int y=0; y<high; y++) {
        //tiles[x][y]=new Tile(new Vector(x*scale, y*scale), (random(0, 1)+(high-y)/10f));
        //tiles[x][y]=new Tile(new Vector(x*scale, y*scale), random(0, 10));
        if(x>=400){
          tiles[x][y]=new Tile(new Vector(x*scale, y*scale), 25.5);
        }else
          tiles[x][y]=new Tile(new Vector(x*scale, y*scale), 0);
      }
    }
  }
  void run() {
    for (int i=0; i<ink.size(); i++) {
      ink.get(i).move();
      ink.get(i).run(canvas);
    }
  }
  float getRealX(float x) {
    return x*scale;
  }
  float getRealY(float y) {
    return y*scale;
  }
  float getGridFX(float x){
    return getGridFX(x,false);
  }
  float getGridFX(float x,boolean wrap) {
    float gridX = x/scale;
    if(wrap){
      while (gridX>=tiles.length) {
        gridX-=tiles.length;
      }
      while (gridX<0) {
        gridX+=tiles.length;
      }
    }
    return gridX;
  }
  float getGridFY(float y){
    return getGridFY(y,false);
  }
  float getGridFY(float y,boolean wrap) {
    float gridY = y/scale;
    if(wrap){
      while (gridY>=tiles[0].length) {
        gridY-=tiles[0].length;
      }
      while (gridY<0) {
        gridY+=tiles[0].length;
      }
    }
    return gridY;
  }
  int getGridX(float x){
    return getGridX(x,false);
  }
  int getGridX(float x,boolean wrap) {
    int gridX = floor((x/scale));
    if(wrap){
      while (gridX>=tiles.length) {
        gridX-=tiles.length;
      }
      while (gridX<0) {
        gridX+=tiles.length;
      }
    }
    return gridX;
  }
  int getGridY(float y){
    return getGridY(y,false);
  }
  int getGridY(float y,boolean wrap) {
    int gridY = floor((y/scale));
    if(wrap){
      while (gridY>=tiles[0].length) {
        gridY-=tiles[0].length;
      }
      while (gridY<0) {
        gridY+=tiles[0].length;
      }
    }
    return gridY;
  }
  Tile getTile(Vector pos) {
    return getTile(pos.x, pos.y);
  }
  Tile getTile(float tx, float ty) {
    int x=getGridX(tx);
    int y=getGridY(ty);
    return getGridTile(x, y);
  }
  Tile getGridTile(int tx, int ty) {
    int x=tx;
    int y=ty;

    while (x>=tiles.length) {
      x-=tiles.length;
    }
    while (x<0) {
      x+=tiles.length;
    }

    while (y>=tiles[x].length) {
      y-=tiles[x].length;
    }
    while (y<0) {
      y+=tiles[x].length;
    }

    if (x<tiles.length&&x>=0&&y<tiles[x].length&&y>=0) {
      return tiles[x][y];
    } else {
      return null;
    }
  }
  void addInk(Particle toAdd) {
    ink.add(toAdd);
  }
  void display(float zoom) {
    for (int x=0; x<tiles.length; x++) {
      for (int y=0; y<tiles[0].length; y++) {
        if(tiles[x][y].changed){
          tiles[x][y].changed=false;
          noStroke();
          float val=tiles[x][y].getVal();
          fill(min(max(val*10, 0), 255));
          rect(x*zoom, y*zoom, zoom, zoom);
        }
      }
    }
  }
  void display2(float zoom) {
    for (int i=0; i<ink.size(); i++) {
      ink.get(i).display(zoom,this);
    }
  }
}

Map canvas;

float weight=0.3;
float weight2=0.3;
int range=8;
int range2=6;
float curve=0.8;
float curve2=0.9;

void setup() {
  size(800, 800);
  canvas=new Map(800, 800, 1);

  for (int i=0; i<15000; i++) {
    canvas.addInk(new Particle(new Vector(300+random(-10, 10),random(380, 420))));
  }
  for (int i=0; i<15000; i++) {
    canvas.addInk(new Particle2(new Vector(500+random(-10, 10),random(380, 420))));
  }
  for (int i=0; i<1000; i++) {
    canvas.addInk(new Particle2(new Vector(300+random(-40, 40),random(380, 420))));
    canvas.addInk(new Particle(new Vector(500+random(-40, 40),random(380, 420))));
  }
  //canvas.display(1);
  //background(100,50,50);
}
void draw() {
  canvas.run();
  canvas.display(1);
  //canvas.display2(4);
  //rem=max(0,rem-0.0002);
}
