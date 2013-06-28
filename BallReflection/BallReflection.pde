Wall[] aWall;
int MAX_WALL = 1;
int currentWallIndex = 0;

Ball[] aBall;
int MAX_BALL = 100;
int MAX_BALL_AGE = 250;
float MAX_BALL_SIZE = 50;




PVector reflection(PVector p1, PVector pi, PVector norm) {
  float rx, ry;
  float lenOrg = p1.mag();
  float dot = (pi.x-p1.x)*norm.x + (pi.y-p1.y)*norm.y;
  rx = (pi.x-p1.x) - 2*norm.x*dot;
  ry = (pi.y-p1.y) - 2*norm.y*dot;
  PVector PNew = new PVector(rx, ry, 0);
  float lenNew = PNew.mag();
  PNew.mult(lenOrg/lenNew);
  return PNew;
}

PVector intersection(PVector p1, PVector p2, PVector p3, PVector p4)
{
  if (max(p1.x, p2.x) < min(p3.x, p4.x)  ||
      min(p1.x, p2.x) > max(p3.x, p4.x)  ||
      max(p1.y, p2.y) < min(p3.y, p4.y)  ||
      min(p1.y, p2.y) > max(p3.y, p4.y)) {
    return null;
  }
  
  float d = (p1.x-p2.x)*(p3.y-p4.y) - (p1.y-p2.y)*(p3.x-p4.x);
  if ( abs(d) < 0.0000001) {
    return null;
  }
  float x = ((p3.x-p4.x)*(p1.x*p2.y-p1.y*p2.x)-(p1.x-p2.x)*(p3.x*p4.y-p3.y*p4.x))/d;
  float y = ((p3.y-p4.y)*(p1.x*p2.y-p1.y*p2.x)-(p1.y-p2.y)*(p3.x*p4.y-p3.y*p4.x))/d;
  // check if intersection is on line
  if (min(p1.x,p2.x) > x ||
      max(p1.x,p2.x) < x ||
      min(p3.x,p4.x) > x ||
      max(p3.x,p4.x) < x ||
      min(p1.y,p2.y) > y ||
      max(p1.y,p2.y) < y ||
      min(p3.y,p4.y) > y ||
      max(p3.y,p4.y) < y)  {
        return null;
  }
  return new PVector(x,y,0);
}


class Ball {
  PVector pos;
  PVector vel;
  int age;
  float size;
  float sizeVel;
  float sizeMax;
  color BallColor;
  
  
  Ball(float x, float y) {
    pos = new PVector(x, y, 0);
    vel = new PVector(random(-1,1), random(-1,1));
    age = int(random(20, MAX_BALL_AGE));
    size = 0;
    sizeMax = random(10,MAX_BALL_SIZE);
    sizeVel = sizeMax / (age/2);
    
    BallColor = color(0,0,0);
  }

  boolean update() {
    pos.add(vel);
    
    if (pos.x < size) {
      vel.x = -vel.x;
      pos.x = size;
    }
    if (pos.x > (width-size)) {
      vel.x = -vel.x;
      pos.x = width-size;
    }
    if (pos.y < size) {
      vel.y = -vel.y;
      pos.y = size;
    }
    if (pos.y > (height-size)) {
      vel.y = -vel.y;
      pos.y = height-size;
    }    
    
    size += sizeVel;
    if (size > sizeMax) {
       sizeVel = -sizeVel;
       size = sizeMax;
    }
    age--;
    return age > 0;
  }
  
  PVector collide(Wall wall) {
    PVector posNew = new PVector(pos.x + vel.x, pos.y + vel.y); 
    PVector collision = intersection(pos,posNew,wall.p1,wall.p2);
    return collision;
  }
  
  boolean reflect(Wall wall) {
    PVector posNew = new PVector(pos.x + vel.x, pos.y + vel.y); 
    PVector collision = intersection(pos, posNew, wall.p1, wall.p2);
    if (collision != null) {
      PVector norm = wall.getNorm();
      vel = reflection(vel, collision, norm);
      return true;
    }
    else {
      return false;
    }
  }  
  void draw() {
    fill(BallColor);
    stroke(255);
    strokeWeight(1);
//    noStroke();
    ellipse(pos.x, pos.y, size, size);
  }
  
}


class Wall { 
  PVector p1, p2;
  int weight; 
  color WallColor;
  
  Wall(float x1, float y1, float x2, float y2) {  
    p1 = new PVector(x1,y1,0);
    p2 = new PVector(x2,y2,0);
    weight = 0;
    WallColor = color(0, 200, 0);
  } 

  void setP2(float x2, float y2) {  
    p2 = new PVector(x2,y2,0);
  } 
  
  PVector getNorm() {
    PVector v = new PVector(p2.x-p1.x, p2.y-p1.y, 0);
//    v.normalize();
    PVector norm = new PVector(-v.y, v.x);
    return norm;
  }
  
  void setStrokeWeight(int w) {
    weight = w;
  }
  void draw()
  {
    stroke(WallColor);
    strokeWeight(weight); 
    line(p1.x, p1.y, p2.x, p2.y); 
  } 
} 





void setup()
{
  // default size
  size(600,600);
 
 
  aBall = new Ball[MAX_BALL];
  for (int i=0; i<MAX_BALL; i++) {
    aBall[i] = new Ball(i, i);
  }
  rect(40,50,100,200);
  
  aWall = new Wall[MAX_WALL];
  for (int i=0; i<MAX_WALL; i++) {
    aWall[i] = new Wall(0, 0, 0, 0);
  }

}

void  draw()
{
  background(0);
  
  // update balls
  for (int i=0; i<MAX_BALL; i++) {
    if (aBall[i].update() == false) {
      aBall[i] = new Ball(mouseX, mouseY);
//      colorMode(HSB);
      int r = (int)map(mouseX, 0, width, 0, 255);
      int g = (int)map(mouseY, 0, height, 0, 255);
      int b = (int)random(0,255);
      aBall[i].BallColor = color( r,g,b, random(0,255) );
    }
    for (int w=0; w<MAX_WALL; w++) {
      aBall[i].reflect(aWall[w]);
//      PVector collision = aBall[i].collide(aWall[w]);
/*      
      if (collision != null) {
        ellipse(collision.x, collision.y, 30, 30);
        reflection
        aBall[i].vel = reflection(aBall[i].vel, collision, 
        new PVector(-aBall[i].vel.y,-aBall[i].vel.x,0);
        */
      
    }
  }
  
  
/*
  PVector intersection = intersection(aWall[0].p1, aWall[0].p2, 
                                     aWall[1].p1, aWall[1].p2);
                                    
  if (intersection != null) {
     ellipse(intersection.x, intersection.y, 40, 40);
  }    
*/
  
  for (int i=0; i<MAX_WALL; i++) {
    aWall[i].draw();
  }
  
  for (int i=0; i<MAX_BALL; i++) {
    aBall[i].draw();
  }
  
}


void mousePressed()
{
  currentWallIndex++;
  if (currentWallIndex >= MAX_WALL) {
    currentWallIndex = 0;
  }
  
  // rubber band
  aWall[currentWallIndex] = new Wall(mouseX, mouseY, mouseX, mouseY);
  
}

void mouseReleased()
{
  aWall[currentWallIndex].setStrokeWeight(4);
}

void mouseDragged()
{
  if (mousePressed) {
    aWall[currentWallIndex].setP2(mouseX, mouseY);
  }

}