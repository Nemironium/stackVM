#include <iostream>
#include <string>
#include <map>
#include <fstream>

using std::string;
using std::cout;
using std::cerr;
using std::endl;

void commandHandler(string);

int main(int argc, char const *argv[])
{
    if (argc < 2) {
    std::cerr << "interpretator: Error, no file. Try ./interpretator \"filename.zasm\"" << endl;
        return -1;
    }

    commandHandler(argv[1]);

    return 0;
}

void commandHandler(string fileName)
{
    std::ifstream inFile(fileName);
    if (!inFile.is_open()) {
        cerr << "interpretator: Error, Cannot open " << fileName << endl;
        return;
    }

}

