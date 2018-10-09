
#property copyright "rendy_fx"
#property link      "fxrendy19@yahoo.com"

extern string SetWaktu = "Seting Jam Open";
extern bool UseEntryTime = FALSE;
extern int EntryTime = 3;
extern int EntryMinute = 0;
extern string not = "---------------------";
extern double LOTS = 0.1;
extern int LEVELS = 2;
extern double MAX_LOTS = 1.0;
extern string not1 = "---------------------";
extern bool CONTINUE = TRUE;
extern int INCREMENT = 50;
extern bool MONEY_MANAGEMENT = FALSE;
extern int RISK_RATIO = 2;
extern string not2 = "---------------------";
extern bool UseProfitTarget = FALSE;
extern bool UsePartialProfitTarget = FALSE;
extern int Target_Increment = 50;
extern int First_Target = 50;
extern int MAGIC = 123456;
bool Gi_176 = TRUE;
int Gi_180;

// E37F0136AA3FFAF149B351F6A4C948E9
int init() {
   Gi_180 = First_Target;
   return (0);
}

// 52D46093050F38C27267BCE42543EF60
int deinit() {
   return (0);
}

// EA2B2676C28C0DB26D39331A336C6B92
int start() {
   int Li_0;
   int Li_16;
   int Li_20;
   int Li_24;
   double Ld_68;
   Comment("         UNICORN ATTACK DS9 -DEWA SCAPLER-", 
      "\n         **************************", 
      "\n", "         Equty Akun               :", AccountEquity(), 
      "\n", "         Balance Akun             :", AccountBalance(), 
      "\n", "         Spreed Pair                :", MarketInfo(Symbol(), MODE_SPREAD), 
      "\n", "         Profit Akun                :", AccountEquity() - AccountBalance(), 
      "\n", "         Lot                            :", OrderLots(), 
      "\n", "         Leverange                  :1:", AccountLeverage(), 
      "\n", "         Jam server                : ", Hour(), ": ", Minute(), 
      "\n         **************************", 
   "\n");
   ObjectCreate("HB", OBJ_LABEL, 0, 0, 0);
   ObjectSet("HB", OBJPROP_CORNER, 10);
   ObjectSet("HB", OBJPROP_XDISTANCE, 10);
   ObjectSet("HB", OBJPROP_YDISTANCE, 130);
   ObjectSet("HB", OBJPROP_BACK, TRUE);
   ObjectSetText("HB", "    ROBOT UNICORN ATTACK DS9   ", 14, "Bauhaus 93", Blue);
   ObjectCreate("CC", OBJ_LABEL, 0, 0, 0);
   ObjectSet("CC", OBJPROP_CORNER, 10);
   ObjectSet("CC", OBJPROP_XDISTANCE, 10);
   ObjectSet("CC", OBJPROP_YDISTANCE, 150);
   ObjectSet("CC", OBJPROP_BACK, TRUE);
   ObjectSetText("CC", "       Gunakan Money Management dengan sebaiknya", 8, "Arial", Yellow);
   int Li_12 = 0;
   double Ld_28 = INCREMENT * 2;
   double Ld_36 = 0;
   double Ld_44 = 0;
   double Ld_52 = (Ask - Bid) / Point;
   double Ld_60 = 0;
   if (INCREMENT < MarketInfo(Symbol(), MODE_STOPLEVEL) + Ld_52) INCREMENT = MarketInfo(Symbol(), MODE_STOPLEVEL) + 1.0 + Ld_52;
   if (MONEY_MANAGEMENT) LOTS = NormalizeDouble(AccountBalance() * AccountLeverage() / 1000000.0 * RISK_RATIO, 0) * MarketInfo(Symbol(), MODE_MINLOT);
   if (LOTS < MarketInfo(Symbol(), MODE_MINLOT)) return (0);
   for (int Li_4 = 1; Li_4 < LEVELS; Li_4++) Li_24 += Li_4 * INCREMENT;
   for (Li_4 = 0; Li_4 < OrdersTotal(); Li_4++) {
      OrderSelect(Li_4, SELECT_BY_POS, MODE_TRADES);
      if (OrderMagicNumber() == MAGIC && OrderSymbol() == Symbol()) {
         Li_12++;
         if (!Ld_60) Ld_60 = StrToDouble(OrderComment());
         if (UsePartialProfitTarget && UseProfitTarget && OrderType() < OP_BUYLIMIT) {
            Ld_68 = f0_3(OrderOpenPrice(), OrderType());
            f0_0(Ld_68, OrderTicket());
         }
      }
   }
   if (Li_12 < 1 && Gi_176 && (!UseEntryTime) || (UseEntryTime && Hour() == EntryTime)) {
      if (AccountFreeMargin() < 100.0 * LOTS) return (0);
      Ld_60 = Ask;
      Ld_44 = Ld_60 - (LEVELS + 1) * INCREMENT * Point;
      Ld_36 = Ld_60 + (LEVELS + 1) * INCREMENT * Point;
      for (Li_4 = 1; Li_4 <= LEVELS; Li_4++) {
         OrderSend(Symbol(), OP_BUYSTOP, LOTS, Ld_60 + Li_4 * INCREMENT * Point, 2, Ld_44, Ld_36, DoubleToStr(Ld_60, MarketInfo(Symbol(), MODE_DIGITS)), MAGIC, 0);
         OrderSend(Symbol(), OP_SELLSTOP, LOTS, Ld_60 - Li_4 * INCREMENT * Point, 2, Ld_36 + Ld_52 * Point, Ld_44 + Ld_52 * Point, DoubleToStr(Ld_60, MarketInfo(Symbol(),
            MODE_DIGITS)), MAGIC, 0);
      }
   } else {
      Ld_36 = Ld_60 + INCREMENT * (LEVELS + 1) * Point;
      Ld_44 = Ld_60 - INCREMENT * (LEVELS + 1) * Point;
      Li_12 = OrdersHistoryTotal();
      for (Li_4 = 0; Li_4 < Li_12; Li_4++) {
         OrderSelect(Li_4, SELECT_BY_POS, MODE_HISTORY);
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == MAGIC && StrToDouble(OrderComment()) == Ld_60) {
            f0_1();
            return (0);
         }
      }
      if (UseProfitTarget && f0_2(LOTS, 1, 1, Ld_60) > Ld_28) {
         f0_1();
         return (0);
      }
      Li_16 = f0_2(LOTS, 0, 0, Ld_60);
      Li_20 = f0_2(LOTS, 1, 0, Ld_60);
      if (Li_16 < Ld_28) {
         for (Li_4 = LEVELS; Li_4 >= 1 && Li_16 < Ld_28; Li_4--) {
            if (Ask <= Ld_60 + (Li_4 * INCREMENT - MarketInfo(Symbol(), MODE_STOPLEVEL)) * Point) {
               Li_0 = OrderSend(Symbol(), OP_BUYSTOP, Li_4 * LOTS, Ld_60 + Li_4 * INCREMENT * Point, 2, Ld_44, Ld_36, DoubleToStr(Ld_60, MarketInfo(Symbol(), MODE_DIGITS)), MAGIC,
                  0);
            }
            if (Li_0 > 0) Li_16 += LOTS * (Ld_36 - Ld_60 - Li_4 * INCREMENT * Point) / Point;
         }
      }
      if (Li_20 < Ld_28) {
         for (Li_4 = LEVELS; Li_4 >= 1 && Li_20 < Ld_28; Li_4--) {
            if (Bid >= Ld_60 - (Li_4 * INCREMENT - MarketInfo(Symbol(), MODE_STOPLEVEL)) * Point) {
               Li_0 = OrderSend(Symbol(), OP_SELLSTOP, Li_4 * LOTS, Ld_60 - Li_4 * INCREMENT * Point, 2, Ld_36 + Ld_52 * Point, Ld_44 + Ld_52 * Point, DoubleToStr(Ld_60, MarketInfo(Symbol(),
                  MODE_DIGITS)), MAGIC, 0);
            }
            if (Li_0 > 0) Li_20 += LOTS * (Ld_60 - Li_4 * INCREMENT * Point - Ld_44 - Ld_52 * Point) / Point;
         }
      }
   }
   return (0);
}

// 60BDFA23759F5FF8559327D3409D2C47
int f0_2(double Ad_0, int Ai_8, bool Ai_12, double Ad_16) {
   int Li_24 = 0;
   if (Ai_12) {
      for (int Li_28 = 0; Li_28 < OrdersTotal(); Li_28++) {
         OrderSelect(Li_28, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() == Symbol() && StrToDouble(OrderComment()) == Ad_16) {
            if (OrderType() == OP_BUY) Li_24 += (Bid - OrderOpenPrice()) / Point * OrderLots() / Ad_0;
            if (OrderType() == OP_SELL) Li_24 += (OrderOpenPrice() - Ask) / Point * OrderLots() / Ad_0;
         }
      }
      return (Li_24);
   }
   if (Ai_8 == 0) {
      for (Li_28 = 0; Li_28 < OrdersTotal(); Li_28++) {
         OrderSelect(Li_28, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() == Symbol() && StrToDouble(OrderComment()) == Ad_16) {
            if (OrderType() == OP_BUY) Li_24 += (OrderTakeProfit() - OrderOpenPrice()) / Point * OrderLots() / Ad_0;
            if (OrderType() == OP_SELL) Li_24 -= (OrderStopLoss() - OrderOpenPrice()) / Point * OrderLots() / Ad_0;
            if (OrderType() == OP_BUYSTOP) Li_24 += (OrderTakeProfit() - OrderOpenPrice()) / Point * OrderLots() / Ad_0;
         }
      }
      return (Li_24);
   }
   for (Li_28 = 0; Li_28 < OrdersTotal(); Li_28++) {
      OrderSelect(Li_28, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol() && StrToDouble(OrderComment()) == Ad_16) {
         if (OrderType() == OP_BUY) Li_24 -= (OrderOpenPrice() - OrderStopLoss()) / Point * OrderLots() / Ad_0;
         if (OrderType() == OP_SELL) Li_24 += (OrderOpenPrice() - OrderTakeProfit()) / Point * OrderLots() / Ad_0;
         if (OrderType() == OP_SELLSTOP) Li_24 += (OrderOpenPrice() - OrderTakeProfit()) / Point * OrderLots() / Ad_0;
      }
   }
   return (Li_24);
}

// 5DCE47445D4F52E8FFD379B9E3F710DC
int f0_1() {
   int Li_4 = OrdersTotal();
   for (int Li_0 = 0; Li_0 < Li_4; Li_0++) {
      Sleep(3000);
      OrderSelect(Li_0, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol() && OrderType() > OP_SELL) OrderDelete(OrderTicket());
      else {
         if (OrderSymbol() == Symbol() && OrderType() == OP_BUY) OrderClose(OrderTicket(), OrderLots(), Bid, 3);
         else
            if (OrderSymbol() == Symbol() && OrderType() == OP_SELL) OrderClose(OrderTicket(), OrderLots(), Ask, 3);
      }
   }
   if (!CONTINUE) Gi_176 = FALSE;
   return (1);
}

// 9069BDD57A9D7956EF32D73486F16C6D
double f0_3(double Ad_0, int Ai_8) {
   double Ld_12;
   RefreshRates();
   if (Ai_8 == 1) Ld_12 = NormalizeDouble(Ad_0, Digits) - NormalizeDouble(Ask, Digits);
   else Ld_12 = NormalizeDouble(Bid, Digits) - NormalizeDouble(Ad_0, Digits);
   Ld_12 /= Point;
   return (Ld_12);
}

// 5B6D6C31757D6DE94A5E1D2CD9FC65E1
void f0_0(int Ai_0, int Ai_4) {
   if (OrderSelect(Ai_4, SELECT_BY_TICKET)) {
      if (Ai_0 >= Gi_180 && Ai_0 < Gi_180 + Target_Increment) {
         if (OrderType() == OP_SELL) {
            if (OrderClose(Ai_4, MAX_LOTS, Ask, 3)) {
               Gi_180 += Target_Increment;
               return;
            }
            Print("Error closing order : ", GetLastError());
            return;
         }
         if (OrderClose(Ai_4, MAX_LOTS, Bid, 3)) {
            Gi_180 += Target_Increment;
            return;
         }
         Print("Error closing order : ", GetLastError());
      }
   }
}
