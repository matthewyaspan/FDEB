float K = 0.1;
float CHARGE = 0.1;
int numSegments = 100;


Graph<Node, Spring> parseFile(String file) {
  Graph<Node, Spring> graph = new Graph<Node, Spring>();
  String[] lines = loadStrings(file);


  int numEntries = lines.length;
  String str;
  String[] authors;

  for (int i = 0; i < numEntries; i++) {
    if (lines[i].indexOf("@") == 1 && lines[i].length() > 2) {
      str = lines[i].substring(2, lines[i].length() - 1);
      authors = str.split(",");
      for (int j = 0; j < authors.length; j++) {
        Node n = new Node();
//        n.mass = 1.0;
        n.name = authors[j];
        graph.addNode(n, authors[j]);

        for (int k = j + 1; k < authors.length; k++) {
          if (j < authors.length - 1) {
            Spring sp = new Spring();
            sp.numSegments = numSegments;
            sp.k = K;
            sp.c = CHARGE;
            graph.undirectedEdge(authors[j], authors[k], sp);
          }
        }
      }
    }
  }
  return graph;
}

class CountEdges implements EdgeMapFun<Node, Spring> {
  int acc = 0;
  void op(Node n, Spring e) {
    acc += 1;
  }
}

class PositionNodes implements NodeMapFun<Node> {

//  int numNodes;
  int numEndpoints;
  int iterator;
  Graph<Node, Spring> g;

  void op(Node n) {

/*    float r = 0.45;
    float cx = 0.5;
    float cy = 0.5;*/
    
    CountEdges nEdges = new CountEdges();
    g.mapEdges(n.name, nEdges);
    int nodeSize = nEdges.acc;
    
    n.startAngle = iterator * TWO_PI / numEndpoints;
    n.angleSize = nodeSize * TWO_PI / numEndpoints;
/*
    n.x = cx + r*cos(iterator * TWO_PI / numNodes);
    n.y = cy + r*sin(iterator * TWO_PI / numNodes);*/

    iterator += nodeSize;
  }

  PositionNodes(Graph<Node, Spring> _g) {
    g = _g;
//    numNodes = _g.numNodes();
    numEndpoints = 2 * _g.numEdges();
    iterator = 0;
  }
}

class SetAnchors implements EdgeMapFun<Node, Spring> {
  int used;
  float start;
  float r, cx, cy;
  float sliceSize;
  boolean outgoing;
  void op(Node n, Spring e) {
    Point p = new Point();
    p.vx = 0;
    p.vy = 0;
    p.charge = 0;
    
    p.x = cx + (r * cos(start + (used * sliceSize)));
    p.y = cy + (r * sin(start + (used * sliceSize)));
    
    if (outgoing) {
      e.startAnchor = p;
    } else {
      e.endAnchor = p;
    }
    used++;
  }
  SetAnchors(boolean _outgoing, float _start, int _used, float _sliceSize, float _r, float _cx, float _cy) {
    outgoing = _outgoing;
    start = _start;
    used = _used;
    sliceSize = _sliceSize;
    r = _r;
    cx = _cx;
    cy = _cy;
  }
}

class SetMidPoints implements EdgeMapFun<Node, Spring> {
  void op(Node n, Spring e) {
    for (int i = 0; i < e.numSegments; ++i) {
      Point p = new Point();
      
      p.vx = 0;
      p.vy = 0;
      p.charge = CHARGE;
      
      p.x = lerp(e.startAnchor.x, e.endAnchor.x, (float)i / (float)(e.numSegments - 1));
      p.y = lerp(e.startAnchor.y, e.endAnchor.y, (float)i / (float)(e.numSegments - 1));
      
      e.points.add(p);
    }
  }
}

class InitializeEdges implements NodeMapFun<Node> {
  Graph<Node, Spring> g;
  void op(Node n) {
//    g.mapEdges(n.name, new InitializeEdgesFromNode(n));
    int numEndpoints = 2 * g.numEdges();
    float sliceSize = TWO_PI / (float) numEndpoints;
    SetAnchors outgoingAnchors = new SetAnchors(true, n.startAngle, 0, sliceSize, .45, .5, .5);
    g.mapOutgoingEdges(n.name, outgoingAnchors);
    g.mapIncomingEdges(n.name, new SetAnchors(false, n.startAngle, outgoingAnchors.used, sliceSize, .45, .5, .5));
    //g.mapOutgoingEdges(n.name, new SetMidPoints());
  }

  InitializeEdges(Graph<Node, Spring> _g) {
    g = _g;
  }
}

class InitializeEdgeMidpoints implements NodeMapFun<Node> {
  Graph<Node, Spring> g;
  void op(Node n) {
    g.mapOutgoingEdges(n.name, new SetMidPoints());
  }
  InitializeEdgeMidpoints(Graph<Node, Spring> _g) {
    g = _g;
  }
}

/*

class InitializeEdgesFromNode implements EdgeMapFun<Node, Spring> {
  Node node;


  void op(Node n, Spring s) {
    float srcX = n.x;
    float srcY = n.y;
    float trgtX = node.x;
    float trgtY = node.y;


    if (node == null || n == null) println("node is null");
    if (s == null) println("s is null");


    if (s.points.size() == 0 && n.name != node.name) {

      for (int i = 0; i < s.numSegments; i++) {
        Point newPoint = new Point();
        newPoint.x = lerp(srcX, trgtX, (i + 1)/( s.numSegments + 1));
        newPoint.y = lerp(srcY, trgtY, i / 100);

        s.points.add(newPoint);
      }
    }
  }

  InitializeEdgesFromNode(Node n) {
    node = n;
  }
}
*/

fdeb fdeb;

void setup() {
  background(255);
  surface.setSize(800, 600);
  Graph<Node, Spring> g = parseFile("smallinput.txt");
  g.mapNodes(new PositionNodes(g));
  g.mapNodes(new InitializeEdges(g));
  g.mapNodes(new InitializeEdgeMidpoints(g));
  fdeb = new fdeb(g);
  fdeb.render(0, 0, 800, 600);
}

void draw() {
  fdeb.render(0, 0, width, height);
}