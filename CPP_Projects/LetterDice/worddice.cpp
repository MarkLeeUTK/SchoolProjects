// Project 5 -- Letter Dice
// Mark Lee and Jarod Jelinek
// CS302/307   4-10-19

/* The purpose of this program is to use the Edmonds-Karp Algorithm
 * and concepts of Network Flow to solve the following problem: given
 * a number of dice with letters on each side, and a series of words,
 * determine for each word whether the word can be spelled using a
 * combination of the dice. The solution consists of constructing a
 * graph with the dice and word letters as Nodes, using Breadth-First
 * Search as the method to find augmenting paths, and using the residual
 * graph to determine maximum flow. If the maximum flow equals the number
 * of letters in the word, it can be spelled.
 */

#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <cstdio>
#include <queue>
#include <map>
#include <set>

using namespace std;

//The Node class for each dice and the letters of the word, used in
//the Graph class
class Node {
	public:
		Node(string);
		vector<char> name; //vector of chars for comparison
		set<int> adj; //list of adjacent Nodes based on index in adjacency list
		int back_edge;
		bool visited;
		int index;
};

//Node constructor
Node::Node(string s) {
	for(unsigned int i = 0; i < s.size(); i++) {
		name.push_back(s[i]);
	}
	back_edge = -1;
	index = -1;
	visited = false;
}

//Graph class around which the program is centered. Has methods for adding
//dice, words, BFS traversal, Edmonds-Karp analysis, and removing words
class Graph {
	public:
		Graph();
		~Graph();
		void Add_Dice(string);
		void Add_Word(string);
		bool BFS_Traversal(class Node*, class Node*);
		void Edmonds_Karp();
		void Remove_Word(string);
		void Reset_BFS();

		unsigned int MaxFlow;
		string current_word;
		Node *Source;
		Node *Sink;

		vector <Node *> Dice;    //Holds every dice
		vector <Node *> Letters; //Holds every letter
		vector <Node *> Nodes;   //All Nodes (adj. list representation)
};

//Graph Constructor
Graph::Graph() {

	MaxFlow = 0;
	current_word = "";

	Source = new Node("SOURCE");
	Sink = new Node("SINK");

	Nodes.push_back(Source);
	Source->index = 0;
}

//Graph Deconstructor (letters are deleted by Remove_Word())
Graph::~Graph() {

	delete Source;
	delete Sink;

	for(unsigned int i = 0; i < Dice.size(); i++) {
		delete Dice[i];
	}
}

//This method adds each dice as a Node* to the Graph
void Graph::Add_Dice(string dice) {

	Node *n = new Node(dice);
	Nodes.push_back(n);
	n->index = Nodes.size() - 1;
	Dice.push_back(n);
}

//This method adds each word as letter Node*s in the Graph,
//then connects the edges between all Nodes in the Graph. Acts
//as a second constructor
void Graph::Add_Word(string word) {

	unsigned int i, j, k;
	string s;

	//Store the word for later printing
	current_word = word;

	//Create a Node for each letter in the word
	for(i = 0; i < word.size(); i++) {
		s = word[i];
		Node *n = new Node(s);
		Nodes.push_back(n);
		n->index = Nodes.size() - 1;
		Letters.push_back(n);
	}
	Nodes.push_back(Sink);
	Sink->index = Nodes.size() - 1;

	//Connect the Source Node to each dice Node
	for(i = 0; i < Dice.size(); i++) {
		Source->adj.insert(Dice[i]->index);
	}

	//Connect the dice to the word letters
	for(i = 0; i < Dice.size(); i++) {
		for(j = 0; j < Letters.size(); j++) {
			for(k = 0; k < Dice[i]->name.size(); k++) {
				if(Dice[i]->name[k] == Letters[j]->name[0]){
					Dice[i]->adj.insert(Letters[j]->index);
				}
			}
		}
	}

	//Connect each letter to the Sink
	for(i = 0; i < Letters.size(); i++) {
		Letters[i]->adj.insert(Sink->index);
	}
}

//BFS_traversal method takes the Source Node* and the Sink Node* and
//uses Breadth-First Search to see if a path exists between the two
bool Graph::BFS_Traversal(Node* start, Node* end)
{
	//q is used to hold the Node*s that we should be visiting
	queue<Node*> q;

	//This variable holds the current Node* index in the adjacency list
	//representation of the Graph (the vector "Nodes")
	int current_index;

	//Initialize the queue for BFS
	q.push(start);

	set<int>::iterator set_iter;

	while(!q.empty())
	{
		//Get the Node* at the top of the queue and remove it
		current_index = q.front()->index;
		q.pop();

		//If this node hasn't already been visited, then visit it
		if(!Nodes[current_index]->visited)
		{
			//If the current Node* equals the Sink, then the path has been found
			if(Nodes[current_index] == end) return true;

			//Put the Node*'s adjacent Node*s on the queue if they haven't been
			//visited, and set their back edges to the index of the Node* that
			//put them on the queue
			for(set_iter = Nodes[current_index]->adj.begin();
					set_iter != Nodes[current_index]->adj.end(); ++set_iter) {

				if(!Nodes[*set_iter]->visited) {
					Nodes[*set_iter]->back_edge = current_index;
					q.push(Nodes[*set_iter]);
				}
			}

			//We're done with this Node*, so mark it as visited
			Nodes[current_index]->visited = true;
		}
		//Else the node has been visited; ignore it and continue
	}

	//No path to the destination node exists
	return false;
}

//This simple function resets every Node*'s visited field to false so that
//BFS can properly be performed on the Graph again
void Graph::Reset_BFS() {

	for(unsigned int i = 0; i < Nodes.size(); i++) {
		Nodes[i]->visited = false;
	}
}

//The crux of the program, this method implements the Edmonds-Karp
//Algorithm to determine if the given dice can spell the given word.
void Graph::Edmonds_Karp() {

	int start;
	set<int>::iterator set_iter;
	map<char, int>::iterator map_iter;

	//For every path BFS finds between the Source and the Sink,
	//increment the MaxFlow and reverse the path (reversing in this
	//case creates the residual graph)
	while(BFS_Traversal(Source, Sink)) {

		MaxFlow += 1;

		//Reverse path from Sink to Source. To "reverse", follow the
		//back edges, removing one Node index from one adjacent list
		//and adding it to the other. Then increment start.
		start = Sink->index;
		while(start != Source->index) {
			set_iter = Nodes[Nodes[start]->back_edge]->adj.find(start);
			Nodes[Nodes[start]->back_edge]->adj.erase(set_iter);
			Nodes[start]->adj.insert(Nodes[start]->back_edge);
			start = Nodes[Nodes[start]->back_edge]->index;
		}

		Reset_BFS();
	}

	Reset_BFS();

	//Print the result. If MaxFlow = the number of letters in the word,
	//then the word can be spelled, and every letter's adjacency list
	//points to the one dice it can be spelled by.
	if(MaxFlow != current_word.size())
		cout << "Cannot spell " << current_word << endl;
	else {
		set_iter = Letters[0]->adj.begin();
		cout << Nodes[*set_iter]->index - 1;
		for(unsigned int i = 1; i < Letters.size(); i++) {
			set_iter = Letters[i]->adj.begin();
			cout << "," << Nodes[*set_iter]->index - 1;
		}
		cout << ": " << current_word << endl;
	}

}

//This method removes the word from the Graph
void Graph::Remove_Word(string word) {

	unsigned int i;

	//Clear the adjacency lists of Nodes not being deleted
	Source->adj.clear();
	Sink->adj.clear();
	for(i = 0; i < Dice.size(); i++) {
		Dice[i]->adj.clear();
	}

	//Delete every Node* representing the letters of the word
	for(i = 0; i < Letters.size(); i++) {
		delete Letters[i];
	}

	//Reset the vectors holding the Nodes to avoid massive seg-faulting
	Letters.clear();
	Nodes.resize(Dice.size() + 1);

	//Reset the maximum flow variable to 0 for the next iteration
	MaxFlow = 0;
}

int main (int argc, char *argv[]) {

	string dice, word;
	ifstream fin_dice, fin_words;

	//Error check (unnecessary with these flawless files, but what the hell!)
	fin_dice.open(argv[1]);
	if(fin_dice.fail()) {
		cout << "Command line format: worddice [dice_filename].txt [words_filename].txt" << endl;
		return 0;
	}

	fin_words.open(argv[2]);
	if(fin_words.fail()){
		cout << "Command line format: worddice [dice_filename].txt [words_filename].txt" << endl;
		return 0;
	}

	//Instantiate Graph object, then add every dice to graph as a Node*
	Graph* graph = new Graph();

	while(fin_dice >> dice) {
		graph->Add_Dice(dice);
	}
	fin_dice.close();

	//Add a word to the graph, separating its individual letters, and perform the
	//Edmonds-Karp Algorithm to determine if the word can be spelled by a combinaiton
	//of the dice. Remove the word afterwards and move on to the next.
	while(fin_words >> word) {

		graph->Add_Word(word);

		graph->Edmonds_Karp();

		graph->Remove_Word(word);
	}

	delete graph;

	fin_words.close();

	return 0;
}
