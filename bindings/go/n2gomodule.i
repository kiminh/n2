%module n2

%{
#include "n2gomodule.h"
#include <vector>

%}

// const float *
%typemap(gotype) (std::vector<float>)  "[]float32"

%typemap(in) (std::vector<float>)
%{
    float *v;
    std::vector<float> w;
    v = (float *)$input.array;
    for (int i = 0; i < $input.len; i++) {
       w.push_back(v[i]);
    }
    $1 = w;
%}

// vector<int> *
%typemap(gotype) (std::vector<int> *)  "*[]int"

%typemap(goin) (std::vector<int> *)
%{
	//Wrap variables to avoid cgocheck
	var v []int
	$result = &v
%}

%typemap(in) (std::vector<int> *)
%{
  $1 = new std::vector<int>();
%}

%typemap(freearg) (std::vector<int> *)
%{
  delete $1;
%}

%typemap(argout) (std::vector<int> *)
%{
  {
    $input->len = $1->size();
    $input->cap = $1->size();
    $input->array = malloc($input->len * sizeof(intgo));
    for (int i = 0; i < $1->size(); i++) {
        ((intgo *)$input->array)[i] = (intgo)(*$1)[i];
    }
  }
%}

%typemap(goargout) (std::vector<int> *)
%{
	{
		r := swigCopyIntSlice($input)
		*$1 = r
	}
%}

// vector<float> *
%typemap(gotype) (std::vector<float> *)  "*[]float32"

%typemap(goin) (std::vector<float> *)
%{
	//Wrap variables to avoid cgocheck
	var vv []float32
	$result = &vv
%}

%typemap(in) (std::vector<float> *)
%{
  $1 = new std::vector<float>();
%}

%typemap(freearg) (std::vector<float> *)
%{
  delete $1;
%}

%typemap(argout) (std::vector<float> *)
%{
  {
    $input->len = $1->size();
    $input->cap = $1->size();
    $input->array = malloc($input->len * sizeof(float));
    for (int i = 0; i < $1->size(); i++) {
        ((float *)$input->array)[i] = (float)(*$1)[i];
    }
  }
%}

%typemap(goargout) (std::vector<float> *)
%{
	{
		r := swigCopyFloatSlice($input)
		*$1 = r
	}
%}


%typemap(gotype) (const char *) "string"

%typemap(in) (const char *)
%{
  $1 = (char *)calloc((((_gostring_)$input).n + 1), sizeof(char));
  strncpy($1, (((_gostring_)$input).p), ((_gostring_)$input).n);
%}

%typemap(freearg) (const char *)
%{
  free($1);
%}

%insert("go_runtime") %{
type swig_goslice struct { array uintptr; len int; cap int }
func swigCopyIntSlice(s *[]int) []int {
	p := *(*swig_goslice)(unsafe.Pointer(s))
	r := make([]int, p.len)
	copy(r, *s)
	Swig_free(p.array)
	return r
}


func swigCopyFloatSlice(s *[]float32) []float32 {
	p := *(*swig_goslice)(unsafe.Pointer(s))
	r := make([]float32, p.len)
	copy(r, *s)
	Swig_free(p.array)
	return r
}
%}

%include "n2gomodule.h"

%feature("noabstract") Hnsw;
