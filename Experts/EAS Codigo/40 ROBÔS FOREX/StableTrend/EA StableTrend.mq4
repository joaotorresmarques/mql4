//#import "MQ4Check.dll"
//   int getKey1();
//#import

extern int Step = 170;
extern double FirstLot = 0.1;
extern double IncLot = 0.0;
extern int Magic = 2008;
extern string PlaceTradesFrom = "00:00";
extern string PlaceTradesTo = "23:59";
extern double MinProfit = 15.0;
extern string MaxLoss = "0=none; 1=pips (position with largest loss); 2=percent (all orders)";
extern int MaxLossMethod = 1;
extern int MaxLossPips = 100;
extern int MaxLossPct = 5;
extern string CloseOr = "Whether to close the forced orders";
extern bool CloseOrder = false;
extern int CountOrders = 0; //Количество ордеров 
extern int AddToStep = 170;


extern bool    UseNewsFilter = false;
extern int     MinsBeforeNews = 60; 
extern int     MinsAfterNews  = 30;
//extern int     NewsImpact = 3;


int dinStepBuy = 0;
int dinStepSell = 0;
double g_ord_lots_144 = 0.0;
double g_ord_lots_152 = 0.0;
double gd_160;
double gd_168;
int gi_176 = 16749022;
int gi_unused_180 = 1774;
color  WevesColor;
 

bool NewsTime;

// // Function to check if it is news time
 void NewsHandling()
 {
     static int PrevMinute = -1;

     if (Minute() != PrevMinute)
     {
         PrevMinute = Minute();
    
         int minutesSincePrevEvent = iCustom(NULL, 0, "FFCal", true, true, false, true, true, 1, 0);
 
         int minutesUntilNextEvent = iCustom(NULL, 0, "FFCal", true, true, false, true, true, 1, 1);
 
         NewsTime = false;
         if ((minutesUntilNextEvent <= MinsBeforeNews) || 
             (minutesSincePrevEvent <= MinsAfterNews))
         {
             NewsTime = true;
         }
     }
 }//newshandling

int start() {
   int li_0;
   
   if (AccountBalance()<0) WevesColor=Red; else WevesColor=Lime;
      ObjectSetText("BALANCE","  BALANCE: "+DoubleToStr(AccountBalance(),2)+" | Available: "+DoubleToStr(AccountFreeMargin(),2),11,"Arial",WevesColor);
      ObjectSetText("Info","  Orders:" + DoubleToStr(OrdersTotal(), 0) + " | TP:" + DoubleToStr(MinProfit, 0) + " | BUY Lot:" + DoubleToStr(g_ord_lots_152,2) + " | SELL Lot:" + DoubleToStr(g_ord_lots_144,2) + " | Mn:" + Magic,9,"Arial",White);

      ObjectCreate("BALANCE", OBJ_LABEL, 0, 0, 0);// Создание объ.
      ObjectSet("BALANCE", OBJPROP_CORNER, 2);      
      ObjectSet("BALANCE", OBJPROP_XDISTANCE, 2 ); 
      ObjectSet("BALANCE", OBJPROP_YDISTANCE, 45);// Координата Y
   
      ObjectCreate("Info", OBJ_LABEL, 0, 0, 0);// Создание объ.
      ObjectSet("Info", OBJPROP_CORNER, 2);      
      ObjectSet("Info", OBJPROP_XDISTANCE, 2 ); 
      ObjectSet("Info", OBJPROP_YDISTANCE, 25);// Координата Y
   
   if (idCheck_unique() != 1) {
      
      if (GetTotalProfit(Magic) >= MinProfit) {
         DeletePendingOrders(Magic);
         CloseOrders(Magic);
      }
      if (MaxLossMethod == 1 && GetMaxLossPips(Magic) >= MaxLossPips) {
         DeletePendingOrders(Magic);
         CloseOrders(Magic);
      } else {
         if (MaxLossMethod == 2 && GetTotalProfit(Magic) <= (-1.0 * AccountBalance()) * MaxLossPct / 100.0) {
            DeletePendingOrders(Magic);
            CloseOrders(Magic);
         }
      }
      GlobalVariableSet("OldBalance", AccountBalance());
      li_0 = MyOrdersTotal(Magic);
      if (!IsInTimeWindow(PlaceTradesFrom, PlaceTradesTo)) {
         if (li_0 > 0) DeletePendingOrders(Magic);
         if (CloseOrder) CloseOrders(Magic); //принудительное закрытие ордеров
         Comment("not in trading window");
      } else {
         Comment("in trading window");
         
         if (UseNewsFilter) { 
               NewsHandling();
               if (NewsTime) {
                  Comment("News range for ",Symbol()," ,work suspended...");
                  DeletePendingOrders(Magic);
                  return;
               }
         }
         
         if (li_0 == 0) {
            OrderSend(Symbol(), OP_BUYLIMIT, FirstLot, Ask - Step * Point, 3, 0, 0, "StableTrend", Magic, 0, Green);
            OrderSend(Symbol(), OP_SELLLIMIT, FirstLot, Bid + Step * Point, 3, 0, 0, "StableTrend", Magic, 0, Red);
         }
         gd_160 = GetLastSellPrice(Magic);
         gd_168 = GetLastBuyPrice(Magic);
         
         if (CountOrders > 0) {
            dinStepBuy = Step + MathCeil(MyOrdersTotalBuy(Magic) / CountOrders) * AddToStep;
            dinStepSell = Step + MathCeil(MyOrdersTotalSell(Magic) / CountOrders) * AddToStep;
         } else {
            dinStepBuy = Step;
            dinStepSell = Step;
         }
         Print(dinStepBuy);
         Print(dinStepSell);
         if (gd_160 - Bid <= 5.0 * Point) OrderSend(Symbol(), OP_SELLLIMIT, g_ord_lots_144 + IncLot, gd_160 + dinStepSell * Point, 3, 0, 0, "StableTrend", Magic, 0, Red);
         if (Ask - gd_168 <= 5.0 * Point) OrderSend(Symbol(), OP_BUYLIMIT, g_ord_lots_152 + IncLot, gd_168 - dinStepBuy * Point, 3, 0, 0, "StableTrend", Magic, 0, Red);
         
         
         //if (gd_160 - Bid <= 5.0 * Point) OrderSend(Symbol(), OP_SELLLIMIT, g_ord_lots_144 + IncLot, gd_160 + Step * Point, 3, 0, 0, "Cable Run", Magic, 0, Red);
         //if (Ask - gd_168 <= 5.0 * Point) OrderSend(Symbol(), OP_BUYLIMIT, g_ord_lots_152 + IncLot, gd_168 - Step * Point, 3, 0, 0, "Cable Run", Magic, 0, Red);
      }
   }
   return (0);
}

int DeletePendingOrders(int a_magic_0) {
     for (int i=OrdersTotal()-1; i>=0; i--) {
         if (!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) break;
         if (OrderMagicNumber() == a_magic_0 && OrderSymbol() == Symbol() && OrderType() == OP_BUYLIMIT || OrderType() == OP_SELLLIMIT) OrderDelete(OrderTicket());
      }
   
   return (0);
}

int CloseOrders(int a_magic_0) {
     for (int i=OrdersTotal()-1; i>=0; i--) {
         if (!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) break;
        if (OrderMagicNumber() == a_magic_0 && OrderSymbol() == Symbol()) {
            if (OrderType() == OP_BUY) OrderClose(OrderTicket(), OrderLots(), Bid, 3);
            if (OrderType() == OP_SELL) OrderClose(OrderTicket(), OrderLots(), Ask, 3);
         }
   }
   return (0);
}

int MyOrdersTotal(int a_magic_0) {
   int l_count_4;
   int l_ord_total_8;
   if (idCheck_unique() != 1) {
      l_count_4 = 0;
      l_ord_total_8 = OrdersTotal();
      for (int l_pos_12 = 0; l_pos_12 < l_ord_total_8; l_pos_12++) {
         OrderSelect(l_pos_12, SELECT_BY_POS, MODE_TRADES);
         if (OrderMagicNumber() == a_magic_0 && OrderSymbol() == Symbol()) l_count_4++;
      }
   }
   return (l_count_4);
}


int MyOrdersTotalBuy(int a_magic_0) {
   int count = 0;
      for (int i = 0; i < OrdersTotal(); i++) {
         OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
         if (OrderMagicNumber() == a_magic_0 && OrderSymbol() == Symbol() && OrderType() == OP_BUY) count++;
      }
   return (count);
}

int MyOrdersTotalSell(int a_magic_0) {
   int count = 0;
      for (int i = 0; i < OrdersTotal(); i++) {
         OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
         if (OrderMagicNumber() == a_magic_0 && OrderSymbol() == Symbol() && OrderType() == OP_SELL) count++;
      }
   return (count);
}


double GetLastBuyPrice(int a_magic_0) {
   int li_4;
      li_4 = OrdersTotal() - 1;
      for (int l_pos_8 = li_4; l_pos_8 >= 0; l_pos_8--) {
         OrderSelect(l_pos_8, SELECT_BY_POS, MODE_TRADES);
         if (OrderMagicNumber() == a_magic_0 && OrderSymbol() == Symbol() && OrderType() == OP_BUYLIMIT || OrderType() == OP_BUY) {
            g_ord_lots_152 = OrderLots();
            return (OrderOpenPrice());
         }
   }
   return (0);
}

double GetLastSellPrice(int a_magic_0) {
   int li_4;
   if (idCheck_unique() != 1) {
      li_4 = OrdersTotal() - 1;
      for (int l_pos_8 = li_4; l_pos_8 >= 0; l_pos_8--) {
         OrderSelect(l_pos_8, SELECT_BY_POS, MODE_TRADES);
         if (OrderMagicNumber() == a_magic_0 && OrderSymbol() == Symbol() && OrderType() == OP_SELLLIMIT || OrderType() == OP_SELL) {
            g_ord_lots_144 = OrderLots();
            return (OrderOpenPrice());
         }
      }
   }
   return (100000);
}

int GetMaxLossPips(int a_magic_0) {
   int li_4;
   int li_8;
   bool li_ret_12;
   if (idCheck_unique() != 1) {
      li_ret_12 = FALSE;
      li_4 = OrdersTotal() - 1;
      for (int l_pos_16 = li_4; l_pos_16 >= 0; l_pos_16--) {
         OrderSelect(l_pos_16, SELECT_BY_POS, MODE_TRADES);
         if (OrderMagicNumber() == a_magic_0 && OrderSymbol() == Symbol() && OrderType() == OP_BUY || OrderType() == OP_SELL) {
            if (OrderType() == OP_BUY) li_8 = Ask - OrderOpenPrice();
            else li_8 = OrderOpenPrice() - Bid;
            if (li_8 < 0 && MathAbs(li_8) > li_ret_12) li_ret_12 = MathAbs(li_8);
         }
      }
   }
   return (li_ret_12);
}

int GetTotalProfit(int a_magic_0) {
   int li_4;
   double ld_ret_8;
   if (idCheck_unique() != 1) {
      ld_ret_8 = 0;
      li_4 = OrdersTotal() - 1;
      for (int l_pos_16 = li_4; l_pos_16 >= 0; l_pos_16--) {
         OrderSelect(l_pos_16, SELECT_BY_POS, MODE_TRADES);
         if (OrderMagicNumber() == a_magic_0 && OrderSymbol() == Symbol() && OrderType() == OP_BUY || OrderType() == OP_SELL) ld_ret_8 += OrderProfit();
      }
   }
   return (ld_ret_8);
}

bool IsInTimeWindow(string as_0, string as_8) {
   string l_time2str_16;
   if (idCheck_unique() != 1) {
      l_time2str_16 = TimeToStr(TimeCurrent(), TIME_MINUTES);
      if (as_8 > as_0) return (l_time2str_16 >= as_0 && l_time2str_16 <= as_8);
   }
   return (l_time2str_16 >= as_0 || l_time2str_16 <= as_8);
}

int idCheck_unique() {
   //if (getKey1() == gi_176) 
   return (0);
   //return (1);
}