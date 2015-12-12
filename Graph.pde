import java.util.Iterator;

public interface NodeMapFun<NodeType> {
  public void op(NodeType n);
}


public interface EdgeMapFun<NodeType, EdgeData> {
  public void op(NodeType n, EdgeData e);
}



class Edge<EdgeData> {
  String n1, n2;
  boolean directed;
  EdgeData data;
  Edge(String _n1, String _n2, boolean _directed, EdgeData _data) {
    n1 = _n1;
    n2 = _n2;
    directed = _directed;
    data = _data;
  }
}

class Graph<NodeType, EdgeData> {
  private HashMap<String, NodeType> _nodes;
  private ArrayList<Edge<EdgeData>> _edges;

  Graph() {
    _nodes = new HashMap<String, NodeType>();
    _edges = new ArrayList<Edge<EdgeData>>();
  }
  void addNode(NodeType node, String id) {
    if (!_nodes.containsKey(id)) _nodes.put(id, node);
    //else _nodes.get(id).mass += 1.0;
     
  }
  
  int numNodes () {
    return _nodes.size();
  }

  void undirectedEdge(String id1, String id2, EdgeData data) {
    _edges.add(new Edge<EdgeData>(id1, id2, false, data));
  }
  void directedEdge(String id1, String id2, EdgeData data) {
    _edges.add(new Edge<EdgeData>(id1, id2, true, data));
  }
  void mapNodes(NodeMapFun fun) {
    Iterator<NodeType> i = _nodes.values().iterator();
    while (i.hasNext()) {
      fun.op(i.next());
    }
  }
  void mapEdges(String id, EdgeMapFun fun) {
    for (int i = 0; i < _edges.size(); ++i) {
      if (_edges.get(i).n1 == id || _edges.get(i).n2 == id) {
        fun.op(_edges.get(i).n1 == id ? _nodes.get(_edges.get(i).n2) :
                                        _nodes.get(_edges.get(i).n1),
               _edges.get(i).data);
      }
    }
  }
  void mapOutgoingEdges(String id, EdgeMapFun fun) {
    for (int i = 0; i < _edges.size(); ++i) {
      if (_edges.get(i).n1 == id) {
        fun.op(_nodes.get(_edges.get(i).n2), _edges.get(i).data);
      }
    }
  }
  void mapIncomingEdges(String id, EdgeMapFun fun) {
    for (int i = 0; i < _edges.size(); ++i) {
      if (_edges.get(i).n2 == id) {
        fun.op(_nodes.get(_edges.get(i).n1), _edges.get(i).data);
      }
    }
  }
}