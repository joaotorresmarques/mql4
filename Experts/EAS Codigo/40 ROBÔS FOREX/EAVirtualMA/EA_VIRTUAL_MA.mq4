//+------------------------------------------------------------------+
//|                                                EA_VIRTUAL_MA.mq4 |
//|                                                               IO |
//|                                               http://www.vmql.ru |
//+------------------------------------------------------------------+
#property copyright "IO"
#property link      "http://www.vmql.ru"

extern bool VIRTUAL = false;
extern int N = 5;
extern int BARS_min = 5;
extern int BARS_max = 15;
extern int BARS_last_trades = 5;
extern int MAX_TRADES = 5;
extern int TakeProfit = 300;
extern int StopLoss = 300;
extern int BEZUBITOK = 100;
extern double LOTS = 0.1;
extern double PERCENT_LOTS = 10;
extern int SYSTEM_LOTS = 0;
extern int MAX_LOSS = 5;
extern int ID = 52325;
extern bool Time_work = false;
extern int Order_Open_Hour = 0;
extern int Order_Open_Minutes = 0;
extern int Order_Close_Hour = 23;
extern int Order_Close_Minutes = 59;
extern string MA = "Настройки МА";
extern int MA_period = 8;
extern int MA_method = 1;
extern int MA_applied_price = 0;

int init()
{
   return(0);
}

int deinit()
{
   switch( UninitializeReason() )
   {
        case REASON_REMOVE:      delete_glob ( "_"+ID+"_" );
   }
   if ( IsTesting() )delete_glob ( "_"+ID+"_" );
   return(0);
}

int start()
{
   if ( BEZUBITOK > MarketInfo(Symbol(),MODE_STOPLEVEL) )modify_orders();
   int type = Signal_MA();
   if ( !IsTesting() )return(0);
   if ( VIRTUAL )
   {      
      virt_modify_orders();      
      if( ( type == 0 || type == 1 ) && Time_Function() && virt_order_total() < MAX_TRADES && virt_last_trade() )virt_open(type,0.1,StopLoss,TakeProfit);
   }
   
   double lot;   
   if ( SYSTEM_LOTS == 0 )lot = LOT_1();
   if ( SYSTEM_LOTS == 1 )lot = LOT_2();
   if( VIRTUAL && GlobalVariableGet("N_"+ID+"_") >= N && ( type == 0 || type == 1 ) && order_total_date(type,0) == 0 && Time_Function() && order_total() < MAX_TRADES && last_trade() )open(type,lot,StopLoss,TakeProfit);
   if( !VIRTUAL && ( type == 0 || type == 1 ) && order_total_date(type,0) == 0 && Time_Function() && order_total() < MAX_TRADES && last_trade() )open(type,lot,StopLoss,TakeProfit);
   
   return(0);
}

bool virt_last_trade()
{
   if ( BARS_last_trades < 1 )BARS_last_trades = 1;
   int i,op;
   datetime time=0;  
   if ( GlobalVariableCheck("TIME_OP_"+ID+"_") )time = GlobalVariableGet("TIME_OP_"+ID+"_"); 
   if ( time == 0 )return(true);
   if ( iBarShift(Symbol(),Period(),time) >= BARS_last_trades )return(true);
   return(false);
}

int virt_order_total()
{
   int i,kol = 0;   
   for ( i = GlobalVariablesTotal() - 1; i >= 0; i -- )if ( StringFind(GlobalVariableName(i),"_"+ID+"_") >= 0 )if ( StringFind(GlobalVariableName(i),"OPEN_BUY:") >= 0 || StringFind(GlobalVariableName(i),"OPEN_SELL:") >= 0 )kol++;
   return(kol);
}

void virt_modify_orders()
{
   int i,n;
   string NAME;
   double OP_PR,SL,TP,LOT,SPREAD = MarketInfo(Symbol(),MODE_SPREAD)*Point;
   for ( i = GlobalVariablesTotal() - 1; i >= 0; i -- )
   {
      if ( StringFind(GlobalVariableName(i),"OPEN_BUY:") >= 0 )
      {             
         NAME = GlobalVariableName(i);         
         OP_PR = StrToDouble(StringSubstr(NAME,StringFind(NAME,"OPEN_BUY:")+StringLen("OPEN_BUY:"),StringFind(NAME,";LOT:")-StringFind(NAME,"OPEN_BUY:")-StringLen("OPEN_BUY:")));
         LOT = StrToDouble(StringSubstr(NAME,StringFind(NAME,"LOT:")+StringLen("LOT:"),StringFind(NAME,";SL:")-StringFind(NAME,"LOT:")-StringLen("LOT:")));
         SL = StrToDouble(StringSubstr(NAME,StringFind(NAME,"SL:")+StringLen("SL:"),StringFind(NAME,";TP:")-StringFind(NAME,"SL:")-StringLen("SL:")));
         TP = StrToDouble(StringSubstr(NAME,StringFind(NAME,"TP:")+StringLen("TP:"),StringFind(NAME,";_"+ID+"_")-StringFind(NAME,"TP:")-StringLen("TP:")));
         
         if ( (Ask - OP_PR)/Point >= BEZUBITOK && NormalizeDouble(SL,Digits) != NormalizeDouble(OP_PR,Digits) )
         {
            GlobalVariableDel(NAME);
            NAME = "OPEN_BUY:"+DoubleToStr(OP_PR,Digits)+";LOT:"+DoubleToStr(LOT,2)+";SL:"+DoubleToStr(OP_PR,Digits)+";TP:"+DoubleToStr(TP,Digits)+";_"+ID+"_";
            GlobalVariableSet(NAME,OP_PR);            
            break;
         }
         if ( TP <= Bid )
         {
            GlobalVariableDel(NAME);
            GlobalVariableSet("N_"+ID+"_",0);            
            ObjectCreate( TimeToStr(Time[0])+" OP_B_TP",OBJ_ARROW,0,Time[0],TP);
            ObjectSet( TimeToStr(Time[0])+" OP_B_TP", OBJPROP_ARROWCODE, 3);
            ObjectSet( TimeToStr(Time[0])+" OP_B_TP", OBJPROP_COLOR, Lime);
            break;
         }
         if ( SL >= Bid )
         {
            GlobalVariableDel(NAME);
            n = GlobalVariableGet("N_"+ID+"_");
            if ( NormalizeDouble(SL,Digits) != NormalizeDouble(OP_PR,Digits) )n ++;
            GlobalVariableSet("N_"+ID+"_",n);
            GlobalVariableSet("TIME_CL_"+ID+"_",Time[0]);
            ObjectCreate( TimeToStr(Time[0])+" OP_B_SL",OBJ_ARROW,0,Time[0],SL);
            ObjectSet( TimeToStr(Time[0])+" OP_B_SL", OBJPROP_ARROWCODE, 3);
            ObjectSet( TimeToStr(Time[0])+" OP_B_SL", OBJPROP_COLOR, Lime);
            break;
         }
      }
      if ( StringFind(GlobalVariableName(i),"OPEN_SELL:") >= 0 )
      {             
         NAME = GlobalVariableName(i);         
         OP_PR = StrToDouble(StringSubstr(NAME,StringFind(NAME,"OPEN_SELL:")+StringLen("OPEN_SELL:"),StringFind(NAME,";LOT:")-StringFind(NAME,"OPEN_SELL:")-StringLen("OPEN_SELL:")));
         LOT = StrToDouble(StringSubstr(NAME,StringFind(NAME,"LOT:")+StringLen("LOT:"),StringFind(NAME,";SL:")-StringFind(NAME,"LOT:")-StringLen("LOT:")));
         SL = StrToDouble(StringSubstr(NAME,StringFind(NAME,"SL:")+StringLen("SL:"),StringFind(NAME,";TP:")-StringFind(NAME,"SL:")-StringLen("SL:")));
         TP = StrToDouble(StringSubstr(NAME,StringFind(NAME,"TP:")+StringLen("TP:"),StringFind(NAME,";_"+ID+"_")-StringFind(NAME,"TP:")-StringLen("TP:")));
         
         if ( (OP_PR - Bid)/Point >= BEZUBITOK && NormalizeDouble(SL,Digits) != NormalizeDouble(OP_PR,Digits) )
         {
            GlobalVariableDel(NAME);
            NAME = "OPEN_SELL:"+DoubleToStr(OP_PR,Digits)+";LOT:"+DoubleToStr(LOT,2)+";SL:"+DoubleToStr(OP_PR,Digits)+";TP:"+DoubleToStr(TP,Digits)+";_"+ID+"_";
            GlobalVariableSet(NAME,OP_PR);
            break;
         }
         if ( TP >= Bid )
         {
            GlobalVariableDel(NAME);
            GlobalVariableSet("N_"+ID+"_",0);            
            ObjectCreate( TimeToStr(Time[0])+" OP_S_TP",OBJ_ARROW,0,Time[0],TP);
            ObjectSet( TimeToStr(Time[0])+" OP_S_TP", OBJPROP_ARROWCODE, 3);
            ObjectSet( TimeToStr(Time[0])+" OP_S_TP", OBJPROP_COLOR, OrangeRed);
            break;
         }
         if ( SL <= Bid )
         {
            GlobalVariableDel(NAME);
            n = GlobalVariableGet("N_"+ID+"_");
            if ( NormalizeDouble(SL,Digits) != NormalizeDouble(OP_PR,Digits) )n ++;
            GlobalVariableSet("N_"+ID+"_",n);
            GlobalVariableSet("TIME_CL_"+ID+"_",Time[0]);
            ObjectCreate( TimeToStr(Time[0])+" OP_S_TP",OBJ_ARROW,0,Time[0],SL);
            ObjectSet( TimeToStr(Time[0])+" OP_S_TP", OBJPROP_ARROWCODE, 3);
            ObjectSet( TimeToStr(Time[0])+" OP_S_TP", OBJPROP_COLOR, OrangeRed);
            break;
         }
      }
   }
}

int virt_open(int type, double l, double sl = 0, double tp = 0 )
{
   string NAME;
   double v_sl, v_tp;
   if ( type == 0 )
   {
      v_tp = Bid + tp * Point;
      v_sl = Bid - sl * Point;
      NAME = "OPEN_BUY:"+DoubleToStr(Ask,Digits)+";LOT:"+DoubleToStr(l,2)+";SL:"+DoubleToStr(v_sl,Digits)+";TP:"+DoubleToStr(v_tp,Digits)+";_"+ID+"_";
      if ( Time[0] > GlobalVariableGet("TIME_OP_"+ID+"_") )GlobalVariableSet("TIME_OP_"+ID+"_",Time[0]);
      ObjectCreate( TimeToStr(Time[0])+" OP_B",OBJ_ARROW,0,Time[0],Ask);
      ObjectSet( TimeToStr(Time[0])+" OP_B", OBJPROP_ARROWCODE, 1);
      ObjectSet( TimeToStr(Time[0])+" OP_B", OBJPROP_COLOR, Lime);
   }
   if ( type == 1 )
   {
      v_tp = Ask - tp * Point;
      v_sl = Ask + sl * Point;
      NAME = "OPEN_SELL:"+DoubleToStr(Bid,Digits)+";LOT:"+DoubleToStr(l,2)+";SL:"+DoubleToStr(v_sl,Digits)+";TP:"+DoubleToStr(v_tp,Digits)+";_"+ID+"_";
      if ( Time[0] > GlobalVariableGet("TIME_OP_"+ID+"_") )GlobalVariableSet("TIME_OP_"+ID+"_",Time[0]);
      ObjectCreate( TimeToStr(Time[0])+" OP_S",OBJ_ARROW,0,Time[0],Bid);
      ObjectSet( TimeToStr(Time[0])+" OP_S", OBJPROP_ARROWCODE, 1);
      ObjectSet( TimeToStr(Time[0])+" OP_S", OBJPROP_COLOR, OrangeRed);
   }
   GlobalVariableSet(NAME,v_sl);
}

void delete_glob ( string g )
{
   int i;
   for ( i = GlobalVariablesTotal()-1; i >= 0 ; i -- )if ( StringFind(GlobalVariableName(i),g) >= 0 )GlobalVariableDel(GlobalVariableName(i));
}

bool last_trade()
{
   if ( BARS_last_trades == 0 )return(true);
   int i,op;
   datetime time=0;
   
   for( i = OrdersTotal()-1;i >= 0;i -- )
   {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);      
      if( OrderOpenTime() > time && OrderMagicNumber() == ID )time = OrderOpenTime();
   }
   if ( time == 0 )
   for( i = OrdersHistoryTotal()-1; i >= 0;i-- )
   {
      OrderSelect(i,SELECT_BY_POS,MODE_HISTORY);      
      if( OrderOpenTime() > time && OrderMagicNumber() == ID )time = OrderOpenTime();
   }
   if ( time == 0 )return(true);
   if ( iBarShift(Symbol(),Period(),time) >= BARS_last_trades )return(true);
   return(false);
}

double LOT_1()
{
   int i,ticket = 0,loss = 0;
   double l,loss_p = 0;
   datetime time=0;
   
   for( i = OrdersHistoryTotal() - 1 ; i >= 0;i -- )
   {
      OrderSelect(i,SELECT_BY_POS,MODE_HISTORY);      
      if( OrderCloseTime() > time && OrderMagicNumber() == ID )
      {
         if ( OrderProfit() > 0 )break;
         if ( OrderProfit() < 0 ){loss++;loss_p+=OrderProfit()-((AccountBalance()*(PERCENT_LOTS/100))/MarketInfo(Symbol(),MODE_MARGINREQUIRED))*TakeProfit*MarketInfo(Symbol(),MODE_TICKVALUE);}
         if ( OrderProfit() < 0 && ticket == 0 )ticket = OrderTicket();
      }
   }   
   l = LOTS;
   if ( PERCENT_LOTS != 0 )
   {      
      l = (AccountBalance()*(PERCENT_LOTS/100))/MarketInfo(Symbol(),MODE_MARGINREQUIRED);
      if ( ticket != 0 )
      {
         OrderSelect(ticket,SELECT_BY_TICKET,MODE_HISTORY);
         if ( loss < MAX_LOSS && loss != 0 )l = (MathAbs(loss_p)+((AccountBalance()*(PERCENT_LOTS/100))/MarketInfo(Symbol(),MODE_MARGINREQUIRED))*TakeProfit*MarketInfo(Symbol(),MODE_TICKVALUE))/(TakeProfit*MarketInfo(Symbol(),MODE_TICKVALUE));
      }   
   }   
   return(l);
}

double LOT_2()
{
   int i,ticket = 0,loss = 0;
   double l,loss_p = 0;
   datetime time=0;
   
   for( i = OrdersHistoryTotal() - 1 ; i >= 0;i -- )
   {
      OrderSelect(i,SELECT_BY_POS,MODE_HISTORY);      
      if( OrderMagicNumber() == ID )
      {
         if ( OrderProfit() > 0 )break;
         if ( OrderProfit() < 0 )
         {
            loss ++;
            loss_p += OrderProfit();
         }
      }
   }   
   l = LOTS;
   if ( PERCENT_LOTS != 0 )l = (AccountBalance()*(PERCENT_LOTS/100))/MarketInfo(Symbol(),MODE_MARGINREQUIRED);
   if ( loss >= N )l = MathAbs(loss_p)/( ( TakeProfit - MarketInfo(Symbol(),MODE_SPREAD) ) * MarketInfo(Symbol(),MODE_TICKVALUE));
   return(l);
}

int order_total( int type_1 = -1, int type_2 = -1 )
{
   int i;
   int kol=0;
   for(i=OrdersTotal()-1;i>=0;i--)       
   {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderMagicNumber()==ID && (OrderType() == type_1 || OrderType() == type_2) )kol++;
      if(OrderMagicNumber()==ID && type_1 == -1 && type_2 == -1 )kol++;
   }
   return(kol);   
}

int order_total_date(int c, int t)
{
   int i;
   int kol=0;
   datetime time = 0;
   for(i=OrdersTotal()-1;i>=0;i--)       
   {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderType()==c  && OrderMagicNumber()==ID && iBarShift(Symbol(),Period(),OrderOpenTime()) == t)kol++;         
   }
   
   for(i=OrdersHistoryTotal()-1;i>=0;i--)       
   {
      OrderSelect(i,SELECT_BY_POS,MODE_HISTORY);
      if(OrderType()==c  && OrderMagicNumber()==ID && iBarShift(Symbol(),Period(),OrderOpenTime()) == t)kol++;         
   }
   if ( GlobalVariableCheck("TIME_CL_"+ID+"_") )
   {
      time = GlobalVariableGet("TIME_CL_"+ID+"_");
      if ( iBarShift(Symbol(),Period(),time) < 1 )kol = -1;
   }   
   return(kol);   
}

int Signal_MA()
{
   int i, kol_B = 0, kol_S = 0;
   for ( i = 1; i <= BARS_max; i++ )
   {
      if ( Low[i] > iMA(NULL,0,MA_period,0,MA_method,MA_applied_price,i) )kol_B++;
      if ( Low[i] <= iMA(NULL,0,MA_period,0,MA_method,MA_applied_price,i) )break;
   }
   for ( i = 1; i <= BARS_max; i++ )
   {
      if ( High[i] < iMA(NULL,0,MA_period,0,MA_method,MA_applied_price,i) )kol_S++;
      if ( High[i] >= iMA(NULL,0,MA_period,0,MA_method,MA_applied_price,i) )break;
   }
   if ( kol_B >= BARS_min && kol_B <= BARS_max && Low[0] < iMA(NULL,0,MA_period,0,MA_method,MA_applied_price,0) )return(0);
   if ( kol_S >= BARS_min && kol_S <= BARS_max && High[0] > iMA(NULL,0,MA_period,0,MA_method,MA_applied_price,0) )return(1);
   return(-1);
}

bool Time_Function()
{
   bool Open_flag=false;
   bool Close_flag=false;
   if(!Time_work)
   {
      Open_flag=true;
      Close_flag=true;
   }   
   else
   {
      if( TimeHour(Time[0]) == Order_Open_Hour && TimeMinute(Time[0]) >= Order_Open_Minutes )Open_flag=true;
      else if( TimeHour(Time[0]) > Order_Open_Hour )Open_flag=true;
      
      if( TimeHour(Time[0]) == Order_Close_Hour && TimeMinute(Time[0]) <= Order_Close_Minutes )Close_flag=true;
      else if( TimeHour(Time[0]) < Order_Close_Hour )Close_flag=true;
   }  
   if(Open_flag && Close_flag)return(true);
   else return(false);
}

double check_lot(double &lo)
{
   double l = MarketInfo(Symbol(),MODE_LOTSTEP);
   int ok = 0;
   while ( l < 1 ){l*=10;ok++;}
   if( lo < MarketInfo(Symbol(),MODE_MINLOT) )lo = MarketInfo(Symbol(),MODE_MINLOT);
   if( lo > MarketInfo(Symbol(),MODE_MAXLOT) )lo = MarketInfo(Symbol(),MODE_MAXLOT);
   return(NormalizeDouble(lo,ok));
}

void modify_orders()
{
   int i;
   for(i=OrdersTotal()-1;i>=0;i--)
   {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderMagicNumber()== ID )
      {
         if(OrderType()==0)
         {
            if ( BEZUBITOK != 0 && OrderStopLoss() == 0 && (Ask-OrderOpenPrice())/Point >= BEZUBITOK)OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice(),OrderTakeProfit(),0);            
            if ( BEZUBITOK != 0 && OrderStopLoss() != 0 && NormalizeDouble(OrderStopLoss(),Digits) != NormalizeDouble(OrderOpenPrice(),Digits) && (Ask-OrderOpenPrice())/Point >= BEZUBITOK)OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice(),OrderTakeProfit(),0);
            //if ( TS != 0 && OrderStopLoss() != 0 && OrderStopLoss() >= OrderOpenPrice() && (Ask-OrderStopLoss())/Point >= 2*TS)OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss()+TS*Point,OrderTakeProfit(),0);
         }
         if(OrderType()==1)
         {
            if ( BEZUBITOK != 0 && OrderStopLoss() == 0 && (OrderOpenPrice()-Bid)/Point >= BEZUBITOK)OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice(),OrderTakeProfit(),0);
            if ( BEZUBITOK != 0 && OrderStopLoss() != 0 && NormalizeDouble(OrderStopLoss(),Digits) != NormalizeDouble(OrderOpenPrice(),Digits) && (OrderOpenPrice()-Bid)/Point >= BEZUBITOK)OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice(),OrderTakeProfit(),0);
            //if ( TS != 0 && OrderStopLoss() != 0 && OrderStopLoss() <= OrderOpenPrice() && (OrderStopLoss()-Bid)/Point >= 2*TS)OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss()-TS*Point,OrderTakeProfit(),0);
         }   
      }
   }   
}

int open(int type, double l, double sl=0, double tp=0, string comm = "")
{
   int isOpened = 0, try = 0;
   double s,t;
   while ( IsTradeContextBusy() ){Sleep(500);}
   RefreshRates();
   if ( sl != 0 && sl < MarketInfo(Symbol(),MODE_STOPLEVEL) )sl = MarketInfo(Symbol(),MODE_STOPLEVEL);
   if ( tp != 0 && tp < MarketInfo(Symbol(),MODE_STOPLEVEL) )tp = MarketInfo(Symbol(),MODE_STOPLEVEL);
   if ( type == 0 )
   {
      if ( tp == 0 )t = 0;
      if ( tp != 0 )t = Bid + tp * Point;
      if ( sl == 0 )s = 0;
      if ( sl != 0 )s = Bid - sl * Point;
   }
   if ( type == 1 )
   {
      if ( tp == 0 )t = 0;
      if ( tp != 0 )t = Ask - tp * Point;
      if ( sl == 0 )s = 0;
      if ( sl != 0 )s = Ask + sl * Point;
   }
   s = NormalizeDouble(s,Digits);
   t = NormalizeDouble(t,Digits);
   if(type==0)isOpened = OrderSend(Symbol(),type,check_lot(l),NormalizeDouble(Ask,Digits),10,s,t,comm,ID);
   if(type==1)isOpened = OrderSend(Symbol(),type,check_lot(l),NormalizeDouble(Bid,Digits),10,s,t,comm,ID);
   Sleep(500);
   while(isOpened<0)
   {
      while ( IsTradeContextBusy() ){Sleep(500);}
      RefreshRates();
      if ( type == 0 )
      {
         if ( tp == 0 )t = 0;
         if ( tp != 0 )t = Bid + tp * Point;
         if ( sl == 0 )s = 0;
         if ( sl != 0 )s = Bid - sl * Point;
      }
      if ( type == 1 )
      {
         if ( tp == 0 )t = 0;
         if ( tp != 0 )t = Ask - tp * Point;
         if ( sl == 0 )s = 0;
         if ( sl != 0 )s = Ask + sl * Point;
      }
      s = NormalizeDouble(s,Digits);
      t = NormalizeDouble(t,Digits);
      try++;
      if(type==0)isOpened = OrderSend(Symbol(),type,check_lot(l),NormalizeDouble(Ask,Digits),10,s,t,comm,ID);
      if(type==1)isOpened = OrderSend(Symbol(),type,check_lot(l),NormalizeDouble(Bid,Digits),10,s,t,comm,ID);
      if(try > 5) break;
      if(isOpened>=0)break;
      Sleep(500);
   }   
   if(isOpened<0) Alert("Ордер не открыт, ошибка :", GetLastError());
   return (isOpened);
}