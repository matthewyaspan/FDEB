float K = 0.1;
float CHARGE = 0.1;
int numSegments = 100;


Graph<Node, Spring> parseFile(String file) {
  Graph<Node, Spring> graph = new Graph<Node, Spring>();
  String[] lines = loadStrings(file);
  HashMap<String, Node> nodes = new HashMap<String, Node>();
  HashMap<Integer, ArrayList<Integer>> papers = new HashMap<Integer, ArrayList<Integer>>();
  HashMap<Integer, String> paperToAuthor = new HashMap<Integer, String>();
    
    
  int numEntries = lines.length;
  String str;
  String[] authors;
  Node n new Node();
  Integer paperIndex  = 0;;
  String author = "";


  for (int i = 0; i < numEntries; i++) {

    
    if (lines[i].indexOf("@") == 1 && lines[i].length() > 2) {
      str = lines[i].substring(2, lines[i].length() - 1);
      authors = str.split(",");
      author = authors[0];
      if (nodes.containsKey(author)) n = nodes.get(author);
      else n = new Node();
      n.name = author;
      
    }
    if (lines[i].indexOf("index") == 1 && lines[i].length() > 6) {
      str = lines[i].substring(6, lines[i].length() - 1);
      paperIndex = Integer.parseInt(str);
      n.papers.add(paperIndex);      
      paperToAuthor.put(paperIndex, author);
      
    }
    
    if (lines[i].indexOf("%") == 1 && lines[i].length() > 2) {
      str = lines[i].substring(2, lines[i].length() - 1);
      papers.get(paperIndex).add(Integer.parseInt(str));
      
    }
      
    }
    
    Iterator<String> iter = nodes.keySet().iterator();
    while(iter.hasNext()) {
      String nodeKey = iter.next();
      Node toInsert = nodes.get(nodeKey);
      graph.addNode(toInsert, toInsert.name);
      
      for (int i = 0; i < toInsert.papers.size(); i++) {
        Integer paperid = toInsert.papers.get(i);
        ArrayList<Integer> citedBy = papers.get(paperid);
        for (int j = 0; j < citedBy.size(); j++) {
          if (paperToAuthor.containsKey(citedBy.get(j))) {
            Spring sp = new Spring();
            sp.numSegments = numSegments;
            graph.directedEdge(toInsert.name, paperToAuthor.get(citedBy.get(j)), sp);
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

  
  void op(Node n, Spring s){
    float srcX = n.x;
    float srcY = n.y;
    float trgtX = node.x;
    float trgtY = node.y;
    
    
    if (node == null || n == null) println("node is null");
    if (s == null) println("s is null");
    
    
    if (s.points.size() == 0 && n.name != node.name){
    
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

void setup(){
  background(255);
  size(800, 600);
  Graph<Node, Spring> g = parseFile("smallinput.txt");
  g.mapNodes(new PositionNodes(g));
  g.mapNodes(new InitializeEdges(g));
  FDEB fdeb = new FDEB(g);
  fdeb.render(0, 0, 800, 600);
  
}

void draw() {
  
}
  