//+------------------------------------------------------------------+
//|                                                   3 21 55 Ma.mq4 |
//|                 Copyright © 2005, tageiger aka fxid10t@yahoo.com |
//|                MetaTrader_Experts_and_Indicators@yahoogroups.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, tageiger aka fxid10t@yahoo.com"
#property link      "MetaTrader_Experts_and_Indicators@yahoogroups.com"

extern int        ShortMA           =3;
extern int        MidMA             =21;
extern int        LongMA            =55;
extern int        MaMethod          =0;//0=sma,1=ema,2=smma,3=lwma
extern int        CloseMaShift      =2;
extern int        Slippage          =0;
extern int        CatastrophicSL    =100;
extern int        TakeProfit        =610;
extern double     Lots              =0.1;
extern double     MaximumRisk       =0.02;
extern double     DecreaseFactor    =3;
extern int        MagicNumber       =358;

int               MaPeriod          =60;
string            TradeSymbol;      TradeSymbol=Symbol();
string            comment;          comment=Period()+"m 3-21-55 MA Cross";
int               cnt,ticket;

double ma1,ma2,ma3,maClose;
ma1=iMA(TradeSymbol,MaPeriod,ShortMA,0,MaMethod,PRICE_CLOSE,0);
ma2=iMA(TradeSymbol,MaPeriod,MidMA,0,MaMethod,PRICE_CLOSE,0);
ma3=iMA(TradeSymbol,MaPeriod,LongMA,0,MaMethod,PRICE_CLOSE,0);
maClose=iMA(TradeSymbol,MaPeriod,ShortMA,0,MaMethod,PRICE_CLOSE,CloseMaShift);


int init(){if(Period()!=MaPeriod) {Alert("Moving Averages computed from ",MaPeriod,"m chart.");}return(0);}
int deinit(){return(0);}
int start(){

if(TotalTradesThisSymbol(TradeSymbol)==0){
   if(ma1>ma2 && ma2>ma3){
      ticket=OrderSend(Symbol(),
                        OP_BUYLIMIT,
                        LotsOptimized(),
                        NormalizeDouble(ma2,Digits),
                        Slippage,
                        NormalizeDouble(ma2,Digits)-(CatastrophicSL*Point),
                        NormalizeDouble(ma2,Digits)+(TakeProfit*Point),
                        "Buy "+comment,
                        MagicNumber,
                        0,
                        MediumSpringGreen);
                        if(ticket>0){
                           if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)){Print(ticket);}
                           else Print("Error Opening BuyLimit Order: ",GetLastError());
                           return(0);}//end if(ticket
                        }//end if(ma1>ma2
   if(ma1<ma2 && ma2<ma3){
      ticket=OrderSend(Symbol(),
                        OP_SELLLIMIT,
                        LotsOptimized(),
                        NormalizeDouble(ma2,Digits),
                        Slippage,
                        NormalizeDouble(ma2,Digits)+(CatastrophicSL*Point),
                        NormalizeDouble(ma2,Digits)-(TakeProfit*Point),
                        "Sell "+comment,
                        MagicNumber,
                        0,
                        OrangeRed);
                        if(ticket>0){
                           if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)){Print(ticket);}
                           else Print("Error Opening SellLimit Order: ",GetLastError());
                           return(0);}//end if(ticket
                        }//end if(ma1>ma2
   }//end if(TotalTradesThisSymbol

for(cnt=0;cnt<OrdersTotal();cnt++){
   OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
   if(OrderType()==OP_BUYLIMIT && OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber){
      if(OrderOpenPrice()<ma2){
         OrderModify(OrderTicket(),
                     NormalizeDouble(ma2,Digits),
                     NormalizeDouble(ma2,Digits)-(CatastrophicSL*Point),
                     NormalizeDouble(ma2,Digits)+(TakeProfit*Point),
                     0,
                     LightSeaGreen);}/*end if(OrderOpenPrice*/}//end if(OrderType
   if(OrderType()==OP_SELLLIMIT && OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber){
      if(OrderOpenPrice()>ma2){
         OrderModify(OrderTicket(),
                     NormalizeDouble(ma2,Digits),
                     NormalizeDouble(ma2,Digits)+(CatastrophicSL*Point),
                     NormalizeDouble(ma2,Digits)-(TakeProfit*Point),
                     0,
                     Chocolate);}/*end if(OrderOpenPrice*/}//end if(OrderType
   if(OrderType()==OP_BUY && OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber){
      if(ma1<maClose){
         OrderClose(OrderTicket(),
                     OrderLots(),
                     Bid,
                     Slippage,
                     MediumBlue);}/*end if(ma1<maClose)*/}//end if(OrderType
   if(OrderType()==OP_SELL && OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber){
      if(ma1>maClose){
         OrderClose(OrderTicket(),
                     OrderLots(),
                     Ask,
                     Slippage,
                     Magenta);}/*end if(ma1<maClose)*/}//end if(OrderType
   if(OrderType()==OP_BUY && OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber){
      if(ma2>OrderOpenPrice() && ma2>OrderStopLoss()){
         OrderModify(OrderTicket(),
                     OrderOpenPrice(),
                     NormalizeDouble(ma2,Digits),
                     OrderTakeProfit(),
                     0,
                     SteelBlue);}/*if(ma2>Ord*/}//if(OrderType
   if(OrderType()==OP_SELL && OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber){
      if(ma2<OrderOpenPrice() && ma2<OrderStopLoss()){
         OrderModify(OrderTicket(),
                     OrderOpenPrice(),
                     NormalizeDouble(ma2,Digits),
                     OrderTakeProfit(),
                     0,
                     Sienna);}/*if(ma2>Ord*/}//if(OrderType
   if(OrderType()==OP_BUY && OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber){
      if(Close[1]<ma3){
         OrderClose(OrderTicket(),
                     OrderLots(),
                     Bid,
                     Slippage,
                     Red);}/*if(Close[1]<ma3)*/}//end if(OrderType
   if(OrderType()==OP_SELL && OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber){
      if(Close[1]>ma3){
         OrderClose(OrderTicket(),
                     OrderLots(),
                     Ask,
                     Slippage,
                     Aqua);}/*if(Close[1]<ma3)*/}//end if(OrderType                     
   }//end for
PrintComments();
return(0);
}//end start

//Functions

double LotsOptimized()  {
   double lot=Lots;
   int    orders=HistoryTotal();     // history orders total
   int    losses=0;                  // number of losses orders without a break
//---- select lot size
   lot=NormalizeDouble(AccountFreeMargin()*MaximumRisk/1000.0,1);
//---- calcuulate number of losses orders without a break
   if(DecreaseFactor>0)
     {
      for(int i=orders-1;i>=0;i--)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==false) { Print("Error in history!"); break; }
         if(OrderSymbol()!=Symbol() || OrderType()>OP_SELL) continue;
         //----
         if(OrderProfit()>0) break;
         if(OrderProfit()<0) losses++;
        }
      if(losses>1) lot=NormalizeDouble(lot-lot*losses/DecreaseFactor,1);
     }
//---- return lot size
   if(lot<0.1) lot=0.1;
return(lot);
}//end LotsOptimized

int TotalTradesThisSymbol(string TradeSymbol) {
   int i, TradesThisSymbol=0;
   
   for(i=0;i<OrdersTotal();i++)  {
      OrderSelect(i,SELECT_BY_POS);
      if(OrderSymbol()==TradeSymbol && OrderMagicNumber()==MagicNumber)   {  TradesThisSymbol++;  }
   }//end for
return(TradesThisSymbol);
}//end TotalTradesThisSymbol


void PrintComments() {  Comment("Current Time: ",Hour(),":",Minute(),"\n",
                                "Ma1:",ma1,"\n",
                                "Ma2:",ma2,"\n",
                                "Ma3:",ma3,"\n",
                                "MaClose:",maClose,"\n");  }