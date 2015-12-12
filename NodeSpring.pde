class Point {
  
  float x, y;
  float vx, vy;
  float charge;
}

class Node {
  String name;
  float startAngle;
  float angleSize;
}

class Spring {
  int numSegments;
  ArrayList<Point> points = new ArrayList();
  Point startAnchor;
  Point endAnchor;
  float k;
  float c;
}