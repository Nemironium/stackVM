#include <iostream>
#include <fstream>
#include <string>
#include <streambuf> // std::istreambuf_iterator
#include <regex>

// Expand expressions with -=,+=,*=,/=,%=
std::string assignReplace(const std::string& fileName)
{
    std::ifstream inFile(fileName);

    if (!inFile.is_open()) {
        std::cerr << "Error: Cannot open " << fileName << std::endl;
        return "";
    }
    std::string content((std::istreambuf_iterator<char>(inFile)), std::istreambuf_iterator<char>());

    std::string reg("[_a-zA-Z]+[a-zA-Z0-9_]*\\s*");
    std::smatch res;

    for (auto const &_ : {"\\+=", "\\-=", "\\*=", "\\/=", "\\%="}) {
        std::regex pattern(reg + _);
        std::string tempBuf(content);
        while (std::regex_search(tempBuf, res, pattern)) {
            std::smatch sBuf;
            std::string tempStr(res[0]);
            std::string signBuf(_);

            std::regex_search(tempStr, sBuf, std::regex(reg));
            tempStr = std::string(sBuf[0]) + std::string("=") + std::string(sBuf[0]);

            std::regex_search(signBuf, sBuf, std::regex("[+*-/%]+"));
            tempStr += std::string(sBuf[0]);

            content = std::regex_replace(content, pattern, tempStr);
            tempBuf = res.suffix();
        }
    }
    return content;
}

int main(int argc, char const *argv[])
{
    if (argc < 2) {
        std::cerr << "preprocessor: Error, no file. Try ./preprocessor \"filename.z\"" << std::endl;
        return -1;
    }

    std::ofstream outFile(std::string(argv[1]) + ".temp");
    outFile << assignReplace(argv[1]);
    return 0;
}
