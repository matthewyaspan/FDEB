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
        n.mass = 1.0;
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

class PositionNodes implements NodeMapFun<Node> {

  int numNodes;
  int iterator;

  void op(Node n) {

    float r = 0.45;
    float cx = 0.5;
    float cy = 0.5;

    n.x = cx + r*cos(iterator * TWO_PI / numNodes);
    n.y = cy + r*sin(iterator * TWO_PI / numNodes);

    iterator++;
  }

  PositionNodes(Graph<Node, Spring> _g) {
    numNodes = _g.numNodes();
    iterator = 0;
  }
}


class InitializeEdges implements NodeMapFun<Node> {
  Graph<Node, Spring> g;
  void op(Node n) {

    g.mapEdges(n.name, new InitializeEdgesFromNode(n));
  }

  InitializeEdges(Graph<Node, Spring> _g) {
    g = _g;
  }
}

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

void setup() {
  background(255);
  surface.setSize(800, 600);
  Graph<Node, Spring> g = parseFile("smallinput.txt");
  g.mapNodes(new PositionNodes(g));
  g.mapNodes(new InitializeEdges(g));
  fdeb fdeb = new fdeb(g);
  fdeb.render(0, 0, 800, 600);
}

void draw() {
}