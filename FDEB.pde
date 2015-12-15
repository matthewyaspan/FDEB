color nthColor(int n) {
  float h = ((n * .41421) % 1) * 360;
  float s = .9;
  float b = .9;
  colorMode(HSB, 360, 1, 1);
  return color(h, s, b);
}
color nthHoverColor(int n) {
  float h = ((n * .41421) % 1) * 360;
  float s = .7;
  float b = .6;
  colorMode(HSB, 360, 1, 1);
  return color(h, s, b);
}

class fdeb {
  Graph<Node, Spring> _graph;
  float timestep;
  int arrowstep;

  fdeb(Graph<Node, Spring> graph) {
    _graph = graph;
    // 24 fps
    timestep = .041666666;
    // animated arrows;
    arrowstep = 0;
  }

  void renderNodes(float xPad, float yPad, float wScale, float hScale) {
    _graph.mapNodes(new DrawNode(xPad, yPad, wScale, hScale));
  }

  void renderEdges(float xPad, float yPad, float wScale, float hScale) {
    _graph.mapNodes(new DrawEdges(_graph, xPad, yPad, wScale, hScale, arrowstep));
  }

  void updateEdges(float dt) {
    // inter-edge forces
    _graph.mapNodes(new ApplyEdgeForces(_graph));
    // intra-edge forces
    for (int i = 1; i < numSegments - 1; ++i) {
      for (int j = 0; j < _graph._edges.size(); ++j) {
        for (int k = 0; k < _graph._edges.size(); ++k) {
          if (j == k) continue;
          Point p1 = _graph._edges.get(j).data.points.get(i);
          Point p2 = _graph._edges.get(k).data.points.get(i);
          float dist = sqrt(pow(p1.x - p2.x, 2) + pow(p1.y - p2.y, 2));
          float force = -G / pow(dist, 2);
          if (dist < .01) {
            force = 0;
          }
          
          float dx = p1.x - p2.x;
          float dy = p1.y - p2.y;
          float factor = sqrt(pow(dx, 2) + pow(dy, 2));
          dx = dx / factor;
          dy = dy / factor;
          float angle = dy > 0 ? acos(dx) : TWO_PI - acos(dx);
          p1.vx += force * cos(angle);
          p1.vy += force * sin(angle);
        }
      }
    }
    // velocity
    _graph.mapNodes(new MoveEdgeSegments(_graph, dt));
  }

  void render(float xPad, float yPad, float wScale, float hScale) {
    updateEdges(timestep);
    renderNodes(xPad, yPad, wScale, hScale);
    renderEdges(xPad, yPad, wScale, hScale);
    arrowstep += 1;
    arrowstep %= 10;
  }
}

class MoveEdgeSegments implements NodeMapFun<Node> {
  Graph<Node, Spring> _g;
  float _dt;
  MoveEdgeSegments(Graph<Node, Spring> g, float dt) {
    _g = g;
    _dt = dt;
  }

  void op (Node n){
    _g.mapOutgoingEdges(n.name, new MoveSegments(_dt));
  }
}

class MoveSegments implements EdgeMapFun<Node, Spring> {
  float _dt;

  MoveSegments (float dt) {
    _dt = dt;
  }

  void op (Node n, Spring e) {
    int i;
    for (i = 1; i < e.points.size()-1; i++) {
      e.points.get(i).x += _dt * e.points.get(i).vx;
      e.points.get(i).y += _dt * e.points.get(i).vy;
      e.points.get(i).vx *= .9;
      e.points.get(i).vy *= .9;
    }
  }
}

class ApplyEdgeForces implements NodeMapFun<Node> {
  Graph<Node, Spring> _g;
  ApplyEdgeForces(Graph<Node, Spring> g) {
    _g = g;
  }

  void op (Node n) {
    _g.mapOutgoingEdges(n.name, new EdgeForces());
  }
}

class EdgeForces implements EdgeMapFun<Node, Spring> {
  void op (Node n, Spring e) {
    int i;

    applySpringForce(e.startAnchor, e.points.get(0));
    for (i = 0; i < e.points.size() - 1; i++) {
      applySpringForce(e.points.get(i), e.points.get(i+1));
    }
    applySpringForce(e.points.get(e.points.size()-1), e.endAnchor);
  }

  void applySpringForce(Point p1, Point p2) {
    float dist = sqrt(pow((p1.x - p2.x), 2) + pow((p1.y - p2.y), 2));
    float force = -K * dist;
    float dx = p1.x - p2.x;
    float dy = p1.y - p2.y;
    float factor = sqrt(pow(dx, 2) + pow(dy, 2));
    dx = dx / factor;
    dy = dy / factor;
    float angle = dy > 0 ? acos(dx) : TWO_PI - acos(dx);
    p1.vx += force * cos(angle);
    p1.vy += force * sin(angle);
    p2.vx -= force * cos(angle);
    p2.vy -= force * sin(angle);
  }
  
}



class DrawNode implements NodeMapFun<Node> {
  float xPad, yPad, wScale, hScale;

  void op(Node n) {
    int colorIndex = n.id;
    colorMode(RGB, 255);
    //fill(0, 0, 255);
    fill(nthColor(colorIndex));
    colorMode(RGB, 255);
    stroke(0);
    strokeWeight(0);
    float cx = xPad + .5 * wScale;
    float cy = yPad + .5 * hScale;
    float r = min(wScale, hScale) * .45;
    float ir = min(wScale, hScale) * .4;
    
    n.hover = false;
    float dx = mouseX - wScale/2;
    float dy = mouseY - hScale/2;
    float factor = sqrt((dx * dx) + (dy * dy));
    dx = dx / factor;
    dy = dy / factor;
    float mTheta = dy > 0 ? acos(dx) : TWO_PI - acos(dx);
    float mR = dist(cx, cy, mouseX, mouseY);
    if (mR >= ir && mR <= r) {
      if (mTheta >= n.startAngle && mTheta <= (n.startAngle + n.angleSize)) {
        n.hover = true;
        fill(255);
        stroke(0);
        //rect(25, 25, 150, 30);
        fill(0);
        text("Name: " + n.name, 30, 40);
        fill(nthHoverColor(colorIndex));
        colorMode(RGB, 255);
      }
    }
    
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
  int arrowstep;
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
  
    
  void drawArrow(float x1, float y1, float x2, float y2, float m) {
    line(x1, y1, x2, y2);
    pushMatrix();
    translate(x2, y2);
    float a = atan2(x1 - x2, y2 - y1);
    rotate(a);
    line(0, 0, -m, -m);
    line(0, 0, m, -m);
    popMatrix();
  }

  void op(Node n, Spring s) {
    strokeWeight(3);
    stroke(255, 0, 0);

    line(toRealX(s.startAnchor.x), toRealY(s.startAnchor.y), 
      toRealX(s.points.get(0).x), toRealY(s.points.get(0).y));
    for (int i = 0; i < s.points.size() - 1; i++) {
      //stroke(lerpColor(color(0, 255, 0), color(255, 0, 0), (float)i / (float)s.points.size()));
      stroke(lerpColor(nthColor(s.paperAuthorId), nthColor(s.sourceAuthorId), (float)i / (float)s.points.size()));
      colorMode(RGB, 255);
      if ((start.hover || n.hover) && i % 10 == arrowstep) {
        drawArrow(toRealX(s.points.get(i).x), toRealY(s.points.get(i).y), 
                  toRealX(s.points.get(i + 1).x), toRealY(s.points.get(i + 1).y), 6);
      } else {
        line(toRealX(s.points.get(i).x), toRealY(s.points.get(i).y), 
             toRealX(s.points.get(i + 1).x), toRealY(s.points.get(i + 1).y));
      }
    }
    line(toRealX(s.points.get(s.points.size() - 1).x), toRealY(s.points.get(s.points.size() - 1).y), 
      toRealX(s.endAnchor.x), toRealY(s.endAnchor.y));
      
  }
  DrawEdge(Node s, float _xPad, float _yPad, float _wScale, float _hScale, int _arrowstep) {
    arrowstep = _arrowstep;
    start = s;
    xPad = _xPad;
    yPad = _yPad;
    wScale = _wScale;
    hScale = _hScale;
  }
}

class DrawEdges implements NodeMapFun<Node> {
  float xPad, yPad, wScale, hScale;
  int arrowstep;
  Graph<Node, Spring> graph;
  void op(Node n) {
    graph.mapOutgoingEdges(n.name, new DrawEdge(n, xPad, yPad, wScale, hScale, arrowstep));
  }
  DrawEdges(Graph<Node, Spring> g, float _xPad, float _yPad, float _wScale, float _hScale, int _arrowstep) {
    arrowstep = _arrowstep;
    graph = g;
    xPad = _xPad;
    yPad = _yPad;
    wScale = _wScale;
    hScale = _hScale;
  }
}

/*
hover:
if mouse center is at point center within certain width, highlight entire edge
if mouse center is between two points line, highlight entire edge

*/