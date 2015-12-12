class fdeb {
  Graph<Node, Spring> _graph;
  float timestep;
  
  fdeb(Graph<Node, Spring> graph) {
    _graph = graph;
    // 24 fps
    timestep = .041666666 / 50;
    //timestep = .001;
  }
  
  void renderNodes(float xPad, float yPad, float wScale, float hScale) {
    _graph.mapNodes(new DrawNode(xPad, yPad, wScale, hScale));
  }
  
  void renderEdges(float xPad, float yPad, float wScale, float hScale) {
    _graph.mapNodes(new DrawEdges(_graph, xPad, yPad, wScale, hScale));
  }
  
  void render(float xPad, float yPad, float wScale, float hScale) {
    /*for (int i = 0; i < 50; ++i) {
    } */
    
    renderNodes(xPad, yPad, wScale, hScale);
    renderEdges(xPad, yPad, wScale, hScale);
  }
}

class DrawNode implements NodeMapFun<Node> {
  float xPad, yPad, wScale, hScale;
  
  void op(Node n) {
    colorMode(RGB, 255);
    fill(0, 0, 255);
    strokeWeight(2);
    float cx = xPad + .5 * wScale;
    float cy = yPad + .5 * hScale;
    float r = min(wScale, hScale) * .45;
    float ir = min(wScale, hScale) * .4;
    arc(cx, cy, 2 * r, 2 * r, n.startAngle, n.startAngle + n.angleSize, PIE);
    fill(255);
    ellipse(cx, cy, ir * 2, ir * 2);
  }
  
  DrawNode(float _xPad, float _yPad, float _wScale, float _hScale) {
    xPad = _xPad;
    yPad = _yPad;
    wScale = _wScale;
    hScale = _hScale;
  }
}

class DrawEdge implements EdgeMapFun<Node, Spring> {
  float xPad, yPad, wScale, hScale;
  Node start;
  
  float toRealX(float x) {
    float cx = xPad + wScale / 2;
    float s = min(wScale, hScale);
    return (x * s) + (cx - (s * .5));
    //return xPad + x * wScale;
  }
  float toRealY(float y) {
    float cy = yPad + hScale / 2;
    float s = min(wScale, hScale);
    return (y * s) + (cy - (s * .5));
    //return yPad + y * hScale;
  }
  
  void op(Node n, Spring s) {
    strokeWeight(3);
    stroke(255, 0, 0);
    
    line(toRealX(s.startAnchor.x), toRealY(s.startAnchor.y),
         toRealX(s.points.get(0).x), toRealY(s.points.get(0).y));
    for (int i = 0; i < s.points.size() - 1; i++) {
      line(toRealX(s.points.get(i).x), toRealY(s.points.get(i).y),
           toRealX(s.points.get(i + 1).x), toRealY(s.points.get(i + 1).y));
    }
    line(toRealX(s.points.get(s.points.size() - 1).x), toRealY(s.points.get(s.points.size() - 1).y),
         toRealX(s.endAnchor.x), toRealY(s.endAnchor.y));
  }
  DrawEdge(Node s, float _xPad, float _yPad, float _wScale, float _hScale) {
    start = s;
    xPad = _xPad;
    yPad = _yPad;
    wScale = _wScale;
    hScale = _hScale;
  }
}

class DrawEdges implements NodeMapFun<Node> {
  float xPad, yPad, wScale, hScale;
  Graph<Node, Spring> graph;
  void op(Node n) {
    graph.mapOutgoingEdges(n.name, new DrawEdge(n, xPad, yPad, wScale, hScale));
  }
  DrawEdges(Graph<Node, Spring> g, float _xPad, float _yPad, float _wScale, float _hScale) {
    graph = g;
    xPad = _xPad;
    yPad = _yPad;
    wScale = _wScale;
    hScale = _hScale;
  }
}

/*class AccumulateSpringForce implements EdgeMapFun<Node, Spring> {
  float fx, fy;
  Node node;
  void op(Node n, Spring s) {
    if (n.id == node.id) return;
    float force;
    int end = s.points.size() - 1;
    s.points
    for (int i = 0; i < end; i++) {
      
    }
    float dist = sqrt(pow((node.x - n.x), 2) + pow((node.y - n.y), 2));
    force = -s.k * (dist - (s.len / width));
    float dx = node.x - n.x;
    float dy = node.y - n.y;
    float factor = sqrt(pow(dx, 2) + pow(dy, 2));
    dx = dx / factor;
    dy = dy / factor;
    float angle = dy > 0 ? acos(dx) : TWO_PI - acos(dx);
    fx += force * cos(angle);
    fy += force * sin(angle);
  }
  AccumulateSpringForce(Node n) {
    fx = 0;
    fy = 0;
    node = n;
  }

}*/