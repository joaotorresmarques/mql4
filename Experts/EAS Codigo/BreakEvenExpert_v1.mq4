//+------------------------------------------------------------------+
//|                                           BreakEvenExpert_v1.mq4 |
//|                                  Copyright © 2006, Forex-TSD.com |
//|                         Written by IgorAD,igorad2003@yahoo.co.uk |   
//|            http://finance.groups.yahoo.com/group/TrendLaboratory |                                      
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Forex-TSD.com "
#property link      "http://www.forex-tsd.com/"

//---- input parameters

extern double     BreakEven       = 30;    // Profit Lock in pips  

int      digit=0;

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {

//----
   return(0);
  }

// ---- Trailing Stops
void TrailStops()
{        
    int total=OrdersTotal();
    for (int cnt=0;cnt<total;cnt++)
    { 
     OrderSelect(cnt, SELECT_BY_POS);   
     int mode=OrderType();    
        if ( OrderSymbol()==Symbol() ) 
        {
            if ( mode==OP_BUY )
            {
               if ( Bid-OrderOpenPrice()>Point*BreakEven ) 
               {
               double BuyStop = OrderOpenPrice();
               OrderModify(OrderTicket(),OrderOpenPrice(),
                           NormalizeDouble(BuyStop, digit),
                           OrderTakeProfit(),0,LightGreen);
			      return(0);
			      }
			   }
            if ( mode==OP_SELL )
            {
               if ( OrderOpenPrice()-Ask>Point*BreakEven ) 
               {
               double SellStop = OrderOpenPrice();
               OrderModify(OrderTicket(),OrderOpenPrice(),
   		                  NormalizeDouble(SellStop, digit),
   		                  OrderTakeProfit(),0,Yellow);	    
               return(0);
               }    
            }
         }   
      } 
}

// ---- Scan Trades
int ScanTrades()
{   
   int total = OrdersTotal();
   int numords = 0;
      
   for(int cnt=0; cnt<total; cnt++) 
   {        
   OrderSelect(cnt, SELECT_BY_POS);            
   if(OrderSymbol() == Symbol() && OrderType()<=OP_SELL) 
   numords++;
   }
   return(numords);
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
   digit  = MarketInfo(Symbol(),MODE_DIGITS);

   
   if (ScanTrades()<1) return(0);
   else
   if (BreakEven>0) TrailStops(); 
   
 return(0);
}//int start
//+------------------------------------------------------------------+





