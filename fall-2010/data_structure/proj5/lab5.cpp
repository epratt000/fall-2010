// $Id$
/**
 * @file main.cpp 
 * @brief This is a test program for this project. 
 * @see README. 
 * @warning
 * @author Shumin Guo (guo.18@wright.edu)
 * @version 1.0.0
 */
// $Log$

#include <iostream>
#include <cstdlib>
#include <fstream>
#include "Graph.h"
using namespace std;

// ---------------------------------------------------------------------
// main() -- Test the function of insert, search, load data from file and
//           save data to file. 
// ---------------------------------------------------------------------
void renderUI(char& choice); 
bool execCmd(char choice, Graph *graph);

int main() {
  Graph *graph = new (nothrow) Graph();
  if(!graph) {
    cout << "Error While creating Graph object. " << endl;
    return 1; 
  }
  char choice;			// User command choice. 
  do {
    renderUI(choice);
  } while(execCmd(choice, graph));
  return 0;
}

// Prompt user to enter command 
// The command char will be returned through a reference char. 
void renderUI(char& choice) {
  cout << "\n------------Command Menu--------------" << endl
       << "(A) Adjacency list load from file. " << endl
       << "(D) Depth First Traversal " << endl
       << "(B) Breadth First Traversal" << endl
       << "(S) Shortest Path Dijkstra's Algorithm " << endl
       << "(Q) Quit" << endl
       << endl << "Enter Choice: ";
  cin >> choice; 
}

// Execute user selected command. 
bool execCmd(char choice, Graph *graph) {
  switch(choice) {
  case 'A':
  case 'a': {
    cout << "Loading graph data from file ......";
    string fname = "graph.txt";
    graph->loadFileToAdjList(fname);
    graph->printAdjList();
    cout << "done!" << endl;
    return true;
  }
  case 'D':
  case 'd': {
    cout << "Depth First Graph Traversal. ";
    graph->DFSTraversal(0);
    cout << " done!" << endl;
    return true;
  }
  case 'B':
  case 'b': {
    cout << "Breadth First Graph Traversal. ";
    graph->BFSTraversal(0);
    cout << " done!" << endl;
    return true;
  }
  case 'Q':
  case 'q': {
    return false;
  }
  default:
    cout << "Wrong command: " << choice << ", please try again!" << endl;
    cout << endl;
    return true;
  }
}
