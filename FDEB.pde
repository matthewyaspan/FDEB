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
    renderEdges(xPad, yPad, wScale, hScale);
    renderNodes(xPad, yPad, wScale, hScale);
  }
}

class DrawEdge implements EdgeMapFun<Node, Spring> {
  float xPad, yPad, wScale, hScale;
  Node start;
  void op(Node n, Spring s) {
    strokeWeight(3);
    stroke(255, 0, 0);
    line(xPad + (start.x * wScale), yPad + (start.y * hScale),
         s.points.get(0).x * wScale, s.points.get(0).y * hScale);
    int end = s.points.size() - 1;
    for (int i = 0; i < end; i++) {
      line(xPad + (s.points.get(i).x * wScale), yPad + (s.points.get(i).y * hScale),
                   s.points.get(i+1).x * wScale, s.points.get(i+1).y * hScale);
    }
    
    line(xPad + s.points.get(end).x * wScale, yPad + s.points.get(end).y, n.x * wScale, n.y * hScale);
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
    graph.mapEdges(n.name, new DrawEdge(n, xPad, yPad, wScale, hScale));
  }
  DrawEdges(Graph<Node, Spring> g, float _xPad, float _yPad, float _wScale, float _hScale) {
    graph = g;
    xPad = _xPad;
    yPad = _yPad;
    wScale = _wScale;
    hScale = _hScale;
  }
}


class DrawNode implements NodeMapFun<Node> {
  float xPad, yPad, wScale, hScale;
  void op(Node n) {
    colorMode(RGB, 255);
    fill(0, 0, 255);
  //  fill(nthColor(n.id));
    float x = xPad + (n.x * wScale);
    float y = yPad + (n.y * hScale);
    float w = .05 * sqrt(n.mass) * wScale;
    float h = .05 * sqrt(n.mass) * hScale;
    //if (mouseOver(n)) {
    // fill(255, 100, 100);
  //    fill(nthHoverColor(n.id));
    //}
    strokeWeight(2);
    ellipse(x, y, w, h);
   // if (mouseOver(n)) {
      fill(0);
     // text("id: " + n.id + "\nmass: " + n.mass, x - (w / 4), y - (h / 4), .1 * wScale, .1 * hScale);
    //}
  }
  DrawNode(float _xPad, float _yPad, float _wScale, float _hScale) {
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