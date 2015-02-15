
    #define TYPE(V,I) V=strtoul(#I,0,2);
    TYPES
    #undef TYPE
  }

  #define TYPE(V,I) Int<sizeof(#I)-1> V;
  TYPES
  #undef TYPE

  template <class Op>
  void for_each(Op& op) {
    #define TYPE(V,I) op.apply(V);
    TYPES
    #undef TYPE
  }

  void print_size()
  {
    #define TYPE(V,I) std::cout<< #V <<": "<<(sizeof(#I)-1)<<std::endl;
    TYPES
    #undef TYPE
  }

  void print_val()
  {
    std::cout<<std::hex;
    #define TYPE(V,I) std::cout<< #V <<": "<<V<< std::endl;
    TYPES
    #undef TYPE
    std::cout<<std::dec;
  }

   int size() const
  {
    const int n= (
    #define TYPE(V,I) +sizeof(#I)-1 
    TYPES
    #undef TYPE
    +7)>>3; return n;
  }

  int bits() const
  {
    const int n= (
    #define TYPE(V,I) +sizeof(#I)-1 
    TYPES
    #undef TYPE
    ); return n;
    
  #undef TYPES
