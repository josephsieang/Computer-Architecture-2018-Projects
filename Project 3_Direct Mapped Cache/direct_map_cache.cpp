#include <iostream>
#include <math.h>
#include <stdio.h>
#include <string>
#include <sstream>

using namespace std;

int convertBinaryToDecimal(long long binaryNum)
{
    int decNum = 0;
    int i = 0;
    int remainder = 0;

    while (binaryNum != 0)
    {
        remainder = binaryNum % 10;
        binaryNum /= 10;
        decNum += remainder * pow(2,i);
        i++;
    }
    return decNum;
}

long long convertDecimalToBinary(int decimalNum)
{
    long long binaryNum = 0;
    int remainder;
    int i = 1;
    int step = 1;

    while (decimalNum != 0)
    {
        remainder = decimalNum % 2;
        decimalNum /= 2;
        binaryNum += remainder * i;
        i *= 10;
    }
    return binaryNum;
}

struct cache_content{
	bool v;
	unsigned int  tag;
//	unsigned int	data[16];
};

FILE *output;

void simulate(int cache_size, int block_size){
	unsigned int tag = 0, index = 0, x = 0;
	int line = cache_size / block_size;
	string memory_address_binary = "";
	long long memory_address = 0;
	int quotient =  block_size;
	int quotient2 = line;
	int byte_offset = 0;
	int index_bit = 0;
	int placement = 0;


	cache_content *cache = new cache_content[line];
	//cout<<"cache line:"<<line<<endl;
	int hit_count = 0;
	int miss_count = 0;
	for(int j=0;j<line;j++)
		cache[j].v=false;

    for(;;)
    {
        quotient /= 2;
        byte_offset++;
        if(quotient == 1)
            break;
    }

    for(;;)
    {
        quotient2 /= 2;
        index_bit++;
        if(quotient2 == 1)
            break;
    }

  	FILE * fp=fopen("testcase.txt","r");
  				//read file

	while(fscanf(fp,"%x", &x)!=EOF){
        memory_address = convertDecimalToBinary(x);
        ostringstream convert;
        convert << memory_address;
        memory_address_binary = convert.str();
        string tag_string = "";
        unsigned int tag = 0;

        int tag_size = memory_address_binary.length();
        if((tag_size - byte_offset - index_bit) <= 0)
        {
            tag_size = 0;
        }
        else
        {
            tag_size = tag_size - byte_offset - index_bit;
        }

        for(int i = 0; i < tag_size; i++)
        {
            tag_string += memory_address_binary.at(i);
        }

        stringstream ss(tag_string);
        ss >> tag;

        tag = convertBinaryToDecimal(tag);

        int block_addr = x / block_size;
        int block_num = block_addr % line;
        placement = block_num;



        if(cache[placement].v == true)
        {
            if(tag == cache[placement].tag)
            {
                hit_count++;
            }
            else
            {
                miss_count++;
            }
        }
        else
        {
            miss_count++;
        }
        cache[placement].tag = tag;
        cache[placement].v = true;


        fprintf(output, "Address: %x, Tag: %x\n", x, tag);
	}

	fprintf(output,"hit: %d\n",hit_count);
	fprintf(output,"miss: %d\n",miss_count);
	fclose(fp);
	delete [] cache;
}

int main(){
	output=fopen("./output.txt","w");
	// Let us simulate 4KB cache with 16B blocks
	fprintf(output,"Cache size: 32 Block size: 8\n");
	simulate(32, 8 );
	fprintf(output,"Cache size: 64 Block size: 8\n");
	simulate(64, 8);
	fprintf(output,"Cache size: 256 Block size: 16\n");
	simulate(256, 16);
	fclose(output);
}
