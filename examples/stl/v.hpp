#include <vector>
#include <string>
#include <map>
//#include <pair>
#include "stdio.h"

using std::vector;
using std::string;
using std::map;
using std::pair;

// typedef map<std::string,std::string> MapStringString;
// typedef pair<std::string,std::string> PairStringString;

struct Problem
{
	vector<double> values;
	map<std::string,std::string> stringStringMap2;
	// MapStringString stringStringMap; typedef dont work yet
	// PairStringString pairStringString;
};

Problem problem(double*,size_t);
template <class T>
size_t getVectorSize(void* bytes)
{
	printf("getVectorSize should be %ld\n",sizeof(vector<T>));
	vector<T>* p;
	void** bytesPtr = reinterpret_cast<void**>(bytes);
	p = reinterpret_cast<vector<T>*>(bytesPtr);
	auto size = p->size();
	printf("getVectorSize returning %ld\n",size);
	return size;
}

template <class T>
void printVector(void* bytes)
{
	void** bytesPtr = reinterpret_cast<void**>(bytes);
	vector<T>* p = reinterpret_cast<vector<T>*>(bytesPtr);
	auto size = p->size();	
	printf("vector size = %ld\n",size);
	for(long i = 0;i<size;++i)
		printf("%f",p->data()[i]);
}
template <class T>
void* getVectorData(void* bytes)
{
	void** bytesPtr = reinterpret_cast<void**>(bytes);
	vector<T>* p = reinterpret_cast<vector<T>*>(bytesPtr);
	return (void*) p->data();
}
template <class T>
void createVector(void* ptr, void* data, size_t size)
{
	void** bytesPtr = reinterpret_cast<void**>(ptr);
	vector<T>* v = reinterpret_cast<vector<T>*>(bytesPtr);
	T* refData = reinterpret_cast<T*>(data);
	*v = vector<double>(size);
	for(long i =0; i<size;i++)
		v->assign(i,refData[i]);
}
double* getVectorDataDouble(void* bytes);
size_t getVectorFoo(struct Problem* problem);
void* p1 = (void*) &getVectorSize<double>;
void* p2 = (void*) &getVectorData<double>;
void* p3 = (void*) &createVector<double>;
void* p4 = (void*) &printVector<double>;
