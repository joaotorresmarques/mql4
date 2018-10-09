//+------------------------------------------------------------------+
//|                                                        elvis.mq4 |
//|                                                  ThinkTrustTrade |
//|                                                 euronis-free.com
//
/* The concept


1. Open any currency pair and choose any timeframe

2. Place a Buy order with Take Profit 10 pips and Stop Loss 100 pips and Immediately Place a Sell Order with Take Profit 10 pips and Stop Loss 100 pips.

3. Once any one of the two open orders hit Take Profit, Immediately open two new orders i.e a Buy and a Sell order with TP 10 and SL 100

4. Keep doing this and you will make at least 10% daily returns on equity.


Fine Tuning

1. Once you achieve 10% equity increase, close all open orders and start again

2. If you get a 30% drawdown, close all open orders and begin again

3. Use 0.01 for every $100 */

//+------------------------------------------------------------------+
#property copyright "ProfFX"
#property link      "euronis-free.com"

extern string  Visit="euronis-free.com";
extern string  Like="support@euronis-free.com";
extern string  WARNING=")))";
extern int     stop=0;
extern int     target=50;
extern double  lot=0.1;
extern int     magic_number=1000;
extern int     increase_percent_limit=101;
extern int     drawdown_percent_limit=101;

//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
static int tc;
static double balance;
int init()
{
balance=AccountBalance();
Print("Account balance = ",AccountBalance());
}

int start()
{
int sz=check_closed_number(magic_number);
double current_balance=AccountBalance();
double result=current_balance-balance;
double increase=balance*increase_percent_limit/100;
double dd=-balance*drawdown_percent_limit/100;
 if(current_balance>=balance+increase) 
      {
      Print ("Current Balance: ", current_balance);
      closeall(magic_number);
      balance=current_balance;
      }
   if(current_balance<=balance+dd)
      {
      Print ("Current Balance: ", current_balance);
      //closeall(magic_number);
      balance=current_balance;
      } 
//-------------------------------------------------------------------1

int total=total_open(magic_number);
   if(total==0) 
   {
   open(lot, stop, target, magic_number);
   //-------------------------------------------------------------1.1   
   }
int n=check_last_closed (magic_number); 

if(sz>tc && n==2) {
open(lot, stop, target, magic_number);
tc=sz;
}
if(sz>tc && n==4) {
open(lot, stop, target, magic_number);
tc=sz;
}
//-------------------------------------------------------------------1     
  return(0);
}
//----------------------------------------------------------------------------------------------------------//
void open(double lot, int stop,int target, int magic_number)
{
      //------------------------------------------------------------------------------------------------------
int ticket1=OrderSend(Symbol(),OP_BUY,lot,Ask,5,0,Ask+target*Point,"Elvis Long",magic_number,0,Green);
   if (ticket1==-1)
      {
      Print ("Error opening long position: ", GetLastError());
      Sleep (500);
      if (GetLastError()==148) closeoldest2(magic_number);
      ticket1=OrderSend(Symbol(),OP_BUY,lot,Ask,5,0,Ask+target*Point,"Elvis Long",magic_number,0,Green);
         if (ticket1==-1)
            {
            Print ("Error opening long position: ", GetLastError());
            Sleep (1000);
            ticket1=OrderSend(Symbol(),OP_BUY,lot,Ask,5,0,Ask+target*Point,"Elvis Long",magic_number,0,Green);
            }
      }
if (ticket1>0) Print ("Long position opened: ", ticket1);
int ticket2=OrderSend(Symbol(),OP_SELL,lot,Bid,5,0,Bid-target*Point,"Elvis Short",magic_number,0,Red);
   if (ticket2==-1)
      {
      Print ("Error opening short position: ", GetLastError());
      Sleep (500);
      if (GetLastError()==148) closeoldest2(magic_number);
      ticket2=OrderSend(Symbol(),OP_SELL,lot,Bid,5,0,Bid-target*Point,"Elvis Short",magic_number,0,Red);
         if (ticket2==-1)
            {
            Print ("Error opening short position: ", GetLastError());
            Sleep (1000);
            ticket2=OrderSend(Symbol(),OP_SELL,lot,Bid,5,Bid+stop*Point,Bid-target*Point,"Elvis Short",magic_number,0,Red);
            }
      }
if (ticket2>0) Print ("Short position opened: ", ticket2);
}

//=====================================================================================================

int total_open (int magic)
{
int total=0;
if (OrdersTotal()==0) total=0;
for (int i=OrdersTotal(); i>=0; i--)
         {
               if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)==true)
                  {
                  if (OrderMagicNumber()==magic && OrderSymbol()==Symbol()) total++ ;
                  }
         }
         return (total);
}  
//----------------------------------------------------------------------------------------------------

int check_last_closed (int magic)
{

int n;
int hist=OrdersHistoryTotal();
if(hist==0) 
            {
            n=0;
            return (n);
            }
for (int i=hist; i>=0; i--)
         {
         
               if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)==true)
                 {
                   if (OrderMagicNumber()==magic)
                        {
                           int type=OrderType();
                           double result=OrderProfit();
                           if(type==0 && result<0) n=1; 
                           if(type==0 && result>0) n=2; 
                           if(type==1 && result<0) n=3; 
                           if(type==1 && result>0) n=4; 
                           
                           Comment ("Last closed position: ", OrderTicket(), "Order Type: ", OrderType(), "Magic Number: ", OrderMagicNumber());
                           return (n);
             
                        }     
                  else {
                  n=0;
                  return (n);
                  }
	           
	           }
         }       


}

void closeall(int only_magic)
  {
//----
if (OrdersTotal()==0) return(0);
for (int i=OrdersTotal(); i>=0; i--)
      {
       if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)==true)
            {
            
            if (only_magic>0 && OrderMagicNumber()!=only_magic) continue;
            
            if (OrderType()==0)
               {
               OrderClose(OrderTicket(),OrderLots(), MarketInfo(OrderSymbol(),MODE_BID), 3,Red);
               
               }
            if (OrderType()==1)
               {
               OrderClose(OrderTicket(),OrderLots(), MarketInfo(OrderSymbol(),MODE_ASK), 3,Red);
               
               }   
            }
      }
  
//----
   return(0);
  }
  
int check_closed_number (int magic)
{
int n;
int hist=OrdersHistoryTotal();
if(hist==0) 
            {
            n=0; 
            return (n);
            }
for (int i=hist; i>=0; i--)
         {
         
               if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)==true)
                 {
                    if (OrderMagicNumber()==magic)
                        {
                         n++;               
                        }     
                  }
         }
if (tc==0) tc=n;
return (n);
}

void closeoldest2(int only_magic)
  {
//----
int long_closed=0;
int short_closed=0;
bool closed;
if (OrdersTotal()==0) return(0);
for (int i=0; i<OrdersTotal(); i++)

      {
      
       if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)==true)
            {
            
            if (only_magic>0 && OrderMagicNumber()!=only_magic) continue;
            
            if (OrderType()==0 && long_closed==0)
               {
               closed=OrderClose(OrderTicket(),OrderLots(), MarketInfo(OrderSymbol(),MODE_BID), 3,Red);
               if (closed==true) long_closed=1;
               }
            if (OrderType()==1 && short_closed==0)
               {
               closed=OrderClose(OrderTicket(),OrderLots(), MarketInfo(OrderSymbol(),MODE_ASK), 3,Red);
               if (closed==true) short_closed=1;
               }   
            }
      }
  
//----
   return(0);
  }