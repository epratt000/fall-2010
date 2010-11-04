#include "HashTree.h"

HashNode::HashNode():parent(NULL),hkey("0:0"),level(0){
  children.clear();
  item_sets.clear();
  children_sets.clear();
}

// Visit hash tree node.
void HashNode::visit() {
  // VN: visit node, NC: number of children, NF: number of frequent
  // itemsets, FS: frequent itemsets.
  cout << "VN " << getHashKey() << "->";
  if(getParent()) cout << getParent()->getHashKey();
  cout << " NC: " << getNumChildren()
       << " NFI: " << getNumFreqSets() << " FIS: ";
  map<Itemset, int>::iterator it; 
  for(it = getFreqsets().begin(); it != getFreqsets().end(); it++) {
    cout << (*it).first << ":" << (*it).second << " "; 
  }
  cout << endl;
}

// Add a child to hash node. 
bool HashNode::addChild(HashNode *child) {
  if(!child) return false;
  children.push_back(child);
  child->setParent(this);
  return true;
}

// Join sets within the node.
bool HashNode::joinSameParentSets(vector<Itemset>& set) {
  HashNode *parent = getParent();
  if(!parent || getNumChildrenSets()<2) return false; 

  //  if(getNumFreqSets() < 2) return false; // less than two sets.
  map<Itemset, int>::iterator it;
  for(it = getChildrenSets().begin(); 
      it != getChildrenSets().end(); it++) {
    map<Itemset, int>::iterator iit;
    for(iit = it; iit != getChildrenSets().end(); iit++) {
      //cout << (*it).first << " " << (*iit).first << endl; 
      if(isJoinable(const_cast<Itemset&>((*it).first), 
		    const_cast<Itemset&>((*iit).first))) {
	set.push_back(const_cast<Itemset&>((*it).first).
		      join(const_cast<Itemset&>((*iit).first)));
      }
    }
  }
  clearChildrenSets();
  return set.size() > 0;
}
////////////////////////////////////////////////////
// Hash tree implementation. 
////////////////////////////////////////////////////
HashTree::HashTree():height(0),num_nodes(0) {
  root = new (nothrow) HashNode();
  if(!root) cerr << "Error creating hash tree." << endl;
}

// Insert a node into the tree. 
bool HashTree::insertNode(HashNode *parent, HashNode *node) {
  node->setParent(parent);
  parent->addChild(node);
  addNodeToIndex(node);
#ifdef DEBUG_HASH_INSERT
  cout << "Insert Node with key: " << node->getHashKey()
       << " level: " << node->getNodeLevel()
       << " num item sets: " << node->getNumFreqSets()
       << " num of children: " << node->getNumChildren() << endl;
#endif
  return true; 
}

// insert an itemset into one node of the tree. 
bool HashTree::insertItemset(Itemset& set) {
  // First, find out where we should insert the itemset to.

  // Second, insert.
  return true;
}

// Join and grow the tree to a higher level.
// This function will traverse all the nodes of a given level. 
// And itemsets within each node will be tested to see if they
// are joinable, and produce the joined itemsets. 
// After each join, a scan will be done to get the support of an
// itemset. If the itemset has higher support than given, then grow
// the tree to a higher level and insert the itemset into the newly
// added node. 
bool HashTree::doJoinGrow(int level) {
  // traverse all nodes. 
  for(int i = 0; i < getKindexSize(); i++) {

  } // for.
  return true;
}

// Traverse the hash tree in level order. 
bool HashTree::levelTraverse(HashNode* root) {
  //cout << "level traversal: " << root << endl; 
  if(!root) return false;
  queue<HashNode*> q;
  HashNode* curnode = root; 	// current node. 
  q.push(curnode);
  while(q.size() > 0 && curnode) {
    curnode = q.front(); 
    vector<HashNode*>::iterator it;
    for(it = curnode->getChildren().begin(); 
	it != curnode->getChildren().end(); it++) {
      if(*it) {
	q.push(*it);
      }
    }
    q.pop();
    curnode->visit(); 
  }
  return true;
}

// Print all the content of the hash tree. 
void HashTree::printTree() {

}
