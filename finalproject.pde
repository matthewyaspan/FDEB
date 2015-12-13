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
  int numEndpoints;
  int iterator;
  Graph<Node, Spring> g;

  void op(Node n) {
    
    CountEdges nEdges = new CountEdges();
    g.mapEdges(n.name, nEdges);
    int nodeSize = nEdges.acc;
    
    n.startAngle = iterator * TWO_PI / numEndpoints;
    n.angleSize = nodeSize * TWO_PI / numEndpoints;

    iterator += nodeSize;
  }

  PositionNodes(Graph<Node, Spring> _g) {
    g = _g;
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
    int numEndpoints = 2 * g.numEdges();
    float sliceSize = TWO_PI / (float) numEndpoints;
    SetAnchors outgoingAnchors = new SetAnchors(true, n.startAngle, 0, sliceSize, .4, .5, .5);
    g.mapOutgoingEdges(n.name, outgoingAnchors);
    g.mapIncomingEdges(n.name, new SetAnchors(false, n.startAngle, outgoingAnchors.used, sliceSize, .4, .5, .5));
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