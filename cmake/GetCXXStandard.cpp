#include <iostream>

/* output language_standard

   As of 2018, the available language standards are
   199711, 201103, 201402, 201703.
*/

#ifndef __cplusplus
#define __cplusplus 1
#endif


int main()
{
   long language_standard = __cplusplus;
   // convert to one of 0, 98, 11, 14, 17
   if      (language_standard >= 201703) language_standard = 17;
   else if (language_standard >= 201402) language_standard = 14;
   else if (language_standard >= 201103) language_standard = 11;
   else if (language_standard >= 199711) language_standard = 98;
   else                                  language_standard = 0;

   std::cout << language_standard;
}
