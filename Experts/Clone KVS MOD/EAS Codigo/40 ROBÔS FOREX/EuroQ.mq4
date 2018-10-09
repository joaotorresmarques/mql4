
//====================================================================================================================== 
#property copyright "Copyright © 2013, euronis-free.com"
#property link      "http://euronis-free.com"

extern string tx2="General Configuration Advisor";
extern bool Info=true;
extern bool ShowZeroLevels=true;
extern bool UseVTP=true;
extern bool ManualTrade=false;
extern bool DynamicTP=true;
extern bool UseNewBar=true;
extern int magicbuy=0;
extern int magicsell=0;
extern string tx4="Hours adviser";
extern int StartHour=21;
extern int EndHour=4;
extern string tx1="Settings MoneyManagement";
extern bool UseMM=true;
extern double min_lot=0.1;
extern int MaxTrades=10;
extern int UseMoney=50;
extern int SL_Level=40;
extern bool DrawdownStop=false;
extern string tx6="Basic settings";
extern int step=25;
extern double Step_coef=1;
extern int TP=15;
extern int TP2from=6;
extern int TP2=3;
extern int TPstep=2;
extern int Tral_Size=5;
extern double mult=1.4;
extern int slippage=3;
extern string tx5="Forced closing of the series";
extern bool buyclose=false;
extern bool sellclose=false;
extern string s="Indicator settings Stochastic";
extern int StochTime=5;
extern int per_K=10;
extern int per_D=3;
extern int slow=3;
extern int S_Mode=0;
extern int S_Price=0;
extern int zoneBUY=15;
extern int zoneSELL=85;


int cnt,cu,ticketbuy,ticketsell,dig;
double lotsbuy,lotssell,openpricebuy,openpricesell,lotsbuy2,lotssell2,lastlotbuy,lastlotsell,tpb,tps,mtpb,mtps,
free,balance,ztpb,ztps;
color col,colB,colS;
string txt1,txt2,txt3,txtVTP;
datetime NewBar_B,NewBar_S;


//====================================================================================================================== 
                                                 
                                                 int start() { if(AccountNumber() !=123456) {Comment("No license for your account. Write on support@euronis-free.com"); return(0);}
  double profitbuy=0;
  double profitsell=0;
  string symbol = Symbol();
  double TV=MarketInfo(Symbol(),MODE_TICKVALUE);
  double LOTStep = MarketInfo(Symbol(),MODE_LOTSTEP);
  double minLot = MarketInfo(Symbol(),MODE_MINLOT);
  double spread = MarketInfo(Symbol(),MODE_SPREAD);
  if (Digits==4 || Digits==2) cu=1; else cu=10;   // множитель для разных типов счетов 4/2 и 5/3
  if (LOTStep==0.01)dig=2;
  if (LOTStep==0.1) dig=1;
  int tral=Tral_Size*cu;
  int totb=Total_B();
  int tots=Total_S();
  double TPsell,TPbuy,smbuy,smsell;
  if (totb==0) {profitbuy=0;ticketbuy=0;tpb=0; mtpb=0;ztpb=0;smbuy=0;}
  if (tots==0) {profitsell=0;ticketsell=0;tps=0; mtps=0;ztps=0;smsell=0;}
  if (totb<TP2from) TPbuy=TP*cu; else TPbuy=TP2*cu;
  if (tots<TP2from) TPsell=TP*cu; else TPsell=TP2*cu;
  if (DynamicTP) 
      {
      if (totb<TP2from) TPbuy+=(totb-1)*TPstep*cu; 
      if (tots<TP2from) TPsell+=(tots-1)*TPstep*cu;
      }

//==================================================== Вход по стохастику ==============================================
  if(totb==0 && time())
      { 
      tpb=0;ticketbuy=0;
      if (Stochastic("buy") && !buyclose && !ManualTrade)
         {
         if (UseMM) lotsbuy=MM(mult,UseMoney,MaxTrades,step);
         else lotsbuy=min_lot;
         if (lotsbuy<minLot) {TradeStop(); return;}
         RefreshRates();
         OrderSend(symbol,OP_BUY,NormalizeDouble(lotsbuy,dig),NormalizeDouble(Ask,Digits),slippage*cu,0,0,totb+1+" order Buy",magicbuy,0,Blue); NewBar_B=Time[0];
         }
      }

  if(tots==0 && time())
      {
      tps=0;ticketsell=0;
      if (Stochastic("sell") && !sellclose && !ManualTrade)
         {
         if (UseMM) lotssell=MM(mult,UseMoney,MaxTrades,step);
         else lotssell=min_lot;
         if (lotssell<minLot) {TradeStop(); return;}
         RefreshRates();
         OrderSend(symbol,OP_SELL,NormalizeDouble(lotssell,dig),NormalizeDouble(Bid,Digits),slippage*cu,0,0,tots+1+" order Sell",magicsell,0,Red); NewBar_S=Time[0];
         }
      }

//====================================================================================================================== 

  if(totb>0)
  {

    
  for (cnt=0;cnt<OrdersTotal();cnt++)
    {
    OrderSelect(cnt,SELECT_BY_POS, MODE_TRADES);
    if (OrderSymbol() == symbol && OrderType() == OP_BUY && OrderMagicNumber()==magicbuy) 
      {
      ticketbuy = OrderTicket();OrderSelect(ticketbuy,SELECT_BY_TICKET, MODE_TRADES);
      smbuy+=OrderLots();openpricebuy = OrderOpenPrice();lastlotbuy = OrderLots(); profitbuy+=OrderProfit()+OrderCommission()+OrderSwap();
      }
    }
   
   tpb = NormalizeDouble(Bid+((0-profitbuy)/(smbuy*TV)+TPbuy)*Point,Digits);
   if (profitbuy<0)mtpb=tpb;
   ztpb = tpb-TPbuy*Point;



  
        if ((UseNewBar && NewBar_B!=Time[0]) || !UseNewBar) if(Ask<=openpricebuy-MathFloor(step*MathPow(Step_coef,totb-1)*cu)*Point && totb<MaxTrades)
          {

          lotsbuy2=lastlotbuy*mult; NewBar_B=Time[0];
            
            if (AccountFreeMarginCheck(symbol,OP_BUY,lotsbuy2)>0)
            {
            RefreshRates();
            OrderSend(symbol,OP_BUY,NormalizeDouble(lotsbuy2,dig),NormalizeDouble(Ask,Digits),slippage*cu,0,0,totb+1+" order Buy",magicbuy,0,Blue);
            }
            
          }
      
   }

//======================================================================================================================

  if(tots>0)
  {


  for (cnt=0;cnt<OrdersTotal();cnt++)
    {
    OrderSelect(cnt,SELECT_BY_POS, MODE_TRADES);
    if (OrderSymbol() == symbol && OrderType() == OP_SELL && OrderMagicNumber()==magicsell)
      {
      ticketsell = OrderTicket();OrderSelect(ticketsell,SELECT_BY_TICKET, MODE_TRADES);
      smsell+=OrderLots();openpricesell = OrderOpenPrice();lastlotsell = OrderLots(); profitsell+=OrderProfit()+OrderCommission()+OrderSwap();
      }     
    }

   tps = NormalizeDouble(Ask-((0-profitsell)/(smsell*TV)+TPsell)*Point,Digits);
   if (profitsell<0)mtps=tps;
   ztps = tps+TPsell*Point;


        if ((UseNewBar && NewBar_B!=Time[0]) || !UseNewBar) if(Bid>=openpricesell+MathFloor(step*MathPow(Step_coef,tots-1)*cu)*Point && tots<MaxTrades)
          {
          lotssell2=lastlotsell*mult; NewBar_S=Time[0];
         
            if (AccountFreeMarginCheck(symbol,OP_SELL,lotssell2)>0)
            {
            RefreshRates();
            OrderSend(symbol,OP_SELL,NormalizeDouble(lotssell2,dig),NormalizeDouble(Bid,Digits),slippage*cu,0,0,tots+1+" order Sell",magicsell,0,Red);
            }

          }
      
   }

//====================================== модуль выставления ТейкПрофита ================================================
if (!UseVTP) {
for (cnt = OrdersTotal() - 1; cnt >= 0; cnt--)

    {
    if (!OrderSelect(cnt,SELECT_BY_POS, MODE_TRADES)) continue;
    if (OrderSymbol() != symbol) continue;

    if (OrderType() == OP_BUY && OrderMagicNumber()==magicbuy) 
      {
      if (MathAbs((OrderTakeProfit()-tpb)/Point)>cu) 
      OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),NormalizeDouble(tpb,Digits),0);

      }
    if (OrderType() == OP_SELL && OrderMagicNumber()==magicsell) 
      {
      if (MathAbs((OrderTakeProfit()-tps)/Point)>cu)
      OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),NormalizeDouble(tps,Digits),0);            

      }
    }
}

//======================================================================================================================
if (UseVTP) {
if (totb>0 && Bid>tpb)
   {
   if (Bid<=NormalizeDouble(mtpb,Digits))closeBUYorders();
   else if (mtpb<(Bid-tral*Point)) mtpb=NormalizeDouble(Bid-tral*Point,Digits);
   }
if (tots>0 && Ask<tps)
   {
   if (Ask>=NormalizeDouble(mtps,Digits))closeSELLorders();
   else if (mtps>(Ask+tral*Point)) mtps=NormalizeDouble(Ask+tral*Point,Digits);
   }
}
//======================================================================================================================  
if (totb>0) {if (MathAbs(mtpb-tpb)>Point)colB=Yellow;else colB=Blue;}
if (tots>0) {if (MathAbs(mtps-tps)>Point)colS=Yellow;else colS=Red;}
//======================================================================================================================

if (buyclose && Total_B()!=0)closeBUYorders();
if (sellclose && Total_S()!=0)closeSELLorders();

if (DrawdownStop && AccountEquity()<AccountBalance()*(100-SL_Level)/100) {closeBUYorders(); closeSELLorders();}

//======================================================================================================================
   
  free = AccountFreeMargin();balance = AccountBalance();
  
if(Info && (!IsTesting() || IsVisualMode()))
  { //изменение цвета при уменьшении "СРЕДСТВА" относительно "БАЛАНС"
    int Balans = NormalizeDouble( AccountBalance(),0);
    int Sredstva = NormalizeDouble(AccountEquity(),0);  
    if (Sredstva >= Balans/6*5) col = DodgerBlue; 
    if (Sredstva >= Balans/6*4 && Sredstva < Balans/6*5)col = DeepSkyBlue;
    if (Sredstva >= Balans/6*3 && Sredstva < Balans/6*4)col = Gold;
    if (Sredstva >= Balans/6*2 && Sredstva < Balans/6*3)col = OrangeRed;
    if (Sredstva >= Balans/6   && Sredstva < Balans/6*2)col = Crimson;
    if (Sredstva <  Balans/5                           )col = Red;
   //------------------------- 
ObjectDelete("Lable1");
ObjectCreate("Lable1",OBJ_LABEL,0,0,1.0);
   ObjectSet("Lable1", OBJPROP_CORNER, 3);
   ObjectSet("Lable1", OBJPROP_XDISTANCE, 10);
   ObjectSet("Lable1", OBJPROP_YDISTANCE, 31);
   txt1=(DoubleToStr(AccountBalance(), 0));
   ObjectSetText("Lable1","BALANCE     "+txt1+"",12,"Times New Roman",DodgerBlue);
   //-------------------------   
ObjectDelete("Lable2");
ObjectCreate("Lable2",OBJ_LABEL,0,0,1.0);
   ObjectSet("Lable2", OBJPROP_CORNER, 3);
   ObjectSet("Lable2", OBJPROP_XDISTANCE, 10);
   ObjectSet("Lable2", OBJPROP_YDISTANCE, 11);
   txt2=(DoubleToStr(AccountEquity(), 0));
   ObjectSetText("Lable2","EQUITY     "+txt2+"",12,"Times New Roman",col);
  
  string spips; 
  int pips;
  if (MathAbs(smbuy-smsell)>0) pips=NormalizeDouble(AccountEquity()/MathAbs(smbuy-smsell)/TV,0);
  if (smbuy>smsell) spips="Prior to loss "+pips+" pips down";
  if (smbuy<smsell) spips="Prior to loss "+pips+" pips up";
  if (smbuy==smsell) {if (smbuy==0) spips="No orders"; else spips="Lock";}
if (UseVTP) txtVTP="Mode VTP enabled."; 
       else txtVTP="Mode VTP disabled.";
  Comment(
  "\n"," "+txtVTP,
  "\n"," Maximum lot = ",NormalizeDouble(MarketInfo(Symbol(),MODE_MAXLOT),dig), 
  "\n"," Price pips (1lot) = ",TV,
  "\n"," Leverage = 1:",AccountLeverage(),
  "\n"," Modifier lot = ",mult,
  "\n"," Trailing Stop = ",tral, "\n",
  "---------------------------------------------------------------",
  "\n"," Orders Buy = ",Total_B(),"  Total volume = ",smbuy,
  "\n"," TakeProfit Buy= ",tpb,
  "\n"," Profit Buy = ",profitbuy,"\n",
  "---------------------------------------------------------------",
  "\n"," Orders Sell = ",Total_S(),"  Total volume = ",smsell,
  "\n"," TakeProfit Sell= ",tps,
  "\n"," Profit Sell = ",profitsell,  "\n",
  "---------------------------------------------------------------","\n",
  "\n"," "+spips);
  
  }

//======================================================================================================================
   if (!IsTesting() || IsVisualMode()) 
   {
   ObjectDelete("SellTP");
   ObjectDelete("BuyTP");
   ObjectDelete("SellZeroLevel");
   ObjectDelete("BuyZeroLevel");

   if (UseVTP) 
      {
      ObjectCreate("SellTP",OBJ_HLINE, 0, 0,mtps-spread*Point);
      ObjectSet("SellTP", OBJPROP_COLOR, colS);
      ObjectSet("SellTP", OBJPROP_WIDTH, 2);
      ObjectSet("SellTP", OBJPROP_RAY, False);
  
      ObjectCreate("BuyTP",OBJ_HLINE, 0, 0,mtpb);
      ObjectSet("BuyTP", OBJPROP_COLOR, colB);
      ObjectSet("BuyTP", OBJPROP_WIDTH, 2);
      ObjectSet("BuyTP", OBJPROP_RAY, False);
      }

   if (ShowZeroLevels) 
      {
      ObjectCreate("SellZeroLevel",OBJ_HLINE, 0, 0,ztps-spread*Point);
      ObjectSet("SellZeroLevel", OBJPROP_COLOR, Red);
      ObjectSet("SellZeroLevel", OBJPROP_WIDTH, 0);
      ObjectSet("SellZeroLevel", OBJPROP_RAY, False);

      ObjectCreate("BuyZeroLevel",OBJ_HLINE, 0, 0,ztpb);
      ObjectSet("BuyZeroLevel", OBJPROP_COLOR, Blue);
      ObjectSet("BuyZeroLevel", OBJPROP_WIDTH, 0);
      ObjectSet("BuyZeroLevel", OBJPROP_RAY, False);
      }
   }

return(0);
}  

//====================================================== Функции =======================================================

                                bool time()
 {
   if (StartHour<EndHour) 
      {if (Hour()>=StartHour && Hour()<EndHour) return(true); else return(false);}
   if (StartHour>EndHour) 
      {if (Hour()>=EndHour && Hour()<StartHour) return(false); else return(true);}
 }
//======================================================================================================================
                                int Total_B()                   
 {
   int j,r;
   for (r=0;r<OrdersTotal();r++) {
     if(OrderSelect(r,SELECT_BY_POS,MODE_TRADES) && OrderSymbol() == Symbol() && OrderType()==OP_BUY  && OrderMagicNumber()==magicbuy) j++;
   }   
 return(j); 
 }
//======================================================================================================================
                                int Total_S()
{
   int d,n;
   for (n=0;n<OrdersTotal();n++) {
     if(OrderSelect(n,SELECT_BY_POS,MODE_TRADES)  && OrderSymbol() == Symbol() && OrderType()==OP_SELL && OrderMagicNumber()==magicsell) d++;
   }    
 return(d);
  }     
//======================================================================================================================

                                 bool Stochastic (string SMode)
{
   double sM0 = iStochastic(Symbol(),StochTime,per_K,per_D,slow,S_Mode,S_Price,MODE_MAIN,0);
   double sM1 = iStochastic(Symbol(),StochTime,per_K,per_D,slow,S_Mode,S_Price,MODE_MAIN,1);
   double sS0 = iStochastic(Symbol(),StochTime,per_K,per_D,slow,S_Mode,S_Price,MODE_SIGNAL,0);
   double sS1 = iStochastic(Symbol(),StochTime,per_K,per_D,slow,S_Mode,S_Price,MODE_SIGNAL,1);
   if (SMode=="buy" && sS0<zoneBUY && sM0<zoneBUY && sM1<sS1 && sM0>=sS0) return(true);
   if (SMode=="sell" && sS0>zoneSELL && sM0>zoneSELL && sM1>sS1 && sM0<=sS0) return(true);
   return(false);
}


//======================================================================================================================

                                    void closeBUYorders()
{
  while(Total_B()>0)
   {
   for (cnt=OrdersTotal()-1;cnt>=0;cnt--)
      {
      OrderSelect(cnt,SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol() && OrderType() == OP_BUY && OrderMagicNumber()==magicbuy)
         {
         RefreshRates();OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(Bid,Digits),slippage*cu,Blue);
         }
      }
   }
}

//======================================================================================================================
                                    void closeSELLorders()
{
  while(Total_S()>0)
   {
   for (cnt=OrdersTotal()-1;cnt>=0;cnt--)
      {
      OrderSelect(cnt,SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol() && OrderType() == OP_SELL && OrderMagicNumber()==magicsell)
         {
         RefreshRates();OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(Ask,Digits),slippage*cu,Red);
         }
      }
   }
}

//====================================================== блок ММ =======================================================
   double MM(double mult1, int UM, int MaxTrades1,int step1) 
      {
      double trade_vol=1;
      double sum_vol=1;
      double MaxDrawdown;
      double maxLot=MarketInfo(Symbol(),MODE_MAXLOT);
      double minLot=MarketInfo(Symbol(),MODE_MINLOT);
      double margin=MarketInfo(Symbol(),MODE_MARGINREQUIRED);
      double    TV1=MarketInfo(Symbol(),MODE_TICKVALUE);
      int cnt2,cnt3;
      double marginsum,points;
      
      for (cnt2=MaxTrades1; cnt2>=1;cnt2--) 
         {
         points=0;
         for (cnt3=MaxTrades1-cnt2; cnt3<MaxTrades1; cnt3++)
            {
            points+=NormalizeDouble(step*MathPow(Step_coef,cnt3),0);
            }
         MaxDrawdown+=trade_vol*(points*cu)*TV1;                                      // расчет максимальной просадки при объеме 1-го ордера в 1.00 лот
         sum_vol+=trade_vol;
         trade_vol*=mult1;

         }
      marginsum=margin*sum_vol;
      double lot=NormalizeDouble(((AccountBalance()+AccountCredit())*UM/100)/(MaxDrawdown+marginsum),dig);  // расчет максимального объема для 1-го ордера серии
      
      if (lot*sum_vol>maxLot) lot=NormalizeDouble(maxLot/sum_vol,dig);                    // проверка на максимально возможный объем 1-го ордера серии
      return(lot);
      }

//======================================================================================================================

                        void TradeStop()
   {
   int cnt2,cnt3;
   double trade_vol=1,points;
   double sum_vol=1;
   double MaxDrawdown,marginsum;
   double minLot=MarketInfo(Symbol(),MODE_MINLOT);
   double margin=MarketInfo(Symbol(),MODE_MARGINREQUIRED);
   double    TV1=MarketInfo(Symbol(),MODE_TICKVALUE);
   
      for (cnt2=MaxTrades; cnt2>=1;cnt2--)
         {
         points=0;
         for (cnt3=MaxTrades-cnt2; cnt3<MaxTrades; cnt3++)
            {
            points+=NormalizeDouble(step*MathPow(Step_coef,cnt3),0);
            }
         MaxDrawdown+=trade_vol*(points*cu)*TV1;
         sum_vol+=trade_vol;
         trade_vol*=mult;
         }
      marginsum=margin*sum_vol;
   double deposit=minLot*(MaxDrawdown+marginsum)/UseMoney*100;
   if (!IsTesting()) Alert("Not enough money deposit must be at least ",deposit," units");
   if (IsTesting()) Print(lotsbuy," Not enough money deposit must be at least ",deposit," units"); 
   return;   
   }
   