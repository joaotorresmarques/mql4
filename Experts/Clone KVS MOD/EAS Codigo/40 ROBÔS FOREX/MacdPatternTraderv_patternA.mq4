//+------------------------------------------------------------------+
//|                                            MacdPatternTrader.mq4 |
//|                                                     FORTRADER.RU |
//|                                              http://FORTRADER.RU |
//+------------------------------------------------------------------+

/*
 
Looking for an interpreter for the English version of the magazine on partnership.

//добавлено ограничение на одну сделку в одном направлении
//исправлена ошибка приводившая к не правильному открытию по сигналу
//добавлен параметр maxbarABpoint задающий количество баров между точками для генерации сигнала на вход, всегда должен быть 1 или больше. 

Страница обсуждения советника, последние новости и обновления:
http://fortrader.ru/services/eaVersion/single?id=8

Download last EA version:
http://fortrader.ru/services/eaVersion/single?id=8


*/

#property copyright "FORTRADER.RU"
#property link      "http://FORTRADER.RU"

extern int stoplossbars = 6; // count bars for find minimum/maximum for enter stoploss
extern int takeprofitbars = 20;
extern int stoploss_deviation = 10; 
extern int lowema=5;
extern int fastema=13;
extern double maxur=0.0045;
extern double minur=-0.0045;
extern int maxbarABpoint=1;

extern string x="Настройки MA:";
extern  int perema1=7;
extern  int perema2=21;
extern  int persma3=98;
extern  int perema4=365;

extern double Lots=1;

int buy,sell;int nummodb,nummods;int flaglot;
int start()
  {   

      AOPattern(lowema,fastema,maxur,minur);
      ActivePosManager(perema1,perema2,persma3,perema4);
 
   return(0);
  }
int aop_maxur,aop_minur,aop_oksell,aop_okbuy,numberbar,numberbarsell,s_otstup;
int AOPattern(double FastEMA,double SlowEMA,double maxur,double minur)
{

      if(Digits==5 || Digits==3)
     {
      s_otstup = stoploss_deviation*10;
     }
 
   
   //загружаем индикаторы
   double macdcurr =iMACD(NULL,0,FastEMA,SlowEMA,1,PRICE_CLOSE,MODE_MAIN,1);
   double macdlast =iMACD(NULL,0,FastEMA,SlowEMA,1,PRICE_CLOSE,MODE_MAIN,2);
   double macdlast3 =iMACD(NULL,0,FastEMA,SlowEMA,1,PRICE_CLOSE,MODE_MAIN,3);
   
   if(macdcurr<0){aop_maxur=0;}
   if(macdcurr>maxur){aop_maxur=1;  numberbarsell=Bars;}
   if(macdcurr<maxur && macdcurr<macdlast && macdlast>macdlast3 && aop_maxur==1 && macdcurr>0 && macdlast3<maxur && (Bars-numberbarsell) > 1)
   { 
   aop_oksell=1;
   numberbarsell=0;
   }
   
   //if we have open sell position, don't new enter
   if(aop_oksell==1 && Chpos(0)>0) {aop_oksell=0;}
   
   if(aop_oksell==1)
   {
      OrderSend(Symbol(),OP_SELL,Lots,Bid,3,StopLoss(0),TakeProfit(0),"FORTRADER.RU",16385,0,Red);
      aop_oksell=0;
      aop_maxur=0;
      nummods=0;
      flaglot=0;
   }
   
   //don't enter long if macd has risen above 0
   if(macdcurr>0){aop_minur=0;}
   
   if(macdcurr<minur){aop_minur=1; numberbar=Bars;}
   if(macdcurr>minur && macdcurr<0 && macdcurr>macdlast && macdlast<macdlast3 && aop_minur==1 && macdlast3>minur && (Bars-numberbar) > 1)
   { 
   aop_okbuy=1;
   numberbar=0;
   }
   
   //if we have opne buy position, don't new enter
   if(aop_okbuy==1 && Chpos(1)>0 ) {aop_okbuy=0;}
   
   if(aop_okbuy==1 )
   {
       OrderSend(Symbol(),OP_BUY,Lots,Ask,3,StopLoss(1),TakeProfit(1),"FORTRADER.RU",16385,0,Red);
      aop_okbuy=0;
      aop_minur=0;
      nummodb=0;
      flaglot=0;
   }

}

  //проверяет есть ли стоп ордера
int Chpos(int type) 
{int i;
   for( i=1; i<=OrdersTotal(); i++)         
   {
      if(OrderSelect(i-1,SELECT_BY_POS)==true) 
       {                                   
           if(OrderType()==OP_BUY && OrderSymbol()==Symbol() && type==1){return(1);}
           if(OrderType()==OP_SELL && OrderSymbol()==Symbol() && type==0){return(1);}
       }
    }   
return(0);
}

double StopLoss(int type)
{double stoploss;
if(type==0)
{
  stoploss=High[iHighest(NULL,0,MODE_HIGH,stoplossbars,1)]+s_otstup*Point;
 return(stoploss);
}
if(type==1)
{
  stoploss=Low[iLowest(NULL,0,MODE_LOW,stoplossbars,1)]-s_otstup*Point;
 return(stoploss);
}

}

double TakeProfit(int type)
{ int x=0,stop=0;double takeprofit;
  
  if(type==0)
   {
   while(stop==0)
         {
           takeprofit =Low[iLowest(NULL,0,MODE_LOW,takeprofitbars,x)];
          if(takeprofit>Low[iLowest(NULL,0,MODE_LOW,takeprofitbars,x+takeprofitbars)])
            {
            takeprofit =Low[iLowest(NULL,0,MODE_LOW,takeprofitbars,x+takeprofitbars)];
            x=x+takeprofitbars;
            }
          else
            {
             stop=1;return(takeprofit);
            }
         }
   }
   
   if(type==1)
   {
   while(stop==0)
         {
           takeprofit =High[iHighest(NULL,0,MODE_HIGH,takeprofitbars,x)];
          if(takeprofit<High[iHighest(NULL,0,MODE_HIGH,takeprofitbars,x+takeprofitbars)])
            {
            takeprofit =High[iHighest(NULL,0,MODE_HIGH,takeprofitbars,x+takeprofitbars)];
            x=x+takeprofitbars;
            }
          else
            {
             stop=1;return(takeprofit);
            }
         }
   }
                
}

int  ActivePosManager(int perema1, int perema2, int persma3, int perema4)
{
   double ema1 =iMA(NULL,0,perema1,0,MODE_EMA,PRICE_CLOSE,1);
    double ema2 =iMA(NULL,0,perema2,0,MODE_EMA,PRICE_CLOSE,1);
     double sma1 =iMA(NULL,0,persma3,0,MODE_SMA,PRICE_CLOSE,1);
      double ema3 =iMA(NULL,0,perema4,0,MODE_EMA,PRICE_CLOSE,1);

   for( int i=0;i<OrdersTotal();i++)
      {
              OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
              if(OrderType()==OP_BUY && OrderProfit()>5 && Close[1]>ema2 && nummodb==0)
              {  
                 OrderClose(OrderTicket(),NormalizeDouble(OrderLots()/3,2),Bid,3,Violet); 
                 nummodb++;
              }
              
                 if(OrderType()==OP_BUY && OrderProfit()>5 && High[1]>(sma1+ema3)/2 && nummodb==1)
              {  
                 OrderClose(OrderTicket(),NormalizeDouble(OrderLots()/2,2),Bid,3,Violet); 
                 nummodb++;
              }
              
                if(OrderType()==OP_SELL && OrderProfit()>5 && Close[1]<ema2 && nummods==0)
              {  
                 OrderClose(OrderTicket(),NormalizeDouble(OrderLots()/3,2),Ask,3,Violet); 
                 nummods++;
              }
              
                   if(OrderType()==OP_SELL && OrderProfit()>5 && Low[1]<(sma1+ema3)/2 && nummods==1)
              {  
                 OrderClose(OrderTicket(),NormalizeDouble(OrderLots()/2,2),Ask,3,Violet); 
                 nummods++;
              }
      }

}


