
#property copyright "Copyright 2013, lazellnet@live.com"
#property link      "lazellnet@live.com"

//#include <stdlib.mqh>
#import "stdlib.ex4"
   string ErrorDescription(int a0); // DA69CBAFF4D38B87377667EEC549DE5A
#import

extern string ActivationCode = "0";
extern double Lots = 0.01;
extern int StopLoss = 0;
extern int TakeProfit = 20;
extern bool Compounding = FALSE;
extern bool Trailing = FALSE;
extern int TrailingStop = 20;
extern bool Averaging = FALSE;
extern int MaxOpenAveraging = 5;
extern int PipStep = 20;
extern double Multiplier = 0.0;
extern double TargetMoney = 0.0;
int Gi_140 = 3;
int Gi_144 = 10;
string Gs_148;
bool Gi_156 = FALSE;
double Gd_160;
int Gi_168;
int Gi_172;


int init() {
   f0_5();
   return (0);
}


int deinit() {
   Comment("");
   return (0);
}


int start() {
   if (!f0_2()) return (0);
   f0_3();
   f0_0();
   f0_10();
   f0_7();
   f0_15();
   f0_11();
   f0_13();
   return (0);
}


bool f0_2() {
   int Li_4;
   bool Li_0 = TRUE;
   if (!IsTesting()) {
      Li_4 = AccountNumber() * 2 + 234;
      ActivationCode = StringTrimLeft(ActivationCode);
      ActivationCode = StringTrimRight(ActivationCode);
      if (ActivationCode != DoubleToStr(Li_4, 0)) {
         Alert("Kode Aktivasi Anda salah");
         Li_0 = FALSE;
      }
   }
   return (Li_0);
}

// B1897515D548A960AFE49ECF66A29021
void f0_10() {
   double Ld_0;
   double Ld_8;
   double Ld_16;
   double Ld_24;
   double Ld_32;
   double Ld_40;
   if (Averaging && f0_12() > 0 && f0_12() < MaxOpenAveraging) {
      Ld_0 = MarketInfo(Symbol(), MODE_POINT);
      Ld_8 = 0;
      Ld_16 = 0;
      Ld_24 = 0;
      for (int Li_48 = 0; Li_48 < OrdersTotal(); Li_48++) {
         if (OrderSelect(Li_48, SELECT_BY_POS, MODE_TRADES)) {
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == 4784563) {
               if (OrderType() == OP_BUY) {
                  if (Ld_8 == 0.0) Ld_8 = OrderOpenPrice();
                  else Ld_8 = MathMin(Ld_8, OrderOpenPrice());
               }
               if (OrderType() == OP_SELL) Ld_16 = MathMax(Ld_16, OrderOpenPrice());
            }
         }
      }
      Ld_32 = MarketInfo(Symbol(), MODE_ASK);
      Ld_40 = MarketInfo(Symbol(), MODE_BID);
      if (Ld_8 > 0.0 && Ld_40 > 0.0) {
         Ld_24 = (Ld_8 - Ld_40) / Ld_0;
         if (Ld_24 >= PipStep) f0_4();
      }
      if (Ld_16 > 0.0 && Ld_32 > 0.0) {
         Ld_24 = (Ld_32 - Ld_16) / Ld_0;
         if (Ld_24 >= PipStep) f0_1();
      }
   }
}

// F72E2C9C4F1AD08446755CDBBFB9F925
void f0_17(string As_0) {
   int Li_8 = GetLastError();
   Gs_148 = StringConcatenate(Gs_148, As_0, " Error ", Li_8, ": ", ErrorDescription(Li_8), 
   "\n");
   if (Li_8 != 0/* NO_ERROR */) Comment(Gs_148);
}

// 9B17F334A36AD9F222E99288185E16B9
void f0_7() {
   double Ld_100;
   double Ld_108;
   if (f0_12() == 0) Gi_156 = FALSE;
   int Li_0 = 1440 / Period() + 1;
   double Ld_4 = MarketInfo(Symbol(), MODE_POINT);
   double Ld_12 = MarketInfo(Symbol(), MODE_DIGITS);
   double Ld_20 = MarketInfo(Symbol(), MODE_BID);
   double Ld_28 = MarketInfo(Symbol(), MODE_ASK);
   double Ld_36 = iClose(Symbol(), 0, 1);
   double Ld_44 = iOpen(Symbol(), 0, 1);
   double Ld_52 = iHigh(Symbol(), 0, 1);
   double Ld_60 = iLow(Symbol(), 0, 1);
   double Ld_68 = iHigh(Symbol(), PERIOD_D1, 0);
   double Ld_76 = iLow(Symbol(), PERIOD_D1, 0);
   double Ld_84 = Ld_52 + Gi_144 * Ld_4;
   double Ld_92 = Ld_60 - Gi_144 * Ld_4;
   bool Li_116 = Ld_36 == Ld_44;
   bool Li_120 = FALSE;
   Ld_68 += Gi_144 * Ld_4;
   Ld_76 -= Gi_144 * Ld_4;
   bool Li_124 = TRUE;
   bool Li_128 = TRUE;
   if (Averaging) {
      if (f0_12(OP_BUY) > 0 || f0_12(OP_SELL) > 0) {
         Li_124 = FALSE;
         Li_128 = FALSE;
      }
   }
   for (int Li_132 = 1; Li_132 <= Li_0; Li_132++) {
      if (iClose(Symbol(), 0, Li_132) == iOpen(Symbol(), 0, Li_132)) {
         if (TimeDay(iTime(Symbol(), 0, 0)) == TimeDay(iTime(Symbol(), 0, Li_132)))
            if (TimeHour(iTime(Symbol(), 0, Li_132)) == 0 && TimeMinute(iTime(Symbol(), 0, Li_132)) == 0) Li_120 = TRUE;
      }
   }
   if (TimeHour(iTime(Symbol(), 0, 0)) == 0 && TimeMinute(iTime(Symbol(), 0, 0)) == 0) Li_120 = TRUE;
   bool Li_136 = Li_116 && (!Li_120) && f0_8();
   if (Li_136) {
      if (StopLoss == 0 && (!Averaging)) {
         Ld_100 = NormalizeDouble(Ld_76, Ld_12);
         Ld_108 = NormalizeDouble(Ld_68, Ld_12);
      } else {
         Ld_100 = 0;
         Ld_108 = 0;
      }
      if (Li_124) f0_9(Ld_84, Ld_100);
      if (Li_128) f0_6(Ld_92, Ld_108);
   }
}

// 9BE56135A813CD4A28278A9A2815F9D7
int f0_8() {
   bool Li_0 = TRUE;
   int Li_8 = TimeDay(iTime(Symbol(), 0, 0));
   int Li_12 = TimeMonth(iTime(Symbol(), 0, 0));
   int Li_16 = TimeYear(iTime(Symbol(), 0, 0));
   string Ls_20 = StringConcatenate("#", Li_8, Li_12, Li_16);
   for (int Li_4 = OrdersHistoryTotal() - 1; Li_4 >= 0; Li_4--) {
      if (OrderSelect(Li_4, SELECT_BY_POS, MODE_HISTORY)) {
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == 4784563) {
            if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
               if (StringFind(OrderComment(), Ls_20) != -1) {
                  Li_0 = FALSE;
                  break;
               }
            }
         }
      }
   }
   for (Li_4 = OrdersTotal() - 1; Li_4 >= 0; Li_4--) {
      if (OrderSelect(Li_4, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == 4784563) {
            if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
               if (StringFind(OrderComment(), Ls_20) != -1) {
                  Li_0 = FALSE;
                  break;
               }
            }
         }
      }
   }
   return (Li_0);
}

// BC539D082D21A48FD2858637A11DF20B
int f0_12(int Ai_0 = -1) {
   int Li_4 = 0;
   for (int Li_8 = 0; Li_8 < OrdersTotal(); Li_8++) {
      if (OrderSelect(Li_8, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == 4784563) {
            if (Ai_0 == -1) {
               if (!(OrderType() == OP_BUY || OrderType() == OP_SELL || OrderType() == OP_BUYSTOP || OrderType() == OP_SELLSTOP || OrderType() == OP_BUYLIMIT || OrderType() == OP_SELLLIMIT)) continue;
               Li_4++;
               continue;
            }
            if (OrderType() == Ai_0) Li_4++;
         }
      }
   }
   return (Li_4);
}

// DE32E07A945B1EA90F4381687524F9C4
double f0_16(int Ai_0) {
   double Ld_4 = 0;
   double Ld_12 = MarketInfo(Symbol(), MODE_MINLOT);
   double Ld_20 = MarketInfo(Symbol(), MODE_MAXLOT);
   for (int Li_28 = 0; Li_28 < OrdersTotal(); Li_28++) {
      if (OrderSelect(Li_28, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == 4784563)
            if (OrderType() == Ai_0) Ld_4 = MathMax(Ld_4, OrderLots());
      }
   }
   if (Ld_4 == 0.0) {
      if (Compounding) Ld_4 = AccountBalance() / 10000.0;
      else Ld_4 = Lots;
   } else {
      if (Multiplier > 0.0) Ld_4 *= Multiplier;
      else {
         if (Compounding) Ld_4 = AccountBalance() / 100000.0;
         else Ld_4 = Lots;
      }
   }
   if (Ld_4 < Ld_12) Ld_4 = Ld_12;
   if (Ld_4 > Ld_20) Ld_4 = Ld_20;
   if (Ld_12 == 0.01) Ld_4 = NormalizeDouble(Ld_4, 2);
   else Ld_4 = NormalizeDouble(Ld_4, 1);
   return (Ld_4);
}

// 831A28F1E8DF07C553FCD59546465D13
int f0_4() {
   int Li_0;
   int Li_4 = TimeDay(iTime(Symbol(), 0, 0));
   int Li_8 = TimeMonth(iTime(Symbol(), 0, 0));
   int Li_12 = TimeYear(iTime(Symbol(), 0, 0));
   string Ls_16 = StringConcatenate("#", Li_4, Li_8, Li_12);
   int Li_24 = iTime(Symbol(), 0, 0);
   double Ld_28 = f0_16(OP_BUY);
   double Ld_36 = MarketInfo(Symbol(), MODE_ASK);
   if (Gi_168 != Li_24) Li_0 = OrderSend(Symbol(), OP_BUY, Ld_28, Ld_36, Gi_140, 0, 0, Ls_16, 4784563, 0, Blue);
   if (Li_0 == -1) f0_17("Order Buy");
   else Gi_168 = Li_24;
   return (Li_0);
}

// 3068C5A98C003498F1FEC0C489212E8B
int f0_1() {
   int Li_0;
   int Li_4 = TimeDay(iTime(Symbol(), 0, 0));
   int Li_8 = TimeMonth(iTime(Symbol(), 0, 0));
   int Li_12 = TimeYear(iTime(Symbol(), 0, 0));
   string Ls_16 = StringConcatenate("#", Li_4, Li_8, Li_12);
   int Li_24 = iTime(Symbol(), 0, 0);
   double Ld_28 = f0_16(OP_SELL);
   double Ld_36 = MarketInfo(Symbol(), MODE_BID);
   if (Gi_172 != Li_24) Li_0 = OrderSend(Symbol(), OP_SELL, Ld_28, Ld_36, Gi_140, 0, 0, Ls_16, 4784563, 0, Red);
   if (Li_0 == -1) f0_17("Order Sell");
   else Gi_172 = Li_24;
   return (Li_0);
}

// B1588F6D87B6F27F057A9D75B989EFBA
int f0_9(double Ad_0, double Ad_8) {
   int Li_16;
   int Li_20 = TimeDay(iTime(Symbol(), 0, 0));
   int Li_24 = TimeMonth(iTime(Symbol(), 0, 0));
   int Li_28 = TimeYear(iTime(Symbol(), 0, 0));
   string Ls_32 = StringConcatenate("#", Li_20, Li_24, Li_28);
   double Ld_40 = f0_16(OP_BUYSTOP);
   Ad_0 = NormalizeDouble(Ad_0, Digits);
   if (f0_12(OP_BUYSTOP) == 0) Li_16 = OrderSend(Symbol(), OP_BUYSTOP, Ld_40, Ad_0, Gi_140, Ad_8, 0, Ls_32, 4784563, 0, Blue);
   return (Li_16);
}

// 97425EA85E9AFB38C5B5895351450D05
int f0_6(double Ad_0, double Ad_8) {
   int Li_16;
   int Li_20 = TimeDay(iTime(Symbol(), 0, 0));
   int Li_24 = TimeMonth(iTime(Symbol(), 0, 0));
   int Li_28 = TimeYear(iTime(Symbol(), 0, 0));
   string Ls_32 = StringConcatenate("#", Li_20, Li_24, Li_28);
   double Ld_40 = f0_16(OP_SELLSTOP);
   Ad_0 = NormalizeDouble(Ad_0, Digits);
   if (f0_12(OP_SELLSTOP) == 0) Li_16 = OrderSend(Symbol(), OP_SELLSTOP, Ld_40, Ad_0, Gi_140, Ad_8, 0, Ls_32, 4784563, 0, Red);
   return (Li_16);
}

// 958739D014E96B2B944B0A62A781AE1A
void f0_5() {
   if (Digits == 3 || Digits == 5) {
      StopLoss = 10 * StopLoss;
      TakeProfit = 10 * TakeProfit;
      Gi_140 = 10 * Gi_140;
      Gi_144 = 10 * Gi_144;
      TrailingStop = 10 * TrailingStop;
      PipStep = 10 * PipStep;
   }
}

// 0C0FCBE69A575795AB87E4D148518C50
void f0_0() {
   int Li_0;
   int Li_4;
   int Li_8;
   string Ls_12;
   string Ls_20;
   string Ls_28;
   int Li_36;
   int Li_40;
   int Li_44;
   int Li_48;
   bool Li_56;
   bool Li_60;
   if (f0_12(OP_BUYSTOP) > 0 || f0_12(OP_SELLSTOP) > 0) {
      Li_0 = TimeDay(iTime(Symbol(), 0, 0));
      Li_4 = TimeMonth(iTime(Symbol(), 0, 0));
      Li_8 = TimeYear(iTime(Symbol(), 0, 0));
      Ls_12 = StringConcatenate("#", Li_0, Li_4, Li_8);
      Ls_20 = "";
      Ls_28 = "";
      Li_36 = 0;
      Li_40 = 0;
      Li_44 = 0;
      Li_48 = 0;
      for (int Li_52 = 0; Li_52 < OrdersTotal(); Li_52++) {
         if (OrderSelect(Li_52, SELECT_BY_POS, MODE_TRADES)) {
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == 4784563) {
               if (OrderType() == OP_BUYSTOP) {
                  Ls_20 = OrderComment();
                  Li_36 = OrderTicket();
                  if (OrderComment() != Ls_12) Li_44 = OrderTicket();
               }
               if (OrderType() == OP_SELLSTOP) {
                  Ls_28 = OrderComment();
                  Li_40 = OrderTicket();
                  if (OrderComment() != Ls_12) Li_48 = OrderTicket();
               }
            }
         }
      }
      Li_56 = FALSE;
      Li_60 = FALSE;
      for (Li_52 = 0; Li_52 < OrdersTotal(); Li_52++) {
         if (OrderSelect(Li_52, SELECT_BY_POS, MODE_TRADES)) {
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == 4784563) {
               if (OrderType() == OP_BUYSTOP)
                  if (OrderComment() == Ls_28) Li_60 = TRUE;
               if (OrderType() == OP_SELLSTOP)
                  if (OrderComment() == Ls_20) Li_56 = TRUE;
            }
         }
      }
      if (Ls_20 != "" && Li_36 != 0 && (!Li_56)) OrderDelete(Li_36);
      if (Ls_28 != "" && Li_40 != 0 && (!Li_60)) OrderDelete(Li_40);
      if (Li_44 != 0) OrderDelete(Li_44);
      if (Li_48 != 0) OrderDelete(Li_48);
   }
}

// D962D24560A23981DE8820057C748302
void f0_15() {
   double Ld_4;
   double Ld_12;
   int Li_20;
   double Ld_24;
   int Li_32;
   double Ld_36;
   double Ld_44;
   bool Li_52;
   bool Li_56;
   bool Li_60;
   bool Li_64;
   if (f0_12() > 0) {
      Li_20 = MarketInfo(Symbol(), MODE_DIGITS);
      Ld_24 = MarketInfo(Symbol(), MODE_POINT);
      Li_32 = MarketInfo(Symbol(), MODE_STOPLEVEL);
      if (Li_20 % 2 != 0) Li_32 = 10 * Li_32;
      Ld_36 = 0;
      Ld_44 = 0;
      Li_52 = TRUE;
      Li_56 = TRUE;
      Li_60 = FALSE;
      Li_64 = FALSE;
      for (int Li_0 = 0; Li_0 < OrdersTotal(); Li_0++) {
         if (OrderSelect(Li_0, SELECT_BY_POS, MODE_TRADES)) {
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == 4784563) {
               if (OrderType() == OP_BUY) Ld_36 = MathMax(Ld_36, OrderOpenPrice());
               if (OrderType() == OP_SELL) {
                  if (Ld_44 == 0.0) {
                     Ld_44 = OrderOpenPrice();
                     continue;
                  }
                  Ld_44 = MathMin(Ld_44, OrderOpenPrice());
               }
            }
         }
      }
      if (f0_12(OP_BUY) > 1) Li_60 = TRUE;
      if (f0_12(OP_SELL) > 1) Li_64 = TRUE;
      if (Averaging && f0_12(OP_BUY) > 1) Li_52 = FALSE;
      if (Averaging && f0_12(OP_SELL) > 1) Li_56 = FALSE;
      for (Li_0 = 0; Li_0 < OrdersTotal(); Li_0++) {
         if (OrderSelect(Li_0, SELECT_BY_POS, MODE_TRADES)) {
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == 4784563) {
               if (OrderType() == OP_BUY || OrderType() == OP_BUYSTOP) {
                  if (OrderType() == OP_BUY && Averaging && TargetMoney == 0.0) {
                     Ld_12 = MarketInfo(Symbol(), MODE_BID);
                     if (Ld_36 != 0.0 && (Ld_36 - Ld_12) / Ld_24 > Li_32 && Li_60)
                        if (OrderTakeProfit() != Ld_36) OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), Ld_36, 0);
                  }
                  if (Li_52) {
                     if (OrderStopLoss() == 0.0 && StopLoss != 0) OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice() - StopLoss * Point, OrderTakeProfit(), 0);
                     if (OrderTakeProfit() == 0.0 && TakeProfit != 0) OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), OrderOpenPrice() + TakeProfit * Point, 0);
                  }
               }
               if (OrderType() == OP_SELL || OrderType() == OP_SELLSTOP) {
                  if (OrderType() == OP_SELL && Averaging && TargetMoney == 0.0) {
                     Ld_4 = MarketInfo(Symbol(), MODE_ASK);
                     if (Ld_44 != 0.0 && (Ld_4 - Ld_44) / Ld_24 > Li_32 && Li_64)
                        if (OrderTakeProfit() != Ld_44) OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), Ld_44, 0);
                  }
                  if (Li_56) {
                     if (OrderStopLoss() == 0.0 && StopLoss != 0) OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice() + StopLoss * Point, OrderTakeProfit(), 0);
                     if (OrderTakeProfit() == 0.0 && TakeProfit != 0) OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), OrderOpenPrice() - TakeProfit * Point, 0);
                  }
               }
            }
         }
      }
   }
}

// B7E7EECBC4A9A1151CCAE2F9C5AA7B14
void f0_11() {
   double Ld_0;
   double Ld_8;
   double Ld_16;
   double Ld_24;
   int Li_32;
   int Li_36;
   if (Trailing && f0_12() > 0) {
      Ld_0 = MarketInfo(Symbol(), MODE_POINT);
      Li_32 = MarketInfo(Symbol(), MODE_STOPLEVEL);
      Li_36 = MarketInfo(Symbol(), MODE_DIGITS);
      if (Li_36 == 3 || Li_36 == 5) Li_32 = 10 * Li_32;
      if (TrailingStop < Li_32) TrailingStop = Li_32;
      for (int Li_40 = 0; Li_40 < OrdersTotal(); Li_40++) {
         if (OrderSelect(Li_40, SELECT_BY_POS, MODE_TRADES)) {
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == 4784563) {
               if (OrderType() == OP_BUY) {
                  Ld_8 = MarketInfo(Symbol(), MODE_BID);
                  if (Ld_8 - OrderOpenPrice() > TrailingStop * Ld_0) {
                     if (Ld_8 - OrderStopLoss() > TrailingStop * Ld_0) {
                        Ld_16 = Ld_8 - TrailingStop * Ld_0;
                        Ld_24 = MathAbs((Ld_16 - OrderStopLoss()) / Ld_0);
                        if (Ld_16 > OrderStopLoss() && Ld_24 >= 1.0) OrderModify(OrderTicket(), OrderOpenPrice(), Ld_16, OrderTakeProfit(), 0);
                     }
                  }
               }
               if (OrderType() == OP_SELL) {
                  Ld_8 = MarketInfo(Symbol(), MODE_ASK);
                  if (OrderOpenPrice() - Ld_8 > TrailingStop * Ld_0) {
                     if (OrderStopLoss() - Ld_8 > TrailingStop * Ld_0 || OrderStopLoss() == 0.0) {
                        Ld_16 = Ld_8 + TrailingStop * Ld_0;
                        Ld_24 = MathAbs((OrderStopLoss() - Ld_16) / Ld_0);
                        if ((Ld_16 < OrderStopLoss() && Ld_24 >= 1.0) || OrderStopLoss() == 0.0) OrderModify(OrderTicket(), OrderOpenPrice(), Ld_16, OrderTakeProfit(), 0);
                     }
                  }
               }
            }
         }
      }
   }
}

// D43CF0F27808F53715C65F405A5023D1
void f0_14(int Ai_0) {
   bool Li_4 = FALSE;
   double Ld_8 = 0;
   for (int Li_16 = OrdersTotal() - 1; Li_16 >= 0; Li_16--) {
      if (OrderSelect(Li_16, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == 4784563) {
            if (OrderType() == Ai_0) {
               if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
                  if (Ai_0 == OP_BUY) Ld_8 = MarketInfo(Symbol(), MODE_BID);
                  if (Ai_0 == OP_SELL) Ld_8 = MarketInfo(Symbol(), MODE_ASK);
                  Li_4 = OrderClose(OrderTicket(), OrderLots(), Ld_8, Gi_140);
                  if (!(!Li_4)) continue;
                  f0_17(StringConcatenate("Close ", Ai_0));
                  continue;
               }
               OrderDelete(OrderTicket());
            }
         }
      }
   }
}

// 7D12B398B33701BD133AEEEE1BB629A8
void f0_3() {
   double Ld_0;
   if (f0_12(OP_BUY) > 0 || f0_12(OP_SELL) > 0) {
      Ld_0 = 0;
      for (int Li_8 = 0; Li_8 < OrdersTotal(); Li_8++) {
         if (OrderSelect(Li_8, SELECT_BY_POS, MODE_TRADES)) {
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == 4784563)
               if (OrderType() == OP_BUY || OrderType() == OP_SELL) Ld_0 += OrderProfit();
         }
      }
      if (Ld_0 > TargetMoney && TargetMoney > 0.0 && Averaging) Gi_156 = TRUE;
      if (Gi_156) {
         f0_14(OP_BUY);
         f0_14(OP_SELL);
      }
      Gd_160 = Ld_0;
   }
}

// C0C2BA730CFAE5ADCCEC1E46FE96835D
void f0_13() {
   double Ld_8;
   double Ld_0 = MarketInfo(Symbol(), MODE_SPREAD);
   string Ls_16 = "";
   string Ls_24 = "";
   string Ls_32 = "";
   if (Digits % 2 != 0) Ld_0 /= 10.0;
   if (f0_12(OP_BUY) > 0 || f0_12(OP_SELL) > 0) {
      Ld_8 = NormalizeDouble(100.0 * (AccountEquity() / AccountMargin()), 2);
      Ls_24 = StringConcatenate("Margin                  : ", DoubleToStr(Ld_8, 2), "%", 
      "\n");
      Ls_32 = StringConcatenate("CurrentProfit          ", ": $ ", DoubleToStr(Gd_160, 2), 
      "\n");
      if (Averaging && TargetMoney != 0.0) {
         Ls_16 = StringConcatenate("TargetProfit           ", ": $ ", DoubleToStr(TargetMoney, 1), 
         "\n");
      }
   }
   Comment("\n", "Balance                 : $ ", DoubleToStr(NormalizeDouble(AccountBalance(), 2), 2), 
      "\n", "Leverage               : ", AccountLeverage(), 
      "\n", "Spread                  : ", Ld_0, 
   "\n", Ls_24, Ls_16, Ls_32, "-----------------------------------------------");
}
