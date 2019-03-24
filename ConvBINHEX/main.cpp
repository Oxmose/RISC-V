#include <iostream>
#include <fstream>
#include <iomanip>

using namespace std;

int main(int argc, char** argv)
{
    if(argc != 3)
    {
        return -1;
    }

    ifstream inputFile(argv[1], ios::in|ios::binary);
    ofstream outputFile(argv[2], std::ios_base::app);
    if(!inputFile.is_open() || !outputFile.is_open()) {
        cout << "NOPE" << endl;
        return -1;
    }
    uint32_t i = 0;
    uint32_t val = 0;
    inputFile.read((char*)&val,sizeof(int8_t));
    while(!inputFile.eof())
    {
        if(i != 0 && i % 1 == 0)
        {
            outputFile << "\n";
            cout << std::endl;
        }
        ++i;


        outputFile << hex << setw(2) << setfill('0') << (uint32_t)val;
        cout << hex << setw(2) << setfill('0') << (uint32_t)val;
        inputFile.read((char*)&val,sizeof(int8_t));
    }

    inputFile.close();
    outputFile.close();
}
