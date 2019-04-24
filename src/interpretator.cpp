#include <iostream>
#include <string>
#include <map>
#include <vector>
#include <fstream>
#include <regex>

using std::string;
using std::cout;
using std::cerr;
using std::endl;

void fileProcessing(string);
void commandHandler(string);
void push(string);
void str(string);
void pop(void);
void sub(void);
void add(void);
void mul(void);
void div(void);
void mod(void);
void neg(void);

void cmp();
void goTo(string);
void print(void);
void ret(void);

enum states
{
    MORE,
    LESS,
    EQ
};

std::map<string, int> labels;
std::map<string, int> heap;
std::vector<string> fileBuf;
std::vector<int> stack;

unsigned gInstructionPtr = 0;

states SREG;


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
    std::regex pattern("(label||cycle)[0-9]+:");
    std::smatch result;

    for (string line; getline(inFile, line); ) {
        // label and cycle searching
        if (std::regex_search(line, result, pattern)) {
            string temp(result[0]);
            labels.emplace(temp.substr(0, temp.size() - 1), lineCtr);
        }

        lineCtr++;
        fileBuf.emplace_back(line);
    }

    for (; gInstructionPtr < lineCtr; gInstructionPtr++)
        commandHandler(fileBuf[gInstructionPtr]);

    inFile.close();
}

void commandHandler(string line)
{
    //static size_t ctr = 0;
    //cout << ctr++ << ". " << line << endl;
    /*
    if (line.find("push") != string::npos) {
        std::smatch sBuf;

        // search push operand: number or [var]
        std::regex_search(line, sBuf, std::regex("[0-9]+|\[[_a-zA-Z0-9]+\]"));
        push(string(sBuf[0]));
    }
    else if (line.find("str") != string::npos) { 
        std::smatch sBuf;

        // search str operand: [var]
        std::regex_search(line, sBuf, std::regex("\[[_a-zA-Z0-9]+\]"));
        str(string(sBuf[0]));
    }*/
    if (line.find("pop") != string::npos) {
        pop();
    }
    else if (line.find("add") != string::npos) {
        add();
    }
    else if (line.find("sub") != string::npos) {
        sub();
    }
    else if (line.find("mul") != string::npos) {
        mul();
    }
    else if (line.find("div") != string::npos) {
        div();
    }
    else if (line.find("mod") != string::npos) {
        mod();
    }
    else if (line.find("neg") != string::npos) {
        neg();
    }
    else if (line.find("call print") != string::npos) {
        print();
    }
    else if (line.find("call ret") != string::npos) {
        ret();
    }
    else if (line.find("cmp") != string::npos) {
        cmp();
    }
    /*else if (line.find("jmp") != string::npos) {
        std::smatch sBuf;
        // search jmp operand: cycle or label
        std::regex_search(line, sBuf, std::regex("\[[_a-zA-Z0-9]+\]"));
        goTo(string(sBuf[0]) + ':');
    }
    else if (line.find("jz") != string::npos) {
        std::smatch sBuf;
        // search jz operand: cycle or label
        std::regex_search(line, sBuf, std::regex("\[[_a-zA-Z0-9]+\]"));
        if (SREG == MORE || SREG == LESS)
            goTo(string(sBuf[0]) + ':');
    }
    else if (line.find("je") != string::npos) {
        std::smatch sBuf;
        // search je operand: cycle or label
        std::regex_search(line, sBuf, std::regex("\[[_a-zA-Z0-9]+\]"));
        if (SREG == EQ)
            goTo(string(sBuf[0]) + ':');
    }
    else if (line.find("jae") != string::npos) {
        std::smatch sBuf;
        // search jae operand: cycle or label
        std::regex_search(line, sBuf, std::regex("\[[_a-zA-Z0-9]+\]"));
        if (SREG == EQ || SREG == MORE)
            goTo(string(sBuf[0]) + ':');
    }
    else if (line.find("jbe") != string::npos) {
        std::smatch sBuf;
        // search jbe operand: cycle or label
        std::regex_search(line, sBuf, std::regex("\[[_a-zA-Z0-9]+\]"));
        if (SREG == EQ || SREG == LESS)
            goTo(string(sBuf[0]) + ':');
    }
    else if (line.find("jb") != string::npos) {
        std::smatch sBuf;
        // search jb operand: cycle or label
        std::regex_search(line, sBuf, std::regex("\[[_a-zA-Z0-9]+\]"));
        if (SREG == MORE)
            goTo(string(sBuf[0]) + ':');
    }
    else if (line.find("ja") != string::npos) {
        std::smatch sBuf;
        // search ja operand: cycle or label
        std::regex_search(line, sBuf, std::regex("\[[_a-zA-Z0-9]+\]"));
        if (SREG == LESS)
            goTo(string(sBuf[0]) + ':');
    }*/

}

void push(string arg)
{
    if (arg[0] != '[')
        stack.emplace_back(std::stoi(arg));
    else {
        arg.erase(0, 1);
        arg.erase(arg.size() - 1, 1);
        for(auto const & _ : heap) {
            if (arg == _.first) {
                stack.emplace_back(_.second);
                return;
            }   
        }
        cerr << "interpretator: Error, uninitialised value " << arg << endl;
    }   
}

void str(string arg)
{
    heap.emplace(arg, stack[stack.size() - 1]);
}

void pop(void)
{
    stack.pop_back();
}

void add(void)
{
    int temp = stack[stack.size() - 1] + stack[stack.size() - 2];
    stack.pop_back();
    stack.pop_back();
    stack.push_back(temp);
}

void sub(void)
{
    int temp = stack[stack.size() - 2] - stack[stack.size() - 1];
    stack.pop_back();
    stack.pop_back();
    stack.push_back(temp);
}

void mul(void)
{
    int temp = stack[stack.size() - 1] * stack[stack.size() - 2];
    stack.pop_back();
    stack.pop_back();
    stack.push_back(temp);
}

void div(void)
{
    int temp = stack[stack.size() - 2] / stack[stack.size() - 1];
    stack.pop_back();
    stack.pop_back();
    stack.push_back(temp);
}

void mod(void)
{
    int temp = stack[stack.size() - 2] % stack[stack.size() - 1];
    stack.pop_back();
    stack.pop_back();
    stack.push_back(temp);
}

void neg(void)
{
    int temp = -stack[stack.size() - 1];
    stack.pop_back();
    stack.push_back(temp);
}

void cmp()
{
    if (stack[stack.size() - 1] > stack[stack.size() - 2])
        SREG = MORE;
    else if (stack[stack.size() - 1] < stack[stack.size() - 2])
        SREG = LESS;
    else if (stack[stack.size() - 1] == stack[stack.size() - 2])
        SREG = EQ;
}

/*void goTo(string arg)
{
    for (auto const &_ : labels) {
        if (arg == _.first) {
            gInstructionPtr = _.second;
            return;
        }
    }
}*/

void print(void)
{
    cout << stack[stack.size() - 1] << endl;
}

void ret(void)
{
    cout << "Program was terminated with " << stack[stack.size() - 1] << " code" << endl;
    exit(0);
}