//+------------------------------------------------------------------+
//|                                              Trendlord EA v9.mq4 |
//|                                      Copyright © 2010, Ido Kasse |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010, Ido Kasse"
#property link      ""

extern double Lotsize = 0.1;
extern int MagicNumber = 5582;
extern string quittorders = "Close orders when quit EA";
extern bool closeordersonquit = true;
extern string stotals = "Show order totals";
extern bool showtotals = true;
// dayMA en MA kunnen nog verwijderd worden!
int dayMA = 50, MA = 8, existbuy, existsell, ready = 0, gi_92 = 0, gi_96 = 0, buys, sells;
double BarClose, BarOpen, Profit, Trendlord, Heiken_op, Heiken_cl, mysl, g_ibuf_84[], g_ibuf_88[], summ;
string status, ha, trend, avgresult, gghsignal;
//++++ These are adjusted for 5 digit brokers.
double  pips2points,    // slippage  3 pips    3=points    30=points
        pips2dbl;       // Stoploss 15 pips    0.0015      0.00150
int     Digits.pips;    // DoubleToStr(dbl/pips2dbl, Digits.pips)
static datetime barStart;

//KG GGH Signal
void ggh()
{
int li_8;
   double l_ima_20;
   double l_ima_28;
   double l_ima_36;
   double l_ima_44;
   double ld_52;
   double ld_60;
   double ld_unused_12 = 0;
   int li_68 = Bars - 1;
   if (li_68 < 0) return (-1);
   if (li_68 > 0) li_68--;
   int li_0 = Bars - li_68;
   for (int li_4 = 1; li_4 <= li_0; li_4++) {
      li_8 = li_4;
      ld_52 = 0;
      ld_60 = 0;
      for (li_8 = li_4; li_8 <= li_4 + 9; li_8++) ld_60 += MathAbs(High[li_8] - Low[li_8]);
      ld_52 = ld_60 / 10.0;
      l_ima_20 = iMA(NULL, 0, 8, -1, MODE_LWMA, PRICE_TYPICAL, li_4);
      l_ima_36 = iMA(NULL, 0, 8, -1, MODE_LWMA, PRICE_TYPICAL, li_4 + 1);
      l_ima_28 = iMA(NULL, 0, 8, 0, MODE_LWMA, PRICE_TYPICAL, li_4);
      l_ima_44 = iMA(NULL, 0, 8, 0, MODE_LWMA, PRICE_TYPICAL, li_4 + 1);
      g_ibuf_84[li_4] = 0;
      g_ibuf_88[li_4] = 0;
      if (l_ima_20 > l_ima_28 && l_ima_36 < l_ima_44) {
         if (li_4 == 1 && gi_92 == FALSE) {
            gi_92 = TRUE;
            gi_96 = FALSE;
            gghsignal="BUY";               
         }
         g_ibuf_84[li_4] = Low[li_4] - ld_52 / 2.0;
      } else {
         if (l_ima_20 < l_ima_28 && l_ima_36 > l_ima_44) {
            if (li_4 == 1 && gi_96 == FALSE) {
               gi_96 = TRUE;
               gi_92 = FALSE;
               gghsignal="SELL";
            }
            g_ibuf_88[li_4] = High[li_4] + ld_52 / 2.0;
         }
      }
   }

}

//Close buy order
void CloseBuy()
{
int total = OrdersTotal();
for (int cnt = 0 ; cnt < total ; cnt++)
{
OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
if(OrderType()==OP_BUY&& OrderMagicNumber()==MagicNumber)
OrderClose(OrderTicket(),OrderLots(),Bid,NULL, Yellow);
}
existbuy = 0;
}

//Close sell order
void CloseSell()
{
int total = OrdersTotal();
for (int cnt = 0 ; cnt < total ; cnt++)
{
OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
if(OrderType()==OP_SELL&& OrderMagicNumber()==MagicNumber) 
OrderClose(OrderTicket(),OrderLots(),Ask,NULL, Yellow);
}
existsell = 0;
}

//Check for existing orders and count closed orders
void CheckOrders()
{
int total = OrdersTotal();
for (int cnt = 0 ; cnt < total ; cnt++)
{
OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
if(OrderType()==OP_SELL&& OrderMagicNumber()==MagicNumber) existsell = 1;
if(OrderType()==OP_BUY&& OrderMagicNumber()==MagicNumber) existbuy = 1; 
}
}


//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//----
   if (Digits == 5 || Digits == 3)
   {    // Adjust for five (5) digit brokers.
               pips2dbl    = Point*10; pips2points = 10;   Digits.pips = 1;
   } else {    pips2dbl    = Point;    pips2points =  1;   Digits.pips = 0; }
   
   ObjectCreate("today", OBJ_LABEL, 0, 0, 0);
   ObjectSet("today", OBJPROP_CORNER, 1);
   ObjectSet("today", OBJPROP_XDISTANCE, 15);
   ObjectSet("today", OBJPROP_YDISTANCE, 15);
   
   ObjectCreate("magic", OBJ_LABEL, 0, 0, 0);
   ObjectSet("magic", OBJPROP_CORNER, 1);
   ObjectSet("magic", OBJPROP_XDISTANCE, 15);
   ObjectSet("Magic", OBJPROP_YDISTANCE, 35);
   
   ObjectCreate("lot", OBJ_LABEL, 0, 0, 0);
   ObjectSet("lot", OBJPROP_CORNER, 1);
   ObjectSet("lot", OBJPROP_XDISTANCE, 15);
   ObjectSet("lot", OBJPROP_YDISTANCE, 55);

   ObjectCreate("trend", OBJ_LABEL, 0, 0, 0);
   ObjectSet("trend", OBJPROP_CORNER, 1);
   ObjectSet("trend", OBJPROP_XDISTANCE, 15);
   ObjectSet("trend", OBJPROP_YDISTANCE, 95);
   
   ObjectCreate("ha", OBJ_LABEL, 0, 0, 0);
   ObjectSet("ha", OBJPROP_CORNER, 1);
   ObjectSet("ha", OBJPROP_XDISTANCE, 15);
   ObjectSet("ha", OBJPROP_YDISTANCE,115);
   
   if (showtotals==true){
   ObjectCreate("history", OBJ_LABEL, 0, 0, 0);
   ObjectSet("history", OBJPROP_CORNER, 1);
   ObjectSet("history", OBJPROP_XDISTANCE, 15);
   ObjectSet("history", OBJPROP_YDISTANCE, 225);
   
   ObjectCreate("total", OBJ_LABEL, 0, 0, 0);
   ObjectSet("total", OBJPROP_CORNER, 3);
   ObjectSet("total", OBJPROP_XDISTANCE, 15);
   ObjectSet("total", OBJPROP_YDISTANCE, 100);
   ObjectSetText("total","TOTAL P/L", 30, "Arial Bold", Silver);
   
   ObjectCreate("summ", OBJ_LABEL, 0, 0, 0);
   ObjectSet("summ", OBJPROP_CORNER, 3);
   ObjectSet("summ", OBJPROP_XDISTANCE, 15);
   ObjectSet("summ", OBJPROP_YDISTANCE, 50);
   }
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   ObjectDelete("trend");
   ObjectDelete("ha");
   ObjectDelete("order");
   ObjectDelete("today");
   ObjectDelete("pl");
   ObjectDelete("magic");
   ObjectDelete("lot");
   ObjectDelete("bid");
   if (showtotals==true) ObjectDelete("summ");
   if (showtotals==true) ObjectDelete("total");
   if (showtotals==true) ObjectDelete("history");
   if (closeordersonquit==true) { CloseBuy(); CloseSell(); }
   if (closeordersonquit==false) Alert("Existing orders remain open!"); 
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
//----
   if (barStart < Time[0]) //start of new bar 
   {
   barStart = Time[0];
   
   ObjectSetText("today", StringConcatenate("", TimeToStr(CurTime())), 10, "Arial Bold", Silver);
   ObjectSetText("magic", "MagicNumber= " + MagicNumber, 10, "Arial Bold", Silver);
   ObjectSetText("lot", "Lotsize= " + (DoubleToStr(Lotsize,2)), 10, "Arial Bold", Silver);
   
   Trendlord=iMA(NULL,1440,50,0,MODE_EMA,PRICE_CLOSE,1);
   BarClose=iClose(NULL,1440,1);
   BarOpen=iOpen(NULL,1440,1);
   if (BarClose < Trendlord) trend="DOWN";
   if (BarClose > Trendlord) trend="UP";
   if (trend=="DOWN") ObjectSetText("trend", "Trend = Down", 13, "Arial Bold", Red);
   if (trend=="UP") ObjectSetText("trend", "Trend = Up", 13, "Arial Bold", Green);
   
   Heiken_op = iCustom(NULL,0,"Heiken Ashi",Red,White,Red,White,2,1);
   Heiken_cl = iCustom(NULL,0,"Heiken Ashi",Red,White,Red,White,3,1);
   if (Heiken_op < Heiken_cl) ha ="UP";
   if (Heiken_op > Heiken_cl) ha ="DOWN";
   if (ha=="DOWN") ObjectSetText("ha", "Heiken Ashi = Down", 13, "Arial Bold", Red);
   if (ha=="UP") ObjectSetText("ha", "Heiken Ashi = Up", 13, "Arial Bold", Green);
   
   double HI2 = iHigh(NULL,1440,0);
   double LOW2 = iLow(NULL,1440,0); 
   double HI3 = iHigh(NULL,1440,1);
   double LOW3 = iLow(NULL,1440,1);
   double HI4 = iHigh(NULL,1440,0);
   double LOW4 = iLow(NULL,1440,0);
   double HI5 = iHigh(NULL,1440,2);
   double LOW5 = iLow(NULL,1440,2);
   double HI6 = iHigh(NULL,1440,3);
   double LOW6 = iLow(NULL,1440,3);
   double HI7 = iHigh(NULL,1440,4);
   double LOW7 = iLow(NULL,1440,4);
   double HI8 = iHigh(NULL,1440,5);
   double LOW8 = iLow(NULL,1440,5);
   double HI9 = iHigh(NULL,1440,6);
   double LOW9 = iLow(NULL,1440,6);
   double HI10 = iHigh(NULL,1440,7);
   double LOW10 = iLow(NULL,1440,7);
   double HI11 = iHigh(NULL,1440,8);
   double LOW11 = iLow(NULL,1440,8);
   double HI12 = iHigh(NULL,1440,9);
   double LOW12 = iLow(NULL,1440,9);
   double HI13 = iHigh(NULL,1440,10);
   double LOW13 = iLow(NULL,1440,10);
   double HI14 = iHigh(NULL,1440,11);
   double LOW14 = iLow(NULL,1440,11);
   double HI15 = iHigh(NULL,1440,12);
   double LOW15 = iLow(NULL,1440,12);
   double HI16 = iHigh(NULL,1440,13);
   double LOW16 = iLow(NULL,1440,13);
   double HI17 = iHigh(NULL,1440,14);
   double LOW17 = iLow(NULL,1440,14);
   double HI18 = iHigh(NULL,1440,15);
   double LOW18 = iLow(NULL,1440,15);
   double HI19 = iHigh(NULL,1440,16);
   double LOW19 = iLow(NULL,1440,16);
   double HI20 = iHigh(NULL,1440,17);
   double LOW20 = iLow(NULL,1440,17);
   double HI21 = iHigh(NULL,1440,18);
   double LOW21 = iLow(NULL,1440,18);
   double HI22 = iHigh(NULL,1440,19);
   double LOW22 = iLow(NULL,1440,19);
   double HI23 = iHigh(NULL,1440,20);
   double LOW23 = iLow(NULL,1440,20);
  
   double OPEN = iOpen(NULL,1440,0);
   double CLOSE = iClose(NULL,1440,0);
  
   double ONE = (HI3-LOW3)/2;
  
   double FIVE = ((HI3-LOW3)+(HI5-LOW5)+(HI6-LOW6)+(HI7-LOW7)+(HI8-LOW8))/10;
                   
                
   double TEN = ((HI3-LOW3)+(HI5-LOW5)+(HI6-LOW6)+(HI7-LOW7)+(HI8-LOW8)+
                  (HI9-LOW9)+(HI10-LOW10)+(HI11-LOW11)+(HI12-LOW12)+(HI13-LOW13))/20;
                    
   double TWENTY = ((HI3-LOW3)+(HI5-LOW5)+(HI6-LOW6)+(HI7-LOW7)+(HI8-LOW8)+
               (HI9-LOW9)+(HI10-LOW10)+(HI11-LOW11)+(HI12-LOW12)+(HI13-LOW13)+
               (HI14-LOW14)+(HI15-LOW15)+(HI16-LOW16)+(HI17-LOW17)+(HI18-LOW18)+
               (HI19-LOW19)+(HI20-LOW20)+(HI21-LOW21)+(HI22-LOW22)+(HI23-LOW23))/40; 
                                             
   double AV2 = ((FIVE+TEN+TWENTY)/3)*20000;
   avgresult=(DoubleToStr(AV2,0));
   mysl=(NormalizeDouble(AV2,0)/2);
   
   if (ready==0) ObjectSetText("order","Waiting for signal", 13, "Arial Bold", Silver);
   if (ready==1) {
   ObjectCreate("order", OBJ_LABEL, 0, 0, 0);
   ObjectSet("order", OBJPROP_CORNER, 1);
   ObjectSet("order", OBJPROP_XDISTANCE, 15);
   ObjectSet("order", OBJPROP_YDISTANCE, 155);
   
   ObjectCreate("bid", OBJ_LABEL, 0, 0, 0);
   ObjectSet("bid", OBJPROP_CORNER, 1);
   ObjectSet("bid", OBJPROP_XDISTANCE, 15);
   ObjectSet("bid", OBJPROP_YDISTANCE, 175);
   
   ObjectCreate("pl", OBJ_LABEL, 0, 0, 0);
   ObjectSet("pl", OBJPROP_CORNER, 1);
   ObjectSet("pl", OBJPROP_XDISTANCE, 15);
   ObjectSet("pl", OBJPROP_YDISTANCE, 195);
   }
   
   ggh();
   CheckOrders();
   
   //find 1st sell signal
   if (BarOpen > Trendlord&& BarClose < Trendlord&& (ready==0)&& (ha=="DOWN")) 
   {
   ready=1;
   CloseBuy();
   OrderSend(Symbol(),OP_SELL,Lotsize,Bid,50,Bid+mysl*pips2dbl,NULL,NULL,MagicNumber,0,Red);
   Print("ADR= ", avgresult," with trend= ", trend, ", Stoploss= ",mysl);
   }
   
   //find 1st buy signal
   if (BarOpen < Trendlord&& BarClose > Trendlord&& (ready==0)&& (ha=="UP")) 
   {
   ready=1;
   CloseSell();
   OrderSend(Symbol(),OP_BUY,Lotsize,Ask,50,Ask-mysl*pips2dbl,NULL,NULL,MagicNumber,0,Blue);
   Print("ADR= ", avgresult," with trend= ", trend, ", Stoploss= ",mysl);
   }
   
   if (BarOpen > Trendlord&& BarClose < Trendlord&& existbuy==1&& ready==1&& (ha=="DOWN")) 
   {
   CloseBuy();
   ready=0;
   }
   
   if (BarOpen < Trendlord&& BarClose > Trendlord&& existsell==1&& ready==1&& (ha=="UP")) 
   {
   CloseSell();
   ready=0;
   } 
   
   if (existsell==1&& ready==1&& gghsignal=="BUY") 
   {
   ready=0;
   gghsignal="NONE";
   CloseSell();
   Print("Closed by GGH Signal");
   } 
   
   if (existbuy==1&& ready==1&& gghsignal=="SELL") 
   {
   ready=0;
   gghsignal="NONE";
   CloseBuy();
   Print("Close by GGH Signal");
   }
   }
   
   int total = OrdersTotal();
   for (int cnt = 0 ; cnt < total ; cnt++)
   {
      OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
      if(OrderType()==OP_SELL&& OrderMagicNumber()==MagicNumber) 
      {
         if (ready==1){
         ObjectSetText("order","SELL order active", 13, "Arial Bold", Red);
         Profit=OrderProfit()+OrderSwap();
         if (Profit>0) ObjectSetText("pl","Order P/L= " + (DoubleToStr(Profit,2)), 22, "Arial Bold", Green);
         if (Profit<0) ObjectSetText("pl","Order P/L= " + (DoubleToStr(Profit,2)), 22, "Arial Bold", Red);
         if (Profit==0) ObjectSetText("pl","Order P/L= " + (DoubleToStr(Profit,2)), 22, "Arial Bold", Silver);
         ObjectSetText("bid","@ " + DoubleToStr(OrderOpenPrice(),2), 9, "Arial Bold", Silver);}
      }
      if(OrderType()==OP_BUY&& OrderMagicNumber()==MagicNumber) 
      {
         if (ready==1){
         ObjectSetText("order","BUY order active", 13, "Arial Bold", Green);
         Profit=OrderProfit()+OrderSwap();
         if (Profit>0) ObjectSetText("pl","Order P/L= " + (DoubleToStr(Profit,2)), 22, "Arial Bold", Green);
         if (Profit<0) ObjectSetText("pl","Order P/L= " + (DoubleToStr(Profit,2)), 22, "Arial Bold", Red);
         if (Profit==0) ObjectSetText("pl","Order P/L= " + (DoubleToStr(Profit,2)), 22, "Arial Bold", Silver);
         ObjectSetText("bid","@ " + DoubleToStr(OrderOpenPrice(),5), 9, "Arial Bold", Silver);}
      }
   }

   if (showtotals==true){
   static int closedOrders=0;
   if(OrdersHistoryTotal()!=closedOrders)
   {
      closedOrders=OrdersHistoryTotal();
      int hstTotal = OrdersHistoryTotal(); 
      for (int i = 0 ; i < hstTotal ; i++)
      {   
         if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY) && OrderMagicNumber()==MagicNumber&& OrderType()==OP_BUY) buys++;
         if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY) && OrderMagicNumber()==MagicNumber&& OrderType()==OP_SELL) sells++;
         if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY) && OrderMagicNumber()==MagicNumber&& OrderProfit()>=0) summ+=OrderProfit();
         if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY) && OrderMagicNumber()==MagicNumber&& OrderProfit()<0) summ+=OrderProfit();
         ObjectSetText("history","Closed orders: " + buys + " BUY / " + sells + " SELL", 10, "Arial Bold", Silver);
         if (summ>0) ObjectSetText("summ","" + DoubleToStr(summ,2), 30, "Arial Bold", Green);
         if (summ<0) ObjectSetText("summ","" + DoubleToStr(summ,2), 30, "Arial Bold", Red);
         if (summ==0) ObjectSetText("summ","" + DoubleToStr(summ,2), 30, "Arial Bold", Silver);
      }
   }
   }
   
//----
   return(0);
  }
//+------------------------------------------------------------------+