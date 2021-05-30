#ifndef _STD_H_
#define _STD_H_

#define RunOnceEvery(_prescaler, _code) {		\
    static uint16_t prescaler = 0;			\
    prescaler++;					\
    if (prescaler >= _prescaler) {			\
      prescaler = 0;					\
      _code;						\
    }							\
  }

#endif