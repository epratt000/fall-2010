// -*- C++ -*-
/**
 * @file Employee.h
 * @brief Definition of a Employee class. 
 * @author Shumin Guo (guo.18@wright.edu)
 * @version 1.0.0
 */
// $Log$

#include "Graph.h"

// Load graph structure data from file.
bool Graph::loadFileToAdjList(string fname) {
  int num; 			// number of vertices.
  int w; 			// weight between vertices. 
  ifstream fdata(fname.c_str()); 
  if(!fdata) {
    cerr << "Error opening data file " << fname << endl;
    return false;
  }
  fdata >> num; cout << "Number is:" << num << endl; 
  Vertex *pvt = NULL;		// Vertex pointer. 
  for(int i = 0; i < num; i++) { 
    pvt = new (nothrow) Vertex(i);
    v.push_back(pvt);
    for(int j = 0; j < num; j++) {
      fdata >> w;
      if(w>0) {
	cout << w;
	Vertex *pnvt = new (nothrow) Vertex(j); 
	if(!pnvt) {
	  cerr << "Error while creating vertex object." << endl; 
	  return false;
	}
	pnvt->setWeight(w);
	pvt->setNext(pnvt); 
	pvt = pnvt;
      }	// if weight > 0.
    } // for line. 
    cout << endl;
  } // while fdata. 
  fdata.close();
  return true;
}

// Depth first traversal. 
bool Graph::DFSTraversal(int id) {
  cout << "Depth first traversal..." << endl;
  visit(id);
  Vertex *pv = v[id];
  pv = pv->next();
  while(pv != NULL) {
    cout << pv->getWeight(); 
    if(pv->next() != NULL) {cout << ",";}
    pv = pv->next();
  }
  cout << endl; 
  return true; 
}

// Breadth first traversal. 
bool Graph::BFSTraversal(int id) {
  cout << "Breadth first traversal..." << endl;
  return true; 
}

// Dijkstra's shortest path algorithm.
bool Graph::DijSP(int id) {
  cout << "Dijkstra's Algorithm..." << endl; 
  return true; 
}

bool Graph::printAdjList() {
  cout << "Printing adjacency list..." << endl; 
  for(int i = 0; i < getNumVertices(); i++) {
    Vertex *pv = v[i];
    //cout << pv << endl; 
    cout << pv->getId() << "->"; 
    pv = pv->next();
    while(pv != NULL) {
      cout << pv->getWeight(); 
      if(pv->next() != NULL) {cout << ",";}
      pv = pv->next();
    }
    cout << endl; 
  }
  return true; 
}

// Visit a vertex within the graph given by Id. 
bool Graph::visit(int id) {
  if((id > getNumVertices()) || (id < 0)) {
    cerr << "Wrong id, please check again." << endl; 
    return false;
  }
  Vertex *pv = v[id];
  pv->visit(); 
  return true; 
}
