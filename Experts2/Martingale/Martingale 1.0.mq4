/*========DESCRIÇÃO Martingale 1.0====== 

  
=======================*/

/*=======================================================ANOTAÇÕES========================================================



========================================================================================================================*/
string Robo = "Martingale 2.0";
extern int Slippage = 0;
extern int MagicNumber = 121212;

extern double Lots = 0.01;
extern int lotdecimal = 2; 
extern double LotExponent = 2; 


int ticket,NumOfTrades;
datetime tempo;
double iLots;

int OnInit(){return(INIT_SUCCEEDED);}
  
void OnTick()
  {     

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++FECHAR TODAS ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
   
      
         static int closedOrders=0;
         if(OrdersHistoryTotal()!=closedOrders)
         {
            closedOrders=OrdersHistoryTotal();
            int hstTotal = OrdersHistoryTotal(); 
        
            if(OrderSelect(hstTotal-1,SELECT_BY_POS,MODE_HISTORY))
            {
               tempo = OrderCloseTime();
               if(OrderType()==OP_SELL && OrderMagicNumber()==MagicNumber  )
               {
                  if(OrderOpenPrice()>OrderClosePrice())
                  {
                     bool STOPTUDO = true;
                  }
               }
               
               if(OrderType()==OP_BUY && OrderMagicNumber()==MagicNumber  )
               {
                  if(OrderOpenPrice()<OrderClosePrice())
                  {
                     bool STOPTUDOb = true;
                  }
               }      
           }
        } 
            
            int v, totalv=OrdersTotal();
            for(int i=OrdersTotal()-1; i>=0; i--)   
            {
               if(OrderSelect(v,SELECT_BY_POS)==true)
               {
                 int Tck = OrderTicket();
                 if( STOPTUDO==true || STOPTUDOb==true)  ticket = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,clrPink);
                
                } 
           
            }//FIM CONTADOR  
               
            
      //========================POINT===============================
               double MyPoint=Point;                                      
               if(Digits==3 || Digits==5) MyPoint=Point*10;               
      //============================================================
      double MA = iMA(Symbol(),NULL,5,0,MODE_SMA,PRICE_CLOSE,0);
      

   NumOfTrades = CountTrades();
   //iLots = NormalizeDouble(Lots * MathPow(LotExponent, NumOfTrades), lotdecimal); 
     iLots = Lots+(NumOfTrades*0.02); //anda de 2 em 2. 0.01 - 0.03 - 0.05...
   
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ABERTURA ORDEM++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
   if(Time[0]>=tempo)
   {
      if(OrdersTotal()==0) 
      {
         if(Open[0]>MA) ticket = OrderSend(Symbol(),OP_SELL,iLots,Bid,0,0,Bid-5*MyPoint,NULL,MagicNumber,0,Red);
         if(Open[0]<MA) ticket = OrderSend(Symbol(),OP_BUY,iLots,Ask,0,0,Ask+5*MyPoint,NULL,MagicNumber,0,Blue);
      }    
    }
            
   for (int trade=OrdersTotal()-1; trade>=0; trade--) 
   {
      if (OrderSelect(trade,SELECT_BY_POS, MODE_TRADES)) 
      {
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber)
         {
            
            if(OrderType()==OP_SELL)
            {
               if(Bid-10*MyPoint>OrderOpenPrice()) ticket = OrderSend(Symbol(),OP_SELL,iLots,Bid,0,0,Bid-NumOfTrades*4*MyPoint,NULL,MagicNumber,0,Red);
               break; //Bid-2*NumOfTrades*MyPoint
            }
            if(OrderType()==OP_BUY)
            {
               if(Ask+10*MyPoint<OrderOpenPrice()) ticket = OrderSend(Symbol(),OP_BUY,iLots,Ask,0,0,Ask+NumOfTrades*4*MyPoint,NULL,MagicNumber,0,Blue);
               break;
           }      
         } 
      }     
   }

  
  
  
  
  
  
  
  
  
  
  }//FIM ONTICK
  
//Contar quantas ordens existe em aberto
  
   int CountTrades() {
   int count = 0;
   for (int trade = OrdersTotal() - 1; trade >= 0; trade--) 
   {
      int a = OrderSelect(trade, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
         if (OrderType() == OP_SELL || OrderType() == OP_BUY) count++;
   }
   return (count);
}

  //a- MathPow(3, NumOfTrades)*MyPoint  
         
        /* for (int trade = OrdersTotal() - 1; trade >= 0; trade--) {
         if (OrderSelect(trade, SELECT_BY_POS, MODE_TRADES)) {
            
            if (OrderSymbol() == Symbol() || OrderMagicNumber() == MagicNumber) {
               if (OrderType() == OP_SELL)
               {
               double a = OrderOpenPrice();
                  if(Bid-10*MyPoint>OrderOpenPrice()) ticket = OrderSend(Symbol(),OP_SELL,iLots,Bid,0,0,,NULL,MagicNumber,0,Red);
                  
                  break;
               }
               }
               }
               }
          //a- MathPow(3, NumOfTrades)*MyPoint     
               */