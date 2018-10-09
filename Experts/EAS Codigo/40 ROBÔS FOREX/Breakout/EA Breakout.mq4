//+------------------------------------------------------------------+
//|                                      Hans123 testing version.mq4 |
//+------------------------------------------------------------------+

#property link "http://euronis-free.com"

//---- input parameters
extern double    Lots=0.10;
static int       Begin=10;
static int       Length=4;
static int       EOD=24;
static int       Pips=5;
extern int       StopLoss=50;
extern int       BreakEven=30;
extern int       TakeProfit=80;

//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
   //---- 
   int i,Ticket,LastOrderTime,StartTime,EODTime,Bought=0,Sold=0;
   double EntryLong,EntryShort,SLLong,SLShort,TPLong,TPShort;
   
   //Settings
   if (!IsTesting()){
      if (Symbol()=="EURUSD"){
         Begin=10;
         Length=4;
         EOD=24;
         Pips=5;
         StopLoss=50;
         BreakEven=30;
         TakeProfit=80;
      }   
      else if (Symbol()=="GBPUSD"){
         Begin=10;
         Length=4;
         EOD=24;
         Pips=5;
         StopLoss=70;
         BreakEven=40;
         TakeProfit=120;
      }
      else {
         Begin=10;
         Length=4;
         EOD=24;
         Pips=5;
         StopLoss=50;
         BreakEven=30;
         TakeProfit=80;
      }
   }
   

   //Count time
   if(Hour()>=Begin-1){
      StartTime= StrToTime(Begin+":00");
      if(DayOfWeek()==5)   EODTime  = MathMin(StrToTime("22:55"),StrToTime(EOD+":00"));
      else                 EODTime  = StartTime+(EOD-Begin)*3600-60;
   }
   
   //Set orders
   if(CurTime()>= StartTime && CurTime()<StartTime+300){
      //Determine range
      EntryLong   =High[Highest(NULL,0,MODE_HIGH,Length*60/Period(),0)]+(Pips+MarketInfo(Symbol(),MODE_SPREAD))*Point;
      EntryShort  =Low [Lowest (NULL,0,MODE_LOW, Length*60/Period(),0)]-Pips*Point;
      SLLong      =MathMax(EntryLong-StopLoss*Point,EntryShort);
      SLShort     =MathMin(EntryShort+StopLoss*Point,EntryLong);
      TPLong      =EntryLong+TakeProfit*Point;
      TPShort     =EntryShort-TakeProfit*Point;
      
      //Check Orders
      for (i=0;i<OrdersTotal();i++){
         OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
         if(OrderSymbol()==Symbol() && (OrderType()==OP_BUYSTOP || OrderType()==OP_BUY)) Bought++;
         if(Bought>1){ //more than 1 buy order
            if(CurTime()<=GlobalVariableGet("LastOrderTime")+10) Sleep(10000);
            if(OrderSymbol()==Symbol() && OrderType()==OP_BUY)      OrderClose(OrderTicket(),OrderLots(),Bid,3,Red);
            if(OrderSymbol()==Symbol() && OrderType()==OP_BUYSTOP)  OrderDelete(OrderTicket());
         }

         if(OrderSymbol()==Symbol() && (OrderType()==OP_SELLSTOP || OrderType()==OP_SELL)) Sold++;
         if(Sold>1){ //more than 1 sell order
            if(CurTime()<=GlobalVariableGet("LastOrderTime")+10) Sleep(10000);
            if(OrderSymbol()==Symbol() && OrderType()==OP_SELL)     OrderClose(OrderTicket(),OrderLots(),Ask,3,Red);
            if(OrderSymbol()==Symbol() && OrderType()==OP_SELLSTOP) OrderDelete(OrderTicket());
         }
      }
      
      if(Bought==0){ //no buy order
         if(CurTime()<=GlobalVariableGet("LastOrderTime")+10) Sleep(10000);
         Ticket=OrderSend(Symbol(),OP_BUYSTOP,Lots,EntryLong,3,SLLong,TPLong,NULL,0,0,Green);
         if(Ticket<0 && GetLastError()==130)
            Ticket=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,SLLong,TPLong,NULL,0,0,Green);
         GlobalVariableSet("LastOrderTime",OrderOpenTime()); 
      }
      if(Sold==0){ //no sell order
         if(CurTime()<=GlobalVariableGet("LastOrderTime")+10) Sleep(10000);
         Ticket=OrderSend(Symbol(),OP_SELLSTOP,Lots,EntryShort,3,SLShort,TPShort,NULL,0,0,Green);
         if(Ticket<0 && GetLastError()==130)
            Ticket=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,SLShort,TPShort,NULL,0,0,Green);
         GlobalVariableSet("LastOrderTime",OrderOpenTime()); 
      }
   }
   
   //Manage opened orders
   for (i=0;i<OrdersTotal();i++){
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(CurTime()<=GlobalVariableGet("LastOrderTime")+10) Sleep(10000);
      //uzavøení otevøených pozic na konci dne
      if(CurTime()>=EODTime){
         if(OrderSymbol()==Symbol() && OrderType()==OP_BUY)      OrderClose(OrderTicket(),OrderLots(),Bid,3,Red);
         if(OrderSymbol()==Symbol() && OrderType()==OP_SELL)     OrderClose(OrderTicket(),OrderLots(),Ask,3,Red);
         if(OrderSymbol()==Symbol() && OrderType()==OP_BUYSTOP)  OrderDelete(OrderTicket());
         if(OrderSymbol()==Symbol() && OrderType()==OP_SELLSTOP) OrderDelete(OrderTicket());
         GlobalVariableSet("LastOrderTime",CurTime());
      }   
      //move at BE if profit>BE
      else {
         if(OrderSymbol()==Symbol() && OrderType()==OP_BUY){
            if(High[0]-OrderOpenPrice()>=BreakEven*Point && OrderStopLoss()!=OrderOpenPrice()){
               OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice(),OrderTakeProfit(),0,Green);
               GlobalVariableSet("LastOrderTime",CurTime());
            }   
         }   
         if(OrderSymbol()==Symbol() && OrderType()==OP_SELL){
            if(OrderOpenPrice()-Low[0]>=BreakEven*Point && OrderStopLoss()!=OrderOpenPrice()){
               OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice(),OrderTakeProfit(),0,Green);
               GlobalVariableSet("LastOrderTime",CurTime());
            }
         }
      }
   }
   
   //Reset global variables at EOD
   if(CurTime()>=EODTime) GlobalVariablesDeleteAll();
   
   return(0);
  }
//+------------------------------------------------------------------+