#include <iostream>
#include <string>
#include <map>
#include <list>
#include <fstream>
#include <regex>

using std::string;
using std::cout;
using std::cerr;
using std::endl;

std::map<string, int> labels;
std::list<string> fileBuf;

void fileProcessing(string);
void commandHandler(string);

void push(string);
void pop(void);
void ret(void);
void sub(void);
void add(void);
void mul(void);
void div(void);
void mod(void);
void neg(void);
void str(void);
void str(string);
void cmp();
void goTo(string);


int main(int argc, char const *argv[])
{
    if (argc < 2) {
        cerr << "interpretator: Error, no file. Try ./interpretator \"filename.zasm\"" << endl;
        return -1;
    }

    fileProcessing(argv[1]);

    return 0;
}

void fileProcessing(string fileName)
{
    std::ifstream inFile(fileName);
    if (!inFile.is_open()) {
        cerr << "interpretator: Error, Cannot open " << fileName << endl;
        return;
    }

    int lineCtr = 0;
    for (string line; getline(inFile, line); ) {
        if (line.find("label") == 0 || line.find("cycle_") == 0) 
            labels.emplace(line, lineCtr);

        lineCtr++;
        fileBuf.emplace_back(line);
    }

    for (auto const &_ : labels)
        cout << "label: " << _.first << " line number: " << _.second << endl;
    cout << endl;

    for (auto const &_ : fileBuf)
        commandHandler(_);
}

void commandHandler(string line)
{
    static size_t ctr = 0;
    cout << ctr++ << ". " << line << endl;
    if (line.find("push")) {
        //cout << "found string: " << line << endl;
        //push(line.substr(search, string::npos));
    }
}

void push(string arg)
{
    cout << "push: " << arg << endl;
}