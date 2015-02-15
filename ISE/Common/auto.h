#ifndef AUTO_H
#define AUTO_H

#ifdef AUTO
#undef AUTO
#endif
#define AUTO(VAR,INIT) typeof(INIT) VAR = INIT

#endif /* AUTO_H */
