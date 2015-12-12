class Point {
  
  float x, y;
  float vx, vy;
  float charge;
}

class Node extends Point {
  String name;
  float mass;
}

class Spring {
  int numSegments;
  ArrayList<Point> points = new ArrayList();
  float k;
  float c;
  

}
