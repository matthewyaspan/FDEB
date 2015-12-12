class Point {
  
  float x, y;
  float vx, vy;
  float charge;
}

class Node {
  String name;
  ArrayList<Integer> papers = new ArrayList<Integer>();
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