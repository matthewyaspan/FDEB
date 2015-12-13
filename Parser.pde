HashMap<Integer, String> indexToPaper;

ArrayList<ArrayList<String>> ArraySplit(String[] input, String[] delimiters) {
  println("input len: " + input.length);
  ArrayList<ArrayList<String>> split = new ArrayList<ArrayList<String>>();
  if (input.length == 0) return null;
  split.add(new ArrayList<String>());
  for (int i = 0; i < input.length; ++i) {
    boolean match = false;
    for (int j = 0; j < delimiters.length; ++j) {
      if (input[i].replace("\n", "").replace("\r", "").replace(" ", "").equals(delimiters[j])) {
        match = true;
      }
    }
    if (match) {
      if (i + 1 < input.length && split.get(split.size() - 1).size() > 0) {
        split.add(new ArrayList<String>());
      }
    } else {
      split.get(split.size() - 1).add(input[i]);
    }
  }
  return split;
}

class DataBlock {
  String title = "";
  String[] authors = null;
  int index = -1;
  ArrayList<Integer> sources = new ArrayList<Integer>();
}

DataBlock tryParseBlock(ArrayList<String> blockStrings) {
  DataBlock block = new DataBlock();
  for (int i = 0; i < blockStrings.size(); ++i) {
    if (blockStrings.get(i).length() > 2 && blockStrings.get(i).charAt(1) == '*') {
      block.title = blockStrings.get(i).substring(2, blockStrings.get(i).length());
    }
    if (blockStrings.get(i).length() > 2 && blockStrings.get(i).charAt(1) == '@') {
      String str = blockStrings.get(i).substring(2, blockStrings.get(i).length());
      block.authors = str.split(",");
    }
    if (blockStrings.get(i).indexOf("index") == 1 && blockStrings.get(i).length() > 6) {
      String str = blockStrings.get(i).substring(6, blockStrings.get(i).length());
      block.index = Integer.parseInt(str);
    }

    if (blockStrings.get(i).length() > 2 && blockStrings.get(i).charAt(1) == '%') {
      String str = blockStrings.get(i).substring(2, blockStrings.get(i).length());
      try {
        block.sources.add(Integer.parseInt(str));
      } catch (Exception e) {
        continue;
      }
    }
  }
  if (/*block.title == "" || */block.authors == null || block.index == -1) {
    return null;
  } else {
    return block;
  }
}

Graph<Node, Spring> parseFile(String file) {
  Graph<Node, Spring> graph = new Graph<Node, Spring>();
  String[] lines = loadStrings(file);
  String[] delimiters = {"", " "};
  ArrayList<ArrayList<String>> blocks = ArraySplit(lines, delimiters);
  
  HashMap<String, Node> nodes = new HashMap<String, Node>();
  HashMap<Integer, ArrayList<Integer>> papers = new HashMap<Integer, ArrayList<Integer>>();
  HashMap<Integer, String> paperToAuthor = new HashMap<Integer, String>();
  indexToPaper = new HashMap<Integer, String>();
  
  int idNum = 0;

  ArrayList<DataBlock> blocksData = new ArrayList<DataBlock>();
  for (int i = 0; i < blocks.size(); ++i) {
    DataBlock block = tryParseBlock(blocks.get(i));
    if (block != null) {
      blocksData.add(block);
    }
  }
  for (int i = 0; i < blocksData.size(); ++i) {
    DataBlock block = blocksData.get(i);
    Node n;
    if (nodes.containsKey(block.authors[0])) {
      n = nodes.get(block.authors[0]);
    } else {
      n = new Node();
      n.name = block.authors[0];
      nodes.put(block.authors[0], n);
      n.id = idNum;
      idNum++;
    }
    n.papers.add(block.index);
    indexToPaper.put(block.index, block.title);
    paperToAuthor.put(block.index, block.authors[0]);
    papers.put(block.index, new ArrayList<Integer>());
  }
  for (int i = 0; i < blocksData.size(); ++i) {
    DataBlock block = blocksData.get(i);
    for (int j = 0; j < block.sources.size(); ++j) {
      papers.get(block.index).add(block.sources.get(j));
    }
  }
/*
  int numEntries = lines.length;
  String str;
  String[] authors;
  Node n = null;
  Integer paperIndex = 0;
  String author = "";
  String title = "";
  int idNum = 0;

  for (int i = 0; i < numEntries; i++) {
    if (lines[i].length() > 2 && lines[i].charAt(1) == '*') {
      str = lines[i].substring(2, lines[i].length());
      title = str;
    }
    if (lines[i].length() > 2 && lines[i].charAt(1) == '@') {
      str = lines[i].substring(2, lines[i].length());
      authors = str.split(",");
      author = authors[0];
      if (nodes.containsKey(author)) n = nodes.get(author);
      else {
        n = new Node();
        n.name = author;
        n.id = idNum;
        idNum++;
        nodes.put(author, n);
      }
    }
    if (lines[i].indexOf("index") == 1 && lines[i].length() > 6) {
      str = lines[i].substring(6, lines[i].length());
      paperIndex = Integer.parseInt(str);
      n.papers.add(paperIndex);  
      papers.put(paperIndex, new ArrayList<Integer>());
      paperToAuthor.put(paperIndex, author);
      indexToPaper.put(paperIndex, title);
    }

    if (lines[i].length() > 2 && lines[i].charAt(1) == '%') {
      str = lines[i].substring(2, lines[i].length());
      try {
        papers.get(paperIndex).add(Integer.parseInt(str));
      } catch (Exception e) {
        continue;
      }
    }
  }*/

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
          if (!nodes.containsKey(paperToAuthor.get(citations.get(j)))) {
            continue;
          }
          Spring sp = new Spring();
          sp.numSegments = numSegments;
          sp.paperId = paperid;
          sp.sourceId = citations.get(j);
          sp.sourceAuthorId = nodes.get(paperToAuthor.get(citations.get(j))).id;
          sp.paperAuthorId = toInsert.id;
          
          graph.directedEdge(toInsert.name, paperToAuthor.get(citations.get(j)), sp);
        }
      }
    }
  }


  return graph;
}