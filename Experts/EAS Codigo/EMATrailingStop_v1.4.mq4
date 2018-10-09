//+------------------------------------------------------------------+
//|                                         EMATrailingStop_v1.4.mq4 |
//|                                  Copyright © 2009, Forex-TSD.com |
//|           Original written 2006 by IgorAD,igorad2003@yahoo.co.uk |
//|                                   2009 version written by mladen |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Forex-TSD.com "
#property link      "http://www.forex-tsd.com/"
#include <stdlib.mqh>

//
//
//
//
//

extern bool   TrailAllSymbols   = true;
extern bool   TrailOnlyInProfit = false;
extern double CloseWhenProfit   = 0.0;
extern bool   showMessages      = true;

//
//
//
//
//

extern int  EMATimeFrame      =   0;
extern int  Price             =   0;
extern int  EMAPeriod         =  13;
extern int  EMAShift          =   2;    
extern int  InitialStop       = 100;
extern int  magicNumber.from  =   0;
extern int  magicNumber.to    =   0;


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

int init()   { return(0); }
int deinit()
{
   switch(UninitializeReason())
   {
      case REASON_CHARTCHANGE:
      case REASON_PARAMETERS:  break;
      case REASON_RECOMPILE:
      case REASON_CHARTCLOSE:
      case REASON_REMOVE:
      case REASON_ACCOUNT:     if (showMessages) for(int i=0; i<10; i++)  ObjectDelete("msg.que"+i);
   }
   return(0);
}



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//
      
int start()
{
   if (!CheckTerminalStatus()) return(0); showTwoStateMessage("working","EMA trailing EA working",true);

   //
   //
   //
   //
   //

   datetime startTime   = TimeCurrent();
   double   totalProfit = 0;
   int      err,c;
   
   //
   //
   //
   //
   //

   for (int i=OrdersTotal()-1; i>=0; i--)
   { 
      OrderSelect(i, SELECT_BY_POS,MODE_TRADES);
      if (!TrailAllSymbols)
         if (OrderSymbol()!=Symbol())               continue;
         if (OrderMagicNumber() < magicNumber.from) continue;
         if (OrderMagicNumber() > magicNumber.to)   continue;
      RefreshRates();

      //
      //
      //
      //
      //
         
         int    digits     = MarketInfo(OrderSymbol(),MODE_DIGITS);
         double point      = MarketInfo(OrderSymbol(),MODE_POINT);
         double PointRatio = 1;
               if (digits==3 || digits==5) PointRatio = 10;
      
      //
      //
      //
      //
      //

      if (OrderType()==OP_BUY) 
      {
         totalProfit += OrderProfit();
         double bid        = MarketInfo(OrderSymbol(),MODE_BID);
         double maxBuyStop = NormalizeDouble(bid-MarketInfo(OrderSymbol(),MODE_STOPLEVEL)*point,digits);
            if (OrderStopLoss()==0 && InitialStop > 0)
               {
                  double buyStop        = bid-InitialStop*point*PointRatio;
                  double currentBuyStop = buyStop-point;
               }
            else
               {             
                  buyStop        = stopValue(OrderSymbol());
                  currentBuyStop = OrderStopLoss(); if(currentBuyStop == 0) currentBuyStop = OrderOpenPrice();
                  currentBuyStop = MathMax(currentBuyStop,OrderOpenPrice());
               }                                          
         buyStop        = NormalizeDouble(buyStop       ,digits);
         currentBuyStop = NormalizeDouble(currentBuyStop,digits);
         
         //
         //
         //
         //
         //

         bool doModifyBuy = (buyStop > NormalizeDouble(OrderStopLoss(),digits)); if (TrailOnlyInProfit) doModifyBuy = (buyStop > currentBuyStop);
         if ( doModifyBuy && (buyStop < maxBuyStop))
         for(c=0 ; c<3; c++)
         {
            OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(buyStop,Digits),OrderTakeProfit(),0,CLR_NONE);
               err=GetLastError();
               checkError(OrderSymbol()+" buy stop loss set to "+DoubleToStr(buyStop,digits),err);
               if(err==4 || err==136 || err==137 || err==138 || err==146)
               {
                  RefreshRates();
                  continue;
               }
            break; 
         }                     
      }   

      //
      //
      //
      //
      //
      
      if (OrderType()==OP_SELL)
      {
         totalProfit += OrderProfit();
         double ask         = MarketInfo(OrderSymbol(),MODE_ASK);
         double minSellStop = NormalizeDouble(ask+MarketInfo(OrderSymbol(),MODE_STOPLEVEL)*point,digits);
            if (OrderStopLoss()==0 && InitialStop > 0)
               {
                  double sellStop        = ask+InitialStop*point*PointRatio;
                  double currentSellStop = sellStop+point;
               }
            else
               {             
                  sellStop        = stopValue(OrderSymbol());
                  currentSellStop = OrderStopLoss(); if(currentSellStop == 0) currentSellStop = OrderOpenPrice();
                  currentSellStop = MathMin(currentSellStop,OrderOpenPrice());
               }                                          
         sellStop        = NormalizeDouble(sellStop       ,digits);
         currentSellStop = NormalizeDouble(currentSellStop,digits);
         
         //
         //
         //
         //
         //
            
         bool doModifySell = (sellStop < NormalizeDouble(OrderStopLoss(),digits) || OrderStopLoss()==0); if (TrailOnlyInProfit) doModifySell = (sellStop < currentSellStop);
         if ( doModifySell && (sellStop > minSellStop))
         for(c=0 ; c<3; c++)
         {
            OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(sellStop,digits),OrderTakeProfit(),0,CLR_NONE);
               err=GetLastError();
               checkError(OrderSymbol()+" sell stop loss set to "+DoubleToStr(sellStop,digits),err);
               if(err==4 || err==136 || err==137 || err==138 || err==146)
               {
                  RefreshRates();
                  continue;
               }
            break; 
         }                     
      }
   }
   
   //
   //
   //
   //
   //
   
   if (CloseWhenProfit>0)
   {
      if ((TimeCurrent()-startTime)>15) totalProfit = colectProfit();
      
      //
      //
      //
      //
      //
      
      if (CloseWhenProfit<totalProfit)
      for (i=OrdersTotal()-1; i>=0; i--)
      { 
         OrderSelect(i, SELECT_BY_POS,MODE_TRADES);
         if (!TrailAllSymbols)
            if (OrderSymbol()!=Symbol())               continue;
            if (OrderMagicNumber() < magicNumber.from) continue;
            if (OrderMagicNumber() > magicNumber.to)   continue;
      
            //
            //
            //
            //
            //
            
            if (OrderType()==OP_BUY || OrderType()==OP_SELL)
            for(c=0 ; c<3; c++)
            {
               OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,CLR_NONE);
                  err=GetLastError();
                  checkError(OrderSymbol()+" order closed",err);
                  if(err==4 || err==136 || err==137 || err==138 || err==146)
                  {
                     RefreshRates();
                     continue;
                  }
                  break; 
            }                     
      }
   }
   return(0);      
}




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

double colectProfit()
{
   double profitSoFar=0;
   
   //
   //
   //
   //
   //
   
   for (int i=OrdersTotal()-1; i>=0; i--)
   { 
      OrderSelect(i, SELECT_BY_POS,MODE_TRADES);
      if (!TrailAllSymbols)
         if (OrderSymbol()!=Symbol())               continue;
         if (OrderMagicNumber() < magicNumber.from) continue;
         if (OrderMagicNumber() > magicNumber.to)   continue;
         if (OrderType()==OP_BUY || OrderType()==OP_SELL)
               profitSoFar += OrderProfit();
   }         
   return(profitSoFar);
}

//
//
//
//
//

double stopValue(string symbol)
{
   double ema = iMA(symbol,EMATimeFrame,EMAPeriod,0,MODE_EMA,Price,EMAShift);
   return(ema);
}





//----------------------------------------------------------------------------------------
//       terminal status handling
//----------------------------------------------------------------------------------------
//
//
//
//
//

bool CheckTerminalStatus()
{
   bool status=false;
   
   //
   //
   //
   //
   //
   
   while(true)
   {
         if (!IsConnected())
             { showTwoStateMessage("connected","No connection to server",False); break; }
         else  showTwoStateMessage("connected","Conected to server",true);
         if ( IsStopped())
             { showTwoStateMessage("stopped","EA stopped",False); break; }  
         else  showTwoStateMessage("stopped","EA started",true);
         if (!IsTradeAllowed())
             { showTwoStateMessage("allowed","Trading not allowed",false); break; }
         else  showTwoStateMessage("allowed","Trading allowed",true);
         if (!IsExpertEnabled() && !IsTesting())
            { showTwoStateMessage("disabled","EA''s are disabled",false); break; }
         else showTwoStateMessage("disabled","EA''s are enabled",true);
         if ( IsTradeContextBusy())
            { showTwoStateMessage("busy","Trade contest busy",false); break; }
         else showTwoStateMessage("busy","Trade contest ready",true);
         
      //
      //
      //
      //
      //
      
      status=true;
      break;
   }
   return(status);
}

//----------------------------------------------------------------------------------------
//       messages handling
//----------------------------------------------------------------------------------------
//
//
//
//
//
//

bool   msg.errState[];
string msg.errNames[];
string msg.messageText[10];
color  msg.messageColor[10];
int    msg.lastMessage=0;

//
//
//
//
//

void checkError(string what,int err)
{
   showMessage(what);
   if(err!=0)
         showMessage("error occured :"+ErrorDescription(err),Red);

}

//
//
//
//
//

void showTwoStateMessage(string name, string message, bool state)
{
   for(int i=ArraySize(msg.errNames)-1; i>-1; i--) if (msg.errNames[i]==name) break;
   if (i==-1)
      {
         int size = ArraySize(msg.errNames)+1;
         i = size-1;
            ArrayResize(msg.errNames,size); msg.errNames[i] = name;
            ArrayResize(msg.errState,size); msg.errState[i] = -1;
      }

   //
   //
   //
   //
   //

   if (msg.errState[i]!= state)
   {   
      msg.errState[i] = state;
      if (state==false)
            showMessage(message,Red);
      else  showMessage(message,Green);
   }      
}

//
//
//
//
//

void showMessage(string text, color theColor=Gray)
{
   if(!showMessages) { Print(text); return; }
   if(msg.lastMessage>9)
   {
      for(int i=0; i<9; i++)
      {
         msg.messageText[i] =msg.messageText[i+1];
         msg.messageColor[i]=msg.messageColor[i+1];
      }
      msg.lastMessage = 9;
   }

   //
   //
   //    set message que text and color
   //
   //
   
      msg.messageText[msg.lastMessage]  = text+" - "+TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS);
      msg.messageColor[msg.lastMessage] = theColor;
   
   //
   //
   //
   //
   //
      
   for(i=0; i<=msg.lastMessage; i++)
   {
      string name = "msg.que"+i;
      if (ObjectFind(name) == -1)
      {
         ObjectCreate(name,OBJ_LABEL,0,0,0);
            ObjectSet(name,OBJPROP_CORNER  ,3);
            ObjectSet(name,OBJPROP_XDISTANCE,5);
            ObjectSet(name,OBJPROP_YDISTANCE,5+14*i);
      }
      ObjectSetText(name,msg.messageText[i],9,"Arial",msg.messageColor[i]);
   }
   msg.lastMessage++;
   WindowRedraw();
}