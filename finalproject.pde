float K = 15;
float G = .000002;
float CHARGE = 0.1;
int numSegments = 100;

class CountEdges implements EdgeMapFun<Node, Spring> {
  int acc = 0;
  void op(Node n, Spring e) {
    acc += 1;
  }
}

class PositionNodes implements NodeMapFun<Node> {
  int numPapers;
  int numEndPoints;
  int iterator;
  Graph<Node, Spring> g;

  void op(Node n) {
    
    CountEdges nEdges = new CountEdges();
    g.mapEdges(n.name, nEdges);
    int nodeSize = nEdges.acc;
    //int nodeSize = n.papers.size();
    
    
    n.startAngle = iterator * TWO_PI / numEndPoints;//numPapers;//numEndpoints;
    n.angleSize = nodeSize * TWO_PI / numEndPoints;//numPapers;//numEndpoints;

    println("start angle: " + n.startAngle + " end angle: " + (n.startAngle + n.angleSize));
    iterator += nodeSize;
  }

  PositionNodes(Graph<Node, Spring> _g) {
    g = _g;
    numEndPoints = 2 * _g.numEdges();
    //numPapers = indexToPaper.keySet().size();
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
    
    p.x = cx + (r * cos(start + ((used + .5) * sliceSize)));
    p.y = cy + (r * sin(start + ((used + .5) * sliceSize)));
    
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
  
  
  /*
  float sliceSize;
  boolean outgoing;
  float r, cx, cy;
  float start;
  Node node;
  void op(Node n, Spring e) {
    Point p = new Point();
    p.vx = 0;
    p.vy = 0;
    p.charge = 0;
    
    int index = outgoing ? node.papers.indexOf(e.paperId) : node.papers.indexOf(e.sourceId);
    float angle = node.startAngle + ((index + .5) * sliceSize);
    
    if (e.paperId == 5) {
      println("paper 5:");
      println("author: " + node.name);
      println("name: " + indexToPaper.get(e.paperId));
    }
    if (e.sourceId == 5) {
      println("paper 5 cited:");
      println("author: " + n.name);
      println("citation in paper: " + e.paperId);
      println("name: " + indexToPaper.get(e.paperId));
    }
    
    p.x = cx + (r * cos(angle));
    p.y = cy + (r * sin(angle));
    
    if (outgoing) {
      e.startAnchor = p;
    } else {
      e.endAnchor = p;
    }
  }
  SetAnchors(boolean _outgoing, Node _node, float _sliceSize, float _r, float _cx, float _cy) {
    node = _node;
    sliceSize = _sliceSize;
    outgoing = _outgoing;
    r = _r;
    cx = _cx;
    cy = _cy;
  }*/
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
    //int numEndpoints = 2 * g.numEdges();
    int numPapers = indexToPaper.keySet().size();
    float sliceSize = TWO_PI / (float) numPapers;
    SetAnchors outgoingAnchors = new SetAnchors(true, n.startAngle, 0, sliceSize, .4, .5, .5);
    //SetAnchors outgoingAnchors = new SetAnchors(true, n, sliceSize, .4, .5, .5);
    g.mapOutgoingEdges(n.name, outgoingAnchors);
    g.mapIncomingEdges(n.name, new SetAnchors(false, n.startAngle, outgoingAnchors.used, sliceSize, .4, .5, .5));
    //g.mapIncomingEdges(n.name, new SetAnchors(false, n, sliceSize, .4, .5, .5));
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
  background(255);
  fdeb.render(0, 0, width, height);
}