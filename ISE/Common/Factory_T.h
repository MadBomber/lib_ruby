#ifndef FACTORY_T_H
#define FACTORY_T_H

template <class BT>
class FactoryPlant
{
   public:
      FactoryPlant() {}
      virtual ~FactoryPlant() {}
      virtual BT *createInstance(void) = 0;
};

template <class BT, class ST>
class Factory : public FactoryPlant<BT>
{
   public:
      Factory() {}
      virtual ~Factory() {}
      virtual BT *createInstance(void) {return new ST();}
};

#endif // FACTORY_T_H

