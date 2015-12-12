
Graph<Node, Spring> parseFile(String file) {
  Graph<Node, Spring> graph = new Graph<Node, Spring>();
  String[] lines = loadStrings(file);
  HashMap<String, Node> nodes = new HashMap<String, Node>();
  HashMap<Integer, ArrayList<Integer>> papers = new HashMap<Integer, ArrayList<Integer>>();
  HashMap<Integer, String> paperToAuthor = new HashMap<Integer, String>();


  int numEntries = lines.length;
  String str;
  String[] authors;
  Node n = null;
  Integer paperIndex = 0;
  String author = "";

  for (int i = 0; i < numEntries; i++) {
    if (lines[i].indexOf("@") == 1 && lines[i].length() > 2) {
      str = lines[i].substring(2, lines[i].length());
      authors = str.split(",");
      author = authors[0];
      if (nodes.containsKey(author)) n = nodes.get(author);
      else {
        n = new Node();
        n.name = author;
        nodes.put(author, n);
      }
    }
    if (lines[i].indexOf("index") == 1 && lines[i].length() > 6) {
      str = lines[i].substring(6, lines[i].length());
      paperIndex = Integer.parseInt(str);
      n.papers.add(paperIndex);  
      papers.put(paperIndex, new ArrayList<Integer>());
      paperToAuthor.put(paperIndex, author);
    }

    if (lines[i].indexOf("%") == 1 && lines[i].length() > 2) {
      str = lines[i].substring(2, lines[i].length());
      papers.get(paperIndex).add(Integer.parseInt(str));
    }
  }

  Iterator<String> iter = nodes.keySet().iterator();
  println(nodes.keySet().size());
  while (iter.hasNext()) {
    String nodeKey = iter.next();
    Node toInsert = nodes.get(nodeKey);
    graph.addNode(toInsert, toInsert.name);

    for (int i = 0; i < toInsert.papers.size(); i++) {
      Integer paperid = toInsert.papers.get(i);
      ArrayList<Integer> citations = papers.get(paperid);
      for (int j = 0; j < citations.size(); j++) {
        if (paperToAuthor.containsKey(citations.get(j))) {
          Spring sp = new Spring();
          sp.numSegments = numSegments;
          graph.directedEdge(toInsert.name, paperToAuthor.get(citations.get(j)), sp);
        }
      }
    }
  }


  return graph;
}