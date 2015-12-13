class Point {
  
  float x, y;
  float vx, vy;
  float charge;
}

class Node {
  boolean hover = false;
  int id;
  String name;
  ArrayList<Integer> papers = new ArrayList<Integer>();
  float startAngle;
  float angleSize;
}

class Spring {
  int numSegments;
  ArrayList<Point> points = new ArrayList();
  int sourceId;
  int paperId;
  int sourceAuthorId;
  int paperAuthorId;
  Point startAnchor;
  Point endAnchor;
  float k;
  float c;
}