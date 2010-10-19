// -*- C++ -*-
/**
 * @file Database.cpp
 * @brief Implementation of the Database class. 
 * @author Shumin Guo (guo.18@wright.edu)
 * @version 1.0.0
 */
// $Log$

#include "Database.h"

Database::Database() {
  index = new (nothrow) BSTree(); // create employee id index. 
  if(!index) {
    cerr << "Error while creating employee index." << endl;
  }
}

// Constructor with vector. 
Database::Database(const vector<string>& ed) {

}

// Copy Constructor. 
Database::Database(const Database& e) {

}

// overloading << also for output.
// without annotations. 
ostream& operator<<(ostream& out, Database& e) {
  return out;
}

// Save the employee information to file.
bool Database::saveToFile() {
  string fname; 
  cout << "Please Enter the File Name to Save TO: ";
  cin >> fname; 
  cout << "Saving records to file " << fname << "..." << endl; 
  if(employee.saveToFile(fname))
    cout << "Totally saved " << employee.size() 
	 << " records to " << fname << endl;
  return true;
}

// Load employee information from file. 
bool Database::loadFromFile() {
  string fname; 
  cout << "Please Enter file name to read from: ";
  cin >> fname;
  string line; int num = 0;
  fstream fd;
  vector<string> edata;		// Employee data. 
  fd.open(fname.c_str(), fstream::in);
  if(!fd) {cerr << "Error opening data file..." << endl; return false;}
  cout << "Loading records from file " << fname << "..." << endl; 
  while(fd) {
    getline(fd, line, fd.widen('\n'));
    // Start of file or start of employee data. 
    if((line.compare("<Records>")==0) || (line.compare("--")==0)) {
      edata.clear();
      for(int i = 0; i < 9; i++) {
	getline(fd, line, fd.widen('\n'));
	if(line.compare("<END>")==0) {
	  cout << "Loading finished, totally loaded " 
	       << num << " records. "<< endl; 
	  return true; // end of file 
	}
	edata.push_back(line);
      }
      // Now creating Employee object and insert into list.
      Employee em(edata);
      BTreeNode *node = new (nothrow) BTreeNode(&em);
      index->insertNode(index->getRoot(), node);
      if(!node) return false;
      employee.insert(em); num++; 
    } //if 
  } //while 
  return true; 
}

// print out all the records to stdout.
void Database::printAll() {
  employee.print();
}

// Insert new Employee into database. 
bool Database::insertNewEmployee() {
  Employee e;
  BTreeNode *node = new (nothrow) BTreeNode(&e);
  if(!node) return false;
  index->insertNode(index->getRoot(), node);
  employee.insert(e);
}

// Search employee by lastname. 
void Database::findByLastname(string var) {
  employee.find(var);
}
