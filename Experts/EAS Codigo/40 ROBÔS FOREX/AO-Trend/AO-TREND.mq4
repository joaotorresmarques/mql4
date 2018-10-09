//+------------------------------------------------------------------+
//|                                                    AO-TREND .mq4 |
//|                                                totom sukopratomo |
//|                                            forexengine@gmail.com |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//+----- belum punya account fxopen? --------------------------------+
//+----- buka di http://www.ovsemu.com/forum/93-674-1#1722 ----------+
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//+----- ingin bisa scalping dengan real tp 3 pips? -----------------+
//+----- ingin dapat bonus $30 dengan deposit awal $100? ------------+
//+----- buka account di http://www.ovsemu.com/forum/93-674-1#1722---+
//+------------------------------------------------------------------+

#property copyright "totom sukopratomo"
#property link      "forexengine@gmail.com"
#define buy -2
#define sell 2
//---- input parameters
extern bool      use_daily_target=false;
extern double    daily_target=100;
extern bool      EachTickMode = True;
extern bool      trade_in_fri=true;
extern int       magic=1;
extern double    start_lot=0.1;
extern double    range=25;
extern int       level=10;
extern bool      lot_multiplier=true;
extern double    multiplier=2.0;
extern double    increament=0.1;
extern bool      use_sl_and_tp=false;
extern double    sl=60;
extern double    tp=30;
extern double    tp_in_money=5.0;
extern bool      stealth_mode=true;





extern string  separator_01="----- Additional -----";
extern bool      hedge=false;
extern int       hedge_start=4;
extern double    h_lot_factor=0.5;
extern double    h_tp_factor=1.0;
extern double    lot_multiplier_2=1.5;
extern int       lot_multi_2_level=3;

double pt;
double minlot;
double stoplevel;
int prec=0;
int a=0;
int ticket=0;
//----
double s_lot,s_lot2,hf,h_tp,lm_1,lm_2,lm_2_level,O_equity;
bool Close_All; // Part of Close_All Inhibit ...
int O_rst=0;
string opt="NULL";


int BarCount;
int Current;
bool TickCheck = False;







//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//----


BarCount = Bars;
   if (EachTickMode) Current = 0; else Current = 1;





   if(Digits==3 || Digits==5) pt=10*Point;
   else                          pt=Point;
   minlot   =   MarketInfo(Symbol(),MODE_MINLOT);
   stoplevel=MarketInfo(Symbol(),MODE_STOPLEVEL);
   if(start_lot<minlot)      Print("lotsize is to small.");
   if(sl<stoplevel)   Print("stoploss is to tight.");
   if(tp<stoplevel) Print("takeprofit is to tight.");
   if(minlot==0.01) prec=2;
   if(minlot==0.1)  prec=1;
//----
   s_lot=start_lot; if(hedge==false){ hedge_start=0; } hf=h_lot_factor; h_tp=h_tp_factor*range*pt;
   lm_1=multiplier; lm_2=lot_multiplier_2; lm_2_level=lot_multi_2_level; O_equity=AccountEquity();
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
   if(use_daily_target && dailyprofit()>=daily_target)
   {
     Comment("\ndaily target achieved.");
     return(0);
   }
   if(!trade_in_fri && DayOfWeek()==5 && total()==0)
   {
     Comment("\nstop trading in Friday.");
     return(0);
   }
//+------------------------------------------------------------------+
   int T_cnt=0,b_cnt=0,s_cnt=0,h_cnt,O_cnt=0,OOT,FOOT; // Close_All Inhibit ...
   bool s_hedge=false,b_hedge=false; string FOT="0";
   for(int cnt=0; cnt<=OrdersTotal(); cnt++)
   {
      OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==magic && OrderType()<2)
      {
         T_cnt+=1; OOT=OrderOpenTime();
         if(OrderType()==0){ b_cnt+=1; } if(OrderType()==1){ s_cnt+=1; }
         if(T_cnt==1 || OOT<FOOT){ FOOT=OOT; FOT="B"; if(OrderType()==1){ FOT="S"; } }
      }
   }
//----
   if(FOT=="B")
   {
      O_cnt=b_cnt; h_cnt=s_cnt; opt="BUY";  if(hedge==true && b_cnt>=hedge_start-1){ s_hedge=true; }
   }
   if(FOT=="S")
   {
      O_cnt=s_cnt; h_cnt=b_cnt; opt="SELL"; if(hedge==true && s_cnt>=hedge_start-1){ b_hedge=true; }
   }
//----
   multiplier=lm_1; if(lm_2>0 && O_cnt>=lm_2_level-1){ multiplier=lm_2; }
//----
   if(T_cnt==0){ Close_All=false; }
//+------------------------------------------------------------------+
   if(O_cnt==0 && a==0 && h_cnt==0) // substituted total() with O_cnt ...
   {
     if(signal()==buy && Close_All==false) // added close_all and hedge
     {
        if(stealth_mode)
        {
          if(use_sl_and_tp){ s_lot=start_lot; ticket=OrderSend(Symbol(),0,s_lot,Ask,3,Ask-sl*pt,Ask+tp*pt,"",magic,0,Blue); }
          else             { s_lot=start_lot; ticket=OrderSend(Symbol(),0,s_lot,Ask,3,        0,        0,"",magic,0,Blue); }
        }
        else
        {
          if(use_sl_and_tp) 
          {
             s_lot=start_lot;
             if(OrderSend(Symbol(),0,start_lot,Ask,3,Ask-sl*pt,Ask+tp*pt,"",magic,0,Blue)>0)
             {
                for(int i=1; i<level; i++)
                {
                    if(lot_multiplier){ s_lot=NormalizeDouble(start_lot*MathPow(multiplier,i),prec); ticket=OrderSend(Symbol(),2,s_lot,Ask-(range*i)*pt,3,(Ask-(range*i)*pt)-sl*pt,(Ask-(range*i)*pt)+tp*pt,"",magic,0,Blue); }
                    else              { s_lot=NormalizeDouble(start_lot+increament*i,prec);          ticket=OrderSend(Symbol(),2,s_lot,Ask-(range*i)*pt,3,(Ask-(range*i)*pt)-sl*pt,(Ask-(range*i)*pt)+tp*pt,"",magic,0,Blue); }
                }
             }
          }
          else
          {
             s_lot=start_lot;
             if(OrderSend(Symbol(),0,start_lot,Ask,3,0,0,"",magic,0,Blue)>0)
             {
                for(i=1; i<level; i++)
                {
                    if(lot_multiplier){ s_lot=NormalizeDouble(start_lot*MathPow(multiplier,i),prec); ticket=OrderSend(Symbol(),2,s_lot,Ask-(range*i)*pt,3,0,0,"",magic,0,Blue); }
                    else              { s_lot=NormalizeDouble(start_lot+increament*i,prec);          ticket=OrderSend(Symbol(),2,s_lot,Ask-(range*i)*pt,3,0,0,"",magic,0,Blue); }
                }
             }
          }
        }
        if(s_hedge==true){ ticket=OrderSend(Symbol(),1,s_lot*hf,Bid,3,0,Bid-h_tp,"h",magic,0,Red); }
     }
//+------------------------------------------------------------------+
     if(signal()==sell && Close_All==false) // added close_all and hedge
     {
        if(stealth_mode)
        {
          if(use_sl_and_tp){ s_lot=start_lot; ticket=OrderSend(Symbol(),1,s_lot,Bid,3,Bid+sl*pt,Bid-tp*pt,"",magic,0,Red); }
          else             { s_lot=start_lot; ticket=OrderSend(Symbol(),1,s_lot,Bid,3,        0,        0,"",magic,0,Red); }
        }
        else
        {
          if(use_sl_and_tp) 
          {
             s_lot=start_lot;
             if(OrderSend(Symbol(),1,start_lot,Bid,3,Bid+sl*pt,Bid-tp*pt,"",magic,0,Red)>0)
             {
                for(i=1; i<level; i++)
                {
                    if(lot_multiplier){ s_lot=NormalizeDouble(start_lot*MathPow(multiplier,i),prec); ticket=OrderSend(Symbol(),3,s_lot,Bid+(range*i)*pt,3,(Bid+(range*i)*pt)+sl*pt,(Bid+(range*i)*pt)-tp*pt,"",magic,0,Red); }
                    else              { s_lot=NormalizeDouble(start_lot+increament*i,prec);          ticket=OrderSend(Symbol(),3,s_lot,Bid+(range*i)*pt,3,(Bid+(range*i)*pt)+sl*pt,(Bid+(range*i)*pt)-tp*pt,"",magic,0,Red); }
                }
             }
          }
          else
          {
             s_lot=start_lot;
             if(OrderSend(Symbol(),1,start_lot,Bid,3,0,0,"",magic,0,Red)>0)
             {
                for(i=1; i<level; i++)
                {
                    if(lot_multiplier){ s_lot=NormalizeDouble(start_lot*MathPow(multiplier,i),prec); ticket=OrderSend(Symbol(),3,s_lot,Bid+(range*i)*pt,3,0,0,"",magic,0,Red); }
                    else              { s_lot=NormalizeDouble(start_lot+increament*i,prec);          ticket=OrderSend(Symbol(),3,s_lot,Bid+(range*i)*pt,3,0,0,"",magic,0,Red); }
                }
             }
          }
        }
        if(b_hedge==true){ ticket=OrderSend(Symbol(),0,s_lot*hf,Ask,3,0,Ask+h_tp,"h",magic,0,Blue); }
     } 
   }
//+------------------------------------------------------------------+
   if(stealth_mode && O_cnt>0 && O_cnt<level && h_cnt==0) // substituted total() with O_cnt ...
   {
     int type; double op, lastlot; 
     for(i=0; i<OrdersTotal(); i++)
     {
         OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
         if(OrderSymbol()!=Symbol() || OrderMagicNumber()!=magic) continue;
         type=OrderType();
         op=OrderOpenPrice();
         lastlot=OrderLots();
     }
     if(type==0 && Ask<=op-range*pt && Close_All==false) // added close_all and hedge
     {
        if(use_sl_and_tp)
        {
           if(lot_multiplier){ s_lot=NormalizeDouble(lastlot*multiplier,prec); ticket=OrderSend(Symbol(),0,s_lot,Ask,3,Ask-sl*pt,Ask+tp*pt,"",magic,0,Blue); }
           else              { s_lot=NormalizeDouble(lastlot+increament,prec); ticket=OrderSend(Symbol(),0,s_lot,Ask,3,Ask-sl*pt,Ask+tp*pt,"",magic,0,Blue); }
        }
        else
        {
           if(lot_multiplier){ s_lot=NormalizeDouble(lastlot*multiplier,prec); ticket=OrderSend(Symbol(),0,s_lot,Ask,3,0,0,"",magic,0,Blue); }
           else              { s_lot=NormalizeDouble(lastlot+increament,prec); ticket=OrderSend(Symbol(),0,s_lot,Ask,3,0,0,"",magic,0,Blue); }
        }
        if(s_hedge==true){ ticket=OrderSend(Symbol(),1,s_lot*hf,Bid,3,0,Bid-h_tp,"h",magic,0,Red); }
     }
     if(type==1 && Bid>=op+range*pt && Close_All==false) // added close_all and hedge
     {
        if(use_sl_and_tp)
        {
           if(lot_multiplier){ s_lot=NormalizeDouble(lastlot*multiplier,prec); ticket=OrderSend(Symbol(),1,s_lot,Bid,3,Bid+sl*pt,Bid-tp*pt,"",magic,0,Red); }
           else              { s_lot=NormalizeDouble(lastlot+increament,prec); ticket=OrderSend(Symbol(),1,s_lot,Bid,3,Bid+sl*pt,Bid-tp*pt,"",magic,0,Red); }
        }
        else
        {
           if(lot_multiplier){ s_lot=NormalizeDouble(lastlot*multiplier,prec); ticket=OrderSend(Symbol(),1,s_lot,Bid,3,0,0,"",magic,0,Red); }
           else              { s_lot=NormalizeDouble(lastlot+increament,prec); ticket=OrderSend(Symbol(),1,s_lot,Bid,3,0,0,"",magic,0,Red); }
        }
        if(b_hedge==true){ ticket=OrderSend(Symbol(),0,s_lot*hf,Ask,3,0,Ask+h_tp,"h",magic,0,Blue); }
     }
   }
//+------------------------------------------------------------------+
   double st_lots=0,h_lots,t_lots,n_lots; cnt=0; // Close_All Inhibit ...
   for(cnt=0; cnt<=OrdersTotal(); cnt++)
   {
      OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==magic && OrderType()<2)
      {
         if((FOT=="B" && OrderType()==1) || (FOT=="S" && OrderType()==0)){ h_lots+=OrderLots(); }
         t_lots+=OrderLots(); st_lots=t_lots-h_lots; n_lots=st_lots-h_lots;
      }
   }
//+------------------------------------------------------------------+
   double AE=AccountEquity(),a_profit=AE-O_equity,b_profit; if(a_profit>b_profit){ b_profit=a_profit; }
   Comment("OPT = ",opt,"  /  LEVEL = ",O_cnt,"  /  Hedge Start = ",hedge_start,"  |  Standard Lots = ",DoubleToStr(st_lots,2),
   "  /  Hedge Lots = ",DoubleToStr(h_lots,2),"  /  Net Lots = ",DoubleToStr(n_lots,2),"\n","Account Equity = ",DoubleToStr(AE,2),"  /  Account Profit = ",DoubleToStr(a_profit,2));
//+------------------------------------------------------------------+
   if(use_sl_and_tp && total()>1)
   {
     double s_l, t_p;
     for(i=0; i<OrdersTotal(); i++)
     {
         OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
         if(OrderSymbol()!=Symbol() || OrderMagicNumber()!=magic || OrderType()>1) continue;
         type=OrderType();
         s_l=OrderStopLoss();
         t_p=OrderTakeProfit();
     }
     for(i=OrdersTotal()-1; i>=0; i--)
     {
       OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
       if(OrderSymbol()!=Symbol() || OrderMagicNumber()!=magic || OrderType()>1) continue;
       if(OrderType()==type)
       {
          if(OrderStopLoss()!=s_l || OrderTakeProfit()!=t_p)
          {
             OrderModify(OrderTicket(),OrderOpenPrice(),s_l,t_p,0,CLR_NONE);
          }
       }
     }
   }
   double profit=0;
   for(i=0; i<OrdersTotal(); i++)
   {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderSymbol()!=Symbol() || OrderMagicNumber()!=magic || OrderType()>1) continue;
      profit+=OrderProfit();
   }
   if(profit>=tp_in_money || a>0) 
   {
      closeall();
      closeall();
      closeall();
      a++;
      if(total()==0) a=0;
   }
   if(!stealth_mode && use_sl_and_tp && total()<level) closeall();
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
double dailyprofit()
{
  int day=Day(); double res=0;
  for(int i=0; i<OrdersHistoryTotal(); i++)
  {
      OrderSelect(i,SELECT_BY_POS,MODE_HISTORY);
      if(OrderSymbol()!=Symbol() || OrderMagicNumber()!=magic) continue;
      if(TimeDay(OrderOpenTime())==day) res+=OrderProfit();
  }
  return(res);
}
//+------------------------------------------------------------------+
int total()
{
  int total=0;
  for(int i=0; i<OrdersTotal(); i++)
  {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderSymbol()!=Symbol() || OrderMagicNumber()!=magic) continue;
      total++;
  }
  return(total);
}
//+------------------------------------------------------------------+
int signal()
{
 
 
   double Buy1_1 = iMACD(NULL, 0, 12, 26, 9, PRICE_OPEN, MODE_MAIN, Current + 0);
 double Buy1_2 = 0;
 double Buy2_1 = iMACD(NULL, 0, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, Current + 2);
 double Buy2_2 = iMACD(NULL, 0, 12, 26, 9, PRICE_CLOSE, MODE_SIGNAL, Current + 2);
 double Buy3_1 = iMACD(NULL, 0, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, Current + 1);
 double Buy3_2 = iMACD(NULL, 0, 12, 26, 9, PRICE_CLOSE, MODE_SIGNAL, Current + 1);

 double Sell1_1 = iMACD(NULL, 0, 12, 26, 9, PRICE_OPEN, MODE_MAIN, Current + 0);
 double Sell1_2 = 0;
 double Sell2_1 = iMACD(NULL, 0, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, Current + 2);
 double Sell2_2 = iMACD(NULL, 0, 12, 26, 9, PRICE_CLOSE, MODE_SIGNAL, Current + 2);
 double Sell3_1 = iMACD(NULL, 0, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, Current + 1);
 double Sell3_2 = iMACD(NULL, 0, 12, 26, 9, PRICE_CLOSE, MODE_SIGNAL, Current + 1);


   if (Buy1_1 < Buy1_2 && Buy2_1 < Buy2_2 && Buy3_1 > Buy3_2) return(buy);

   if (Sell1_1 > Sell1_2 && Sell2_1 > Sell2_2 && Sell3_1 < Sell3_2) return(sell);
 
 
  }
  return(0);

//+------------------------------------------------------------------+
void closeall()
{
  for(int i=OrdersTotal()-1; i>=0; i--)
  {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderSymbol()!=Symbol() || OrderMagicNumber()!=magic) continue; Close_All=true; // Close_All Inhibit ...
      if(OrderType()>1) OrderDelete(OrderTicket());
      else
      {
        if(OrderType()==0) OrderClose(OrderTicket(),OrderLots(),Bid,3,CLR_NONE);
        else               OrderClose(OrderTicket(),OrderLots(),Ask,3,CLR_NONE);
      }
  }
} 